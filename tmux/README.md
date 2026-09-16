# tmux

tmux は `~/.config` を読まないため symlink が必要:

```sh
ln -sf ~/.config/tmux/tmux.conf ~/.tmux.conf
./setup.sh   # resurrect/continuum プラグインを ~/.local/share/tmux/plugins へ導入
```

## セッション保存・復元 (tmux-resurrect / tmux-continuum)

- 手動: `prefix C-s` (save) / `prefix C-r` (restore)
- 自動: 5分毎に autosave、tmux server 起動時に自動 restore (`@continuum-restore`)
- タブを閉じると client-detached フックで該当セッションを kill + 即時 save
  (閉じたセッションは次回復元対象から除外される)
- 保存先 `~/.tmux/resurrect/`。30日より古い保存ファイルは自動削除 (最低5世代保持)

### PC再起動時の復元の流れ (Ghostty / macOS)

1. Ghostty の `window-save-state` がタブ構成とタブ毎のCWDを復元
2. 最初の tmux 起動時に continuum がセッション群を復元
3. `.zshrc` がタブのCWDと同名のセッションへ自動再アタッチ

タブ↔セッションの自動再接続を効かせるには、セッションを**ディレクトリ名で作成**する
(`tmux new -A -s repoA` 等)。数字のデフォルト名セッションは復元されるが自動再アタッチ
対象外 (手動 `tmux attach` で利用可)。

### WSL / Windows Terminal の注記

WT プロファイルは `tmux-new-session.sh` で起動のたび新規 `{base}-N` セッションを
作成する仕様のため、continuum の復元とは接続しない (autosave 自体は動作する)。

## scripts/

- `glm-usage.sh`: GLM API の利用残量を statusline へ表示。`GLM_TOKEN` 未設定なら黙って何も表示しない（statusline を壊さない設計）
- `tmux-new-session.sh`: Windows Terminal の "Ubuntu (tmux)" プロファイル（base名 `main`）と Coderm のターミナルプロファイル（`Coderm/settings.json`）から起動されるセッション採番スクリプト。未アタッチのゴミセッションを起動時に破棄し、`{base}-N` の連番で毎回新規セッションを作成してアタッチする。status line は常に表示。bash + tmux があればOS非依存で動く。homebrew の PATH（macOS/WSL）を冪等に補強し、tmuxサーバー環境（→ display-popup）で lazygit 等の homebrew製ツールが解決できるようにする（tmux.conf 側にも同目的の if-shell 保証あり）
- `reload-statusline.sh`: client-attached フックから statusline.conf を再読込し、continuum の autosave フックを status-right へ再埋込する
- `git-status.sh` / `session-switch.sh`: statusline 表示とセッション切替（fzf）
