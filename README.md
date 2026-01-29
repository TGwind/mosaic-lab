# Over's Blog

基于 Hexo + Butterfly 主题的个人博客

## 快速开始

### 启动博客

```bash
# macOS/Linux
chmod +x start.sh
./start.sh

# 或者手动启动
npx hexo server
```

访问：http://localhost:4000

### 常用命令

```bash
# 创建新文章
npx hexo new "文章标题"

# 创建新页面
npx hexo new page "页面名称"

# 清理缓存
npx hexo clean

# 生成静态文件
npx hexo generate

# 启动本地服务器
npx hexo server

# 部署到服务器
npx hexo deploy
```

## 目录结构

```
my-blog/
├── _config.yml           # 站点配置文件
├── _config.butterfly.yml # Butterfly 主题配置
├── source/              # 源文件目录
│   ├── _posts/         # 文章目录
│   └── about/          # 关于页面
├── themes/             # 主题目录
│   └── butterfly/      # Butterfly 主题
└── public/             # 生成的静态文件
```

## 写作指南

### 创建文章

```bash
npx hexo new "我的第一篇文章"
```

这会在 `source/_posts/` 目录下创建一个新的 Markdown 文件。

### 文章 Front-matter

```yaml
---
title: 文章标题
date: 2026-01-29 20:30:00
tags:
  - 标签1
  - 标签2
categories:
  - 分类名
cover: 封面图片URL
description: 文章描述
---
```

## 主题配置

编辑 `_config.butterfly.yml` 文件来自定义主题：

- **网站图标**：修改 `favicon` 配置
- **头像**：修改 `avatar.img` 配置
- **社交链接**：修改 `social` 配置
- **导航菜单**：修改 `menu` 配置
- **首页顶部图**：修改 `index_img` 配置

## 部署

### GitHub Pages

1. 修改 `_config.yml`：

```yaml
deploy:
  type: git
  repo: https://github.com/yourusername/yourusername.github.io
  branch: main
```

2. 安装部署插件：

```bash
npm install hexo-deployer-git --save
```

3. 部署：

```bash
npx hexo deploy
```

### Vercel/Netlify

直接连接 GitHub 仓库，设置构建命令：

- 构建命令：`npx hexo generate`
- 发布目录：`public`

## 资源链接

- [Hexo 官方文档](https://hexo.io/zh-cn/docs/)
- [Butterfly 主题文档](https://butterfly.js.org/)
- [Butterfly 主题演示](https://demo.jerryc.me/)

## 常见问题

### 修改配置后页面没变化？

```bash
npx hexo clean
npx hexo generate
```

### 如何更换主题？

编辑 `_config.yml`，修改 `theme` 字段，然后重新生成。

### 如何自定义样式？

在主题配置文件 `_config.butterfly.yml` 中找到 `inject` 配置，添加自定义 CSS。

---

Made with ❤️ by Over
