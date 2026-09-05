---
name: worktree-start
model: github-copilot/gpt-5-mini
description: 1行以上のコード作成/変更タスクを開始する際に利用。forest cliを使って隔離されたworktreeを作成
---

# 作業コピー作成スキル（セットアップ編）

## このスキルについて

このスキルは **作業コピーのセットアップのみ** を担当します。
`forest start` コマンドを使って、git worktreeベースの独立した作業環境を **1回のBash呼び出し** で作成します。
セットアップ完了後、自動的に `worktree-code` スキルを呼び出して実装フェーズに移行します。

---

## ガードレール（絶対に守ること）

| ルール | 理由 |
| ------ | ---- |
| **`.worktrees/`固定配置** | ディレクトリ選定ロジックは使用しない |
| **プロジェクトルートで実行** | `forest start .` の `.` はcwdに解決されるため、プロジェクトルートにいることが前提 |
| **ブランチはforestが自動作成** | `forest start` が `{name}` ブランチを自動作成する |
| **セットアップ完了後にworktree-codeを呼ぶ** | 実装はworktree-codeスキルで行う |
| **forest startの終了コードを必ず確認** | 0以外はエラー。ユーザーに報告してターン即終了 |

---

## 実行フロー

### Step 0: タスク管理（簡略版）

TaskCreateで3項目を作成:

|  #  |          content           | status  |
| --- | -------------------------- | ------- |
| 1   | worktree名の生成           | pending |
| 2   | セットアップ実行           | pending |
| 3   | worktree-code呼び出し      | pending |

---

### Step 1: worktree名の自動生成

会話コンテキストから実装内容を分析して名前を生成。

**ルール**:
- 短く説明的な英単語（小文字ハイフン区切り）
- 最大3単語
- 機能を端的に表現
- `/` やスペースは使用しない

**例**:

| ユーザーの要求 | worktree名 |
| -------------- | ---------- |
| ユーザー認証機能を追加して | `auth` |
| ダッシュボードのバグを修正 | `dashboard-fix` |
| APIのレート制限を実装 | `rate-limit` |
| GitHub Projects連携を実装 | `gh-projects` |

---

### Step 2: forest start の実行

**1回のBash呼び出しでセットアップ全体を実行:**

```bash
forest start . {worktree_name}
```

**forest startが実行する処理:**
1. base_pathの存在確認
2. nameのkebab-case検証
3. `git worktree add -b {name} .worktrees/{name} HEAD` でgit管理ファイルをチェックアウト（ブランチ作成＋チェックアウトを一括実行）
4. worktree側の `.gitignore` に `.worktrees/` を追加
5. `.forest.toml` がworktreeにない場合、テンプレートを自動作成
6. `[start].share` パターンに基づいて非git管理ファイル（`.env`, `node_modules` 等）をコピー
7. `.forest.toml` の `[start].commands` があればworktree内で実行

**出力:**
- stdout: `.worktrees/{name}` （相対パス）。**この値を変数として記憶し、Step 3で使用する**
- stderr: 進捗メッセージ

**成功時のセッション追跡（必須）:**

`forest start`が成功（終了コード0）した直後に、セッション情報を`/tmp`に記録する:

```bash
REPO_ROOT="$(pwd)"
REPO_HASH=$(echo "$REPO_ROOT" | md5 -q)
SESSION_FILE="/tmp/.claude-active-sessions-$REPO_HASH"
TMUX_SESSION=$(tmux display-message -p '#S' 2>/dev/null || echo "none")
echo -e "{worktree_name}\t$REPO_ROOT\t$(date -u +%Y-%m-%dT%H:%M:%SZ)\t$TMUX_SESSION\t$$" >> "$SESSION_FILE"
```

各フィールドはTSV形式（1行1セッション）: `{worktree_name}\t{project_path}\t{created_at}\t{tmux_session}\t{pid}`

**終了コード:**

| コード | 意味 |
| ------ | ---- |
| 0 | 成功 |
| 1 | base_pathが存在しない |
| 2 | nameがkebab-caseではない |
| 3 | worktreeが既に存在する |
| 4 | git worktreeの作成に失敗（同名ブランチ既存、gitdirの破損、書き込み権限不足等を含む） |
| 5 | startコマンドの実行に失敗 |
| 13 | `.forest.toml` のshareパターンが不正 |

**エラー時の処理:**
1. stderrのエラーメッセージをユーザーに報告
2. AskUserQuestionで次のアクションを確認
3. ターン終了

---

### Step 3: worktree-codeの呼び出し

**目的**: 実装フェーズに移行

**要件**:
- Skill toolを使用して `worktree-code` を呼び出す
- args形式: `{worktree_name}|{implementation_summary}`
- worktree-code側は `|` で分割し、第1要素を作業コピー名、第2要素を実装内容として解釈する

**例**:

```text
Skill tool: skill="worktree-code", args="auth|ユーザー認証機能の実装"
```

---

## エラー発生時の処理

1. TaskUpdateのタスクを維持
2. forest startのエラー出力をユーザーに報告
3. AskUserQuestionで次のアクションを確認

---

## 連携スキル

| スキル | 用途 |
| ------ | ---- |
| `/worktree-code` | セットアップ完了後に自動呼び出し（実装〜修正サイクル） |
| `/worktree-finish` | 作業完了後にユーザーが実行 |
