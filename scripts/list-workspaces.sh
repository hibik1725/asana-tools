#!/usr/bin/env bash
# ワークスペース一覧を取得する
# Usage: ./list-workspaces.sh
source "$(dirname "$0")/_config.sh"

asana_api GET "/workspaces" | jq '.data[] | {gid, name}'
