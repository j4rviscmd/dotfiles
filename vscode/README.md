# VSCode

VSCode の設定は `~/.config` 外（`~/Library/Application Support/Code/User/`）のため手動 symlink が必要:

```sh
ln -sf ~/work/dev/dotfiles/vscode/settings.json ~/Library/Application\ Support/Code/User/settings.json
ln -sf ~/work/dev/dotfiles/vscode/keybindings.json ~/Library/Application\ Support/Code/User/keybindings.json
```

`Coderm/` は VSCode fork「Coderm」向けの同種設定。

## ニッチ知見

- `vscode-neovim.neovimInitVimPaths` の `~` は拡張が展開せず `nvim -u` へ素通しされる。
  `~` 展開は nvim 側の挙動に依存するため `~` 表記で動く（実機検証済み。絶対パスにユーザ名を含めないための運用）
- Linux では nvim を `/snap/bin/nvim` に想定
