-- 結果フロートの共通管理: プレースホルダ、開閉とフォーカス突入

local M = {}

-- 最後に開いた結果フロートのウィンドウID(閉じたらnil)
---@type integer|nil
local last_win = nil

--- 結果フロートを追跡する: focus()の対象として記憶し、<Esc>で閉じるマップを付与する
--- @param win integer フロートのウィンドウID
--- @param buf integer フロートのバッファID
--- @return nil
local function track(win, buf)
  last_win = win
  vim.keymap.set("n", "<Esc>", function()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, false)
    end
  end, { buffer = buf, silent = true })
end

--- 翻訳中であることを示すプレースホルダフロートを開き、閉じる関数を返す
--- Why: LSP往復+ネットワーク翻訳には時間がかかりうるため、
--- 押下が効いていないように見えないよう即座に開く
--- @return fun() プレースホルダを閉じる関数
function M.open_placeholder()
  local _, win = vim.lsp.util.open_floating_preview(
    { "Translating..." },
    "plaintext",
    { border = "rounded", focusable = false }
  )
  return function()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end
end

--- 翻訳結果フロートをtrack込みで開く
--- Why: focusable=falseだと長い結果を読めない(スクロール手段がない)。
--- focusable + focus=falseにより、開いた時はカーソルをバッファに残し、
--- 突入(マウスクリック / <C-w>w)すれば長文をスクロールできる
--- @param lines string[] 表示行
--- @param filetype string フロートのfiletype("markdown"|"plaintext")
--- @return integer buf, integer win
function M.open_result(lines, filetype)
  -- NOTE: open_floating_previewの戻り値は(bufnr, winnr)の順(0.11)
  -- Note: focusable=falseだとopen_floating_previewはfocus_idを参照しない
  -- (再利用分岐はfocusable ~= falseが条件)のため、focus_idは渡さない
  local buf, win = vim.lsp.util.open_floating_preview(lines, filetype, {
    border = "rounded",
    focusable = true,
    focus = false,
    max_height = math.floor(vim.o.lines * 0.8),
  })
  track(win, buf)
  return buf, win
end

--- 追跡中のフロートが開いていればカーソルを移す
--- @return boolean フォーカス移動できたらtrue
function M.focus()
  if last_win and vim.api.nvim_win_is_valid(last_win) then
    vim.api.nvim_set_current_win(last_win)
    return true
  end
  last_win = nil
  return false
end

return M
