# Nacos 配置导入指南

## 1. 访问 Nacos 控制台
- **地址**: `http://localhost:8848/nacos`
- **默认账号**: `nacos`
- **默认密码**: `nacos`

## 2. 导入配置
1.  登录后，点击左侧菜单 **配置管理** -> **配置列表**。
2.  点击右上角的 **导入配置** 按钮 (或手动逐个创建)。
3.  由于我们是首次初始化，建议手动创建以下配置 (Data ID / Group / Format):

| Data ID | Group | Format | 内容来源 |
| :--- | :--- | :--- | :--- |
| `documind-gateway.yaml` | `DEFAULT_GROUP` | `YAML` | `deploy/nacos/config/documind-gateway.yaml` |
| `documind-system.yaml` | `DEFAULT_GROUP` | `YAML` | `deploy/nacos/config/documind-system.yaml` |
| `documind-auth.yaml` | `DEFAULT_GROUP` | `YAML` | `deploy/nacos/config/documind-auth.yaml` |
| `documind-document.yaml` | `DEFAULT_GROUP` | `YAML` | `deploy/nacos/config/documind-document.yaml` |
| `documind-ai.yaml` | `DEFAULT_GROUP` | `YAML` | `deploy/nacos/config/documind-ai.yaml` |

## 3. 注意事项
- 所有配置中的数据库/Redis/MinIO 地址均使用了 **Docker 容器名** (如 `documind-mysql`, `documind-redis`)。
- 如果您是在 **IDEA 本地启动** 后端服务（而不是在 Docker 中运行），需要将这些 host 修改为 `localhost` 或 `127.0.0.1`。
- **开发环境建议**: 在 Nacos 中创建两套配置：
    - `documind-system-dev.yaml` (本地开发用，Host = localhost)
    - `documind-system-prod.yaml` (容器部署用，Host = documind-mysql)

## 4. 快速切换本地开发配置
为了方便本地调试，你可以直接修改刚刚生成的 yaml 文件，将 `documind-mysql` 等替换为 `localhost`，然后发布到 Nacos。
