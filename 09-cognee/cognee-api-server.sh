#!/bin/bash
# cognee FastAPI server — 独占文件库（kuzu+lancedb+sqlite），供所有 cognee-mcp 客户端
# 经 --api-url 委托，实现 Claude/Codex/Desktop 并发访问同一知识图谱（根治单写锁）。
# 由 launchd 守护常驻；密钥从环境/.zshrc 读，零硬编码。
set -u

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
export REQUIRE_AUTHENTICATION="false"
export HTTP_API_HOST="127.0.0.1"
export HTTP_API_PORT="8000"

exec /Users/moonz/MoonzWorkspace/Claude_up/09-cognee/.venv/bin/python -m cognee.api.client
