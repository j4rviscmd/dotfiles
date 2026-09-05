-- ============================================================
-- 自宅Wi-Fi接続時のみディスプレイスリープを抑制する
-- ============================================================
-- 動作:
--   自宅Wi-Fi接続時 かつ 画面ロック中でない -> hs.caffeinate で
--                      ディスプレイスリープを抑制（アイドル時間が経過しても
--                      画面は暗くならず、ディスプレイもオフにならない = caffeinate -d と同等）
--   それ以外（自宅Wi-Fi外 or 画面ロック中）-> 抑制を解除し、システム環境設定の
--                      「ディスプレイをオフにする」設定値に従う
--
-- 注意 (Caution): Hammerspoon 停止時は抑制が解除され、
--   システム設定値に戻る。自宅以外のスリープ時間は
--   システム環境設定で別途設定すること（本モジュールは変更しない）
--
--   画面ロックの定義（いずれも自宅外扱いで抑制解除）:
--     - 画面ロック（⌘Ctrl+Q・メニューバーからロック）
--     - ホットコーナー（スクリーンセーバー/ロック起動）
--     - スクリーンセーバー起動
--
--   また本抑制の対象外（別仕組みで効かない）:
--     - バッテリー低下時の自動省電力調光
--     - 手動での輝度調整
--     - 蓋を閉じる（クラムシェルスリープ）
--
-- 依存: ~/.hammerspoon/home-wifi.local（自宅SSID一覧、Git管理外）
-- ============================================================

local caffeinate = require("hs.caffeinate")
local caffeinateWatcher = require("hs.caffeinate.watcher")
local wifi = require("hs.wifi")
-- Why: hs.logger は moduleid を10文字に切り詰めて表示し設定変更不可のため、
--      識別子を完全に表示すべく print で直接フォーマットして出力する
local function log(msg)
  print("[display-sleep] " .. msg)
end

local HOME_WIFI_FILE = os.getenv("HOME") .. "/.hammerspoon/home-wifi.local"

-- home-wifi.local から自宅Wi-FiのSSID一覧を読み込む
-- 形式: 1行1SSID。# で始まる行はコメント。ファイル不存在時は空集合
-- Why: SSID は環境固有情報のため .local に分離（repo直下 .env と同じ秘匿分離方針）
local function loadHomeWifiSet()
  local set = {}
  local f = io.open(HOME_WIFI_FILE, "r")
  if not f then
    -- Caution: ファイル不存在時はサイレントに空になり抑制が効かない。
    --          気づきやすくするため warning を出す
    log("WARNING: home-wifi.local not found; sleep suppression disabled")
    return set
  end
  local count = 0
  for line in f:lines() do
    local ssid = line:match("^%s*(.-)%s*$")
    -- Why: 空行と # で始まるコメント行を除外
    if ssid ~= "" and ssid:sub(1, 1) ~= "#" then
      set[ssid] = true
      count = count + 1
    end
  end
  f:close()
  log("loaded " .. count .. " SSID(s) from home-wifi.local")
  return set
end

local homeWifi = loadHomeWifiSet()

-- 画面ロック状態（true=ロック中）。起動時はアンロックと仮定
-- Why: Hammerspoon 起動時に現在のロック状態を取得する API がないため、
--      アンロック前提で開始し screensDidLock/Unlock イベントで追従する
local isLocked = false

-- 現在のSSIDとロック状態に基づいてディスプレイスリープ抑制を切り替える
local function applySleepPolicy()
  local current = wifi.currentNetwork()
  local isHome = current ~= nil and homeWifi[current] == true
  -- Why: 自宅Wi-Fi接続中でも画面ロック時は自宅外扱いとし画面を切る（要件）
  local shouldSuppress = isHome and not isLocked

  -- Why: 現在の抑制状態と比較し、変化があるときのみ set を呼ぶ
  --      （不要なシステム呼び出しを抑制する）
  if caffeinate.get("displayIdle") ~= shouldSuppress then
    caffeinate.set("displayIdle", shouldSuppress, true)
  end
  log(
    "current="
      .. tostring(current)
      .. " -> "
      .. (isHome and "HOME" or "NOT HOME")
      .. "; locked="
      .. tostring(isLocked)
      .. "; caffeinate="
      .. (shouldSuppress and "ON" or "OFF")
  )
end

-- 画面ロック/スクリーンセーバー状態の変化を isLocked に反映しポリシー再適用
-- Why: ⌘Ctrl+Q・ホットコーナー・スクリーンセーバーを「画面ロック状態」として扱い、
--      ロック中は自宅Wi-Fiでも抑制を解除する
local function onCaffeinateEvent(event)
  if event == caffeinateWatcher.screensDidLock or event == caffeinateWatcher.screensaverDidStart then
    if not isLocked then
      isLocked = true
      log("screen locked")
      applySleepPolicy()
    end
  elseif event == caffeinateWatcher.screensDidUnlock or event == caffeinateWatcher.screensaverDidStop then
    if isLocked then
      isLocked = false
      log("screen unlocked")
      applySleepPolicy()
    end
  end
end

-- Hammerspoon 起動直後に現在の状態を反映
applySleepPolicy()

-- SSID変更を即時検知してポリシーを再適用（ポーリング不要）
-- TODO: Wi-Fi無効化/有効化時の linkChange イベントも拾うかは要観察。
--       現状は SSIDChange デフォルト監視で十分
local wifiWatcher = wifi.watcher.new(applySleepPolicy)
wifiWatcher:start()

-- 画面ロック/解除を検知してポリシーを再適用
local lockWatcher = caffeinateWatcher.new(onCaffeinateEvent)
lockWatcher:start()

-- Why: 両 watcher を強参照で保持し、チャンク終了後の GC による
--      サイレント停止を防ぐ（Hammerspoon 公式: variable lifecycles）
return { wifi = wifiWatcher, lock = lockWatcher }
