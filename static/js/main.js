/**
 * 全局变量和配置
 */
const config = {
    apiEndpoint: '/api',
    modelViewerConfig: {
        autoRotate: true,
        cameraControls: true,
        shadowIntensity: 1,
        exposure: 1,
        environmentImage: 'neutral',
        loading: 'lazy'
    }
};

/**
 * 页面加载完成后初始化
 */
document.addEventListener('DOMContentLoaded', () => {
    initializeModelViewers();
    initializeAnimations();
    initializeScrollEffects();
    initializeFormValidation();
    initPage();
});

/**
 * 初始化所有model-viewer组件
 */
function initializeModelViewers() {
    const modelViewers = document.querySelectorAll('model-viewer');
    modelViewers.forEach(viewer => {
        // 应用配置
        Object.entries(config.modelViewerConfig).forEach(([key, value]) => {
            viewer[key] = value;
        });

        // 添加加载事件监听
        viewer.addEventListener('load', () => {
            viewer.classList.add('loaded');
        });

        // 添加错误处理
        viewer.addEventListener('error', (error) => {
            console.error('Model loading error:', error);
            viewer.classList.add('error');
        });
    });
}

/**
 * 初始化页面动画
 */
function initializeAnimations() {
    // 初始化GSAP ScrollTrigger
    gsap.registerPlugin(ScrollTrigger);

    // 页面加载动画
    gsap.from('.hero-content', {
        duration: 1,
        y: 100,
        opacity: 0,
        ease: 'power4.out'
    });

    // 关于卡片动画
    gsap.from('.about-card', {
        scrollTrigger: {
            trigger: '.about',
            start: 'top center',
            toggleActions: 'play none none reverse'
        },
        duration: 0.8,
        y: 50,
        opacity: 0,
        stagger: 0.2,
        ease: 'back.out(1.7)'
    });

    // 特点展示动画
    gsap.from('.feature-item', {
        scrollTrigger: {
            trigger: '.features',
            start: 'top center',
            toggleActions: 'play none none reverse'
        },
        duration: 0.8,
        x: -100,
        opacity: 0,
        stagger: 0.2,
        ease: 'power4.out'
    });

    // 技术原理时间线动画
    gsap.from('.timeline-item', {
        scrollTrigger: {
            trigger: '.tech',
            start: 'top center',
            toggleActions: 'play none none reverse'
        },
        duration: 0.8,
        scale: 0.8,
        opacity: 0,
        stagger: 0.2,
        ease: 'elastic.out(1, 0.8)'
    });
}

/**
 * 初始化滚动效果
 */
function initializeScrollEffects() {
    // 导航栏滚动效果
    let lastScroll = 0;
    const nav = document.querySelector('.main-nav');
    
    window.addEventListener('scroll', () => {
        const currentScroll = window.pageYOffset;
        
        if (currentScroll <= 0) {
            nav.classList.remove('scroll-up');
            return;
        }
        
        if (currentScroll > lastScroll && !nav.classList.contains('scroll-down')) {
            nav.classList.remove('scroll-up');
            nav.classList.add('scroll-down');
        } else if (currentScroll < lastScroll && nav.classList.contains('scroll-down')) {
            nav.classList.remove('scroll-down');
            nav.classList.add('scroll-up');
        }
        
        lastScroll = currentScroll;
    });

    // 平滑滚动
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                target.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });

    // 鼠标移动视差效果
    document.addEventListener('mousemove', (e) => {
        const moveX = (e.clientX - window.innerWidth / 2) * 0.01;
        const moveY = (e.clientY - window.innerHeight / 2) * 0.01;

        gsap.to('.hero-content', {
            duration: 1,
            x: moveX,
            y: moveY,
            ease: 'power1.out'
        });
    });

    // 滚动到顶部按钮
    const scrollToTop = () => {
        window.scrollTo({
            top: 0,
            behavior: 'smooth'
        });
    };

    // 监听滚动显示/隐藏返回顶部按钮
    window.addEventListener('scroll', () => {
        const scrollTop = document.documentElement.scrollTop;
        const backToTop = document.querySelector('.back-to-top');
        
        if (backToTop) {
            if (scrollTop > 300) {
                backToTop.style.opacity = '1';
                backToTop.style.visibility = 'visible';
            } else {
                backToTop.style.opacity = '0';
                backToTop.style.visibility = 'hidden';
            }
        }
    });
}

/**
 * 初始化表单验证
 */
function initializeFormValidation() {
    const forms = document.querySelectorAll('form');
    
    forms.forEach(form => {
        form.addEventListener('submit', (e) => {
            if (!validateForm(form)) {
                e.preventDefault();
            }
        });
    });
}

/**
 * 表单验证函数
 * @param {HTMLFormElement} form - 表单元素
 * @returns {boolean} 验证是否通过
 */
function validateForm(form) {
    let isValid = true;
    const inputs = form.querySelectorAll('input[required], textarea[required]');
    
    inputs.forEach(input => {
        if (!input.value.trim()) {
            showError(input, '此字段不能为空');
            isValid = false;
        } else {
            clearError(input);
        }
    });
    
    return isValid;
}

/**
 * 显示错误信息
 * @param {HTMLElement} element - 表单元素
 * @param {string} message - 错误信息
 */
function showError(element, message) {
    const errorDiv = document.createElement('div');
    errorDiv.className = 'error-message';
    errorDiv.textContent = message;
    
    element.classList.add('error');
    element.parentNode.appendChild(errorDiv);
}

/**
 * 清除错误信息
 * @param {HTMLElement} element - 表单元素
 */
function clearError(element) {
    element.classList.remove('error');
    const errorDiv = element.parentNode.querySelector('.error-message');
    if (errorDiv) {
        errorDiv.remove();
    }
}

/**
 * 显示加载动画
 * @param {HTMLElement} element - 要显示加载动画的元素
 */
function showLoading(element) {
    const spinner = document.createElement('div');
    spinner.className = 'loading-spinner';
    element.appendChild(spinner);
}

/**
 * 隐藏加载动画
 * @param {HTMLElement} element - 要隐藏加载动画的元素
 */
function hideLoading(element) {
    const spinner = element.querySelector('.loading-spinner');
    if (spinner) {
        spinner.remove();
    }
}

/**
 * 显示提示消息
 * @param {string} message - 消息内容
 * @param {string} type - 消息类型（success/warning/error）
 */
function showAlert(message, type = 'success') {
    const alert = document.createElement('div');
    alert.className = `alert alert-${type}`;
    alert.textContent = message;
    
    document.body.appendChild(alert);
    
    setTimeout(() => {
        alert.remove();
    }, 3000);
}

/**
 * 防抖函数
 * @param {Function} func - 要执行的函数
 * @param {number} wait - 等待时间（毫秒）
 * @returns {Function} 防抖后的函数
 */
function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}

// 导出工具函数
window.utils = {
    showLoading,
    hideLoading,
    showAlert,
    debounce
};

/**
 * 模型数据
 * @type {Array<Object>}
 */
const models = [
    {
        id: 'bus',
        name: '大巴',
        path: 'models/大巴.usdz',
        description: '3D大巴模型'
    },
    {
        id: 'zc2',
        name: 'ZC2',
        path: 'models/zc2.usdz',
        description: 'ZC2模型'
    },
    {
        id: 'zc',
        name: 'ZC',
        path: 'models/zc.usdz',
        description: 'ZC模型'
    },
    {
        id: 'untitled',
        name: '未命名扫描',
        path: 'models/Untitled_Scan.usdz',
        description: '扫描模型'
    },
    {
        id: 'kanye',
        name: 'Kanye',
        path: 'models/kanye.usdz',
        description: 'Kanye模型'
    }
];

/**
 * 创建模型卡片
 * @param {Object} model - 模型数据
 * @returns {HTMLElement} 模型卡片元素
 */
function createModelCard(model) {
    const card = document.createElement('div');
    card.className = 'model-card';
    
    card.innerHTML = `
        <div class="model-preview">
            <model-viewer
                src="${model.path}"
                alt="${model.name}"
                auto-rotate
                camera-controls
                shadow-intensity="1"
            ></model-viewer>
        </div>
        <div class="model-info">
            <h3 class="model-title">${model.name}</h3>
            <p class="model-description">${model.description}</p>
        </div>
    `;
    
    return card;
}

/**
 * 初始化页面
 */
function initPage() {
    const modelsGrid = document.querySelector('.models-grid');
    
    // 添加模型卡片到网格
    models.forEach(model => {
        const card = createModelCard(model);
        modelsGrid.appendChild(card);
    });
} 