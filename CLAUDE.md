# Asana Tools

Asana API を操作するためのシェルスクリプトツールキット。どのプロジェクトからでも再利用可能。

## セットアップ

```bash
cd ~/Desktop/asana-tools
bun install
cp .env.example .env
# .env に ASANA_PAT を設定
./scripts/get-me.sh   # 動作確認
```

## スクリプト一覧

| スクリプト | 説明 | Usage |
|-----------|------|-------|
| `get-me.sh` | 自分のユーザー情報取得 | `./scripts/get-me.sh` |
| `list-workspaces.sh` | ワークスペース一覧 | `./scripts/list-workspaces.sh` |
| `list-projects.sh` | プロジェクト一覧 | `./scripts/list-projects.sh [workspace_gid]` |
| `list-sections.sh` | セクション一覧 | `./scripts/list-sections.sh [project_gid]` |
| `list-tasks.sh` | タスク一覧 | `./scripts/list-tasks.sh [project_gid] [--completed]` |
| `get-task.sh` | タスク詳細 | `./scripts/get-task.sh <task_gid>` |
| `create-task.sh` | タスク作成 | `./scripts/create-task.sh <name> [-p gid] [-a gid] [-d date] [-n notes]` |
| `update-task.sh` | タスク更新 | `./scripts/update-task.sh <task_gid> [--name x] [--completed] [--due date]` |
| `delete-task.sh` | タスク削除 | `./scripts/delete-task.sh <task_gid>` |
| `add-comment.sh` | コメント追加 | `./scripts/add-comment.sh <task_gid> <text>` |
| `get-comments.sh` | コメント取得 | `./scripts/get-comments.sh <task_gid>` |
| `search-tasks.sh` | タスク検索 | `./scripts/search-tasks.sh <query> [workspace_gid]` |
| `move-to-section.sh` | セクション移動 | `./scripts/move-to-section.sh <section_gid> <task_gid>` |

## 環境変数

| 変数 | 必須 | 説明 |
|------|------|------|
| `ASANA_PAT` | Yes | Personal Access Token |
| `ASANA_WORKSPACE_GID` | No | デフォルトワークスペースGID |
| `ASANA_PROJECT_GID` | No | デフォルトプロジェクトGID |
| `ASANA_ASSIGNEE_GID` | No | デフォルト担当者GID |

## Asana API リファレンス

### 認証

```
Authorization: Bearer <ASANA_PAT>
```

PAT は https://app.asana.com/0/developer-console で発行。

### ベースURL

```
https://app.asana.com/api/1.0
```

### 主要エンドポイント

| メソッド | エンドポイント | 説明 |
|---------|---------------|------|
| GET | `/users/me` | 自分の情報 |
| GET | `/workspaces` | ワークスペース一覧 |
| GET | `/workspaces/{gid}/projects` | プロジェクト一覧 |
| GET | `/projects/{gid}/sections` | セクション一覧 |
| GET | `/projects/{gid}/tasks` | タスク一覧 |
| GET | `/tasks/{gid}` | タスク詳細 |
| POST | `/tasks` | タスク作成 |
| PUT | `/tasks/{gid}` | タスク更新 |
| DELETE | `/tasks/{gid}` | タスク削除 |
| GET | `/tasks/{gid}/stories` | ストーリー（コメント）取得 |
| POST | `/tasks/{gid}/stories` | コメント追加 |
| POST | `/sections/{gid}/addTask` | セクションにタスク追加 |
| GET | `/workspaces/{gid}/tasks/search` | タスク検索 |

### レート制限

- 1分あたり約1,500リクエスト
- 429レスポンス時は `Retry-After` ヘッダーに従う

### ページネーション

レスポンスに `next_page` がある場合は `offset` パラメータで次ページを取得:

```bash
curl -s -H "Authorization: Bearer $ASANA_PAT" \
  "https://app.asana.com/api/1.0/projects/{gid}/tasks?limit=100&offset=<next_page.offset>"
```

### opt_fields

レスポンスに含めるフィールドを `opt_fields` で指定可能:

```bash
# 例: タスク名、担当者名、期日を取得
?opt_fields=name,assignee.name,due_on
```

### エラーコード

| コード | 説明 |
|-------|------|
| 400 | リクエスト不正 |
| 401 | 認証エラー（PAT無効） |
| 403 | アクセス権限なし |
| 404 | リソースが見つからない |
| 429 | レート制限超過 |
| 500 | サーバーエラー |

## curl パターン集

### タスク一覧（未完了のみ）

```bash
source ~/.claude/discord/config.sh  # 不要（Asana用）
curl -s -H "Authorization: Bearer $ASANA_PAT" \
  "https://app.asana.com/api/1.0/projects/{project_gid}/tasks?opt_fields=name,completed,due_on" \
  | jq '.data[] | select(.completed == false)'
```

### タスク作成

```bash
curl -s -X POST \
  -H "Authorization: Bearer $ASANA_PAT" \
  -H "Content-Type: application/json" \
  -d '{"data":{"name":"タスク名","projects":["PROJECT_GID"]}}' \
  "https://app.asana.com/api/1.0/tasks" | jq '.data'
```

### タスク完了にする

```bash
curl -s -X PUT \
  -H "Authorization: Bearer $ASANA_PAT" \
  -H "Content-Type: application/json" \
  -d '{"data":{"completed":true}}' \
  "https://app.asana.com/api/1.0/tasks/{task_gid}" | jq '.data'
```

### コメント追加

```bash
curl -s -X POST \
  -H "Authorization: Bearer $ASANA_PAT" \
  -H "Content-Type: application/json" \
  -d '{"data":{"text":"コメント本文"}}' \
  "https://app.asana.com/api/1.0/tasks/{task_gid}/stories" | jq '.data'
```

## 注意事項

- `.env` ファイルは `.gitignore` で除外済み。トークンをコミットしないこと
- 削除操作（`delete-task.sh`）は実行前にユーザーに確認を取ること
- レート制限に注意: 短時間に大量リクエストを送らないこと
