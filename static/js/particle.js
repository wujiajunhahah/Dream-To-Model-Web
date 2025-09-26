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
     */
    constructor(canvas, x, y) {
        this.canvas = canvas;
        this.x = x;
        this.y = y;
        this.size = Math.random() * 3 + 1;
        this.speedX = Math.random() * 2 - 1;
        this.speedY = Math.random() * 2 - 1;
        this.maxLife = Math.random() * 100 + 150;
        this.life = 0;
        this.opacity = Math.random() * 0.5 + 0.5;
        this.color = this.getRandomColor();
    }

    /**
     * 生成粒子颜色
     * @returns {string} 颜色值
     */
    getRandomColor() {
        const colors = [
            { r: 0, g: 255, b: 204 },  // 青色
            { r: 138, g: 43, b: 226 }   // 紫色
        ];
        const color = colors[Math.floor(Math.random() * colors.length)];
        return `rgba(${color.r}, ${color.g}, ${color.b}, ${this.opacity})`;
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
            this.speedX *= -1;
        }
        if (this.y <= 0 || this.y >= this.canvas.height) {
            this.speedY *= -1;
        }

        this.opacity = Math.max(0, 1 - (this.life / this.maxLife));
    }

    /**
     * 绘制粒子
     * @param {CanvasRenderingContext2D} ctx - Canvas上下文
     */
    draw(ctx) {
        ctx.beginPath();
        ctx.arc(this.x, this.y, this.size, 0, Math.PI * 2);
        ctx.fillStyle = this.color.replace(/[\d.]+\)$/,`${this.opacity})`);
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
    constructor(canvasId) {
        this.canvas = document.getElementById(canvasId);
        this.ctx = this.canvas.getContext('2d');
        this.particles = [];
        this.maxParticles = 100;
        this.mouseX = 0;
        this.mouseY = 0;
        this.mouseRadius = 100;
        this.init();
    }

    /**
     * 初始化画布尺寸和粒子
     */
    init() {
        this.resizeCanvas();
        this.createInitialParticles();
        this.setupEventListeners();
        this.animate();
    }

    /**
     * 调整画布尺寸
     */
    resizeCanvas() {
        this.canvas.width = window.innerWidth;
        this.canvas.height = window.innerHeight;
    }

    /**
     * 创建初始粒子
     */
    createInitialParticles() {
        for (let i = 0; i < this.maxParticles; i++) {
            const x = Math.random() * this.canvas.width;
            const y = Math.random() * this.canvas.height;
            this.particles.push(new Particle(this.canvas, x, y));
        }
    }

    /**
     * 设置事件监听器
     */
    setupEventListeners() {
        window.addEventListener('resize', () => this.resizeCanvas());
        
        this.canvas.addEventListener('mousemove', (e) => {
            const rect = this.canvas.getBoundingClientRect();
            this.mouseX = e.clientX - rect.left;
            this.mouseY = e.clientY - rect.top;
        });

        this.canvas.addEventListener('mouseleave', () => {
            this.mouseX = undefined;
            this.mouseY = undefined;
        });
    }

    /**
     * 连接临近的粒子
     */
    connectParticles() {
        const maxDistance = 150;
        for (let i = 0; i < this.particles.length; i++) {
            for (let j = i + 1; j < this.particles.length; j++) {
                const dx = this.particles[i].x - this.particles[j].x;
                const dy = this.particles[i].y - this.particles[j].y;
                const distance = Math.sqrt(dx * dx + dy * dy);

                if (distance < maxDistance) {
                    const opacity = (1 - distance / maxDistance) * 0.5;
                    this.ctx.beginPath();
                    this.ctx.strokeStyle = `rgba(255, 255, 255, ${opacity})`;
                    this.ctx.lineWidth = 0.5;
                    this.ctx.moveTo(this.particles[i].x, this.particles[i].y);
                    this.ctx.lineTo(this.particles[j].x, this.particles[j].y);
                    this.ctx.stroke();
                }
            }
        }
    }

    /**
     * 动画循环
     */
    animate() {
        this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);

        // 更新和绘制粒子
        this.particles.forEach((particle, index) => {
            particle.update();
            
            // 鼠标交互
            if (this.mouseX !== undefined && this.mouseY !== undefined) {
                const dx = particle.x - this.mouseX;
                const dy = particle.y - this.mouseY;
                const distance = Math.sqrt(dx * dx + dy * dy);
                
                if (distance < this.mouseRadius) {
                    const force = (this.mouseRadius - distance) / this.mouseRadius;
                    const angle = Math.atan2(dy, dx);
                    particle.x += Math.cos(angle) * force * 2;
                    particle.y += Math.sin(angle) * force * 2;
                }
            }

            particle.draw(this.ctx);

            // 替换死亡的粒子
            if (particle.isDead()) {
                this.particles[index] = new Particle(
                    this.canvas,
                    Math.random() * this.canvas.width,
                    Math.random() * this.canvas.height
                );
            }
        });

        // 连接临近的粒子
        this.connectParticles();

        requestAnimationFrame(() => this.animate());
    }
}

// 当DOM加载完成后初始化粒子系统
document.addEventListener('DOMContentLoaded', () => {
    new ParticleSystem('particleCanvas');
}); 