#!/usr/bin/env bash
# プロジェクトのタスク一覧を取得する
# Usage: ./list-tasks.sh [project_gid] [--completed]
#   project_gid: プロジェクトGID（省略時: ASANA_PROJECT_GID）
#   --completed: 完了タスクも含める
source "$(dirname "$0")/_config.sh"

PROJECT_GID=""
SHOW_COMPLETED=false

for arg in "$@"; do
  case "$arg" in
    --completed) SHOW_COMPLETED=true ;;
    *) PROJECT_GID="$arg" ;;
  esac
done

PROJECT_GID="${PROJECT_GID:-${ASANA_PROJECT_GID:-}}"

if [[ -z "$PROJECT_GID" ]]; then
  echo -e "${RED}Usage: $0 [project_gid] [--completed]${NC}" >&2
  echo "  または ASANA_PROJECT_GID を .env に設定してください" >&2
  exit 1
fi

FIELDS="name,completed,assignee.name,due_on,memberships.section.name"

if [[ "$SHOW_COMPLETED" == "true" ]]; then
  COMPLETED_FILTER="completed_since=2020-01-01&"
else
  COMPLETED_FILTER=""
fi

asana_api GET "/projects/${PROJECT_GID}/tasks?${COMPLETED_FILTER}opt_fields=${FIELDS}" \
  | jq '.data[] | {gid, name, completed, due_on, assignee: .assignee.name, section: (.memberships[0].section.name // null)}'
