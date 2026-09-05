# tmux

tmux は `~/.config` を読まないため symlink が必要:

```sh
ln -sf ~/.config/tmux/tmux.conf ~/.tmux.conf
```

## scripts/

- `glm-usage.sh`: GLM API の利用残量を statusline へ表示。`GLM_TOKEN` 未設定なら黙って何も表示しない（statusline を壊さない設計）
- `vscode-new-session.sh`: VSCode/Coderm のターミナルプロファイル（`vscode/settings.json`・`Coderm/settings.json`）から起動されるセッション採番スクリプト。Why: `.zshrc` の tmux 自動起動と同じ `dotfiles-N` 採番でセッション命名を統一するため
- `git-status.sh` / `session-switch.sh`: statusline 表示とセッション切替（fzf）
