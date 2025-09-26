/**
 * 模型生成进度组件
 * 用于显示3D模型生成的进度和状态
 */
class ModelGenerationProgress {
    /**
     * @param {Object} options - 配置选项
     * @param {string} options.containerSelector - 容器选择器
     * @param {string} options.dreamId - 梦境ID
     * @param {number} options.pollInterval - 轮询间隔（毫秒）
     * @param {Function} options.onComplete - 完成时的回调函数
     * @param {Function} options.onError - 出错时的回调函数
     */
    constructor(options) {
        this.container = document.querySelector(options.containerSelector);
        this.dreamId = options.dreamId;
        this.pollInterval = options.pollInterval || 3000;
        this.onComplete = options.onComplete || function() {};
        this.onError = options.onError || function() {};
        this.pollingTimer = null;
        this.stages = [
            {id: 'analysis', title: '梦境分析', description: '分析描述中的关键元素与场景'},
            {id: 'modeling', title: '3D建模', description: '生成3D几何结构与基础纹理'},
            {id: 'texturing', title: '细节渲染', description: '添加光照、材质与特效'},
            {id: 'finalizing', title: '最终处理', description: '优化模型尺寸与格式'}
        ];
        this.currentStage = 0;
        this.totalProgress = 0;
        
        this.init();
    }
    
    /**
     * 初始化进度界面
     */
    init() {
        // 创建进度HTML
        this.container.innerHTML = `
            <div class="progress-container">
                <div class="progress-header">
                    <h3 class="progress-title">模型生成进度</h3>
                    <div class="progress-percent">${this.totalProgress}%</div>
                </div>
                
                <div class="progress-stages">
                    ${this.stages.map((stage, index) => `
                        <div class="progress-stage ${index === 0 ? 'active' : ''}" data-stage="${stage.id}">
                            <div class="stage-indicator">
                                <div class="stage-number">${index + 1}</div>
                                <div class="stage-line"></div>
                            </div>
                            <div class="stage-content">
                                <div class="stage-title">${stage.title}</div>
                                <div class="stage-description">${stage.description}</div>
                                <div class="stage-bar-container">
                                    <div class="stage-bar" style="width: 0%"></div>
                                </div>
                                <div class="stage-status">等待中...</div>
                            </div>
                        </div>
                    `).join('')}
                </div>
                
                <div class="progress-bar-container">
                    <div class="progress-bar" style="width: 0%"></div>
                </div>
                
                <div class="progress-footer">
                    <div class="estimated-time">
                        <i class="fas fa-clock"></i> 预计剩余时间: <span class="time-value">计算中...</span>
                    </div>
                    <div class="loading-cubes">
                        <div class="cube"></div>
                        <div class="cube"></div>
                        <div class="cube"></div>
                    </div>
                </div>
            </div>
        `;
    }
    
    /**
     * 开始轮询进度
     */
    startPolling() {
        this.pollingTimer = setInterval(() => {
            this.fetchProgress();
        }, this.pollInterval);
        
        // 立即获取一次进度
        this.fetchProgress();
    }
    
    /**
     * 停止轮询
     */
    stopPolling() {
        if (this.pollingTimer) {
            clearInterval(this.pollingTimer);
            this.pollingTimer = null;
        }
    }
    
    /**
     * 获取进度信息
     * 在实际应用中, 这应该是从后端API获取的真实数据
     */
    fetchProgress() {
        // 在实际项目中，这里应该是一个API调用
        // fetch(`/api/model-progress/${this.dreamId}`)
        //    .then(response => response.json())
        //    .then(data => this.updateProgress(data))
        //    .catch(error => this.handleError(error));
        
        // 模拟进度数据
        this.simulateProgress();
    }
    
    /**
     * 模拟进度数据 (仅用于演示)
     */
    simulateProgress() {
        const stageProgress = Math.min(this.totalProgress / 25, 1) * 100;
        let remainingTime = "约5分钟";
        let status = "处理中...";
        let hasError = false;
        
        // 根据总进度计算当前阶段
        if (this.totalProgress <= 25) {
            this.currentStage = 0;
        } else if (this.totalProgress <= 50) {
            this.currentStage = 1;
        } else if (this.totalProgress <= 75) {
            this.currentStage = 2;
        } else {
            this.currentStage = 3;
        }
        
        // 根据当前阶段更新剩余时间
        switch (this.currentStage) {
            case 0:
                remainingTime = "约5分钟";
                break;
            case 1:
                remainingTime = "约3分钟";
                break;
            case 2:
                remainingTime = "约2分钟";
                break;
            case 3:
                remainingTime = "不到1分钟";
                break;
        }
        
        // 随机生成状态消息
        const messages = [
            ["分析梦境描述...", "提取关键场景元素...", "识别空间关系..."],
            ["构建基础几何形状...", "创建场景结构...", "生成主要物体..."],
            ["应用材质与纹理...", "添加光照效果...", "处理表面细节..."],
            ["优化模型结构...", "准备文件输出...", "完成最终处理..."]
        ];
        
        status = messages[this.currentStage][Math.floor(Math.random() * 3)];
        
        // 随机添加5%的错误概率 (仅用于演示)
        if (Math.random() < 0.05 && this.totalProgress < 95) {
            hasError = true;
            status = "处理遇到问题，正在重试...";
        }
        
        // 更新进度
        this.updateProgress({
            totalProgress: this.totalProgress,
            stageProgress: stageProgress,
            currentStage: this.currentStage,
            remainingTime: remainingTime,
            status: status,
            hasError: hasError
        });
        
        // 增加总进度 (仅用于演示)
        if (this.totalProgress < 100) {
            this.totalProgress += Math.floor(Math.random() * 4) + 1;
            
            // 确保不超过100%
            if (this.totalProgress > 100) {
                this.totalProgress = 100;
                
                // 完成时停止轮询并调用回调
                setTimeout(() => {
                    this.stopPolling();
                    this.onComplete({
                        modelId: `model-${Date.now()}`, // 模拟模型ID
                        modelUrl: `/static/models/dream_model_${Date.now()}.glb`
                    });
                }, 1000);
            }
        }
    }
    
    /**
     * 更新界面显示
     * @param {Object} data - 进度数据
     */
    updateProgress(data) {
        // 更新总进度条
        const progressBar = this.container.querySelector('.progress-bar');
        progressBar.style.width = `${data.totalProgress}%`;
        
        // 更新百分比显示
        const progressPercent = this.container.querySelector('.progress-percent');
        progressPercent.textContent = `${data.totalProgress}%`;
        
        // 更新剩余时间
        const timeValue = this.container.querySelector('.time-value');
        timeValue.textContent = data.remainingTime;
        
        // 更新所有阶段状态
        const stages = this.container.querySelectorAll('.progress-stage');
        stages.forEach((stage, index) => {
            if (index < data.currentStage) {
                // 已完成的阶段
                stage.classList.remove('active');
                stage.classList.add('completed');
                const stageBar = stage.querySelector('.stage-bar');
                stageBar.style.width = '100%';
                const stageStatus = stage.querySelector('.stage-status');
                stageStatus.textContent = '已完成';
            } else if (index === data.currentStage) {
                // 当前阶段
                stage.classList.add('active');
                stage.classList.remove('completed');
                const stageBar = stage.querySelector('.stage-bar');
                stageBar.style.width = `${data.stageProgress}%`;
                const stageStatus = stage.querySelector('.stage-status');
                stageStatus.textContent = data.status;
                
                // 如果有错误，添加错误样式
                if (data.hasError) {
                    stage.classList.add('has-error');
                } else {
                    stage.classList.remove('has-error');
                }
            } else {
                // 等待中的阶段
                stage.classList.remove('active', 'completed', 'has-error');
                const stageBar = stage.querySelector('.stage-bar');
                stageBar.style.width = '0%';
                const stageStatus = stage.querySelector('.stage-status');
                stageStatus.textContent = '等待中...';
            }
        });
    }
    
    /**
     * 处理错误
     * @param {Error} error - 错误对象
     */
    handleError(error) {
        console.error('获取进度失败:', error);
        this.stopPolling();
        this.onError({
            message: '无法获取生成进度，请刷新页面重试。',
            error: error
        });
    }
}

// 导出组件
window.ModelGenerationProgress = ModelGenerationProgress; 