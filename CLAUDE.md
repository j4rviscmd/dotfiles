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
- ヒトによる動確前には`review-all(mode:review)`スキルを発動すること
  - `lazy-lock.json`もコミット対象
- このrepoの資材はmacOS/Windows/WSLの各OSから利用される
  - 変更時は全OSでの動作を担保すること（GNU/BSD互換、OS固有のパス・ツール依存など）
- `~/.config`にシンボリックリンクして運用している
  - このrepo資材を操作すると環境へ反映される
<!-- Note: git reset --hard はref指定なしなので lazy-lock.json がピン留めしたコミットに戻るだけで、回復してもプラグインのバージョンは変わらない (2026-09-10に HEAD と nvim/lazy-lock.json の copilot.lua commit の一致を確認) -->
- `:Lazy sync`がcopilot.luaのlocal changesで失敗したら、runtimeがagentをプラグインdir内のgit追跡ファイルへ上書きしたのが原因。以下で回復:
  `cd ~/.local/share/nvim/lazy/copilot.lua && git reset --hard && git clean -fd`
