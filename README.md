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
