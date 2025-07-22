#!/usr/bin/env python3
"""
配置文件 - 包含Veo3视频生成的各种配置选项
"""
import os
from typing import Dict, Any

# 基础配置
GCP_PROJECT_ID = os.getenv("GOOGLE_CLOUD_PROJECT")
GCP_REGION = os.getenv("GOOGLE_CLOUD_LOCATION", "us-central1")
GCS_OUTPUT_URI = os.getenv("GCS_OUTPUT_BUCKET")

# 模型配置
MODEL_NAME = "veo-3.0-generate-preview"

# 重试配置 - 用于解决503错误
RETRY_CONFIG = {
    "max_retries": int(os.getenv("MAX_RETRIES", "3")),
    "base_delay": int(os.getenv("BASE_DELAY", "5")),
    "max_delay": int(os.getenv("MAX_DELAY", "60")),
    "retryable_errors": [
        "503",
        "service unavailable", 
        "quota exceeded",
        "rate limit",
        "temporary error",
        "internal error"
    ]
}

# 超时配置
TIMEOUT_CONFIG = {
    "operation_timeout": int(os.getenv("OPERATION_TIMEOUT", "1800")),  # 30分钟
    "polling_interval": int(os.getenv("POLLING_INTERVAL", "15")),      # 15秒
    "download_timeout": int(os.getenv("DOWNLOAD_TIMEOUT", "300"))      # 5分钟
}

# 视频生成配置
VIDEO_CONFIG = {
    "aspect_ratio": "16:9",
    "quality": "standard",  # 标准质量
    "duration": 8           # 8秒时长
}

# 日志配置
LOG_CONFIG = {
    "level": os.getenv("LOG_LEVEL", "INFO"),
    "format": "%(asctime)s - %(levelname)s - %(message)s",
    "file": os.getenv("LOG_FILE", "logs/veo3_generation.log")
}

def get_config() -> Dict[str, Any]:
    """
    获取完整配置
    
    Returns:
        包含所有配置的字典
    """
    return {
        "gcp": {
            "project_id": GCP_PROJECT_ID,
            "region": GCP_REGION,
            "output_uri": GCS_OUTPUT_URI
        },
        "model": {
            "name": MODEL_NAME
        },
        "retry": RETRY_CONFIG,
        "timeout": TIMEOUT_CONFIG,
        "video": VIDEO_CONFIG,
        "logging": LOG_CONFIG
    }

def validate_config() -> bool:
    """
    验证配置是否完整
    
    Returns:
        配置是否有效
    """
    required_vars = [
        "GOOGLE_CLOUD_PROJECT",
        "GOOGLE_CLOUD_LOCATION",
        "GCS_OUTPUT_BUCKET"
    ]
    
    missing_vars = []
    for var in required_vars:
        if not os.getenv(var):
            missing_vars.append(var)
    
    if missing_vars:
        print("❌ 缺少必要的环境变量:")
        for var in missing_vars:
            print(f"   - {var}")
        return False
    
    return True 