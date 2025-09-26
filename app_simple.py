#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from flask import Flask, render_template

# 创建Flask应用
app = Flask(__name__)
app.config['SECRET_KEY'] = 'simple-dreamecho'

# 简化路由，直接渲染模板
@app.route('/')
def index():
    # 模拟一些数据，避免数据库查询
    recent_models = []
    return render_template('index_original.html', recent_models=recent_models, current_user=None)

@app.route('/health')
def health():
    return {'status': 'ok', 'message': 'Simple version running'}

if __name__ == '__main__':
    print("🚀 DreamEcho Simple Version starting...")
    print("📱 URL: http://localhost:5006")
    app.run(host='0.0.0.0', port=5006, debug=False, threaded=True) 