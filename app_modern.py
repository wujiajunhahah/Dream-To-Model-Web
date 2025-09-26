#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import logging
from datetime import datetime
from flask import Flask, render_template, request, redirect, url_for, flash, jsonify, session
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask_login import LoginManager, login_user, logout_user, login_required, current_user
from werkzeug.security import generate_password_hash, check_password_hash
from werkzeug.utils import secure_filename
import secrets

# 创建Flask应用
app = Flask(__name__)

# 配置
app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY') or secrets.token_hex(16)
app.config['SQLALCHEMY_DATABASE_URI'] = os.environ.get('DATABASE_URL') or 'sqlite:///modern_dreamecho.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['UPLOAD_FOLDER'] = 'static/uploads'
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024  # 16MB max file size

# 初始化扩展
db = SQLAlchemy(app)
migrate = Migrate(app, db)
login_manager = LoginManager()
login_manager.init_app(app)
login_manager.login_view = 'login'
login_manager.login_message = '请先登录以访问此页面'

# 配置日志
logging.basicConfig(level=logging.INFO)
app.logger.setLevel(logging.INFO)

# 数据模型
from flask_login import UserMixin

class User(UserMixin, db.Model):
    """用户模型"""
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(64), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(128))
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    avatar_url = db.Column(db.String(200))
    
    # 用户偏好设置
    email_notifications = db.Column(db.Boolean, default=True)
    browser_notifications = db.Column(db.Boolean, default=False)
    dark_mode = db.Column(db.Boolean, default=True)
    animations_enabled = db.Column(db.Boolean, default=True)
    
    # 用户统计
    dream_count = db.Column(db.Integer, default=0)
    last_login = db.Column(db.DateTime)
    
    # 关联
    dreams = db.relationship('Dream', backref='author', lazy='dynamic')

    def set_password(self, password):
        """设置密码"""
        self.password_hash = generate_password_hash(password)

    def check_password(self, password):
        """验证密码"""
        return check_password_hash(self.password_hash, password)

    def to_dict(self):
        """转换为字典"""
        return {
            'id': self.id,
            'username': self.username,
            'email': self.email,
            'avatar_url': self.avatar_url,
            'created_at': self.created_at.isoformat(),
            'dream_count': self.dream_count,
            'last_login': self.last_login.isoformat() if self.last_login else None,
            'preferences': {
                'email_notifications': self.email_notifications,
                'browser_notifications': self.browser_notifications,
                'dark_mode': self.dark_mode,
                'animations_enabled': self.animations_enabled
            }
        }

class Dream(db.Model):
    """梦境模型"""
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(100), nullable=False)
    description = db.Column(db.Text, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # 梦境属性
    mood = db.Column(db.String(50))  # 梦境情绪
    style = db.Column(db.String(50))  # 艺术风格
    blockchain = db.Column(db.String(20), default='ethereum')  # 区块链类型
    initial_price = db.Column(db.Float, default=0.1)  # 初始价格
    royalty = db.Column(db.Float, default=2.5)  # 版税
    is_public = db.Column(db.Boolean, default=True)  # 是否公开
    
    # 文件路径
    model_url = db.Column(db.String(200))  # 3D模型URL
    image_url = db.Column(db.String(200))  # 预览图URL
    
    # 元数据
    tags = db.Column(db.String(200))  # 以逗号分隔的标签
    status = db.Column(db.String(20), default='pending')  # pending, processing, completed, failed
    error_message = db.Column(db.Text)
    
    # 统计数据
    view_count = db.Column(db.Integer, default=0)
    download_count = db.Column(db.Integer, default=0)
    like_count = db.Column(db.Integer, default=0)
    
    # 外键
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)

    def to_dict(self):
        """转换为字典"""
        return {
            'id': self.id,
            'title': self.title,
            'description': self.description,
            'model_url': self.model_url,
            'image_url': self.image_url,
            'mood': self.mood,
            'style': self.style,
            'blockchain': self.blockchain,
            'initial_price': self.initial_price,
            'royalty': self.royalty,
            'is_public': self.is_public,
            'created_at': self.created_at.isoformat(),
            'updated_at': self.updated_at.isoformat(),
            'tags': self.tags.split(',') if self.tags else [],
            'status': self.status,
            'error_message': self.error_message,
            'stats': {
                'views': self.view_count,
                'downloads': self.download_count,
                'likes': self.like_count
            },
            'author': {
                'id': self.author.id,
                'username': self.author.username,
                'avatar_url': self.author.avatar_url
            }
        }

@login_manager.user_loader
def load_user(user_id):
    return User.query.get(int(user_id))

# 路由
@app.route('/')
def index():
    """首页"""
    try:
        # 获取最新的一些模型用于展示
        recent_models = Dream.query.filter_by(is_public=True).order_by(Dream.created_at.desc()).limit(6).all()
        return render_template('index_modern.html', recent_models=recent_models)
    except Exception as e:
        app.logger.error(f"首页加载错误: {str(e)}")
        return render_template('index_modern.html', recent_models=[])

@app.route('/create_dream', methods=['GET', 'POST'])
@login_required
def create_dream():
    """创造梦境页面"""
    if request.method == 'POST':
        try:
            # 获取表单数据
            dream_title = request.form.get('dream_title', '').strip()
            dream_description = request.form.get('dream_description', '').strip()
            dream_mood = request.form.get('dream_mood', '')
            dream_style = request.form.get('dream_style', '')
            blockchain = request.form.get('blockchain', '')
            initial_price = request.form.get('initial_price', type=float)
            royalty = request.form.get('royalty', type=float)
            is_public = 'is_public' in request.form
            
            # 验证必填字段
            if not dream_title or not dream_description or not blockchain:
                flash('请填写所有必填字段', 'error')
                return render_template('create_dream_modern.html')
            
            if len(dream_description) < 50:
                flash('梦境描述至少需要50个字符', 'error')
                return render_template('create_dream_modern.html')
            
            # 创建新的梦境模型
            new_model = Dream(
                title=dream_title,
                description=dream_description,
                mood=dream_mood,
                style=dream_style,
                blockchain=blockchain,
                initial_price=initial_price or 0.1,
                royalty=royalty or 2.5,
                is_public=is_public,
                user_id=current_user.id,
                status='processing'
            )
            
            db.session.add(new_model)
            db.session.commit()
            
            # 这里可以添加异步任务来生成3D模型
            # 暂时设置为已完成状态
            new_model.status = 'completed'
            new_model.model_url = f'/static/models/dream_{new_model.id}.glb'
            new_model.image_url = f'/static/images/dream_{new_model.id}.jpg'
            db.session.commit()
            
            # 更新用户梦境计数
            current_user.dream_count += 1
            db.session.commit()
            
            flash('梦境创造成功！', 'success')
            return redirect(url_for('model_detail', model_id=new_model.id))
            
        except Exception as e:
            app.logger.error(f"创造梦境错误: {str(e)}")
            flash('创造梦境时发生错误，请重试', 'error')
            return render_template('create_dream_modern.html')
    
    return render_template('create_dream_modern.html')

@app.route('/model_library')
def model_library():
    """模型库页面"""
    try:
        page = request.args.get('page', 1, type=int)
        per_page = 12
        
        # 获取筛选参数
        mood_filter = request.args.get('mood', '')
        style_filter = request.args.get('style', '')
        blockchain_filter = request.args.get('blockchain', '')
        
        # 构建查询
        query = Dream.query.filter_by(is_public=True, status='completed')
        
        if mood_filter:
            query = query.filter(Dream.mood == mood_filter)
        if style_filter:
            query = query.filter(Dream.style == style_filter)
        if blockchain_filter:
            query = query.filter(Dream.blockchain == blockchain_filter)
        
        # 分页
        models = query.order_by(Dream.created_at.desc()).paginate(
            page=page, per_page=per_page, error_out=False
        )
        
        return render_template('model_library_modern.html', models=models)
        
    except Exception as e:
        app.logger.error(f"模型库加载错误: {str(e)}")
        flash('加载模型库时发生错误', 'error')
        return render_template('model_library_modern.html', models=None)

@app.route('/model/<int:model_id>')
def model_detail(model_id):
    """模型详情页面"""
    try:
        model = Dream.query.get_or_404(model_id)
        
        # 增加浏览次数
        model.view_count += 1
        db.session.commit()
        
        # 获取相关模型
        related_models = Dream.query.filter(
            Dream.id != model_id,
            Dream.is_public == True,
            Dream.status == 'completed'
        ).order_by(Dream.created_at.desc()).limit(4).all()
        
        return render_template('model_detail_modern.html', model=model, related_models=related_models)
        
    except Exception as e:
        app.logger.error(f"模型详情加载错误: {str(e)}")
        flash('模型不存在或已被删除', 'error')
        return redirect(url_for('model_library'))

@app.route('/login', methods=['GET', 'POST'])
def login():
    """登录页面"""
    if current_user.is_authenticated:
        return redirect(url_for('index'))
    
    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')
        remember_me = 'remember_me' in request.form
        
        user = User.query.filter_by(username=username).first()
        
        if user and user.check_password(password):
            login_user(user, remember=remember_me)
            user.last_login = datetime.utcnow()
            db.session.commit()
            
            next_page = request.args.get('next')
            if not next_page or not next_page.startswith('/'):
                next_page = url_for('index')
            return redirect(next_page)
        else:
            flash('用户名或密码错误', 'error')
    
    return render_template('login_modern.html')

@app.route('/register', methods=['GET', 'POST'])
def register():
    """注册页面"""
    if current_user.is_authenticated:
        return redirect(url_for('index'))
    
    if request.method == 'POST':
        username = request.form.get('username')
        email = request.form.get('email')
        password = request.form.get('password')
        confirm_password = request.form.get('confirm_password')
        
        # 验证
        if password != confirm_password:
            flash('两次输入的密码不一致', 'error')
            return render_template('register_modern.html')
        
        if User.query.filter_by(username=username).first():
            flash('用户名已存在', 'error')
            return render_template('register_modern.html')
        
        if User.query.filter_by(email=email).first():
            flash('邮箱已被注册', 'error')
            return render_template('register_modern.html')
        
        # 创建新用户
        user = User(username=username, email=email)
        user.set_password(password)
        db.session.add(user)
        db.session.commit()
        
        flash('注册成功！请登录', 'success')
        return redirect(url_for('login'))
    
    return render_template('register_modern.html')

@app.route('/logout')
@login_required
def logout():
    """退出登录"""
    logout_user()
    flash('已成功退出登录', 'success')
    return redirect(url_for('index'))

@app.route('/about')
def about():
    """关于页面"""
    return render_template('about_modern.html')

@app.route('/api/models')
def api_models():
    """API: 获取模型列表"""
    try:
        page = request.args.get('page', 1, type=int)
        per_page = min(request.args.get('per_page', 10, type=int), 100)
        
        models = Dream.query.filter_by(is_public=True, status='completed').paginate(
            page=page, per_page=per_page, error_out=False
        )
        
        return jsonify({
            'models': [model.to_dict() for model in models.items],
            'pagination': {
                'page': models.page,
                'pages': models.pages,
                'per_page': models.per_page,
                'total': models.total,
                'has_next': models.has_next,
                'has_prev': models.has_prev
            }
        })
    except Exception as e:
        app.logger.error(f"API错误: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

@app.errorhandler(404)
def page_not_found(error):
    """404错误处理"""
    return render_template('404_modern.html'), 404

@app.errorhandler(500)
def internal_error(error):
    """500错误处理"""
    db.session.rollback()
    return render_template('500_modern.html'), 500

# 创建数据库表
with app.app_context():
    db.create_all()
    
    # 创建默认管理员用户（如果不存在）
    admin = User.query.filter_by(username='admin').first()
    if not admin:
        admin = User(username='admin', email='admin@dreamecho.com')
        admin.set_password('admin123')
        db.session.add(admin)
        db.session.commit()
        app.logger.info("创建默认管理员用户: admin/admin123")

if __name__ == '__main__':
    app.logger.info("DreamEcho 现代化应用启动")
    app.run(host='0.0.0.0', port=5002, debug=True) 