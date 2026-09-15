-- Tailwind CSS言語のLSP設定
-- tailwindcss-language-serverがclassname補完とhoverでの実際のCSSスタイル表示
-- (例: w-10 -> width: 2.5rem)を提供する
-- NOTE: 補完対象のclass属性(class/className等)とfiletypesはlspconfig既定値を使用
return {
  -- Note: LSPサーバー名は"tailwindcss"だが、masonパッケージ名・実バイナリ名は
  -- "tailwindcss-language-server"(~/.local/share/nvim/mason/packages/ 配下と同名)。
  -- executables_by_ftの存在チェックで案内される「:MasonInstall tailwindcss-language-server」は
  -- このパッケージ名に一致するため成立する
  lsp = { "tailwindcss" },
  linters = {},
  formatters = {},
  filetypes = { "html", "css", "typescriptreact", "javascriptreact" },
  executables = { "tailwindcss-language-server" },
  --- require("lsp")の初回ロード時に呼ばれる(autocmd登録等)
  --- @return nil
  on_setup = function()
    -- Why: lspconfig既定のcmdは関数でPATH上の実行ファイル(プロジェクトローカル優先)
    -- を使うが、mason/binシンボリックリンク経由だとnpm binラッパーの$0問題で起動
    -- 即死するため、同一ロジックのフォールバック先をresolve_cmd(実体パス解決)に
    -- 変えた関数で上書きする(lsp/init.luaのresolve_cmd参照)
    vim.lsp.config("tailwindcss", {
      cmd = function(dispatchers, config)
        local cmd = "tailwindcss-language-server"
        if (config or {}).root_dir then
          local local_cmd = vim.fs.joinpath(config.root_dir, "node_modules/.bin", cmd)
          if vim.fn.executable(local_cmd) == 1 then
            cmd = local_cmd
          end
        end
        return vim.lsp.rpc.start({ require("lsp").resolve_cmd(cmd), "--stdio" }, dispatchers)
      end,
    })
  end,
}
