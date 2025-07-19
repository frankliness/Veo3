# Dockerfile
FROM apache/airflow:2.9.2

# 设置工作目录
WORKDIR /opt/airflow

# 安装系统依赖
USER root
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 切换回airflow用户
USER airflow

# 复制项目依赖文件
COPY requirements.txt .

# 安装Python依赖
RUN pip install --no-cache-dir -r requirements.txt

# 复制项目源代码到镜像中
COPY src/ /opt/airflow/src/
COPY prompts/ /opt/airflow/prompts/

# 创建必要的目录
RUN mkdir -p /opt/airflow/dags /opt/airflow/logs /opt/airflow/plugins /opt/airflow/outputs

# 设置环境变量
ENV PYTHONPATH="${PYTHONPATH}:/opt/airflow/src"
ENV AIRFLOW_HOME=/opt/airflow

# 设置默认命令
CMD ["webserver"] 