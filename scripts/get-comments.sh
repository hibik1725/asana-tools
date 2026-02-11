#!/usr/bin/env bash
# タスクのコメント一覧を取得する
# Usage: ./get-comments.sh <task_gid>
source "$(dirname "$0")/_config.sh"

TASK_GID="${1:-}"

if [[ -z "$TASK_GID" ]]; then
  echo -e "${RED}Usage: $0 <task_gid>${NC}" >&2
  exit 1
fi

asana_api GET "/tasks/${TASK_GID}/stories?opt_fields=text,created_at,created_by.name,type" \
  | jq '.data[] | select(.type == "comment") | {gid, text, created_at, created_by: .created_by.name}'
