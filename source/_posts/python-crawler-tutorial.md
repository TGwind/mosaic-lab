---
title: Python 爬虫入门教程：从零开始抓取网页数据
date: 2026-01-24
tags:
  - Python
  - 爬虫
  - 数据采集
  - 教程
categories:
  - 技术
cover: https://images.unsplash.com/photo-1526379095098-d400fd0bf935?w=800&h=400&fit=crop
description: Python 爬虫从入门到实战，涵盖 requests、BeautifulSoup、Selenium 等工具，教你合法合规地采集网页数据。
keywords: Python爬虫, 网页爬虫, requests, BeautifulSoup, Selenium, 数据采集, Python教程
---

## 什么是网页爬虫？

网页爬虫是一种自动获取网页内容的程序。它可以帮助我们：

- 采集公开数据
- 监控价格变化
- 聚合信息内容
- 构建搜索引擎

<!-- more -->

## 准备工作

### 环境配置

```bash
# 创建虚拟环境
python -m venv venv
source venv/bin/activate  # Mac/Linux
# venv\Scripts\activate  # Windows

# 安装依赖
pip install requests beautifulsoup4 lxml
```

### 基本工具

| 库 | 用途 |
|---|------|
| requests | 发送 HTTP 请求 |
| BeautifulSoup | 解析 HTML |
| lxml | 高性能解析器 |
| Selenium | 动态页面爬取 |
| Scrapy | 爬虫框架 |

## 第一个爬虫

### 使用 requests 获取网页

```python
import requests

# 发送 GET 请求
url = 'https://httpbin.org/get'
response = requests.get(url)

# 检查状态码
print(response.status_code)  # 200

# 获取内容
print(response.text)  # HTML 内容
print(response.json())  # JSON 数据
```

### 设置请求头

```python
headers = {
    'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9',
    'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
}

response = requests.get(url, headers=headers)
```

### 处理参数和表单

```python
# GET 请求带参数
params = {'key': 'value', 'page': 1}
response = requests.get(url, params=params)

# POST 请求发送数据
data = {'username': 'user', 'password': 'pass'}
response = requests.post(url, data=data)

# 发送 JSON 数据
import json
response = requests.post(url, json={'key': 'value'})
```

## 解析 HTML

### BeautifulSoup 基础

```python
from bs4 import BeautifulSoup

html = '''
<html>
<head><title>示例页面</title></head>
<body>
    <h1 class="title">欢迎来到 BitMosaic Lab</h1>
    <div id="content">
        <p>这是第一段文字</p>
        <p>这是第二段文字</p>
        <a href="https://example.com">链接</a>
    </div>
    <ul class="list">
        <li>项目1</li>
        <li>项目2</li>
        <li>项目3</li>
    </ul>
</body>
</html>
'''

# 创建解析对象
soup = BeautifulSoup(html, 'lxml')

# 获取标题
print(soup.title.string)  # 示例页面

# 获取特定元素
h1 = soup.find('h1', class_='title')
print(h1.text)  # 欢迎来到 BitMosaic Lab

# 获取所有段落
paragraphs = soup.find_all('p')
for p in paragraphs:
    print(p.text)

# 获取链接
link = soup.find('a')
print(link['href'])  # https://example.com
print(link.text)  # 链接
```

### CSS 选择器

```python
# 使用 CSS 选择器
title = soup.select_one('h1.title')
items = soup.select('ul.list li')

for item in items:
    print(item.text)
```

## 实战：爬取新闻列表

```python
import requests
from bs4 import BeautifulSoup
import time

def fetch_news():
    """爬取新闻列表示例"""
    url = 'https://news.ycombinator.com/'
    headers = {
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)'
    }

    response = requests.get(url, headers=headers)
    soup = BeautifulSoup(response.text, 'lxml')

    # 查找新闻标题
    news_list = []
    items = soup.select('.titleline > a')

    for item in items[:10]:  # 只取前10条
        news = {
            'title': item.text,
            'link': item['href']
        }
        news_list.append(news)

    return news_list

# 运行爬虫
if __name__ == '__main__':
    news = fetch_news()
    for i, item in enumerate(news, 1):
        print(f"{i}. {item['title']}")
        print(f"   {item['link']}\n")
```

## 处理动态页面

### Selenium 基础

```python
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

# 创建浏览器实例
driver = webdriver.Chrome()

try:
    # 访问页面
    driver.get('https://example.com')

    # 等待元素加载
    element = WebDriverWait(driver, 10).until(
        EC.presence_of_element_located((By.ID, "content"))
    )

    # 获取内容
    content = driver.find_element(By.ID, "content")
    print(content.text)

    # 模拟点击
    button = driver.find_element(By.CLASS_NAME, "btn")
    button.click()

    # 输入文字
    input_field = driver.find_element(By.NAME, "search")
    input_field.send_keys("Python")

finally:
    driver.quit()
```

### 无头浏览器

```python
from selenium.webdriver.chrome.options import Options

# 配置无头模式
options = Options()
options.add_argument('--headless')
options.add_argument('--disable-gpu')
options.add_argument('--no-sandbox')

driver = webdriver.Chrome(options=options)
```

## 数据存储

### 保存为 JSON

```python
import json

data = [{'title': 'News 1'}, {'title': 'News 2'}]

# 保存
with open('data.json', 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

# 读取
with open('data.json', 'r', encoding='utf-8') as f:
    loaded_data = json.load(f)
```

### 保存为 CSV

```python
import csv

data = [
    {'title': 'News 1', 'link': 'https://...'},
    {'title': 'News 2', 'link': 'https://...'},
]

# 保存
with open('data.csv', 'w', newline='', encoding='utf-8') as f:
    writer = csv.DictWriter(f, fieldnames=['title', 'link'])
    writer.writeheader()
    writer.writerows(data)
```

### 保存到数据库

```python
import sqlite3

# 连接数据库
conn = sqlite3.connect('news.db')
cursor = conn.cursor()

# 创建表
cursor.execute('''
    CREATE TABLE IF NOT EXISTS news (
        id INTEGER PRIMARY KEY,
        title TEXT,
        link TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
''')

# 插入数据
cursor.execute(
    'INSERT INTO news (title, link) VALUES (?, ?)',
    ('News Title', 'https://...')
)

conn.commit()
conn.close()
```

## 反爬虫处理

### 常见反爬措施

1. **User-Agent 检测**
2. **IP 限制**
3. **验证码**
4. **登录验证**
5. **动态加载**

### 应对策略

```python
import random
import time

# 随机 User-Agent
user_agents = [
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36',
    'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36',
]

headers = {
    'User-Agent': random.choice(user_agents)
}

# 随机延迟
time.sleep(random.uniform(1, 3))

# 使用代理
proxies = {
    'http': 'http://proxy.example.com:8080',
    'https': 'https://proxy.example.com:8080',
}
response = requests.get(url, proxies=proxies)
```

## 爬虫框架 Scrapy

```python
# 安装
# pip install scrapy

# 创建项目
# scrapy startproject myproject

# spider 示例
import scrapy

class NewsSpider(scrapy.Spider):
    name = 'news'
    start_urls = ['https://example.com/news']

    def parse(self, response):
        for article in response.css('.article'):
            yield {
                'title': article.css('h2::text').get(),
                'link': article.css('a::attr(href)').get(),
            }

        # 翻页
        next_page = response.css('.next-page::attr(href)').get()
        if next_page:
            yield response.follow(next_page, self.parse)
```

## 最佳实践

### 1. 遵守规则

```python
import urllib.robotparser

# 检查 robots.txt
rp = urllib.robotparser.RobotFileParser()
rp.set_url('https://example.com/robots.txt')
rp.read()

# 检查是否允许爬取
can_fetch = rp.can_fetch('*', '/path/to/page')
```

### 2. 错误处理

```python
import requests
from requests.exceptions import RequestException

def safe_request(url, retries=3):
    for i in range(retries):
        try:
            response = requests.get(url, timeout=10)
            response.raise_for_status()
            return response
        except RequestException as e:
            print(f"请求失败 ({i+1}/{retries}): {e}")
            time.sleep(2 ** i)  # 指数退避
    return None
```

### 3. 日志记录

```python
import logging

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    filename='crawler.log'
)

logging.info('开始爬取...')
logging.error('请求失败')
```

## 法律与道德

1. **遵守 robots.txt**
2. **控制请求频率**
3. **不爬取敏感数据**
4. **遵守网站服务条款**
5. **合理使用数据**

## 总结

Python 爬虫开发要点：

- 使用 requests 发送请求
- 使用 BeautifulSoup 解析 HTML
- 使用 Selenium 处理动态页面
- 合理存储数据
- 遵守法律法规

## 推荐资源

- [Requests 文档](https://docs.python-requests.org/)
- [BeautifulSoup 文档](https://www.crummy.com/software/BeautifulSoup/bs4/doc/)
- [Scrapy 文档](https://docs.scrapy.org/)

---

有问题欢迎评论区讨论！
