#!/bin/bash

# 历史数据恢复脚本

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}开始恢复历史数据...${NC}"

# 检查临时容器是否运行
if ! docker ps | grep -q temp_postgres_old; then
    echo -e "${YELLOW}启动临时PostgreSQL容器...${NC}"
    docker run --name temp_postgres_old --rm -d \
        -v ai-asmr-veo3-batch_postgres-db-volume:/var/lib/postgresql/data \
        -e POSTGRES_USER=airflow \
        -e POSTGRES_PASSWORD=airflow \
        -e POSTGRES_DB=airflow \
        postgres:13
    
    echo -e "${BLUE}等待PostgreSQL启动...${NC}"
    sleep 10
fi

# 备份当前数据
echo -e "${BLUE}备份当前数据...${NC}"
./backup_database.sh

# 导出历史jobs数据
echo -e "${BLUE}导出历史jobs数据...${NC}"
docker exec temp_postgres_old pg_dump -U airflow -t jobs --data-only --column-inserts airflow > historical_jobs.sql

# 检查导出的数据
if [ -s historical_jobs.sql ]; then
    echo -e "${GREEN}✅ 成功导出历史数据${NC}"
    echo -e "${BLUE}历史作业数量: $(grep -c "INSERT INTO jobs" historical_jobs.sql)${NC}"
else
    echo -e "${RED}❌ 导出历史数据失败${NC}"
    exit 1
fi

# 清理当前jobs表
echo -e "${YELLOW}清理当前jobs表...${NC}"
docker compose exec postgres psql -U airflow -d airflow -c "TRUNCATE TABLE jobs RESTART IDENTITY;"

# 导入历史数据
echo -e "${BLUE}导入历史数据...${NC}"
docker compose exec -T postgres psql -U airflow -d airflow < historical_jobs.sql

# 验证导入结果
echo -e "${BLUE}验证导入结果...${NC}"
JOB_COUNT=$(docker compose exec postgres psql -U airflow -d airflow -t -c "SELECT COUNT(*) FROM jobs;")
echo -e "${GREEN}✅ 成功导入 $JOB_COUNT 个历史作业${NC}"

# 显示统计信息
echo -e "${BLUE}作业状态统计:${NC}"
docker compose exec postgres psql -U airflow -d airflow -c "
SELECT 
    job_type,
    status,
    COUNT(*) as count
FROM jobs 
GROUP BY job_type, status 
ORDER BY job_type, status;
"

# 恢复Airflow元数据（可选）
echo -e "${YELLOW}是否要恢复Airflow运行历史？(y/N)${NC}"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo -e "${BLUE}导出Airflow元数据...${NC}"
    docker exec temp_postgres_old pg_dump -U airflow \
        --exclude-table=jobs \
        --exclude-table=log \
        airflow > airflow_metadata.sql
    
    echo -e "${BLUE}导入Airflow元数据...${NC}"
    docker compose exec -T postgres psql -U airflow -d airflow < airflow_metadata.sql
    
    echo -e "${GREEN}✅ Airflow元数据恢复完成${NC}"
fi

# 恢复日志文件（可选）
echo -e "${YELLOW}是否要恢复历史日志文件？(y/N)${NC}"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo -e "${BLUE}恢复历史日志...${NC}"
    
    # 创建日志备份目录
    mkdir -p logs/historical_backup
    
    # 复制历史日志
    docker run --rm -v dev_airflow_logs:/old_logs -v $(pwd)/logs/historical_backup:/backup alpine sh -c "
        cp -r /old_logs/* /backup/ 2>/dev/null || echo '无法复制日志文件'
    "
    
    echo -e "${GREEN}✅ 历史日志已备份到 logs/historical_backup/${NC}"
fi

# 清理临时文件
echo -e "${BLUE}清理临时文件...${NC}"
rm -f historical_jobs.sql airflow_metadata.sql

# 停止临时容器
echo -e "${BLUE}停止临时容器...${NC}"
docker stop temp_postgres_old

echo -e "${GREEN}🎉 历史数据恢复完成！${NC}"
echo -e "${BLUE}现在可以访问:${NC}"
echo -e "${GREEN}  - Prompt Manager: http://localhost:5001${NC}"
echo -e "${GREEN}  - Airflow: http://localhost:8081${NC}" 