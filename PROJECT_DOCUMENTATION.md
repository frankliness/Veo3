# AI ASMR Veo3 批量处理系统 - 详细文档

## 📋 项目概述

AI ASMR Veo3 批量处理系统是一个基于Apache Airflow的生产就绪生成式AI管道作业队列系统，支持文本到图像和视频生成。系统采用异步架构，将生成和下载任务分离，提供高可用性和可扩展性。

## 🏗️ 系统架构

### 核心组件

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Airflow       │    │   PostgreSQL    │    │   SQLite        │
│   (编排引擎)     │    │   (元数据)       │    │   (作业队列)     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Vertex AI     │    │   Docker        │    │   Google Cloud  │
│   (AI模型)       │    │   (容器化)       │    │   (存储)         │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### 项目结构 (已清理)

```
ai-asmr-veo3-batch/
├── 📁 dags/                          # Airflow DAG文件
│   ├── test_image_generation_dag.py  # 图片生成DAG
│   ├── download_workflow_dag.py      # 下载工作流DAG
│   ├── veo_video_generation_dag.py  # 视频生成DAG
│   └── simple_test_dag.py           # 简单测试DAG
├── 📁 src/                           # 核心应用逻辑
│   ├── job_manager.py               # 作业管理器
│   ├── downloader.py                # 文件下载器
│   ├── image_generator.py           # 图像生成器
│   ├── gen_video.py                 # 视频生成器
│   ├── core_workflow.py             # 核心工作流
│   ├── database.py                  # 数据库管理
│   ├── config.py                    # 配置管理
│   ├── utils.py                     # 工具函数
│   └── batch_runner.py              # 批量运行器
├── 📁 prompts/                      # 提示词文件
│   └── prompts.txt                  # ASMR风格提示词
├── 📁 outputs/                      # 生成文件输出
├── 📁 logs/                         # 系统日志
├── 📁 plugins/                      # 自定义插件
├── 📁 venv/                         # Python虚拟环境
├── 📄 docker-compose.yml            # Docker编排
├── 📄 Dockerfile                    # 自定义镜像
├── 📄 requirements.txt              # Python依赖
├── 📄 .env                          # 环境变量
├── 📄 debug_imports.py              # 调试工具
├── 📄 example_usage.py              # 使用示例
├── 📄 README.md                     # 项目主文档
├── 📄 PROJECT_DOCUMENTATION.md      # 详细技术文档
├── 📄 SYSTEM_STATUS_REPORT.md       # 系统状态报告
├── 📄 AIRFLOW_SETUP.md              # Airflow设置指南
└── 📄 QUICK_START.md                # 快速开始指南
```

### 已清理的文件

**删除的测试文件：**
- `test_503_fix.py` - 503错误修复测试
- `test_docker_setup.py` - Docker设置测试  
- `test_dry_run.py` - 干运行测试
- `test_system.py` - 系统测试
- `test_vertex_ai_config.py` - Vertex AI配置测试

**删除的冗余文档：**
- `503_ERROR_SOLUTION.md` - 已解决的问题
- `ARCHITECTURE.md` - 架构文档（已合并到PROJECT_DOCUMENTATION.md）
- `IMPLEMENTATION_SUMMARY.md` - 实现总结（已合并）
- `DRY_RUN_GUIDE.md` - 干运行指南（已合并）
- `DAG_FIX_SUMMARY.md` - DAG修复总结（已合并）
- `DEPLOYMENT_SUMMARY.md` - 部署总结（已合并）
- `DRY_RUN_IMPLEMENTATION.md` - 干运行实现（已合并）

## 🔄 数据流转过程

### 1. 图片生成流程

```
📝 用户输入
    ↓
📄 prompts.txt (ASMR提示词)
    ↓
🗄️ 数据库 (jobs表)
    ↓
🎯 Airflow DAG (test_image_generation_dag)
    ↓
🤖 Vertex AI (图像生成)
    ↓
💾 本地存储 (outputs/)
    ↓
📊 状态更新 (completed/failed)
```

### 2. 视频生成流程

```
📝 用户输入
    ↓
⚙️ Airflow变量 (veo_prompt)
    ↓
🎯 Airflow DAG (veo_video_generation_dag)
    ↓
🤖 Vertex AI (视频生成)
    ↓
☁️ Google Cloud Storage
    ↓
💾 本地下载 (outputs/)
```

### 3. 异步下载流程

```
📝 生成完成
    ↓
🗄️ 数据库 (download_queue表)
    ↓
🎯 Airflow DAG (download_workflow_dag)
    ↓
📥 并行下载 (图像/视频)
    ↓
💾 本地存储 (outputs/)
    ↓
📊 状态更新 (completed/failed)
```

## 🎯 DAG操作过程详解

### 1. 图片生成DAG (test_image_generation_dag)

#### 任务流程
```python
@dag(dag_id='image_generation_test_workflow')
def test_image_generation_dag():
    # 1. 初始化数据库
    initialize_database()
    
    # 2. 获取待处理作业
    job_data = get_job_task()
    
    # 3. 生成图像
    generation_result = generate_image_task(job_data)
    
    # 4. 完成作业
    finalize_job_task(generation_result)
    
    # 5. 清理临时文件
    cleanup_test_files()
```

#### 关键特性
- **Dry Run模式**: 默认启用，创建占位符文件而非真实API调用
- **作业锁定**: 原子性获取和锁定作业，防止重复处理
- **错误处理**: 自动重试和状态更新
- **资源管理**: 限制并发运行数量

### 2. 下载工作流DAG (download_workflow_dag)

#### 任务流程
```python
@dag(dag_id='download_workflow')
def download_workflow_dag():
    # 1. 扫描下载队列
    scan_result = scan_download_queue()
    
    # 2. 准备下载批次
    batch_info = prepare_download_batch(scan_result)
    
    # 3. 并行下载图像和视频
    image_result = download_images(batch_info)
    video_result = download_videos(batch_info)
    
    # 4. 更新统计信息
    stats_result = update_download_stats(image_result, video_result)
    
    # 5. 清理旧记录
    cleanup_result = cleanup_old_records()
```

#### 关键特性
- **异步处理**: 生成和下载完全分离
- **批量下载**: 支持图像和视频并行下载
- **优先级管理**: 基于文件类型和创建时间的优先级
- **断点续传**: 支持下载中断后继续
- **状态跟踪**: 完整的下载状态管理

### 3. 视频生成DAG (veo_video_generation_dag)

#### 任务流程
```python
@dag(dag_id='veo_video_generation')
def veo_video_generation_dag():
    # 1. 设置环境
    setup_task = setup_environment()
    
    # 2. 生成视频
    generate_video_task_op = generate_video_task()
    
    # 3. 后处理
    post_process_task = post_process_video()
    
    # 4. 清理
    cleanup_task_op = cleanup_task()
```

## 🗄️ 数据库设计

### jobs表 (作业队列)
```sql
CREATE TABLE jobs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    prompt_text TEXT NOT NULL,
    job_type TEXT NOT NULL,           -- IMAGE_TEST, VIDEO_PROD
    status TEXT DEFAULT 'pending',    -- pending, processing, completed, failed
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP NULL,
    local_path TEXT NULL,
    error_message TEXT NULL
);
```

### download_queue表 (下载队列)
```sql
CREATE TABLE download_queue (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    job_id INTEGER NOT NULL,
    remote_url TEXT NOT NULL,
    local_path TEXT NOT NULL,
    file_type TEXT NOT NULL,          -- image, video
    priority INTEGER DEFAULT 0,
    status TEXT DEFAULT 'pending',    -- pending, downloading, completed, failed
    attempts INTEGER DEFAULT 0,
    max_attempts INTEGER DEFAULT 3,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    started_at TIMESTAMP NULL,
    completed_at TIMESTAMP NULL,
    file_size INTEGER NULL,
    error_message TEXT NULL
);
```

## 🔧 配置管理

### 环境变量
```bash
# Google Cloud设置
GOOGLE_CLOUD_PROJECT=your-gcp-project-id
GOOGLE_CLOUD_LOCATION=us-central1
GCS_OUTPUT_BUCKET=gs://your-bucket/outputs
GOOGLE_GENAI_USE_VERTEXAI=True

# Airflow设置
AIRFLOW__CORE__FERNET_KEY=your_fernet_key
AIRFLOW__CORE__SQL_ALCHEMY_CONN=postgresql://...

# 重试配置
MAX_RETRIES=3
BASE_DELAY=5
MAX_DELAY=60

# 超时配置
OPERATION_TIMEOUT=1800
POLLING_INTERVAL=15
DOWNLOAD_TIMEOUT=300
```

### 模型配置
```python
# 图像生成模型
IMAGE_MODEL = "publishers/google/models/imagegeneration@006"

# 视频生成模型
VIDEO_MODEL = "veo-3.0-generate-preview"

# 下载配置
DOWNLOAD_CONFIG = {
    "max_concurrent": 5,
    "chunk_size": 8192,
    "timeout": 300,
    "retry_attempts": 3
}
```

## 🚀 部署和运维

### 1. 系统启动
```bash
# 使用启动脚本
./start_system.sh

# 或手动启动
docker-compose up -d
```

### 2. 服务监控
```bash
# 查看服务状态
docker-compose ps

# 查看日志
docker-compose logs -f airflow-scheduler

# 检查数据库
docker-compose exec airflow-scheduler python /opt/airflow/src/job_manager.py stats
```

### 3. 数据管理
```bash
# 添加作业
docker-compose exec airflow-scheduler python /opt/airflow/src/job_manager.py add --prompt "测试提示词" --type IMAGE_TEST

# 批量添加
docker-compose exec airflow-scheduler python /opt/airflow/src/job_manager.py add --file /opt/airflow/prompts/prompts.txt

# 重置卡住作业
docker-compose exec airflow-scheduler python /opt/airflow/src/job_manager.py reset
```

## 🧹 数据清理和维护

### 1. 临时文件清理
```bash
# 清理Python缓存
find . -name "__pycache__" -type d -exec rm -rf {} +
find . -name "*.pyc" -type f -delete

# 清理临时文件
find outputs/ -name "*.tmp" -type f -delete
find outputs/ -name "*_dry_run.txt" -type f -delete

# 清理占位符图片 (小于1KB的PNG文件)
find outputs/ -name "*.png" -size -1k -delete

# 清理日志文件
find logs/ -name "*.log" -mtime +7 -delete
```

### 2. 数据库维护
```sql
-- 清理7天前的已完成下载记录
DELETE FROM download_queue 
WHERE status = 'completed' 
AND completed_at < datetime('now', '-7 days');

-- 清理失败的作业
DELETE FROM jobs 
WHERE status = 'failed' 
AND updated_at < datetime('now', '-30 days');

-- 重置卡住的作业
UPDATE jobs 
SET status = 'pending' 
WHERE status = 'processing' 
AND updated_at < datetime('now', '-1 hour');
```

### 3. 存储空间管理
```bash
# 查看输出目录大小
du -sh outputs/

# 清理大文件
find outputs/ -size +100M -delete

# 压缩旧文件
find outputs/ -name "*.png" -mtime +30 -exec gzip {} \;
```

### 4. 自动化清理脚本
```bash
#!/bin/bash
# cleanup.sh - 自动化清理脚本

echo "开始清理临时文件..."

# 清理Python缓存
find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null
find . -name "*.pyc" -type f -delete 2>/dev/null

# 清理占位符文件
find outputs/ -name "*.png" -size -1k -delete 2>/dev/null
find outputs/ -name "*_dry_run.txt" -type f -delete 2>/dev/null

# 清理旧日志
find logs/ -name "*.log" -mtime +7 -delete 2>/dev/null

# 清理临时文件
find . -name "*.tmp" -type f -delete 2>/dev/null

echo "清理完成！"
```

## 🔍 故障排除

### 常见问题

#### 1. DAG导入失败
```bash
# 检查DAG语法
docker-compose exec airflow-scheduler python -c "import dags.test_image_generation_dag"

# 查看DAG列表
docker-compose exec airflow-scheduler airflow dags list
```

#### 2. 数据库连接问题
```bash
# 检查数据库文件
ls -la job_queue.db

# 重新初始化数据库
docker-compose exec airflow-scheduler python /opt/airflow/src/init_database.py
```

#### 3. API调用失败
```bash
# 检查Google Cloud凭证
docker-compose exec airflow-scheduler gcloud auth list

# 测试API连接
docker-compose exec airflow-scheduler python /opt/airflow/src/test_vertex_ai_config.py
```

#### 4. 下载失败
```bash
# 检查网络连接
docker-compose exec airflow-scheduler curl -I https://api.example.com

# 查看下载队列
docker-compose exec airflow-scheduler python -c "from src.job_manager import JobManager; jm = JobManager(); print(jm.get_pending_downloads())"
```

## 📊 性能监控

### 关键指标
- **作业处理速度**: 每分钟处理的作业数量
- **API调用成功率**: 成功/失败的API调用比例
- **下载完成率**: 成功下载的文件比例
- **系统资源使用**: CPU、内存、存储使用情况

### 监控命令
```bash
# 查看作业统计
docker-compose exec airflow-scheduler python /opt/airflow/src/job_manager.py stats

# 查看下载统计
docker-compose exec airflow-scheduler python -c "from src.job_manager import JobManager; jm = JobManager(); print(jm.get_download_stats())"

# 查看系统资源
docker stats
```

## 🔐 安全考虑

### 1. 凭证管理
- 使用环境变量存储敏感信息
- 定期轮换API密钥
- 限制服务账号权限

### 2. 网络安全
- 使用HTTPS进行API调用
- 实施网络访问控制
- 监控异常访问模式

### 3. 数据保护
- 加密存储敏感数据
- 定期备份数据库
- 实施数据保留策略

## 📈 扩展性设计

### 1. 水平扩展
- 支持多个Airflow Worker
- 数据库读写分离
- 负载均衡配置

### 2. 垂直扩展
- 增加API调用配额
- 优化数据库性能
- 提升存储容量

### 3. 功能扩展
- 支持更多AI模型
- 添加更多文件格式
- 集成更多存储服务

## 📝 更新日志

### v1.1.0 (2025-07-19)
- ✅ 清理冗余测试文件和文档
- ✅ 优化项目结构，提高可维护性
- ✅ 添加自动化清理脚本
- ✅ 完善临时文件清理机制
- ✅ 更新项目文档结构

### v1.0.0 (2025-07-19)
- ✅ 实现基础图片生成功能
- ✅ 实现异步下载系统
- ✅ 添加Dry Run模式
- ✅ 完善错误处理和重试机制
- ✅ 实现数据库状态管理
- ✅ 添加完整的DAG工作流
- ✅ 实现容器化部署

### 待实现功能
- 🔄 视频生成DAG集成
- 🔄 实时监控仪表板
- 🔄 自动扩缩容
- 🔄 多租户支持
- 🔄 API网关集成

## 📋 项目维护指南

### 定期维护任务
1. **每周清理**: 运行清理脚本，删除临时文件和旧日志
2. **每月检查**: 检查数据库性能，清理过期记录
3. **每季度更新**: 更新依赖包，检查安全漏洞

### 文件组织原则
- 保持核心文档精简，避免冗余
- 测试文件使用后及时删除
- 定期整理项目结构
- 重要配置和文档版本控制

---

**文档版本**: v1.1.0  
**最后更新**: 2025-07-19  
**维护者**: AI Team  
**项目大小**: 268MB (主要包含venv虚拟环境和outputs输出文件) 