return {
  "craftzdog/solarized-osaka.nvim",
  lazy = false,
  priority = 1000,
  opts = {
    transparent = true,
  },
  config = function(_, opts)
    require("solarized-osaka").setup(opts)
    vim.cmd("colorscheme solarized-osaka")
    -- 行番号をVSCode風に: 通常=グレー、アクティブ行=白
    -- NOTE: on_highlightsコールバックは反映されなかったため、colorscheme適用後に直接上書き
    -- Why: solarized-osakaの既定はLineNr=黄系(yellow700)/CursorLineNr=橙系(orange500)でVSCode風のグレー/白と競合するため、適用後に強制上書きしている(プラグイン内 lua/solarized-osaka/groups/editor.lua)
    -- Note: nvim_set_hlは全定義を置換し、未指定の属性もクリアされる(:h nvim_set_hl)。fgだけ指定すればbold等は付かない
    vim.api.nvim_set_hl(0, "LineNr", { fg = "#4f5561" })
    vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#c6c6c6", bold = false })
    -- Why: codefence本文のbuiltin構文highlightはmarkdownCodeBlockで描画され、
    --   既定がyellow500(#b28500)=辛子色のため、treesitter有効時の実測色String(cyan500)へ寄せる
    -- Note: treesitter highlight有効化後は原則使われないが、パーサー欠損時のフォールバックとして残す
    vim.api.nvim_set_hl(0, "markdownCodeBlock", { fg = "#29a298" })
    -- Why: treesitterのkeyword系既定green500(#849900)が黄味すぎるため、violet500へ変更
    -- Note: @labelはmarkdown codefenceの言語名表示にも使われる
    vim.api.nvim_set_hl(0, "@keyword", { fg = "#6d71c4" })
    vim.api.nvim_set_hl(0, "@keyword.function", { fg = "#6d71c4" })
    vim.api.nvim_set_hl(0, "@label", { fg = "#6d71c4" })
    -- Why: treesitter有効化でmarkdown描画がregex構文→TSへ変わり色味が変わったため、
    --   旧regex構文時代のtheme実色(solarized-osaka syntax.lua定義の実測hex)へ寄せて踏襲する
    -- Note: 同captureで分離できない部位の妥協点:
    --   - fenceのmarker/言語名/本文は同一capture(@markup.raw.block)のためteal一色(旧markerはgray)
    --   - 旧inline codeのmustard(#b28500)はユーザー却下済みのため復元しない
    -- Caution: themeが定義するlang suffix付きgroupはcapture本体のoverrideより優先される
    --   (highlighterは@capture.<lang>を解決するため :h treesitter-highlight, runtime lua/vim/treesitter/highlighter.lua)。
    --   よって旧色へ戻す部位はsuffix付きgroup自体を上書きする(markdown外への影響も消える)
    -- 妥協点(旧色を復元しない部位):
    --   - hr(`---`)はorange boldのまま(旧は赤。分離不可)
    --   - 行内code(`x`)はtheme定義のblue500(#268bd3)のまま(旧mustardはユーザー却下済み)
    vim.api.nvim_set_hl(0, "@markup.heading.1", { fg = "#d23681", bold = true }) -- 旧markdownH1=magenta500
    vim.api.nvim_set_hl(0, "@markup.heading.2", { fg = "#6d71c4", bold = true }) -- 旧markdownH2=violet500
    vim.api.nvim_set_hl(0, "@markup.heading.3", { fg = "#268bd3", bold = true }) -- 旧markdownH3以降=htmlH2=blue500
    vim.api.nvim_set_hl(0, "@markup.heading.4", { fg = "#268bd3", bold = true })
    vim.api.nvim_set_hl(0, "@markup.heading.5", { fg = "#268bd3", bold = true })
    vim.api.nvim_set_hl(0, "@markup.heading.6", { fg = "#268bd3", bold = true })
    vim.api.nvim_set_hl(0, "@markup.list", { fg = "#849900" }) -- 旧ListMarker=Statement=green500(非markdown言語用)
    vim.api.nvim_set_hl(0, "@markup.list.markdown", { fg = "#849900" }) -- 同上。markdownは本行が優先される
    vim.api.nvim_set_hl(0, "@punctuation.special.markdown", { fg = "#576d74", italic = true }) -- 旧引用marker=Comment
    vim.api.nvim_set_hl(0, "@markup.link.label", { fg = "#268bd3", underline = true }) -- 旧markdownLinkText
    -- Note: themeは@markup.link.urlをUnderlinedにlinkしているだけで色を持たない
    --   (solarized-osaka groups/treesitter.lua)ため、labelと同色に揃えるために明示上書き
    vim.api.nvim_set_hl(0, "@markup.link.url", { fg = "#268bd3", underline = true })
    vim.api.nvim_set_hl(0, "@punctuation.special", { fg = "#576d74", italic = true }) -- 旧引用marker=Comment(非markdown言語用)
    -- Why: Telescopeのpicker(C-i/C-g)背景が黒っぽくなるのは、solarized-osakaが
    --   TelescopeNormal/TelescopeBorderへbg=bg_floatを固定定義しているため(transparent=trueの対象外、
    --   solarized-osaka lua/solarized-osaka/groups/telescope.lua)。ここでbgのみ除去しpickerを透過する
    -- Note: telescope本体はwindow種別group(TelescopeResultsNormal等)をwinhlへ指定するがthemeは未定義のため、
    --   bg=NONE化した本体groupへlinkさせて全window(prompt/results/preview)を透過統一する
    -- Note: 半透明(winblend)はtransparent colorscheme環境で黒帯が描かれるため使わない(neovim#18576、satellite.lua参照)
    local function clear_bg(name)
      local hl = vim.api.nvim_get_hl(0, { name = name })
      hl.bg = nil
      vim.api.nvim_set_hl(0, name, hl)
    end
    clear_bg("TelescopeNormal")
    clear_bg("TelescopeBorder")
    for _, group in ipairs({ "TelescopePromptNormal", "TelescopeResultsNormal", "TelescopePreviewNormal" }) do
      vim.api.nvim_set_hl(0, group, { link = "TelescopeNormal" })
    end
    for _, group in ipairs({ "TelescopePromptBorder", "TelescopeResultsBorder", "TelescopePreviewBorder" }) do
      vim.api.nvim_set_hl(0, group, { link = "TelescopeBorder" })
    end
  end,
}
