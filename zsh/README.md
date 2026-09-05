# Zsh

## セットアップ

zsh は `~/.config` を読まないためホーム直下へ symlink する
（starship は `~/.config/starship.toml` を直接読むため不要）:

```sh
ln -sf ~/work/dev/dotfiles/zsh/.zshrc ~/.zshrc
ln -sf ~/work/dev/dotfiles/zsh/.zshenv ~/.zshenv
ln -sf ~/work/dev/dotfiles/zsh/.zsh_plugins.txt ~/.zsh_plugins.txt
```

前提ツール（antidote / zoxide / starship）は `.zshrc` 内で初期化しているため、未インストールだと対応機能が動かない。

## OS固有設定（任意）

`.zshrc` は `~/.zshrc.darwin` / `~/.zshrc.linux` を「存在すれば」読み込む設計。
repo に置いてあるだけで `~` への symlink は必須ではなく、必要なOSのみ有効化する:

```sh
ln -sf ~/work/dev/dotfiles/zsh/.zshrc.darwin ~/.zshrc.darwin
```

Why: 未symlinkなら単にスキップされエラーにならない。

## 機密情報

repo直下`.env`（Git管理外）に記述する。`.zshrc` は `~/.config/.env` を読み込む。
雛形はrepo直下の `.env.sample` を参照。
