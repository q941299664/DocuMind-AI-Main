# DocuMind-AI MVP 功能开发清单 (v0.5.0)

本文档作为全栈开发的 **Master Checklist**，涵盖从基础设施到业务闭环的所有关键功能点。请在开发过程中实时更新状态。

> **状态图例**:
>
> - [ ] 待开发 (Pending)
> - [x] 已完成 (Done)
> - [-] 已废弃 (Dropped)

---

## 1. 基础设施与 DevOps (Main)

### 1.1 环境编排

- [x] **Docker Compose 基础环境**: MySQL, Redis, Nacos, MinIO, Elasticsearch/Milvus。
- [ ] **Nginx 反向代理**: 配置前端静态资源代理与 API 转发。
- [ ] **初始化脚本**: 数据库表结构初始化 (SQL), MinIO Bucket 创建。

### 1.2 项目规范

- [x] **多仓库结构拆分**: Main, Backend, Frontend, Python。
- [x] **Git Flow 规范**: 分支管理策略与保护规则。
- [x] **开发文档**: 部署指南, 架构图, 进度跟踪模板。

---

## 2. 后端服务 (Backend - Java)

### 2.1 基础架构 (Common/Infra)

- [x] **统一依赖管理 (BOM)**: Spring Boot 3.x, Spring Cloud Alibaba 2022.x。
- [x] **统一响应封装**: `Result<T>`, `ResultCode`, `GlobalExceptionHandler`。
- [ ] **网关服务 (Gateway)**:
  - [ ] 路由转发配置 (Forwarding)。
  - [ ] 全局跨域处理 (CORS)。
  - [ ] 统一鉴权过滤器 (AuthFilter)。
- [ ] **认证中心 (Auth)**:
  - [ ] JWT Token 生成与解析。
  - [ ] Spring Security 配置。
  - [ ] 用户上下文 (`UserContext`) 传递。

### 2.2 系统服务 (System)

- [ ] **用户管理**:
  - [ ] 用户注册/登录接口。
  - [ ] 用户信息查询/修改。
- [ ] **角色权限**: RBAC 基础表结构与查询。

### 2.3 文档服务 (Document)

- [ ] **文件存储**:
  - [ ] 集成 MinIO SDK。
  - [ ] 文件上传接口 (MultipartFile)。
  - [ ] 文件下载/预览链接生成。
- [ ] **文档管理**:
  - [ ] 文档元数据表 (MySQL)。
  - [ ] 文档列表查询 (分页/筛选)。
  - [ ] 文档状态流转 (上传中 -> 解析中 -> 索引中 -> 完成)。

### 2.4 AI 聚合服务 (AI)

- [ ] **RAG 流程编排**:
  - [ ] 调用 Python 服务进行解析 (Feign)。
  - [ ] 调用 Python 服务进行向量化/检索 (Feign)。
  - [ ] 对接 LLM (OpenAI/DeepSeek) 生成回答。
- [ ] **对话管理**:
  - [ ] 会话 (Session) 创建与历史记录存储。
  - [ ] SSE (Server-Sent Events) 流式响应接口。

---

## 3. 前端应用 (Frontend - React)

### 3.1 基础框架

- [x] **脚手架**: Vite + React + TS + Tailwind CSS。
- [x] **UI 组件库**: Ant Design 5.x + Ant Design X (AI 组件)。
- [x] **路由配置**: React Router v6, 布局组件 (Layout)。
- [ ] **网络请求**: Axios 封装 (拦截器处理 Token/全局错误)。
- [ ] **状态管理**: Zustand/Redux Toolkit (用户信息, 全局配置)。

### 3.2 核心页面

- [ ] **登录/注册页**: 表单验证, Token 存储。
- [x] **首页/工作台**: 基础布局已完成。
- [ ] **文档中心**:
  - [ ] 上传组件 (拖拽上传, 进度条)。
  - [ ] 文档列表 (Table), 状态徽标。
- [ ] **AI 对话页**:
  - [ ] 聊天窗口 (Bubble List)。
  - [ ] 输入框 (Sender), 流式打字机效果。
  - [ ] 引用来源展示 (Reference)。

---

## 4. 算法服务 (Python)

### 4.1 基础架构

- [x] **服务骨架**: FastAPI + Uvicorn。
- [ ] **服务注册**: 接入 Nacos (nacos-sdk-python)。
- [ ] **异步任务**: Celery + Redis (处理耗时任务)。

### 4.2 核心算法

- [ ] **PDF 解析器**:
  - [ ] PyMuPDF (fitz) 提取文本。
  - [ ] 文本分块 (RecursiveCharacterTextSplitter)。
- [ ] **向量引擎**:
  - [ ] Embedding 模型加载 (HuggingFace/OpenAI)。
  - [ ] 向量数据库写入/检索 (Elasticsearch/Milvus)。
- [ ] **重排服务 (Rerank)**:
  - [ ] BGE-Reranker 模型集成 (可选)。

---

## 5. 验收标准 (DoD)

- [ ] **全流程跑通**: 用户登录 -> 上传 PDF -> 解析成功 -> 提问 -> 返回基于 PDF 的答案。
- [ ] **一键部署**: `docker-compose up` 可拉起所有服务且无报错。
- [ ] **文档完整**: 包含操作手册与 API 文档。
