#!/bin/bash

echo "🚀 启动 Hexo 博客..."
echo ""

# 进入博客目录
cd "$(dirname "$0")"

# 清理缓存
echo "📦 清理缓存..."
npx hexo clean

# 生成静态文件
echo "🔨 生成静态文件..."
npx hexo generate

# 启动服务器
echo "🌐 启动本地服务器..."
echo ""
echo "访问地址: http://localhost:4000"
echo "按 Ctrl+C 停止服务"
echo ""
npx hexo server
