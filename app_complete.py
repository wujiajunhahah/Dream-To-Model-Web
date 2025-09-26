#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from flask import Flask, render_template, request, redirect, url_for, flash, jsonify, make_response
import os

# 创建Flask应用
app = Flask(__name__)
app.config['SECRET_KEY'] = 'complete-dreamecho'

# 模拟用户状态
class MockUser:
    def __init__(self):
        self.is_authenticated = False
        self.username = None

current_user = MockUser()

# 主页路由
@app.route('/')
def index():
    # 模拟一些最近的模型数据
    recent_models = [
        {'id': 1, 'title': 'Flying Dragon Dream', 'description': 'A majestic dragon soaring through clouds'},
        {'id': 2, 'title': 'Underwater Palace', 'description': 'A beautiful palace beneath the ocean waves'},
        {'id': 3, 'title': 'Forest Guardian', 'description': 'A mystical creature protecting the ancient forest'}
    ]
    
    response = make_response(render_template('index_complete.html', 
                                           recent_models=recent_models, 
                                           current_user=current_user))
    
    # 添加缓存头
    response.headers['Cache-Control'] = 'public, max-age=300'  # 5分钟缓存
    return response

# 创建梦境页面
@app.route('/create_dream')
def create_dream():
    return render_template('create_dream_complete.html', current_user=current_user)

# 模型库页面
@app.route('/model_library')
def model_library():
    # 模拟模型数据
    models = [
        {'id': 1, 'title': 'Flying Dragon Dream', 'description': 'A majestic dragon soaring through clouds', 'author': 'DreamUser1'},
        {'id': 2, 'title': 'Underwater Palace', 'description': 'A beautiful palace beneath the ocean waves', 'author': 'DreamUser2'},
        {'id': 3, 'title': 'Forest Guardian', 'description': 'A mystical creature protecting the ancient forest', 'author': 'DreamUser3'},
        {'id': 4, 'title': 'Space Station', 'description': 'A futuristic space station orbiting Earth', 'author': 'DreamUser4'},
        {'id': 5, 'title': 'Magic Castle', 'description': 'An enchanted castle floating in the sky', 'author': 'DreamUser5'},
        {'id': 6, 'title': 'Robot Companion', 'description': 'A friendly robot helper from the future', 'author': 'DreamUser6'}
    ]
    return render_template('model_library_complete.html', models=models, current_user=current_user)

# 登录页面
@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')
        
        # 简单的模拟登录
        if username and password:
            current_user.is_authenticated = True
            current_user.username = username
            flash('登录成功！', 'success')
            return redirect(url_for('index'))
        else:
            flash('请填写用户名和密码', 'error')
    
    return render_template('login_complete.html', current_user=current_user)

# 注册页面
@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        username = request.form.get('username')
        email = request.form.get('email')
        password = request.form.get('password')
        
        if username and email and password:
            flash('注册成功！请登录', 'success')
            return redirect(url_for('login'))
        else:
            flash('请填写所有字段', 'error')
    
    return render_template('register_complete.html', current_user=current_user)

# 退出登录
@app.route('/logout')
def logout():
    current_user.is_authenticated = False
    current_user.username = None
    flash('已成功退出登录', 'success')
    return redirect(url_for('index'))

# 关于页面
@app.route('/about')
def about():
    return render_template('about_complete.html', current_user=current_user)

# 个人资料页面
@app.route('/profile')
def profile():
    if not current_user.is_authenticated:
        return redirect(url_for('login'))
    
    # 模拟用户的梦境数据
    user_dreams = [
        {'id': 1, 'title': 'My First Dream', 'description': 'A beautiful landscape from my childhood', 'is_public': True},
        {'id': 2, 'title': 'Secret Garden', 'description': 'A hidden garden with magical flowers', 'is_public': False}
    ]
    
    return render_template('profile_complete.html', 
                         current_user=current_user, 
                         user_dreams=user_dreams,
                         public_dreams=[d for d in user_dreams if d['is_public']],
                         private_dreams=[d for d in user_dreams if not d['is_public']])

# 健康检查
@app.route('/health')
def health():
    return {'status': 'ok', 'message': 'Complete version running fast!'}

# 静态文件缓存优化
@app.after_request
def after_request(response):
    # 为静态文件添加长期缓存
    if request.endpoint == 'static':
        response.headers['Cache-Control'] = 'public, max-age=31536000'  # 1年
    
    # 添加安全头
    response.headers['X-Content-Type-Options'] = 'nosniff'
    response.headers['X-Frame-Options'] = 'DENY'
    response.headers['X-XSS-Protection'] = '1; mode=block'
    
    return response

if __name__ == '__main__':
    print("🚀 DreamEcho Complete Version - Fast & Full Featured!")
    print("📱 URL: http://localhost:5008")
    print("✨ Features: Full Navigation, Create Dream, Model Library, Login/Register")
    app.run(host='0.0.0.0', port=5008, debug=False, threaded=True) 