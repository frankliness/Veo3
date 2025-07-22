"""
数据库管理模块
负责创建和管理jobs表，提供数据库连接和初始化功能
"""

import os
import psycopg2
from psycopg2.extras import RealDictCursor
from typing import Optional, Dict, Any
import logging

logger = logging.getLogger(__name__)

class DatabaseManager:
    """数据库管理器，负责连接和初始化数据库"""
    
    def __init__(self):
        self.connection_params = {
            'host': 'postgres',
            'port': 5432,
            'database': os.getenv('POSTGRES_DB', 'airflow'),
            'user': os.getenv('POSTGRES_USER', 'airflow'),
            'password': os.getenv('POSTGRES_PASSWORD', 'airflow')
        }
    
    def get_connection(self):
        """获取数据库连接"""
        return psycopg2.connect(**self.connection_params)
    
    def check_table_exists(self, table_name: str = 'jobs') -> bool:
        """检查表是否存在"""
        check_sql = """
        SELECT EXISTS (
            SELECT FROM information_schema.tables 
            WHERE table_schema = 'public' 
            AND table_name = %s
        );
        """
        
        try:
            with self.get_connection() as conn:
                with conn.cursor() as cursor:
                    cursor.execute(check_sql, (table_name,))
                    exists = cursor.fetchone()[0]
                    return exists
        except Exception as e:
            logger.error(f"检查表是否存在失败: {e}")
            return False
    
    def init_database(self):
        """初始化数据库，创建jobs表和download_queue表"""
        # 首先检查jobs表是否已存在
        jobs_exists = self.check_table_exists('jobs')
        downloads_exists = self.check_table_exists('download_queue')
        
        if jobs_exists and downloads_exists:
            logger.info("所有表已存在，跳过初始化")
            return
        
        create_table_sql = """
        CREATE TABLE IF NOT EXISTS jobs (
            id SERIAL PRIMARY KEY,
            prompt_text TEXT NOT NULL UNIQUE,
            status TEXT NOT NULL DEFAULT 'pending' 
                CHECK (status IN ('pending', 'processing', 'completed', 'failed', 'awaiting_retry', 'generation_successful')),
            job_type TEXT NOT NULL 
                CHECK (job_type IN ('IMAGE_TEST', 'VIDEO_PROD')),
            local_path TEXT,
            gcs_uri TEXT,
            operation_id TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        
        -- 创建索引以提高查询性能
        CREATE INDEX IF NOT EXISTS idx_jobs_status ON jobs(status);
        CREATE INDEX IF NOT EXISTS idx_jobs_job_type ON jobs(job_type);
        CREATE INDEX IF NOT EXISTS idx_jobs_created_at ON jobs(created_at);
        CREATE INDEX IF NOT EXISTS idx_jobs_operation_id ON jobs(operation_id);
        
        -- 创建触发器自动更新updated_at
        CREATE OR REPLACE FUNCTION update_updated_at_column()
        RETURNS TRIGGER AS $$
        BEGIN
            NEW.updated_at = CURRENT_TIMESTAMP;
            RETURN NEW;
        END;
        $$ language 'plpgsql';
        
        DROP TRIGGER IF EXISTS update_jobs_updated_at ON jobs;
        CREATE TRIGGER update_jobs_updated_at
            BEFORE UPDATE ON jobs
            FOR EACH ROW
            EXECUTE FUNCTION update_updated_at_column();
        """
        
        # 如果表已存在，添加缺失的字段
        alter_table_sql = """
        DO $$
        BEGIN
            -- 添加operation_id字段（如果不存在）
            IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                          WHERE table_name = 'jobs' AND column_name = 'operation_id') THEN
                ALTER TABLE jobs ADD COLUMN operation_id TEXT;
            END IF;
            
            -- 更新status约束以包含新的状态值
            IF EXISTS (SELECT 1 FROM information_schema.check_constraints 
                      WHERE constraint_name = 'jobs_status_check') THEN
                ALTER TABLE jobs DROP CONSTRAINT jobs_status_check;
            END IF;
            
            ALTER TABLE jobs ADD CONSTRAINT jobs_status_check 
            CHECK (status IN ('pending', 'processing', 'completed', 'failed', 'awaiting_retry', 'generation_successful'));
        END $$;
        """
        
        try:
            with self.get_connection() as conn:
                with conn.cursor() as cursor:
                    cursor.execute(create_table_sql)
                    cursor.execute(alter_table_sql)
                    conn.commit()
                    logger.info("jobs表已创建/更新")
                    
                    # 创建download_queue表
                    if not downloads_exists:
                        download_queue_sql = """
                        CREATE TABLE IF NOT EXISTS download_queue (
                            id SERIAL PRIMARY KEY,
                            job_id INTEGER REFERENCES jobs(id) ON DELETE CASCADE,
                            remote_url TEXT NOT NULL,
                            local_path TEXT NOT NULL,
                            file_type TEXT NOT NULL CHECK (file_type IN ('image', 'video')),
                            file_size BIGINT,
                            status TEXT NOT NULL DEFAULT 'pending' 
                                CHECK (status IN ('pending', 'downloading', 'completed', 'failed')),
                            priority INTEGER DEFAULT 0,
                            attempts INTEGER DEFAULT 0,
                            max_attempts INTEGER DEFAULT 3,
                            error_message TEXT,
                            started_at TIMESTAMP,
                            completed_at TIMESTAMP,
                            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                        );
                        
                        -- 创建索引
                        CREATE INDEX IF NOT EXISTS idx_download_queue_status ON download_queue(status);
                        CREATE INDEX IF NOT EXISTS idx_download_queue_job_id ON download_queue(job_id);
                        CREATE INDEX IF NOT EXISTS idx_download_queue_priority ON download_queue(priority);
                        CREATE INDEX IF NOT EXISTS idx_download_queue_created_at ON download_queue(created_at);
                        
                        -- 为download_queue表创建updated_at触发器
                        CREATE TRIGGER update_download_queue_updated_at BEFORE UPDATE
                        ON download_queue FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
                        """
                        
                        cursor.execute(download_queue_sql)
                        conn.commit()
                        logger.info("download_queue表已创建")
                    
                    logger.info("数据库初始化成功，所有表已创建/更新")
        except Exception as e:
            logger.error(f"数据库初始化失败: {e}")
            raise
    
    def add_job(self, prompt_text: str, job_type: str) -> Optional[int]:
        """添加新作业到队列"""
        insert_sql = """
        INSERT INTO jobs (prompt_text, job_type)
        VALUES (%s, %s)
        RETURNING id
        """
        
        try:
            with self.get_connection() as conn:
                with conn.cursor() as cursor:
                    cursor.execute(insert_sql, (prompt_text, job_type))
                    job_id = cursor.fetchone()[0]
                    conn.commit()
                    logger.info(f"作业已添加到队列，ID: {job_id}, 类型: {job_type}")
                    return job_id
        except psycopg2.IntegrityError as e:
            if "unique constraint" in str(e).lower():
                logger.warning(f"重复的prompt_text: {prompt_text}")
                return None
            raise
        except Exception as e:
            logger.error(f"添加作业失败: {e}")
            raise
    
    def get_job_stats(self) -> Dict[str, Any]:
        """获取作业统计信息"""
        stats_sql = """
        SELECT 
            job_type,
            status,
            COUNT(*) as count
        FROM jobs 
        GROUP BY job_type, status
        ORDER BY job_type, status
        """
        
        try:
            with self.get_connection() as conn:
                with conn.cursor(cursor_factory=RealDictCursor) as cursor:
                    cursor.execute(stats_sql)
                    results = cursor.fetchall()
                    
                    stats = {}
                    for row in results:
                        job_type = row['job_type']
                        status = row['status']
                        count = row['count']
                        
                        if job_type not in stats:
                            stats[job_type] = {}
                        stats[job_type][status] = count
                    
                    return stats
        except Exception as e:
            logger.error(f"获取作业统计失败: {e}")
            return {}

# 全局数据库管理器实例
db_manager = DatabaseManager() 