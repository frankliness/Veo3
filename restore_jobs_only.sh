#!/bin/bash

# 只恢复jobs数据的脚本

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}开始恢复历史jobs数据...${NC}"

# 启动临时PostgreSQL容器
echo -e "${YELLOW}启动临时PostgreSQL容器...${NC}"
docker run --name temp_postgres_old --rm -d \
    -v ai-asmr-veo3-batch_postgres-db-volume:/var/lib/postgresql/data \
    -e POSTGRES_USER=airflow \
    -e POSTGRES_PASSWORD=airflow \
    -e POSTGRES_DB=airflow \
    postgres:13

echo -e "${BLUE}等待PostgreSQL启动...${NC}"
sleep 10

# 导出历史jobs数据
echo -e "${BLUE}导出历史jobs数据...${NC}"
docker exec temp_postgres_old psql -U airflow -d airflow -c "
SELECT 
    id,
    prompt_text,
    status,
    job_type,
    COALESCE(local_path, ''),
    COALESCE(gcs_uri, ''),
    created_at,
    updated_at
FROM jobs 
ORDER BY id;
" > historical_jobs_data.txt

# 检查导出的数据
if [ -s historical_jobs_data.txt ]; then
    echo -e "${GREEN}✅ 成功导出历史数据${NC}"
    JOB_COUNT=$(grep -c "^[0-9]" historical_jobs_data.txt)
    echo -e "${BLUE}历史作业数量: $JOB_COUNT${NC}"
else
    echo -e "${RED}❌ 导出历史数据失败${NC}"
    docker stop temp_postgres_old
    exit 1
fi

# 备份当前数据
echo -e "${BLUE}备份当前数据...${NC}"
./backup_database.sh

# 清理当前jobs表
echo -e "${YELLOW}清理当前jobs表...${NC}"
docker compose exec postgres psql -U airflow -d airflow -c "TRUNCATE TABLE jobs RESTART IDENTITY;"

# 导入历史数据
echo -e "${BLUE}导入历史数据...${NC}"
while IFS='|' read -r id prompt_text status job_type local_path gcs_uri created_at updated_at; do
    # 跳过标题行和空行
    if [[ "$id" =~ ^[0-9]+$ ]]; then
        # 转义单引号
        prompt_text=$(echo "$prompt_text" | sed "s/'/''/g")
        local_path=$(echo "$local_path" | sed "s/'/''/g")
        gcs_uri=$(echo "$gcs_uri" | sed "s/'/''/g")
        
        docker compose exec postgres psql -U airflow -d airflow -c "
        INSERT INTO jobs (id, prompt_text, status, job_type, local_path, gcs_uri, created_at, updated_at)
        VALUES ($id, '$prompt_text', '$status', '$job_type', '$local_path', '$gcs_uri', '$created_at', '$updated_at');
        "
    fi
done < historical_jobs_data.txt

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

# 恢复日志文件
echo -e "${BLUE}恢复历史日志...${NC}"
mkdir -p logs/historical_backup

# 复制历史日志
docker run --rm \
    -v dev_airflow_logs:/old_logs \
    -v "$(pwd)/logs/historical_backup:/backup" \
    alpine sh -c "cp -r /old_logs/* /backup/ 2>/dev/null || echo '无法复制日志文件'"

echo -e "${GREEN}✅ 历史日志已备份到 logs/historical_backup/${NC}"

# 清理临时文件
echo -e "${BLUE}清理临时文件...${NC}"
rm -f historical_jobs_data.txt

# 停止临时容器
echo -e "${BLUE}停止临时容器...${NC}"
docker stop temp_postgres_old

echo -e "${GREEN}🎉 历史jobs数据恢复完成！${NC}"
echo -e "${BLUE}现在可以访问:${NC}"
echo -e "${GREEN}  - Prompt Manager: http://localhost:5001${NC}"
echo -e "${GREEN}  - Airflow: http://localhost:8081${NC}"
echo -e "${BLUE}历史日志位置: logs/historical_backup/${NC}" 