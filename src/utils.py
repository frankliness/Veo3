#!/usr/bin/env python3
"""
工具函数 - 包含各种辅助功能
"""
import os
import time
import logging
import random
from typing import Callable, Any, Optional
from google.api_core import exceptions

def setup_logging(log_level: str = "INFO", log_file: Optional[str] = None):
    """
    设置日志配置
    
    Args:
        log_level: 日志级别
        log_file: 日志文件路径（可选）
    """
    # 确保日志目录存在
    if log_file:
        os.makedirs(os.path.dirname(log_file), exist_ok=True)
    
    # 配置日志格式
    log_format = "%(asctime)s - %(levelname)s - %(message)s"
    
    # 设置日志级别
    numeric_level = getattr(logging, log_level.upper(), None)
    if not isinstance(numeric_level, int):
        raise ValueError(f"Invalid log level: {log_level}")
    
    # 配置日志处理器
    handlers = []
    handlers.append(logging.StreamHandler())
    if log_file:
        handlers.append(logging.FileHandler(log_file))
    
    logging.basicConfig(
        level=numeric_level,
        format=log_format,
        handlers=handlers
    )

def is_retryable_error(error: Exception) -> bool:
    """
    判断错误是否可重试
    
    Args:
        error: 异常对象
    
    Returns:
        是否可重试
    """
    error_str = str(error).lower()
    retryable_keywords = [
        "503",
        "service unavailable",
        "quota exceeded", 
        "rate limit",
        "temporary error",
        "internal error",
        "timeout",
        "connection error"
    ]
    
    return any(keyword in error_str for keyword in retryable_keywords)

def retry_with_exponential_backoff(
    func: Callable[[], Any],
    max_retries: int = 3,
    base_delay: float = 2.0,
    max_delay: float = 60.0,
    jitter: bool = True
) -> Any:
    """
    使用指数退避策略重试函数
    
    Args:
        func: 要重试的函数
        max_retries: 最大重试次数
        base_delay: 基础延迟时间（秒）
        max_delay: 最大延迟时间（秒）
        jitter: 是否添加随机抖动
    
    Returns:
        函数执行结果
    
    Raises:
        最后一次尝试的异常
    """
    for attempt in range(max_retries + 1):
        try:
            return func()
        except Exception as e:
            if attempt == max_retries:
                logging.error(f"最终失败，已重试 {max_retries} 次: {e}")
                raise e
            
            if not is_retryable_error(e):
                logging.error(f"遇到不可重试的错误: {e}")
                raise e
            
            # 计算延迟时间
            delay = min(base_delay * (2 ** attempt), max_delay)
            if jitter:
                delay += random.uniform(0, 1)
            
            logging.warning(f"遇到可重试错误 (尝试 {attempt + 1}/{max_retries + 1}): {e}")
            logging.info(f"等待 {delay:.1f} 秒后重试...")
            time.sleep(delay)

def check_gcp_quota_and_permissions():
    """
    检查GCP配额和权限
    
    Returns:
        检查是否通过
    """
    try:
        from google.cloud import storage
        from google.auth import default
        
        # 检查认证
        credentials, project = default()
        if not credentials:
            logging.error("❌ 未找到有效的GCP认证")
            return False
        
        # 检查项目ID
        if not project:
            logging.error("❌ 未设置GCP项目ID")
            return False
        
        # 尝试访问Storage API
        storage_client = storage.Client()
        buckets = list(storage_client.list_buckets(max_results=1))
        
        logging.info(f"✅ GCP认证和权限检查通过，项目ID: {project}")
        return True
        
    except Exception as e:
        logging.error(f"❌ GCP权限检查失败: {e}")
        return False

def validate_environment():
    """
    验证环境配置
    
    Returns:
        环境是否有效
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
        logging.error("❌ 缺少必要的环境变量:")
        for var in missing_vars:
            logging.error(f"   - {var}")
        return False
    
    logging.info("✅ 环境变量检查通过")
    return True

def get_operation_status_info(operation) -> dict:
    """
    获取操作状态的详细信息
    
    Args:
        operation: 操作对象
    
    Returns:
        状态信息字典
    """
    return {
        "name": getattr(operation, 'name', 'Unknown'),
        "done": getattr(operation, 'done', None),
        "error": getattr(operation, 'error', None),
        "response": getattr(operation, 'response', None),
        "metadata": getattr(operation, 'metadata', {})
    }

def log_operation_progress(operation, attempt: int = 1):
    """
    记录操作进度
    
    Args:
        operation: 操作对象
        attempt: 当前尝试次数
    """
    status_info = get_operation_status_info(operation)
    
    logging.info(f"📊 操作状态 (尝试 {attempt}):")
    logging.info(f"   - 名称: {status_info['name']}")
    logging.info(f"   - 完成状态: {status_info['done']}")
    
    if status_info['error']:
        logging.error(f"   - 错误: {status_info['error']}")
    
    if status_info['metadata']:
        logging.info(f"   - 元数据: {status_info['metadata']}") 