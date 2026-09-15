-- typescript/javascript言語のLinter/Formatter/LSP設定
-- vtsls: 型・補完・定義(LSP本体)、biome: lint + format
return {
  lsp = { "vtsls", "biome" },
  linters = {},
  formatters = {},
  filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
  executables = { "vtsls", "biome" },
  --- require("lsp")の初回ロード時に呼ばれる(autocmd登録等)
  --- @return nil
  on_setup = function()
    -- Why: lspconfig既定のbiome cmdは関数でPATH上の実行ファイル(プロジェクトローカル
    -- 優先)を使うが、mason/binシンボリックリンク経由だとnpm binラッパーの$0問題で
    -- 起動即死するため、同一ロジックのフォールバック先をresolve_cmd(実体パス解決)に
    -- 変えた関数で上書きする(lsp/init.luaのresolve_cmd参照)
    vim.lsp.config("biome", {
      cmd = function(dispatchers, config)
        local cmd = "biome"
        if (config or {}).root_dir then
          local local_cmd = vim.fs.joinpath(config.root_dir, "node_modules/.bin", cmd)
          if vim.fn.executable(local_cmd) == 1 then
            cmd = local_cmd
          end
        end
        return vim.lsp.rpc.start({ require("lsp").resolve_cmd(cmd), "lsp-proxy" }, dispatchers)
      end,
    })
    --- プロジェクトにbiome設定(biome.json/biome.jsonc)が存在するか判定する
    --- @param buf integer バッファ番号
    --- @return boolean
    local function has_biome_config(buf)
      return vim.fs.root(buf, { "biome.json", "biome.jsonc" }) ~= nil
    end

    -- 保存後のbiome自動fix + 自動フォーマット。biome設定が存在する場合のみ実行
    -- Why: biome LSPはcodeAction非対応のためfixAllをLSP経由で実行できず、
    -- CLI(biome check --write)でsafe fix + formatをファイルへ直接適用する。
    -- ファイルパス渡しのためBiome 2のstdin仕様変更の影響も受けない
    vim.api.nvim_create_autocmd("BufWritePost", {
      group = vim.api.nvim_create_augroup("UserBiomeFormat", {}),
      -- Why: BufWritePostはpatternにfiletypeを指定できないため拡張子列挙とする。
      -- filetype(ts/js系4種)との対応はnvimのファイルタイプ判定に従う
      -- Note: mts/ctsはtypescript、mjs/cjsはjavascriptに判定されるため、8拡張子の列挙で
      -- filetypes(typescript/typescriptreact/javascript/javascriptreact)と同範囲になる
      -- (:h filetype / nvim 0.11 runtime lua/vim/filetype.lua の拡張子テーブル)
      pattern = { "*.ts", "*.tsx", "*.js", "*.jsx", "*.mts", "*.cts", "*.mjs", "*.cjs" },
      callback = function(args)
        if not has_biome_config(args.buf) then
          return
        end
        -- Why: biomeはvcs.useIgnoreFile設定が無い限り.gitignoreを解釈しないため、
        -- prettierと同等のgitignore保護をnvim側で行う(lsp/init.luaのis_git_ignored参照)
        if require("lsp").is_git_ignored(args.buf) then
          return
        end
        -- Why: checktimeはautoread無効だとファイル変更を検知しても再読込しないため、
        -- biome実行前後のファイルサイズ比較で変更を検知し:editでリロードする
        -- NOTE: :editのリロードはundo履歴を保持する
        -- NOTE: サイズ不変の整形は検知できないが、その場合はユーザーが:eすれば良い
        local file = vim.api.nvim_buf_get_name(args.buf)
        local size_before = vim.fn.getfsize(file)
        -- Why: vim.systemは完了を待たないため:wait()で同期待ちする
        -- Note: wait()の第1引数はタイムアウト(ms)。超過時はプロセスがSIGKILLされ
        -- 整形もリロードも行われない(エラーにはならないため無音でスキップされる)
        -- (:h vim.system.SystemObj:wait(), neovim 0.11 runtime lua/vim/_system.lua)
        -- Why: mason/binシンボリックリンク経由だとnpm binラッパーの相対解決が
        -- 崩れてMODULE_NOT_FOUNDで無音失敗するため、実体パスへ解決して実行する
        -- (詳細はlsp/init.luaのresolve_cmd参照)
        vim.system({ require("lsp").resolve_cmd("biome"), "check", "--write", file }):wait(5000)
        if vim.fn.getfsize(file) ~= size_before then
          -- Why: :editはカレントバッファを対象にするため、:wa等でargs.bufが
          -- 非カレントのときも対象バッファを確実にリロードする
          vim.api.nvim_buf_call(args.buf, function()
            vim.cmd("silent! edit")
          end)
        end
      end,
    })
  end,
}
