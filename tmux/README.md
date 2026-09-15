# tmux

tmux は `~/.config` を読まないため symlink が必要:

```sh
ln -sf ~/.config/tmux/tmux.conf ~/.tmux.conf
```

## scripts/

- `glm-usage.sh`: GLM API の利用残量を statusline へ表示。`GLM_TOKEN` 未設定なら黙って何も表示しない（statusline を壊さない設計）
- `tmux-new-session.sh`: Windows Terminal の "Ubuntu (tmux)" プロファイル（base名 `main`）と Coderm のターミナルプロファイル（`Coderm/settings.json`）から起動されるセッション採番スクリプト。未アタッチのゴミセッションを起動時に破棄し、`{base}-N` の連番で毎回新規セッションを作成してアタッチする。status line は常に表示。bash + tmux があればOS非依存で動く
- `git-status.sh` / `session-switch.sh`: statusline 表示とセッション切替（fzf）
