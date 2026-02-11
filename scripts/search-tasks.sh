#!/usr/bin/env bash
# タスクを検索する
# Usage: ./search-tasks.sh <query> [workspace_gid]
#   query: 検索キーワード
#   workspace_gid: ワークスペースGID（省略時: ASANA_WORKSPACE_GID）
source "$(dirname "$0")/_config.sh"

QUERY="${1:-}"
WORKSPACE_GID="${2:-${ASANA_WORKSPACE_GID:-}}"

if [[ -z "$QUERY" ]]; then
  echo -e "${RED}Usage: $0 <query> [workspace_gid]${NC}" >&2
  exit 1
fi

if [[ -z "$WORKSPACE_GID" ]]; then
  echo -e "${RED}workspace_gid が必要です（引数または ASANA_WORKSPACE_GID）${NC}" >&2
  exit 1
fi

ENCODED_QUERY=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$QUERY'))")

asana_api GET "/workspaces/${WORKSPACE_GID}/tasks/search?text=${ENCODED_QUERY}&opt_fields=name,completed,assignee.name,due_on" \
  | jq '.data[] | {gid, name, completed, due_on, assignee: .assignee.name}'
