-- 独自ユーザーコマンド定義
-- quick_open のパレット（> モード）に自動表示される

-- CopyFilePath: アクティブファイルの絶対パスをクリップボードへコピー
vim.api.nvim_create_user_command("CopyFilePath", function()
  local path = vim.fn.expand("%:p")
  if path == "" then
    vim.notify("No active file", vim.log.levels.WARN)
    return
  end
  vim.fn.setreg("+", path)
  vim.notify("Copied: " .. path)
end, { desc = "Copy path of active file to clipboard" })

return {}
