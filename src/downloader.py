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

# 设置日志
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class FileDownloader:
    """高效文件下载器"""
    
    def __init__(self, max_concurrent: int = 3, chunk_size: int = 8192):
        """
        初始化下载器
        
        Args:
            max_concurrent: 最大并发下载数
            chunk_size: 下载块大小
        """
        self.max_concurrent = max_concurrent
        self.chunk_size = chunk_size
        self.semaphore = asyncio.Semaphore(max_concurrent)
    
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
        同步下载文件
        
        Args:
            url: 下载URL
            local_path: 本地保存路径
            resume: 是否支持断点续传
        
        Returns:
            下载结果字典
        """
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
            if os.path.exists(local_path) and self._is_file_complete_sync(url, local_path):
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
            
            logger.info(f"下载完成: {local_path}, 大小: {downloaded} bytes")
            
        except Exception as e:
            result.update({
                'error': str(e),
                'duration': time.time() - start_time
            })
            logger.error(f"下载失败 {url}: {e}")
        
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