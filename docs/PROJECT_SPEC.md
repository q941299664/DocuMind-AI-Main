# DocuMind-AI - AI 中台智能文档处理系统项目规范

> **文档版本**: v1.2
> **更新时间**: 2026-02-25
> **更新内容**: 新增 Git Flow 规范、进度跟踪机制及 Python Nacos 接入规范
> **适用对象**: 全栈开发工程师 (Trae)

---

## 1. 项目仓库管理策略

为了方便代码管理、独立部署，项目将拆分为 **1 个主控仓库** 和 **3 个应用仓库**。

### 1.1 仓库列表与地址

| 仓库标识 | 仓库名称 (建议) | 说明 | 技术栈 |
| :--- | :--- | :--- | :--- |
| **Main** | `DocuMind-AI-Main` | **主控仓库**。包含整体工程文档、部署脚本 (Docker/K8s)、全局配置、CI/CD 脚本。 | Markdown, Shell, YAML |
| **Backend** | `DocuMind-AI-Backend` | **后端仓库**。Spring Cloud 微服务集群，采用父子工程结构。 | Java, Spring Cloud |
| **Frontend** | `DocuMind-AI-Frontend` | **前端仓库**。React 客户端应用。 | React, TS, Ant Design X |
| **Python** | `DocuMind-AI-Python` | **算法仓库**。Python 算法服务集群 (解析/向量/重排)。 | Python, FastAPI, LangChain |

### 1.2 服务部署地址 (示例)

- **主页/演示**: `https://documind.your-domain.com`
- **API 文档**: `https://api.documind.your-domain.com/doc.html` (聚合 Swagger)
- **监控面板**: `https://monitor.documind.your-domain.com`

---

## 2. 后端项目结构 (DocuMind-AI-Backend)

后端采用 **Spring Cloud Alibaba / Spring Cloud** 微服务架构，严格遵循 **Maven 多模块 (父子工程)** 设计。

### 2.1 模块分层设计原则

- **分层治理**: 基础依赖 -> 通用组件 -> 基础设施 -> 业务服务。
- **业务隔离**: 每个业务域独立为一个父模块。
- **三层架构**: 每个业务服务拆分为 `api` (契约), `service` (业务), `server` (启动/Web)。

### 2.2 目录结构树

```text
DocuMind-AI-Backend/
├── documind-dependencies/         # [工程] 统一依赖管理 (BOM)
│   └── pom.xml                    # 锁定 Spring Boot, Cloud, Alibaba 及第三方包版本
├── documind-common/               # [工程] 通用模块集合 (工具/基类)
│   ├── documind-common-core/      # 核心工具 (Result, Exception, Utils)
│   ├── documind-common-redis/     # 缓存配置 (RedisTemplate)
│   ├── documind-common-web/       # Web 通用 (GlobalExceptionHandler, Jackson)
│   ├── documind-common-security/  # 安全组件 (UserContext, Token解析)
│   ├── documind-common-database/  # 数据源配置 (MyBatis Plus/JPA)
│   └── documind-common-swagger/   # 接口文档配置
├── documind-infrastructure/       # [工程] 基础设施服务
│   ├── documind-gateway/          # 网关服务 (Gateway, Filter, Limiter)
│   └── documind-auth/             # 认证中心 (Oauth2/JWT)
├── documind-modules/              # [工程] 业务服务聚合
│   ├── documind-system/           # [业务] 系统与用户服务
│   │   ├── documind-system-api/     # DTO, Feign Client (供外部依赖)
│   │   ├── documind-system-service/ # Domain, Repository, Service Impl (业务逻辑)
│   │   └── documind-system-server/  # Controller, Application (启动入口, 依赖 api+service)
│   ├── documind-document/         # [业务] 文档管理服务
│   │   ├── documind-document-api/
│   │   ├── documind-document-service/
│   │   └── documind-document-server/
│   ├── documind-ai/               # [业务] AI 核心服务 (RAG, Chat)
│   │   ├── documind-ai-api/
│   │   ├── documind-ai-service/
│   │   └── documind-ai-server/
│   └── documind-search/           # [业务] 搜索服务
│       ├── documind-search-api/
│       ├── documind-search-service/
│       └── documind-search-server/
└── pom.xml                        # 根 POM (聚合所有子模块)
```

### 2.3 模块依赖关系详解

1. **Dependencies (BOM)**:
    - 位于最底层，只包含 `pom.xml`。
    - 管理 `spring-boot-dependencies`, `spring-cloud-dependencies`, `lombok`, `hutool` 等所有版本号。
    - 所有其他模块在 `<dependencyManagement>` 中引入此模块。

2. **Common (通用)**:
    - `common-core`: 纯 Java 工具，不依赖 Web/DB 容器。
    - `common-web`: 依赖 `spring-boot-starter-web`，提供统一响应封装。

3. **业务模块内部依赖 (以 System 为例)**:
    - **Api 工程 (`system-api`)**:
        - 存放：DTO (Data Transfer Object), VO (View Object), Feign Client 接口定义。
        - 依赖：`common-core`。
        - 作用：暴露给其他微服务引用的“契约包”。
    - **Service 工程 (`system-service`)**:
        - 存放：Entity, Mapper/Repository, Service 接口与实现, 业务逻辑。
        - 依赖：`system-api` (使用 DTO), `common-database`, `common-redis`。
        - 作用：核心业务逻辑层。
    - **Server 工程 (`system-server`)**:
        - 存放：Controller, Bootstrap (启动类), Configuration (配置类)。
        - 依赖：`system-api`, `system-service`, `common-web`, `common-security`。
        - 作用：服务的**部署单元**，负责 HTTP 请求处理和应用启动。

---

## 3. 前端项目结构 (DocuMind-AI-Frontend)

独立仓库，专注于 UI/UX 交互。

```text
DocuMind-AI-Frontend/
├── public/
├── src/
│   ├── api/                 # API 接口定义 (对应后端的 Controller)
│   │   ├── system/
│   │   ├── document/
│   │   └── ai/
│   ├── assets/
│   ├── components/          # 通用组件
│   │   ├── Business/        # 业务组件 (如 PdfViewer, ChatWindow)
│   │   └── Common/          # 基础组件
│   ├── config/              # 全局配置
│   ├── hooks/
│   ├── layouts/
│   ├── pages/
│   ├── store/               # 状态管理 (Redux/Zustand)
│   ├── types/               # TS 类型定义 (对应后端的 DTO)
│   └── utils/
├── .env.development
├── .env.production
├── package.json
└── vite.config.ts
```

---

## 4. Python 服务结构 (DocuMind-AI-Python)

独立仓库，专注于计算密集型任务 (AI/OCR)。

```text
DocuMind-AI-Python/
├── common/                  # 共享工具 (Log, Config, Nacos Client)
├── services/
│   ├── pdf-parser/          # [服务] PDF 解析器
│   │   ├── core/            # 解析逻辑 (PyMuPDF)
│   │   ├── api/             # FastAPI 路由
│   │   └── worker/          # Celery/RabbitMQ 消费者
│   ├── vector-engine/       # [服务] 向量化引擎
│   │   ├── core/            # LangChain, Embedding Models
│   │   └── worker/
│   └── ranker/              # [服务] 重排服务 (Rerank)
├── docker/                  # 各服务 Dockerfile
├── requirements.txt         # 基础依赖
└── main.py                  # 调试入口
```

---

## 5. 主控仓库结构 (DocuMind-AI-Main)

用于管理整个生态，不包含具体业务代码。

```text
DocuMind-AI-Main/
├── docs/                    # 项目文档
│   ├── architecture/        # 架构图
│   ├── database/            # SQL 脚本, ER 图
│   ├── api/                 # 接口文档导出
│   └── templates/           # 规范模板 (PR, Progress)
├── deploy/                  # 部署脚本
│   ├── docker-compose/      # 本地/开发环境编排
│   │   ├── base.yml         # 基础中间件 (MySQL, Redis, MQ, ES)
│   │   └── app.yml          # 应用服务
│   └── nginx/               # 反向代理配置
├── scripts/                 # 运维脚本
│   ├── init-env.sh          # 环境初始化
│   └── build-all.sh         # 一键构建所有仓库
├── README.md                # 项目总览 (包含子仓库链接)
└── LICENSE
```

---

## 6. 开发与协作流程

1. **环境准备**: 在 `Main` 仓库中运行 `docker-compose up -d base` 启动基础中间件。
2. **后端开发**: 打开 `Backend` 仓库，启动 `Gateway` 和目标业务模块的 `Server` 工程。
3. **前端开发**: 打开 `Frontend` 仓库，连接本地 Gateway (localhost:8080)。
4. **Python 开发**: 打开 `Python` 仓库，启动对应的 Worker 或 API 服务。

---

## 7. 关键技术选型补充

- **注册中心/配置中心**: Nacos 2.x (支持 Java/Python 多语言接入)
- **服务调用**: OpenFeign (内部), RestTemplate/WebClient (外部)
- **网关**: Spring Cloud Gateway
- **熔断限流**: Sentinel
- **分布式事务**: Seata (按需)
- **链路追踪**: SkyWalking / Micrometer Tracing

---

## 8. Git Flow 多仓库管理规范

为确保多仓库协作的顺畅与代码质量，本项目严格遵循 Git Flow 工作流，并针对微服务架构特点制定以下管理方案。

### 8.1 仓库初始化策略

#### 8.1.1 仓库创建与依赖顺序

为避免循环依赖和环境配置混乱，需严格按照以下顺序初始化仓库：

1. **Stage 1: 主控仓库 (Main)** `DocuMind-AI-Main`
    - **时机**: 项目启动第一天。
    - **内容**: 全局文档、Docker 编排脚本、CI/CD 配置、数据库初始化脚本。
    - **目的**: 确立基础设施，所有后续服务依赖此环境运行。

2. **Stage 2: 核心服务仓库 (Backend & Python)** `DocuMind-AI-Backend`, `DocuMind-AI-Python`
    - **时机**: 基础设施搭建完成后 (MySQL/Redis/Nacos 可用)。
    - **内容**: 后端微服务脚手架、Python 算法服务骨架。
    - **目的**: 定义 API 契约，打通服务间调用。

3. **Stage 3: 前端仓库 (Frontend)** `DocuMind-AI-Frontend`
    - **时机**: 后端 API 契约定义完成 (Swagger 可访问) 后。
    - **内容**: React 脚手架、API Client 生成。
    - **目的**: 基于真实接口开发 UI，减少 Mock 工作量。

### 8.2 Git Flow 工作流详解

所有仓库统一采用标准 Git Flow 模型，分支管理规则如下：

#### 8.2.1 分支定义与生命周期

| 分支类型 | 命名规范 | 以此为基准 | 合并回 | 说明 |
| :--- | :--- | :--- | :--- | :--- |
| **Main** | `main` | - | - | **生产分支**。永远处于可部署状态 (Stable)。仅允许从 release 或 hotfix 合并。打 Tag (v1.0.0)。 |
| **Develop** | `develop` | `main` | - | **开发主干**。包含最新完成功能的代码 (Nightly)。所有 Feature 分支最终合并于此。 |
| **Feature** | `feature/<功能名>` | `develop` | `develop` | **功能分支**。用于开发新功能。例: `feature/user-login`, `feature/pdf-parser`。开发完成后提 PR 合并回 develop 并删除。 |
| **Release** | `release/v<版本号>` | `develop` | `main`, `develop` | **发布分支**。当 develop 积累了足够的特性，准备发布新版本时创建。只修 Bug，不加新功能。测试通过后合并。 |
| **Hotfix** | `hotfix/v<版本号>` | `main` | `main`, `develop` | **热修复分支**。用于修复生产环境紧急 Bug。例: `hotfix/v1.0.1`。修复后立即发布并同步回开发分支。 |

#### 8.2.2 合并窗口与规则

- **Feature -> Develop**: 随时可合并，必须通过 CI 单元测试。
- **Develop -> Release**: 每两周 (Sprint 结束) 冻结一次 Develop，创建 Release 分支进行集成测试。
- **Release -> Main**: 测试通过并通过验收后，于发布窗口 (通常为周四晚) 合并。

### 8.3 版本号策略 (SemVer)

严格遵循 **Semantic Versioning 2.0.0** (X.Y.Z)：

- **X (Major)**: 主版本号。架构升级或不兼容的 API 修改。
- **Y (Minor)**: 次版本号。向下兼容的功能性新增。
- **Z (Patch)**: 修订号。向下兼容的问题修正。

**里程碑规划**:

- `v0.1.0` (Alpha): 核心架构跑通，Hello World 级别服务互通。
- `v0.5.0` (Beta): 完成 MVP 所有功能，进入内部测试。
- `v1.0.0` (GA): 首个正式生产版本。

### 8.4 代码评审与 CI 门禁

所有代码合并必须通过 Pull Request (PR) / Merge Request (MR) 进行。

1. **PR 模板**: 提交 PR 时必须填写标准模板 (见 `docs/templates/PULL_REQUEST_TEMPLATE.md`)，说明变更内容、测试结果。
2. **Code Review Checklist**:
    - [ ] 代码风格符合规范 (Linter 通过)。
    - [ ] 核心逻辑有单元测试覆盖。
    - [ ] 无硬编码 (Hardcode) 配置，使用配置中心。
    - [ ] 敏感信息 (密码/Key) 未提交到仓库。
3. **CI 门禁 (自动化)**:
    - PR 提交后自动触发 Build 和 Unit Test。
    - **Blocker**: 如果 CI 失败，禁止合并。

---

## 9. 首期核心功能清单 (MVP) 与验收标准

### 9.1 里程碑目标: v0.5.0 (MVP)

**目标**: 实现完整的文档上传、解析、向量化与基础问答流程。

### 9.2 功能清单与优先级

| 模块 | 功能点 | 优先级 | 验收标准 (DoD) |
| :--- | :--- | :--- | :--- |
| **Backend** | 用户认证 | P0 | 支持账号注册登录，接口需 JWT 鉴权。 |
| **Backend** | 文档上传 | P0 | 支持 PDF 上传至 MinIO，记录元数据到 MySQL。 |
| **Python** | PDF 解析 | P0 | 能解析纯文本 PDF，提取文本内容，保留段落结构。 |
| **Python** | 向量化 | P0 | 将文本块转换为向量并存入向量数据库 (Elasticsearch/Milvus)。 |
| **Frontend** | 文档管理 | P1 | 用户可查看已上传文档列表，状态实时更新 (解析中/完成)。 |
| **Frontend** | 简单问答 | P1 | 提供对话框，用户提问后能返回基于文档的答案。 |
| **Main** | 一键部署 | P0 | `docker-compose up` 可拉起所有服务，无报错。 |

---

## 10. 开发进度跟踪与协作机制

### 10.1 跟踪文档体系

为保证多仓库协作透明，建立统一的进度跟踪机制。

- **进度跟踪表**: 使用标准模板 `docs/templates/PROGRESS_TRACKING_TEMPLATE.md`。
- **存放位置**: `DocuMind-AI-Main/docs/management/progress/` (按周或里程碑归档)。
- **维护责任人**: 技术负责人 (Tech Lead) 或 当周值班长。

### 10.2 协作流程

1. **任务分解**: 每周初将 Story 拆解为 Task，录入进度表，指派给个人。
2. **每日同步**:
    - 更新进度表中的 "实际工时" 和 "状态"。
    - 识别并记录风险到 "风险登记册"。
3. **燃尽图更新**: 每周五统计剩余工作量，绘制/更新燃尽图数据。

### 10.3 风险管理

- 任何可能导致延期的技术难点或资源问题，必须在每日站会提出并记录在案。
- 风险等级高 (High) 的问题需在 24 小时内制定缓解措施。

---

## 11. Python 服务接入 Nacos 规范

为实现多语言微服务架构，Python 算法服务 (`DocuMind-AI-Python`) 需接入 Nacos 注册中心，以便 Java 后端通过 OpenFeign 或 RestTemplate 进行服务发现与调用。

### 11.1 依赖与配置

1. **依赖库**: 使用 `nacos-sdk-python`。

    ```text
    nacos-sdk-python>=0.1.12
    ```

2. **配置文件**: 在 `.env` 或 `common/config.py` 中配置 Nacos 地址。

    ```python
    NACOS_SERVER_ADDR = "127.0.0.1:8848"
    NACOS_NAMESPACE = ""  # public
    SERVICE_NAME = "documind-ai-python"
    ```

### 11.2 服务注册流程

- **启动时 (Startup)**: Python 服务启动 FastAPI 应用时，通过 `lifespan` 事件自动向 Nacos 注册临时实例 (Ephemeral Instance)。
  - 注册信息包含: `IP`, `Port`, `Service Name`, `Cluster Name` (默认 DEFAULT)。
- **运行时 (Runtime)**: 客户端会自动发送心跳维持连接。
- **关闭时 (Shutdown)**: 服务停止时，必须显式调用注销接口，从 Nacos 移除实例，避免无效调用。

### 11.3 服务间调用约定

- **Java 调用 Python**:
  - Java 端通过 `documind-ai-python` 服务名查找实例列表。
  - 使用 LoadBalancer 选择实例发起 HTTP 请求。
- **Python 回调 Java**:
  - Python 任务完成后，通过 Nacos 获取 Java 后端服务 (`documind-system` 或 `documind-document`) 的实例地址。
  - 通过 HTTP POST 回调通知任务状态 (如: 解析完成、向量化进度)。

### 11.4 异常处理

- 若 Nacos 连接失败，Python 服务应降级启动 (记录 Error 日志)，但不应导致进程崩溃，以允许本地调试。
