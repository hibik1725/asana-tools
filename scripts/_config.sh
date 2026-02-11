#!/usr/bin/env bash
# Asana ツールキット共通設定ローダー
set -euo pipefail

# 色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

# スクリプトのディレクトリを基準に .env を探す
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# .env が存在する場合はロード（dotenv-cli 経由でなくても単体実行できるようにする）
if [[ -z "${ASANA_PAT:-}" ]] && [[ -f "$PROJECT_DIR/.env" ]]; then
  set -a
  source "$PROJECT_DIR/.env"
  set +a
fi

# 必須環境変数チェック
if [[ -z "${ASANA_PAT:-}" ]]; then
  echo -e "${RED}エラー: ASANA_PAT が設定されていません${NC}" >&2
  echo "  .env ファイルに ASANA_PAT を設定してください" >&2
  echo "  参考: .env.example" >&2
  exit 1
fi

# Asana API ベースURL
ASANA_API="https://app.asana.com/api/1.0"

# 共通curlヘルパー
# Usage: asana_api <METHOD> <endpoint> [curl_options...]
# レスポンスボディを返し、HTTPステータスが2xxでなければエラー終了
asana_api() {
  local method="$1"
  local endpoint="$2"
  shift 2

  local response
  response=$(curl -s -w "\n%{http_code}" \
    -X "$method" \
    -H "Authorization: Bearer ${ASANA_PAT}" \
    -H "Content-Type: application/json" \
    "$@" \
    "${ASANA_API}${endpoint}")

  local body
  body=$(echo "$response" | sed '$d')
  local http_code
  http_code=$(echo "$response" | tail -1)

  if [[ "$http_code" -lt 200 || "$http_code" -ge 300 ]]; then
    echo -e "${RED}エラー: HTTP ${http_code}${NC}" >&2
    echo "$body" | jq '.' 2>/dev/null || echo "$body" >&2
    exit 1
  fi

  echo "$body"
}
