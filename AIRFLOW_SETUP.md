# Airflow Veo项目设置指南

## 概述

本项目提供了一个完整的Apache Airflow环境，用于自动化Veo3视频生成任务。通过Docker Compose，您可以快速启动一个包含所有必要服务的环境。

## 项目结构

```
ai-asmr-veo3-batch/
├── docker-compose.yml          # Docker Compose配置
├── Dockerfile                  # 自定义Airflow镜像
├── requirements.txt            # Python依赖
├── .dockerignore              # Docker忽略文件
├── env.template               # 环境变量模板
├── start_airflow.sh           # 启动脚本
├── dags/                      # Airflow DAGs目录
│   └── veo_video_generation_dag.py
├── src/                       # 源代码
├── outputs/                   # 输出目录
├── logs/                      # 日志目录
└── prompts/                   # 提示词目录
```

## 快速开始

### 1. 前置要求

- Docker 20.10+
- Docker Compose 2.0+
- Python 3.8+
- Google Cloud项目和服务账号

### 2. 环境设置

#### 2.1 复制环境变量模板
```bash
cp env.template .env
```

#### 2.2 编辑.env文件
```bash
# 设置Google Cloud配置
GOOGLE_CLOUD_PROJECT=your-gcp-project-id
GOOGLE_CLOUD_LOCATION=us-central1
GCS_OUTPUT_BUCKET=gs://your-bucket/outputs
GOOGLE_GENAI_USE_VERTEXAI=True

# 生成Fernet密钥
python3 -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())"
```

#### 2.3 准备GCP凭证
```bash
# 方法1: 使用服务账号密钥文件
# 将您的服务账号密钥文件重命名为 gcp-credentials.json

# 方法2: 使用gcloud认证
gcloud auth application-default login
```

### 3. 启动服务

#### 使用启动脚本（推荐）
```bash
./start_airflow.sh
```

#### 手动启动
```bash
# 构建镜像
docker-compose build

# 启动服务
docker-compose up -d

# 检查状态
docker-compose ps
```

### 4. 访问Airflow

- **URL**: http://localhost:8080
- **用户名**: admin
- **密码**: admin

## 配置说明

### 环境变量

| 变量名 | 说明 | 示例 |
|--------|------|------|
| `GOOGLE_CLOUD_PROJECT` | GCP项目ID | `my-project-123` |
| `GOOGLE_CLOUD_LOCATION` | GCP区域 | `us-central1` |
| `GCS_OUTPUT_BUCKET` | GCS输出桶 | `gs://my-bucket/outputs` |
| `MAX_RETRIES` | 重试次数 | `3` |
| `BASE_DELAY` | 基础延迟（秒） | `5` |
| `MAX_DELAY` | 最大延迟（秒） | `60` |

### 重试配置

项目包含智能重试机制来处理503错误：

```python
RETRY_CONFIG = {
    "max_retries": 3,
    "base_delay": 5,
    "max_delay": 60,
    "retryable_errors": [
        "503", "service unavailable", "quota exceeded"
    ]
}
```

## DAG说明

### veo_video_generation_dag.py

这个DAG展示了如何在Airflow中集成Veo视频生成：

1. **setup_environment**: 验证环境和权限
2. **generate_video**: 生成视频
3. **post_process_video**: 后处理（可选）
4. **cleanup**: 清理临时文件

### 任务流程

```
setup_environment → generate_video → post_process_video → cleanup
```

## 使用指南

### 1. 启用DAG

1. 访问 http://localhost:8080
2. 登录（admin/admin）
3. 找到 `veo_video_generation` DAG
4. 点击切换按钮启用DAG

### 2. 触发运行

#### 手动触发
1. 在DAG页面点击"Trigger DAG"
2. 可以设置变量，如：
   ```json
   {
     "veo_prompt": "A beautiful sunset over the ocean, high quality"
   }
   ```

#### 自动调度
DAG默认每小时运行一次，可以在DAG定义中修改：
```python
schedule_interval=timedelta(hours=1)
```

### 3. 监控任务

- 在Airflow UI中查看任务状态
- 查看日志：`docker-compose logs -f airflow-scheduler`
- 检查输出文件：`./outputs/`

## 故障排除

### 常见问题

#### 1. 服务启动失败
```bash
# 检查日志
docker-compose logs

# 重启服务
docker-compose restart
```

#### 2. 503错误
- 检查GCP配额
- 验证服务账号权限
- 查看重试日志

#### 3. 认证问题
```bash
# 重新生成Fernet密钥
python3 -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())"

# 更新.env文件后重启
docker-compose restart
```

### 日志位置

- **Airflow日志**: `./logs/`
- **Docker日志**: `docker-compose logs`
- **应用日志**: `./logs/veo_dag.log`

## 开发指南

### 添加新的DAG

1. 在 `dags/` 目录创建新的Python文件
2. 导入必要的模块：
   ```python
   from gen_video import generate_video_with_genai
   from utils import setup_logging
   ```

3. 定义DAG和任务
4. 重启Airflow服务

### 自定义配置

#### 修改重试策略
编辑 `src/config.py` 中的 `RETRY_CONFIG`

#### 添加新的环境变量
1. 在 `env.template` 中添加
2. 在 `docker-compose.yml` 中设置
3. 在代码中使用 `os.getenv()`

## 性能优化

### 1. 资源限制

在 `docker-compose.yml` 中添加资源限制：
```yaml
services:
  airflow-scheduler:
    deploy:
      resources:
        limits:
          memory: 2G
          cpus: '1.0'
```

### 2. 并发控制

在DAG中设置并发限制：
```python
dag = DAG(
    'veo_video_generation',
    max_active_runs=1,  # 限制并发运行数
    concurrency=2,      # 限制任务并发数
)
```

### 3. 缓存优化

使用Airflow的XCom功能在任务间传递数据：
```python
context['task_instance'].xcom_push(key='video_path', value=local_video_path)
```

## 安全考虑

### 1. 凭证管理

- 不要将 `.env` 文件提交到Git
- 使用Google Cloud IAM管理权限
- 定期轮换服务账号密钥

### 2. 网络安全

- 在生产环境中使用HTTPS
- 配置防火墙规则
- 使用VPN访问（如需要）

### 3. 数据保护

- 加密敏感数据
- 定期备份数据库
- 实施访问控制

## 生产部署

### 1. 使用外部数据库

```yaml
# 在docker-compose.yml中替换postgres服务
services:
  postgres:
    image: postgres:13
    environment:
      POSTGRES_DB: airflow
      POSTGRES_USER: airflow
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
```

### 2. 使用Redis作为消息队列

```yaml
services:
  redis:
    image: redis:6-alpine
    ports:
      - "6379:6379"
```

### 3. 配置监控

- 使用Prometheus监控
- 配置告警规则
- 设置日志聚合

## 总结

这个Airflow设置提供了：

✅ **完整的自动化环境** - 一键启动所有服务  
✅ **智能错误处理** - 自动重试503错误  
✅ **灵活的配置** - 支持环境变量配置  
✅ **生产就绪** - 包含监控和日志  
✅ **易于扩展** - 模块化设计  

通过这个设置，您可以轻松地自动化Veo3视频生成流程，提高工作效率并减少人工干预。 