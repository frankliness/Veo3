#!/usr/bin/env python3
"""
下载工作流DAG - 异步下载生成的文件
"""

from datetime import datetime, timedelta
from airflow import DAG
from airflow.decorators import task
from airflow.operators.python import PythonOperator
from airflow.operators.bash import BashOperator
import os
import sys
import asyncio
import logging

# 添加src目录到Python路径
sys.path.insert(0, '/opt/airflow/src')

from src.downloader import file_downloader
from src.job_manager import JobManager

# 设置日志
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# DAG默认参数
default_args = {
    'owner': 'ai-team',
    'depends_on_past': False,
    'start_date': datetime(2025, 1, 1),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 2,
    'retry_delay': timedelta(minutes=5),
}

# 创建DAG
dag = DAG(
    'download_workflow',
    default_args=default_args,
    description='异步下载生成的文件',
    schedule_interval=timedelta(minutes=5),  # 每5分钟检查一次
    catchup=False,
    max_active_runs=1,
    params={
        "file_type": "all",  # 文件类型过滤: image/video/all
        "max_downloads": 10,  # 每次最大下载数量
        "priority_threshold": 0,  # 优先级阈值
        "force_redownload": False,  # 强制重新下载
    }
)

@task(task_id="scan_download_queue")
def scan_download_queue(**context) -> dict:
    """扫描下载队列，获取待下载任务"""
    
    # 获取DAG参数
    params = context.get('params', {})
    file_type = params.get('file_type', 'all')
    max_downloads = params.get('max_downloads', 10)
    priority_threshold = params.get('priority_threshold', 0)
    
    logger.info(f"扫描下载队列，文件类型: {file_type}, 最大数量: {max_downloads}")
    
    job_manager = JobManager()
    
    # 获取待下载任务
    filter_type = None if file_type == 'all' else file_type
    pending_downloads = job_manager.get_pending_downloads(
        limit=max_downloads, 
        file_type=filter_type
    )
    
    # 过滤优先级
    filtered_downloads = [
        task for task in pending_downloads 
        if task['priority'] >= priority_threshold
    ]
    
    logger.info(f"找到 {len(filtered_downloads)} 个待下载任务")
    
    return {
        'download_tasks': filtered_downloads,
        'total_count': len(filtered_downloads),
        'file_type_filter': file_type
    }

@task(task_id="prepare_download_batch")
def prepare_download_batch(scan_result: dict, **context) -> dict:
    """准备下载批次"""
    
    download_tasks = scan_result['download_tasks']
    
    if not download_tasks:
        logger.info("没有待下载的任务")
        return {
            'has_downloads': False,
            'batch_info': {}
        }
    
    # 按优先级和文件类型分组
    image_tasks = []
    video_tasks = []
    
    for task in download_tasks:
        if task['file_type'] == 'image':
            image_tasks.append(task)
        elif task['file_type'] == 'video':
            video_tasks.append(task)
    
    # 构建下载批次
    batch_info = {
        'image_tasks': image_tasks,
        'video_tasks': video_tasks,
        'total_images': len(image_tasks),
        'total_videos': len(video_tasks),
        'estimated_duration': estimate_download_time(download_tasks)
    }
    
    logger.info(f"准备下载批次 - 图像: {len(image_tasks)}, 视频: {len(video_tasks)}")
    
    return {
        'has_downloads': True,
        'batch_info': batch_info
    }

def estimate_download_time(tasks: list) -> int:
    """估算下载时间（秒）"""
    # 简单估算：图像5秒，视频30秒
    total_seconds = 0
    for task in tasks:
        if task['file_type'] == 'image':
            total_seconds += 5
        elif task['file_type'] == 'video':
            total_seconds += 30
    return total_seconds

@task(task_id="download_images")
def download_images(batch_info: dict, **context) -> dict:
    """下载图像文件"""
    
    logger.info(f"接收到的batch_info: {batch_info}")
    
    # 检查参数有效性
    if not batch_info:
        logger.warning("batch_info为None，尝试从数据库重新获取任务")
        job_manager = JobManager()
        pending_downloads = job_manager.get_pending_downloads(limit=10, file_type='image')
        if pending_downloads:
            image_tasks = pending_downloads
            logger.info(f"从数据库获取到 {len(image_tasks)} 个图像下载任务")
        else:
            logger.info("跳过图像下载，没有任务")
            return {'downloaded': 0, 'failed': 0}
    elif not batch_info.get('has_downloads', False):
        logger.info("跳过图像下载，没有任务")
        return {'downloaded': 0, 'failed': 0}
    else:
        image_tasks = batch_info['batch_info']['image_tasks']
    
    if not image_tasks:
        logger.info("没有图像下载任务")
        return {'downloaded': 0, 'failed': 0}
    
    logger.info(f"开始下载 {len(image_tasks)} 个图像文件")
    
    job_manager = JobManager()
    downloaded = 0
    failed = 0
    
    for task in image_tasks:
        try:
            # 更新状态为下载中
            job_manager.update_download_status(task['id'], 'downloading')
            
            # 执行下载
            result = file_downloader.download_file_sync(
                task['remote_url'], 
                task['local_path'],
                resume=True
            )
            
            if result['success']:
                # 更新为完成状态
                job_manager.update_download_status(
                    task['id'], 
                    'completed',
                    file_size=result['file_size']
                )
                downloaded += 1
                logger.info(f"图像下载成功: {task['local_path']}")
            else:
                # 更新为失败状态
                job_manager.update_download_status(
                    task['id'], 
                    'failed',
                    error_message=result['error']
                )
                failed += 1
                logger.error(f"图像下载失败: {result['error']}")
        
        except Exception as e:
            job_manager.update_download_status(
                task['id'], 
                'failed',
                error_message=str(e)
            )
            failed += 1
            logger.error(f"图像下载异常: {e}")
    
    logger.info(f"图像下载完成 - 成功: {downloaded}, 失败: {failed}")
    
    return {
        'downloaded': downloaded,
        'failed': failed,
        'type': 'image'
    }

@task(task_id="download_videos")
def download_videos(batch_info: dict, **context) -> dict:
    """下载视频文件"""
    
    logger.info(f"接收到的batch_info: {batch_info}")
    
    # 检查参数有效性
    if not batch_info:
        logger.warning("batch_info为None，尝试从数据库重新获取任务")
        job_manager = JobManager()
        pending_downloads = job_manager.get_pending_downloads(limit=10, file_type='video')
        if pending_downloads:
            video_tasks = pending_downloads
            logger.info(f"从数据库获取到 {len(video_tasks)} 个视频下载任务")
        else:
            logger.info("跳过视频下载，没有任务")
            return {'downloaded': 0, 'failed': 0}
    elif not batch_info.get('has_downloads', False):
        logger.info("跳过视频下载，没有任务")
        return {'downloaded': 0, 'failed': 0}
    else:
        video_tasks = batch_info['batch_info']['video_tasks']
    
    if not video_tasks:
        logger.info("没有视频下载任务")
        return {'downloaded': 0, 'failed': 0}
    
    logger.info(f"开始下载 {len(video_tasks)} 个视频文件")
    
    job_manager = JobManager()
    downloaded = 0
    failed = 0
    
    for task in video_tasks:
        try:
            # 更新状态为下载中
            job_manager.update_download_status(task['id'], 'downloading')
            
            # 执行下载（视频文件通常较大，使用更长超时）
            result = file_downloader.download_file_sync(
                task['remote_url'], 
                task['local_path'],
                resume=True
            )
            
            if result['success']:
                # 更新为完成状态
                job_manager.update_download_status(
                    task['id'], 
                    'completed',
                    file_size=result['file_size']
                )
                downloaded += 1
                logger.info(f"视频下载成功: {task['local_path']}")
            else:
                # 更新为失败状态
                job_manager.update_download_status(
                    task['id'], 
                    'failed',
                    error_message=result['error']
                )
                failed += 1
                logger.error(f"视频下载失败: {result['error']}")
        
        except Exception as e:
            job_manager.update_download_status(
                task['id'], 
                'failed',
                error_message=str(e)
            )
            failed += 1
            logger.error(f"视频下载异常: {e}")
    
    logger.info(f"视频下载完成 - 成功: {downloaded}, 失败: {failed}")
    
    return {
        'downloaded': downloaded,
        'failed': failed,
        'type': 'video'
    }

@task(task_id="update_download_stats")
def update_download_stats(image_result: dict, video_result: dict, **context) -> dict:
    """更新下载统计信息"""
    
    total_downloaded = image_result['downloaded'] + video_result['downloaded']
    total_failed = image_result['failed'] + video_result['failed']
    
    logger.info(f"本次下载统计 - 总成功: {total_downloaded}, 总失败: {total_failed}")
    
    # 获取整体统计
    job_manager = JobManager()
    stats = job_manager.get_download_stats()
    
    logger.info(f"整体下载统计: {stats}")
    
    return {
        'current_batch': {
            'images_downloaded': image_result['downloaded'],
            'images_failed': image_result['failed'],
            'videos_downloaded': video_result['downloaded'],
            'videos_failed': video_result['failed'],
            'total_downloaded': total_downloaded,
            'total_failed': total_failed
        },
        'overall_stats': stats
    }

@task(task_id="cleanup_old_records")
def cleanup_old_records(**context) -> dict:
    """清理旧的下载记录"""
    
    job_manager = JobManager()
    
    # 清理7天前的已完成下载记录
    cleaned_count = job_manager.cleanup_old_downloads(days=7)
    
    logger.info(f"清理了 {cleaned_count} 条旧下载记录")
    
    return {'cleaned_records': cleaned_count}

# 定义任务依赖关系
with dag:
    scan_result = scan_download_queue()
    batch_info = prepare_download_batch(scan_result)

    # 并行下载图像和视频
    image_result = download_images(batch_info)
    video_result = download_videos(batch_info)

    # 更新统计和清理
    stats_result = update_download_stats(image_result, video_result)
    cleanup_result = cleanup_old_records()

    # 设置依赖关系
    scan_result >> batch_info >> [image_result, video_result] >> stats_result >> cleanup_result 