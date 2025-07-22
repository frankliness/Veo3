"""
企业级Veo视频生成DAG - 状态化工作流版本
实现基于数据库状态的高效重试机制，避免重复的API调用
"""
from datetime import datetime, timedelta
from airflow.decorators import dag, task
import logging
import sys
import os
import pytz

# 添加src目录到Python路径
sys.path.append('/opt/airflow/src')

logger = logging.getLogger(__name__)

@dag(
    dag_id='veo_video_generation_workflow',
    description='企业级Veo视频生成工作流 - 状态化版本',
    start_date=datetime(2024, 1, 1),
    schedule=None,  # 手动触发
    catchup=False,
    tags=['veo', 'video-generation', 'enterprise', 'stateful'],
    default_args={
        'owner': 'ai-team',
        'depends_on_past': False,
        'email_on_failure': False,
        'email_on_retry': False,
        'retries': 2,
        'retry_delay': timedelta(minutes=5),
    }
)
def veo_video_generation_workflow():
    """企业级视频生成工作流 - 状态化版本"""

    # 在DAG函数内部导入模块
    try:
        from src.core_workflow import (
            get_and_lock_job, mark_job_as_failed, mark_job_as_generation_successful,
            get_job_by_id, update_job_gcs_uri, update_job_operation_info, get_job_operation_id
        )
        from src.gen_video import submit_veo_generation_task, poll_veo_operation_status
        from src.database import db_manager
        from src.job_manager import JobManager
    except ImportError as e:
        logger.error(f"导入模块失败: {e}")
        raise

    @task(task_id='initialize_database')
    def initialize_database():
        """初始化数据库连接"""
        try:
            # 只在表不存在时初始化
            if not db_manager.check_table_exists('jobs'):
                db_manager.init_database()
                logger.info("数据库初始化完成")
            else:
                logger.info("数据库表已存在，跳过初始化")
            return "database_ready"
        except Exception as e:
            logger.error(f"数据库初始化失败: {e}")
            raise

    @task(task_id='get_job_task')
    def get_job_task():
        """获取待处理的VIDEO_PROD作业"""
        try:
            job = get_and_lock_job('VIDEO_PROD')
            if job:
                logger.info(f"获取到作业: ID={job['id']}, 提示词={job['prompt_text'][:50]}...")
                return job
            else:
                logger.info("没有找到可用的VIDEO_PROD作业")
                return None
        except Exception as e:
            logger.error(f"获取作业失败: {e}")
            raise

    @task(task_id='submit_if_needed_task')
    def submit_if_needed_task(job_data):
        """智能提交任务：如果operation_id不存在则提交，否则跳过"""
        if not job_data:
            logger.info("跳过提交，没有可用作业")
            return None

        job_id = job_data['id']
        prompt_text = job_data['prompt_text']
        
        logger.info(f"🔍 检查作业 {job_id} 的operation_id状态...")
        
        try:
            # 步骤1: 检查数据库中是否已有operation_id
            existing_operation_id = get_job_operation_id(job_id)
            
            if existing_operation_id:
                logger.info(f"✅ 作业 {job_id} 已有operation_id: {existing_operation_id}")
                logger.info(f"🔄 跳过提交步骤，直接使用现有operation_id")
                return {
                    'job_id': job_id,
                    'operation_id': existing_operation_id,
                    'mode': 'resume',
                    'prompt_text': prompt_text
                }
            else:
                logger.info(f"📝 作业 {job_id} 没有operation_id，需要提交新任务")
                
                # 步骤2: 提交新任务
                logger.info(f"🚀 提交视频生成任务...")
                operation_id = submit_veo_generation_task(prompt_text)
                
                # 步骤3: 预检operation_id有效性
                logger.info(f"🔍 预检operation_id有效性: {operation_id}")
                try:
                    # 这里可以添加简单的预检逻辑，比如检查格式
                    if not operation_id or 'operations/' not in operation_id:
                        raise Exception(f"无效的operation_id格式: {operation_id}")
                    logger.info(f"✅ operation_id预检通过")
                except Exception as pre_check_error:
                    logger.error(f"❌ operation_id预检失败: {pre_check_error}")
                    raise
                
                # 步骤4: 持久化operation_id到数据库
                logger.info(f"💾 持久化operation_id到数据库...")
                update_success = update_job_operation_info(job_id, operation_id)
                if not update_success:
                    raise Exception(f"无法更新作业 {job_id} 的operation_id")
                
                logger.info(f"✅ 作业 {job_id} 提交成功，operation_id已持久化")
                return {
                    'job_id': job_id,
                    'operation_id': operation_id,
                    'mode': 'submit',
                    'prompt_text': prompt_text
                }
                
        except Exception as e:
            logger.error(f"❌ 提交任务失败: {e}")
            # 标记作业为失败
            try:
                mark_job_as_failed(job_id, str(e))
                logger.info(f"作业 {job_id} 已标记为失败")
            except Exception as mark_error:
                logger.error(f"标记作业失败时出错: {mark_error}")
            raise

    @task(task_id='poll_and_finalize_task', execution_timeout=timedelta(minutes=30))
    def poll_and_finalize_task(submit_result):
        """轮询并完成任务"""
        if not submit_result:
            logger.info("跳过轮询，没有提交结果")
            return None
            
        job_id = submit_result['job_id']
        operation_id = submit_result['operation_id']
        mode = submit_result.get('mode', 'submit')
        prompt_text = submit_result.get('prompt_text', '')
        
        logger.info(f"🔄 开始轮询作业 {job_id}，模式: {mode}")
        logger.info(f"📋 operation_id: {operation_id}")
        
        try:
            # 步骤1: 验证输入参数
            if not operation_id or operation_id.strip() == "":
                raise ValueError(f"作业 {job_id} 的 operation_id 为空，无法进行轮询")
            
            # 步骤2: 检查作业状态
            job = get_job_by_id(job_id)
            if not job:
                raise ValueError(f"作业 {job_id} 不存在")
            
            if job['status'] == 'completed':
                logger.info(f"✅ 作业 {job_id} 已经完成，跳过轮询")
                return job.get('gcs_uri', '')
            
            # 步骤3: 执行轮询
            logger.info(f"⏳ 开始轮询operation: {operation_id}")
            video_uri = poll_veo_operation_status(operation_id)
            
            if video_uri:
                logger.info(f"✅ 轮询成功，获得视频URI: {video_uri}")
                
                # 步骤4: 添加下载任务到队列
                logger.info(f"📥 添加下载任务到队列...")
                job_manager = JobManager()
                
                # 生成本地保存路径 - 使用东8区时间戳
                # 1. 定义东8区时区 (Asia/Shanghai 是标准的UTC+8时区)
                tz_utc_8 = pytz.timezone('Asia/Shanghai')
                
                # 2. 获取东8区的当前时间
                now_in_utc8 = datetime.now(tz_utc_8)
                
                # 3. 格式化时间字符串，例如: '20250722_153005'
                formatted_time = now_in_utc8.strftime('%Y%m%d_%H%M%S')
                
                # 4. 创建可读性强且唯一的文件名
                unique_filename = f"video_{formatted_time}.mp4"
                
                # 5. 构建完整的、唯一的本地保存路径
                local_save_path = f"/opt/airflow/outputs/{unique_filename}"
                
                logger.info(f"📁 生成本地路径: {local_save_path}")
                
                # 添加下载任务
                download_id = job_manager.add_download_task(
                    job_id=job_id,
                    remote_url=video_uri,
                    local_path=local_save_path,  # 使用新生成的唯一路径
                    file_type='video',
                    priority=1  # 视频优先级较高
                )
                
                logger.info(f"📋 下载任务已添加，下载ID: {download_id}")
                
                # 步骤5: 标记作业为生成成功
                logger.info(f"🎯 标记作业为生成成功状态...")
                success = mark_job_as_generation_successful(job_id, video_uri)
                
                if success:
                    logger.info(f"✅ 作业 {job_id} 处理完成:")
                    logger.info(f"   - 视频已生成: {video_uri}")
                    logger.info(f"   - 下载任务已创建: ID {download_id}")
                    logger.info(f"   - 作业状态已更新为generation_successful")
                    
                    return {
                        'job_id': job_id,
                        'gcs_uri': video_uri,
                        'download_id': download_id,
                        'status': 'generation_successful'
                    }
                else:
                    raise Exception(f"无法标记作业 {job_id} 为生成成功状态")
            else:
                raise Exception(f"作业 {job_id} 轮询失败：未获取到视频URI")
                
        except Exception as e:
            logger.error(f"❌ 轮询失败: {str(e)}")
            
            # 标记作业为失败
            try:
                mark_job_as_failed(job_id, str(e))
                logger.info(f"作业 {job_id} 已标记为失败")
            except Exception as mark_error:
                logger.error(f"标记作业失败时出错: {mark_error}")
            
            # 重新抛出异常，让Airflow处理重试
            raise Exception(f"轮询任务失败: {str(e)}")

    # 定义任务流程 - 状态化工作流
    init_db = initialize_database()
    job_data = get_job_task()
    submit_result = submit_if_needed_task(job_data)
    poll_result = poll_and_finalize_task(submit_result)

    # 设置任务依赖
    init_db >> job_data >> submit_result >> poll_result

# 实例化DAG
veo_video_generation_dag = veo_video_generation_workflow()