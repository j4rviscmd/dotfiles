---
name: action-logs
description: >-
  このスキルは、ユーザーが「GitHub Actionsが失敗している」「Actionsが落ちた」
  「CIのログを見て」「CIのエラーを確認」「workflowがこけた」「パイプラインが失敗」
  「テストが落ちた原因を知りたい」「ビルドエラーの理由を調査して」
  「直近のworkflow runを確認」「GitHub Actionsの実行結果を見て」と言った場合、または
  GitHub Actions/CI/workflowの失敗、テスト・ビルドエラーの調査について話している場合に使用される。
  GitHub Actionsの実行ログを確認し、失敗原因を調査・デバッグする。
model: github-copilot/gpt-5-mini
context: false
---

# GitHub Actions ログ確認

## 概要

GitHub Actionsの実行ログを確認します。主に失敗したworkflowのデバッグ用途を想定しています。

### 主要機能
- 失敗したGitHub Actionsのログを一括表示
- ワークフローの特定な実行結果の詳細確認
- 複数失敗時のインタラクティブなログ選択
- ワークフロー名でのフィルタリング

### 前提条件
- `gh CLI` がインストールされ、GitHubに認証されていること
- `jq` コマンドがインストールされていること（JSON解析用）
- カレントディレクトリがGitHubリポジトリであること

## 実行フロー

### 引数の解析

実行時の引数に応じて処理を分岐します：

|              引数パターン              |                  動作                  |
| -------------------------------------- | -------------------------------------- |
| 引数なし                               | 最新の失敗したworkflow runのログを表示 |
| `--list` または `-l`                   | 最近のworkflow runを一覧表示           |
| `--run-id <id>` または `-r <id>`       | 特定のrun_idのログを表示               |
| `--workflow <name>` または `-w <name>` | 特定のworkflowの最新失敗ログを表示     |

### ステップ 1: レポジトリの確認

カレントディレクトリがgitレポジトリであることを確認し、GitHub レポジトリ情報を取得します：

```bash
git remote -v | grep origin | head -1
```

**注意**: このステップは失敗しても即時終了せず、ユーザーにGitHubリポジトリであることを確認させるプロンプトを表示します。

### ステップ 2: 各モードの処理

#### モードA: 引数なし（最新の失敗ログ）

1. 最新の失敗したworkflow runを取得：

```bash
gh run list --limit 20 --json databaseId,status,conclusion,workflowName,headBranch,displayTitle --jq '.[] | select(.conclusion == "failure") | .databaseId' | head -1
```

2. run_idが見つかった場合、失敗したステップのログを表示：

```bash
gh run view <run-id> --log-failed
```

3. 人間向けの要約を表示：

```text
## Workflow Run サマリー

- Workflow: {workflowName}
- Run ID: {run-id}
- Branch: {headBranch}
- Title: {displayTitle}
- 結果: 失敗
- タイムスタンプ: {timestamp}

### エラー箇所

上記ログに失敗したステップの詳細が表示されています。
主なエラー内容を確認してください。

**推奨されるアクション**:
- エラーメッセージを検索: `error` や `failed` などのキーワードでログを検索
- ステップ番号を確認: "Step X/Y" の形式でどのステップで失敗したか特定
- マトリックスビルドの場合: 失敗したOSやバージョンを特定
```

#### モードB: `--list`（run一覧表示）

最近のworkflow runを一覧表示：

```bash
gh run list --limit 20
```

#### モードC: `--run-id <id>`（特定run_idのログ）

指定されたrun_idの失敗ログを表示：

```bash
gh run view <run-id> --log-failed
```

#### モードD: `--workflow <name>`（特定workflowの失敗ログ）

1. 特定のworkflowの最新失敗runを取得：

```bash
gh run list --workflow=<name> --limit 10 --json databaseId,status,conclusion --jq '.[] | select(.conclusion == "failure") | .databaseId' | head -1
```

2. 失敗ログを表示（モードAと同様）

### ステップ 3: インタラクティブ選択（失敗したrunが複数ある場合）

引数なしで実行し、失敗したrunが複数ある場合は、インタラクティブに選択肢を提示：

```text
失敗したworkflow runが複数あります。どのログを確認しますか？

1. ci.yml (test) - Run ID: 1234567890 - branch: feature/auth - 5分前
2. deploy.yml (deploy) - Run ID: 1234567889 - branch: main - 1時間前
3. ci.yml (build) - Run ID: 1234567888 - branch: feature/api - 2時間前

番号を入力するか、Enterで最新を選択:
```

## エラーハンドリング

以下の場合は適切なエラーメッセージを表示：

|            エラー条件            |                                    メッセージ                                    |
| -------------------------------- | -------------------------------------------------------------------------------- |
| gitレポジトリではない            | `現在のディレクトリはgitレポジトリではありません`                                |
| GitHub remoteがない              | `GitHubのremoteが見つかりません。git remote add origin <repo-url>`で設定してください` |
| gh CLIがインストールされていない | `gh CLIがインストールされていません。https://cli.github.com/ を参照してください` |
| jqがインストールされていない     | `jqコマンドが必要です。https://stedolan.github.io/jq/ を参照してください`       |
| 失敗したrunがない                | `最近の失敗したworkflow runは見つかりませんでした（最近30日以内に失敗したrunがないか確認）` |
| 指定したrun_idが存在しない       | `指定されたrun_idが見つかりません: <run-id>`                                     |
| GitHub APIレート制限に達した     | `GitHub APIのレート制限に達しました。しばらく待ってから再実行してください`       |
| プライベートリポジトリへのアクセス権がない | `プライベートリポジトリへのアクセス権が不足しています。権限を確認してください` |

## 使用例

```bash
/action-logs                          # 最新の失敗ログを表示
/action-logs --list                   # 最近のrun一覧を表示（失敗・成功含む）
/action-logs --list -l -q status:failure  # 失敗したrunのみ一覧表示
/action-logs --run-id 1234567890      # 特定のrun_idのログを表示
/action-logs --workflow ci.yml        # ci.ymlの最新失敗ログを表示
/action-logs -w deploy.yml -r 1234567890  # どちらかの引数でも指定可能
```

## 高度な使用例

```bash
# 複数のワークフローをチェック
for workflow in ci.yml deploy.yml; do
  /action-logs --workflow $workflow
done

# 特定のブランチのログを確認（jqを直接使用）
gh run list --branch main --limit 10 --json databaseId,status,conclusion --jq '.[] | select(.conclusion == "failure") | .databaseId' | head -5 | xargs -I {} gh run view {} --log-failed
```

## 注意事項

- gh CLIがインストールされ、認証されている必要があります
- jqコマンドが必要です（JSON解析用）
- デフォルトではカレントディレクトリのGitHubレポジトリを対象とします
- GitHub APIにはレート制限があります（5000リクエスト/時間）
- 大規模なリポジトリではログ取得に時間がかかる場合があります
- フォークされたリポジトリでは、親リポジトリのActionsログは確認できません

## セキュリティ考慮事項

- このスキルはGitHub APIを直接呼び出しますが、認証情報は保存せずにgh CLIに委譲します
- ログには機密情報（シークレットなど）が含まれる可能性があります。表示前に確認してください
- Organizationレベルのレート制限に注意してください

## パフォーマンス最適化

- 大量のログを確認する場合は `--limit` パラメータを使用して必要な範囲のみ取得
- 繰り返し確認する場合はキャッシュ機構を検討（gh CLIのローカルキャッシュを活用）
- CI/CDログの自動化ではWebhookと連携した専用のデバッグツールの使用を推奨
