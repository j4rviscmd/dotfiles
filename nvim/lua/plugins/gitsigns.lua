-- gitsigns.nvim: Git変更をサインカラムに表示
return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    -- ハイライト設定（背景透明でも見えるように前景色を明示）
    vim.api.nvim_set_hl(0, "GitSignsAdd", { fg = "#859900" }) -- 緑
    vim.api.nvim_set_hl(0, "GitSignsChange", { fg = "#b58900" }) -- 黄
    vim.api.nvim_set_hl(0, "GitSignsDelete", { fg = "#f14c4c" }) -- VSCode風の明るい赤

    require("gitsigns").setup({
      debug_mode = false, -- エラーをthrowせず通知として表示
      -- Why: gitバーを最左レーンに置くため診断sign(既定priority 10)より大きくする
      -- (signcolumnはpriority降順で左から並ぶ。VSCodeもgitバーがgutter最左)
      sign_priority = 20,
      -- 削除行はVSCode相当のsign(▁)のみで表示。
      -- 旧show_deletedオプション(deprecated)の仮想行表示は使わない
      -- Note: gitsigns既定はtopdelete='▔'/changedelete='~'で、3種を'▁'へ統一するのは意図的な上書き(~/.local/share/nvim/lazy/gitsigns.nvim/lua/gitsigns/config.lua)
      signs = {
        add = { text = "│" },
        change = { text = "│" },
        delete = { text = "▁" },
        topdelete = { text = "▁" },
        changedelete = { text = "▁" },
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- hunk間ジャンプ
        map("n", "]c", function()
          if vim.wo.diff then
            return "]c"
          end
          vim.schedule(function()
            gs.next_hunk()
          end)
          return "<Ignore>"
        end, { expr = true, desc = "Next hunk" })

        map("n", "[c", function()
          if vim.wo.diff then
            return "[c"
          end
          vim.schedule(function()
            gs.prev_hunk()
          end)
          return "<Ignore>"
        end, { expr = true, desc = "Prev hunk" })

        -- hunk操作
        map("n", "<leader>hs", gs.stage_hunk, { desc = "Stage hunk" })
        map("n", "<leader>hr", gs.reset_hunk, { desc = "Reset hunk" })
        map("n", "<leader>hp", gs.preview_hunk, { desc = "Preview hunk" })
        map("n", "<leader>hb", function()
          gs.blame_line({ full = true })
        end, { desc = "Blame line" })
      end,
    })
  end,
}
