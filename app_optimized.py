#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import logging
from datetime import datetime, timedelta
from flask import Flask, render_template, request, redirect, url_for, flash, jsonify, make_response
from flask_sqlalchemy import SQLAlchemy
from flask_login import LoginManager, login_user, logout_user, login_required, current_user, UserMixin
from flask_compress import Compress
from flask_caching import Cache
from werkzeug.security import generate_password_hash, check_password_hash
import secrets

# 创建Flask应用
app = Flask(__name__)

# 配置
app.config['SECRET_KEY'] = secrets.token_hex(16)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///optimized_dreamecho.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

# 缓存配置
app.config['CACHE_TYPE'] = 'simple'
app.config['CACHE_DEFAULT_TIMEOUT'] = 300  # 5分钟缓存

# 初始化扩展
db = SQLAlchemy(app)
login_manager = LoginManager()
login_manager.init_app(app)
login_manager.login_view = 'login'

# 初始化压缩和缓存
compress = Compress(app)
cache = Cache(app)

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

# 静态文件缓存中间件
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
    return response

# 路由
@app.route('/')
@cache.cached(timeout=300)  # 缓存5分钟
def index():
    recent_models = Dream.query.filter_by(is_public=True).order_by(Dream.created_at.desc()).limit(6).all()
    response = make_response(render_template('index_original.html', recent_models=recent_models))
    # 添加性能优化头部
    response.headers['X-Content-Type-Options'] = 'nosniff'
    response.headers['X-Frame-Options'] = 'DENY'
    response.headers['X-XSS-Protection'] = '1; mode=block'
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
        
        # 清除首页缓存
        cache.delete('view//index')
        
        flash('Dream created successfully!', 'success')
        return redirect(url_for('model_library'))
    
    return render_template('create_dream_original.html')

@app.route('/model_library')
def model_library():
    page = request.args.get('page', 1, type=int)
    cache_key = f'model_library_page_{page}'
    
    # 尝试从缓存获取
    cached_result = cache.get(cache_key)
    if cached_result:
        return cached_result
    
    models = Dream.query.filter_by(is_public=True).order_by(Dream.created_at.desc()).paginate(
        page=page, per_page=12, error_out=False
    )
    
    response = make_response(render_template('model_library_original.html', models=models))
    cache.set(cache_key, response, timeout=300)  # 缓存5分钟
    return response

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

# API路由用于快速数据获取
@app.route('/api/recent_dreams')
@cache.cached(timeout=60)  # 缓存1分钟
def api_recent_dreams():
    dreams = Dream.query.filter_by(is_public=True).order_by(Dream.created_at.desc()).limit(6).all()
    return jsonify([{
        'id': dream.id,
        'title': dream.title,
        'description': dream.description[:100] + '...' if len(dream.description) > 100 else dream.description,
        'created_at': dream.created_at.isoformat()
    } for dream in dreams])

# 健康检查端点
@app.route('/health')
def health_check():
    return jsonify({'status': 'healthy', 'timestamp': datetime.utcnow().isoformat()})

# 清除缓存端点（仅用于开发）
@app.route('/clear_cache')
def clear_cache():
    if app.debug:
        cache.clear()
        return jsonify({'message': 'Cache cleared'})
    return jsonify({'error': 'Not allowed'}), 403

# 性能监控路由
@app.route('/performance')
def performance_stats():
    if app.debug:
        import psutil
        import time
        
        # 获取系统信息
        cpu_percent = psutil.cpu_percent(interval=1)
        memory = psutil.virtual_memory()
        
        # 数据库查询性能
        start_time = time.time()
        dream_count = Dream.query.count()
        user_count = User.query.count()
        db_query_time = (time.time() - start_time) * 1000
        
        return jsonify({
            'cpu_usage': f'{cpu_percent}%',
            'memory_usage': f'{memory.percent}%',
            'memory_available': f'{memory.available / 1024 / 1024:.1f} MB',
            'database': {
                'dreams': dream_count,
                'users': user_count,
                'query_time_ms': f'{db_query_time:.2f}'
            },
            'cache_stats': {
                'type': app.config['CACHE_TYPE'],
                'timeout': app.config['CACHE_DEFAULT_TIMEOUT']
            }
        })
    return jsonify({'error': 'Not available in production'}), 403

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
    print("DreamEcho Optimized Version running on http://localhost:5004")
    print("Features: Compression, Caching, Static File Optimization")
    app.run(host='0.0.0.0', port=5004, debug=True, threaded=True) 