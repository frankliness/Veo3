#!/usr/bin/env python3
"""
调试脚本：检查Python路径和模块导入
"""

import sys
import os

print("🔍 Python路径调试")
print("=" * 50)

# 显示当前Python路径
print("当前Python路径:")
for i, path in enumerate(sys.path):
    print(f"  {i}: {path}")

print("\n" + "=" * 50)

# 检查src目录
src_path = "/opt/airflow/src"
print(f"检查src目录: {src_path}")
print(f"目录是否存在: {os.path.exists(src_path)}")

if os.path.exists(src_path):
    print("src目录内容:")
    try:
        files = os.listdir(src_path)
        for file in files:
            print(f"  - {file}")
    except Exception as e:
        print(f"读取目录失败: {e}")

print("\n" + "=" * 50)

# 尝试添加src路径
print("尝试添加src路径到Python路径...")
if src_path not in sys.path:
    sys.path.append(src_path)
    print("✅ 已添加src路径到Python路径")
else:
    print("ℹ️  src路径已在Python路径中")

print("\n" + "=" * 50)

# 尝试导入模块
print("尝试导入模块...")

try:
    import database
    print("✅ 成功导入 database 模块")
except ImportError as e:
    print(f"❌ 导入 database 模块失败: {e}")

try:
    import core_workflow
    print("✅ 成功导入 core_workflow 模块")
except ImportError as e:
    print(f"❌ 导入 core_workflow 模块失败: {e}")

try:
    import image_generator
    print("✅ 成功导入 image_generator 模块")
except ImportError as e:
    print(f"❌ 导入 image_generator 模块失败: {e}")

print("\n" + "=" * 50)
print("调试完成") 