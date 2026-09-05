-- GitHub Copilot Chat
local function generate_commit_message(buf)
  local ok, chat = pcall(require, "CopilotChat")
  if not ok then
    vim.notify("[copilot] Failed to load CopilotChat", vim.log.levels.ERROR)
    return
  end
  vim.notify("[copilot] Generating commit message...", vim.log.levels.INFO)
  chat.ask(
    "Write commit message for the change with commitizen convention. Keep the title under 50 characters and wrap message at 72 characters. Format as a gitcommit code block.",
    {
      resources = { "gitdiff:staged" },
      headless = true,
      callback = function(response)
        local text = type(response) == "table" and response.content or tostring(response)
        local commit_msg = text:match("```[%w]*\n(.-)\n?```")
        local lines
        if commit_msg then
          lines = vim.split(commit_msg, "\n", { plain = true })
        else
          lines = { "# Unable to extract commit message" }
          for _, line in ipairs(vim.split(text, "\n", { plain = true })) do
            table.insert(lines, "# " .. line)
          end
        end
        vim.schedule(function()
          pcall(vim.api.nvim_buf_set_lines, buf, 0, 0, false, lines)
          vim.notify("[copilot] Commit message generated", vim.log.levels.INFO)
        end)
      end,
    }
  )
end

return {
  "CopilotC-Nvim/CopilotChat.nvim",
  build = "make tiktoken",
  ft = "gitcommit",
  dependencies = {
    { "nvim-lua/plenary.nvim", branch = "master" },
    { "zbirenbaum/copilot.lua" },
  },
  opts = {},
  config = function(_, opts)
    require("CopilotChat").setup(opts)

    -- Generate commit message for current gitcommit buffer
    if vim.bo.filetype == "gitcommit" then
      generate_commit_message(vim.api.nvim_get_current_buf())
    end

    -- Handle future gitcommit buffers
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "gitcommit",
      callback = function()
        generate_commit_message(vim.api.nvim_get_current_buf())
      end,
    })
  end,
}
