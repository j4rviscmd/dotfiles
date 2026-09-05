-- satellite.nvim: 右端に装飾スクロールバー表示(VSCode風)
-- カーソル位置マーカー + diagnostics/gitsignsマークを右端へ集約表示
return {
  "lewis6991/satellite.nvim",
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    -- マーカー記号(width=4に合わせ4文字連結)
    local marker = "▂▂▂▂"

    require("satellite").setup({
      -- width: 既定2列は細く視認しづらいため4列へ拡張
      -- winblend: 0必須。transparent colorscheme(Normal bg NONE)でwinblend>0にすると
      -- ターミナル疑似透過の合成により黒帯が描かれる(neovim#18576、satellite.nvim#60)
      width = 4,
      winblend = 0,
      handlers = {
        -- Why: 漢数字の「一」のような平たい横ラインにするため下端1/4ブロック▂を4連結
        -- (satelliteのsymbolは単一文字想定だが実装上はvirt_textへそのまま渡るため複数文字も動作する)
        cursor = {
          symbols = { marker },
        },
        -- Why: 既定は同一位置の診断個数で記号が変化(1個'-'、2個'='、3個以上'≡')し
        -- 2本線'='等が不格好なため、個数に関係なく色のみでseverityを区別する
        diagnostic = {
          signs = {
            error = { marker },
            warn = { marker },
            info = { marker },
            hint = { marker },
          },
        },
      },
    })

    -- Why: satellite.nvimはsetup()内で同名ハイライトをdefault=true付きで定義するため
    -- (satellite.nvim lua/satellite.lua, lua/satellite/handlers/diagnostic.lua)、
    -- 確実に上書きするにはsetup()後に定義する必要がある。setup()との順序を入れ替えないこと
    -- 診断マークの色(gitsigns.luaと同じSolarized系パレットで明示指定)
    vim.api.nvim_set_hl(0, "SatelliteDiagnosticError", { fg = "#f14c4c" }) -- VSCode風の明るい赤
    vim.api.nvim_set_hl(0, "SatelliteDiagnosticWarn", { fg = "#b58900" }) -- 黄
    -- Why: 表示領域thumb(既定はVisualリンクの灰色帯)は不要のため透過。
    -- 現在位置はcursorハンドラのマーカーで把握する
    vim.api.nvim_set_hl(0, "SatelliteBar", { bg = "NONE" })
  end,
}
