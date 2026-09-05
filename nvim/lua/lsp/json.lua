-- json言語のLinter/Formatter/LSP設定
-- NOTE: prettierはmarkdown.luaでも使用するためmason導入前提
return {
  filetypes = { "json", "jsonc" },
  executables = { "prettier" },
  linters = {},
  -- conform.nvim: :Format手動実行(prettier設定が無いプロジェクト向け)
  -- NOTE: prettierは.gitignore対象ファイルを無言で整形スキップする(exit 0で
  -- 入力をそのまま返す)。機密ファイル等を整形しない妥当な挙動のため放置方針
  formatters = {
    json = { "prettier" },
    jsonc = { "prettier" },
  },
  --- require("lsp")の初回ロード時に呼ばれる(autocmd登録等)
  --- @return nil
  on_setup = function()
    --- プロジェクトにprettier設定(.prettierrc系/prettier.config系/package.jsonの
    --- prettierフィールド)が存在するか判定する。設定値の解釈はprettier側が行う
    --- @param buf integer バッファ番号
    --- @return boolean
    local function has_prettier_config(buf)
      if
        vim.fs.root(buf, {
          ".prettierrc",
          ".prettierrc.json",
          ".prettierrc.yml",
          ".prettierrc.yaml",
          ".prettierrc.toml",
          ".prettierrc.js",
          ".prettierrc.cjs",
          ".prettierrc.mjs",
          "prettier.config.js",
          "prettier.config.cjs",
          "prettier.config.mjs",
        })
      then
        return true
      end
      local package = vim.fs.root(buf, { "package.json" })
      if not package then
        return false
      end
      local content = table.concat(vim.fn.readfile(vim.fs.joinpath(package, "package.json")), "\n")
      -- TODO: prettierフィールド検出は文字列検索の簡易実装。誤検知は実害なし
      return content:find('"prettier"') ~= nil
    end

    -- 保存時のprettier自動フォーマット。prettier設定が存在する場合のみ実行
    -- Why: 設定ファイルの存在を「そのプロジェクトのprettierスタイルへの同意」と
    -- みなす方針(pythonのruff、TSのbiomeと同じ)。設定が無いプロジェクトのjsonは
    -- 整形しない。markdownはREADME等の他者記載を壊すリスクから本方針の対象外
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = vim.api.nvim_create_augroup("UserPrettierFormat", {}),
      callback = function(args)
        -- Why: patternにfiletypeを指定できないためcallback内で判定する。
        -- 拡張子列挙(*.json等)だとtsconfig.json(.json拡張子のjsonc)等の
        -- filetype判定から取りこぼしが出るためfiletype直接チェックとする
        local ft = vim.bo[args.buf].filetype
        if ft ~= "json" and ft ~= "jsonc" then
          return
        end
        if not has_prettier_config(args.buf) then
          return
        end
        -- Why: prettier自身も.gitignore対象を整形スキップするが、その場合は
        -- prettier起動(node)が無駄に走るため、nvim側で先に引く
        if require("lsp").is_git_ignored(args.buf) then
          return
        end
        -- Why: BufWritePre内では同期実行にする必要がある。非同期だと書き込みが
        -- 先に走り、整形前の内容がそのまま保存されるため
        require("conform").format({
          bufnr = args.buf,
          async = false,
          lsp_format = "never",
        })
      end,
    })
  end,
}
