# Security Policy

## What This Repository Must Never Contain

- Real API keys, tokens, or credentials of any kind
- `.env`, `.env.production`, `.env.local` or any real environment files
- Private keys (`.pem`, `.key`, `.p12`)
- Database passwords, connection strings with credentials
- OAuth secrets or refresh tokens
- SSH private keys
- Session cookies or bearer tokens

## Safe Patterns

Use environment variable references in config files:
```json
"env": {
  "ANTHROPIC_API_KEY": "${env:ANTHROPIC_API_KEY}"
}
```

Never hardcode values like:
```json
"env": {
  "ANTHROPIC_API_KEY": "sk-ant-..."  ← NEVER DO THIS
}
```

## Git History

If a secret is accidentally committed:
1. Immediately rotate the credential (do not wait)
2. Remove from Git history using `git filter-repo` or BFG
3. Force-push after review
4. Notify affected services

## Reporting

If you discover a secret has been committed, do not open a public issue. Handle privately and rotate immediately.
