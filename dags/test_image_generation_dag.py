"""
⚠️ 测试图像生成DAG ⚠️

此DAG仅用于测试目的，使用低成本的文本到图像模型。
生成的数据标记为"测试数据"，便于清理。

重要警告：
- 此DAG仅用于开发和测试环境
- 使用低成本模型，生成质量可能较低
- 生成的文件会自动标记为测试数据
- 请勿在生产环境中使用此DAG
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

# DAG文档
dag_doc = """
# 测试图像生成工作流

## ⚠️ 重要警告 ⚠️

**此DAG仅用于测试目的！**

### 使用说明：
- 此DAG使用低成本的文本到图像模型
- 生成的文件会自动标记为测试数据（文件名包含`_image_test`）
- 生成的数据质量可能较低，仅用于验证工作流程
- 请勿在生产环境中使用此DAG

### Dry Run模式（默认）：
- **默认启用**：Dry Run模式默认开启，确保零API成本
- **占位符文件**：创建`.txt`占位符文件而不是真实图像
- **完整测试**：验证所有数据库操作、任务依赖和文件I/O
- **安全第一**：防止意外API调用和成本产生

### 真实模式：
- 手动关闭Dry Run开关以启用真实API调用
- 生成真实的`.png`图像文件
- 会产生Google Vertex AI API成本
- 仅用于最终测试和验证

### 工作流程：
1. 从数据库获取待处理的IMAGE_TEST类型作业
2. 根据Dry Run设置决定是否调用API
3. 保存图像或占位符文件到本地outputs目录
4. 更新作业状态为完成

### 清理：
- 测试文件会在24小时后自动清理
- 可以通过手动触发清理任务来立即清理旧文件

### 注意事项：
- 确保Google Cloud凭据已正确配置
- 确保数据库连接正常
- 监控生成的文件大小和存储空间
- **重要**：Dry Run模式默认开启，确保测试安全
"""

@dag(
    dag_id='image_generation_test_workflow',
    default_args=default_args,
    description='测试图像生成工作流 - 仅用于测试目的',
    schedule=None,  # 手动触发
    catchup=False,
    tags=['test', 'image-generation', 'development'],
    doc_md=dag_doc,
    max_active_runs=1,  # 限制并发运行
    concurrency=1,
    params={
        "dry_run": {
            "type": "boolean",
            "default": False,
            "title": "Dry Run Mode",
            "description": "If True, skips the actual API call and creates a placeholder file. Set to False for real API calls."
        }
    }
)
def test_image_generation_dag():
    """
    测试图像生成DAG
    
    此DAG仅用于测试目的，使用低成本的文本到图像模型。
    生成的数据标记为"测试数据"，便于清理。
    """
    
    # 在DAG函数内部导入模块
    try:
        from core_workflow import get_and_lock_job, mark_job_as_completed, mark_job_as_failed
        from image_generator import image_generator
        from database import db_manager
    except ImportError as e:
        logger.error(f"导入模块失败: {e}")
        raise
    
    @task(task_id='initialize_database')
    def initialize_database():
        """初始化数据库表结构"""
        try:
            db_manager.init_database()
            logger.info("数据库初始化完成")
            return "数据库初始化成功"
        except Exception as e:
            logger.error(f"数据库初始化失败: {e}")
            raise
    
    @task(task_id='get_job_task')
    def get_job_task():
        """获取并锁定一个待处理的测试图像作业"""
        try:
            job = get_and_lock_job('IMAGE_TEST')
            if job:
                logger.info(f"成功获取作业: ID={job['id']}, 提示词={job['prompt_text']}")
                return job
            else:
                logger.info("没有可用的测试图像作业")
                return None
        except Exception as e:
            logger.error(f"获取作业失败: {e}")
            raise
    
    @task(task_id='generate_image_task')
    def generate_image_task(job_data, **context):
        """生成测试图像"""
        if not job_data:
            logger.info("跳过图像生成，没有可用作业")
            return None
        
        try:
            job_id = job_data['id']
            prompt_text = job_data['prompt_text']
            
            # 从DAG参数获取dry_run设置
            dry_run_value = context['params'].get('dry_run', True)
            logger.info(f"开始生成图像，作业ID: {job_id}, Dry Run模式: {dry_run_value}")
            
            # 生成图像（传递dry_run参数）
            local_path = image_generator.generate_test_image_and_save(
                prompt_text, 
                dry_run=dry_run_value
            )
            
            mode_text = "DRY RUN" if dry_run_value else "REAL"
            logger.info(f"{mode_text}图像生成完成，保存路径: {local_path}")
            
            return {
                'job_id': job_id,
                'local_path': local_path,
                'prompt_text': prompt_text,
                'dry_run': dry_run_value
            }
            
        except Exception as e:
            logger.error(f"图像生成失败: {e}")
            # 标记作业为失败
            if job_data:
                mark_job_as_failed(job_data['id'], str(e))
            raise
    
    @task(task_id='finalize_job_task')
    def finalize_job_task(generation_result):
        """完成作业处理"""
        if not generation_result:
            logger.info("跳过作业完成，没有生成结果")
            return "跳过完成"
        
        try:
            job_id = generation_result['job_id']
            local_path = generation_result['local_path']
            dry_run = generation_result.get('dry_run', True)
            
            # 标记作业为完成
            success = mark_job_as_completed(job_id, local_path)
            
            if success:
                mode_text = "DRY RUN" if dry_run else "REAL"
                logger.info(f"作业 {job_id} 已成功完成 ({mode_text}模式)")
                return f"作业 {job_id} 完成 ({mode_text}模式)"
            else:
                logger.error(f"无法标记作业 {job_id} 为完成")
                raise Exception(f"无法标记作业 {job_id} 为完成")
                
        except Exception as e:
            logger.error(f"完成作业失败: {e}")
            raise
    
    @task(task_id='cleanup_test_files')
    def cleanup_test_files():
        """清理旧的测试文件"""
        try:
            cleaned_count = image_generator.cleanup_test_files(max_age_hours=24)
            logger.info(f"清理了 {cleaned_count} 个测试文件")
            return f"清理了 {cleaned_count} 个文件"
        except Exception as e:
            logger.error(f"清理测试文件失败: {e}")
            raise
    
    # 定义任务流程
    init_db = initialize_database()
    job_data = get_job_task()
    generation_result = generate_image_task(job_data)
    finalize_result = finalize_job_task(generation_result)
    cleanup = cleanup_test_files()
    
    # 设置任务依赖
    init_db >> job_data >> generation_result >> finalize_result
    cleanup  # 清理任务可以独立运行

# 创建DAG实例
test_dag = test_image_generation_dag() 