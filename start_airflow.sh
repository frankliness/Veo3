#!/bin/bash

# Airflow Veo项目启动脚本

set -e

echo "🚀 启动Airflow Veo项目..."

# 检查Docker和Docker Compose是否安装
if ! command -v docker &> /dev/null; then
    echo "❌ Docker未安装，请先安装Docker"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose未安装，请先安装Docker Compose"
    exit 1
fi

# 检查.env文件是否存在
if [ ! -f .env ]; then
    echo "⚠️  .env文件不存在，正在从模板创建..."
    if [ -f env.template ]; then
        cp env.template .env
        echo "✅ 已创建.env文件，请编辑并填入实际配置值"
        echo "   特别是以下关键配置："
        echo "   - GOOGLE_CLOUD_PROJECT"
        echo "   - GCS_OUTPUT_BUCKET"
        echo "   - AIRFLOW__CORE__FERNET_KEY"
        echo ""
        echo "   生成Fernet密钥的命令："
        echo "   python -c \"from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())\""
        echo ""
        read -p "编辑完成后按回车继续..."
    else
        echo "❌ env.template文件不存在"
        exit 1
    fi
fi

# 检查GCP凭证文件
if [ ! -f gcp-credentials.json ]; then
    echo "⚠️  gcp-credentials.json文件不存在"
    echo "检测到您已设置Google Cloud默认凭证，将使用默认凭证"
    echo "如需使用服务账号密钥，请将文件重命名为gcp-credentials.json"
fi

# 创建必要的目录
echo "📁 创建必要的目录..."
mkdir -p dags logs plugins outputs prompts

# 生成Fernet密钥（如果未设置）
if grep -q "YOUR_FERNET_KEY_PLEASE_REPLACE" .env; then
    echo "🔑 生成Fernet密钥..."
    # 尝试使用pip安装cryptography
    if ! python3 -c "import cryptography" 2>/dev/null; then
        echo "📦 安装cryptography模块..."
        pip3 install cryptography
    fi
    FERNET_KEY=$(python3 -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())")
    sed -i.bak "s/YOUR_FERNET_KEY_PLEASE_REPLACE/$FERNET_KEY/" .env
    echo "✅ Fernet密钥已生成并更新到.env文件"
fi

# 构建和启动服务
echo "🔨 构建Docker镜像..."
docker-compose build

echo "🚀 启动Airflow服务..."
docker-compose up -d

# 等待服务启动
echo "⏳ 等待服务启动..."
sleep 30

# 检查服务状态
echo "📊 检查服务状态..."
docker-compose ps

echo ""
echo "🎉 Airflow环境启动完成！"
echo ""
echo "📋 访问信息："
echo "   - Airflow Web UI: http://localhost:8080"
echo "   - 用户名: admin"
echo "   - 密码: admin"
echo ""
echo "📁 重要目录："
echo "   - DAGs: ./dags/"
echo "   - 日志: ./logs/"
echo "   - 输出: ./outputs/"
echo "   - 插件: ./plugins/"
echo ""
echo "🔧 常用命令："
echo "   - 查看日志: docker-compose logs -f"
echo "   - 停止服务: docker-compose down"
echo "   - 重启服务: docker-compose restart"
echo "   - 重建镜像: docker-compose build --no-cache"
echo ""
echo "📝 下一步："
echo "1. 访问 http://localhost:8080 登录Airflow"
echo "2. 在DAGs页面找到 'veo_video_generation' DAG"
echo "3. 启用DAG并触发运行"
echo "4. 监控任务执行状态" 