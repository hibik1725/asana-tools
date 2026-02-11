#!/usr/bin/env bash
# 自分のユーザー情報を取得する
# Usage: ./get-me.sh
source "$(dirname "$0")/_config.sh"

asana_api GET "/users/me" | jq '.data | {gid, name, email}'
