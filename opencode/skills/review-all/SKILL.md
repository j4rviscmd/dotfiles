---
name: review-all
description: >-
  このスキルは、ユーザーが「レビューして」「確認して」「チェックして」
  「コード綺麗にして」「リファクタして」「整理して」「フォーマットして」「整形して」
  「ドキュメント生成して」「コメント追加して」と言った場合、または
  コミット前のコード品質向上について話している場合に使用される。
  コード品質チェック・ドキュメント生成・整形を一括実行し、
  スタイルチェック、簡略化、ドキュメンテーション、フォーマットを含む。
model: github-copilot/claude-sonnet-4.6
parameters:
  language:
    description: ドキュメント言語（parent_mode=true時は必須、それ以外は省略時detect-languageで判定）
    required: false
  parent_mode:
    description: 親スキルから呼び出し時にtrue（タスク管理スキップ、エラー時自動スキップ）
    required: false
    default: false
---

# コード品質レビュー（All-in-One）

## パラメータ

| パラメータ | 必須 | 説明 |
| ---------- | ---- | ---- |
| `language` | 条件付き | ドキュメント言語（`parent_mode=true`時は必須、それ以外は省略時detect-languageで判定） |
| `parent_mode` | 否 | 親スキルから呼び出し時にtrue（タスク管理スキップ、エラー時自動スキップ） |

---

## ガードレール（絶対に守ること）

| ルール | 理由 |
| ------ | ---- |
| **自然言語判定は`detect-language`スキルで実行** | doc-generatorの言語を決定するため |
| **最大3回ループ** | code-reviewerの指摘は最大3回まで自動修正 |
| **指定ファイルのみ処理** | 検出された変更ファイルのみを対象とする |
| **ドキュメント削除禁止** | code-simplifierでドキュメントコメントを削除してはならない |
| **全タスク完了まで停止しない** | エラー時のみユーザーに確認（parent_mode時は自動スキップ） |
| **parent_mode時はタスク管理しない** | 親スキル側でタスク管理しているため重複を避ける |
| **parent_mode時はlanguage必須** | 親スキルで判定済みの言語を使用するため |
| **各Rvエージェント並列実行禁止** | 前段の修正に対してレビューをする仕組みのため |

---

## 実行フロー

### Step 0: タスク管理のセットアップ

**`parent_mode: true`の場合はスキップ**

**TaskCreateで以下の順序で作成（並列作成禁止・順序厳守）:**

1. 自然言語判定
2. 変更ファイル検出
3. code-reviewer実行
4. code-simplifier実行
5. doc-generator実行
6. フォーマット実行
7. レビュー完了フラグの設定

**依存関係の設定（TaskUpdateのaddBlockedBy）:**
- 各タスクは前のタスクに依存（2→1, 3→2, ... 7→6）

---

### Step 1: 自然言語判定

**目的**: doc-generatorで生成するドキュメントの言語を決定

**条件分岐**:
- `language`パラメータがある場合 → その値を使用、Step 2へ進む
- `parent_mode=true` かつ `language`未指定 → **エラー終了**（parent_mode時はlanguage必須）
- 上記以外 → detect-languageスキルを実行

**実行方法（detect-languageが必要な場合）**:

```text
Skill tool:
  skill: "detect-language"
```

**判定結果を記憶**: Step 5のdoc-generatorで使用

---

### Step 2: 変更ファイルの検出

**目的**: git statusで未コミットの変更ファイルを特定

**要件**:
- staged/unstaged/untracked すべてを対象
- 除外: `.lock`ファイル、ビルド成果物（dist/, build/, node_modules/）、.git/、.DS_Store

**例**:
```bash
git status --porcelain --untracked-files=all | grep -E '^[AMRC?]' | sed 's/^...//'
```

**ファイル0件時**: タスク2をcompletedにして終了

**重要**: 検出されたファイルを `CHANGED_FILES`（改行区切り）、件数を `FILE_COUNT` として記憶し、以降のステップで使用

---

### Step 3: code-reviewer（ループ付き）

**目的**: コード品質の問題を検出・修正

**実行方法**:

```text
Agent tool:
  subagent_type: "pr-review-toolkit:code-reviewer"
  prompt: |
    以下の未コミットファイルをレビューしてください：

    対象ファイル ({FILE_COUNT}):
    {CHANGED_FILES}

    レビュー観点:
    - コード品質・スタイル違反
    - バグ・ロジックエラー
    - セキュリティ脆弱性

    重要: 指定されたファイルのみレビュー対象とし、他のファイルは調査しないでください。
```

**要件**:
- 最大3回まで自動修正を試みる
- 指摘がなくなれば次へ進む
- 3回でも指摘が残る場合はその旨を報告して次へ進む

**処理フロー**:
1. code-reviewerを実行
2. 指摘があれば自動修正して1に戻る（最大3回まで）
3. 指摘がなければ次へ進む

---

### Step 4: code-simplifier

**目的**: 冗長なコードを簡潔化

**実行方法**:

```text
Agent tool:
  subagent_type: "code-simplifier:code-simplifier"
  prompt: |
    以下の未コミットファイルを簡潔化してください：

    対象ファイル ({FILE_COUNT}):
    {CHANGED_FILES}

    対象: 冗長なコード、複雑な構造
    原則: 機能は変更せず、可読性のみ向上

    重要:
    - 指定されたファイルのみ処理対象
    - ドキュメントコメント（JSDoc/docstring/Javadoc等）は削除禁止
```

---

### Step 5: doc-generator

**目的**: ドキュメントコメントを生成

**実行方法**:

```text
Agent tool:
  subagent_type: "doc-generator"
  prompt: |
    以下の未コミットファイルにドキュメントコメントを生成してください：

    対象ファイル ({FILE_COUNT}):
    {CHANGED_FILES}

    生成対象:
    - エクスポートされた関数・クラス
    - 複雑なロジック（循環複雑度 > 5）
    - 公開API

    形式:
    - TypeScript/JavaScript: JSDoc
    - Python: docstring (PEP 257)
    - Rust: rustdoc (`///`)

    言語: {Step 1で判定した言語}

    重要:
    - 指定されたファイルのみ処理対象
    - 既存のドキュメントコメントは削除禁止
    - 新規生成または更新のみ許可
```

---

### Step 6: フォーマッター実行

**目的**: プロジェクト設定に基づいてフォーマット

**検出ロジック**:

| 言語 | 設定ファイル | コマンド |
| ---- | ------------ | -------- |
| TypeScript/JavaScript | biome.json → Biome | `npx biome check --write .` |
| TypeScript/JavaScript | .prettierrc* → Prettier | `npx prettier --write .` |
| Python | pyproject.toml [tool.ruff] | `ruff format .` |
| Rust | Cargo.toml | `cargo fmt` |
| Lua | stylua.toml | `stylua .` |

設定ファイルがない場合はスキップ。

---

### Step 7: レビュー完了フラグの設定

**目的**: pre-commit hookの無限ループを防止

**要件**:
- `mark-review-done.sh` を実行してレビュー済みフラグを設定
- **parent_mode に関わらず必ず実行**（親スキル経由でもコミット時にhookが発動するため）

**実行方法**:

```bash
~/.claude/hooks/mark-review-done.sh
```

---

## エラー発生時の処理

**通常モード（parent_mode=false）**:
1. 現在のタスクを維持（`status: "in_progress"` のまま）
2. エラー内容を報告
3. AskUserQuestionで次のアクションを確認（再試行/スキップ/中断）

**子スキルモード（parent_mode=true）**:
1. エラー内容をログに記録
2. 自動的にスキップして次のStepへ進む
3. 完了報告にエラー内容を含める

---

## 完了報告

以下の形式でユーザーに報告する（詳細は `examples/completion-report.md`）:

```text
## /review-all 完了

| ステップ | 状態 | 概要 |
|----------|------|------|
| 変更ファイル検出 | ✅ | {FILE_COUNT} ファイル |
| code-reviewer | ✅ | {ループ回数}回 / {修正数}件 |
| code-simplifier | ✅ | {改善箇所数} |
| doc-generator | ✅ | {生成コメント数} |
| フォーマット | ✅ | {実行フォーマッター} |
| レビューフラグ設定 | ✅ | pre-commit hook無限ループ防止 |
```

---

## 注意事項

- レビュー結果は未コミット状態で残る
- `/worktree-finish` で実装変更と合わせてまとめてコミットされる
- `parent_mode=true`の場合はタスク管理を行わず、エラー時は自動スキップして次へ進む

---

## 親スキルからの呼び出し例

```text
Skill tool:
  skill: "review-all"
  parameters:
    language: "日本語"
    parent_mode: true
```

---

## 連携スキル

| スキル | 用途 |
| ------ | ---- |
| `/detect-language` | ドキュメント言語の判定 |
| `/worktree-finish` | レビュー後のコミット・PR作成 |
