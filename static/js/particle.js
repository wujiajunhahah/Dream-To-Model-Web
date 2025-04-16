/**
 * 粒子动画系统
 * @class Particle
 */
class Particle {
    /**
     * 创建一个新的粒子实例
     * @param {Object} canvas - Canvas元素
     * @param {number} x - 初始X坐标
     * @param {number} y - 初始Y坐标
     * @param {boolean} isMouseParticle - 是否是鼠标触发的粒子
     */
    constructor(canvas, x, y, isMouseParticle = false) {
        this.canvas = canvas;
        this.x = x;
        this.y = y;
        this.isMouseParticle = isMouseParticle;
        this.size = isMouseParticle ? Math.random() * 3 + 2 : Math.random() * 2 + 1;
        this.baseSize = this.size;
        this.speedX = Math.random() * 3 - 1.5;
        this.speedY = Math.random() * 3 - 1.5;
        this.maxLife = isMouseParticle ? 50 : 150;
        this.life = 0;
        this.color = this.generateColor();
    }

    /**
     * 生成粒子颜色
     * @returns {string} 颜色值
     */
    generateColor() {
        const colors = [
            [0, 255, 157],  // 青绿色
            [0, 212, 255],  // 天蓝色
            [157, 0, 255]   // 紫色
        ];
        const color = colors[Math.floor(Math.random() * colors.length)];
        return `rgb(${color[0]}, ${color[1]}, ${color[2]})`;
    }

    /**
     * 更新粒子状态
     */
    update() {
        this.x += this.speedX;
        this.y += this.speedY;
        this.life++;

        // 边界检查和反弹
        if (this.x <= 0 || this.x >= this.canvas.width) {
            this.speedX *= -0.95; // 添加一些能量损失
            this.x = Math.max(0, Math.min(this.x, this.canvas.width));
        }
        if (this.y <= 0 || this.y >= this.canvas.height) {
            this.speedY *= -0.95; // 添加一些能量损失
            this.y = Math.max(0, Math.min(this.y, this.canvas.height));
        }

        // 鼠标粒子特殊效果
        if (this.isMouseParticle) {
            this.size = this.baseSize * (1 - this.life / this.maxLife);
        }
    }

    /**
     * 绘制粒子
     * @param {CanvasRenderingContext2D} ctx - Canvas上下文
     */
    draw(ctx) {
        const opacity = 1 - (this.life / this.maxLife);
        ctx.fillStyle = this.color.replace('rgb', 'rgba').replace(')', `, ${opacity})`);
        ctx.beginPath();
        ctx.arc(this.x, this.y, this.size, 0, Math.PI * 2);
        ctx.fill();
    }

    /**
     * 检查粒子是否应该被移除
     * @returns {boolean}
     */
    isDead() {
        return this.life >= this.maxLife;
    }
}

/**
 * 粒子系统管理器
 */
class ParticleSystem {
    /**
     * 创建粒子系统
     */
    constructor() {
        this.canvas = document.getElementById('particleCanvas');
        this.ctx = this.canvas.getContext('2d');
        this.particles = [];
        this.mouse = {
            x: null,
            y: null,
            radius: 150
        };
        this.lastTime = 0;
        this.fps = 60;
        this.frameInterval = 1000 / this.fps;

        this.init();
        this.animate();
        this.setupEventListeners();
    }

    /**
     * 初始化画布尺寸和粒子
     */
    init() {
        this.resizeCanvas();
        this.createInitialParticles();
    }

    /**
     * 调整画布尺寸
     */
    resizeCanvas() {
        const dpr = window.devicePixelRatio || 1;
        this.canvas.width = window.innerWidth * dpr;
        this.canvas.height = window.innerHeight * dpr;
        this.canvas.style.width = `${window.innerWidth}px`;
        this.canvas.style.height = `${window.innerHeight}px`;
        this.ctx.scale(dpr, dpr);
    }

    /**
     * 创建初始粒子
     */
    createInitialParticles() {
        const numberOfParticles = Math.min(
            100,
            Math.floor((this.canvas.width * this.canvas.height) / 15000)
        );
        for (let i = 0; i < numberOfParticles; i++) {
            const x = Math.random() * this.canvas.width;
            const y = Math.random() * this.canvas.height;
            this.particles.push(new Particle(this.canvas, x, y));
        }
    }

    /**
     * 设置事件监听器
     */
    setupEventListeners() {
        let resizeTimeout;
        window.addEventListener('resize', () => {
            clearTimeout(resizeTimeout);
            resizeTimeout = setTimeout(() => {
                this.resizeCanvas();
                this.particles = [];
                this.createInitialParticles();
            }, 250);
        });
        
        this.canvas.addEventListener('mousemove', (e) => {
            const rect = this.canvas.getBoundingClientRect();
            const dpr = window.devicePixelRatio || 1;
            this.mouse.x = (e.clientX - rect.left) * dpr;
            this.mouse.y = (e.clientY - rect.top) * dpr;
            
            if (this.particles.length < 300) { // 限制最大粒子数
                for (let i = 0; i < 2; i++) {
                    this.particles.push(new Particle(
                        this.canvas,
                        this.mouse.x,
                        this.mouse.y,
                        true
                    ));
                }
            }
        });

        this.canvas.addEventListener('mouseleave', () => {
            this.mouse.x = null;
            this.mouse.y = null;
        });
    }

    /**
     * 连接临近的粒子
     */
    connectParticles() {
        const maxDistance = 100;
        const maxConnections = 3; // 每个粒子最大连接数

        for (let i = 0; i < this.particles.length; i++) {
            let connections = 0;
            for (let j = i + 1; j < this.particles.length && connections < maxConnections; j++) {
                const dx = this.particles[i].x - this.particles[j].x;
                const dy = this.particles[i].y - this.particles[j].y;
                const distance = Math.sqrt(dx * dx + dy * dy);

                if (distance < maxDistance) {
                    connections++;
                    const opacity = 1 - (distance / maxDistance);
                    const gradient = this.ctx.createLinearGradient(
                        this.particles[i].x,
                        this.particles[i].y,
                        this.particles[j].x,
                        this.particles[j].y
                    );
                    gradient.addColorStop(0, this.particles[i].color.replace('rgb', 'rgba').replace(')', `, ${opacity * 0.2})`));
                    gradient.addColorStop(1, this.particles[j].color.replace('rgb', 'rgba').replace(')', `, ${opacity * 0.2})`));

                    this.ctx.strokeStyle = gradient;
                    this.ctx.lineWidth = 1;
                    this.ctx.beginPath();
                    this.ctx.moveTo(this.particles[i].x, this.particles[i].y);
                    this.ctx.lineTo(this.particles[j].x, this.particles[j].y);
                    this.ctx.stroke();
                }
            }
        }
    }

    /**
     * 动画循环
     * @param {number} timestamp - 当前时间戳
     */
    animate(timestamp = 0) {
        const deltaTime = timestamp - this.lastTime;

        if (deltaTime >= this.frameInterval) {
            this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
            
            this.particles = this.particles.filter(particle => !particle.isDead());
            
            this.particles.forEach(particle => {
                particle.update();
                particle.draw(this.ctx);
            });
            
            this.connectParticles();
            
            this.lastTime = timestamp - (deltaTime % this.frameInterval);
        }
        
        requestAnimationFrame((timestamp) => this.animate(timestamp));
    }
}

// 当DOM加载完成后初始化粒子系统
document.addEventListener('DOMContentLoaded', () => {
    new ParticleSystem();
}); 