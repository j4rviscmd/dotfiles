-- インサートモード離脱時にIMEを自動でオフにする

-- WSL/Windows: zenhan.exe を使用（nvim設定ディレクトリへ手動配置。Git管理外）
local zenhan_path = vim.fn.stdpath("config") .. "/zenhan.exe"
if vim.fn.filereadable(zenhan_path) == 1 then
  for _, event in ipairs({ "InsertLeave", "CmdlineLeave" }) do
    vim.api.nvim_create_autocmd(event, {
      pattern = "*",
      callback = function(_)
        vim.fn.system(zenhan_path .. " 0")
      end,
    })
  end
end

-- macOS: im-select を使用
-- brew install im-select
if vim.fn.executable("im-select") == 1 then
  for _, event in ipairs({ "InsertLeave", "CmdlineLeave" }) do
    vim.api.nvim_create_autocmd(event, {
      pattern = "*",
      callback = function(_)
        vim.fn.system("im-select com.apple.keylayout.ABC")
      end,
    })
  end
end

-- lazy.nvim用（プラグインなし）
return {}
