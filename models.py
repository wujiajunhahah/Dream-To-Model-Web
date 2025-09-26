from flask_login import UserMixin
from werkzeug.security import generate_password_hash, check_password_hash
from datetime import datetime
from app import db

class User(UserMixin, db.Model):
    """用户模型"""
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(64), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(128))
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
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
    model_file = db.Column(db.String(200))
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # 新增字段
    mood = db.Column(db.String(50))  # 梦境情绪
    style = db.Column(db.String(50))  # 艺术风格
    blockchain = db.Column(db.String(20), default='ethereum')  # 区块链类型
    initial_price = db.Column(db.Float, default=0.1)  # 初始价格
    royalty = db.Column(db.Float, default=2.5)  # 版税
    is_public = db.Column(db.Boolean, default=True)  # 是否公开
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
            'model_file': self.model_file,
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
                'username': self.author.username
            }
        } 