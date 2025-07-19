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
    
    def init_database(self):
        """初始化数据库，创建jobs表"""
        create_table_sql = """
        CREATE TABLE IF NOT EXISTS jobs (
            id SERIAL PRIMARY KEY,
            prompt_text TEXT NOT NULL UNIQUE,
            status TEXT NOT NULL DEFAULT 'pending' 
                CHECK (status IN ('pending', 'processing', 'completed', 'failed')),
            job_type TEXT NOT NULL 
                CHECK (job_type IN ('IMAGE_TEST', 'VIDEO_PROD')),
            local_path TEXT,
            gcs_uri TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        
        -- 创建索引以提高查询性能
        CREATE INDEX IF NOT EXISTS idx_jobs_status ON jobs(status);
        CREATE INDEX IF NOT EXISTS idx_jobs_job_type ON jobs(job_type);
        CREATE INDEX IF NOT EXISTS idx_jobs_created_at ON jobs(created_at);
        
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
        
        try:
            with self.get_connection() as conn:
                with conn.cursor() as cursor:
                    cursor.execute(create_table_sql)
                    conn.commit()
                    logger.info("数据库初始化成功，jobs表已创建")
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