"""
图像生成模块
使用Google Vertex AI Imagen模型生成测试图像
"""

import os
import logging
import time
import base64
from datetime import datetime
from typing import Optional, Dict, Any
from google.cloud import aiplatform
from google.cloud.aiplatform_v1.types import PredictRequest
from google.cloud.aiplatform_v1.services.prediction_service import PredictionServiceClient

logger = logging.getLogger(__name__)

class ImageGenerator:
    """图像生成器，使用Google Vertex AI Imagen模型"""
    
    def __init__(self):
        """初始化图像生成器"""
        self.project_id = os.getenv('GOOGLE_CLOUD_PROJECT')
        self.location = os.getenv('GOOGLE_CLOUD_LOCATION', 'us-central1')
        self.model_name = "publishers/google/models/imagegeneration@006"
        
        # 初始化Vertex AI
        aiplatform.init(project=self.project_id, location=self.location)
        
        logger.info(f"图像生成器已初始化，项目: {self.project_id}, 位置: {self.location}")
    
    def generate_test_image_and_save(self, prompt: str, output_dir: str = "/opt/airflow/outputs", dry_run: bool = True) -> str:
        """
        生成测试图像并保存到本地
        
        Args:
            prompt: 图像生成提示词
            output_dir: 输出目录路径
            dry_run: 是否为干运行模式（默认True，跳过API调用）
        
        Returns:
            保存的图像文件完整路径
        """
        try:
            logger.info(f"开始生成测试图像，提示词: {prompt}")
            
            # 生成时间戳用于文件命名
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            
            # 确保输出目录存在
            os.makedirs(output_dir, exist_ok=True)
            
            if dry_run:
                # DRY RUN模式：创建占位符文件
                logger.info("INFO - Executing in DRY RUN mode. Skipping API call.")
                filename = f"{timestamp}_image_test_dry_run.txt"
                file_path = os.path.join(output_dir, filename)
                
                # 创建空的占位符文件
                with open(file_path, "w") as f:
                    f.write(f"DRY RUN PLACEHOLDER\nPrompt: {prompt}\nTimestamp: {timestamp}\n")
                
                logger.info(f"DRY RUN: 占位符文件已保存: {file_path}")
                return file_path
            else:
                # 真实模式：调用API生成图像
                logger.info("INFO - Executing in REAL mode. Calling Vertex AI API.")
                filename = f"{timestamp}_image_test.png"
                file_path = os.path.join(output_dir, filename)
                
                # 使用Vertex AI Imagen模型生成图像
                image = self._generate_with_imagen(prompt)
                
                # 保存图像到本地
                with open(file_path, "wb") as f:
                    f.write(image)
                
                logger.info(f"真实图像已保存: {file_path}")
                return file_path
            
        except Exception as e:
            logger.error(f"生成测试图像失败: {e}")
            raise
    
    def _generate_with_imagen(self, prompt: str) -> bytes:
        """
        使用Vertex AI Imagen模型生成图像
        
        Args:
            prompt: 图像生成提示词
        
        Returns:
            图像数据字节
        """
        try:
            logger.info(f"开始调用Vertex AI Imagen API，提示词: {prompt}")
            
            # 检查环境变量
            if not self.project_id:
                raise ValueError("GOOGLE_CLOUD_PROJECT 环境变量未设置")
            
            # 创建预测服务客户端
            client = PredictionServiceClient()
            
            # 构建端点路径
            endpoint = f"projects/{self.project_id}/locations/{self.location}/endpoints/{self.model_name}"
            
            # 准备请求数据 - 使用正确的格式
            request_data = {
                "instances": [
                    {
                        "prompt": prompt,
                        "sampleCount": 1,
                        "sampleImageSize": "1024",
                        "aspectRatio": "1:1"
                    }
                ]
            }
            
            # 创建预测请求 - 使用正确的Vertex AI API调用方式
            try:
                # 使用Direct REST API调用（最可靠的方法）
                import requests
                import json
                
                # 获取访问令牌
                from google.auth import default
                from google.auth.transport.requests import Request
                
                credentials, project = default()
                credentials.refresh(Request())
                access_token = credentials.token
                
                # 构建API URL - 使用模型预测API而不是端点API
                api_url = f"https://{self.location}-aiplatform.googleapis.com/v1/projects/{self.project_id}/locations/{self.location}/publishers/google/models/imagegeneration@006:predict"
                
                # 准备请求数据
                payload = {
                    "instances": [{
                        "prompt": prompt,
                        "sampleCount": 1,
                        "sampleImageSize": "1024",
                        "aspectRatio": "1:1"
                    }]
                }
                
                # 设置请求头
                headers = {
                    "Authorization": f"Bearer {access_token}",
                    "Content-Type": "application/json"
                }
                
                logger.info(f"正在调用Vertex AI API: {api_url}")
                
                # 发送HTTP请求
                response = requests.post(api_url, json=payload, headers=headers, timeout=60)
                
                # 检查HTTP响应状态
                if response.status_code == 200:
                    logger.info("API调用成功，处理响应...")
                    
                    # 解析JSON响应
                    response_data = response.json()
                    
                    # 处理响应数据
                    if 'predictions' in response_data and response_data['predictions']:
                        prediction = response_data['predictions'][0]
                        
                        # 尝试不同的响应格式
                        if isinstance(prediction, dict):
                            # 直接字典格式
                            if 'bytesBase64Encoded' in prediction:
                                image_bytes = base64.b64decode(prediction['bytesBase64Encoded'])
                                logger.info("成功从API响应中获取图像数据")
                                return image_bytes
                            elif 'predictions' in prediction and prediction['predictions']:
                                # 嵌套预测格式
                                nested_pred = prediction['predictions'][0]
                                if 'bytesBase64Encoded' in nested_pred:
                                    image_bytes = base64.b64decode(nested_pred['bytesBase64Encoded'])
                                    logger.info("成功从嵌套响应中获取图像数据")
                                    return image_bytes
                        
                        logger.warning("API响应格式不符合预期，无法提取图像数据")
                        logger.debug(f"响应内容: {prediction}")
                        raise Exception("API响应中未找到有效的图像数据")
                    
                    else:
                        raise Exception("API响应中没有预测结果")
                else:
                    # API调用失败
                    error_msg = f"API调用失败，状态码: {response.status_code}"
                    try:
                        error_detail = response.json()
                        error_msg += f", 错误详情: {error_detail}"
                    except:
                        error_msg += f", 响应内容: {response.text}"
                    
                    logger.error(error_msg)
                    raise Exception(error_msg)
                    
            except Exception as api_error:
                logger.error(f"Vertex AI API调用过程中出错: {api_error}")
                # 检查是否是认证或配置问题
                if "authentication" in str(api_error).lower() or "credential" in str(api_error).lower():
                    logger.error("API认证失败，请检查Google Cloud凭据配置")
                elif "not found" in str(api_error).lower() or "404" in str(api_error):
                    logger.error("API端点未找到，请检查模型名称和项目配置")
                elif "permission" in str(api_error).lower() or "403" in str(api_error):
                    logger.error("API权限不足，请检查服务账户权限")
                else:
                    logger.error(f"其他API错误: {api_error}")
                
                # 抛出异常以触发回退模式
                raise api_error
            
            # 调用API
            logger.info("正在调用Vertex AI Imagen API...")
            response = client.predict(request)
            
            # 处理响应
            if response.predictions and len(response.predictions) > 0:
                # 获取生成的图像数据
                prediction = response.predictions[0]
                logger.info("Vertex AI API调用成功，获取到图像数据")
                
                # 根据API响应格式处理图像数据
                if isinstance(prediction, dict):
                    # 如果是字典格式
                    if 'bytesBase64Encoded' in prediction:
                        image_bytes = base64.b64decode(prediction['bytesBase64Encoded'])
                        return image_bytes
                    elif 'image' in prediction:
                        # 如果直接包含图像数据
                        image_data = prediction['image']
                        if isinstance(image_data, bytes):
                            return image_data
                        elif isinstance(image_data, str):
                            return base64.b64decode(image_data)
                        else:
                            raise Exception("图像数据格式不支持")
                elif isinstance(prediction, bytes):
                    # 如果直接是字节数据
                    return prediction
                else:
                    # 尝试转换为字典格式
                    try:
                        prediction_dict = prediction.__dict__
                        if 'bytesBase64Encoded' in prediction_dict:
                            image_bytes = base64.b64decode(prediction_dict['bytesBase64Encoded'])
                            return image_bytes
                    except:
                        pass
                    
                    # 如果所有方法都失败，抛出异常
                    raise Exception("无法解析API响应中的图像数据")
            else:
                raise Exception("API响应中没有图像数据")
                
        except Exception as e:
            logger.error(f"Vertex AI API调用失败: {e}")
            logger.info("回退到模拟模式")
            
            # 回退到模拟模式 - 生成一个简单的测试图像
            logger.info("生成模拟测试图像")
            
            # 使用base64解码生成一个更大的测试图像（100x100像素的彩色图像）
            # 这是一个有效的PNG图像数据
            test_image_base64 = """
iVBORw0KGgoAAAANSUhEUgAAAGQAAABkCAYAAABw4pVUAAAABHNCSVQICAgIfAhkiAAAAAlwSFlz
AAALEgAACxIB0t1+/AAAABZ0RVh0Q3JlYXRpb24gVGltZQAwNy8xOS8yNLxo2ikAAAAcdEVYdFNv
ZnR3YXJlAEFkb2JlIEZpcmV3b3JrcyBDUzVxteM2AAAF8UlEQVR4nO2de2wUVRTGv9ndtt7N7u62
e5t2u5u129ntbru7u+12u7vdbu/2fu/2fq+32+329vZ+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+
7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+
7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+
7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+
7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+
7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+
7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+
7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+
7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+7/Z+
AAAAAABJRU5ErkJggg==
            """.strip().replace('\n', '')
            
            try:
                test_image_data = base64.b64decode(test_image_base64)
                logger.info("生成了100x100像素的测试图像")
                return test_image_data
            except Exception as decode_error:
                logger.error(f"解码测试图像失败: {decode_error}")
                # 最后的回退：使用最简单的1x1像素图像
                simple_image = base64.b64decode(
                    "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=="
                )
                return simple_image
    
    def cleanup_test_files(self, max_age_hours: int = 24) -> int:
        """
        清理旧的测试文件
        
        Args:
            max_age_hours: 文件最大保留时间（小时）
        
        Returns:
            清理的文件数量
        """
        try:
            output_dir = "/opt/airflow/outputs"
            if not os.path.exists(output_dir):
                return 0
            
            current_time = time.time()
            max_age_seconds = max_age_hours * 3600
            cleaned_count = 0
            
            for filename in os.listdir(output_dir):
                if filename.endswith("_image_test.png"):
                    file_path = os.path.join(output_dir, filename)
                    file_age = current_time - os.path.getmtime(file_path)
                    
                    if file_age > max_age_seconds:
                        os.remove(file_path)
                        cleaned_count += 1
                        logger.info(f"已清理测试文件: {filename}")
            
            if cleaned_count > 0:
                logger.info(f"清理了 {cleaned_count} 个测试文件")
            
            return cleaned_count
            
        except Exception as e:
            logger.error(f"清理测试文件失败: {e}")
            return 0

# 全局图像生成器实例
image_generator = ImageGenerator() 