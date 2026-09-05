---
name: monitor-pr-ci
model: github-copilot/gpt-5-mini
user-invocable: false
description: >-
  このスキルはworktree-finishのStep 10からのみ呼び出される。
  PR作成後にGitHub ActionsのCIが完了するまで監視し、結果（OK/NG/TIMEOUT）を返す。
  自動修正は行わず、結果報告のみを担当する。
---

# PR CI監視

## 前提条件

- 呼び出し元（worktree-finish）からPR番号を受け取っていること

## ガードレール（絶対に守ること）

| ルール | 理由 |
| ------ | ---- |
| **ユーザーからの直接呼び出し禁止** | `user-invocable: false` により制御済み |
| **自動修正禁止** | 修正は呼び出し元（worktree-finish）の責任範囲 |
| **gh CLIを使用** | GitHub MCPにはCI監視用ツールが存在しないため |
| **30秒間隔でポーリング** | 頻繁すぎるとAPI制限に引っかかるため |
| **30分でタイムアウト** | compile check等の重いCIが実行される可能性があるため |

---

## 実行フロー

### Step 0: PRトリガworkflowの存在確認（早期リターン）

**目的**: PRトリガで発動するworkflowが存在するかを事前に確認し、存在しない場合は無駄な監視をスキップする

**実行**:
```bash
gh workflow list --json name,on --jq '.[] | select(.on | tostring | test("pull_request")) | .name'
```

**判定**:

| 結果 | アクション |
| ---- | ---------- |
| 1つ以上のworkflow名が返る | Step 1（最新のworkflow runを取得）へ進む |
| 空文字（該当なし） | Step 3（SKIPPED結果）へ進んで早期リターン |

**注意**: `gh workflow list`はデフォルトで有効なworkflowのみを対象とするため、無効化されたworkflowは無視される。

---

### Step 1: 最新のworkflow runを取得

**目的**: PRに紐づく最新のworkflow runを特定

**実行**:
```bash
gh pr checks {pr_number}
```

またはブランチ名から取得:
```bash
gh run list --branch {branch_name} --limit 5
```

**完了条件**: 監視対象のworkflow runを特定
**次のアクション**: 直ちに Step 2（ポーリング監視）へ進む

---

### Step 2: ポーリング監視

**目的**: CIが完了するまで30秒間隔でステータスを監視

**実行**:
- 30秒間隔で `gh run view {run_id}` を実行
- ステータスが `completed` になるまで繰り返し
- 開始から30分経過でタイムアウト

**ステータス判定**:

| ステータス | アクション |
| ---------- | ---------- |
| `queued` / `in_progress` | 30秒待機して再確認 |
| `completed` + `conclusion: success` | Step 3（OK結果）へ |
| `completed` + `conclusion: failure` | Step 3（NG結果）へ |
| 30分経過 | Step 3（TIMEOUT結果）へ |

---

### Step 3: 結果の出力

**目的**: CI結果を定型フォーマットで出力して呼び出し元に返す

**出力フォーマット**: `examples/ci-result.md` を参照

**OKの場合**:
- 成功フォーマットを出力

**NGの場合**:
1. 失敗したジョブ一覧を取得: `gh run view {run_id}`
2. 失敗ジョブのログを取得: `gh run view {run_id} --log-failed`
3. 失敗フォーマットで出力

**TIMEOUTの場合**:
- タイムアウトフォーマットを出力

---

## 入力・出力

### 入力（呼び出し元から受け取る）

| パラメータ | 型 | 説明 |
| ---------- | -- | ---- |
| `pr_number` | number | 監視対象のPR番号 |

### 出力（呼び出し元に返す）

| フィールド | 値 | 説明 |
| ---------- | -- | ---- |
| 結果 | `OK` / `NG` / `TIMEOUT` / `SKIPPED` | CI監視の最終結果 |
| 失敗ジョブ | 配列 or null | 失敗したジョブ名とrun_id |
| エラーログ | 文字列 or null | 失敗ジョブのエラー行 |

---

## 連携スキル

| スキル | 用途 |
| ------ | ---- |
| `/worktree-finish` | 呼び出し元。Step 10でこのスキルを呼び出す |
