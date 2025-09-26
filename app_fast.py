#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from flask import Flask, render_template_string
import os

# 创建Flask应用
app = Flask(__name__)
app.config['SECRET_KEY'] = 'fast-dreamecho'

# 极简HTML模板
FAST_TEMPLATE = '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>DreamEcho - Fast Version</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { 
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: linear-gradient(135deg, #0f1419 0%, #1a2332 100%);
            color: white;
            line-height: 1.6;
        }
        .container { max-width: 1200px; margin: 0 auto; padding: 20px; }
        .nav { 
            display: flex; 
            justify-content: space-between; 
            align-items: center; 
            padding: 20px 0; 
            border-bottom: 1px solid rgba(255,255,255,0.1);
        }
        .logo { font-size: 24px; font-weight: bold; color: #4ade80; }
        .nav-links { display: flex; gap: 30px; }
        .nav-links a { color: #ccc; text-decoration: none; transition: color 0.3s; }
        .nav-links a:hover { color: #4ade80; }
        .hero { text-align: center; padding: 80px 0; }
        .hero h1 { 
            font-size: 4rem; 
            margin-bottom: 20px; 
            background: linear-gradient(135deg, #4ade80, #22c55e);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }
        .hero p { font-size: 1.2rem; color: #ccc; margin-bottom: 40px; max-width: 600px; margin-left: auto; margin-right: auto; }
        .btn { 
            display: inline-block;
            padding: 15px 30px;
            background: linear-gradient(135deg, #4ade80, #22c55e);
            color: white;
            text-decoration: none;
            border-radius: 50px;
            font-weight: 600;
            transition: transform 0.3s, box-shadow 0.3s;
        }
        .btn:hover { 
            transform: translateY(-2px);
            box-shadow: 0 10px 25px rgba(74, 222, 128, 0.3);
        }
        .image-section { 
            margin: 60px 0;
            background: rgba(255,255,255,0.05);
            border-radius: 20px;
            padding: 40px;
            backdrop-filter: blur(10px);
        }
        .main-image { 
            width: 100%; 
            max-width: 800px; 
            height: auto; 
            border-radius: 15px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.3);
        }
        .tech-support { text-align: center; margin: 60px 0; }
        .tech-links { display: flex; justify-content: center; gap: 40px; margin-top: 20px; }
        .tech-links a { 
            color: #4ade80; 
            text-decoration: none; 
            font-size: 1.1rem; 
            font-weight: 600;
            transition: color 0.3s;
        }
        .tech-links a:hover { color: #22c55e; }
        .features { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 30px; margin: 60px 0; }
        .feature { 
            background: rgba(255,255,255,0.05);
            padding: 30px;
            border-radius: 15px;
            text-align: center;
            backdrop-filter: blur(10px);
        }
        .feature h3 { color: #4ade80; margin-bottom: 15px; }
        .contact { 
            background: rgba(255,255,255,0.05);
            padding: 40px;
            border-radius: 20px;
            margin: 60px 0;
            backdrop-filter: blur(10px);
        }
        .contact-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 40px; align-items: center; }
        .contact img { width: 100px; height: 100px; border-radius: 50%; object-fit: cover; }
        .qr-code { width: 120px; height: 120px; border-radius: 10px; }
        @media (max-width: 768px) {
            .hero h1 { font-size: 2.5rem; }
            .nav-links { display: none; }
            .tech-links { flex-direction: column; gap: 20px; }
            .contact-grid { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>
    <div class="container">
        <!-- 导航栏 -->
        <nav class="nav">
            <div class="logo">🌟 DreamEcho</div>
            <div class="nav-links">
                <a href="#features">Features</a>
                <a href="#about">About</a>
                <a href="#contact">Contact</a>
            </div>
        </nav>

        <!-- 主要内容 -->
        <section class="hero">
            <h1>Transform Dreams into 3D Art</h1>
            <p>使用先进的AI技术，将您的梦境转化为独特的3D艺术作品。每个梦境都将成为独一无二的数字艺术品。</p>
            <a href="#contact" class="btn">开始创作 Start Creating</a>
        </section>

        <!-- 主图片展示 -->
        <section class="image-section" style="text-align: center;">
            <img src="/static/images/已移除背景的网站图拍呢.png" alt="DreamEcho Showcase" class="main-image">
        </section>

        <!-- 技术支持 -->
        <section class="tech-support">
            <p style="color: #ccc; margin-bottom: 10px;">Powered by cutting-edge AI and 3D printing technologies</p>
            <div class="tech-links">
                <a href="https://bambulab.com" target="_blank">🖨️ Bambu Lab</a>
                <a href="https://deepseek.com" target="_blank">🤖 DeepSeek</a>
                <a href="https://tripo3d.ai" target="_blank">🎨 Tripo</a>
            </div>
        </section>

        <!-- 特色功能 -->
        <section id="features" class="features">
            <div class="feature">
                <h3>🚀 Advanced AI Technology</h3>
                <p>使用DeepSeek AI进行高级梦境解释，精确理解您的梦境描述</p>
            </div>
            <div class="feature">
                <h3>🎯 High-Quality 3D Models</h3>
                <p>使用Tripo3D生成专业级别的3D模型，质量卓越</p>
            </div>
            <div class="feature">
                <h3>🖨️ 3D Printing Ready</h3>
                <p>兼容Bambu Lab打印机，可直接进行物理创作</p>
            </div>
        </section>

        <!-- 关于和联系 -->
        <section id="about" class="contact">
            <h2 style="text-align: center; margin-bottom: 30px; color: #4ade80;">About & Contact</h2>
            <div class="contact-grid">
                <div>
                    <h3 style="color: #4ade80; margin-bottom: 15px;">Our Mission</h3>
                    <p style="margin-bottom: 20px;">
                        在DreamEcho，我们相信每个梦境都值得被实现。我们的使命是通过先进的AI技术，
                        让3D艺术创作变得人人可及，将抽象的思想和梦境转化为有形的3D艺术品。
                    </p>
                    <div style="display: flex; align-items: center; gap: 15px; margin-bottom: 20px;">
                        <img src="/static/images/avatar.jpg" alt="Wu Jiajun" style="width: 60px; height: 60px; border-radius: 50%; object-fit: cover;">
                        <div>
                            <h4 style="color: #4ade80;">Wu Jiajun</h4>
                            <p style="color: #ccc; font-size: 0.9rem;">Founder & Lead Developer</p>
                            <a href="https://github.com/wujiajunhahah" target="_blank" style="color: #4ade80; text-decoration: none;">
                                📱 @wujiajunhahah
                            </a>
                        </div>
                    </div>
                </div>
                <div id="contact" style="text-align: center;">
                    <h3 style="color: #4ade80; margin-bottom: 15px;">Connect with Us</h3>
                    <p style="margin-bottom: 20px;">📧 contact@dreamecho.ai</p>
                    <p style="margin-bottom: 15px;">💬 WeChat QR Code:</p>
                    <img src="/static/images/default-qr.png" alt="WeChat QR" class="qr-code">
                    <p style="margin-top: 10px; font-size: 0.9rem; color: #ccc;">扫码添加微信直接沟通</p>
                </div>
            </div>
        </section>

        <!-- 页脚 -->
        <footer style="text-align: center; padding: 40px 0; border-top: 1px solid rgba(255,255,255,0.1); margin-top: 60px;">
            <p style="color: #ccc;">&copy; 2024 DreamEcho. All rights reserved. 🌟</p>
        </footer>
    </div>

    <script>
        // 平滑滚动
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', function (e) {
                e.preventDefault();
                const target = document.querySelector(this.getAttribute('href'));
                if (target) {
                    target.scrollIntoView({ behavior: 'smooth', block: 'start' });
                }
            });
        });

        // 简单的加载动画
        window.addEventListener('load', function() {
            document.body.style.opacity = '0';
            document.body.style.transition = 'opacity 0.5s';
            setTimeout(() => { document.body.style.opacity = '1'; }, 100);
        });
    </script>
</body>
</html>
'''

@app.route('/')
def index():
    return render_template_string(FAST_TEMPLATE)

@app.route('/health')
def health():
    return {'status': 'ok', 'version': 'fast'}

if __name__ == '__main__':
    print("🚀 DreamEcho Fast Version starting...")
    print("📱 Opening in browser: http://localhost:5005")
    app.run(host='0.0.0.0', port=5005, debug=False, threaded=True) 