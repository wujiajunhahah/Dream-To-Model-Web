#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from flask import Flask

# 创建Flask应用
app = Flask(__name__)

# 静态HTML内容
STATIC_HTML = '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>DreamEcho - Transform your dreams into unique 3D art</title>
    
    <!-- Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@100;200;300;400;500;600;700;800;900&display=swap" rel="stylesheet">
    
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: {
                        background: 'hsl(137 47% 15%)',
                        foreground: 'hsl(81 80% 85%)',
                        primary: 'hsl(81 70% 60%)',
                        'primary-foreground': 'hsl(137 50% 10%)',
                        'dreamecho-accent': 'hsl(81 80% 70%)',
                        'dreamecho-accent-foreground': 'hsl(137 50% 10%)',
                        card: 'hsl(137 47% 15%)',
                        'card-foreground': 'hsl(81 80% 85%)',
                        popover: 'hsl(137 47% 12%)',
                        'popover-foreground': 'hsl(81 80% 85%)',
                        secondary: 'hsl(137 40% 25%)',
                        'secondary-foreground': 'hsl(81 70% 80%)',
                        muted: 'hsl(137 40% 20%)',
                        'muted-foreground': 'hsl(81 50% 70%)',
                        accent: 'hsl(137 40% 30%)',
                        'accent-foreground': 'hsl(81 80% 95%)',
                        destructive: 'hsl(0 84% 60%)',
                        'destructive-foreground': 'hsl(0 0% 100%)',
                        border: 'hsl(137 40% 25%)',
                        input: 'hsl(137 40% 25%)',
                        ring: 'hsl(81 70% 60%)'
                    },
                    fontFamily: {
                        'inter': ['Inter', 'sans-serif']
                    }
                }
            }
        }
    </script>
    
    <style>
        body {
            font-family: 'Inter', sans-serif;
            background: hsl(137 47% 15%);
            color: hsl(81 80% 85%);
        }
        
        .glass {
            background: rgba(0, 0, 0, 0.3);
            backdrop-filter: blur(12px);
            border: 1px solid rgba(129, 140, 248, 0.2);
        }
        
        .glass-hover {
            transition: all 0.3s ease;
        }
        
        .glass-hover:hover {
            background: rgba(0, 0, 0, 0.4);
            border-color: rgba(129, 140, 248, 0.4);
        }
        
        .button-gradient-dreamecho {
            background: linear-gradient(to right, hsl(81 70% 60%), hsl(81 80% 70%));
            color: hsl(137 50% 10%);
            transition: opacity 0.3s ease;
        }
        
        .button-gradient-dreamecho:hover {
            opacity: 0.9;
        }
        
        .animate-slide-up {
            animation: slideUp 0.6s ease-out;
        }
        
        @keyframes slideUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
    </style>
</head>
<body class="min-h-screen bg-background text-foreground antialiased">
    <!-- Navigation -->
    <header id="navigation" class="fixed top-3.5 left-1/2 -translate-x-1/2 z-50 transition-all duration-300 rounded-full h-14 bg-background/80 backdrop-blur-lg w-[95%] max-w-3xl border border-transparent">
        <div class="mx-auto h-full px-6">
            <nav class="flex items-center justify-between h-full">
                <div class="flex items-center gap-2">
                    <svg class="w-5 h-5 text-primary" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4"></path>
                    </svg>
                    <span class="font-bold text-base text-foreground">DreamEcho</span>
                </div>

                <!-- Desktop Navigation -->
                <div class="hidden md:flex items-center gap-6">
                    <a href="#" onclick="scrollToTop()" class="text-sm text-muted-foreground hover:text-foreground transition-all duration-300">Home</a>
                    <a href="#features" onclick="scrollToSection('features')" class="text-sm text-muted-foreground hover:text-foreground transition-all duration-300">Features</a>
                    <a href="#about" onclick="scrollToSection('about')" class="text-sm text-muted-foreground hover:text-foreground transition-all duration-300">About</a>
                    <a href="#contact" onclick="scrollToSection('contact')" class="text-sm text-muted-foreground hover:text-foreground transition-all duration-300">Contact</a>
                    <a href="#contact" class="px-4 py-2 button-gradient-dreamecho rounded-full text-sm font-medium">Start Creating</a>
                </div>

                <!-- Mobile Navigation Button -->
                <div class="md:hidden">
                    <button onclick="toggleMobileMenu()" class="glass p-2 rounded-lg">
                        <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"></path>
                        </svg>
                    </button>
                </div>
            </nav>
        </div>
    </header>

    <!-- Hero Section -->
    <section class="relative container mx-auto px-4 pt-40 pb-20">
        <div class="max-w-4xl relative z-10">
            <h1 class="text-5xl md:text-7xl font-normal mb-4 tracking-tight text-left">
                <span class="text-foreground/80">
                    Transform your dreams
                </span>
                <br />
                <span class="text-foreground font-medium">
                    into unique 3D art
                </span>
            </h1>
            
            <p class="text-lg md:text-xl text-muted-foreground mb-8 max-w-2xl text-left animate-slide-up">
                With advanced AI, we transform your dreams into unique 3D artworks.
                <span class="text-foreground">Each dream becomes a one-of-a-kind NFT, permanently stored on the blockchain.</span>
            </p>
            
            <div class="flex flex-col sm:flex-row gap-4 items-start animate-slide-up">
                <a href="#contact" class="px-6 py-3 button-gradient-dreamecho rounded-full text-lg font-semibold">
                    Start Creating
                </a>
                <a href="#features" class="px-6 py-3 text-foreground hover:text-primary transition-colors text-lg font-semibold flex items-center">
                    Explore Dreams 
                    <svg class="ml-2 w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"></path>
                    </svg>
                </a>
            </div>
        </div>

        <div class="relative mx-auto max-w-5xl mt-20 animate-slide-up">
            <div class="glass rounded-xl overflow-hidden">
                <img
                    src="/static/images/已移除背景的网站图拍呢.png"
                    alt="DreamEcho 3D Dream Art Showcase"
                    class="w-full h-auto"
                />
            </div>
        </div>
    </section>

    <!-- Tech Support Carousel -->
    <section class="py-12 bg-background">
        <div class="container mx-auto px-4">
            <div class="text-center mb-8">
                <p class="text-muted-foreground text-sm">Powered by cutting-edge AI and 3D printing technologies</p>
            </div>
            <div class="flex justify-center items-center gap-8 opacity-60">
                <a href="https://bambulab.com" target="_blank" class="text-2xl font-bold hover:text-primary transition-colors">Bambu Lab</a>
                <a href="https://deepseek.com" target="_blank" class="text-2xl font-bold hover:text-primary transition-colors">DeepSeek</a>
                <a href="https://tripo3d.ai" target="_blank" class="text-2xl font-bold hover:text-primary transition-colors">Tripo</a>
            </div>
        </div>
    </section>

    <!-- Features Section -->
    <section id="features" class="bg-background">
        <div class="container mx-auto px-4 py-20">
            <div class="text-center mb-16">
                <h2 class="text-3xl md:text-4xl font-bold mb-4 text-foreground">
                    Why Choose DreamEcho?
                </h2>
                <p class="text-lg text-muted-foreground max-w-2xl mx-auto">
                    Experience the future of digital art creation with our advanced AI technology
                </p>
            </div>
            
            <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
                <div class="glass glass-hover p-8 rounded-xl text-center">
                    <div class="w-16 h-16 bg-gradient-to-r from-primary to-dreamecho-accent rounded-full flex items-center justify-center mx-auto mb-6">
                        <svg class="w-8 h-8 text-primary-foreground" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z"></path>
                        </svg>
                    </div>
                    <h3 class="text-xl font-semibold mb-4 text-foreground">Advanced AI Technology</h3>
                    <p class="text-muted-foreground">Using cutting-edge artificial intelligence to precisely understand and transform your dream descriptions</p>
                </div>
                
                <div class="glass glass-hover p-8 rounded-xl text-center">
                    <div class="w-16 h-16 bg-gradient-to-r from-primary to-dreamecho-accent rounded-full flex items-center justify-center mx-auto mb-6">
                        <svg class="w-8 h-8 text-primary-foreground" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"></path>
                        </svg>
                    </div>
                    <h3 class="text-xl font-semibold mb-4 text-foreground">High-Quality 3D Models</h3>
                    <p class="text-muted-foreground">Generated using Tripo3D for professional-grade results</p>
                </div>
                
                <div class="glass glass-hover p-8 rounded-xl text-center">
                    <div class="w-16 h-16 bg-gradient-to-r from-primary to-dreamecho-accent rounded-full flex items-center justify-center mx-auto mb-6">
                        <svg class="w-8 h-8 text-primary-foreground" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z"></path>
                        </svg>
                    </div>
                    <h3 class="text-xl font-semibold mb-4 text-foreground">3D Printing Ready</h3>
                    <p class="text-muted-foreground">Compatible with Bambu Lab printers for physical creation</p>
                </div>
            </div>
        </div>
    </section>

    <!-- About Section -->
    <section id="about" class="bg-background">
        <div class="container mx-auto px-4 py-20">
            <div class="text-center mb-16">
                <h2 class="text-3xl md:text-4xl font-bold mb-4 text-foreground">
                    About Our Vision
                </h2>
                <p class="text-lg text-muted-foreground max-w-2xl mx-auto">
                    Bridging the gap between imagination and reality through cutting-edge AI technology
                </p>
            </div>
            
            <div class="grid grid-cols-1 lg:grid-cols-2 gap-12 items-center">
                <div class="space-y-6">
                    <h3 class="text-2xl font-semibold text-foreground">Our Mission</h3>
                    <p class="text-muted-foreground leading-relaxed">
                        At DreamEcho, we believe that every dream deserves to be brought to life. Our mission is to democratize 3D art creation by making it accessible to everyone, regardless of their technical background. Through advanced AI technology, we transform abstract thoughts and dreams into tangible 3D artworks.
                    </p>
                    
                    <div class="flex items-center space-x-4 pt-4">
                        <img src="/static/images/avatar.jpg" alt="Creator Avatar" class="w-16 h-16 rounded-full object-cover">
                        <div>
                            <h4 class="font-semibold text-foreground">Wu Jiajun</h4>
                            <p class="text-muted-foreground">Founder & Lead Developer</p>
                            <a href="https://github.com/wujiajunhahah" target="_blank" class="text-primary hover:text-primary/80 transition-colors text-sm">
                                @wujiajunhahah
                            </a>
                        </div>
                    </div>
                </div>
                
                <div class="glass p-8 rounded-xl">
                    <h3 class="text-xl font-semibold mb-6 text-foreground">Why Choose DreamEcho?</h3>
                    <div class="space-y-4">
                        <div class="flex items-start space-x-3">
                            <div class="w-6 h-6 bg-primary rounded-full flex items-center justify-center mt-1">
                                <svg class="w-3 h-3 text-primary-foreground" fill="currentColor" viewBox="0 0 20 20">
                                    <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"></path>
                                </svg>
                            </div>
                            <div>
                                <h4 class="font-medium text-foreground">Innovative AI Technology</h4>
                                <p class="text-sm text-muted-foreground">Powered by DeepSeek AI for advanced dream interpretation</p>
                            </div>
                        </div>
                        
                        <div class="flex items-start space-x-3">
                            <div class="w-6 h-6 bg-primary rounded-full flex items-center justify-center mt-1">
                                <svg class="w-3 h-3 text-primary-foreground" fill="currentColor" viewBox="0 0 20 20">
                                    <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"></path>
                                </svg>
                            </div>
                            <div>
                                <h4 class="font-medium text-foreground">High-Quality 3D Models</h4>
                                <p class="text-sm text-muted-foreground">Generated using Tripo3D for professional-grade results</p>
                            </div>
                        </div>
                        
                        <div class="flex items-start space-x-3">
                            <div class="w-6 h-6 bg-primary rounded-full flex items-center justify-center mt-1">
                                <svg class="w-3 h-3 text-primary-foreground" fill="currentColor" viewBox="0 0 20 20">
                                    <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"></path>
                                </svg>
                            </div>
                            <div>
                                <h4 class="font-medium text-foreground">3D Printing Ready</h4>
                                <p class="text-sm text-muted-foreground">Compatible with Bambu Lab printers for physical creation</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Contact Section -->
    <section id="contact" class="bg-background">
        <div class="container mx-auto px-4 py-20">
            <div class="text-center mb-16">
                <h2 class="text-3xl md:text-4xl font-bold mb-4 text-foreground">
                    Get In Touch
                </h2>
                <p class="text-lg text-muted-foreground max-w-2xl mx-auto">
                    Have questions about DreamEcho? We'd love to hear from you.
                </p>
            </div>
            
            <div class="grid grid-cols-1 lg:grid-cols-2 gap-12">
                <div class="space-y-8">
                    <div>
                        <h3 class="text-xl font-semibold mb-6 text-foreground">Contact Information</h3>
                        <div class="space-y-4">
                            <div class="flex items-center space-x-4">
                                <div class="w-10 h-10 bg-primary/10 rounded-full flex items-center justify-center">
                                    <svg class="w-5 h-5 text-primary" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 4.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"></path>
                                    </svg>
                                </div>
                                <div>
                                    <p class="font-medium text-foreground">Email</p>
                                    <p class="text-muted-foreground">contact@dreamecho.ai</p>
                                </div>
                            </div>
                            
                            <div class="flex items-center space-x-4">
                                <div class="w-10 h-10 bg-primary/10 rounded-full flex items-center justify-center">
                                    <svg class="w-5 h-5 text-primary" fill="currentColor" viewBox="0 0 24 24">
                                        <path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z"/>
                                    </svg>
                                </div>
                                <div>
                                    <p class="font-medium text-foreground">GitHub</p>
                                    <a href="https://github.com/wujiajunhahah" target="_blank" class="text-primary hover:text-primary/80 transition-colors">
                                        github.com/wujiajunhahah
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <div>
                        <h3 class="text-xl font-semibold mb-6 text-foreground">Connect on WeChat</h3>
                        <div class="flex items-center space-x-4">
                            <img src="/static/images/default-qr.png" alt="WeChat QR Code" class="w-24 h-24 rounded-lg">
                            <div>
                                <p class="font-medium text-foreground">Scan to connect</p>
                                <p class="text-muted-foreground text-sm">Add me on WeChat for direct communication</p>
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="glass p-8 rounded-xl">
                    <h3 class="text-xl font-semibold mb-6 text-foreground">Ready to Start?</h3>
                    <p class="text-muted-foreground mb-6">
                        Transform your dreams into unique 3D artworks with our advanced AI technology. 
                        Contact us to begin your creative journey!
                    </p>
                    <div class="space-y-4">
                        <div class="p-4 bg-primary/10 rounded-lg">
                            <h4 class="font-medium text-foreground mb-2">🚀 AI-Powered Creation</h4>
                            <p class="text-sm text-muted-foreground">Advanced dream interpretation using DeepSeek AI</p>
                        </div>
                        <div class="p-4 bg-primary/10 rounded-lg">
                            <h4 class="font-medium text-foreground mb-2">🎨 Professional Quality</h4>
                            <p class="text-sm text-muted-foreground">High-quality 3D models generated with Tripo3D</p>
                        </div>
                        <div class="p-4 bg-primary/10 rounded-lg">
                            <h4 class="font-medium text-foreground mb-2">🖨️ Print Ready</h4>
                            <p class="text-sm text-muted-foreground">Compatible with Bambu Lab 3D printers</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Footer -->
    <footer class="bg-background border-t border-border">
        <div class="container mx-auto px-4 py-12">
            <div class="text-center">
                <div class="flex items-center justify-center space-x-2 mb-4">
                    <svg class="w-6 h-6 text-primary" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4"></path>
                    </svg>
                    <span class="text-xl font-semibold text-foreground">DreamEcho</span>
                </div>
                <p class="text-muted-foreground mb-4">Transform your dreams into unique 3D artworks</p>
                <p class="text-muted-foreground">&copy; 2024 DreamEcho. All rights reserved.</p>
            </div>
        </div>
    </footer>

    <script>
        // 平滑滚动
        function scrollToSection(sectionId) {
            const element = document.getElementById(sectionId);
            if (element) {
                element.scrollIntoView({ behavior: 'smooth' });
            }
        }

        function scrollToTop() {
            window.scrollTo({ top: 0, behavior: 'smooth' });
        }

        // 移动端菜单切换
        function toggleMobileMenu() {
            // 简化版本，暂不实现
        }

        // 导航栏滚动效果
        window.addEventListener('scroll', function() {
            const nav = document.getElementById('navigation');
            if (window.scrollY > 50) {
                nav.classList.add('bg-background/60', 'backdrop-blur-xl', 'border-border', 'scale-95');
                nav.classList.remove('bg-background/80', 'border-transparent');
                nav.style.width = '90%';
                nav.style.maxWidth = '32rem';
            } else {
                nav.classList.remove('bg-background/60', 'backdrop-blur-xl', 'border-border', 'scale-95');
                nav.classList.add('bg-background/80', 'border-transparent');
                nav.style.width = '95%';
                nav.style.maxWidth = '48rem';
            }
        });
    </script>
</body>
</html>
'''

@app.route('/')
def index():
    return STATIC_HTML

@app.route('/health')
def health():
    return {'status': 'ok', 'message': 'Static version running fast!'}

if __name__ == '__main__':
    print("🚀 DreamEcho Static Version - Super Fast!")
    print("📱 URL: http://localhost:5007")
    app.run(host='0.0.0.0', port=5007, debug=False, threaded=True) 