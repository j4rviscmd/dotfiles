-- Neovim configuration
-- init.lua

-- VSCode-neovim拡張機能で動作している場合は早期リターン
if vim.g.vscode then
  return
end

-- Leader key（すべてのキーマップより先に定義が必要）
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- 外部変更の自動検知・自動読み込み
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  pattern = "*",
  callback = function()
    if vim.fn.mode() ~= "c" then
      vim.cmd("checktime")
    end
  end,
})
vim.api.nvim_create_autocmd("FileChangedShell", {
  pattern = "*",
  callback = function()
    vim.v.fcs_choice = "reload"
    -- TODO: 運用してみてうっとうしければ削除
    vim.notify("File changed on disk, reloaded!", vim.log.levels.INFO)
  end,
})

-- ===========================================
-- キーバインド
-- ===========================================

-- プラグイン非依存の基本操作
vim.keymap.set("n", "<Esc>", "<Cmd>nohlsearch<CR>") -- 検索ハイライト解除

-- Visual選択の翻訳(lsp_translator: 自作lua/lsp_translator/、plugin非依存)
-- Why: LSP未attachバッファ(:ene直後等)でも発火するようグローバル登録(LspAttach内マップはbuffer-local)
-- Why: "v"だとSelect mode(LuaSnipプレースホルダ等)でも発火し選択テキストが削除されるため、Visual専用の"x"を指定
vim.keymap.set("x", "<leader>h", function()
  require("lsp_translator").visual()
end, { silent = true })

-- ===========================================
-- 基本設定
-- ===========================================

-- 行番号
vim.opt.number = true

-- インデント
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
-- Why: 同梱ftplugin/markdown.vimがmarkdown_recommended_style既定ONでsw/ts/sts=4をbuffer-local上書きするため無効化
vim.g.markdown_recommended_style = 0

-- 検索
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true

-- 見た目
-- Why: CursorLineNrハイライト有効化のため。cursorlineopt="number"で行番号のみ着色し行背景は出さない(VSCode風)
vim.opt.cursorline = true
vim.opt.cursorlineopt = "number"
-- Why: 診断+gitの2 signが並ぶ行だけ2レーン使い、それ以外は必要幅のみ(VSCodeのgutter相当)
vim.opt.signcolumn = "auto:2"
-- Why: VSCode風に[行番号][gitバー][診断icon]の順で並べる(標準構成はsignが行番号の左固定のため)
vim.opt.statuscolumn = "%=%l%s "
-- Why: 行番号の最小幅を既定4から縮め、gutter全体の横幅を詰める(3桁行番号は自動拡張)
vim.opt.numberwidth = 2
vim.opt.scrolloff = 8
vim.opt.termguicolors = true
vim.opt.wrap = false
-- solarized-osakaの`transparent=true`で対応されるので不要
-- vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
-- vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })

-- 操作性
-- 行末+1文字分までカーソル移動・選択可能にする
vim.opt.virtualedit = "onemore"
-- クリップボード連携
vim.opt.clipboard = "unnamedplus"
vim.opt.splitbelow = true
vim.opt.splitright = true

-- ファイル
vim.opt.swapfile = false
vim.opt.undofile = true
vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"
vim.opt.autoread = true

-- ===========================================
-- プラグインマネージャー (lazy.nvim)
-- ===========================================

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    lazyrepo,
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins", {
  checker = { enabled = true },
})
