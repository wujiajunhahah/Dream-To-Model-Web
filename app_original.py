#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import logging
from datetime import datetime
from flask import Flask, render_template, request, redirect, url_for, flash, jsonify, make_response
from flask_sqlalchemy import SQLAlchemy
from flask_login import LoginManager, login_user, logout_user, login_required, current_user, UserMixin
from werkzeug.security import generate_password_hash, check_password_hash
import secrets

# 创建Flask应用
app = Flask(__name__)

# 配置
app.config['SECRET_KEY'] = secrets.token_hex(16)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///original_dreamecho.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

# 初始化扩展
db = SQLAlchemy(app)
login_manager = LoginManager()
login_manager.init_app(app)
login_manager.login_view = 'login'

# 性能优化：添加缓存头
@app.after_request
def after_request(response):
    # 为静态文件设置长期缓存
    if request.endpoint == 'static':
        response.cache_control.max_age = 31536000  # 1年
        response.cache_control.public = True
    # 为HTML页面设置短期缓存
    elif response.content_type.startswith('text/html'):
        response.cache_control.max_age = 300  # 5分钟
        response.cache_control.public = True
    
    # 添加安全头
    response.headers['X-Content-Type-Options'] = 'nosniff'
    response.headers['X-Frame-Options'] = 'DENY'
    response.headers['X-XSS-Protection'] = '1; mode=block'
    
    return response

# 数据模型
class User(UserMixin, db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(64), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(128))
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    dreams = db.relationship('Dream', backref='author', lazy='dynamic')

    def set_password(self, password):
        self.password_hash = generate_password_hash(password)

    def check_password(self, password):
        return check_password_hash(self.password_hash, password)

class Dream(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(100), nullable=False)
    description = db.Column(db.Text, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    # 梦境属性
    mood = db.Column(db.String(50))
    style = db.Column(db.String(50))
    blockchain = db.Column(db.String(20), default='ethereum')
    initial_price = db.Column(db.Float, default=0.1)
    is_public = db.Column(db.Boolean, default=True)
    status = db.Column(db.String(20), default='completed')
    
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)

@login_manager.user_loader
def load_user(user_id):
    return User.query.get(int(user_id))

# 路由
@app.route('/')
def index():
    recent_models = Dream.query.filter_by(is_public=True).order_by(Dream.created_at.desc()).limit(6).all()
    response = make_response(render_template('index_original.html', recent_models=recent_models))
    return response

@app.route('/create_dream', methods=['GET', 'POST'])
@login_required
def create_dream():
    if request.method == 'POST':
        dream_title = request.form.get('dream_title', '').strip()
        dream_description = request.form.get('dream_description', '').strip()
        dream_mood = request.form.get('dream_mood', '')
        dream_style = request.form.get('dream_style', '')
        blockchain = request.form.get('blockchain', '')
        initial_price = request.form.get('initial_price', type=float)
        is_public = 'is_public' in request.form
        
        if not dream_title or not dream_description or not blockchain:
            flash('Please fill in all required fields', 'error')
            return render_template('create_dream_original.html')
        
        if len(dream_description) < 50:
            flash('Dream description must be at least 50 characters', 'error')
            return render_template('create_dream_original.html')
        
        new_model = Dream(
            title=dream_title,
            description=dream_description,
            mood=dream_mood,
            style=dream_style,
            blockchain=blockchain,
            initial_price=initial_price or 0.1,
            is_public=is_public,
            user_id=current_user.id
        )
        
        db.session.add(new_model)
        db.session.commit()
        
        flash('Dream created successfully!', 'success')
        return redirect(url_for('model_library'))
    
    return render_template('create_dream_original.html')

@app.route('/model_library')
def model_library():
    page = request.args.get('page', 1, type=int)
    models = Dream.query.filter_by(is_public=True).order_by(Dream.created_at.desc()).paginate(
        page=page, per_page=12, error_out=False
    )
    return render_template('model_library_original.html', models=models)

@app.route('/login', methods=['GET', 'POST'])
def login():
    if current_user.is_authenticated:
        return redirect(url_for('index'))
    
    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')
        
        user = User.query.filter_by(username=username).first()
        
        if user and user.check_password(password):
            login_user(user)
            next_page = request.args.get('next')
            if next_page:
                return redirect(next_page)
            return redirect(url_for('create_dream'))
        else:
            flash('Invalid username or password', 'error')
    
    return render_template('login_original.html')

@app.route('/register', methods=['GET', 'POST'])
def register():
    if current_user.is_authenticated:
        return redirect(url_for('index'))
    
    if request.method == 'POST':
        username = request.form.get('username')
        email = request.form.get('email')
        password = request.form.get('password')
        
        if User.query.filter_by(username=username).first():
            flash('Username already exists', 'error')
            return render_template('register_original.html')
        
        if User.query.filter_by(email=email).first():
            flash('Email already registered', 'error')
            return render_template('register_original.html')
        
        user = User(username=username, email=email)
        user.set_password(password)
        db.session.add(user)
        db.session.commit()
        
        flash('Registration successful! Please login', 'success')
        return redirect(url_for('login'))
    
    return render_template('register_original.html')

@app.route('/logout')
@login_required
def logout():
    logout_user()
    flash('Successfully logged out', 'success')
    return redirect(url_for('index'))

# 性能监控端点
@app.route('/health')
def health_check():
    return jsonify({'status': 'healthy', 'timestamp': datetime.utcnow().isoformat()})

@app.route('/test_images')
def test_images():
    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <title>图片测试</title>
        <style>
            body { 
                background: #1a1a1a; 
                color: white; 
                font-family: Arial, sans-serif;
                padding: 20px;
            }
            img { 
                max-width: 100%; 
                height: auto; 
                border: 2px solid #4ade80;
                border-radius: 10px;
                margin: 10px 0;
            }
            .container {
                max-width: 800px;
                margin: 0 auto;
                text-align: center;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>图片显示测试</h1>
            <h2>您的图片：已移除背景的网站图拍呢.png</h2>
            <img src="/static/images/已移除背景的网站图拍呢.png" alt="您的网站图片">
            
            <h2>头像图片：avatar.jpg</h2>
            <img src="/static/images/avatar.jpg" alt="头像" style="width: 200px; height: 200px; object-fit: cover; border-radius: 50%;">
            
            <h2>微信二维码：default-qr.png</h2>
            <img src="/static/images/default-qr.png" alt="微信二维码" style="width: 200px; height: 200px;">
            
            <p><a href="/" style="color: #4ade80;">返回首页</a></p>
        </div>
    </body>
    </html>
    '''

# 创建数据库表
with app.app_context():
    db.create_all()
    
    # 创建默认管理员用户
    if not User.query.filter_by(username='admin').first():
        admin = User(username='admin', email='admin@dreamecho.com')
        admin.set_password('admin123')
        db.session.add(admin)
        db.session.commit()
        print("Created default admin user: admin/admin123")

if __name__ == '__main__':
    print("DreamEcho Original Design running on http://localhost:5003")
    app.run(host='0.0.0.0', port=5003, debug=True) 