# Zsh

## セットアップ

zsh は `~/.config` を読まないためホーム直下へ symlink する
（starship は `~/.config/starship.toml` を直接読むため不要）:

```sh
ln -sf /mnt/e/work/dotfiles/zsh/.zshrc ~/.zshrc
ln -sf /mnt/e/work/dotfiles/zsh/.zshenv ~/.zshenv
ln -sf /mnt/e/work/dotfiles/zsh/.zsh_plugins.txt ~/.zsh_plugins.txt
```

## ツールセットアップ

前提CLIツールは `setup.sh` で一括導入できる（未インストールのもののみ `brew install` する冪等なスクリプト）:

```sh
./setup.sh
```

- 対象: antidote / starship / zoxide / eza / peco / fzf / lazygit / fnm / pyenv / tmux / neovim / ripgrep / make
- 前提: zsh本体とHomebrew導入済み（未導入ならインストール手順を表示して中断）
- NOTE: claude/coderm/opencode/copilot等のLLMエージェント系とbun/rustは公式手順のため対象外
- NOTE: neovimはLinux(WSL2)ではbrew対象外。Ubuntu公式リポジトリが0.11系で古いため、
  `nvim/install-nvim.sh`（公式stable tarball）で手動導入する（未導入ならsetup.shが案内表示）

前提ツール（antidote / zoxide / starship）は `.zshrc` 内で初期化しているため、未インストールだと対応機能が動かない。

## OS固有設定（任意）

`.zshrc` は `~/.zshrc.darwin` / `~/.zshrc.linux` を「存在すれば」読み込む設計。
repo に置いてあるだけで `~` への symlink は必須ではなく、必要なOSのみ有効化する:

```sh
ln -sf /mnt/e/work/dotfiles/zsh/.zshrc.darwin ~/.zshrc.darwin
ln -sf /mnt/e/work/dotfiles/zsh/.zshrc.linux ~/.zshrc.linux   # WSL/Linux用
```

Why: 未symlinkなら単にスキップされエラーにならない。

## 機密情報

repo直下`.env`（Git管理外）に記述する。`.zshrc` は `~/.config/.env` を読み込む。
雛形はrepo直下の `.env.sample` を参照。
