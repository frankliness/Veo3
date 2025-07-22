#!/bin/bash

# AI ASMR Veo3 项目清理脚本
# 清理临时文件、日志和重复文件

echo "🧹 开始清理AI ASMR Veo3项目..."

# 1. 清理Python缓存文件
echo "📁 清理Python缓存文件..."
find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null
find . -name "*.pyc" -type f -delete 2>/dev/null
find . -name "*.pyo" -type f -delete 2>/dev/null

# 2. 清理临时文件
echo "🗑️ 清理临时文件..."
find . -name "*.tmp" -type f -delete 2>/dev/null
find . -name "*.temp" -type f -delete 2>/dev/null
find . -name "*~" -type f -delete 2>/dev/null
find . -name ".#*" -type f -delete 2>/dev/null
find . -name ".DS_Store" -type f -delete 2>/dev/null

# 3. 清理outputs目录中的重复文件
echo "📂 清理outputs目录中的重复文件..."
if [ -d "outputs" ]; then
    # 删除备份文件
    find outputs/ -name "*backup*" -type f -delete 2>/dev/null
    find outputs/ -name "*old*" -type f -delete 2>/dev/null
    
    # 删除旧的sample文件（保留最新的）
    echo "   - 保留最新的动态命名文件"
    echo "   - 删除旧的sample_0.mp4文件"
    find outputs/ -name "sample_0.mp4" -type f -delete 2>/dev/null
fi

# 4. 清理旧日志文件（保留最近7天）
echo "📋 清理旧日志文件..."
find logs/ -name "*.log" -mtime +7 -delete 2>/dev/null
find logs/ -name "*.jsonl" -mtime +7 -delete 2>/dev/null

# 5. 清理Docker相关临时文件
echo "🐳 清理Docker临时文件..."
docker system prune -f 2>/dev/null

# 6. 显示清理结果
echo ""
echo "📊 清理完成！"
echo ""

# 显示当前outputs目录状态
if [ -d "outputs" ]; then
    echo "📂 outputs目录当前文件:"
    ls -la outputs/ | grep -E "\.(mp4|png)$" | wc -l | xargs echo "   - 视频/图片文件数量:"
    du -sh outputs/ | xargs echo "   - 总大小:"
fi

# 显示项目大小
echo ""
echo "📁 项目总体状态:"
du -sh . | xargs echo "   - 项目总大小:"
find . -name "*.py" | wc -l | xargs echo "   - Python文件数量:"
find . -name "*.md" | wc -l | xargs echo "   - 文档文件数量:"

echo ""
echo "✅ 项目清理完成！"
echo "💡 建议定期运行此脚本以保持项目整洁" 