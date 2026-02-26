-- DocuMind-AI 数据库初始化脚本
-- 版本: v0.6.0 (RBAC Enhanced)
-- 日期: 2026-02-26
-- 说明: 引入标准 RBAC 模型 (User-Role-Permission)
SET NAMES utf8mb4;
CREATE DATABASE IF NOT EXISTS `documind_system` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS `documind_document` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS `documind_ai` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- =================================================================================================
-- 1. 系统服务 (System Service) - documind_system
-- =================================================================================================
USE `documind_system`;

-- 1.1 用户表 (User)
CREATE TABLE IF NOT EXISTS `sys_user` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `username` VARCHAR(64) NOT NULL COMMENT '用户名',
    `password` VARCHAR(128) NOT NULL COMMENT '密码 (BCrypt)',
    `nickname` VARCHAR(64) DEFAULT NULL COMMENT '昵称',
    `email` VARCHAR(128) DEFAULT NULL COMMENT '邮箱',
    `avatar` VARCHAR(255) DEFAULT NULL COMMENT '头像',
    `status` TINYINT DEFAULT 1 COMMENT '状态 (0:禁用, 1:正常)',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted` TINYINT DEFAULT 0 COMMENT '逻辑删除 (0:未删, 1:已删)',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_username` (`username`)
) ENGINE=InnoDB COMMENT='系统用户表';

-- 1.2 角色表 (Role)
CREATE TABLE IF NOT EXISTS `sys_role` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `role_code` VARCHAR(64) NOT NULL COMMENT '角色编码 (ROLE_ADMIN, ROLE_USER)',
    `role_name` VARCHAR(64) NOT NULL COMMENT '角色名称 (管理员, 普通用户)',
    `description` VARCHAR(255) DEFAULT NULL COMMENT '描述',
    `status` TINYINT DEFAULT 1 COMMENT '状态 (0:禁用, 1:正常)',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted` TINYINT DEFAULT 0 COMMENT '逻辑删除',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_role_code` (`role_code`)
) ENGINE=InnoDB COMMENT='角色表';

-- 1.3 权限/菜单表 (Permission/Menu)
CREATE TABLE IF NOT EXISTS `sys_permission` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `parent_id` BIGINT DEFAULT 0 COMMENT '父级ID',
    `name` VARCHAR(64) NOT NULL COMMENT '权限名称 (查看用户, 上传文档)',
    `permission_code` VARCHAR(128) DEFAULT NULL COMMENT '权限标识 (user:list, doc:upload)',
    `type` TINYINT NOT NULL COMMENT '类型 (1:菜单, 2:按钮/API)',
    `path` VARCHAR(128) DEFAULT NULL COMMENT '路由地址 (仅菜单)',
    `component` VARCHAR(255) DEFAULT NULL COMMENT '前端组件路径 (仅菜单)',
    `icon` VARCHAR(64) DEFAULT NULL COMMENT '图标',
    `sort_order` INT DEFAULT 0 COMMENT '排序',
    `status` TINYINT DEFAULT 1 COMMENT '状态',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted` TINYINT DEFAULT 0 COMMENT '逻辑删除',
    PRIMARY KEY (`id`),
    KEY `idx_parent_id` (`parent_id`)
) ENGINE=InnoDB COMMENT='权限菜单表';

-- 1.4 用户-角色关联表
CREATE TABLE IF NOT EXISTS `sys_user_role` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `role_id` BIGINT NOT NULL COMMENT '角色ID',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_user_role` (`user_id`, `role_id`)
) ENGINE=InnoDB COMMENT='用户角色关联表';

-- 1.5 角色-权限关联表
CREATE TABLE IF NOT EXISTS `sys_role_permission` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `role_id` BIGINT NOT NULL COMMENT '角色ID',
    `permission_id` BIGINT NOT NULL COMMENT '权限ID',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_role_perm` (`role_id`, `permission_id`)
) ENGINE=InnoDB COMMENT='角色权限关联表';

-- 初始化基础数据
INSERT INTO `sys_role` (`role_code`, `role_name`, `description`) VALUES 
('ROLE_ADMIN', '系统管理员', '拥有最高权限'),
('ROLE_USER', '普通用户', '基础功能权限');

-- =================================================================================================
-- 2. 文档服务 (Document Service) - documind_document
-- =================================================================================================
USE `documind_document`;

-- 文档表
CREATE TABLE IF NOT EXISTS `doc_info` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `user_id` BIGINT NOT NULL COMMENT '所属用户ID',
    `file_name` VARCHAR(255) NOT NULL COMMENT '原始文件名',
    `file_size` BIGINT DEFAULT 0 COMMENT '文件大小(字节)',
    `file_type` VARCHAR(32) DEFAULT NULL COMMENT '文件类型(pdf, docx)',
    `storage_path` VARCHAR(512) NOT NULL COMMENT '存储路径 (MinIO Key)',
    `bucket_name` VARCHAR(64) NOT NULL COMMENT '存储桶名称',
    `status` TINYINT DEFAULT 0 COMMENT '状态 (0:上传中, 1:待解析, 2:解析中, 3:索引中, 4:完成, 9:失败)',
    `error_msg` TEXT DEFAULT NULL COMMENT '错误信息',
    `page_count` INT DEFAULT 0 COMMENT '页数',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted` TINYINT DEFAULT 0 COMMENT '逻辑删除',
    PRIMARY KEY (`id`),
    KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB COMMENT='文档信息表';

-- =================================================================================================
-- 3. AI 服务 (AI Service) - documind_ai
-- =================================================================================================
USE `documind_ai`;

-- 聊天会话表
CREATE TABLE IF NOT EXISTS `ai_chat_session` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `title` VARCHAR(255) DEFAULT '新对话' COMMENT '会话标题',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted` TINYINT DEFAULT 0 COMMENT '逻辑删除',
    PRIMARY KEY (`id`),
    KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB COMMENT='聊天会话表';

-- 聊天消息表
CREATE TABLE IF NOT EXISTS `ai_chat_message` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `session_id` BIGINT NOT NULL COMMENT '会话ID',
    `role` VARCHAR(16) NOT NULL COMMENT '角色 (user, assistant, system)',
    `content` TEXT NOT NULL COMMENT '消息内容',
    `ref_docs` JSON DEFAULT NULL COMMENT '引用文档 (JSON数组)',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    KEY `idx_session_id` (`session_id`)
) ENGINE=InnoDB COMMENT='聊天消息表';
