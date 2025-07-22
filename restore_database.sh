#!/bin/bash

# 数据库恢复脚本

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置
BACKUP_DIR="./backups"

echo -e "${BLUE}可用的备份文件:${NC}"
ls -la "$BACKUP_DIR"/airflow_backup_*.sql 2>/dev/null || {
    echo -e "${RED}❌ 没有找到备份文件${NC}"
    exit 1
}

# 显示备份文件列表
ls -lt "$BACKUP_DIR"/airflow_backup_*.sql | head -10

echo ""
read -p "请输入要恢复的备份文件名 (或按回车选择最新的): " BACKUP_FILE

if [ -z "$BACKUP_FILE" ]; then
    BACKUP_FILE=$(ls -t "$BACKUP_DIR"/airflow_backup_*.sql | head -1)
fi

if [ ! -f "$BACKUP_FILE" ]; then
    echo -e "${RED}❌ 备份文件不存在: $BACKUP_FILE${NC}"
    exit 1
fi

echo -e "${YELLOW}⚠️  警告: 这将覆盖当前数据库中的所有数据！${NC}"
read -p "确认要恢复数据库吗？(输入 'yes' 确认): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo -e "${YELLOW}取消恢复操作${NC}"
    exit 0
fi

echo -e "${BLUE}开始恢复数据库...${NC}"

# 停止相关服务
echo -e "${BLUE}停止相关服务...${NC}"
docker compose stop airflow-webserver airflow-scheduler prompt-manager

# 恢复数据库
echo -e "${BLUE}恢复数据库...${NC}"
docker compose exec -T postgres psql -U airflow -d airflow -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"
docker compose exec -T postgres psql -U airflow -d airflow < "$BACKUP_FILE"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ 数据库恢复成功！${NC}"
    
    # 重启服务
    echo -e "${BLUE}重启服务...${NC}"
    docker compose up -d
    
    echo -e "${GREEN}✅ 恢复完成！服务已重启${NC}"
else
    echo -e "${RED}❌ 数据库恢复失败${NC}"
    exit 1
fi 