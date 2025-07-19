#!/usr/bin/env python3
"""
数据库初始化脚本
用于在Airflow启动时初始化数据库表结构
"""

import os
import sys
import logging

# 设置日志
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# 添加当前目录到Python路径
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from database import db_manager

def main():
    """主函数：初始化数据库"""
    try:
        logger.info("开始初始化数据库...")
        
        # 初始化数据库表结构
        db_manager.init_database()
        
        logger.info("数据库初始化完成！")
        
        # 显示数据库统计信息
        stats = db_manager.get_job_stats()
        if stats:
            logger.info("当前作业统计:")
            for job_type, status_counts in stats.items():
                logger.info(f"  {job_type}:")
                for status, count in status_counts.items():
                    logger.info(f"    {status}: {count}")
        else:
            logger.info("数据库中没有作业")
            
    except Exception as e:
        logger.error(f"数据库初始化失败: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main() 