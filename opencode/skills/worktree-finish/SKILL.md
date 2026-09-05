---
name: worktree-finish
model: github-copilot/claude-opus-4.6
description: ユーザが動確完了時のみに利用。作業内容をレビュー・コミットしてPRを作成し、CI監視・PRマージ確認を経て、最後にworktreeを削除する
---

# worktreeタスク完了

## 前提条件

- ユーザーによる動作確認が完了していること

## ガードレール（絶対に守ること）

| ルール | 理由 |
| ------ | ---- |
| **言語判定は`/detect-language`スキルで実行** | README.mdを直接読むと誤判定の原因になる |
| **PR作成は`/create-pr`スキルで実行** | ラベル自動設定・CI監視・失敗時修正が含まれるため |
| **`/review-all`はworktree内で実行** | メインディレクトリで実行してもworktree内のファイルは変更されない |
| **ユーザー動作確認後のみ実行** | 未確認のコードをコミット・PRしない |
| **mainへの直接コミット禁止** | 必ずfeatureブランチを作成してからコミット |
| **機密情報チェックはコミット前に必須** | APIキーや認証情報の誤コミットを防止 |
| **pushはworktree内から実行** | worktree内からgitコマンドが正常に動作するため、削除前にpush可能 |
| **`forest finish`はベースディレクトリから実行** | forest finishはcwdをベースとして判定する仕様 |

---

## 実行フロー

<!-- DATA FLOW SUMMARY: State is passed between steps via "memory" (variables
     the agent must retain across steps), not via files or return values.
     Key variables and their producers/consumers:

     Variable          | Produced by | Consumed by
     ------------------|-------------|------------------------------------------
     language          | Step 1      | Steps 4, 6.5, 8
     {name}            | Step 5      | Steps 11, 12 (session cleanup)
     conflict_resolved | Step 6      | Step 6.5
     conflict_files    | Step 6      | Step 6.5
     {pr_number}       | Step 8      | Steps 9, 10
-->

> **重要**: Step 0〜12を**一気通貫で連続実行**する（Step 12の完了報告まで含む）。各Step完了時の停止・待機・ユーザー報告は禁止。
> エラー発生時のみAskUserQuestionで確認し、それ以外は最後まで実行し続けること。

### Step 0: タスク管理のセットアップ

<!-- NOTE: Task creation order determines the display order in the task tracker.
     Creating tasks out of order causes the task list to display in an unexpected
     sequence, which confuses the user. Always create sequentially as listed below. -->

**前提処理**: TaskListで既存タスクを確認し、あればすべて`status: "deleted"`でクリーンアップ。

**TaskCreateで以下の順序で作成（並列作成禁止・順序厳守）:**

1. プロジェクト言語判定
2. レビューの実行
3. 機密情報チェック
4. コミットの作成
5. ブランチのリネーム（prefix付与）
6. mainの同期・マージ
7. デグレチェック ※コンフリクト解消時のみ実行・スキップ条件あり
8. push（worktree内から）
9. PRの作成（worktree内から）
10. CI監視(GitHub ActionsなどのCIが成功するまで監視)
11. PRのマージ確認
12. ベースディレクトリに戻る
13. worktreeの削除（forest finish）

**依存関係の設定（TaskUpdateのaddBlockedBy）:**
- 各タスクは前のタスクに依存（2→1, 3→2, ... 13→12）

---

### Step 1: プロジェクト言語判定

<!-- STATE: The detected language is carried forward as a parameter to multiple
     downstream steps: commit message generation (Step 4), degrde fix commit
     (Step 6.5), PR body (Step 8). Failing to execute this step corrupts all
     subsequent user-facing output. -->

**目的**: コミットメッセージ・PR本文の言語を決定

**実行**: Skill toolで `detect-language` を呼び出す

**完了アクション**: TaskUpdateで`status: "completed"`に更新、判定言語を記憶、即座にStep 2へ。

**【絶対禁止】**:
- `detect-language` スキルを呼び出さずに次のステップに進む行為
- スキル完了後に停止・待機・ユーザー報告する行為
- README.mdを直接読む行為

---

### Step 2: レビューの実行

**目的**: コード品質チェック・ドキュメント生成・整形

**実行**: worktree内で Skill toolで `review-all` を呼び出す

```text
Skill tool:
  skill: "review-all"
  parameters:
    language: {Step 1で判定した言語}
    parent_mode: true
```

**完了アクション**: review-allのSkill呼び出しから制御が戻った直後に、TaskUpdateで`status: "completed"`に更新、即座にStep 3へ。

**【絶対禁止】**:
- worktree外で実行する行為
- review-all完了後に停止・待機・ユーザー報告する行為
- review-allの結果テーブル・完了メッセージ・サマリーを出力する行為

**重要**: 必ずworktree内で実行すること。`parent_mode: true`により、review-all側ではタスク管理を行わず、エラー時は自動スキップする。

---

### Step 3: 機密情報チェック

**目的**: コミット前に機密情報の混入を検出・防止

**チェック項目**:

| カテゴリ | チェック内容 |
| -------- | ------------ |
| シークレット | API Key, Token, Password, Private Key, AWS Credential, OAuth Secret などのパターンマッチ |
| .gitignore漏れ | .env, credentials, id_rsa などが .gitignore に含まれているか |
| ハードコード | URL埋め込み認証情報、IPアドレス、個人情報のハードコード |

**実行手順**:

1. `git diff --name-only` と `git ls-files --others --exclude-standard` で変更ファイル一覧を取得
2. 変更ファイルに対して以下のGrep検索を実行（バイナリ・画像ファイルは除外）:
   - シークレットパターン: `password`, `secret`, `api_key`, `apikey`, `token`, `private_key`, `aws_access_key`, `authorization`, `bearer`, `client_secret`, `credentials`
   - .gitignore漏れ: 変更ファイルに `.env` 系ファイルが含まれる場合、`.gitignore` に該当パターンが存在するか確認
   - ハードコード: `http://.*:.*@`, IPアドレスパターン（`\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}`）
3. 検出結果がない場合 → 完了アクションへ
4. 検出結果がある場合 → 下記「検出時の処理」へ

**検出時の処理**:
1. 検出内容をカテゴリ別に報告
2. AskUserQuestionで以下の選択肢を提示:
   - 修正して再チェック（推奨）
   - 誤検知としてスキップ
   - 処理を中断
3. 「修正して再チェック」選択時は修正後、再度Step 3から実行
4. 「誤検知としてスキップ」選択時は完了アクションへ
5. 「処理を中断」選択時はエラー発生時の処理に従う

**完了アクション**: TaskUpdateで`status: "completed"`に更新、即座にStep 4へ。

**【絶対禁止】**:
- 検出結果があるのにスキップせずに次のステップに進む行為
- ユーザーに確認せずにファイルを自動修正する行為

---

### Step 4: コミットの作成

**目的**: 実装変更とレビュー結果をまとめてコミット

**要件**:
- Step 1で判定した言語を使用してコミットメッセージを生成
- Conventional Commits形式
- すべての変更（untracked含む）をステージングしてコミット
- 変更がない場合は警告を表示してスキル全体を終了（空コミット・空PRを防止）

**完了アクション**: TaskUpdateで`status: "completed"`に更新、即座にStep 5へ。

**コミットタイプ**:

| 変更内容 | タイプ | 例 |
| -------- | ------ | -- |
| 新機能の追加 | `feat:` | `feat: ユーザー認証を追加` |
| バグ修正 | `fix:` | `fix: 表示崩れを修正` |
| リファクタリング | `refactor:` | `refactor: APIクライアントを整理` |
| ドキュメント変更 | `docs:` | `docs: READMEを更新` |
| テスト追加・修正 | `test:` | `test: 認証テストを追加` |
| ビルド・設定・ツール | `chore:` | `chore: CI設定を更新` |

---

### Step 5: ブランチのリネーム（prefix付与）

<!-- STATE: {name} (the pre-rename branch name) is a critical value consumed by
     Step 11 (base directory navigation), Step 12 (forest finish), and the
     session file cleanup in Step 12. After `git branch -m`, the current branch
     name includes the prefix, so {name} can no longer be obtained from git.
     It MUST be captured before the rename command executes. -->

**前提**: 現在のブランチ名（`git branch --show-current`）を記憶する。これが `forest finish` で使用する `{name}` である。

**セッション間の引き継ぎ**: worktree-code→worktree-finishは別セッションになるため、`{name}` は自動では引き継がれない。worktree-finish起動時に `git branch --show-current` でブランチ名を取得すること。ただし **Step 5でリネーム後はprefix付きになるため、リネーム前の名前を取得できない**。このため以下のいずれかの方法で `{name}` を特定する:
1. worktreeのディレクトリ名から取得: `basename $(git rev-parse --show-toplevel)` はリネームに関わらず元のまま（例: `.worktrees/auth` → `auth`）
2. セッション追跡ファイル（`/tmp/.claude-active-sessions-*`）から該当エントリを検索

**目的**: worktree-startで作成されたブランチ（prefixなし）に、変更内容に応じたprefixを付与してリネーム

**ブランチ名形式**: `{prefix}/{name}`

**実行**: `git branch -m {current_name} {prefix}/{current_name}`

**完了アクション**:
1. `{name}`（リネーム前のブランチ名）を記憶（Step 12の `forest finish` で使用）
2. TaskUpdateで`status: "completed"`に更新、即座にStep 6へ。

**プレフィックス判定**:

| 変更内容 | プレフィックス |
| -------- | -------------- |
| 新機能追加 | `feat` |
| バグ修正 | `fix` |
| リファクタリング | `refactor` |
| ドキュメント更新 | `docs` |
| その他 | `chore` |

**例**: ブランチ名`auth` + 新機能 → リネーム後`feat/auth`

**【絶対禁止】**:
- `git branch -m` 実行後にブランチ名を取得する行為（prefix付きの名前が返されるため、`{name}`として不正になる）
- `{name}` を記憶せずにリネームを実行する行為

---

### Step 6: mainの同期・マージ

<!-- STATE: This step produces two variables consumed by Step 6.5:
     - conflict_resolved (bool): whether any merge conflicts were auto-resolved
     - conflict_files (list[str]): files involved in conflicts, obtained via
       `git diff --name-only --diff-filter=U` before resolution
     Step 6.5 skips entirely when conflict_resolved is false. -->

**目的**: 並列開発時の競合を事前に解消

**実行手順**:

1. **fetch + merge**:
   ```bash
   git fetch origin main
   git merge origin/main
   ```

2. **失敗時**: エラー発生時の処理に従い、AskUserQuestionで確認

**コンフリクト発生時**:
- AIが自動解決

**完了アクション**:
1. マージ結果を記憶（後続ステップで参照）:
   - コンフリクト発生・自動解決時: `conflict_resolved = true`、解消ファイルを `conflict_files` として記憶（`git diff --name-only --diff-filter=U` で取得）
   - コンフリクトなし: `conflict_resolved = false`
2. TaskUpdateで`status: "completed"`に更新、即座にStep 6.5へ。

---

### Step 6.5: デグレチェック

**目的**: コンフリクト自動解決によって生じたデグレ（機能退行）を検出・自動修正する

#### ガードレール

<!-- DESIGN RATIONALE: This step exists because `git merge` auto-resolution may
     silently discard logic from either branch. The re-analysis is capped at one
     retry to prevent infinite fix-analyze cycles. If degradation persists after
     a single auto-fix attempt, the agent escalates to the user. -->

| ルール | 理由 |
| ------ | ---- |
| **`conflict_resolved = false` ならば即スキップ** | コンフリクトなしマージに対する不要な分析を防止 |
| **自動修正はデグレ箇所のみに限定** | 過剰修正によるコード破損を防止 |
| **修正後は必ず追加コミットを作成** | 修正履歴を残してPRレビュー可能にする |
| **再分析は1回のみ実施** | 無限ループ防止。2回目でもデグレが残る場合はAskUserQuestionで確認 |
| **ユーザー確認なしで自動修正を実行** | 一気通貫フローを維持する |

---

#### 実行手順

**【STEP A】スキップ判定（最初に必ず実施）**

`conflict_resolved` の値を確認する:

- `conflict_resolved = false` の場合:
  1. TaskUpdateで`status: "completed"`に更新、即座にStep 7へ
  2. 以降の手順はすべてスキップ

- `conflict_resolved = true` の場合:
  - 以降の手順を実行する

---

**【STEP B】並行バージョン比較のデータ取得**

`conflict_files`（Step 6で記憶したコンフリクト解消ファイルのリスト）の各ファイルについて、マージ前後の両バージョンを取得:

```bash
# マージ前（origin/main側）のバージョン
git show origin/main:<conflict_file>

# マージ後（HEAD）のバージョン
git show HEAD:<conflict_file>
```

`conflict_files` が不明な場合は `git diff --name-only origin/main HEAD` で変更ファイルを特定。

**ファイルサイズが大きい場合の最適化**: ファイルが500行を超える場合は、`git diff origin/main HEAD -- <file>` で変更箇所を特定し、その前後50行のスコープに絞って両バージョンを取得。

---

**【STEP C】AIによる並行比較分析**

STEP Bで取得した両バージョンを比較し、「origin/mainに存在してHEADに存在しない」内容を検出する:

| チェック観点 | デグレとみなす条件 |
| ---------- | ---------------- |
| **関数・クラス・メソッドの消失** | `origin/main` に存在した定義ブロックが `HEAD` から完全に削除されている |
| **export済みAPI・シンボルの消失** | `export` されていたシンボルが `HEAD` で消えており、別ファイルへの移動も確認できない |
| **処理ロジックの欠落** | 条件分岐・ループ・エラーハンドリング・アルゴリズムが `origin/main` から削除されており、同等ロジックが他の場所に存在しない |
| **意図しない機能喪失** | 上記3観点に当てはまらないが、`origin/main` にあった振る舞い・機能・設定が `HEAD` で失われていると判断される箇所 |

**分析の実行方法**: 各 `conflict_file` ごとに Agent tool（subagent_type: `feature-dev:code-reviewer`）を並行起動し、両バージョンを比較させる。各エージェントには以下を提示する:
- `origin/main` 側のファイル内容
- `HEAD` 側のファイル内容
- 上記4観点のチェック指示

**分岐**:
- デグレ検出なし → **【STEP E】完了アクション**へ
- デグレあり → **【STEP D】自動修正フロー**へ

---

**【STEP D】自動修正フロー**

1. **修正実施**: デグレ箇所をファイルに直接修正する
   - 削除された関数・クラス・メソッドを元の位置に復元
   - 消失した `export` シンボルを追加
   - 欠落した処理ロジックを適切な位置に挿入
   - 意図しない機能喪失箇所を復元
   - **修正範囲はデグレ箇所のみ**（それ以外のコードは変更しない）

2. **追加コミット作成**: 修正後に変更をステージングしてコミット
   - コミットメッセージ形式（Step 1で判定した言語を使用）:
     - 日本語例: `fix: コンフリクト解消によるデグレを修正`
     - 英語例: `fix: restore lost logic from merge conflict resolution`

3. **再分析（1回限り）**: 【STEP C】の分析を再実行する
   - 再分析でデグレなし → **【STEP E】完了アクション**へ
   - 再分析でもデグレあり → エラー発生時の処理に従い、AskUserQuestionで「手動修正/スキップ/中断」を確認する

---

**【STEP E】完了アクション**: TaskUpdateで`status: "completed"`に更新、即座にStep 7へ。

**【絶対禁止】**:
- `conflict_resolved` フラグを確認せずにチェックを実行する行為
- デグレ検出時にユーザー確認を挟む行為（自動修正を先に試みること）
- 再分析を2回以上繰り返す行為
- 修正後にコミットを作成しない行為

---

### Step 7: push（worktree内から）

**目的**: ブランチをリモートにプッシュ

**要件**: worktree内から `git push -u origin {branch_name}` を実行

**重要**: worktree内から `git push` は正常に動作する。`forest finish` で削除される前にpushを完了すること。

**完了アクション**: TaskUpdateで`status: "completed"`に更新、即座にStep 8へ。

---

### Step 8: PRの作成（worktree内から）

<!-- STATE: {pr_number} extracted from the create-pr result is consumed by
     Step 9 (CI monitoring) and Step 10 (merge confirmation). The forest copy
     must still exist at this point so that the create-pr skill can read the
     correct branch name from the local git repository. -->

**目的**: worktree内の作業ブランチ上でPRを作成

**実行**: worktree内で Skill toolで `create-pr` を呼び出す

**重要**: worktreeはまだ存在しており、作業ブランチ上にいるため、`create-pr`スキルは`git branch --show-current`で正しいブランチ名を取得できる。

**完了アクション**:
1. create-prの結果からPR番号（`{pr_number}`）を抽出して記憶（Step 9で使用）
2. TaskUpdateで`status: "completed"`に更新
3. 即座にStep 9へ

**【絶対禁止】**:
- GitHub MCPを直接呼び出す行為
- Webブラウザで手動PR作成を促す行為
- create-prスキルを呼び出さずにPRを作成する行為
- スキル完了後に停止・待機する行為

---

### Step 9: CI監視

**目的**: GitHub ActionsなどのCIが成功するまで監視

**実行**: Skill toolで `monitor-pr-ci` を呼び出す（Step 8で記憶したPR番号を引数として渡す）

**完了アクション**:
1. `monitor-pr-ci`スキル結果を受け取る
2. CI成功: TaskUpdateで`status: "completed"`に更新、即座にStep 10へ
3. CI失敗: 以下の自動修正ループを実行（**最大2回**）:
   - `gh run view {run_id} --log-failed` で失敗ログを取得
   - 失敗原因を分析して自動修正（worktree内で修正→`git add`→`git commit`→`git push`）
   - `monitor-pr-ci` を再実行
   - 上記を最大2回まで繰り返し
   - 2回の自動修正でもCIが成功しない場合 → AskUserQuestionで次のアクションを確認（手動修正/スキップ/中断）

**【絶対禁止】**:
- monitor-pr-ciスキルを呼び出さずにCIを監視する行為
- スキル完了後に停止・待機する行為

---

### Step 10: PRのマージ確認

**目的**: CI通過後にユーザーへPRマージの可否を確認

**実行**: AskUserQuestionでユーザーにマージするか確認

```text
選択肢:
- マージする（推奨）
- マージしない（後で手動マージ）
```

**「マージする」選択時**:
1. `gh pr merge {pr_number} --squash`（またはプロジェクトの慣習に合わせたマージ方法）を実行
2. マージ完了を確認

**「マージしない」選択時**: 何もせず次のStepへ

**完了アクション**: TaskUpdateで`status: "completed"`に更新、即座にStep 11へ。

---

### Step 11: ベースディレクトリに戻る

<!-- WHY THIS STEP EXISTS: `forest finish` resolves the worktree path relative
     to the current working directory (cwd), NOT relative to the worktree itself.
     Running it from inside the forest copy would fail to locate the worktree.
     The path is computed by traversing two directories up from the worktree
     root: .worktrees/{name} -> project root. -->

**目的**: `forest finish`を実行するためにベースプロジェクトディレクトリに移動

**要件**: ベースプロジェクトのパスを特定して移動（`cd`）

**パスの特定方法**: worktreeのパス（例: `/project/.worktrees/my-app_auth`）から`.worktrees/`の親（`/project`）をベースパスとして計算:

```bash
cd "$(git rev-parse --show-toplevel)/../.."  # .worktrees/{name} から2階層上
```

**重要**: Step 5で記憶した `{name}`（リネーム前のブランチ名）を使って、Step 12で `forest finish` を実行する。`git branch --show-current` はprefix付きの名前を返すため、Step 5で記憶した名前を使用すること。

**完了アクション**: TaskUpdateで`status: "completed"`に更新、即座にStep 12へ。

---

### Step 12: worktreeの削除

**目的**: 作業完了したworktreeを削除

**要件**: ベースディレクトリから `forest finish {name}` を実行

```bash
forest finish {name}
```

- `{name}` はworktree-startで指定したname（Step 5で記憶したprefixなしのブランチ名）
- `forest finish`はcwdをベースとしてworktreeを特定する仕様のため、**必ずベースディレクトリから実行**すること
- `forest finish`が内部で実行する処理: (1) `.worktrees/<name>/.git` の存在確認、(2) 未プッシュコミット検査、(3) `git worktree remove`、(4) `git pull`（CLI組み込み処理、`[finish].commands`とは別）、(5) マージ済みブランチの自動削除、(6) `[finish].commands` をベースディレクトリで実行

**成功時のセッション追跡ファイル削除（必須）:**

<!-- The session tracking file is created by worktree-start and lives at a path
     derived from the repository root (MD5-hashed). Each line is a TSV entry
     representing one active worktree session. After `forest finish` succeeds,
     the entry for {name} is removed. If the file becomes empty after removal,
     it is deleted entirely to avoid leaving stale state. -->

`forest finish`が成功した直後に、セッション追跡ファイルから該当エントリを削除する。
`{name}` はStep 5で記憶したリネーム前のブランチ名（worktree-startの `{worktree_name}` と同じ値）。

記録フォーマットはworktree-startを参照（TSV形式: `{worktree_name}\t{project_path}\t{created_at}\t{tmux_session}\t{pid}`）。

```bash
REPO_ROOT="$(pwd)"
REPO_HASH=$(echo "$REPO_ROOT" | md5 -q)
SESSION_FILE="/tmp/.claude-active-sessions-$REPO_HASH"
if [ -f "$SESSION_FILE" ]; then
  awk -F'\t' '$1 != "{name}"' "$SESSION_FILE" > "${SESSION_FILE}.tmp" && mv "${SESSION_FILE}.tmp" "$SESSION_FILE"
  [ ! -s "$SESSION_FILE" ] && rm "$SESSION_FILE"
fi
```

**完了アクション**:
1. TaskUpdateで`status: "completed"`に更新
2. すべてのタスクを`status: "deleted"`でクリーンアップ
3. 完了報告（下記フォーマット参照）を出力して終了

---

## worktree名の自動検出

<!-- This section describes the fallback logic for identifying which forest copy
     to operate on when the agent is invoked without an explicit name argument.
     The primary path (inside a forest copy) relies on the git branch name.
     The secondary path (in the base directory) lists worktrees and picks the
     most recently modified one, then confirms with the user. -->

| 状況 | 検出方法 |
| ---- | -------- |
| worktree内にいる | `git branch --show-current` でブランチ名を取得。**Step 5でリネーム前の名前を記憶すること**（リネーム後はprefix付きになり、`forest finish`で使用できない） |
| ベースディレクトリにいる | `forest list` で一覧取得後、`ls -lt .worktrees/` で更新日時順にソートして最新を検出 |

複数ある場合は最新を提案して確認。

---

## エラー発生時の処理

<!-- ERROR HANDLING STRATEGY: Every step in the execution flow shares this
     single error handling protocol. On failure, the current task stays
     in_progress (never auto-completed), the error is reported, and the user
     chooses from retry/skip/abort. This ensures no step is silently marked
     complete when it partially failed. -->

1. 現在のタスクを維持（`status: "in_progress"` のまま）
2. エラー内容を報告
3. AskUserQuestionで次のアクションを確認（再試行/スキップ/中断）

### `forest finish` 失敗時のexit code別対処

| exit code | 原因 | 対処 |
| --------- | ---- | ---- |
| 6 | `.worktrees/`が見つからない | cwdがベースディレクトリでない。Step 11からやり直す |
| 7 | worktreeが見つからない | `{name}` が間違っている可能性。`forest list` で確認して再試行 |
| 8 | finishコマンドの実行失敗 | `.forest.toml` の `[finish].commands` を確認。コマンドを修正して再試行 |
| 10 | `git pull`の失敗 | ネットワークやコンフリクトの可能性。手動で `git pull` してから再試行 |
| 11 | `git worktree remove`の失敗 | `git worktree remove --force` を手動実行してから再試行 |
| 12 | 未プッシュコミットが検出された | Step 7のpushが不完全だった可能性。手動でpushしてから再試行 |

---

## 完了報告

以下の形式でユーザーに報告する（詳細は `examples/completion-report.md`）:

```text
worktree(.worktrees/{worktree_name})での作業を終了しました
タスク概要: {task_summary}

作業完了情報:
- ブランチ: {branch_name}
- コミット: {commit_hash}
- レビュー: /review-all 完了
- 機密情報チェック: 完了（問題なし）
- 削除ファイル数: {deleted_files_count}
- worktree: 削除済み
- push: 完了
- PR: 作成完了
- CI: {ci_status}

PR番号: #{number}
{html_url}
```

---

## 連携スキル

| スキル | 用途 |
| ------ | ---- |
| `/worktree-start` | worktreeの作成、セットアップ |
| `/review-all` | コード品質チェック |
| `/create-pr` | PR作成（ラベル自動設定・CI監視含む） |
| `/detect-language` | 言語判定（.language → 既存PR → README → ユーザー確認） |
| `/monitor-pr-ci` | CI監視（GitHub Actionsの完了待ち・結果報告） |
