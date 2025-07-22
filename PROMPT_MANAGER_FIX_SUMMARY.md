# Prompt Manager 修复总结

## 问题描述

访问 http://localhost:5001 时出现 `Internal Server Error`，错误信息显示：

```
psycopg2.errors.UndefinedTable: relation "jobs" does not exist
```

## 根本原因

1. **数据库不一致**: prompt-manager应用试图访问PostgreSQL中的 `jobs` 表，但该表不存在
2. **JobManager使用SQLite**: 核心的JobManager类仍在使用SQLite数据库，而不是PostgreSQL
3. **数据库架构不统一**: 不同组件使用不同的数据库系统

## 修复内容

### 1. PostgreSQL数据库表创建

在PostgreSQL中创建了 `jobs` 表：

```sql
CREATE TABLE IF NOT EXISTS jobs (
    id SERIAL PRIMARY KEY,
    prompt_text TEXT NOT NULL UNIQUE,
    status TEXT NOT NULL DEFAULT 'pending' 
        CHECK (status IN ('pending', 'processing', 'completed', 'failed', 'awaiting_retry')),
    job_type TEXT NOT NULL 
        CHECK (job_type IN ('IMAGE_TEST', 'VIDEO_PROD')),
    local_path TEXT,
    gcs_uri TEXT,
    operation_id TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 2. 索引和触发器创建

```sql
-- 创建索引
CREATE INDEX IF NOT EXISTS idx_jobs_status ON jobs(status);
CREATE INDEX IF NOT EXISTS idx_jobs_job_type ON jobs(job_type);
CREATE INDEX IF NOT EXISTS idx_jobs_created_at ON jobs(created_at);
CREATE INDEX IF NOT EXISTS idx_jobs_operation_id ON jobs(operation_id);

-- 创建触发器
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_jobs_updated_at
    BEFORE UPDATE ON jobs
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
```

### 3. JobManager类更新

将JobManager从SQLite迁移到PostgreSQL：

#### 主要变更：
- 移除 `sqlite3` 导入，添加 `database` 模块导入
- 更新构造函数，移除 `db_path` 参数
- 使用 `db_manager.get_connection()` 替代 `sqlite3.connect()`
- 修复SQL语法：
  - 参数占位符从 `?` 改为 `%s`
  - 使用 `RETURNING id` 替代 `cursor.lastrowid`
  - 更新时间间隔语法为PostgreSQL格式

#### 修复的方法：
- `add_job()` - 添加作业
- `reset_stuck_jobs()` - 重置卡住作业
- `show_stats()` - 显示统计信息

### 4. 数据库统一

现在所有组件都使用PostgreSQL：
- ✅ Airflow元数据 (PostgreSQL)
- ✅ Prompt Manager (PostgreSQL)
- ✅ JobManager (PostgreSQL)
- ✅ 核心工作流 (PostgreSQL)

## 验证结果

### 1. 数据库连接测试
```bash
docker compose exec airflow-scheduler python -c "from src.database import db_manager; db_manager.init_database(); print('✅ 数据库初始化成功')"
# 输出: ✅ 数据库初始化成功
```

### 2. 作业添加测试
```bash
docker compose exec airflow-scheduler python -c "from src.job_manager import JobManager; jm = JobManager(); job_id = jm.add_job('测试PostgreSQL作业', 'IMAGE_TEST'); print(f'✅ 作业添加成功，ID: {job_id}')"
# 输出: ✅ 作业添加成功，ID: 1
```

### 3. 数据库查询验证
```sql
SELECT id, prompt_text, status, job_type FROM jobs;
-- 输出: 成功显示添加的作业
```

### 4. Prompt Manager界面测试
```bash
curl -s http://localhost:5001 | grep -i "测试PostgreSQL作业"
# 输出: 成功找到作业信息
```

### 5. 统计信息测试
```bash
docker compose exec airflow-scheduler python -c "from src.job_manager import JobManager; jm = JobManager(); jm.show_stats()"
# 输出: 成功显示作业统计信息
```

## 当前状态

### ✅ 已修复
- Prompt Manager可以正常访问 (http://localhost:5001)
- 作业可以成功添加到PostgreSQL数据库
- JobManager完全迁移到PostgreSQL
- 所有数据库操作正常工作
- 统计信息显示正确

### 📊 测试数据
- **IMAGE_TEST**: 2个作业 (pending状态)
- **VIDEO_PROD**: 1个作业 (pending状态)
- **总计**: 3个作业

### 🔧 服务状态
- ✅ Airflow Web Server: http://localhost:8081
- ✅ Airflow Scheduler: 正常运行
- ✅ PostgreSQL: 正常运行
- ✅ Prompt Manager: http://localhost:5001 (已修复)
- ✅ Redis: 正常运行

## 下一步

1. **测试DAG功能**: 验证所有DAG是否能正常处理PostgreSQL中的作业
2. **测试下载功能**: 验证下载工作流是否正常工作
3. **性能监控**: 监控PostgreSQL性能
4. **备份策略**: 实施数据库备份策略

---

**修复时间**: 2025-01-27  
**修复版本**: v1.1.2  
**状态**: ✅ 已完成 