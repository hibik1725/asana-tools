#!/usr/bin/env bash
# タスクをセクションに移動する
# Usage: ./move-to-section.sh <section_gid> <task_gid>
source "$(dirname "$0")/_config.sh"

SECTION_GID="${1:-}"
TASK_GID="${2:-}"

if [[ -z "$SECTION_GID" || -z "$TASK_GID" ]]; then
  echo -e "${RED}Usage: $0 <section_gid> <task_gid>${NC}" >&2
  echo "  セクションGIDは ./list-sections.sh で確認できます" >&2
  exit 1
fi

PAYLOAD=$(jq -n --arg task "$TASK_GID" '{data: {task: $task}}')

asana_api POST "/sections/${SECTION_GID}/addTask" -d "$PAYLOAD" > /dev/null

echo -e "${GREEN}タスク ${TASK_GID} をセクション ${SECTION_GID} に移動しました${NC}"
