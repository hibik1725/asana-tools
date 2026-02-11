#!/usr/bin/env bash
# タスクを更新する
# Usage: ./update-task.sh <task_gid> [options]
#   --name <name>          タスク名
#   --notes <text>         説明文
#   --completed            完了にする
#   --uncompleted          未完了に戻す
#   --assignee <gid>       担当者GID
#   --due <date>           期日（YYYY-MM-DD）
source "$(dirname "$0")/_config.sh"

TASK_GID="${1:-}"
shift || true

if [[ -z "$TASK_GID" ]]; then
  echo -e "${RED}Usage: $0 <task_gid> [options]${NC}" >&2
  echo "  --name <name>       タスク名" >&2
  echo "  --notes <text>      説明文" >&2
  echo "  --completed         完了にする" >&2
  echo "  --uncompleted       未完了に戻す" >&2
  echo "  --assignee <gid>    担当者GID" >&2
  echo "  --due <date>        期日（YYYY-MM-DD）" >&2
  exit 1
fi

# フィールドを配列で集める
FIELDS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --name) FIELDS+=("\"name\": \"$2\""); shift 2 ;;
    --notes) FIELDS+=("\"notes\": \"$2\""); shift 2 ;;
    --completed) FIELDS+=("\"completed\": true"); shift ;;
    --uncompleted) FIELDS+=("\"completed\": false"); shift ;;
    --assignee) FIELDS+=("\"assignee\": \"$2\""); shift 2 ;;
    --due) FIELDS+=("\"due_on\": \"$2\""); shift 2 ;;
    *)
      echo -e "${RED}不明なオプション: $1${NC}" >&2
      exit 1
      ;;
  esac
done

if [[ ${#FIELDS[@]} -eq 0 ]]; then
  echo -e "${YELLOW}更新するフィールドが指定されていません${NC}" >&2
  exit 1
fi

# JSON構築
FIELDS_JSON=$(IFS=,; echo "${FIELDS[*]}")
PAYLOAD="{\"data\": {${FIELDS_JSON}}}"

asana_api PUT "/tasks/${TASK_GID}" -d "$PAYLOAD" | jq '.data | {gid, name, completed}'

echo -e "${GREEN}タスクを更新しました${NC}"
