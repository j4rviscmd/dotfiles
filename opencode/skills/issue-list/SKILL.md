---
description: GitHubのissueリストを表示（最大10件、更新日時順）
context: fork
argument-hint: [open|closed|all]
model: github-copilot/gpt-5-mini
name: issue-list
---

# GitHubのIssueリストを表示

## リポジトリ情報の取得

現在のGitリポジトリのURLから、オーナーとリポジトリ名を特定してください：

- リポジトリURL: !`git remote get-url origin`

上記URLから `owner` と `repo` を抽出してください。
例: `https://github.com/j4rviscmd/opencode-discord-notify.git` → owner: `j4rviscmd`, repo: `opencode-discord-notify`

## 取得条件

**重要**: `mcp__github__search_issues` ツールを使用し、**PRを除外**してください。

**検索クエリの構築**：
- 基本クエリ: `repo:{owner}/{repo} is:issue`
- 状態フィルタ:
  - 引数なし、または "open": `is:open` を追加
  - "closed": `is:closed` を追加
  - "all": 状態フィルタなし

**例**：
- open issues: `repo:owner/repo is:issue is:open`
- closed issues: `repo:owner/repo is:issue is:closed`
- all issues: `repo:owner/repo is:issue`

**ソート・表示設定**：
- 表示件数: 10件（perPage: 10）
- ソート: `sort: "updated"`, `order: "desc"`（更新日時順、新しい順）

## 表示フォーマット

### 見出し

状態に応じて見出しを表示してください：
- Open Issues の場合: "📋 Open Issues ({件数}件)"
- Closed Issues の場合: "📋 Closed Issues ({件数}件)"
- All Issues の場合: "📋 All Issues ({件数}件)"

### Issue一覧

**重要**: 各issueを**2行構成**で出力してください。

**1行目**: 状態アイコン + issue番号 + タイトル（プレーンテキスト）
**2行目**: インデントしたMarkdownリンク

**フォーマット**：
```
{状態アイコン} **#{number}** {title}
   [{title}]({html_url})
```

**状態アイコン**：
- state が "open" の場合: 🟢
- state が "closed" の場合: 🔴

**必須要素**：
- `{number}`: issueオブジェクトの`number`フィールド
- `{title}`: issueオブジェクトの`title`フィールド（**必須**）
- `{html_url}`: issueオブジェクトの`html_url`フィールド

**正しい出力例**：
```
🟢 **#123** ログイン機能のバグ修正
   [ログイン機能のバグ修正](https://github.com/owner/repo/issues/123)

🔴 **#122** ドキュメント更新
   [ドキュメント更新](https://github.com/owner/repo/issues/122)
```

**注意**：
- 1行目はプレーンテキストでタイトルを表示（`{title}` フィールドを使用）
- 2行目は3スペースでインデントし、`{html_url}` を使ったMarkdownリンク形式で表示
- 各issueの間に空行を入れること
- **PRは除外され、純粋なissueのみが表示されます**

### 該当なしの場合

issueが0件の場合は「該当するissueはありません」と表示してください。

### Gitリポジトリでない場合

現在のディレクトリがGitリポジトリでない場合、または `git remote get-url origin` が失敗した場合は、「このディレクトリはGitHubリポジトリではありません」と表示してください。

## 引数の処理

`$ARGUMENTS` に基づいて検索クエリを構築してください：

- 引数なし、または "open":
  - クエリ: `repo:{owner}/{repo} is:issue is:open`
  - 見出し: "📋 Open Issues"

- "closed":
  - クエリ: `repo:{owner}/{repo} is:issue is:closed`
  - 見出し: "📋 Closed Issues"

- "all":
  - クエリ: `repo:{owner}/{repo} is:issue`
  - 見出し: "📋 All Issues"

引数が不正な場合（open/closed/all以外）は、openとして処理してください。
