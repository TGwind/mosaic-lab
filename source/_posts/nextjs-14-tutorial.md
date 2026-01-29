---
title: Next.js 14 完整教程：从入门到实战
date: 2026-01-27
tags:
  - Next.js
  - React
  - 全栈开发
  - 教程
categories:
  - 技术
cover: https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=800&h=400&fit=crop
description: 最全面的 Next.js 14 中文教程，涵盖 App Router、Server Components、数据获取、部署等核心知识，附带实战项目。
keywords: Next.js教程, Next.js 14, React框架, App Router, Server Components, 全栈开发, Web开发教程
---

## 前言

Next.js 是目前最流行的 React 全栈框架，Next.js 14 带来了许多激动人心的新特性。本教程将带你从零开始，系统学习 Next.js 14 的核心概念和最佳实践。

<!-- more -->

## 目录

1. [环境搭建](#环境搭建)
2. [App Router 基础](#app-router-基础)
3. [页面和布局](#页面和布局)
4. [数据获取](#数据获取)
5. [Server Components](#server-components)
6. [API Routes](#api-routes)
7. [样式方案](#样式方案)
8. [部署上线](#部署上线)

## 环境搭建

### 系统要求

- Node.js 18.17 或更高版本
- macOS、Windows 或 Linux

### 创建项目

```bash
# 使用 create-next-app 创建项目
npx create-next-app@latest my-app

# 进入项目目录
cd my-app

# 启动开发服务器
npm run dev
```

创建时会提示以下选项，推荐配置：

```
✔ Would you like to use TypeScript? Yes
✔ Would you like to use ESLint? Yes
✔ Would you like to use Tailwind CSS? Yes
✔ Would you like to use `src/` directory? Yes
✔ Would you like to use App Router? Yes
✔ Would you like to customize the default import alias? No
```

## App Router 基础

Next.js 14 使用 App Router 作为默认路由系统。

### 文件系统路由

```
src/app/
├── page.tsx          # 首页 /
├── about/
│   └── page.tsx      # /about
├── blog/
│   ├── page.tsx      # /blog
│   └── [slug]/
│       └── page.tsx  # /blog/:slug
└── layout.tsx        # 根布局
```

### 特殊文件

| 文件 | 作用 |
|------|------|
| `page.tsx` | 页面组件 |
| `layout.tsx` | 布局组件 |
| `loading.tsx` | 加载状态 |
| `error.tsx` | 错误处理 |
| `not-found.tsx` | 404 页面 |

## 页面和布局

### 创建页面

```tsx
// src/app/page.tsx
export default function HomePage() {
  return (
    <main>
      <h1>欢迎来到 BitMosaic Lab</h1>
      <p>这是首页内容</p>
    </main>
  );
}
```

### 创建布局

```tsx
// src/app/layout.tsx
import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'BitMosaic Lab',
  description: '全栈开发者的数字实验室',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="zh-CN">
      <body>
        <header>导航栏</header>
        {children}
        <footer>页脚</footer>
      </body>
    </html>
  );
}
```

### 嵌套布局

```tsx
// src/app/blog/layout.tsx
export default function BlogLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="blog-container">
      <aside>侧边栏</aside>
      <main>{children}</main>
    </div>
  );
}
```

## 数据获取

Next.js 14 简化了数据获取方式。

### Server Components 中获取数据

```tsx
// src/app/posts/page.tsx
async function getPosts() {
  const res = await fetch('https://api.example.com/posts', {
    next: { revalidate: 3600 } // 1小时重新验证
  });
  return res.json();
}

export default async function PostsPage() {
  const posts = await getPosts();

  return (
    <ul>
      {posts.map((post) => (
        <li key={post.id}>{post.title}</li>
      ))}
    </ul>
  );
}
```

### 缓存策略

```tsx
// 不缓存 - 每次请求都获取最新数据
fetch('https://...', { cache: 'no-store' });

// 缓存 - 默认行为
fetch('https://...', { cache: 'force-cache' });

// 定时重新验证
fetch('https://...', { next: { revalidate: 3600 } });
```

## Server Components

Server Components 是 Next.js 14 的核心特性。

### Server vs Client Components

```tsx
// Server Component (默认)
// src/app/components/ServerComponent.tsx
async function ServerComponent() {
  const data = await fetchData(); // 可以直接访问数据库
  return <div>{data}</div>;
}

// Client Component
// src/app/components/ClientComponent.tsx
'use client';

import { useState } from 'react';

export default function ClientComponent() {
  const [count, setCount] = useState(0);
  return <button onClick={() => setCount(count + 1)}>{count}</button>;
}
```

### 何时使用 Client Component？

- 需要使用 useState、useEffect 等 Hook
- 需要浏览器 API（localStorage、window）
- 需要事件监听器
- 需要使用 React 类组件

## API Routes

### 创建 API 端点

```tsx
// src/app/api/posts/route.ts
import { NextResponse } from 'next/server';

export async function GET() {
  const posts = await getPosts();
  return NextResponse.json(posts);
}

export async function POST(request: Request) {
  const body = await request.json();
  const newPost = await createPost(body);
  return NextResponse.json(newPost, { status: 201 });
}
```

### 动态路由 API

```tsx
// src/app/api/posts/[id]/route.ts
export async function GET(
  request: Request,
  { params }: { params: { id: string } }
) {
  const post = await getPost(params.id);
  if (!post) {
    return NextResponse.json(
      { error: 'Post not found' },
      { status: 404 }
    );
  }
  return NextResponse.json(post);
}
```

## 样式方案

### Tailwind CSS（推荐）

```tsx
export default function Card({ title, content }) {
  return (
    <div className="rounded-lg bg-white p-6 shadow-md hover:shadow-lg transition-shadow">
      <h2 className="text-xl font-bold text-gray-900">{title}</h2>
      <p className="mt-2 text-gray-600">{content}</p>
    </div>
  );
}
```

### CSS Modules

```tsx
// styles/Card.module.css
.card {
  border-radius: 8px;
  padding: 24px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

// Card.tsx
import styles from './Card.module.css';

export default function Card() {
  return <div className={styles.card}>内容</div>;
}
```

## 部署上线

### Vercel 部署（推荐）

1. 将代码推送到 GitHub
2. 访问 [vercel.com](https://vercel.com)
3. 导入 GitHub 仓库
4. 点击 Deploy

### Docker 部署

```dockerfile
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:18-alpine AS runner
WORKDIR /app
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public

EXPOSE 3000
CMD ["node", "server.js"]
```

## 最佳实践

### 1. 项目结构

```
src/
├── app/                 # 路由和页面
├── components/          # 可复用组件
│   ├── ui/             # UI 组件
│   └── features/       # 功能组件
├── lib/                # 工具函数
├── hooks/              # 自定义 Hooks
├── types/              # TypeScript 类型
└── styles/             # 全局样式
```

### 2. 性能优化

- 使用 `next/image` 优化图片
- 使用 `next/font` 优化字体
- 合理使用 Server/Client Components
- 实现增量静态再生成 (ISR)

### 3. SEO 优化

```tsx
// 使用 Metadata API
export const metadata: Metadata = {
  title: '页面标题',
  description: '页面描述',
  openGraph: {
    title: '分享标题',
    description: '分享描述',
    images: ['/og-image.png'],
  },
};
```

## 总结

Next.js 14 是构建现代 Web 应用的绝佳选择：

- ✅ App Router 提供更好的路由体验
- ✅ Server Components 提升性能
- ✅ 内置优化（图片、字体、脚本）
- ✅ 完善的 TypeScript 支持
- ✅ 灵活的部署选项

## 下一步

- 阅读 [Next.js 官方文档](https://nextjs.org/docs)
- 尝试构建一个完整项目
- 探索 Next.js 生态系统

---

有问题欢迎在评论区讨论！
