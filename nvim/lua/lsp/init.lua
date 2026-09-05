-- 言語別Linter/Formatter/LSP設定の集約エントリ
-- 言語追加時はlua/lsp/配下にモジュールを追加し、languagesへ登録する

-- 集約対象の言語モジュール
local languages = {
  "lsp.markdown",
  "lsp.python",
  "lsp.typescript",
  "lsp.tailwind",
  "lsp.lua",
  "lsp.rust",
}

local M = {
  --- vim.lsp.config/enable対象のLSPサーバー一覧(mason管理外を含む。
  --- ensure_installedにはmason_serversを使用すること)
  servers = {},
  --- mason-lspconfig ensure_installed対象のサーバー一覧(mason管理外サーバーは除外)
  mason_servers = {},
  --- LSPサーバー毎のsettings(vim.lsp.config経由でサーバーへ渡される)
  lsp_settings = {},
  --- nvim-lintへ登録するfiletype毎のlinter一覧
  linters_by_ft = {},
  --- conform.nvimへ登録するfiletype毎のformatter一覧
  formatters_by_ft = {},
  --- filetype毎の必須cli一覧(バッファオープン時に存在チェック)
  --- 要素は文字列(mason管理。warnは:MasonInstallを案内)または
  --- { cmd, install }テーブル(mason管理外。warnはinstallコマンドを案内)
  executables_by_ft = {},
}

for _, name in ipairs(languages) do
  local lang = require(name)

  local servers = lang.lsp or {}
  vim.list_extend(M.servers, servers)
  -- Why: rustup管理等のmason管理外サーバー(mason = false)はensure_installedへ
  -- 入れるとmason版バイナリが既存導入をshadowするため除外する
  if lang.mason ~= false then
    vim.list_extend(M.mason_servers, servers)
  end
  for server, settings in pairs(lang.lsp_settings or {}) do
    M.lsp_settings[server] = settings
  end
  for ft, linters in pairs(lang.linters or {}) do
    M.linters_by_ft[ft] = linters
  end
  for ft, formatters in pairs(lang.formatters or {}) do
    M.formatters_by_ft[ft] = formatters
  end
  -- Why: 複数言語モジュールが同一filetypeを共有する(tailwindとtypescriptでtsx等)ため、
  -- 代入だと後勝ちで先のモジュールのチェックが消える。マージする
  local executables = lang.executables or {}
  for _, ft in ipairs(lang.filetypes or {}) do
    M.executables_by_ft[ft] = vim.list_extend(M.executables_by_ft[ft] or {}, executables)
  end
  if lang.on_setup then
    lang.on_setup()
  end
end

-- 対象言語のバッファオープン時に必須cliの存在チェック
-- Why: mason-lspconfigの自動インストール失敗等でcliが欠けた場合、LSP起動失敗の
-- 通知だけでは対策がわかりにくいため、インストールコマンド付きで明示的にwarnする
-- NOTE: 1セッションで同一cliのwarnは1回のみ(warn済みを記憶して連発を防ぐ)
local warned = {}
vim.api.nvim_create_autocmd("BufEnter", {
  group = vim.api.nvim_create_augroup("UserLspExecutableCheck", {}),
  callback = function(args)
    local required = M.executables_by_ft[vim.bo[args.buf].filetype]
    if not required then
      return
    end
    for _, exe in ipairs(required) do
      local cmd = type(exe) == "table" and exe.cmd or exe
      if not warned[cmd] and vim.fn.executable(cmd) == 0 then
        warned[cmd] = true
        local guide = type(exe) == "table" and exe.install or ":MasonInstall " .. cmd
        vim.notify(
          cmd .. " が見つかりません。" .. guide .. " でインストールしてください",
          vim.log.levels.WARN
        )
      end
    end
  end,
})

return M
