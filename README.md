# AI ASMR Veo3 批量处理系统

一个基于Apache Airflow的生产就绪生成式AI管道作业队列系统，支持文本到图像和视频生成。

## 🚀 快速开始

### 系统要求
- Docker & Docker Compose
- Google Cloud Platform 账户
- 至少 4GB RAM

### 快速部署
```bash
# 1. 克隆项目
git clone <repository-url>
cd ai-asmr-veo3-batch

# 2. 配置环境变量
cp .env.example .env
# 编辑 .env 文件，填入你的Google Cloud配置

# 3. 启动系统
./start_system.sh

# 4. 访问Airflow Web界面
# http://localhost:8080 (admin/admin)
```

## 📁 项目结构

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

## 🔧 核心功能

### 1. 图片生成
- 基于Google Vertex AI的图像生成
- 支持Dry Run模式（零成本测试）
- 异步处理和状态管理
- 自动重试和错误处理

### 2. 视频生成
- 基于Veo 3.0的视频生成
- 云端存储和本地下载
- 批量处理支持

### 3. 异步下载系统
- 并行下载图像和视频文件
- 断点续传支持
- 优先级队列管理
- 完整的下载状态跟踪

### 4. 作业队列管理
- SQLite数据库存储
- 作业状态跟踪
- 批量作业添加
- 自动清理机制

## 📊 系统状态

- **项目大小**: 268MB (主要包含venv虚拟环境和outputs输出文件)
- **文档版本**: v1.1.0
- **最后更新**: 2025-07-19

### 最近清理
- ✅ 删除5个测试文件
- ✅ 删除7个冗余文档
- ✅ 优化项目结构
- ✅ 添加自动化清理机制

## 📚 详细文档

- **[详细技术文档](PROJECT_DOCUMENTATION.md)** - 完整的系统架构、数据流转、DAG操作详解
- **[系统状态报告](SYSTEM_STATUS_REPORT.md)** - 当前系统健康状态和性能指标
- **[Airflow设置指南](AIRFLOW_SETUP.md)** - Airflow配置和部署说明
- **[快速开始指南](QUICK_START.md)** - 新用户快速上手教程

## 🛠️ 常用命令

### 系统管理
```bash
# 启动系统
docker-compose up -d

# 查看状态
docker-compose ps

# 查看日志
docker-compose logs -f airflow-scheduler

# 停止系统
docker-compose down
```

### 作业管理
```bash
# 添加单个作业
docker-compose exec airflow-scheduler python /opt/airflow/src/job_manager.py add --prompt "测试提示词" --type IMAGE_TEST

# 批量添加作业
docker-compose exec airflow-scheduler python /opt/airflow/src/job_manager.py add --file /opt/airflow/prompts/prompts.txt

# 查看作业统计
docker-compose exec airflow-scheduler python /opt/airflow/src/job_manager.py stats

# 重置卡住作业
docker-compose exec airflow-scheduler python /opt/airflow/src/job_manager.py reset
```

### 数据清理
```bash
# 清理临时文件
find . -name "__pycache__" -type d -exec rm -rf {} +
find . -name "*.pyc" -type f -delete
find outputs/ -name "*.png" -size -1k -delete

# 清理旧日志
find logs/ -name "*.log" -mtime +7 -delete
```

## 🔍 故障排除

### 常见问题
1. **DAG导入失败**: 检查DAG语法和依赖
2. **数据库连接问题**: 检查SQLite文件权限
3. **API调用失败**: 验证Google Cloud凭证
4. **下载失败**: 检查网络连接和存储空间

### 调试工具
- `debug_imports.py` - 检查Python模块导入
- `example_usage.py` - 使用示例和测试代码

## 📈 性能优化

### 系统配置
- 限制并发DAG运行数量
- 优化数据库查询
- 定期清理临时文件
- 监控资源使用情况

### 扩展建议
- 增加Airflow Worker节点
- 使用外部数据库（PostgreSQL/MySQL）
- 集成监控和告警系统
- 添加API网关

## 🤝 贡献指南

1. Fork 项目
2. 创建功能分支
3. 提交更改
4. 推送到分支
5. 创建 Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 📞 支持

- 📧 邮箱: support@example.com
- 📖 文档: [PROJECT_DOCUMENTATION.md](PROJECT_DOCUMENTATION.md)
- 🐛 问题报告: GitHub Issues

---

**维护者**: AI Team  
**版本**: v1.1.0  
**最后更新**: 2025-07-19
