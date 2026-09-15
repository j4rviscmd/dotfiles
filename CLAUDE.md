# CLAUDE.md

個人用dotfilesリポジトリ。

- 個人名や機密情報はコミットしないこと
- すべての作業は日本語で行うこと
  - issue
  - pull request
  - コメントアウト
- `main`ブランチで直接作業を許容
  - pull request/featureブランチ作成は不要
- 作業開始時には`worktree-start`スキルを発動する必要はない
- ヒトによる動確前には`review-all`スキルを発動すること
  - review対象ファイルは作業ファイルのみを指定すること
  - コミット前のコミットメッセージの確認は不要
  - コミット時にはプッシュも行うこと
  - `lazy-lock.json`もコミット対象
- `~/.config`にシンボリックシンクして運用している
  - このrepo資材を操作すると環境へ反映される
<!-- Note: git reset --hard はref指定なしなので lazy-lock.json がピン留めしたコミットに戻るだけで、回復してもプラグインのバージョンは変わらない (2026-09-10に HEAD と nvim/lazy-lock.json の copilot.lua commit の一致を確認) -->
- `:Lazy sync`がcopilot.luaのlocal changesで失敗したら、runtimeがagentをプラグインdir内のgit追跡ファイルへ上書きしたのが原因。以下で回復:
  `cd ~/.local/share/nvim/lazy/copilot.lua && git reset --hard && git clean -fd`
