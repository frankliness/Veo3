#!/bin/bash

# 数据库备份脚本

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置
BACKUP_DIR="./backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/airflow_backup_${DATE}.sql"

# 创建备份目录
mkdir -p "$BACKUP_DIR"

echo -e "${BLUE}开始备份数据库...${NC}"

# 备份PostgreSQL数据库
docker compose exec -T postgres pg_dump -U airflow airflow > "$BACKUP_FILE"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ 数据库备份成功: $BACKUP_FILE${NC}"
    
    # 显示备份文件大小
    BACKUP_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
    echo -e "${BLUE}备份文件大小: $BACKUP_SIZE${NC}"
    
    # 保留最近10个备份文件
    echo -e "${BLUE}清理旧备份文件...${NC}"
    ls -t "$BACKUP_DIR"/airflow_backup_*.sql | tail -n +11 | xargs -r rm
    
    echo -e "${GREEN}✅ 备份完成！${NC}"
else
    echo -e "${RED}❌ 数据库备份失败${NC}"
    exit 1
fi 