# DreamEcho 技术文档

## 项目概述
DreamEcho是一个基于AI技术的梦境转3D模型平台，允许用户将梦境转化为可交易的NFT艺术品。

## 技术栈
- 前端：HTML5, CSS3, JavaScript (ES6+)
- 后端：Python Flask
- 数据库：SQLite
- AI API：Deep Seek API, TripoAPI
- 区块链：Ethereum, Polygon
- 3D渲染：Three.js, model-viewer

## API集成
### Deep Seek API
- 用途：梦境文本分析和场景理解
- 版本：v1.0
- 接入方式：REST API
- 密钥管理：环境变量

### TripoAPI
- 用途：3D模型生成
- 版本：v2.0
- 接入方式：WebSocket
- 支持格式：GLB, USDZ

## 数据库架构
### 用户表 (users)
```sql
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username VARCHAR(64) UNIQUE NOT NULL,
    email VARCHAR(120) UNIQUE NOT NULL,
    password_hash VARCHAR(128),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

### 梦境表 (dreams)
```sql
CREATE TABLE dreams (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    model_file VARCHAR(200),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    user_id INTEGER REFERENCES users(id),
    status VARCHAR(20) DEFAULT 'pending',
    price DECIMAL(10,2),
    blockchain_address VARCHAR(42)
);
```

## NFT集成
### 支持的区块链网络
- Ethereum Mainnet
- Polygon
- Binance Smart Chain

### 智能合约
- ERC-721标准
- 支持版税功能
- 包含元数据存储

## 安全措施
1. 密码加密：使用bcrypt
2. API密钥保护：环境变量
3. SQL注入防护：参数化查询
4. XSS防护：内容转义
5. CSRF保护：令牌验证

## 部署架构
- Web服务器：Nginx
- 应用服务器：Gunicorn
- 缓存：Redis
- 文件存储：AWS S3

## 性能优化
1. 静态资源CDN
2. 图片懒加载
3. 3D模型压缩
4. 数据库索引优化
5. API响应缓存

## 监控与日志
- 应用日志：/logs/app.log
- 错误追踪：Sentry
- 性能监控：New Relic
- 用户行为分析：Google Analytics

## 更新日志
### v1.0.0 (2024-04-02)
- 初始版本发布
- 基础功能实现

### v1.1.0 (计划中)
- 多链支持
- 批量铸造
- 社交功能
- 交易历史
- 实时通知

## 维护计划
1. 每周代码审查
2. 每月安全更新
3. 季度功能迭代
4. 年度架构评估

## 贡献指南
1. Fork项目
2. 创建特性分支
3. 提交变更
4. 发起Pull Request

## 联系方式
- 技术支持：epwujiajun@icloud.com
- GitHub：https://github.com/wujiajunhahah 