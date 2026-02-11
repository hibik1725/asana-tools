#!/usr/bin/env bash
# プロジェクトのセクション一覧を取得する
# Usage: ./list-sections.sh [project_gid]
#   project_gid: プロジェクトGID（省略時: ASANA_PROJECT_GID）
source "$(dirname "$0")/_config.sh"

PROJECT_GID="${1:-${ASANA_PROJECT_GID:-}}"

if [[ -z "$PROJECT_GID" ]]; then
  echo -e "${RED}Usage: $0 <project_gid>${NC}" >&2
  echo "  または ASANA_PROJECT_GID を .env に設定してください" >&2
  exit 1
fi

asana_api GET "/projects/${PROJECT_GID}/sections" | jq '.data[] | {gid, name}'
