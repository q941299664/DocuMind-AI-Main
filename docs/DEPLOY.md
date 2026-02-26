# DocuMind-AI 部署指南

本文档详细说明 DocuMind-AI 项目的本地开发环境搭建、服务端部署及容器化部署流程。

## 1. 环境准备

### 1.1 基础软件依赖

在开始部署前，请确保您的服务器或开发机已安装以下软件：

| 软件 | 版本要求 | 说明 |
| :--- | :--- | :--- |
| **JDK** | 17+ | 后端运行环境 (推荐 OpenJDK 17) |
| **Node.js** | 18+ | 前端构建环境 (推荐使用 nvm 管理) |
| **Python** | 3.10+ | AI 服务运行环境 (推荐使用 Conda) |
| **Docker** | 20.10+ | 容器化部署必备 |
| **Docker Compose** | 2.0+ | 服务编排工具 |
| **Maven** | 3.8+ | Java 项目构建工具 |

### 1.2 中间件依赖

项目依赖以下中间件服务，建议通过 Docker Compose 快速启动：

| 中间件 | 版本 | 默认端口 | 说明 |
| :--- | :--- | :--- | :--- |
| **MySQL** | 8.0 | 3306 | 核心业务数据存储 |
| **Redis** | 6.2+ | 6379 | 缓存与分布式锁 |
| **Nacos** | 2.2+ | 8848 | 注册中心与配置中心 |
| **MinIO** | Latest | 9000/9001 | 对象存储 (文件上传) |
| **Elasticsearch** | 7.17+ | 9200 | 全文检索与向量存储 (可选 Milvus) |

---

## 2. 本地开发环境搭建

### 2.1 启动基础中间件

进入 `DocuMind-AI-Main` 仓库的部署目录，启动基础服务：

```bash
cd DocuMind-AI-Main/deploy/docker-compose
docker-compose -f base.yml up -d
```

*注：请确保 3306, 6379, 8848 等端口未被占用。首次启动需等待 MySQL 初始化完成。*

### 2.2 后端服务启动 (DocuMind-AI-Backend)

1. **导入项目**: 使用 IntelliJ IDEA 打开 `DocuMind-AI-Backend`。
2. **配置 Nacos**: 修改 `documind-common/documind-common-config/src/main/resources/bootstrap.yml` (或对应服务的配置)，指向本地 Nacos (localhost:8848)。
3. **启动顺序**:
    1. `documind-gateway` (网关服务 - 端口 8080)
    2. `documind-auth` (认证服务)
    3. `documind-system-server` (系统服务)
    4. `documind-document-server` (文档服务)

### 2.3 前端服务启动 (DocuMind-AI-Frontend)

```bash
cd DocuMind-AI-Frontend
pnpm install
pnpm dev
```

访问地址: `http://localhost:5173`

### 2.4 Python AI 服务启动 (DocuMind-AI-Python)

建议使用 Conda 创建虚拟环境：

```bash
cd DocuMind-AI-Python
conda create -n documind python=3.10
conda activate documind
pip install -r requirements.txt

# 启动 API 服务
uvicorn main:app --reload --port 8000
```

---

## 3. 生产环境部署 (Docker)

### 3.1 构建镜像

#### 后端镜像

在 `DocuMind-AI-Backend` 根目录执行：

```bash
# 1. 编译打包
mvn clean package -DskipTests

# 2. 构建 Docker 镜像 (需编写 Dockerfile)
docker build -t documind/gateway ./documind-infrastructure/documind-gateway
docker build -t documind/system ./documind-modules/documind-system/documind-system-server
# ... 其他服务同理
```

#### 前端镜像

在 `DocuMind-AI-Frontend` 根目录执行：

```bash
# 1. 构建静态资源
pnpm build

# 2. 构建 Nginx 镜像
docker build -t documind/frontend .
```

#### Python 镜像

在 `DocuMind-AI-Python` 根目录执行：

```bash
docker build -t documind/python-ai .
```

### 3.2 编排启动

使用 `DocuMind-AI-Main/deploy/docker-compose/app.yml` 启动所有业务服务：

```bash
cd DocuMind-AI-Main/deploy/docker-compose
docker-compose -f app.yml up -d
```

---

## 4. 常见问题 (FAQ)

### Q1: Nacos 启动失败？

- 检查 `logs/nacos` 下的日志。
- 确认是否开启了鉴权 (`nacos.core.auth.enabled=true`)，如果是，请在配置文件中配置 `nacos.username` 和 `nacos.password`。
- 本地开发建议使用单机模式启动 (`MODE=standalone`)。

### Q2: 前端连接不上后端？

- 检查前端 `.env` 文件中的 `VITE_API_URL` 是否指向了正确的网关地址 (默认 `http://localhost:8080`)。
- 检查网关服务 (`documind-gateway`) 是否正常启动且无报错。
- 检查浏览器控制台 Network 面板是否有跨域 (CORS) 错误。

### Q3: Python 服务无法注册到 Nacos？

- 确认 Python 环境安装了 `nacos-sdk-python`。
- 检查 Nacos 地址配置是否正确。
- 确保 Python 服务与 Nacos 容器在同一网络下 (如果是 Docker 部署)。
