#!/usr/bin/env python3
"""
Generate *one* Veo video using the google-genai SDK with Vertex AI backend.
Downloads the generated video to local ./outputs/ directory automatically.
"""
from __future__ import annotations
import os
import time
import logging
import sys
import random

# 添加src目录到路径以便导入utils
current_dir = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, current_dir)

from google.api_core import exceptions
from google import genai
from google.genai.types import GenerateVideosConfig

# 导入本地下载功能
from google.cloud import storage
from urllib.parse import urlparse

# --- 配置 ---
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# 从环境变量加载配置
# 这些需要在运行前设置
# export GOOGLE_CLOUD_PROJECT="your-gcp-project-id"
# export GOOGLE_CLOUD_LOCATION="us-central1"
# export GOOGLE_GENAI_USE_VERTEXAI=True
# export GCS_OUTPUT_BUCKET="gs://your-bucket-name/your-prefix"
GCP_PROJECT_ID = os.getenv("GOOGLE_CLOUD_PROJECT")
GCP_REGION = os.getenv("GOOGLE_CLOUD_LOCATION", "us-central1") # 默认为 us-central1
GCS_OUTPUT_URI = os.getenv("GCS_OUTPUT_BUCKET") # 例如 "gs://my-veo-bucket/outputs"

# 设置环境变量，让 genai SDK 使用 Vertex AI 后端
os.environ["GOOGLE_GENAI_USE_VERTEXAI"] = "True"
if GCP_PROJECT_ID:
    os.environ["GOOGLE_CLOUD_PROJECT"] = GCP_PROJECT_ID
if GCP_REGION:
    os.environ["GOOGLE_CLOUD_LOCATION"] = GCP_REGION

MODEL_NAME = "veo-3.0-generate-preview"

def download_gcs_blob_to_local(gcs_uri: str, local_directory: str = "outputs") -> str:
    """
    Download a video file from Google Cloud Storage to local directory.
    
    Args:
        gcs_uri: The GCS URI (e.g., gs://bucket-name/path/to/video.mp4)
        local_directory: Local directory to save the file (default: "outputs")
    
    Returns:
        Full path to the downloaded local file
    """
    # Parse the GCS URI to extract bucket and blob names
    parsed_uri = urlparse(gcs_uri)
    if parsed_uri.scheme != 'gs':
        raise ValueError(f"Invalid GCS URI: {gcs_uri}. Must start with 'gs://'")
    
    bucket_name = parsed_uri.netloc
    blob_name = parsed_uri.path.lstrip('/')  # Remove leading slash
    
    # Ensure local directory exists
    os.makedirs(local_directory, exist_ok=True)
    
    # Construct local file path using the filename from blob
    filename = os.path.basename(blob_name)
    local_file_path = os.path.join(local_directory, filename)
    
    try:
        # Initialize GCS client
        storage_client = storage.Client()
        
        # Get bucket and blob
        bucket = storage_client.bucket(bucket_name)
        blob = bucket.blob(blob_name)
        
        # Download the file
        blob.download_to_filename(local_file_path)
        
        print(f"✅ Successfully downloaded '{gcs_uri}' to '{local_file_path}'")
        return local_file_path
        
    except Exception as e:
        logging.error(f"Failed to download from GCS: {e}")
        raise Exception(f"GCS download failed: {e}")

def retry_with_exponential_backoff(func, max_retries=3, base_delay=2):
    """
    使用指数退避策略重试函数
    
    Args:
        func: 要重试的函数
        max_retries: 最大重试次数
        base_delay: 基础延迟时间（秒）
    
    Returns:
        函数执行结果
    """
    for attempt in range(max_retries + 1):
        try:
            return func()
        except Exception as e:
            if attempt == max_retries:
                raise e
            
            # 检查是否是503错误或其他可重试的错误
            error_str = str(e).lower()
            if any(keyword in error_str for keyword in ['503', 'service unavailable', 'quota exceeded', 'rate limit']):
                delay = base_delay * (2 ** attempt) + random.uniform(0, 1)
                logging.warning(f"遇到可重试错误 (尝试 {attempt + 1}/{max_retries + 1}): {e}")
                logging.info(f"等待 {delay:.1f} 秒后重试...")
                time.sleep(delay)
            else:
                # 如果不是可重试的错误，直接抛出
                raise e

def generate_video_with_genai(prompt_text: str, output_gcs_uri: str, local_directory: str = "outputs") -> str:
    """
    Generates a video using the google-genai SDK and downloads it to local directory.

    Args:
        prompt_text: The text prompt for video generation.
        output_gcs_uri: The GCS URI where the generated video will be stored.
                        Must start with "gs://".
        local_directory: Local directory to save the downloaded video (default: "outputs")

    Returns:
        The local file path of the downloaded video.

    Raises:
        ValueError: If required environment variables are not set.
        Exception: For API errors or other failures during the process.
    """
    if not all([GCP_PROJECT_ID, GCP_REGION, output_gcs_uri]):
        raise ValueError(
            "Missing required configuration. Please set the following environment variables: "
            "GOOGLE_CLOUD_PROJECT, GOOGLE_CLOUD_LOCATION, GCS_OUTPUT_BUCKET"
        )
    if not output_gcs_uri.startswith("gs://"):
        raise ValueError("GCS_OUTPUT_BUCKET must be a valid GCS URI starting with 'gs://'")

    logging.info("Initializing GenAI Client for Vertex AI...")
    client = genai.Client()

    config = GenerateVideosConfig(
        aspect_ratio="16:9",
        output_gcs_uri=output_gcs_uri,
    )
    
    logging.info(f"Submitting video generation task for prompt: '{prompt_text}'")
    logging.info(f"Using model: {MODEL_NAME}")
    logging.info(f"Output will be saved to: {output_gcs_uri}")

    def submit_and_wait():
        """提交任务并等待完成的内部函数"""
        operation = client.models.generate_videos(
            model=MODEL_NAME,
            prompt=prompt_text,
            config=config,
        )

        logging.info(f"Operation started: {operation.name}. Waiting for completion...")
        
        # 添加超时机制，最多等待30分钟
        max_wait_time = 30 * 60  # 30分钟
        start_time = time.time()
        
        while True:
            current_time = time.time()
            if current_time - start_time > max_wait_time:
                raise Exception("Operation timed out after 30 minutes")
                
            time.sleep(15)  # Wait for 15 seconds before checking status
            try:
                # The operation object is updated in-place by the get method.
                client.operations.get(operation)
                logging.info(f"Polling operation... Status: Done={operation.done}")
                
                # 检查操作是否完成
                if operation.done is True:
                    break
                elif operation.done is False:
                    continue
                else:
                    # operation.done 可能是 None，继续等待
                    logging.info("Operation still in progress...")
                    continue
                    
            except exceptions.NotFound:
                # Sometimes there's a slight delay for the operation to become visible via get.
                logging.warning("Operation not found, retrying in a moment...")
                time.sleep(5)
                client.operations.get(operation)

        if operation.error:
            logging.error(f"Operation failed with an error: {operation.error}")
            raise Exception(f"Video generation failed: {operation.error}")

        if operation.response:
            # The result is nested within the operation object.
            result = operation.result()
            if result and hasattr(result, 'generated_videos') and result.generated_videos:
                video_uri = result.generated_videos[0].video.uri
                logging.info(f"Video generated successfully! GCS URI: {video_uri}")
                
                # Immediately download the video to local directory
                logging.info(f"Downloading video to local directory: {local_directory}")
                local_video_path = download_gcs_blob_to_local(video_uri, local_directory)
                
                logging.info(f"Video saved locally at: {local_video_path}")
                return local_video_path
            else:
                raise Exception("Operation completed, but no video was generated.")
        else:
            raise Exception("Operation completed, but no response was received.")

    # 使用重试机制
    try:
        return retry_with_exponential_backoff(submit_and_wait, max_retries=3, base_delay=5)
    except Exception as e:
        logging.error(f"An unexpected error occurred: {e}")
        raise

if __name__ == '__main__':
    test_prompt = "ASMR, a hot glowing knife cutting through a stack of colored crayons, close up, high quality"
    
    try:
        if not GCS_OUTPUT_URI:
            print("❌ Error: GCS_OUTPUT_BUCKET environment variable is not set.")
            print("Please set it to your GCS bucket URI, e.g., 'gs://your-bucket/outputs'")
        else:
            local_video_path = generate_video_with_genai(test_prompt, GCS_OUTPUT_URI)
            print(f"\n✅ Success! Video has been downloaded to local file: {local_video_path}")
            print(f"📁 You can now find your video at: {os.path.abspath(local_video_path)}")
    except (ValueError, Exception) as e:
        print(f"\n❌ An error occurred: {e}") 