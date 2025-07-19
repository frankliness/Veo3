#!/usr/bin/env python3
"""
异步生成-下载系统使用示例
"""

import sys
import time
import json
from pathlib import Path

# 添加src目录到路径
sys.path.insert(0, 'src')

from job_manager import JobManager
from downloader import file_downloader

def demo_workflow():
    """演示完整的异步工作流"""
    
    print("🚀 异步生成-下载系统演示")
    print("=" * 50)
    
    # 1. 初始化作业管理器
    job_manager = JobManager()
    
    # 2. 模拟添加生成作业
    print("\n📝 步骤1: 添加生成作业")
    
    # 添加一些测试作业
    prompts = [
        "一只可爱的小猫在花园里玩耍",
        "未来城市的科幻场景",
        "宁静的湖边日落风景"
    ]
    
    job_ids = []
    for prompt in prompts:
        # 这里假设是图像生成作业
        # 在实际系统中，这会触发生成DAG
        print(f"  添加作业: {prompt}")
        job_ids.append(len(job_ids) + 1)  # 模拟ID
    
    print(f"  ✅ 已添加 {len(job_ids)} 个生成作业")
    
    # 3. 模拟生成完成，添加下载任务
    print("\n📥 步骤2: 模拟生成完成，添加下载任务")
    
    download_tasks = []
    for i, job_id in enumerate(job_ids):
        # 模拟生成完成，获得远程URL
        remote_url = f"https://api.example.com/generated/image_{job_id}.png"
        local_path = f"/opt/airflow/outputs/generated_image_{job_id}.png"
        
        # 添加下载任务
        download_id = job_manager.add_download_task(
            job_id=job_id,
            remote_url=remote_url,
            local_path=local_path,
            file_type='image',
            priority=i  # 不同优先级
        )
        
        download_tasks.append({
            'id': download_id,
            'job_id': job_id,
            'url': remote_url,
            'path': local_path
        })
        
        print(f"  添加下载任务 {download_id}: {remote_url}")
    
    print(f"  ✅ 已添加 {len(download_tasks)} 个下载任务")
    
    # 4. 查询待下载任务
    print("\n🔍 步骤3: 查询待下载任务")
    
    pending_downloads = job_manager.get_pending_downloads(limit=10, file_type='image')
    print(f"  找到 {len(pending_downloads)} 个待下载任务")
    
    for task in pending_downloads:
        print(f"    任务 {task['id']}: 优先级 {task['priority']}, 类型 {task['file_type']}")
    
    # 5. 模拟下载过程
    print("\n⬇️ 步骤4: 模拟下载过程")
    
    for task in pending_downloads[:2]:  # 只处理前2个任务
        print(f"  开始下载任务 {task['id']}")
        
        # 更新状态为下载中
        job_manager.update_download_status(task['id'], 'downloading')
        
        # 模拟下载（这里只是演示，实际会调用真实下载）
        time.sleep(1)  # 模拟下载时间
        
        # 模拟下载成功
        job_manager.update_download_status(
            task['id'], 
            'completed',
            file_size=1024000  # 1MB
        )
        
        print(f"    ✅ 任务 {task['id']} 下载完成")
    
    # 6. 查看下载统计
    print("\n📊 步骤5: 查看下载统计")
    
    stats = job_manager.get_download_stats()
    print("  下载统计:")
    print(f"    {json.dumps(stats, indent=4, ensure_ascii=False)}")
    
    # 7. 演示优先级和过滤
    print("\n🎯 步骤6: 演示高级功能")
    
    # 只获取高优先级任务
    high_priority_tasks = job_manager.get_pending_downloads(limit=5)
    high_priority_tasks = [t for t in high_priority_tasks if t['priority'] >= 1]
    
    print(f"  高优先级任务 (≥1): {len(high_priority_tasks)} 个")
    
    # 按文件类型过滤
    image_tasks = job_manager.get_pending_downloads(limit=10, file_type='image')
    video_tasks = job_manager.get_pending_downloads(limit=10, file_type='video')
    
    print(f"  图像任务: {len(image_tasks)} 个")
    print(f"  视频任务: {len(video_tasks)} 个")
    
    print("\n🎉 演示完成！")
    print("\n📋 系统优势:")
    print("  ✅ 状态驱动 - 基于数据库状态控制流程")
    print("  ✅ 增量下载 - 只下载未完成的文件")
    print("  ✅ 断点续传 - 支持大文件可靠下载")
    print("  ✅ 优先级管理 - 重要任务优先处理")
    print("  ✅ 批量处理 - 并行下载提高效率")
    print("  ✅ 容错重试 - 失败任务自动重试")
    print("  ✅ 灵活调度 - 支持定时和手动触发")

if __name__ == "__main__":
    demo_workflow() 