-- Karabiner-Elements との連携: フルスクリーン状態を変数として通知
local karabinerCli = "/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli"

local lastFullscreenState = false

local function updateKarabinerFullscreen(isFullscreen)
    -- 状態が変わっていない場合はスキップ
    if lastFullscreenState == isFullscreen then
        return
    end
    lastFullscreenState = isFullscreen

    local value = isFullscreen and 1 or 0
    local cmd = string.format('"%s" --set-variables \'{"is_fullscreen":%d}\'', karabinerCli, value)
    hs.execute(cmd)
    print(string.format("Karabiner is_fullscreen = %d", value))
end

-- フロントウィンドウがフルスクリーンかどうかを判定
local function checkFrontWindowFullscreen()
    local win = hs.window.focusedWindow()
    if not win then
        updateKarabinerFullscreen(false)
        return
    end

    -- macOS標準のフルスクリーン
    if win:isFullScreen() then
        updateKarabinerFullscreen(true)
        return
    end

    -- ウィンドウが画面全体を覆っているかどうかを判定
    -- (RDPアプリなど、macOS標準フルスクリーンを使わないアプリ向け)
    local winFrame = win:frame()
    local screen = win:screen()
    if screen then
        local screenFrame = screen:fullFrame()
        local isFullSize = winFrame.w >= screenFrame.w and winFrame.h >= screenFrame.h - 50 -- メニューバー分の余裕
        if isFullSize then
            updateKarabinerFullscreen(true)
            return
        end
    end

    updateKarabinerFullscreen(false)
end

-- ウィンドウフィルタでフルスクリーン状態を監視
local wf = hs.window.filter.new()
wf:subscribe(hs.window.filter.windowFullscreened, function()
    updateKarabinerFullscreen(true)
end)
wf:subscribe(hs.window.filter.windowUnfullscreened, function()
    checkFrontWindowFullscreen()
end)
wf:subscribe(hs.window.filter.windowFocused, function()
    checkFrontWindowFullscreen()
end)

-- 起動時に初期値を設定
checkFrontWindowFullscreen()

-- ============================================================
-- 自宅Wi-Fi接続時のディスプレイスリープ抑制
-- ============================================================
-- Why: 処理本体は別モジュールに分離し、init.lua の関心を分離する
require "display-sleep-by-wifi"
