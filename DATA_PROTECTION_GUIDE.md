# 数据保护指南

## 问题解答

### Q: 为什么重启服务后要初始化数据库？

**A: 之前的初始化逻辑确实有问题，现在已经优化！**

#### 之前的问题：
1. **过度初始化**: 每次创建 `JobManager` 实例都会调用 `init_database()`
2. **无数据卷**: PostgreSQL没有配置数据卷，重启后数据丢失
3. **重复检查**: 没有检查表是否已存在

#### 现在的优化：
1. ✅ **智能初始化**: 只在表不存在时才初始化
2. ✅ **数据持久化**: PostgreSQL数据存储在Docker卷中
3. ✅ **按需检查**: 使用 `check_table_exists()` 避免重复初始化

### Q: 我的数据会被删除吗？

**A: 不会！数据是安全的。**

#### 数据安全机制：
1. **CREATE TABLE IF NOT EXISTS**: 表已存在时不会重新创建
2. **ALTER TABLE**: 只添加缺失的字段，不删除数据
3. **数据卷**: PostgreSQL数据持久化存储
4. **备份机制**: 提供自动备份和恢复功能

## 数据保护措施

### 1. 数据库持久化

PostgreSQL数据现在存储在Docker卷中：
```yaml
volumes:
  - postgres_data:/var/lib/postgresql/data
```

**重启后数据不会丢失！**

### 2. 智能初始化

```python
def init_database(self):
    # 首先检查表是否已存在
    if self.check_table_exists('jobs'):
        logger.info("jobs表已存在，跳过初始化")
        return
    # 只在表不存在时才创建
```

### 3. 自动备份

#### 创建备份：
```bash
./backup_database.sh
```

#### 恢复备份：
```bash
./restore_database.sh
```

### 4. 数据验证

检查当前数据：
```bash
# 查看作业数量
docker compose exec postgres psql -U airflow -d airflow -c "SELECT COUNT(*) FROM jobs;"

# 查看作业详情
docker compose exec postgres psql -U airflow -d airflow -c "SELECT id, prompt_text, status FROM jobs;"
```

## 最佳实践

### 1. 定期备份
```bash
# 添加到crontab，每天凌晨2点备份
0 2 * * * cd /path/to/project && ./backup_database.sh
```

### 2. 重启前备份
```bash
# 重启服务前先备份
./backup_database.sh
docker compose restart
```

### 3. 监控数据
```bash
# 检查数据完整性
docker compose exec airflow-scheduler python -c "from src.job_manager import JobManager; jm = JobManager(); jm.show_stats()"
```

## 故障恢复

### 如果数据丢失了怎么办？

1. **检查Docker卷**:
   ```bash
   docker volume ls | grep postgres_data
   ```

2. **恢复最新备份**:
   ```bash
   ./restore_database.sh
   ```

3. **手动恢复**:
   ```bash
   docker compose exec -T postgres psql -U airflow -d airflow < backups/airflow_backup_YYYYMMDD_HHMMSS.sql
   ```

## 性能优化

### 1. 避免重复初始化
- JobManager不再自动初始化数据库
- DAG只在表不存在时初始化
- 使用 `check_table_exists()` 检查

### 2. 数据库连接池
- 使用 `db_manager.get_connection()` 统一管理连接
- 自动处理连接关闭

### 3. 索引优化
- 为常用查询字段创建索引
- 定期分析查询性能

## 监控和维护

### 1. 数据监控
```bash
# 监控作业状态
docker compose exec airflow-scheduler python -c "from src.job_manager import JobManager; jm = JobManager(); jm.show_stats()"

# 监控数据库大小
docker compose exec postgres psql -U airflow -d airflow -c "SELECT pg_size_pretty(pg_database_size('airflow'));"
```

### 2. 日志监控
```bash
# 查看数据库相关日志
docker compose logs postgres | grep -i "error\|warning"

# 查看应用日志
docker compose logs airflow-scheduler | grep -i "database\|init"
```

### 3. 定期维护
```bash
# 清理旧备份（保留最近10个）
ls -t backups/airflow_backup_*.sql | tail -n +11 | xargs -r rm

# 清理旧日志
docker compose exec airflow-scheduler find /opt/airflow/logs -name "*.log" -mtime +7 -delete
```

## 总结

✅ **数据现在是安全的！**

- **持久化存储**: PostgreSQL数据不会因重启丢失
- **智能初始化**: 避免不必要的数据库操作
- **自动备份**: 提供数据恢复机制
- **性能优化**: 减少重复初始化开销

**重启服务时，你的数据会完整保留！**

---

**文档版本**: v1.0  
**更新时间**: 2025-01-27  
**状态**: ✅ 已实施 