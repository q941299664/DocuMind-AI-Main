# DocuMind AI

[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE)
[![Build Status](https://img.shields.io/badge/build-passing-brightgreen.svg)](https://github.com/your-org/documind-ai)

**DocuMind AI** 是一个企业级智能文档处理中台，致力于释放文档价值，重塑知识边界。它集成了先进的文档解析技术、RAG（检索增强生成）架构以及大语言模型，助您轻松构建企业专属知识大脑。

## 🚀 项目愿景

打造开箱即用、高性能、可扩展的智能文档处理平台，解决企业在文档管理、知识检索、智能问答等场景下的核心痛点。

## 📂 仓库结构

本项目采用多仓库管理模式，核心仓库如下：

| 仓库名称 | 说明 | 技术栈 |
| :--- | :--- | :--- |
| **[DocuMind-AI-Main](https://github.com/q941299664/DocuMind-AI-Main)** | 主仓库 | 项目文档、部署脚本、公共资源 |
| **[DocuMind-AI-Backend](https://github.com/q941299664/DocuMind-AI-Backend)** | 后端服务 | Java 21, Spring Cloud Alibaba, Nacos, MySQL, Redis |
| **[DocuMind-AI-Frontend](https://github.com/q941299664/DocuMind-AI-Frontend)** | 前端应用 | React 18, TypeScript, Vite, Ant Design, Tailwind CSS |
| **[DocuMind-AI-Python](https://github.com/q941299664/DocuMind-AI-Python)** | AI 核心服务 | Python 3.10+, PyTorch, LangChain, OCR, LLM |

## ✨ 核心特性

- **智能文档解析**：支持 PDF、Word、Excel 等多格式文档的高精度解析，自动提取文本、表格、图像。
- **语义检索增强**：基于 RAG 技术，结合向量数据库，提供精准的语义检索能力，拒绝大模型幻觉。
- **AI 问答助手**：集成流式对话体验，支持多轮对话、思维链展示，提供智能化的文档问答服务。
- **知识库管理**：灵活的知识库构建与管理，支持文档分块、索引优化、版本控制。
- **微服务架构**：基于 Spring Cloud Alibaba 构建，具备高可用、易扩展的特性。

## 🛠️ 快速开始

### 前置依赖

- JDK 21+
- Node.js 18+
- Python 3.10+
- Docker & Docker Compose
- MySQL 8.0+
- Redis 7.0+
- Nacos 2.x

### 部署步骤

请参考 [部署文档](docs/DEPLOY.md) 进行详细配置。

简单启动（Docker Compose）：

```bash
cd deploy/docker-compose
docker-compose up -d
```

## 📝 文档中心

- [项目规范](docs/PROJECT_SPEC.md)
- [API 文档](docs/API.md) (待补充)
- [架构设计](docs/ARCHITECTURE.md) (待补充)

## 🤝 贡献指南

欢迎提交 Issue 和 Pull Request！请参考 [贡献规范](docs/CONTRIBUTING.md)。

## 📄 开源协议

本项目采用 [Apache 2.0 协议](LICENSE)。
