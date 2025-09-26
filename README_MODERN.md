# DreamEcho 现代化版本

一个现代化的梦境转3D模型Web应用程序，采用Flask + 现代前端设计。

## 🌟 特性

### 核心功能
- **梦境创造**: 用户可以描述自己的梦境，系统将其转化为3D模型
- **用户系统**: 完整的用户注册、登录、个人资料管理
- **模型库**: 浏览和管理所有公开的3D模型
- **区块链集成**: 支持以太坊、Polygon、Solana等多种区块链
- **NFT功能**: 将3D模型作为NFT进行交易

### 设计特色
- **现代UI**: 采用Tailwind CSS和玻璃拟态设计
- **响应式**: 完美适配桌面端和移动端
- **动画效果**: 粒子背景、平滑过渡动画
- **深色主题**: 现代深色配色方案
- **渐变元素**: 品牌色彩渐变设计

## 🚀 快速开始

### 环境要求
- Python 3.7+
- Flask
- SQLAlchemy

### 安装步骤

1. **克隆项目**
```bash
git clone <repository-url>
cd dream_to_model_web
```

2. **安装依赖**
```bash
pip install flask flask-sqlalchemy flask-login werkzeug
```

3. **运行应用**
```bash
python app_simple.py
```

4. **访问应用**
打开浏览器访问: http://localhost:5002

### 默认账户
- 用户名: `admin`
- 密码: `admin123`

## 📁 项目结构

```
dream_to_model_web/
├── app_simple.py              # 简化版Flask应用
├── templates/                 # HTML模板
│   ├── base_modern.html      # 基础模板
│   ├── index_modern.html     # 首页
│   ├── create_dream_modern.html  # 创造梦境页面
│   ├── model_library_modern.html # 模型库
│   ├── login_modern.html     # 登录页面
│   ├── register_modern.html  # 注册页面
│   ├── about_modern.html     # 关于页面
│   └── profile_modern.html   # 个人资料页面
├── simple_dreamecho.db       # SQLite数据库
└── README_MODERN.md          # 项目文档
```

## 🎨 设计系统

### 颜色方案
- **主色**: 绿色渐变 (hsl(81 70% 60%) → hsl(81 80% 70%))
- **背景**: 深绿色 (hsl(137 47% 15%))
- **文字**: 浅绿色 (hsl(81 80% 85%))
- **玻璃效果**: 半透明黑色背景 + 模糊效果

### 字体
- **主字体**: Inter (Google Fonts)
- **代码字体**: Geist Mono

### 组件
- **玻璃拟态卡片**: 半透明背景 + 边框 + 模糊效果
- **渐变按钮**: 品牌色渐变背景
- **粒子动画**: Canvas实现的动态背景

## 🔧 功能模块

### 1. 用户管理
- 用户注册/登录
- 密码加密存储
- 会话管理
- 个人资料页面

### 2. 梦境创造
- 多步骤表单
- 梦境描述输入
- 情绪和风格选择
- 区块链类型选择
- 定价设置
- 公开/私人设置

### 3. 模型库
- 分页显示
- 筛选功能
- 响应式网格布局
- 模型详情展示

### 4. 个人资料
- 用户统计信息
- 作品分类展示
- 标签页切换
- 作品管理

## 🛠️ 技术栈

### 后端
- **Flask**: Web框架
- **SQLAlchemy**: ORM数据库操作
- **Flask-Login**: 用户会话管理
- **Werkzeug**: 密码加密

### 前端
- **Tailwind CSS**: 原子化CSS框架
- **Vanilla JavaScript**: 原生JS交互
- **Canvas API**: 粒子动画效果
- **CSS3**: 现代CSS特性

### 数据库
- **SQLite**: 轻量级数据库
- **用户表**: 用户信息存储
- **梦境表**: 梦境数据存储

## 📱 响应式设计

- **桌面端**: 完整功能展示
- **平板端**: 适配中等屏幕
- **移动端**: 优化触摸操作

## 🎯 页面功能

### 首页 (/)
- 品牌展示
- 功能介绍
- 最新模型展示
- 统计数据

### 创造梦境 (/create_dream)
- 步骤式表单
- 实时验证
- AI标签生成
- 区块链选择

### 模型库 (/model_library)
- 分页浏览
- 搜索筛选
- 网格布局
- 详情展示

### 关于页面 (/about)
- 公司介绍
- 团队展示
- 技术架构
- 联系方式

### 个人资料 (/profile)
- 用户信息
- 作品统计
- 分类展示
- 作品管理

## 🔐 安全特性

- 密码哈希加密
- CSRF保护
- 用户会话管理
- 输入验证

## 🚀 部署建议

### 开发环境
```bash
python app_simple.py
```

### 生产环境
- 使用Gunicorn或uWSGI
- 配置Nginx反向代理
- 使用PostgreSQL或MySQL
- 启用HTTPS

## 📝 更新日志

### v1.0.0 (2024-12-19)
- ✨ 现代化UI设计
- ✨ 完整用户系统
- ✨ 梦境创造功能
- ✨ 模型库展示
- ✨ 个人资料页面
- ✨ 响应式设计
- ✨ 玻璃拟态效果
- ✨ 粒子动画背景

## 🤝 贡献

欢迎提交Issue和Pull Request来改进这个项目。

## 📄 许可证

MIT License

---

**DreamEcho** - 让梦境成为永恒的艺术品 ✨ 