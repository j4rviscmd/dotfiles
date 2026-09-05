-- python言語のLinter/Formatter/LSP設定
-- pyright: 型チェック/LSP本体、ruff: lint + format
return {
  lsp = { "pyright", "ruff" },
  linters = {},
  formatters = {},
  filetypes = { "python" },
  -- NOTE: 実行コマンド名はmasonパッケージ名と一致させること
  -- (init.luaのwarnが:MasonInstall <cmd>を案内するため。LSP本体の起動コマンドは
  -- pyright-langserverだが、masonパッケージpyrightが両binを提供する)
  executables = { "pyright", "ruff" },
  --- require("lsp")の初回ロード時に呼ばれる(autocmd登録等)
  --- @return nil
  on_setup = function()
    --- プロジェクトにruff設定(ruff.toml/.ruff.toml/pyproject.tomlの[tool.ruff])が
    --- 存在するか判定する。設定値の解釈はruff server側が行う
    --- @param buf integer バッファ番号
    --- @return boolean
    local function has_ruff_config(buf)
      if vim.fs.root(buf, { "ruff.toml", ".ruff.toml" }) then
        return true
      end
      local pyproject = vim.fs.root(buf, { "pyproject.toml" })
      if not pyproject then
        return false
      end
      local content = table.concat(vim.fn.readfile(vim.fs.joinpath(pyproject, "pyproject.toml")), "\n")
      -- TODO: [tool.ruff]検出は文字列検索の簡易実装。誤検知は実害なし
      return content:find("%[tool%.ruff") ~= nil
    end

    -- 保存時のruff自動フォーマット。ruff設定が存在する場合のみ実行
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = vim.api.nvim_create_augroup("UserRuffFormat", {}),
      pattern = "*.py",
      callback = function(args)
        if not has_ruff_config(args.buf) then
          return
        end
        -- Why: ruffは.gitignoreを解釈しないため、prettierと同等の
        -- gitignore保護をnvim側で行う(lsp/init.luaのis_git_ignored参照)
        if require("lsp").is_git_ignored(args.buf) then
          return
        end
        -- Why: BufWritePre内では同期実行(async=false)にする必要がある。async=trueだと
        -- 書き込みが先に走り、整形前の内容がそのまま保存されるため（:h BufWritePre, :h vim.lsp.buf.format()）
        -- Note: filterでruff以外のアタッチ中クライアントを除外し、pyright等との二重整形を防ぐ
        vim.lsp.buf.format({
          bufnr = args.buf,
          async = false,
          filter = function(client)
            return client.name == "ruff"
          end,
        })
      end,
    })
  end,
}
