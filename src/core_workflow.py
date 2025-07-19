"""
核心工作流模块
提供作业队列管理的核心功能，包括获取、锁定、完成和失败处理
"""

import logging
from typing import Optional, Dict, Any, Tuple
from database import db_manager

logger = logging.getLogger(__name__)

def get_and_lock_job(job_type: str) -> Optional[Dict[str, Any]]:
    """
    原子性地获取并锁定一个待处理的作业
    
    Args:
        job_type: 作业类型 ('IMAGE_TEST' 或 'VIDEO_PROD')
    
    Returns:
        作业详情字典，包含id和prompt_text，如果没有可用作业则返回None
    """
    lock_sql = """
    UPDATE jobs 
    SET status = 'processing'
    WHERE id = (
        SELECT id 
        FROM jobs 
        WHERE status = 'pending' 
            AND job_type = %s
        ORDER BY created_at ASC
        LIMIT 1
        FOR UPDATE SKIP LOCKED
    )
    RETURNING id, prompt_text, job_type, created_at
    """
    
    try:
        with db_manager.get_connection() as conn:
            with conn.cursor() as cursor:
                cursor.execute(lock_sql, (job_type,))
                result = cursor.fetchone()
                
                if result:
                    job_id, prompt_text, job_type, created_at = result
                    conn.commit()
                    
                    logger.info(f"成功锁定作业 ID: {job_id}, 类型: {job_type}")
                    return {
                        'id': job_id,
                        'prompt_text': prompt_text,
                        'job_type': job_type,
                        'created_at': created_at
                    }
                else:
                    conn.commit()
                    logger.info(f"没有找到可用的 {job_type} 类型作业")
                    return None
                    
    except Exception as e:
        logger.error(f"获取并锁定作业失败: {e}")
        raise

def mark_job_as_completed(job_id: int, local_path: str, gcs_uri: Optional[str] = None) -> bool:
    """
    将作业标记为已完成
    
    Args:
        job_id: 作业ID
        local_path: 生成文件的本地路径
        gcs_uri: 可选的GCS URI
    
    Returns:
        操作是否成功
    """
    update_sql = """
    UPDATE jobs 
    SET status = 'completed', 
        local_path = %s,
        gcs_uri = %s
    WHERE id = %s
    """
    
    try:
        with db_manager.get_connection() as conn:
            with conn.cursor() as cursor:
                cursor.execute(update_sql, (local_path, gcs_uri, job_id))
                rows_affected = cursor.rowcount
                conn.commit()
                
                if rows_affected > 0:
                    logger.info(f"作业 {job_id} 已标记为完成，本地路径: {local_path}")
                    return True
                else:
                    logger.warning(f"作业 {job_id} 不存在或无法更新")
                    return False
                    
    except Exception as e:
        logger.error(f"标记作业完成失败: {e}")
        raise

def mark_job_as_failed(job_id: int, error_message: Optional[str] = None) -> bool:
    """
    将作业标记为失败
    
    Args:
        job_id: 作业ID
        error_message: 可选的错误信息
    
    Returns:
        操作是否成功
    """
    update_sql = """
    UPDATE jobs 
    SET status = 'failed'
    WHERE id = %s
    """
    
    try:
        with db_manager.get_connection() as conn:
            with conn.cursor() as cursor:
                cursor.execute(update_sql, (job_id,))
                rows_affected = cursor.rowcount
                conn.commit()
                
                if rows_affected > 0:
                    logger.warning(f"作业 {job_id} 已标记为失败")
                    if error_message:
                        logger.error(f"失败原因: {error_message}")
                    return True
                else:
                    logger.warning(f"作业 {job_id} 不存在或无法更新")
                    return False
                    
    except Exception as e:
        logger.error(f"标记作业失败时出错: {e}")
        raise

def reset_stuck_jobs(job_type: Optional[str] = None) -> int:
    """
    重置卡住的作业（状态为processing但可能已经超时）
    
    Args:
        job_type: 可选的作业类型过滤
    
    Returns:
        重置的作业数量
    """
    reset_sql = """
    UPDATE jobs 
    SET status = 'pending'
    WHERE status = 'processing'
    """
    
    if job_type:
        reset_sql += " AND job_type = %s"
        params = (job_type,)
    else:
        params = ()
    
    try:
        with db_manager.get_connection() as conn:
            with conn.cursor() as cursor:
                cursor.execute(reset_sql, params)
                rows_affected = cursor.rowcount
                conn.commit()
                
                if rows_affected > 0:
                    logger.info(f"重置了 {rows_affected} 个卡住的作业")
                else:
                    logger.info("没有找到需要重置的作业")
                
                return rows_affected
                
    except Exception as e:
        logger.error(f"重置卡住作业失败: {e}")
        raise

def get_job_by_id(job_id: int) -> Optional[Dict[str, Any]]:
    """
    根据ID获取作业详情
    
    Args:
        job_id: 作业ID
    
    Returns:
        作业详情字典，如果不存在则返回None
    """
    select_sql = """
    SELECT id, prompt_text, status, job_type, local_path, gcs_uri, created_at, updated_at
    FROM jobs 
    WHERE id = %s
    """
    
    try:
        with db_manager.get_connection() as conn:
            with conn.cursor() as cursor:
                cursor.execute(select_sql, (job_id,))
                result = cursor.fetchone()
                
                if result:
                    return {
                        'id': result[0],
                        'prompt_text': result[1],
                        'status': result[2],
                        'job_type': result[3],
                        'local_path': result[4],
                        'gcs_uri': result[5],
                        'created_at': result[6],
                        'updated_at': result[7]
                    }
                else:
                    return None
                    
    except Exception as e:
        logger.error(f"获取作业详情失败: {e}")
        raise 