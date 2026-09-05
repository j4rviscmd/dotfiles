-- nvim-treesitter: パーサー管理(:TSInstall/:TSUpdate)
-- Why: highlightは自動有効化されない(:h treesitter-highlight)。FileType時にstart()で有効化
-- Note: パーサーの無いfiletypeはpcallでスキップされ、regex構文highlightにフォールバックする
-- TODO: bundling済みparser(c/lua/markdown/markdown_inline/query/vim/vimdoc)以外の言語は
--   :TSInstallが必要。nvim-treesitter main branchはNeovim 0.12+要件(plugin README.md)で、
--   環境は0.12.5(2026-08にbrew upgrade済み)のため要件は満たす。追加パーサーが必要になった時点で:TSInstallを検討
return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  lazy = false,
  config = function()
    vim.api.nvim_create_autocmd("FileType", {
      callback = function()
        pcall(vim.treesitter.start)
      end,
    })
  end,
}
