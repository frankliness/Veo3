#!/usr/bin/env python3
"""
文件下载器 - 支持异步下载和断点续传
"""

import os
import time
import asyncio
import aiohttp
import requests
from typing import List, Dict, Optional
from datetime import datetime
import logging
from pathlib import Path
import hashlib
import logging
from typing import Dict, List, Optional
from google.cloud import storage
from google.auth import default

# 设置日志
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class FileDownloader:
    """
    文件下载器 - 支持HTTP和GCS下载
    """
    
    def __init__(self, max_concurrent: int = 3, chunk_size: int = 8192):
        self.max_concurrent = max_concurrent
        self.chunk_size = chunk_size
        self.semaphore = asyncio.Semaphore(max_concurrent)
        
        # 初始化GCS客户端
        try:
            self.gcs_client = storage.Client()
            logger.info("GCS客户端初始化成功")
        except Exception as e:
            logger.warning(f"GCS客户端初始化失败: {e}")
            self.gcs_client = None
    
    def _is_gcs_uri(self, url: str) -> bool:
        """检查是否为GCS URI"""
        return url.startswith('gs://')
    
    def _parse_gcs_uri(self, gcs_uri: str) -> tuple:
        """解析GCS URI为bucket和blob名称"""
        if not gcs_uri.startswith('gs://'):
            raise ValueError(f"Invalid GCS URI: {gcs_uri}")
        
        # 移除gs://前缀
        path = gcs_uri[5:]
        
        # 分割bucket和blob名称
        if '/' not in path:
            raise ValueError(f"Invalid GCS URI format: {gcs_uri}")
        
        bucket_name = path.split('/')[0]
        blob_name = '/'.join(path.split('/')[1:])
        
        return bucket_name, blob_name
    
    def _download_from_gcs(self, gcs_uri: str, local_path: str, resume: bool = True) -> Dict:
        """从GCS下载文件"""
        result = {
            'success': False,
            'error': None,
            'file_size': 0,
            'downloaded_size': 0,
            'duration': 0,
            'resumed': False
        }
        
        start_time = time.time()
        
        try:
            if not self.gcs_client:
                raise Exception("GCS客户端未初始化")
            
            bucket_name, blob_name = self._parse_gcs_uri(gcs_uri)
            logger.info(f"从GCS下载: bucket={bucket_name}, blob={blob_name}")
            
            bucket = self.gcs_client.bucket(bucket_name)
            blob = bucket.blob(blob_name)
            
            # 检查blob是否存在
            if not blob.exists():
                raise Exception(f"GCS blob不存在: {gcs_uri}")
            
            # 获取文件大小
            blob.reload()
            total_size = blob.size
            result['file_size'] = total_size
            
            # 检查是否需要断点续传
            resume_pos = 0
            if resume and os.path.exists(local_path):
                resume_pos = os.path.getsize(local_path)
                if resume_pos >= total_size:
                    # 文件大小匹配，但需要进一步验证内容
                    # 对于GCS文件，我们可以检查文件的最后修改时间或使用更严格的验证
                    # 这里我们采用保守策略：如果文件存在且大小匹配，仍然重新下载以确保内容正确
                    logger.info(f"文件大小匹配，但为确保内容正确，重新下载: {local_path}")
                    # 删除现有文件，重新下载
                    os.remove(local_path)
                    resume_pos = 0
                else:
                    logger.info(f"断点续传，起始位置: {resume_pos}")
            
            # 确保目录存在
            os.makedirs(os.path.dirname(local_path), exist_ok=True)
            
            # 下载文件
            mode = 'ab' if resume_pos > 0 else 'wb'
            downloaded = resume_pos
            
            with open(local_path, mode) as f:
                # 使用GCS的download_to_file方法，支持断点续传
                if resume_pos > 0:
                    # 对于断点续传，我们需要手动处理
                    # 先获取blob的字节范围
                    blob.download_to_file(f, start=resume_pos)
                    downloaded = total_size
                else:
                    blob.download_to_file(f)
                    downloaded = total_size
            
            result.update({
                'success': True,
                'downloaded_size': downloaded,
                'duration': time.time() - start_time,
                'resumed': resume_pos > 0
            })
            
            logger.info(f"GCS下载完成: {local_path}, 大小: {downloaded} bytes")
            
        except Exception as e:
            result.update({
                'error': str(e),
                'duration': time.time() - start_time
            })
            logger.error(f"GCS下载失败 {gcs_uri}: {e}")
        
        return result
    
    async def download_file(self, url: str, local_path: str, 
                           resume: bool = True, progress_callback = None) -> Dict:
        """
        异步下载文件
        
        Args:
            url: 下载URL
            local_path: 本地保存路径
            resume: 是否支持断点续传
            progress_callback: 进度回调函数
        
        Returns:
            下载结果字典
        """
        async with self.semaphore:
            start_time = time.time()
            result = {
                'url': url,
                'local_path': local_path,
                'success': False,
                'file_size': 0,
                'downloaded_size': 0,
                'duration': 0,
                'error': None
            }
            
            try:
                # 确保目标目录存在
                os.makedirs(os.path.dirname(local_path), exist_ok=True)
                
                # 检查是否已下载且完整
                if os.path.exists(local_path) and await self._is_file_complete(url, local_path):
                    result.update({
                        'success': True,
                        'file_size': os.path.getsize(local_path),
                        'downloaded_size': os.path.getsize(local_path),
                        'duration': 0,
                        'resumed': False
                    })
                    logger.info(f"文件已存在且完整: {local_path}")
                    return result
                
                # 计算起始位置（断点续传）
                resume_pos = 0
                if resume and os.path.exists(local_path):
                    resume_pos = os.path.getsize(local_path)
                    logger.info(f"断点续传，起始位置: {resume_pos}")
                
                # 开始下载
                headers = {}
                if resume_pos > 0:
                    headers['Range'] = f'bytes={resume_pos}-'
                
                async with aiohttp.ClientSession() as session:
                    async with session.get(url, headers=headers) as response:
                        
                        # 检查响应状态
                        if response.status not in [200, 206]:
                            raise Exception(f"HTTP错误: {response.status}")
                        
                        # 获取文件总大小
                        total_size = resume_pos
                        if 'content-length' in response.headers:
                            total_size += int(response.headers['content-length'])
                        
                        result['file_size'] = total_size
                        
                        # 下载文件
                        mode = 'ab' if resume_pos > 0 else 'wb'
                        downloaded = resume_pos
                        
                        with open(local_path, mode) as f:
                            async for chunk in response.content.iter_chunked(self.chunk_size):
                                f.write(chunk)
                                downloaded += len(chunk)
                                result['downloaded_size'] = downloaded
                                
                                # 调用进度回调
                                if progress_callback:
                                    progress = downloaded / total_size if total_size > 0 else 0
                                    await progress_callback(progress, downloaded, total_size)
                        
                        result.update({
                            'success': True,
                            'duration': time.time() - start_time,
                            'resumed': resume_pos > 0
                        })
                        
                        logger.info(f"下载完成: {local_path}, 大小: {downloaded} bytes")
                        
            except Exception as e:
                result.update({
                    'error': str(e),
                    'duration': time.time() - start_time
                })
                logger.error(f"下载失败 {url}: {e}")
            
            return result
    
    async def _is_file_complete(self, url: str, local_path: str) -> bool:
        """检查本地文件是否完整"""
        try:
            # 获取远程文件大小
            async with aiohttp.ClientSession() as session:
                async with session.head(url) as response:
                    if 'content-length' in response.headers:
                        remote_size = int(response.headers['content-length'])
                        local_size = os.path.getsize(local_path)
                        return local_size == remote_size
            return True  # 无法获取远程大小时，假设完整
        except:
            return False
    
    def download_file_sync(self, url: str, local_path: str, 
                          resume: bool = True) -> Dict:
        """
        同步下载文件（支持HTTP和GCS）
        
        Args:
            url: 文件URL或GCS URI
            local_path: 本地保存路径
            resume: 是否支持断点续传
        
        Returns:
            下载结果字典
        """
        # 检查是否为GCS URI
        if self._is_gcs_uri(url):
            logger.info(f"检测到GCS URI，使用GCS下载: {url}")
            return self._download_from_gcs(url, local_path, resume)
        
        # 原有的HTTP下载逻辑
        result = {
            'success': False,
            'error': None,
            'file_size': 0,
            'downloaded_size': 0,
            'duration': 0,
            'resumed': False
        }
        
        start_time = time.time()
        
        try:
            # 确保目录存在
            os.makedirs(os.path.dirname(local_path), exist_ok=True)
            
            # 检查文件是否已存在且完整
            if resume and os.path.exists(local_path):
                if self._is_file_complete_sync(url, local_path):
                    result.update({
                        'success': True,
                        'file_size': os.path.getsize(local_path),
                        'downloaded_size': os.path.getsize(local_path),
                        'duration': 0,
                        'resumed': False
                    })
                    logger.info(f"文件已存在且完整: {local_path}")
                    return result
            
            # 计算起始位置（断点续传）
            resume_pos = 0
            if resume and os.path.exists(local_path):
                resume_pos = os.path.getsize(local_path)
                logger.info(f"断点续传，起始位置: {resume_pos}")
            
            # 开始下载
            headers = {}
            if resume_pos > 0:
                headers['Range'] = f'bytes={resume_pos}-'
            
            response = requests.get(url, headers=headers, stream=True, timeout=300)
            response.raise_for_status()
            
            # 获取文件总大小
            total_size = resume_pos
            if 'content-length' in response.headers:
                total_size += int(response.headers['content-length'])
            
            result['file_size'] = total_size
            
            # 下载文件
            mode = 'ab' if resume_pos > 0 else 'wb'
            downloaded = resume_pos
            
            with open(local_path, mode) as f:
                for chunk in response.iter_content(chunk_size=self.chunk_size):
                    if chunk:
                        f.write(chunk)
                        downloaded += len(chunk)
                        result['downloaded_size'] = downloaded
            
            result.update({
                'success': True,
                'duration': time.time() - start_time,
                'resumed': resume_pos > 0
            })
            
            logger.info(f"HTTP下载完成: {local_path}, 大小: {downloaded} bytes")
            
        except Exception as e:
            result.update({
                'error': str(e),
                'duration': time.time() - start_time
            })
            logger.error(f"HTTP下载失败 {url}: {e}")
        
        return result
    
    def _is_file_complete_sync(self, url: str, local_path: str) -> bool:
        """同步检查本地文件是否完整"""
        try:
            response = requests.head(url, timeout=30)
            if 'content-length' in response.headers:
                remote_size = int(response.headers['content-length'])
                local_size = os.path.getsize(local_path)
                return local_size == remote_size
            return True
        except:
            return False
    
    async def batch_download(self, download_tasks: List[Dict], 
                           progress_callback = None) -> List[Dict]:
        """
        批量异步下载
        
        Args:
            download_tasks: 下载任务列表，每个任务包含url和local_path
            progress_callback: 整体进度回调
        
        Returns:
            下载结果列表
        """
        total_tasks = len(download_tasks)
        completed_tasks = 0
        results = []
        
        async def download_with_progress(task):
            nonlocal completed_tasks
            
            result = await self.download_file(
                task['url'], 
                task['local_path'],
                task.get('resume', True)
            )
            
            completed_tasks += 1
            
            if progress_callback:
                await progress_callback(completed_tasks, total_tasks, result)
            
            return result
        
        # 并发下载
        tasks = [download_with_progress(task) for task in download_tasks]
        results = await asyncio.gather(*tasks, return_exceptions=True)
        
        # 处理异常结果
        processed_results = []
        for i, result in enumerate(results):
            if isinstance(result, Exception):
                processed_results.append({
                    'url': download_tasks[i]['url'],
                    'local_path': download_tasks[i]['local_path'],
                    'success': False,
                    'error': str(result)
                })
            else:
                processed_results.append(result)
        
        return processed_results

# 全局下载器实例
file_downloader = FileDownloader() 