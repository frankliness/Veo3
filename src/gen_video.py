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
# export VEOTEST_MODE="true"  # 启用测试模式，不调用真实API
GCP_PROJECT_ID = os.getenv("GOOGLE_CLOUD_PROJECT")
GCP_REGION = os.getenv("GOOGLE_CLOUD_LOCATION", "us-central1") # 默认为 us-central1
GCS_OUTPUT_URI = os.getenv("GCS_OUTPUT_BUCKET") # 例如 "gs://my-veo-bucket/outputs"
VEOTEST_MODE = os.getenv("VEOTEST_MODE", "false").lower() == "true"  # 测试模式

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

def submit_veo_generation_task(prompt_text: str) -> str:
    """
    提交视频生成任务到Veo API

    Args:
        prompt_text: 视频生成提示词

    Returns:
        operation_id: Google Cloud操作ID

    Raises:
        ValueError: 如果配置不完整
        Exception: 如果API调用失败
    """
    if not all([GCP_PROJECT_ID, GCP_REGION, GCS_OUTPUT_URI]):
        raise ValueError(
            "Missing required configuration. Please set the following environment variables: "
            "GOOGLE_CLOUD_PROJECT, GOOGLE_CLOUD_LOCATION, GCS_OUTPUT_BUCKET"
        )
    if not GCS_OUTPUT_URI.startswith("gs://"):
        raise ValueError("GCS_OUTPUT_BUCKET must be a valid GCS URI starting with 'gs://'")

    logging.info("Initializing GenAI Client for Vertex AI...")
    client = genai.Client()

    # 导入配置
    from config import VIDEO_CONFIG

    # 生成唯一的输出URI
    import uuid
    timestamp = int(time.time())
    unique_id = str(uuid.uuid4())[:8]
    output_gcs_uri = f"{GCS_OUTPUT_URI}/video_{timestamp}_{unique_id}.mp4"

    config = GenerateVideosConfig(
        aspect_ratio=VIDEO_CONFIG["aspect_ratio"],
        output_gcs_uri=output_gcs_uri
    )

    logging.info(f"Submitting video generation task for prompt: '{prompt_text}'")
    logging.info(f"Using model: {MODEL_NAME}")
    logging.info(f"Output will be saved to: {output_gcs_uri}")
    logging.info(f"Video config: {VIDEO_CONFIG}")

    def submit_task():
        """提交任务的内部函数"""
        operation = client.models.generate_videos(
            model=MODEL_NAME,
            prompt=prompt_text,
            config=config,
        )
        logging.info(f"Operation submitted successfully: {operation.name}")
        return operation.name

    # 使用重试机制提交任务
    try:
        operation_id = retry_with_exponential_backoff(submit_task, max_retries=3, base_delay=5)
        logging.info(f"Task submitted with operation_id: {operation_id}")
        return operation_id
    except Exception as e:
        logging.error(f"Failed to submit video generation task: {e}")
        raise

def poll_veo_operation_status(operation_id: str) -> str:
    """
    轮询Veo视频生成操作的状态，直到完成
    使用符合官方API规范的HTTP POST请求
    
    Args:
        operation_id: 操作的ID
        
    Returns:
        gcs_uri: 生成的视频在GCS中的URI
    Raises:
        Exception: 如果轮询失败或超时
    """
    if not all([GCP_PROJECT_ID, GCP_REGION]):
        raise ValueError(
            "Missing required configuration. Please set the following environment variables: "
            "GOOGLE_CLOUD_PROJECT, GOOGLE_CLOUD_LOCATION"
        )

    logging.info(f"Polling operation status for: {operation_id}")
    
    # 验证operation_id格式
    def validate_operation_id(op_id: str) -> tuple:
        """
        验证并解析operation_id格式
        
        Returns:
            tuple: (project_id, model_id) 或抛出异常
        """
        if not op_id or not isinstance(op_id, str):
            raise ValueError("Invalid operation_id: must be a non-empty string")
        
        # 期望格式: projects/{PROJECT_ID}/locations/{LOCATION}/publishers/google/models/{MODEL_ID}/operations/{OPERATION_ID}
        if not op_id.startswith("projects/"):
            raise ValueError(f"Invalid operation_id format: {op_id}")
        
        parts = op_id.split("/")
        if len(parts) < 8 or parts[2] != "locations" or parts[4] != "publishers" or parts[5] != "google" or parts[6] != "models" or parts[8] != "operations":
            raise ValueError(f"Invalid operation_id structure: {op_id}")
        
        project_id = parts[1]
        model_id = parts[7]
        
        logging.info(f"Parsed operation_id - Project: {project_id}, Model: {model_id}")
        return project_id, model_id

    # 验证operation_id并解析组件
    try:
        project_id, model_id = validate_operation_id(operation_id)
    except ValueError as e:
        logging.error(f"Operation ID validation failed: {e}")
        raise

    def pre_check_operation():
        """预检轮询：在长时间等待前验证operation的有效性"""
        logging.info("开始预检轮询，验证operation有效性...")
        
        import requests
        import google.auth
        from google.auth.transport.requests import Request
        
        max_pre_check_attempts = 3
        pre_check_delay = 5  # 秒
        
        for attempt in range(max_pre_check_attempts):
            try:
                logging.info(f"预检尝试 {attempt + 1}/{max_pre_check_attempts}")
                
                # 获取认证凭据
                credentials, _ = google.auth.default()
                credentials.refresh(Request())
                
                headers = {
                    'Authorization': f'Bearer {credentials.token}',
                    'Content-Type': 'application/json'
                }
                
                # 构建正确的URL和请求体
                url = f"https://us-central1-aiplatform.googleapis.com/v1/projects/{project_id}/locations/us-central1/publishers/google/models/{model_id}:fetchPredictOperation"
                json_body = {"operationName": operation_id}
                
                # 发送POST请求
                response = requests.post(url, headers=headers, json=json_body, timeout=10)
                
                if response.status_code == 200:
                    op_data = response.json()
                    logging.info(f"✅ 预检成功：operation存在且有效")
                    return True
                elif response.status_code == 404:
                    logging.warning(f"❌ 预检失败：operation不存在 (404)")
                    if attempt < max_pre_check_attempts - 1:
                        logging.info(f"等待 {pre_check_delay} 秒后重试...")
                        time.sleep(pre_check_delay)
                        continue
                    else:
                        raise Exception(f"Operation {operation_id} 不存在或已过期")
                else:
                    logging.error(f"❌ 预检失败：HTTP {response.status_code} - {response.text[:200]}")
                    if attempt < max_pre_check_attempts - 1:
                        logging.info(f"等待 {pre_check_delay} 秒后重试...")
                        time.sleep(pre_check_delay)
                        continue
                    else:
                        raise Exception(f"预检失败：HTTP {response.status_code}")
                        
            except requests.exceptions.Timeout:
                logging.warning(f"❌ 预检超时")
                if attempt < max_pre_check_attempts - 1:
                    logging.info(f"等待 {pre_check_delay} 秒后重试...")
                    time.sleep(pre_check_delay)
                    continue
                else:
                    raise Exception("预检超时：无法连接到API")
            except Exception as e:
                logging.error(f"❌ 预检异常：{e}")
                if attempt < max_pre_check_attempts - 1:
                    logging.info(f"等待 {pre_check_delay} 秒后重试...")
                    time.sleep(pre_check_delay)
                    continue
                else:
                    raise Exception(f"预检失败：{e}")
        
        return False

    def poll_operation():
        """轮询操作状态的主要函数"""
        import requests
        import google.auth
        from google.auth.transport.requests import Request
        
        # 获取认证凭据（在整个轮询过程中只获取一次）
        credentials, _ = google.auth.default()
        credentials.refresh(Request())
        
        headers = {
            'Authorization': f'Bearer {credentials.token}',
            'Content-Type': 'application/json'
        }
        
        # 构建正确的URL和请求体
        url = f"https://us-central1-aiplatform.googleapis.com/v1/projects/{project_id}/locations/us-central1/publishers/google/models/{model_id}:fetchPredictOperation"
        json_body = {"operationName": operation_id}
        
        max_wait_time = 30 * 60  # 30分钟
        start_time = time.time()
        polling_interval = 15  # 15秒间隔

        logging.info(f"开始轮询，最大等待时间: {max_wait_time//60}分钟，轮询间隔: {polling_interval}秒")

        while True:
            current_time = time.time()
            if current_time - start_time > max_wait_time:
                raise Exception(f"Operation {operation_id} timed out after {max_wait_time//60} minutes")

            try:
                # 发送POST请求
                response = requests.post(url, headers=headers, json=json_body, timeout=20)
                
                if response.status_code == 200:
                    op_data = response.json()
                    op_done = op_data.get('done', False)
                    
                    logging.info(f"轮询响应: done={op_done}")
                    
                    if op_done:
                        # 检查是否有错误
                        if 'error' in op_data:
                            error_msg = op_data['error'].get('message', 'Unknown error')
                            error_code = op_data['error'].get('code', 'Unknown code')
                            raise Exception(f"Operation failed - Code: {error_code}, Message: {error_msg}")
                        
                        # 按照实际API响应结构解析GCS URI
                        try:
                            response_data = op_data.get('response', {})
                            videos = response_data.get('videos', [])
                            
                            if videos and len(videos) > 0:
                                video_gcs_uri = videos[0].get('gcsUri')
                                
                                if video_gcs_uri:
                                    logging.info(f"✅ 操作完成，成功提取GCS URI: {video_gcs_uri}")
                                    return video_gcs_uri
                                else:
                                    raise Exception("响应中找不到gcsUri字段")
                            else:
                                raise Exception("响应中找不到videos数组")
                                
                        except Exception as parse_error:
                            logging.error(f"解析响应失败: {parse_error}")
                            logging.error(f"原始响应: {op_data}")
                            raise Exception(f"操作成功但无法解析GCS URI: {parse_error}")
                    else:
                        # 操作仍在进行中
                        elapsed_minutes = (current_time - start_time) / 60
                        logging.info(f"操作进行中... 已等待 {elapsed_minutes:.1f} 分钟")
                        time.sleep(polling_interval)
                        continue
                        
                elif response.status_code == 404:
                    logging.error(f"❌ 轮询失败：operation不存在 (404)")
                    raise Exception(f"Operation {operation_id} not found")
                elif response.status_code == 401:
                    logging.error(f"❌ 认证失败 (401)")
                    raise Exception("Authentication failed")
                elif response.status_code == 403:
                    logging.error(f"❌ 权限不足 (403)")
                    raise Exception("Permission denied")
                else:
                    logging.error(f"❌ HTTP错误: {response.status_code} - {response.text[:200]}")
                    raise Exception(f"HTTP error {response.status_code}: {response.text[:200]}")

            except requests.exceptions.Timeout:
                logging.warning("轮询请求超时，重试中...")
                time.sleep(polling_interval)
                continue
            except Exception as e:
                if "Operation" in str(e) and ("not found" in str(e) or "failed" in str(e) or "timeout" in str(e)):
                    # 这些是不可重试的错误
                    raise e
                else:
                    # 其他错误，可能是网络问题，等待后重试
                    logging.warning(f"轮询过程中遇到错误，等待后重试: {e}")
                    time.sleep(polling_interval)
                    continue

    # 首先进行预检轮询
    try:
        pre_check_operation()
        logging.info("✅ 预检通过，开始正式轮询...")
    except Exception as e:
        logging.error(f"❌ 预检失败，快速失败：{e}")
        raise e

    # 使用重试机制轮询
    try:
        gcs_uri = retry_with_exponential_backoff(poll_operation, max_retries=3, base_delay=5)
        logging.info(f"Video generation completed. GCS URI: {gcs_uri}")
        return gcs_uri
    except Exception as e:
        logging.error(f"Failed to poll operation status: {e}")
        raise

def generate_video_with_genai(prompt_text: str, output_gcs_uri: str = None) -> str:
    """
    使用google-genai SDK生成视频，但不下载到本地
    
    Args:
        prompt_text: 视频生成的文本提示词
        output_gcs_uri: 可选的输出GCS URI，如果未提供则自动生成
        
    Returns:
        str: 生成的视频在GCS中的URI
        
    Raises:
        ValueError: 如果必需的环境变量未设置
        Exception: 如果API调用或生成过程失败
    """
    if not all([GCP_PROJECT_ID, GCP_REGION, GCS_OUTPUT_URI]):
        raise ValueError(
            "Missing required configuration. Please set the following environment variables: "
            "GOOGLE_CLOUD_PROJECT, GOOGLE_CLOUD_LOCATION, GCS_OUTPUT_BUCKET"
        )

    # 如果未提供输出URI，则生成一个
    if not output_gcs_uri:
        import uuid
        timestamp = int(time.time())
        unique_id = str(uuid.uuid4())[:8]
        output_gcs_uri = f"{GCS_OUTPUT_URI}/video_{timestamp}_{unique_id}.mp4"
    
    if not output_gcs_uri.startswith("gs://"):
        raise ValueError("output_gcs_uri must be a valid GCS URI starting with 'gs://'")

    logging.info("Initializing GenAI Client for Vertex AI...")
    client = genai.Client()

    # 导入配置
    from config import VIDEO_CONFIG

    config = GenerateVideosConfig(
        aspect_ratio=VIDEO_CONFIG.get("aspect_ratio", "16:9"),
        output_gcs_uri=output_gcs_uri,
    )
    
    logging.info(f"Submitting video generation task for prompt: '{prompt_text}'")
    logging.info(f"Using model: {MODEL_NAME}")
    logging.info(f"Output will be saved to: {output_gcs_uri}")
    logging.info(f"Video config: {VIDEO_CONFIG}")

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
                
                # 直接返回GCS URI，不再下载到本地
                return video_uri
            else:
                raise Exception("Operation completed, but no video was generated.")
        else:
            raise Exception("Operation completed, but no response was received.")

    # 使用重试机制
    try:
        gcs_uri = retry_with_exponential_backoff(submit_and_wait, max_retries=3, base_delay=5)
        logging.info(f"Video generation completed. GCS URI: {gcs_uri}")
        return gcs_uri
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
            gcs_uri = generate_video_with_genai(test_prompt, GCS_OUTPUT_URI)
            print(f"\n✅ Success! Video has been generated to GCS: {gcs_uri}")
            print(f"📁 You can now find your video at: {gcs_uri}")
    except (ValueError, Exception) as e:
        print(f"\n❌ An error occurred: {e}") 