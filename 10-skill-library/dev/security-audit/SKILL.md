# Skill: security-audit
> 适配：Node.js Web 服务 + AWS 环境 · 版本：v1.0

## 定位

系统性安全扫描，覆盖 OWASP Top 10 + Node.js / AWS 特定风险。
比 code-review 的安全维度更深、更完整。

---

## 审计清单

### A. 输入验证与注入
```
□ 所有外部输入（请求体、querystring、headers、文件名）都经过 schema 验证？
□ SQL/NoSQL 查询全部使用参数化，无字符串拼接？
□ 文件路径操作是否防目录遍历（path.resolve + startsWith 检查）？
□ HTML 输出是否转义（防 XSS）？
□ 正则表达式是否有 ReDoS 风险（回溯复杂度）？
```

### B. 认证与授权
```
□ JWT/session 是否有过期时间？
□ 密码是否用 bcrypt/argon2 哈希（不是 MD5/SHA1）？
□ 权限校验在 Service 层而非只在 Controller/路由层？
□ 敏感操作是否有二次确认或 MFA？
□ API 是否存在越权访问（IDOR）风险？（用 A 的 token 能访问 B 的数据？）
```

### C. 敏感数据
```
□ 数据库密码、API Key、私钥全部在环境变量，不在代码里？
□ 日志中是否打印了密码、token、PII？
□ 响应中是否返回了多余字段（如密码 hash）？
□ HTTPS 是否全程强制（无 HTTP fallback）？
□ Cookie 是否设置 HttpOnly + Secure + SameSite？
```

### D. 依赖安全
```
□ npm audit 是否有高危漏洞？
□ 依赖版本是否锁定（package-lock.json 提交了？）？
□ 是否有长期不更新的依赖（>1年无安全更新）？
□ 是否引用了来源不明的 npm 包？
```

### E. AWS 配置（针对杆杆响等 AWS 项目）
```
□ IAM 角色是否最小权限（没有 * 权限）？
□ S3 Bucket 是否关闭了公开访问（除非必须公开）？
□ Security Group 入站规则是否只开放必要端口？
□ RDS/数据库是否不在公网（在私有子网）？
□ CloudTrail / 访问日志是否开启？
□ Secrets Manager 是否用于管理密钥（而不是环境变量硬编码）？
```

### F. 错误处理
```
□ 生产环境错误响应是否不暴露 stack trace？
□ 404/500 等错误页面是否不泄露技术栈信息？
□ 异常是否被捕获并记录日志（无静默吞噬）？
```

---

## 输出格式

```markdown
## 安全审计报告 · <项目/模块名> · <日期>

### 高危（必须立即修复）
- [HIGH] <问题>：<风险描述> | 修复建议：<具体方案>

### 中危（应在下次迭代修复）
- [MED] <问题>：<风险描述> | 修复建议：<具体方案>

### 低危（记录，按优先级处理）
- [LOW] <问题>

### 已确认安全
- <已做好的点>

### 建议工具
- npm audit（依赖扫描）
- OWASP ZAP（动态扫描）
- AWS Trusted Advisor（云配置检查）
```
