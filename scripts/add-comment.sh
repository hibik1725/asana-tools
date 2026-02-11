#!/usr/bin/env bash
# タスクにコメントを追加する
# Usage: ./add-comment.sh <task_gid> <comment_text>
source "$(dirname "$0")/_config.sh"

TASK_GID="${1:-}"
COMMENT="${2:-}"

if [[ -z "$TASK_GID" || -z "$COMMENT" ]]; then
  echo -e "${RED}Usage: $0 <task_gid> <comment_text>${NC}" >&2
  exit 1
fi

PAYLOAD=$(jq -n --arg text "$COMMENT" '{data: {text: $text}}')

asana_api POST "/tasks/${TASK_GID}/stories" -d "$PAYLOAD" \
  | jq '.data | {gid, text, created_at, created_by: .created_by.name}'

echo -e "${GREEN}コメントを追加しました${NC}"
