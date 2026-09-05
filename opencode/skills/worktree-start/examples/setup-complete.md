# セットアップ完了時の出力例

## 想定シチュエーション

ユーザー: 「ユーザー認証機能を追加して」

## setup.shの出力例

```
[STAGE: validate] .gitignore検証を開始
[OK: validate] .gitignore検証完了
[STAGE: detect-branch] デフォルトブランチを検出
[OK: detect-branch] デフォルトブランチ: main
[STAGE: create] worktreeを作成中: /path/to/repo/.worktrees/auth
Preparing worktree (detached HEAD abc1234)
HEAD is now at abc1234 feat: some commit message
[OK: create] worktree作成完了: /path/to/repo/.worktrees/auth
[STAGE: copy-env] 環境設定ファイルをコピー中
  コピー: .env
  コピー: .envrc
[OK: copy-env] 2件の環境設定ファイルをコピー
[STAGE: setup-deps] 依存関係をインストール中
  検出: package.json
  実行: bun install
bun install v1.x.x
2 packages installed [28.00ms]
[OK: setup-deps] 依存関係のインストール完了

[DONE] worktreeセットアップ完了
  worktree名: auth
  パス: /path/to/repo/.worktrees/auth
  ベース: origin/main
```

## エラー時の出力例

```
[STAGE: validate] .gitignore検証を開始
[ERROR: validate] .worktrees/ が .gitignore に含まれていません
[ACTION: validate] .gitignore に .worktrees/ を追加してコミットしてください
```

## この後の動作

setup.shが `[DONE]` で完了したら、worktree-codeスキルが自動的に呼び出され、実装フェーズに移行します。
