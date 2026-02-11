#!/usr/bin/env bash
# タスクを作成する
# Usage: ./create-task.sh <name> [options]
#   -p, --project <gid>   プロジェクトGID（省略時: ASANA_PROJECT_GID）
#   -a, --assignee <gid>  担当者GID（省略時: ASANA_ASSIGNEE_GID）
#   -d, --due <date>      期日（YYYY-MM-DD）
#   -n, --notes <text>    説明文
source "$(dirname "$0")/_config.sh"

NAME=""
PROJECT_GID="${ASANA_PROJECT_GID:-}"
ASSIGNEE_GID="${ASANA_ASSIGNEE_GID:-}"
DUE_ON=""
NOTES=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -p|--project) PROJECT_GID="$2"; shift 2 ;;
    -a|--assignee) ASSIGNEE_GID="$2"; shift 2 ;;
    -d|--due) DUE_ON="$2"; shift 2 ;;
    -n|--notes) NOTES="$2"; shift 2 ;;
    -*)
      echo -e "${RED}不明なオプション: $1${NC}" >&2
      exit 1
      ;;
    *)
      NAME="$1"; shift ;;
  esac
done

if [[ -z "$NAME" ]]; then
  echo -e "${RED}Usage: $0 <name> [options]${NC}" >&2
  echo "  -p, --project <gid>   プロジェクトGID" >&2
  echo "  -a, --assignee <gid>  担当者GID" >&2
  echo "  -d, --due <date>      期日（YYYY-MM-DD）" >&2
  echo "  -n, --notes <text>    説明文" >&2
  exit 1
fi

# JSON ペイロード構築
PAYLOAD=$(jq -n \
  --arg name "$NAME" \
  --arg notes "$NOTES" \
  --arg due_on "$DUE_ON" \
  --arg assignee "$ASSIGNEE_GID" \
  --arg project "$PROJECT_GID" \
  '{data: {name: $name}
    + (if $notes != "" then {notes: $notes} else {} end)
    + (if $due_on != "" then {due_on: $due_on} else {} end)
    + (if $assignee != "" then {assignee: $assignee} else {} end)
    + (if $project != "" then {projects: [$project]} else {} end)
  }')

asana_api POST "/tasks" -d "$PAYLOAD" | jq '.data | {gid, name, assignee: .assignee.name}'

echo -e "${GREEN}タスクを作成しました${NC}"
