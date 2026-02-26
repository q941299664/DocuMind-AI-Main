# DocuMind-AI 开发工作流与实战指南

本文档旨在指导开发者在多仓库环境下高效进行功能开发，涵盖环境配置、Git Flow 实战、跨仓库协作及近期开发路线图。

## 1. 开发环境最佳实践

由于项目拆分为 4 个独立仓库，建议采用以下两种方式之一管理编辑器：

### 方案 A: VS Code Multi-Root Workspace (推荐)

将所有仓库添加到一个工作区中，方便全局搜索和上下文切换。

1. 打开 VS Code。
2. `File` -> `Add Folder to Workspace...`。
3. 依次添加 `DocuMind-AI-Main`, `DocuMind-AI-Backend`, `DocuMind-AI-Frontend`, `DocuMind-AI-Python`。
4. `File` -> `Save Workspace As...` -> 保存为 `DocuMind.code-workspace` (建议存在根目录 `d:\gitProject\DocuMind-AI\`).

### 方案 B: 独立窗口

为每个仓库打开一个独立的 VS Code 窗口。适合多屏开发，避免终端混淆。

---

## 2. Git Flow 实战演练

假设我们要开发 **"用户登录"** 功能，涉及后端 API 和前端页面。

### 2.1 后端开发 (Backend)

1. **开始功能**:
    - 切换到 `DocuMind-AI-Backend` 仓库。
    - 确保在 `develop` 分支: `git checkout develop && git pull`。
    - 创建功能分支: `git checkout -b feature/user-login develop`。

2. **编码**:
    - 在 `documind-system-api` 定义 DTO。
    - 在 `documind-system-server` 实现 Controller/Service。
    - 本地测试接口 (Swagger/Postman)。

3. **提交**:

    ```bash
    git add .
    git commit -m "feat(system): implement login api with jwt support"
    ```

4. **完成功能**:
    - 推送到远程备份 (可选): `git push -u origin feature/user-login`。
    - **合并回 develop**:

        ```bash
        git checkout develop
        git pull
        git merge --no-ff feature/user-login
        git push origin develop
        ```

    - 删除功能分支: `git branch -d feature/user-login`。

### 2.2 前端开发 (Frontend)

1. **开始功能**:
    - 切换到 `DocuMind-AI-Frontend` 仓库。
    - 基于 `develop` 创建分支: `git checkout -b feature/user-login develop`。

2. **编码**:
    - 根据后端 Swagger 生成/编写 API Client。
    - 开发登录页面组件。
    - 联调本地后端 (localhost:8080)。

3. **提交与合并**:
    - 同后端流程：Commit -> Merge to develop -> Push。

---

## 3. 跨仓库协作注意事项

1. **接口契约先行**:
    - 在开发跨端功能时，**后端先行**。先定义好 API (Swagger)，甚至可以先 Mock 数据，让前端有据可依。

2. **依赖同步**:
    - 如果 Python 服务更新了 gRPC/HTTP 接口，需通知 Backend 更新对应的 Feign Client 或 DTO。

3. **版本对齐**:
    - 发布 Release 时，确保 Backend v1.0.0 与 Frontend v1.0.0 是兼容的。

---

## 4. 近期开发路线图 (Next Actions)

根据 MVP 目标 (v0.5.0)，以下是建议的开发顺序：

### 阶段一：基础能力构建 (本周 - 下周)

- [ ] **Main**: 完善 Docker Compose 基础环境 (MySQL, Redis, MinIO, Nacos)。
- [ ] **Backend**: 完成 `documind-system` 模块的基础 CRUD 和 JWT 认证。
- [ ] **Frontend**: 搭建基础 Layout，集成 Axios 拦截器和全局状态管理 (Zustand/Redux)。

### 阶段二：核心业务突破

- [ ] **Backend**: 实现文件上传接口 (MinIO 集成)。
- [ ] **Python**: 搭建 PDF 解析服务 (FastAPI + PyMuPDF)，实现 Nacos 注册。
- [ ] **Backend**: 实现 Feign 调用 Python 解析服务。

### 阶段三：RAG 闭环

- [ ] **Python**: 接入 Embedding 模型和向量数据库 (Elasticsearch/Milvus)。
- [ ] **Backend**: 实现问答接口。
- [ ] **Frontend**: 开发 Chat 界面 (Ant Design X)。

---

## 5. 常用命令速查

### 批量更新所有仓库 (PowerShell)

```powershell
# 在 d:\gitProject\DocuMind-AI 目录下运行
Get-ChildItem -Directory | ForEach-Object {
    Write-Host "Updating $($_.Name)..."
    Set-Location $_.FullName
    git checkout develop
    git pull
}
```
