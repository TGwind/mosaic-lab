---
title: 从零构建 AI 智能体：LLM Agent 架构设计实战
date: 2026-01-27 10:00:00
tags:
  - AI
  - LLM
  - Agent
  - RAG
  - Python
categories:
  - AI
cover: https://images.unsplash.com/photo-1677442136019-21780ecad995?w=800&h=400&fit=crop
description: 深入解析 AI 智能体的架构设计与实现，涵盖 ReAct 模式、工具调用、记忆系统、RAG 检索增强等核心模块，附完整 Python 代码。
keywords: AI Agent, LLM Agent, 智能体开发, ReAct, RAG, LangChain, 大语言模型, AI应用开发
---

## 什么是 AI 智能体（Agent）？

AI 智能体是一个能够**感知环境、做出决策、执行行动**的自主系统。与传统的 ChatBot 不同，Agent 不仅能对话，还能调用工具、检索知识、分解任务，自主完成复杂目标。

<!-- more -->

## Agent 的核心架构

一个完整的 AI Agent 通常包含四个核心模块：

```
┌─────────────────────────────────────┐
│              AI Agent               │
├──────────┬──────────┬───────────────┤
│  🧠 大脑  │  🔧 工具  │  💾 记忆      │
│  (LLM)   │ (Tools)  │  (Memory)    │
├──────────┴──────────┴───────────────┤
│           📚 知识库 (RAG)            │
└─────────────────────────────────────┘
```

| 模块 | 作用 | 技术 |
|------|------|------|
| 大脑 | 推理与决策 | GPT-4 / Claude / Llama |
| 工具 | 执行具体操作 | API 调用、代码执行、搜索 |
| 记忆 | 保持上下文 | 短期记忆 + 长期记忆 |
| 知识库 | 检索专业知识 | 向量数据库 + RAG |

## ReAct 模式：思考-行动循环

ReAct（Reasoning + Acting）是最经典的 Agent 设计模式。

### 工作流程

```
用户输入 → 思考(Thought) → 行动(Action) → 观察(Observation) → 思考 → ... → 最终回答
```

### 实现代码

```python
from openai import OpenAI

client = OpenAI()

SYSTEM_PROMPT = """你是一个智能助手，可以使用以下工具：

1. search(query) - 搜索互联网信息
2. calculate(expression) - 计算数学表达式
3. get_weather(city) - 查询天气

请按照以下格式回答：
Thought: 我需要思考如何解决这个问题
Action: tool_name(parameters)
Observation: 工具返回的结果
... (可以重复多次)
Answer: 最终答案
"""

def run_agent(user_input: str, max_steps: int = 5):
    messages = [
        {"role": "system", "content": SYSTEM_PROMPT},
        {"role": "user", "content": user_input}
    ]

    for step in range(max_steps):
        response = client.chat.completions.create(
            model="gpt-4",
            messages=messages
        )

        assistant_msg = response.choices[0].message.content

        # 检查是否有最终答案
        if "Answer:" in assistant_msg:
            return assistant_msg.split("Answer:")[-1].strip()

        # 解析并执行工具调用
        if "Action:" in assistant_msg:
            action = parse_action(assistant_msg)
            observation = execute_tool(action)

            messages.append({"role": "assistant", "content": assistant_msg})
            messages.append({"role": "user", "content": f"Observation: {observation}"})

    return "无法完成任务"
```

## 工具系统设计

### 定义工具

```python
from typing import Callable
from dataclasses import dataclass

@dataclass
class Tool:
    name: str
    description: str
    function: Callable
    parameters: dict

class ToolRegistry:
    def __init__(self):
        self.tools: dict[str, Tool] = {}

    def register(self, name: str, description: str, parameters: dict):
        def decorator(func):
            self.tools[name] = Tool(name, description, func, parameters)
            return func
        return decorator

    def execute(self, name: str, **kwargs):
        if name not in self.tools:
            return f"未知工具: {name}"
        return self.tools[name].function(**kwargs)

    def get_descriptions(self) -> str:
        return "\n".join(
            f"- {t.name}: {t.description}" for t in self.tools.values()
        )

# 使用示例
registry = ToolRegistry()

@registry.register(
    name="search",
    description="搜索互联网获取最新信息",
    parameters={"query": "搜索关键词"}
)
def search(query: str) -> str:
    # 实际实现搜索逻辑
    return f"搜索结果: {query}"

@registry.register(
    name="calculate",
    description="计算数学表达式",
    parameters={"expression": "数学表达式"}
)
def calculate(expression: str) -> str:
    try:
        result = eval(expression)
        return str(result)
    except Exception as e:
        return f"计算错误: {e}"
```

## 记忆系统

### 短期记忆：对话上下文

```python
class ShortTermMemory:
    def __init__(self, max_messages: int = 20):
        self.messages: list[dict] = []
        self.max_messages = max_messages

    def add(self, role: str, content: str):
        self.messages.append({"role": role, "content": content})
        # 保留最近的消息，防止超出 token 限制
        if len(self.messages) > self.max_messages:
            self.messages = self.messages[-self.max_messages:]

    def get_context(self) -> list[dict]:
        return self.messages.copy()
```

### 长期记忆：向量存储

```python
import chromadb
from sentence_transformers import SentenceTransformer

class LongTermMemory:
    def __init__(self, collection_name: str = "agent_memory"):
        self.client = chromadb.Client()
        self.collection = self.client.get_or_create_collection(collection_name)
        self.encoder = SentenceTransformer('all-MiniLM-L6-v2')

    def store(self, content: str, metadata: dict = None):
        embedding = self.encoder.encode(content).tolist()
        self.collection.add(
            documents=[content],
            embeddings=[embedding],
            metadatas=[metadata or {}],
            ids=[f"mem_{self.collection.count()}"]
        )

    def recall(self, query: str, top_k: int = 5) -> list[str]:
        embedding = self.encoder.encode(query).tolist()
        results = self.collection.query(
            query_embeddings=[embedding],
            n_results=top_k
        )
        return results['documents'][0]
```

## RAG 检索增强

RAG（Retrieval-Augmented Generation）让 Agent 能够基于私有知识库回答问题。

```python
class RAGModule:
    def __init__(self, docs_path: str):
        self.client = chromadb.Client()
        self.collection = self.client.get_or_create_collection("knowledge_base")
        self.encoder = SentenceTransformer('all-MiniLM-L6-v2')
        self._index_documents(docs_path)

    def _index_documents(self, path: str):
        """将文档分块并建立索引"""
        # 读取文档
        documents = load_documents(path)

        for i, doc in enumerate(documents):
            # 分块
            chunks = self._split_text(doc, chunk_size=500, overlap=50)
            for j, chunk in enumerate(chunks):
                embedding = self.encoder.encode(chunk).tolist()
                self.collection.add(
                    documents=[chunk],
                    embeddings=[embedding],
                    ids=[f"doc_{i}_chunk_{j}"]
                )

    def retrieve(self, query: str, top_k: int = 3) -> str:
        """检索相关文档片段"""
        embedding = self.encoder.encode(query).tolist()
        results = self.collection.query(
            query_embeddings=[embedding],
            n_results=top_k
        )

        context = "\n\n".join(results['documents'][0])
        return context

    @staticmethod
    def _split_text(text: str, chunk_size: int, overlap: int) -> list[str]:
        chunks = []
        start = 0
        while start < len(text):
            end = start + chunk_size
            chunks.append(text[start:end])
            start = end - overlap
        return chunks
```

## 完整 Agent 实现

```python
class MosaicAgent:
    """Mosaic Lab AI Agent"""

    def __init__(self, model: str = "gpt-4"):
        self.model = model
        self.client = OpenAI()
        self.tools = ToolRegistry()
        self.short_memory = ShortTermMemory()
        self.long_memory = LongTermMemory()
        self.rag = None

    def load_knowledge(self, docs_path: str):
        """加载知识库"""
        self.rag = RAGModule(docs_path)

    def chat(self, user_input: str) -> str:
        # 1. 检索相关知识
        context = ""
        if self.rag:
            context = self.rag.retrieve(user_input)

        # 2. 回忆相关记忆
        memories = self.long_memory.recall(user_input, top_k=3)

        # 3. 构建提示
        system_prompt = self._build_prompt(context, memories)

        # 4. 添加到短期记忆
        self.short_memory.add("user", user_input)

        # 5. 调用 LLM
        messages = [{"role": "system", "content": system_prompt}]
        messages.extend(self.short_memory.get_context())

        response = self.client.chat.completions.create(
            model=self.model,
            messages=messages
        )

        answer = response.choices[0].message.content

        # 6. 保存到记忆
        self.short_memory.add("assistant", answer)
        self.long_memory.store(
            f"Q: {user_input}\nA: {answer}",
            metadata={"type": "conversation"}
        )

        return answer

    def _build_prompt(self, context: str, memories: list) -> str:
        prompt = "你是 Mosaic Lab 的 AI 助手。\n\n"

        if context:
            prompt += f"参考知识：\n{context}\n\n"

        if memories:
            prompt += f"相关历史：\n" + "\n".join(memories) + "\n\n"

        prompt += f"可用工具：\n{self.tools.get_descriptions()}"

        return prompt
```

## 实际应用场景

### 1. 广告投放助手

```python
@registry.register("analyze_campaign", "分析广告投放效果", {})
def analyze_campaign(campaign_id: str) -> str:
    # 调用广告平台 API 获取数据
    # 分析 CTR、CVR、ROI 等指标
    # 生成优化建议
    pass
```

### 2. 数据分析 Agent

```python
@registry.register("query_database", "执行 SQL 查询", {})
def query_database(sql: str) -> str:
    # 安全执行 SQL 查询
    # 返回结构化结果
    pass
```

### 3. 内容生成 Agent

```python
@registry.register("generate_ad_copy", "生成广告文案", {})
def generate_ad_copy(product: str, audience: str) -> str:
    # 根据产品和目标人群生成文案
    pass
```

## 最佳实践

1. **明确边界**：定义 Agent 的能力范围，避免过度承诺
2. **安全第一**：对工具调用做严格的输入验证
3. **可观测性**：记录每一步的推理过程和工具调用
4. **降级策略**：当 Agent 无法完成任务时，优雅地交给人工
5. **迭代优化**：根据实际使用反馈持续改进 Prompt 和工具

## 推荐技术栈

| 组件 | 推荐 |
|------|------|
| LLM | OpenAI GPT-4 / Claude |
| 框架 | LangChain / LlamaIndex |
| 向量数据库 | ChromaDB / Pinecone |
| Embedding | OpenAI / Sentence-Transformers |
| 部署 | FastAPI + Docker |

## 总结

AI Agent 的核心在于：

- **推理能力**：利用 LLM 的推理和规划能力
- **工具使用**：通过工具扩展 Agent 的能力边界
- **知识增强**：RAG 让 Agent 具备专业领域知识
- **记忆机制**：短期 + 长期记忆，让 Agent 具有连续性

---

下一篇我会分享如何将 AI Agent 应用在数字化广告营销场景中。

有问题欢迎评论交流！
