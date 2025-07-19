# 🚀 快速开始指南

## 系统概述

这是一个基于Airflow的生产就绪生成式AI管道作业队列系统，支持：

- ✅ 文本到图像生成（测试环境）
- ✅ 作业队列管理
- ✅ 自动错误处理和重试
- ✅ 容器化部署
- ✅ 可扩展架构

## 📋 前置要求

- Docker 和 Docker Compose
- Python 3.8+
- Google Cloud 项目（用于AI模型）

## 🛠️ 安装步骤

### 1. 克隆项目
```bash
git clone <repository-url>
cd ai-asmr-veo3-batch
```

### 2. 配置环境变量
```bash
# 复制环境变量模板
cp env.template .env

# 编辑环境变量文件
vim .env
```

**重要配置项：**
```bash
# PostgreSQL设置
POSTGRES_USER=airflow
POSTGRES_PASSWORD=airflow
POSTGRES_DB=airflow

# Google Cloud设置
GOOGLE_CLOUD_PROJECT=your-gcp-project-id
GOOGLE_CLOUD_LOCATION=us-central1
GOOGLE_GENAI_USE_VERTEXAI=True

# Airflow设置（会自动生成）
AIRFLOW__CORE__FERNET_KEY=your_fernet_key_here
```

### 3. 启动系统
```bash
# 使用启动脚本（推荐）
./start_system.sh

# 或手动启动
docker-compose up -d
```

### 4. 验证系统
```bash
# 检查服务状态
docker-compose ps

# 查看日志
docker-compose logs -f
```

## 🎯 快速使用

### 1. 访问Airflow界面
打开浏览器访问：http://localhost:8081
- 用户名：admin
- 密码：admin

### 2. 添加测试作业
```bash
# 添加单个作业
docker-compose exec airflow-scheduler python /opt/airflow/src/job_manager.py add --prompt "一只可爱的小猫" --type IMAGE_TEST

# 批量添加作业
docker-compose exec airflow-scheduler python /opt/airflow/src/job_manager.py add --file /opt/airflow/prompts/test_prompts.txt
```

### 3. 运行测试DAG
1. 在Airflow界面找到 `image_generation_test_workflow` DAG
2. 点击 "Trigger DAG" 手动触发
3. 监控任务执行状态

### 4. 查看结果
```bash
# 查看作业统计
docker-compose exec airflow-scheduler python /opt/airflow/src/job_manager.py stats

# 查看生成的文件
ls -la outputs/
```

## 🔧 常用命令

### 系统管理
```bash
# 启动系统
./start_system.sh

# 停止系统
docker-compose down

# 重启系统
docker-compose restart

# 查看服务状态
docker-compose ps
```

### 作业管理
```bash
# 添加作业
docker-compose exec airflow-scheduler python /opt/airflow/src/job_manager.py add --prompt "提示词" --type IMAGE_TEST

# 查看统计
docker-compose exec airflow-scheduler python /opt/airflow/src/job_manager.py stats

# 重置卡住的作业
docker-compose exec airflow-scheduler python /opt/airflow/src/job_manager.py reset
```

### 日志查看
```bash
# 查看所有日志
docker-compose logs -f

# 查看特定服务日志
docker-compose logs -f airflow-scheduler
docker-compose logs -f postgres
```

## 🐛 故障排除

### 常见问题

1. **数据库连接失败**
   ```bash
   # 检查PostgreSQL状态
   docker-compose logs postgres
   
   # 重启数据库
   docker-compose restart postgres
   ```

2. **Airflow无法访问**
   ```bash
   # 检查Airflow状态
   docker-compose logs airflow-webserver
   
   # 重启Airflow
   docker-compose restart airflow-webserver
   ```

3. **Google Cloud认证失败**
   ```bash
   # 检查环境变量
   docker-compose exec airflow-scheduler env | grep GOOGLE
   
   # 确保已配置Google Cloud凭据
   ```

### 系统测试
```bash
# 运行系统测试
docker-compose exec airflow-scheduler python /opt/airflow/test_system.py
```

## 📊 监控和日志

### 关键日志位置
- Airflow任务日志：通过Web界面查看
- 应用日志：`logs/` 目录
- 数据库日志：PostgreSQL容器日志

### 性能监控
```bash
# 查看资源使用情况
docker stats

# 查看磁盘使用情况
docker system df
```

## 🔄 扩展系统

### 添加新的作业类型
1. 在 `src/` 目录创建新的生成器模块
2. 更新数据库约束
3. 创建新的DAG文件

### 生产环境部署
1. 替换为高成本模型
2. 添加GCS文件上传
3. 配置监控和告警
4. 设置备份策略

## 📚 更多信息

- 详细文档：查看 `README.md`
- 系统架构：查看项目结构说明
- 开发指南：查看 `src/` 目录下的模块文档

## 🆘 获取帮助

如果遇到问题：
1. 查看日志文件
2. 运行系统测试
3. 检查环境变量配置
4. 查看故障排除指南

---

**注意**：此系统仅用于测试目的，生产环境需要额外的安全配置和优化。 