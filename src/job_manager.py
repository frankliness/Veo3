#!/usr/bin/env python3
"""
作业管理脚本
用于向数据库添加作业、查看作业状态等管理功能
"""

import os
import sys
import argparse
import logging
from typing import List, Optional, Dict

# 设置日志
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# 添加当前目录到Python路径
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from database import db_manager

class JobManager:
    """作业管理器"""
    
    def __init__(self):
        """初始化作业管理器"""
        # 移除自动初始化，改为按需初始化
        pass
    
    def init_database(self):
        """初始化数据库表"""
        try:
            db_manager.init_database()
            logger.info("数据库初始化完成")
        except Exception as e:
            logger.error(f"数据库初始化失败: {e}")
            raise

    def add_download_task(self, job_id: int, remote_url: str, local_path: str, 
                         file_type: str, priority: int = 0) -> int:
        """
        添加下载任务到队列
        
        Args:
            job_id: 关联的作业ID
            remote_url: 远程文件URL
            local_path: 本地保存路径
            file_type: 文件类型 (image/video)
            priority: 优先级 (数字越大优先级越高)
        
        Returns:
            下载任务ID
        """
        try:
            with db_manager.get_connection() as conn:
                cursor = conn.cursor()
                
                cursor.execute('''
                    INSERT INTO download_queue 
                    (job_id, remote_url, local_path, file_type, priority) 
                    VALUES (%s, %s, %s, %s, %s)
                ''', (job_id, remote_url, local_path, file_type, priority))
                
                download_id = cursor.lastrowid
                conn.commit()
                
                logger.info(f"下载任务已添加，ID: {download_id}, 作业ID: {job_id}")
                return download_id
                
        except Exception as e:
            logger.error(f"添加下载任务失败: {e}")
            raise

    def get_pending_downloads(self, limit: int = 10, file_type: str = None) -> List[Dict]:
        """
        获取待下载的任务
        
        Args:
            limit: 最大返回数量
            file_type: 文件类型过滤 (image/video)
        
        Returns:
            待下载任务列表
        """
        try:
            with db_manager.get_connection() as conn:
                cursor = conn.cursor()
                
                base_query = '''
                    SELECT d.*, j.prompt_text, j.job_type 
                    FROM download_queue d
                    LEFT JOIN jobs j ON d.job_id = j.id
                    WHERE d.status = 'pending' 
                    AND d.attempts < d.max_attempts
                '''
                
                params = []
                
                if file_type:
                    base_query += ' AND d.file_type = %s'
                    params.append(file_type)
                
                base_query += ' ORDER BY d.priority DESC, d.created_at ASC LIMIT %s'
                params.append(limit)
                
                cursor.execute(base_query, params)
                
                columns = [description[0] for description in cursor.description]
                downloads = [dict(zip(columns, row)) for row in cursor.fetchall()]
                
                logger.info(f"获取到 {len(downloads)} 个待下载任务")
                return downloads
                
        except Exception as e:
            logger.error(f"获取待下载任务失败: {e}")
            return []

    def update_download_status(self, download_id: int, status: str, 
                              error_message: str = None, file_size: int = None):
        """
        更新下载任务状态
        
        Args:
            download_id: 下载任务ID
            status: 新状态 (pending/downloading/completed/failed)
            error_message: 错误信息
            file_size: 文件大小
        """
        try:
            with db_manager.get_connection() as conn:
                cursor = conn.cursor()
                
                # 更新下载队列状态
                if status == 'downloading':
                    cursor.execute('''
                        UPDATE download_queue 
                        SET status = %s, started_at = CURRENT_TIMESTAMP, 
                            attempts = attempts + 1, updated_at = CURRENT_TIMESTAMP
                        WHERE id = %s
                    ''', (status, download_id))
                    
                elif status == 'completed':
                    cursor.execute('''
                        UPDATE download_queue 
                        SET status = %s, completed_at = CURRENT_TIMESTAMP, 
                            file_size = %s, updated_at = CURRENT_TIMESTAMP
                        WHERE id = %s
                    ''', (status, file_size, download_id))
                    
                    # 同时更新关联作业的状态为completed（如果存在local_path字段）
                    cursor.execute('''
                        UPDATE jobs 
                        SET status = 'completed', 
                            local_path = (SELECT local_path FROM download_queue WHERE id = %s),
                            updated_at = CURRENT_TIMESTAMP
                        WHERE id = (SELECT job_id FROM download_queue WHERE id = %s)
                    ''', (download_id, download_id))
                    
                elif status == 'failed':
                    cursor.execute('''
                        UPDATE download_queue 
                        SET status = %s, error_message = %s, updated_at = CURRENT_TIMESTAMP
                        WHERE id = %s
                    ''', (status, error_message, download_id))
                else:
                    cursor.execute('''
                        UPDATE download_queue 
                        SET status = %s, updated_at = CURRENT_TIMESTAMP
                        WHERE id = %s
                    ''', (status, download_id))
                
                conn.commit()
                logger.info(f"下载任务 {download_id} 状态已更新为: {status}")
                
        except Exception as e:
            logger.error(f"更新下载状态失败: {e}")
            raise

    def get_download_stats(self) -> Dict:
        """获取下载统计信息"""
        try:
            with db_manager.get_connection() as conn:
                cursor = conn.cursor()
                
                # 总体统计
                cursor.execute('''
                    SELECT 
                        status,
                        COUNT(*) as count,
                        COALESCE(SUM(file_size), 0) as total_size
                    FROM download_queue 
                    GROUP BY status
                ''')
                
                stats = {'by_status': {}}
                total_files = 0
                total_size = 0
                
                for row in cursor.fetchall():
                    status, count, size = row
                    stats['by_status'][status] = {
                        'count': count,
                        'total_size': size
                    }
                    total_files += count
                    if status == 'completed':
                        total_size += size
                
                # 按文件类型统计
                cursor.execute('''
                    SELECT 
                        file_type,
                        status,
                        COUNT(*) as count
                    FROM download_queue 
                    GROUP BY file_type, status
                ''')
                
                stats['by_type'] = {}
                for row in cursor.fetchall():
                    file_type, status, count = row
                    if file_type not in stats['by_type']:
                        stats['by_type'][file_type] = {}
                    stats['by_type'][file_type][status] = count
                
                stats['summary'] = {
                    'total_files': total_files,
                    'total_downloaded_size': total_size
                }
                
                return stats
                
        except Exception as e:
            logger.error(f"获取下载统计失败: {e}")
            return {}

    def cleanup_old_downloads(self, days: int = 7) -> int:
        """
        清理旧的已完成下载记录
        
        Args:
            days: 保留天数
        
        Returns:
            清理的记录数
        """
        try:
            with db_manager.get_connection() as conn:
                cursor = conn.cursor()
                
                cursor.execute('''
                    DELETE FROM download_queue 
                    WHERE status = 'completed' 
                    AND completed_at < CURRENT_TIMESTAMP - INTERVAL '{} days'
                '''.format(days))
                
                cleaned_count = cursor.rowcount
                conn.commit()
                
                logger.info(f"清理了 {cleaned_count} 条旧下载记录")
                return cleaned_count
                
        except Exception as e:
            logger.error(f"清理旧下载记录失败: {e}")
            return 0
    
    def add_job(self, prompt_text: str, job_type: str) -> int:
        """添加新作业"""
        try:
            with db_manager.get_connection() as conn:
                cursor = conn.cursor()
                
                # 检查是否已存在相同提示词的作业
                cursor.execute('''
                    SELECT id FROM jobs 
                    WHERE prompt_text = %s AND job_type = %s
                ''', (prompt_text, job_type))
                
                existing = cursor.fetchone()
                if existing:
                    logger.warning(f"作业已存在: {prompt_text}")
                    return existing[0]
                
                # 添加新作业
                cursor.execute('''
                    INSERT INTO jobs (prompt_text, job_type) 
                    VALUES (%s, %s)
                    RETURNING id
                ''', (prompt_text, job_type))
                
                job_id = cursor.fetchone()[0]
                conn.commit()
                
                logger.info(f"成功添加作业，ID: {job_id}, 类型: {job_type}")
                return job_id
                
        except Exception as e:
            logger.error(f"添加作业失败: {e}")
            return 0
    
    def add_test_jobs(self, prompts: List[str]) -> int:
        """批量添加测试作业"""
        success_count = 0
        for prompt in prompts:
            job_id = self.add_job(prompt, 'IMAGE_TEST')
            if job_id > 0:
                success_count += 1
        
        logger.info(f"成功添加 {success_count}/{len(prompts)} 个测试作业")
        return success_count
    
    def show_stats(self):
        """显示作业统计信息"""
        try:
            with db_manager.get_connection() as conn:
                cursor = conn.cursor()
                
                # 获取作业统计
                cursor.execute('''
                    SELECT job_type, status, COUNT(*) as count
                    FROM jobs 
                    GROUP BY job_type, status
                ''')
                
                stats = {}
                for row in cursor.fetchall():
                    job_type, status, count = row
                    if job_type not in stats:
                        stats[job_type] = {}
                    stats[job_type][status] = count
                
                if stats:
                    print("\n=== 作业统计信息 ===")
                    for job_type, status_counts in stats.items():
                        print(f"\n{job_type}:")
                        total = 0
                        for status, count in status_counts.items():
                            print(f"  {status}: {count}")
                            total += count
                        print(f"  总计: {total}")
                else:
                    print("数据库中没有作业")
                    
        except Exception as e:
            logger.error(f"获取统计信息失败: {e}")
    
    def reset_stuck_jobs(self, job_type: Optional[str] = None) -> int:
        """重置卡住的作业"""
        try:
            with db_manager.get_connection() as conn:
                cursor = conn.cursor()
                
                # 重置长时间处于processing状态的作业
                if job_type:
                    cursor.execute('''
                        UPDATE jobs 
                        SET status = 'pending'
                        WHERE status = 'processing' 
                        AND job_type = %s
                        AND updated_at < CURRENT_TIMESTAMP - INTERVAL '1 hour'
                    ''', (job_type,))
                else:
                    cursor.execute('''
                        UPDATE jobs 
                        SET status = 'pending'
                        WHERE status = 'processing'
                        AND updated_at < CURRENT_TIMESTAMP - INTERVAL '1 hour'
                    ''')
                
                count = cursor.rowcount
                conn.commit()
                
                logger.info(f"重置了 {count} 个卡住的作业")
                return count
                
        except Exception as e:
            logger.error(f"重置卡住作业失败: {e}")
            return 0

def main():
    """主函数"""
    parser = argparse.ArgumentParser(description='作业管理工具')
    parser.add_argument('action', choices=['add', 'stats', 'reset'], 
                       help='操作类型: add(添加作业), stats(查看统计), reset(重置卡住作业)')
    parser.add_argument('--prompt', '-p', help='作业提示词')
    parser.add_argument('--type', '-t', choices=['IMAGE_TEST', 'VIDEO_PROD'], 
                       default='IMAGE_TEST', help='作业类型')
    parser.add_argument('--file', '-f', help='包含提示词的文件路径（每行一个）')
    parser.add_argument('--job-type-filter', help='重置时过滤的作业类型')
    
    args = parser.parse_args()
    
    job_manager = JobManager()
    
    if args.action == 'add':
        if args.file:
            # 从文件读取提示词
            try:
                with open(args.file, 'r', encoding='utf-8') as f:
                    prompts = [line.strip() for line in f if line.strip()]
                job_manager.add_test_jobs(prompts)
            except Exception as e:
                logger.error(f"读取文件失败: {e}")
        elif args.prompt:
            # 添加单个作业
            job_manager.add_job(args.prompt, args.type)
        else:
            print("请提供 --prompt 或 --file 参数")
    
    elif args.action == 'stats':
        job_manager.show_stats()
    
    elif args.action == 'reset':
        job_manager.reset_stuck_jobs(args.job_type_filter)

if __name__ == "__main__":
    main() 