#!/bin/bash
# cognee MCP 启动 wrapper — 注入已验证的 DashScope 配置。
# 密钥从环境变量读取（CLI 走 .zshrc / GUI 走 launchctl），绝不硬编码进任何配置文件。
# 注册方式：claude mcp add cognee -s user -- <本脚本绝对路径>

set -u

# ── 密钥：优先用继承的环境变量，缺失则从 ~/.zshrc 兜底读取 ──
KEY="${DASHSCOPE_API_KEY:-}"
if [ -z "$KEY" ] && [ -f "$HOME/.zshrc" ]; then
  KEY="$(grep -m1 'DASHSCOPE_API_KEY' "$HOME/.zshrc" | sed -E 's/.*DASHSCOPE_API_KEY="?([^"]*)"?.*/\1/')"
fi

export LLM_API_KEY="$KEY"
export EMBEDDING_API_KEY="$KEY"
export LLM_PROVIDER="openai"
export LLM_MODEL="openai/qwen-plus"
export LLM_ENDPOINT="https://dashscope.aliyuncs.com/compatible-mode/v1"
export EMBEDDING_PROVIDER="openai_compatible"
export EMBEDDING_MODEL="text-embedding-v3"
export EMBEDDING_DIMENSIONS="1024"
export EMBEDDING_BATCH_SIZE="10"
export EMBEDDING_ENDPOINT="https://dashscope.aliyuncs.com/compatible-mode/v1"
export DATA_ROOT_DIRECTORY="/Users/moonz/MoonzWorkspace/Claude_up/09-cognee/.data_storage"
export SYSTEM_ROOT_DIRECTORY="/Users/moonz/MoonzWorkspace/Claude_up/09-cognee/.cognee_system"
export ENABLE_BACKEND_ACCESS_CONTROL="false"

exec /Users/moonz/MoonzWorkspace/Claude_up/09-cognee/.venv/bin/cognee-mcp --transport stdio
