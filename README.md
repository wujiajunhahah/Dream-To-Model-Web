# DreamEcho - 梦境转3D模型平台

![DreamEcho Logo](/static/images/dreamecho_logo.png)

DreamEcho是一个创新的AI驱动平台，致力于将人们的梦境创意转化为精美的3D模型，并支持NFT交易。

## ✨ 特色功能

- 🎨 梦境转3D模型：通过AI技术将文字描述转换为精确的3D模型
- 💎 NFT交易市场：支持模型NFT化并在多链上交易
- 🌈 沉浸式体验：独特的粒子动画背景和现代化UI设计
- 📱 响应式设计：完美支持各种设备的显示

## 🛠 技术栈

- 前端：HTML5, CSS3, JavaScript (Particles.js, Three.js)
- 后端：Python Flask
- 数据库：SQLite
- AI集成：Deep Seek API, TripoAPI
- 区块链：支持Ethereum, Polygon, BSC

## 🚀 快速开始

1. 克隆仓库
```bash
git clone https://github.com/wujiajunhahah/Dream-To-Model-Web.git
cd Dream-To-Model-Web
```

2. 安装依赖
```bash
pip install -r requirements.txt
```

3. 启动应用
```bash
python app.py
```

4. 访问网站
```
http://localhost:5001
```

## 📦 项目结构

```
Dream-To-Model-Web/
├── app.py              # Flask应用主文件
├── models.py           # 数据模型定义
├── requirements.txt    # 项目依赖
├── static/            
│   ├── css/           # 样式文件
│   ├── js/            # JavaScript文件
│   ├── images/        # 图片资源
│   └── models/        # 3D模型文件
├── templates/          # HTML模板
└── docs/              # 项目文档
```

## 🔑 环境变量配置

创建`.env`文件并配置以下环境变量：
```
FLASK_SECRET_KEY=your_secret_key
DEEP_SEEK_API_KEY=your_deep_seek_api_key
TRIPO_API_KEY=your_tripo_api_key
```

## 📄 API文档

详细的API文档请参考 `docs/technical_docs.md`

## 🤝 贡献指南

1. Fork 项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启Pull Request

## 📝 开源协议

本项目采用 MIT 协议 - 详情请参见 [LICENSE](LICENSE) 文件

## 👥 联系我们

- 技术支持：support@dreamecho.ai
- GitHub：[https://github.com/wujiajunhahah](https://github.com/wujiajunhahah) 