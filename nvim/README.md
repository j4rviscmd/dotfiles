# Neovim

## バイナリ導入(WSL/Linux)

Why: Ubuntu公式リポジトリのneovimは0.11系で古く、本設定は0.12前提のため、
公式stable tarballを `~/.local/opt/nvim-linux-x86_64/` に展開して運用する。

```sh
./install-nvim.sh
```

- 冪等: stable最新が導入済みなら何もしない
- PATH: `.zshrc.linux` が `~/.local/opt/nvim-linux-x86_64/bin` をapt版(`/usr/bin/nvim`)より優先する
- macOSは `zsh/setup.sh`(brew)で導入するため本スクリプト対象外

## 設定ファイル

`~/.config` を本repoへsymlinkしていれば追加作業不要(repo直下README参照)。

前提: telescopeの `<C-g>`(live_grep) / `<C-i>`(quick_open)はripgrep(`rg`)必須。`zsh/setup.sh` で導入する。
