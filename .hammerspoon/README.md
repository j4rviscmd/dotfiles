# Hammerspoon

## セットアップ

Hammerspoon は `~/.hammerspoon/` を読むためファイル単位で symlink する:

```sh
ln -s ~/.config/.hammerspoon/init.lua ~/.hammerspoon/init.lua
ln -s ~/.config/.hammerspoon/display-sleep-by-wifi.lua ~/.hammerspoon/display-sleep-by-wifi.lua
```

必要な権限:
- アクセシビリティ（`hs.window.filter` のウィンドウ監視）
- 位置情報サービス（`hs.wifi` のSSID取得。macOS Sonoma 以降でないと付与できない罠があり、欠けるとSSIDが空になり抑制が無効になる）

## 自宅Wi-Fi接続時のディスプレイスリープ抑制（display-sleep-by-wifi.lua）

自宅Wi-Fi接続中のみスリープを抑制（イベント駆動で即時切替、visudo 不要）。

1. SSID一覧を作成（Git管理外）:

   ```sh
   cp ~/.config/.hammerspoon/home-wifi.local.sample ~/.hammerspoon/home-wifi.local
   ```

2. システム設定の「ディスプレイをオフにする」を **1分** に設定
   - 自宅Wi-Fi接続時: 抑制（画面を暗くしない）
   - それ以外: システム設定値（1分）に従う

## Karabiner-Elements 連携（init.lua）

`init.lua` がフロントウィンドウのフルスクリーン状態を `karabiner_cli --set-variables` で
Karabiner の `is_fullscreen` 変数へ通知する。
`karabiner/karabiner.json` の「RDPアプリ使用中(フルスクリーン時のみ)…」ルールがこの変数に依存
（hammerspoon を止めている間は変数が更新されず、RDPフルスクリーン時の入れ替えが効かない点に注意）。
