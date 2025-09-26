# DreamEcho 设计规范文档

## 1. 品牌标识

### 1.1 Logo
- 主标志：梦境回声（DreamEcho）
- 字体：Montserrat Bold
- 颜色：#8A2BE2（主色）
- 尺寸：
  - 网站头部：180px × 60px
  - 移动端：120px × 40px
  - 最小使用尺寸：80px × 26px

### 1.2 品牌色系
- 主色：
  - 紫色：#8A2BE2（用于重点强调和主要按钮）
  - 深蓝：#1A1B2F（背景色）
- 辅助色：
  - 亮紫：#B76EFF（悬浮状态）
  - 天蓝：#64FFDA（强调文字）
  - 粉紫：#FF6B9D（装饰元素）
- 中性色：
  - 白色：#FFFFFF（主要文字）
  - 浅灰：#B8B8B8（次要文字）
  - 深灰：#2A2A2A（背景层次）

## 2. 排版系统

### 2.1 字体
- 中文主字体：思源黑体
- 英文主字体：Montserrat
- 代码字体：JetBrains Mono

### 2.2 字号规范
- 页面标题：42px/60px（思源黑体 Bold）
- 主标题：32px/48px（思源黑体 Bold）
- 次标题：24px/36px（思源黑体 Medium）
- 正文大：18px/28px（思源黑体 Regular）
- 正文小：16px/24px（思源黑体 Regular）
- 辅助文字：14px/20px（思源黑体 Regular）
- 注释文字：12px/18px（思源黑体 Regular）

### 2.3 段落间距
- 标题段落间距：32px
- 正文段落间距：24px
- 列表项间距：16px

## 3. 布局系统

### 3.1 网格系统
- 桌面端：12列栅格
  - 最大宽度：1440px
  - 列间距：24px
  - 边距：80px
- 平板端：8列栅格
  - 最大宽度：768px
  - 列间距：16px
  - 边距：40px
- 移动端：4列栅格
  - 最大宽度：375px
  - 列间距：16px
  - 边距：20px

### 3.2 间距规范
- 组件内间距：
  - 大：32px
  - 中：24px
  - 小：16px
  - 极小：8px
- 组件间距：
  - 大：64px
  - 中：48px
  - 小：32px

## 4. 组件设计

### 4.1 按钮
- 主要按钮
  ```css
  {
    height: 48px;
    padding: 0 32px;
    border-radius: 24px;
    background: linear-gradient(45deg, #8A2BE2, #B76EFF);
    font-size: 16px;
    font-weight: 500;
    color: #FFFFFF;
    transition: all 0.3s ease;
  }
  ```
- 次要按钮
  ```css
  {
    height: 48px;
    padding: 0 32px;
    border-radius: 24px;
    border: 2px solid #8A2BE2;
    background: transparent;
    font-size: 16px;
    font-weight: 500;
    color: #8A2BE2;
    transition: all 0.3s ease;
  }
  ```

### 4.2 输入框
```css
{
  height: 48px;
  padding: 0 16px;
  border-radius: 12px;
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
  font-size: 16px;
  color: #FFFFFF;
}
```

### 4.3 卡片
```css
{
  background: rgba(26, 27, 47, 0.8);
  border-radius: 16px;
  backdrop-filter: blur(20px);
  padding: 24px;
  border: 1px solid rgba(255, 255, 255, 0.1);
}
```

## 5. 页面设计

### 5.1 首页
- 顶部导航
  - 高度：80px
  - 背景：rgba(26, 27, 47, 0.8)
  - 模糊效果：backdrop-filter: blur(20px)
  
- Hero区域
  - 高度：100vh
  - 背景：动态粒子效果
  - 标题：64px/80px
  - 副标题：24px/36px
  
- 功能特点区
  - 三列布局
  - 卡片尺寸：360px × 480px
  - 图标尺寸：64px × 64px
  
- 项目愿景区
  - 背景：渐变色 #1A1B2F → #2A1B47
  - 内容宽度：最大800px
  - 动画：滚动触发渐入效果

### 5.2 梦境交易所
- 筛选栏
  - 高度：60px
  - 背景：rgba(26, 27, 47, 0.9)
  
- 模型卡片
  - 尺寸：300px × 400px
  - 图片区：300px × 300px
  - 信息区：高度100px
  - 悬浮效果：上移8px，阴影加深

### 5.3 创建梦境
- 表单布局
  - 最大宽度：800px
  - 居中布局
  - 间距：32px
  
- 3D预览区
  - 尺寸：100% × 500px
  - 背景：#1A1B2F
  - 控制按钮：半透明悬浮

## 6. 交互动效

### 6.1 过渡动画
```css
{
  transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
  transition-duration: 300ms;
}
```

### 6.2 hover效果
- 按钮：
  - 缩放：transform: scale(1.05)
  - 发光：box-shadow: 0 0 20px rgba(138, 43, 226, 0.4)
  
- 卡片：
  - 上移：transform: translateY(-8px)
  - 阴影：box-shadow: 0 20px 40px rgba(0, 0, 0, 0.2)

### 6.3 页面切换
- 淡入：opacity: 0 → 1
- 上移：transform: translateY(20px) → translateY(0)
- 持续时间：500ms

## 7. 响应式设计

### 7.1 断点设置
```css
// 移动端
@media (max-width: 767px) {
  // 样式调整
}

// 平板端
@media (min-width: 768px) and (max-width: 1023px) {
  // 样式调整
}

// 桌面端
@media (min-width: 1024px) {
  // 样式调整
}
```

### 7.2 图片适配
- 使用srcset属性适配不同分辨率
- 移动端图片压缩至原图30%大小
- 使用webp格式作为主要图片格式

### 7.3 字体响应式
```css
// 移动端
html {
  font-size: 14px;
}

// 平板端
@media (min-width: 768px) {
  html {
    font-size: 15px;
  }
}

// 桌面端
@media (min-width: 1024px) {
  html {
    font-size: 16px;
  }
}
```

## 8. 加载状态

### 8.1 全局加载
- 背景：rgba(26, 27, 47, 0.9)
- Logo动画：呼吸效果
- 加载文字：渐变色动画

### 8.2 局部加载
- Spinner样式：
  ```css
  {
    width: 24px;
    height: 24px;
    border: 2px solid rgba(138, 43, 226, 0.1);
    border-top-color: #8A2BE2;
    border-radius: 50%;
    animation: spin 1s linear infinite;
  }
  ```

## 9. 错误状态

### 9.1 表单验证
- 错误文字：#FF4B4B
- 输入框边框：#FF4B4B
- 错误图标：16px × 16px

### 9.2 404页面
- 背景：动态星空效果
- 主标题：128px/160px
- 说明文字：24px/36px
- 返回按钮：主要按钮样式

## 10. 辅助功能

### 10.1 无障碍设计
- 所有交互元素焦点状态清晰可见
- 颜色对比度符合WCAG 2.1标准
- 提供键盘导航支持

### 10.2 性能优化
- 图片懒加载
- 组件按需加载
- 资源预加载策略

## 11. 设计资源

### 11.1 图标库
- 使用Phosphor Icons
- 统一线条粗细：2px
- 统一圆角：2px

### 11.2 插画风格
- 渐变色风格
- 科技感线条
- 柔和光效

### 11.3 动效库
- GSAP用于页面动画
- Three.js用于3D展示
- Lottie用于图标动画 