"""
Veo视频生成DAG示例
展示如何在Airflow中集成Veo3视频生成功能
"""
from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.operators.bash import BashOperator
from airflow.models import Variable
import os
import sys

# 添加src目录到Python路径
sys.path.append('/opt/airflow/src')

# 导入我们的视频生成模块
from gen_video import generate_video_with_genai
from utils import setup_logging, validate_environment, check_gcp_quota_and_permissions

# 默认参数
default_args = {
    'owner': 'veo-team',
    'depends_on_past': False,
    'start_date': datetime(2024, 1, 1),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 3,
    'retry_delay': timedelta(minutes=5),
}

# 创建DAG
dag = DAG(
    'veo_video_generation',
    default_args=default_args,
    description='使用Veo3生成视频的DAG',
    schedule_interval=timedelta(hours=1),
    catchup=False,
    tags=['veo', 'video-generation', 'ai'],
)

def setup_environment(**context):
    """设置环境并验证配置"""
    print("🔧 设置环境...")
    
    # 设置日志
    setup_logging("INFO", "/opt/airflow/logs/veo_dag.log")
    
    # 验证环境变量
    if not validate_environment():
        raise Exception("环境变量验证失败")
    
    # 检查GCP权限
    if not check_gcp_quota_and_permissions():
        raise Exception("GCP权限检查失败")
    
    print("✅ 环境设置完成")
    return "environment_ready"

def generate_video_task(**context):
    """生成视频的任务"""
    print("🎬 开始生成视频...")
    
    # 从Airflow变量或环境变量获取配置
    prompt = Variable.get("veo_prompt", default_var="A beautiful sunset over the ocean, high quality")
    output_bucket = os.getenv('GCS_OUTPUT_BUCKET')
    
    if not output_bucket:
        raise Exception("GCS_OUTPUT_BUCKET环境变量未设置")
    
    try:
        # 生成视频
        local_video_path = generate_video_with_genai(
            prompt_text=prompt,
            output_gcs_uri=output_bucket
        )
        
        print(f"✅ 视频生成成功: {local_video_path}")
        
        # 将结果传递给下一个任务
        context['task_instance'].xcom_push(key='video_path', value=local_video_path)
        
        return local_video_path
        
    except Exception as e:
        print(f"❌ 视频生成失败: {e}")
        raise e

def post_process_video(**context):
    """视频后处理任务"""
    print("🔧 开始后处理...")
    
    # 从上一个任务获取视频路径
    video_path = context['task_instance'].xcom_pull(task_ids='generate_video', key='video_path')
    
    if not video_path:
        raise Exception("未找到视频文件路径")
    
    print(f"📹 处理视频: {video_path}")
    
    # 这里可以添加视频处理逻辑
    # 例如：压缩、格式转换、添加水印等
    
    print("✅ 后处理完成")
    return "post_processing_complete"

def cleanup_task(**context):
    """清理任务"""
    print("🧹 开始清理...")
    
    # 清理临时文件
    cleanup_command = "find /opt/airflow/outputs -name '*.tmp' -delete"
    os.system(cleanup_command)
    
    print("✅ 清理完成")
    return "cleanup_complete"

# 定义任务
setup_task = PythonOperator(
    task_id='setup_environment',
    python_callable=setup_environment,
    dag=dag,
)

generate_video_task_op = PythonOperator(
    task_id='generate_video',
    python_callable=generate_video_task,
    dag=dag,
)

post_process_task = PythonOperator(
    task_id='post_process_video',
    python_callable=post_process_video,
    dag=dag,
)

cleanup_task_op = PythonOperator(
    task_id='cleanup',
    python_callable=cleanup_task,
    dag=dag,
)

# 定义任务依赖
setup_task >> generate_video_task_op >> post_process_task >> cleanup_task_op 