#!/usr/bin/env bash
# プロジェクト一覧を取得する
# Usage: ./list-projects.sh [workspace_gid]
#   workspace_gid: ワークスペースGID（省略時: ASANA_WORKSPACE_GID）
source "$(dirname "$0")/_config.sh"

WORKSPACE_GID="${1:-${ASANA_WORKSPACE_GID:-}}"

if [[ -z "$WORKSPACE_GID" ]]; then
  echo -e "${RED}Usage: $0 <workspace_gid>${NC}" >&2
  echo "  または ASANA_WORKSPACE_GID を .env に設定してください" >&2
  exit 1
fi

asana_api GET "/workspaces/${WORKSPACE_GID}/projects?opt_fields=name,archived,created_at" \
  | jq '.data[] | select(.archived == false) | {gid, name}'
