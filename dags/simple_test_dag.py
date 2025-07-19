"""
简化的测试DAG，用于验证模块导入
"""

import sys
import os
from datetime import datetime, timedelta
from airflow import DAG
from airflow.decorators import dag, task
import logging

# 添加src目录到Python路径
sys.path.append('/opt/airflow/src')

logger = logging.getLogger(__name__)

# DAG配置
default_args = {
    'owner': 'ai-team',
    'depends_on_past': False,
    'start_date': datetime(2024, 1, 1),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

@dag(
    dag_id='simple_test_workflow',
    default_args=default_args,
    description='简化的测试工作流',
    schedule=None,
    catchup=False,
    tags=['test', 'simple']
)
def simple_test_dag():
    """
    简化的测试DAG
    """
    
    @task(task_id='test_import')
    def test_import():
        """测试模块导入"""
        try:
            # 测试导入
            from database import db_manager
            logger.info("✅ 成功导入 database 模块")
            
            from core_workflow import get_and_lock_job
            logger.info("✅ 成功导入 core_workflow 模块")
            
            from image_generator import image_generator
            logger.info("✅ 成功导入 image_generator 模块")
            
            return "所有模块导入成功"
            
        except ImportError as e:
            logger.error(f"❌ 模块导入失败: {e}")
            raise
        except Exception as e:
            logger.error(f"❌ 其他错误: {e}")
            raise
    
    @task(task_id='test_database')
    def test_database():
        """测试数据库连接"""
        try:
            from database import db_manager
            
            # 测试数据库连接
            with db_manager.get_connection() as conn:
                with conn.cursor() as cursor:
                    cursor.execute("SELECT 1")
                    result = cursor.fetchone()
                    if result and result[0] == 1:
                        logger.info("✅ 数据库连接测试成功")
                        return "数据库连接正常"
                    else:
                        raise Exception("数据库连接测试失败")
                        
        except Exception as e:
            logger.error(f"❌ 数据库测试失败: {e}")
            raise
    
    # 定义任务流程
    import_test = test_import()
    db_test = test_database()
    
    # 设置任务依赖
    import_test >> db_test

# 创建DAG实例
simple_dag = simple_test_dag() 