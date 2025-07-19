#!/bin/bash

# AI ASMR Veo3 批量处理系统启动脚本

set -e

echo "🚀 启动 AI ASMR Veo3 批量处理系统..."

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 检查Docker是否安装
check_docker() {
    echo -e "${BLUE}检查Docker安装...${NC}"
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}错误: Docker未安装${NC}"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        echo -e "${RED}错误: Docker Compose未安装${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✓ Docker检查通过${NC}"
}

# 检查环境变量文件
check_env() {
    echo -e "${BLUE}检查环境变量配置...${NC}"
    
    if [ ! -f ".env" ]; then
        echo -e "${YELLOW}警告: .env文件不存在，从模板创建...${NC}"
        if [ -f "env.template" ]; then
            cp env.template .env
            echo -e "${YELLOW}请编辑 .env 文件并配置必要的环境变量${NC}"
            echo -e "${YELLOW}特别是:${NC}"
            echo -e "${YELLOW}  - AIRFLOW__CORE__FERNET_KEY${NC}"
            echo -e "${YELLOW}  - GOOGLE_CLOUD_PROJECT${NC}"
            echo -e "${YELLOW}  - GOOGLE_CLOUD_LOCATION${NC}"
            exit 1
        else
            echo -e "${RED}错误: env.template文件不存在${NC}"
            exit 1
        fi
    fi
    
    echo -e "${GREEN}✓ 环境变量检查通过${NC}"
}

# 生成Fernet密钥
generate_fernet_key() {
    echo -e "${BLUE}检查Fernet密钥...${NC}"
    
    # 检查是否已设置Fernet密钥
    if grep -q "YOUR_FERNET_KEY_PLEASE_REPLACE" .env; then
        echo -e "${YELLOW}生成新的Fernet密钥...${NC}"
        FERNET_KEY=$(python3 -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())")
        
        # 替换.env文件中的Fernet密钥
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            sed -i '' "s/YOUR_FERNET_KEY_PLEASE_REPLACE/$FERNET_KEY/g" .env
        else
            # Linux
            sed -i "s/YOUR_FERNET_KEY_PLEASE_REPLACE/$FERNET_KEY/g" .env
        fi
        
        echo -e "${GREEN}✓ Fernet密钥已生成并配置${NC}"
    else
        echo -e "${GREEN}✓ Fernet密钥已配置${NC}"
    fi
}

# 启动Docker服务
start_services() {
    echo -e "${BLUE}启动Docker服务...${NC}"
    
    # 停止现有服务
    docker-compose down 2>/dev/null || true
    
    # 构建并启动服务
    docker-compose up -d --build
    
    echo -e "${GREEN}✓ Docker服务已启动${NC}"
}

# 等待服务就绪
wait_for_services() {
    echo -e "${BLUE}等待服务就绪...${NC}"
    
    # 等待PostgreSQL就绪
    echo -e "${YELLOW}等待PostgreSQL...${NC}"
    timeout=60
    while [ $timeout -gt 0 ]; do
        if docker-compose exec -T postgres pg_isready -U airflow >/dev/null 2>&1; then
            echo -e "${GREEN}✓ PostgreSQL已就绪${NC}"
            break
        fi
        sleep 2
        timeout=$((timeout - 2))
    done
    
    if [ $timeout -le 0 ]; then
        echo -e "${RED}错误: PostgreSQL启动超时${NC}"
        exit 1
    fi
    
    # 等待Airflow就绪
    echo -e "${YELLOW}等待Airflow...${NC}"
    timeout=120
    while [ $timeout -gt 0 ]; do
        if curl -s http://localhost:8081/health >/dev/null 2>&1; then
            echo -e "${GREEN}✓ Airflow已就绪${NC}"
            break
        fi
        sleep 5
        timeout=$((timeout - 5))
    done
    
    if [ $timeout -le 0 ]; then
        echo -e "${RED}错误: Airflow启动超时${NC}"
        exit 1
    fi
}

# 初始化数据库
init_database() {
    echo -e "${BLUE}初始化数据库...${NC}"
    
    # 等待数据库初始化完成
    sleep 10
    
    # 运行数据库初始化脚本
    docker-compose exec -T airflow-scheduler python /opt/airflow/src/init_database.py
    
    echo -e "${GREEN}✓ 数据库初始化完成${NC}"
}

# 显示系统信息
show_system_info() {
    echo -e "${BLUE}系统信息:${NC}"
    echo -e "${GREEN}✓ Airflow Web界面: http://localhost:8081${NC}"
    echo -e "${GREEN}✓ 用户名: admin${NC}"
    echo -e "${GREEN}✓ 密码: admin${NC}"
    echo ""
    echo -e "${BLUE}有用的命令:${NC}"
    echo -e "${YELLOW}查看服务状态: docker-compose ps${NC}"
    echo -e "${YELLOW}查看日志: docker-compose logs -f${NC}"
    echo -e "${YELLOW}停止服务: docker-compose down${NC}"
    echo -e "${YELLOW}添加测试作业: docker-compose exec airflow-scheduler python /opt/airflow/src/job_manager.py add --prompt '测试提示词' --type IMAGE_TEST${NC}"
    echo -e "${YELLOW}查看作业统计: docker-compose exec airflow-scheduler python /opt/airflow/src/job_manager.py stats${NC}"
}

# 主函数
main() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  AI ASMR Veo3 批量处理系统${NC}"
    echo -e "${BLUE}================================${NC}"
    echo ""
    
    check_docker
    check_env
    generate_fernet_key
    start_services
    wait_for_services
    init_database
    
    echo ""
    echo -e "${GREEN}🎉 系统启动完成！${NC}"
    echo ""
    show_system_info
}

# 运行主函数
main "$@" 