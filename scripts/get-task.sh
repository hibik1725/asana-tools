#!/usr/bin/env bash
# タスクの詳細を取得する
# Usage: ./get-task.sh <task_gid>
source "$(dirname "$0")/_config.sh"

TASK_GID="${1:-}"

if [[ -z "$TASK_GID" ]]; then
  echo -e "${RED}Usage: $0 <task_gid>${NC}" >&2
  exit 1
fi

FIELDS="name,notes,completed,assignee.name,due_on,tags.name,memberships.section.name,custom_fields.name,custom_fields.display_value"

asana_api GET "/tasks/${TASK_GID}?opt_fields=${FIELDS}" | jq '.data'
