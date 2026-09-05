-- lsp_translator
-- LSP診断のvirtual_textとhoverドキュメントを翻訳する

local config = require("lsp_translator.config")
local virtual_text = require("lsp_translator.virtual_text")

local M = {}

--- モジュールのセットアップを行う(virtual_text handlerのwrapを適用する)
--- @param opts table|nil { source?: string, target?: string, icons?: table }
--- @return nil
function M.setup(opts)
  config.setup(opts)
  virtual_text.wrap()
end

-- 診断+hoverドキュメントの翻訳済み統合フロート。
-- キーマップ例: vim.keymap.set("n", "K", require("lsp_translator").hover)
M.hover = require("lsp_translator.hover").show

-- visual選択を翻訳してフロート表示する。
-- キーマップ例: vim.keymap.set("x", "K", require("lsp_translator").visual)
M.visual = require("lsp_translator.visual").show

-- 結果フロートが開いていればフォーカスを移す。
-- 合成利用例(フロートがあれば突入、なければ定義ジャンプ):
--   if not require("lsp_translator").focus_float() then
--     vim.lsp.buf.definition()
--   end
M.focus_float = require("lsp_translator.float").focus

return M
