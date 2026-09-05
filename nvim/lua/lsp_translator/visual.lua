-- visual選択を翻訳してフロート表示する

local translate = require("lsp_translator.translate")
local float = require("lsp_translator.float")

local M = {}

--- 現在のvisual選択を翻訳し、結果をフロート表示する
--- @return nil
function M.show()
  -- Why: getregionは文字/行/ブロック選択を同一APIで扱える(0.10以降)
  local lines = vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = vim.fn.mode() })
  if #lines == 0 or (#lines == 1 and lines[1]:find("^%s*$")) then
    return
  end
  -- Why: 選択テキストを取得した後にnormalへ戻す。これにより続けて
  -- normalモードのキーマップでフロートへ突入できる(visualのままだと
  -- 再度選択翻訳が発火してしまう)
  vim.api.nvim_input("<Esc>")

  local close_placeholder = float.open_placeholder()
  -- 選択原文はバッファ上に見えているため、フロートには訳文のみ表示する
  translate.translate(table.concat(lines, "\n"), function(tr)
    close_placeholder()
    float.open_result(vim.split(tr, "\n", { plain = true }), "plaintext")
  end)
end

return M
