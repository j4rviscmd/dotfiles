-- GitHub Copilot inline suggestion
-- nodeはfnmのdefaultエイリアスから解決（Windows/Linux両対応・バージョンアップに追従）
local fnm_dir = vim.env.FNM_DIR
local copilot_node_command = "node"
if fnm_dir then
  local node = fnm_dir .. "/aliases/default/" .. (vim.fn.has("win32") == 1 and "node.exe" or "bin/node")
  if vim.fn.executable(node) == 1 then
    copilot_node_command = node
  end
end

return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  event = "InsertEnter",
  config = function()
    require("copilot").setup({
      copilot_node_command = copilot_node_command,
      suggestion = {
        enabled = true,
        auto_trigger = true,
        hide_during_completion = true,
        keymap = {
          accept = false,
          accept_word = false,
          accept_line = false,
          next = "<M-]>",
          prev = "<M-[>",
          dismiss = "<C-]>",
        },
      },
      panel = { enabled = false },
      filetypes = {
        markdown = true,
        gitcommit = true,
        help = false,
      },
    })

    -- Why: copilot.lua本体は未認証でもサジェストを黙って抑制するだけで通知しないため(suggestion/init.luaのis_authenticated参照)、
    -- attach時に自前で認証状態を確認して警告を出す
    -- 起動時に認証状態をチェックし、未認証ならnotify
    -- copilotはLSPクライアント起動(初回InsertEnter後のattach)を待つ必要があるためLspAttachで拾う
    local auth_notified = false
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("copilot-auth-check", { clear = true }),
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client or client.name ~= "copilot" then
          return
        end
        -- Note: 未認証の判定は status.status ではなく user フィールドで行う(未認証時は user が nil。copilot_check_status_data の型定義参照)
        require("copilot.api").check_status(client, {}, function(err, status)
          if not err and not status.user and not auth_notified then
            auth_notified = true
            local msg =
              "[copilot] 未認証のためサジェストを使用できません。:Copilot auth でサインインしてください。"
            -- LSP付随の通知はfidgetで出す設計(plugins/notify.lua参照)
            -- fidgetはLspAttachでのロードのため、初回attachでは未ロードの競合がありうる
            local ok, fidget = pcall(require, "fidget")
            local notify = ok and fidget.notify or vim.notify
            notify(msg, vim.log.levels.WARN)
          end
        end)
      end,
    })
  end,
}
