return {
  "mg979/vim-visual-multi",
  branch = "master",
  init = function()
    vim.g.VM_default_mappings = 0 -- デフォルトマッピング全無効化
    vim.g.VM_quit_after_leaving_insert_mode = 1 -- インサート終了でマルチカーソル解除
    vim.g.VM_maps = {
      ["Visual Cursors"] = "mi", -- マルチカーソル化
    }
  end,
}
