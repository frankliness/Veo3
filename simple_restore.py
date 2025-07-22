#!/usr/bin/env python3
"""
简单的历史数据恢复脚本
"""

import psycopg2
import subprocess
import sys

def get_old_data():
    """从旧数据库获取数据"""
    try:
        # 连接到旧数据库
        conn = psycopg2.connect(
            host="localhost",
            port="5433",
            database="airflow",
            user="airflow",
            password="airflow"
        )
        
        cursor = conn.cursor()
        cursor.execute("""
            SELECT id, prompt_text, status, job_type, 
                   COALESCE(local_path, ''), COALESCE(gcs_uri, ''),
                   created_at, updated_at
            FROM jobs 
            ORDER BY id
        """)
        
        data = cursor.fetchall()
        cursor.close()
        conn.close()
        
        return data
    except Exception as e:
        print(f"获取旧数据失败: {e}")
        return []

def insert_to_new_db(data):
    """插入数据到新数据库"""
    try:
        # 连接到新数据库
        conn = psycopg2.connect(
            host="localhost",
            port="5433",
            database="airflow",
            user="airflow",
            password="airflow"
        )
        
        cursor = conn.cursor()
        
        # 清理现有数据
        cursor.execute("TRUNCATE TABLE jobs RESTART IDENTITY")
        
        # 插入历史数据
        for row in data:
            cursor.execute("""
                INSERT INTO jobs (id, prompt_text, status, job_type, local_path, gcs_uri, created_at, updated_at)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            """, row)
        
        conn.commit()
        cursor.close()
        conn.close()
        
        return len(data)
    except Exception as e:
        print(f"插入新数据失败: {e}")
        return 0

def main():
    print("开始恢复历史数据...")
    
    # 启动临时容器
    print("启动临时PostgreSQL容器...")
    subprocess.run([
        "docker", "run", "--name", "temp_postgres_old", "--rm", "-d",
        "-v", "ai-asmr-veo3-batch_postgres-db-volume:/var/lib/postgresql/data",
        "-e", "POSTGRES_USER=airflow",
        "-e", "POSTGRES_PASSWORD=airflow", 
        "-e", "POSTGRES_DB=airflow",
        "-p", "5434:5432",
        "postgres:13"
    ])
    
    # 等待启动
    import time
    time.sleep(10)
    
    # 获取旧数据
    print("获取历史数据...")
    data = get_old_data()
    
    if not data:
        print("没有找到历史数据")
        return
    
    print(f"找到 {len(data)} 条历史记录")
    
    # 插入新数据
    print("插入到新数据库...")
    count = insert_to_new_db(data)
    
    print(f"成功恢复 {count} 条记录")
    
    # 停止临时容器
    subprocess.run(["docker", "stop", "temp_postgres_old"])
    
    print("恢复完成！")

if __name__ == "__main__":
    main() 