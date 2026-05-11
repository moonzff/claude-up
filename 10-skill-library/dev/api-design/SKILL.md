# Skill: api-design
> 适配：Node.js REST API（Express/Fastify）· 版本：v1.0

## 定位

设计 REST API 接口规范，在写代码前对齐约定，避免后期改接口的高成本。

---

## 设计流程

### Step 1 · 资源识别
列出所有核心资源（名词），确定层级关系：
```
资源：User / Order / Product / Membership
层级：/users/{id}/orders（User 下的 Order）
```

### Step 2 · 接口清单

标准 CRUD 模板：
```
GET    /resources          列表（带分页）
POST   /resources          创建
GET    /resources/:id      详情
PATCH  /resources/:id      部分更新（优于 PUT）
DELETE /resources/:id      删除

非 CRUD 操作用动词子路径：
POST   /resources/:id/activate
POST   /orders/:id/cancel
```

### Step 3 · 请求/响应规范

**统一响应格式**：
```json
// 成功
{ "data": { ... }, "meta": { "total": 100, "page": 1 } }

// 错误
{ "error": { "code": "VALIDATION_ERROR", "message": "...", "details": [...] } }
```

**分页参数约定**：
```
GET /users?page=1&limit=20&sort=createdAt&order=desc
```

**版本管理**：
```
URL 前缀：/api/v1/...  （推荐，简单直观）
```

### Step 4 · HTTP 状态码约定

| 场景 | 状态码 |
|------|-------|
| 创建成功 | 201 Created |
| 成功无返回体 | 204 No Content |
| 参数验证失败 | 400 Bad Request |
| 未认证 | 401 Unauthorized |
| 无权限 | 403 Forbidden |
| 资源不存在 | 404 Not Found |
| 业务逻辑冲突 | 409 Conflict |
| 服务器错误 | 500 Internal Server Error |

### Step 5 · 设计 Review 清单

```
□ URL 是否全小写 + 连字符（/user-profiles 不是 /userProfiles）？
□ 资源名是否用复数（/users 不是 /user）？
□ 是否用 PATCH 替代 PUT（除非真的需要全量替换）？
□ 列表接口是否有分页（避免无上限返回）？
□ 错误响应是否有 code 字段（方便客户端程序化处理）？
□ 是否需要幂等性（POST 重复提交是否安全）？
□ 认证方案是否确定（JWT Bearer / Cookie / API Key）？
□ 是否有请求频率限制（Rate Limiting）？
```

---

## 输出物

设计完成后输出：
1. **接口清单**（Markdown 表格：方法 / 路径 / 描述 / 请求体 / 响应）
2. **TS 类型定义**（Request / Response 接口）
3. **OpenAPI 片段**（可选，便于生成文档）
