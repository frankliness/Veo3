import os
import psycopg2
from flask import Flask, render_template, request, redirect, url_for
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)

def get_db_connection():
    # 使用Docker容器中的PostgreSQL服务
    conn = psycopg2.connect(
        host='postgres',  # Docker服务名
        database='airflow',
        user='airflow',
        password='airflow',
        port=5432
    )
    return conn

@app.route('/')
def index():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('SELECT id, prompt_text, status, job_type, created_at FROM jobs ORDER BY id DESC;')
    jobs = cur.fetchall()
    cur.close()
    conn.close()

    status_colors = {
        'pending': 'secondary',
        'processing': 'primary',
        'completed': 'success',
        'failed': 'danger'
    }

    return render_template('index.html', jobs=jobs, status_colors=status_colors)

@app.route('/add', methods=['POST'])
def add_prompt():
    prompt_text = request.form['prompt_text']
    job_type = request.form['job_type']
    
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("INSERT INTO jobs (prompt_text, job_type, status) VALUES (%s, %s, 'pending')",
                (prompt_text, job_type))
    conn.commit()
    cur.close()
    conn.close()
    
    return redirect(url_for('index'))

@app.route('/requeue/<int:job_id>', methods=['POST'])
def requeue_job(job_id):
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("UPDATE jobs SET status = 'pending' WHERE id = %s", (job_id,))
    conn.commit()
    cur.close()
    conn.close()
    
    return redirect(url_for('index'))

@app.route('/delete/<int:job_id>', methods=['POST'])
def delete_job(job_id):
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("DELETE FROM jobs WHERE id = %s", (job_id,))
    conn.commit()
    cur.close()
    conn.close()
    
    return redirect(url_for('index'))

if __name__ == '__main__':
    app.run(debug=True)
