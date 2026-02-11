#!/usr/bin/env bash
# タスクを削除する
# Usage: ./delete-task.sh <task_gid>
source "$(dirname "$0")/_config.sh"

TASK_GID="${1:-}"

if [[ -z "$TASK_GID" ]]; then
  echo -e "${RED}Usage: $0 <task_gid>${NC}" >&2
  exit 1
fi

asana_api DELETE "/tasks/${TASK_GID}" > /dev/null

echo -e "${GREEN}タスク ${TASK_GID} を削除しました${NC}"
