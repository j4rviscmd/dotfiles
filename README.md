# Dotfiles

個人用dotfiles。`~/.config` を本repoへ symlink して運用する。

```sh
git clone https://github.com/j4rviscmd/dotfiles.git ~/work/dev/dotfiles
ln -s ~/work/dev/dotfiles ~/.config
```

`~/.config` 直下を読むツール（nvim / ghostty / lazygit / opencode / git）はこれだけで動く。
ホーム直下や別パスを読むツール（zsh / tmux / Hammerspoon / VSCode）は各ディレクトリのREADME参照。

## フォント

- Moralerspace Neon HW
  - [Moralerspace](https://github.com/yuru7/moralerspace/releases)

## 機密情報の取扱い

Why: 機密の実体をrepoに入れず、読み込み側で分離する運用。すべて `.gitignore` 済み。

- `.env`（repo直下）: 環境変数のSSOT。zsh/bashは`~/.config/.env`経由、Windowsは`user_profile.ps1`がrepo直下を直接読込。雛形は `.env.sample`
- `~/.hammerspoon/home-wifi.local`: 自宅Wi-Fi SSID（`.hammerspoon/README.md` 参照）
- `powershell/*.txt`: 旧Windows用キーtxt（`.env`移行後は廃止。Git管理外のままWin側で手動削除）

### Windows移行手順（旧txt → .env）

Why: pullすると同時にtxt読込が消えるため、先に`.env`配置が必要。

1. Win側repo直下へ`.env`を配置（macからscp等。win専用キーはこの時点で追記してよい）
2. pull → PowerShell起動で`.env`から環境変数が読み込まれることを確認
3. 旧`powershell/*.txt`を手動削除
4. 任意: Git Bash(tmux利用)でも読む場合、`%USERPROFILE%\.config`→repoへjunction（`mklink /J`）で`bash/.bashrc`のsource行が効く
