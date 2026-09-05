---
name: issue-create
description: >-
  このスキルは、ユーザーが「issueを作成」「起票」「報告」「登録」「バグ報告」
  「機能要望」「新規issue」「GitHub issueを作って」と言った場合、または
  バグ報告、機能要望、ドキュメント改善、技術的負債の記録について話している場合に使用される。
  会話内容からGitHub issueを自動生成・作成し、重複チェック、テンプレート自動選択、
  ラベル自動付与、オーナーへのアサインを含む。

argument-hint: [issue-title]
model: github-copilot/claude-sonnet-4.6
---

<!--
## 日本語固定の根拠

issueの言語はPR/コミットメッセージとは別物:
- OSSプロジェクト：PRは英語、issueはユーザーの母国語（日本語など）というケースもあり得る
- detect-languageはPRベースの判定のため、issueには不適切
- ユーザーが日本人のため、issueは常に日本語で作成
-->

# GitHub Issue作成

## ゴール

会話内容からGitHub issueを自動生成・作成する

## 実行フロー

### 1. issue概要の把握

会話内容から問題点や要望を抽出。不明瞭であればAskUserQuestionで詳細を確認

### 2. 重複チェック

gh CLIで類似issueを検索。類似度が高い場合は作成を中止し、既存issueを通知。

### 3. テンプレート選択

`.github/ISSUE_TEMPLATE/` ディレクトリから内容に応じて適切なテンプレートを自動選択。

**判定基準**:
- バグ報告 → `bug_report.md`
- 機能要望 → `feature_request.md`
- その他 → `custom.md` またはデフォルト形式

### 4. GitHub Projects紐付け

https://github.com/users/j4rviscmd/projects/1 に紐づけること

### 5. issue内容の生成

会話内容から以下を抽出してissueタイトル・本文を生成（**常に日本語**）：

- **タイトル**: 問題を簡潔に表現
- **説明**: 問題の詳細、再現手順（バグの場合）
- **期待される動作**: 本来どうあるべきか
- **環境情報**: 必要に応じて自動追加

### 6. ラベル・アサイン設定

**ラベル**: 内容に応じて自動選択（最大5つ、最低1つ）
- バグ → `bug`, `priority: high`
- 新機能 → `enhancement`, `feature`
- ドキュメント → `documentation`
- 技術的負債 → `tech-debt`, `refactor`

**アサイン**: リポジトリのownerを自動設定

### 7. プレビューと承認

生成したissue内容をプレビュー表示。ユーザーが承認したらgh CLIで作成。

### 8. 完了報告

```text
## Issue作成完了 ✅

- **タイトル**: {issue-title}
- **URL**: {issue-url}
- **ラベル**: {labels}
- **アサイン**: @{owner}
```

## エラー処理

- 重複issue検出 → 作成中止、既存issueを通知
- テンプレート/ラベル取得失敗 → 汎用フォーマット/ラベルなしで作成
- GitHub APIエラー → 内容表示、再試行可能

## 制約事項

- ユーザー承認後に作成
- 重複時は新規作成中止
- ラベル最大5個
