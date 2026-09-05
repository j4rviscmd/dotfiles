-- lua言語のLinter/Formatter/LSP設定
-- lua_ls: 補完・診断・定義ジャンプ、stylua: format
-- NOTE: lazydev.nvim(vim API補完library)はplugins/lsp.lua側で定義
-- NOTE: styluaはmason-lspconfigの自動管理対象外のためensure_installedで
-- 入らない。executablesのwarn(:MasonInstall stylua)で導入する
return {
  lsp = { "lua_ls" },
  filetypes = { "lua" },
  executables = { "lua-language-server", "stylua" },
  linters = {},
  formatters = {
    lua = { "stylua" },
  },
  --- サーバー固有のsettings(vim.lsp.config経由でサーバーへ渡される)
  lsp_settings = {
    lua_ls = {
      Lua = {
        workspace = { checkThirdParty = false },
        telemetry = { enable = false },
        completion = { callSnippet = "Replace" },
      },
    },
  },
}
