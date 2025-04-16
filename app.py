from flask import Flask, render_template, request, send_file, jsonify, session, redirect, url_for, flash
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask_login import LoginManager, UserMixin, login_user, login_required, logout_user, current_user
from flask_mail import Mail, Message
import os
import sys
import json
import time
import requests
import subprocess
import sqlite3
from dotenv import load_dotenv
from tqdm import tqdm
import tenacity
from datetime import datetime
from werkzeug.security import generate_password_hash, check_password_hash
from pathlib import Path
from pxr import Usd, UsdGeom, UsdShade, Sdf, Gf, Vt
import logging
from logging.handlers import RotatingFileHandler
from werkzeug.utils import secure_filename
import random
import string

# 加载环境变量
load_dotenv()

# API密钥
DEEPSEEK_API_KEY = "sk-04c0e5cad3ed4ea0bbf0d2344f7f8216"
TRIPO_API_KEY = "tsk_Ep2Vvovn4vAMITNVEjFjOacWy3jfuQtwIzJWV5lsS2T"

app = Flask(__name__)
app.config.from_object('config.Config')
app.secret_key = os.getenv('SECRET_KEY', os.urandom(24))

# 初始化数据库
db = SQLAlchemy(app)
migrate = Migrate(app, db)
login_manager = LoginManager(app)
mail = Mail(app)

# --- 配置 LoginManager ---
login_manager.login_view = 'login'  # 指定登录页面的端点 (route function name)
login_manager.login_message = u"请先登录以访问此页面。"
login_manager.login_message_category = "info"  # 消息类别，用于样式化 (例如 alert-info)
# -------------------------

# 配置日志
if not os.path.exists('logs'):
    os.mkdir('logs')
file_handler = RotatingFileHandler('logs/dream_to_model.log', maxBytes=10240, backupCount=10)
file_handler.setFormatter(logging.Formatter(
    '%(asctime)s %(levelname)s: %(message)s [in %(pathname)s:%(lineno)d]'
))
file_handler.setLevel(logging.INFO)
app.logger.addHandler(file_handler)
app.logger.setLevel(logging.INFO)
app.logger.info('梦境转3D模型应用启动')

# 用户模型
class User(UserMixin, db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(128))
    is_active = db.Column(db.Boolean, default=False)
    is_admin = db.Column(db.Boolean, default=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    dreams = db.relationship('Dream', backref='user', lazy=True)

    def set_password(self, password):
        self.password_hash = generate_password_hash(password)

    def check_password(self, password):
        return check_password_hash(self.password_hash, password)

# 梦境模型
class Dream(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    
    # Form Inputs
    title = db.Column(db.String(150), nullable=False, default="Untitled Dream")
    description = db.Column(db.Text, nullable=True) # Original dream text can go here
    tags = db.Column(db.String(255), nullable=True) # Comma-separated tags
    blockchain = db.Column(db.String(50), nullable=True)
    price = db.Column(db.Float, nullable=True)
    trading_type = db.Column(db.String(50), nullable=True) # e.g., 'fixed', 'auction'
    royalty = db.Column(db.Float, nullable=True) # Royalty percentage
    preview_image = db.Column(db.String(255), nullable=True, default='default_preview.png') # Default preview

    # Generated Data
    dream_text = db.Column(db.Text, nullable=False) # Keep original text
    model_file = db.Column(db.String(255)) # Path to the model file (e.g., .glb, .obj)
    # interpretation_file = db.Column(db.String(255)) # Maybe not needed if storing text?
    keywords = db.Column(db.Text) # JSON string from DeepSeek
    symbols = db.Column(db.Text) # JSON string from DeepSeek
    emotions = db.Column(db.Text) # JSON string from DeepSeek
    visual_description = db.Column(db.Text) # From DeepSeek
    interpretation = db.Column(db.Text) # From DeepSeek
    nft_tx_hash = db.Column(db.String(128), nullable=True) # Store minting transaction hash
    status = db.Column(db.String(50), default='pending') # e.g., pending, processing, complete, minted, failed
    
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

@login_manager.user_loader
def load_user(user_id):
    return User.query.get(int(user_id))

class DreamToModelConverter:
    def __init__(self):
        self.deepseek_api_key = DEEPSEEK_API_KEY
        self.tripo_api_key = TRIPO_API_KEY

        if not self.deepseek_api_key:
            print("错误: 未设置DEEPSEEK_API_KEY环境变量")
            sys.exit(1)

        if not self.tripo_api_key:
            print("警告: 未设置TRIPO_API_KEY环境变量，将无法生成3D模型")

    def test_deepseek_api(self):
        """测试 DeepSeek API 是否可用"""
        try:
            response = requests.post(
                "https://api.deepseek.com/v1/chat/completions",
                headers={
                    "Content-Type": "application/json",
                    "Authorization": f"Bearer {self.deepseek_api_key}"
                },
                json={
                    "model": "deepseek-chat",
                    "messages": [
                        {"role": "user", "content": "你好，这是一个测试请求，请回复 '测试成功'"}
                    ],
                    "temperature": 0.3
                },
                timeout=30
            )
            return response.status_code == 200
        except Exception:
            return False

    @tenacity.retry(
        wait=tenacity.wait_fixed(10),  # 每次重试等待10秒
        stop=tenacity.stop_after_attempt(5),  # 最多重试5次
        retry=tenacity.retry_if_exception_type((requests.exceptions.Timeout, requests.exceptions.ConnectionError)),
        reraise=True
    )
    def extract_keywords(self, dream_text):
        """使用DeepSeek API从梦境文本中提取关键词、象征意义和解梦"""
        prompt = f"""
        请分析以下梦境描述，并提取以下内容:
        1. 5-8个最能代表这个梦境的关键词或短语
        2. 3-5个梦境中的核心象征物或场景
        3. 这个梦境可能传达的主要情感或感受
        4. 一个能够视觉化表达这个梦境的简短描述(50字以内)
        5. 对这个梦境的心理学解析(200字以内)

        请以JSON格式返回结果，包含字段: keywords, symbols, emotions, visual_description, interpretation

        梦境描述:
        {dream_text}
        """

        try:
            response = requests.post(
                "https://api.deepseek.com/v1/chat/completions",
                headers={
                    "Content-Type": "application/json",
                    "Authorization": f"Bearer {self.deepseek_api_key}"
                },
                json={
                    "model": "deepseek-chat",
                    "messages": [
                        {"role": "system", "content": "你是一个专业的梦境分析师，擅长提取梦境中的关键元素和象征意义。请直接返回JSON格式的结果，不要添加任何Markdown格式。"},
                        {"role": "user", "content": prompt}
                    ],
                    "temperature": 0.3
                },
                timeout=90  # 增加超时时间至90秒
            )

            if response.status_code != 200:
                raise Exception(f"DeepSeek API 调用失败，状态码: {response.status_code}")

            result = response.json()
            content = result["choices"][0]["message"]["content"]

            # 从Markdown中提取JSON
            json_content = self.extract_json_from_markdown(content)

            # 手动解析 JSON，确保兼容性
            analysis = json.loads(json_content)

            # 验证返回字段
            required_fields = ["keywords", "symbols", "emotions", "visual_description", "interpretation"]
            for field in required_fields:
                if field not in analysis:
                    raise Exception(f"DeepSeek API 返回缺少字段: {field}")

            return analysis

        except requests.exceptions.Timeout:
            raise
        except Exception as e:
            raise

    def extract_json_from_markdown(self, text):
        """从Markdown文本中提取JSON"""
        import re
        json_match = re.search(r'```(?:json)?\s*([\s\S]*?)\s*```', text)

        if json_match:
            return json_match.group(1)
        else:
            cleaned_text = text.strip()
            if cleaned_text.startswith("```") and cleaned_text.endswith("```"):
                cleaned_text = cleaned_text[3:-3].strip()
            return cleaned_text

    def generate_model_prompt(self, analysis):
        """根据分析结果生成3D模型提示词"""
        symbols = ", ".join(analysis["symbols"])
        emotions = ", ".join(analysis["emotions"])
        model_prompt = f"{analysis['visual_description']} 包含 {symbols}. 整体氛围: {emotions}"
        return model_prompt

    def generate_3d_model(self, model_prompt):
        """使用Tripo API生成3D模型"""
        try:
            # 创建任务
            response = requests.post(
                "https://api.tripo3d.ai/v2/openapi/task",
                headers={
                    "Content-Type": "application/json",
                    "Authorization": f"Bearer {self.tripo_api_key}"
                },
                json={
                    "type": "text_to_model",
                    "prompt": model_prompt
                },
                timeout=30
            )

            if response.status_code != 200:
                return None

            result = response.json()
            task_id = result.get("data", {}).get("task_id")
            if not task_id:
                return None

            # 轮询任务状态
            model_url = None
            max_attempts = 60
            for attempt in range(max_attempts):
                time.sleep(10)
                status_response = requests.get(
                    f"https://api.tripo3d.ai/v2/openapi/task/{task_id}",
                    headers={"Authorization": f"Bearer {self.tripo_api_key}"},
                    timeout=30
                )

                if status_response.status_code != 200:
                    continue

                status_data = status_response.json()
                task_status = status_data.get("data", {}).get("status")

                if task_status == "success":
                    data = status_data.get("data", {})
                    output = data.get("output", {})
                    result = data.get("result", {})

                    model_url = (
                        output.get("pbr_model") or
                        output.get("model") or
                        result.get("pbr_model", {}).get("url") or
                        result.get("model", {}).get("url")
                    )

                    if not model_url:
                        return None

                    break
                elif task_status in ["failed", "cancelled", "unknown"]:
                    return None

            if not model_url:
                return None

            # 下载模型文件
            model_response = requests.get(model_url, stream=True, timeout=30)
            filename = f"dream_model_{int(time.time())}.glb"
            with open(filename, "wb") as f:
                for chunk in model_response.iter_content(chunk_size=1024):
                    if chunk:
                        f.write(chunk)

            return filename

        except Exception:
            return None

    def process_dream(self, dream_text, user_id):
        """处理梦境并生成3D模型"""
        try:
            app.logger.info(f'开始处理用户 {user_id} 的梦境')
            
            # 测试 DeepSeek API 可用性
            if not self.test_deepseek_api():
                app.logger.error('DeepSeek API 不可用')
                raise Exception("DeepSeek API 服务暂时不可用，请稍后再试")

            # 提取关键词和分析
            app.logger.info('开始提取关键词和分析')
            analysis = self.extract_keywords(dream_text)
            
            # 生成3D模型
            app.logger.info('开始生成3D模型')
            model_prompt = self.generate_model_prompt(analysis)
            model_url = self.generate_3d_model(model_prompt)
            
            if not model_url:
                app.logger.error('3D模型生成失败')
                raise Exception("3D模型生成失败，请稍后重试")

            # 创建用户目录
            user_dir = os.path.join('static', 'models', f'user_{user_id}')
            os.makedirs(user_dir, exist_ok=True)
            
            # 下载模型文件
            app.logger.info('下载模型文件')
            model_filename = f"dream_{int(time.time())}.glb"  # 使用GLB格式
            model_path = os.path.join(user_dir, model_filename)
            
            response = requests.get(model_url, stream=True)
            if response.status_code != 200:
                raise Exception("下载模型文件失败")
            
            total_size = int(response.headers.get('content-length', 0))
            block_size = 1024
            
            with open(model_path, 'wb') as f, tqdm(
                desc="下载模型",
                total=total_size,
                unit='iB',
                unit_scale=True,
                unit_divisor=1024,
            ) as pbar:
                for data in response.iter_content(block_size):
                    size = f.write(data)
                    pbar.update(size)

            # 保存到数据库
            app.logger.info('保存梦境记录到数据库')
            dream = Dream(
                user_id=user_id,
                dream_text=dream_text,
                model_file=os.path.join('models', f'user_{user_id}', model_filename),
                keywords=json.dumps(analysis['keywords']),
                symbols=json.dumps(analysis['symbols']),
                emotions=json.dumps(analysis['emotions']),
                visual_description=analysis['visual_description'],
                interpretation=analysis['interpretation']
            )
            db.session.add(dream)
            db.session.commit()
            
            app.logger.info(f'梦境处理完成，ID: {dream.id}')
            return dream
            
        except Exception as e:
            app.logger.error(f'处理梦境时发生错误: {str(e)}')
            db.session.rollback()
            raise

def convert_usdz_to_glb(usdz_path):
    """
    将USDZ文件转换为GLB格式
    使用USD库进行转换
    """
    try:
        # 确保输入文件存在
        if not os.path.exists(usdz_path):
            print(f"错误：找不到USDZ文件 {usdz_path}")
            return None
            
        # 创建输出文件路径
        glb_path = usdz_path.replace('.usdz', '.glb')
        
        # 如果GLB文件已存在，直接返回
        if os.path.exists(glb_path):
            return glb_path
            
        # 打开USDZ文件
        stage = Usd.Stage.Open(usdz_path)
        
        # 导出为GLB
        stage.Export(glb_path)
        
        if os.path.exists(glb_path):
            print(f"成功将 {usdz_path} 转换为 {glb_path}")
            return glb_path
        else:
            print("转换失败：无法创建GLB文件")
            return None
            
    except Exception as e:
        print(f"转换过程中出错：{str(e)}")
        return None

# 路由：首页
@app.route('/')
def index():
    """首页路由"""
    return render_template('index.html')

# 路由：梦境铸造
@app.route('/dream-casting', methods=['GET', 'POST'])
def dream_casting():
    if 'user_id' not in session:
        return redirect(url_for('login'))
    
    if request.method == 'POST':
        dream_text = request.form.get('dream_text')
        converter = DreamToModelConverter()
        result = converter.process_dream(dream_text, session['user_id'])
        if result:
            model_file, interpretation_file = result
            return jsonify({
                'success': True,
                'model_file': model_file,
                'interpretation_file': interpretation_file
            })
        return jsonify({'success': False, 'error': '生成模型失败，请重试。'})
    
    return render_template('dream_casting.html')

# 路由：模型库
@app.route('/model-gallery')
@login_required
def model_gallery():
    models_dir = os.path.join('static', 'models')
    models = []
    
    print(f"正在访问模型目录: {models_dir}")
    
    if not os.path.exists(models_dir):
        print(f"错误：模型目录不存在 {models_dir}")
        os.makedirs(models_dir)
        return render_template('model_gallery.html', models=[])
    
    try:
        files = os.listdir(models_dir)
        print(f"找到的文件: {files}")
        
        for file in files:
            base_name = os.path.splitext(file)[0]
            ext = os.path.splitext(file)[1].lower()
            
            print(f"处理文件: {file}, 扩展名: {ext}")
            
            # 检查是否已经添加了相同基础名称的文件
            if not any(os.path.splitext(m)[0] == base_name for m in models):
                if ext in ['.usdz', '.glb', '.gltf']:
                    print(f"添加{ext}文件: {file}")
                    models.append(file)
        
        # 按文件名排序
        models.sort()
        print(f"最终模型列表: {models}")
        return render_template('model_gallery.html', models=models)
        
    except Exception as e:
        print(f"处理模型目录时出错: {str(e)}")
        return render_template('model_gallery.html', models=[])

# 路由：用户注册
@app.route('/register', methods=['GET', 'POST'])
def register():
    if current_user.is_authenticated:
        return redirect(url_for('index'))
    
    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')
        email = request.form.get('email')
        
        if User.query.filter_by(username=username).first():
            flash('用户名已存在', 'error')
            return redirect(url_for('register'))
        
        if User.query.filter_by(email=email).first():
            flash('邮箱已被注册', 'error')
            return redirect(url_for('register'))
        
        user = User(
            username=username,
            email=email,
            is_active=True
        )
        user.set_password(password)
        db.session.add(user)
        db.session.commit()
        
        flash('注册成功！请登录', 'success')
        return redirect(url_for('login'))
    
    return render_template('register.html')

# 路由：用户登录
@app.route('/login', methods=['GET', 'POST'])
def login():
    if current_user.is_authenticated:
        return redirect(url_for('index'))
        
    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')
        remember = request.form.get('remember') == 'on'
        
        user = User.query.filter_by(username=username).first()
        if user and user.check_password(password):
            login_user(user, remember=remember)
            flash('登录成功！', 'success')
            return redirect(url_for('index'))
        
        flash('用户名或密码错误', 'error')
    
    return render_template('login.html')

# 路由：用户登出
@app.route('/logout')
@login_required
def logout():
    logout_user()
    flash('已退出登录', 'success')
    return redirect(url_for('index'))

# 路由：下载模型
@app.route('/download/<path:filename>')
def download(filename):
    return send_file(filename, as_attachment=True)

@app.cli.command("create-admin")
def create_admin():
    """创建管理员账号"""
    admin = User(
        username='123',
        email='123@example.com',
        is_active=True,
        is_admin=True
    )
    admin.set_password('123')
    db.session.add(admin)
    db.session.commit()
    print('测试账号创建成功！用户名和密码都是：123')

@app.route('/create_dream', methods=['GET'])
@login_required
def create_dream_page():
    """创建梦境页面"""
    return render_template('create_dream.html')

@app.route('/api/create_dream', methods=['POST'])
@login_required
def create_dream_api():
    """创建新的梦境记录 API"""
    try:
        # 从表单获取数据
        title = request.form.get('title', 'Untitled Dream')
        description = request.form.get('description') # Use description as the dream text for analysis
        tags = request.form.get('tags')
        blockchain = request.form.get('blockchain')
        price_str = request.form.get('price')
        trading_type = request.form.get('tradingType')
        royalty_str = request.form.get('royalty')

        if not description:
            return jsonify({'success': False, 'error': '梦境描述不能为空'}), 400
        
        # 数据类型转换和验证
        price = None
        if price_str:
            try:
                price = float(price_str)
            except ValueError:
                return jsonify({'success': False, 'error': '价格必须是数字'}), 400
        
        royalty = None
        if royalty_str:
            try:
                royalty = float(royalty_str)
            except ValueError:
                return jsonify({'success': False, 'error': '版税必须是数字'}), 400

        # 初始化转换器
        converter = DreamToModelConverter()
        
        # --- 调用处理流程 --- 
        # 注意: converter.process_dream 现在处理文本分析、模型生成和初步数据库保存
        # 我们需要修改它或在这里进行更新
        app.logger.info(f"开始为用户 {current_user.id} 处理梦境: {title}")
        dream_record = converter.process_dream(dream_text=description, user_id=current_user.id)
        # ---------------------

        if dream_record:
            # 更新数据库记录，添加表单中的其他信息
            dream_record.title = title
            dream_record.tags = tags
            dream_record.blockchain = blockchain
            dream_record.price = price
            dream_record.trading_type = trading_type
            dream_record.royalty = royalty
            dream_record.description = description # Store original description if needed differently from dream_text
            dream_record.status = 'complete' # Mark as complete after generation
            dream_record.preview_image = 'default_preview.png' # Set default preview
            
            db.session.commit()
            app.logger.info(f"梦境记录 {dream_record.id} 更新成功")

            return jsonify({
                'success': True,
                'dream_id': dream_record.id,
                'message': '梦境创建成功！模型正在后台处理。'
                # 不直接返回模型路径，让用户在交易所查看
            })
        else:
            # 如果 converter.process_dream 返回 None 或出错
            app.logger.error(f"用户 {current_user.id} 的梦境处理失败")
            return jsonify({'success': False, 'error': '梦境处理或模型生成失败，请稍后重试'}), 500
            
    except Exception as e:
        db.session.rollback() # Ensure rollback on any exception
        app.logger.error(f"创建梦境 API 出错: {str(e)}", exc_info=True)
        return jsonify({'success': False, 'error': f'服务器内部错误: {str(e)}'}), 500

@app.route('/profile')
@login_required
def profile():
    """个人中心页面"""
    return render_template('profile.html')

@app.route('/settings')
@login_required
def settings():
    """设置页面"""
    return render_template('settings.html')

@app.route('/contact')
def contact():
    return render_template('contact.html')

@app.route('/faq')
def faq():
    return render_template('faq.html')

@app.route('/privacy')
def privacy():
    return render_template('privacy.html')

@app.route('/api/interpretation/<model_name>')
@login_required
def get_interpretation(model_name):
    # 从模型文件名中提取梦境ID
    dream_id = model_name.split('.')[0]
    
    # 获取梦境数据
    dream = Dream.query.filter_by(id=dream_id).first()
    if not dream:
        return jsonify({'error': '梦境不存在'}), 404
    
    # 检查权限
    if dream.user_id != current_user.id:
        return jsonify({'error': '没有权限访问'}), 403
    
    # 返回解析数据
    return jsonify({
        'keywords': dream.keywords.split(','),
        'symbols': dream.symbols.split(','),
        'emotions': dream.emotions.split(','),
        'visuals': dream.visual_description,
        'psychology': dream.interpretation
    })

# 错误处理
@app.errorhandler(404)
def page_not_found(e):
    return render_template('404.html'), 404

@app.errorhandler(500)
def internal_error(error):
    db.session.rollback()
    app.logger.error(f'服务器错误: {error}')
    return render_template('500.html'), 500

@app.errorhandler(413)
def too_large(error):
    app.logger.error(f'文件过大: {request.url}')
    return render_template('413.html'), 413

@app.route('/model_library')
def model_library():
    # 示例模型数据
    models = [
        {
            'id': 1,
            'title': '梦境巴士',
            'tags': ['交通工具', '城市', '公共空间'],
            'description': '这是一个充满未来感的巴士模型，展现了城市交通的现代化愿景。模型细节丰富，完美呈现了未来城市交通工具的设计理念。',
            'price': 0.5,
            'model_path': '/static/models/大巴.glb'
        },
        {
            'id': 2,
            'title': 'Kanye',
            'tags': ['人物', '艺术', '音乐'],
            'description': '这个模型展现了说唱歌手Kanye West的独特形象，捕捉了他标志性的表情和姿态。模型通过精细的细节刻画，完美展现了艺术家的个性特征。',
            'price': 0.8,
            'model_path': '/static/models/kanye.glb'
        },
        {
            'id': 3,
            'title': '未命名扫描',
            'tags': ['扫描', '实验', '艺术'],
            'description': '这是一个通过3D扫描技术创建的实验性艺术作品。模型展现了扫描过程中捕捉到的独特纹理和形态，呈现出一种介于现实与虚拟之间的视觉效果。',
            'price': 0.3,
            'model_path': '/static/models/Untitled_Scan.glb'
        }
    ]
    return render_template('model_library.html', models=models)

@app.route('/model/<model_id>')
def model_detail(model_id):
    """模型详情页面 - 从数据库获取数据"""
    try:
        # 根据 ID 从数据库查询梦境记录
        # 使用 .first_or_404() 会在找不到记录时自动返回 404 错误
        dream = Dream.query.filter_by(id=model_id).first_or_404()
        
        # 准备传递给模板的数据
        model_data = {
            'id': dream.id,
            'title': dream.title,
            'description': dream.description or dream.dream_text, # 显示原始描述或梦境文本
            'price': f"{dream.price:.2f} ETH" if dream.price is not None else "价格未定", # 添加货币单位
            'created_at': dream.created_at.strftime('%Y/%m/%d'), # 格式化日期
            'tags': [tag.strip() for tag in dream.tags.split(',')] if dream.tags else [],
            'model_file': dream.model_file.split(os.path.sep)[-1] if dream.model_file else 'default_model.obj', # 只取文件名
             # 可以添加其他需要展示的字段，例如 blockchain, status 等
            'blockchain': dream.blockchain,
            'status': dream.status,
            'nft_tx_hash': dream.nft_tx_hash,
            # 确保 creator 信息也传递（如果需要）
             'creator_name': dream.user.username, # 假设关联的 user 对象可用
             'creator_avatar': url_for('static', filename='images/avatar.jpg') # 暂时用通用头像
        }
        
        # 渲染 model_detail.html
        return render_template('model_detail.html', model=model_data)
        
    except Exception as e:
        app.logger.error(f"获取模型详情页时出错 (ID: {model_id}): {str(e)}", exc_info=True)
        return render_template('404.html'), 404 # 或者渲染 500 错误页

@app.route('/api/mint_nft/<model_id>', methods=['POST'])
#@login_required # 如果需要登录才能铸造，取消注释这行
def mint_nft_api(model_id):
    """模拟 NFT 铸造 API"""
    try:
        # 1. 验证模型是否存在 (如果从数据库获取)
        # model = Dream.query.get(model_id)
        # if not model:
        #     return jsonify({'success': False, 'error': '模型不存在'}), 404
        # if model.user_id != current_user.id: # 验证所有权
        #     return jsonify({'success': False, 'error': '无权操作'}), 403
        # if model.nft_tx_hash: # 检查是否已铸造
        #     return jsonify({'success': False, 'error': '该模型已被铸造'}), 400
        
        app.logger.info(f"开始模拟为模型 ID {model_id} 铸造 NFT")
        
        # 2. 模拟区块链交互延迟
        time.sleep(random.uniform(3, 8)) # 模拟 3-8 秒的处理时间
        
        # 3. 模拟成功/失败 (例如，80% 成功率)
        if random.random() < 0.8:
            # 模拟生成交易哈希
            fake_tx_hash = '0x' + ''.join(random.choices(string.ascii_lowercase + string.digits, k=64))
            app.logger.info(f"模型 ID {model_id} NFT 铸造模拟成功，交易哈希: {fake_tx_hash}")
            
            # 4. 更新数据库状态 (如果从数据库获取)
            # model.nft_tx_hash = fake_tx_hash
            # model.status = 'minted'
            # db.session.commit()
            
            return jsonify({'success': True, 'tx_hash': fake_tx_hash})
        else:
            app.logger.error(f"模型 ID {model_id} NFT 铸造模拟失败")
            error_message = random.choice(["网络拥堵，请稍后重试", "Gas 费不足", "合约调用失败"])
            return jsonify({'success': False, 'error': error_message}), 500

    except Exception as e:
        app.logger.error(f"铸造 NFT 时发生意外错误 (模型 ID: {model_id}): {str(e)}")
        return jsonify({'success': False, 'error': '服务器内部错误，请联系管理员'}), 500

@app.route('/project_background')
def project_background():
    """项目背景页面"""
    return render_template('project_background.html')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001, debug=True)
