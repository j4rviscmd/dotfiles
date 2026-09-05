-- Completion configuration
-- nvim-cmp + LuaSnip

return {
  -- LuaSnip: Snippet engine
  {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    build = "make install_jsregexp",
    dependencies = {
      "rafamadriz/friendly-snippets",
    },
    --- LuaSnip の設定関数
    --- VSCode形式のスニペットを遅延ロードする
    --- @return nil
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load()
    end,
  },

  -- nvim-cmp: Completion engine
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "saadparwaiz1/cmp_luasnip",
      "L3MON4D3/LuaSnip",
    },
    --- nvim-cmp の設定関数
    --- コード補完の動作、キーマップ、補完ソース、表示形式を設定する
    --- @return nil
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      --- カーソル前に単語が存在するかチェックする
      --- @return boolean カーソル前に単語がある場合はtrue
      local has_words_before = function()
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end

      cmp.setup({
        snippet = {
          --- スニペット展開関数
          --- LSPから受け取ったスニペットをLuaSnipで展開する
          --- @param args table スニペットの引数(bodyフィールドを含む)
          --- @return nil
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },

        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },

        mapping = cmp.mapping.preset.insert({
          -- Scroll documentation
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),

          -- Trigger completion
          ["<C-Space>"] = cmp.mapping.complete(),

          -- Cancel
          ["<C-e>"] = cmp.mapping.abort(),

          -- Confirm selection
          ["<CR>"] = cmp.mapping.confirm({ select = false }),

          -- Tab: Accept copilot, next item, or expand snippet
          ["<Tab>"] = cmp.mapping(function(fallback)
            local ok, suggestion = pcall(require, "copilot.suggestion")
            if ok and suggestion.is_visible() then
              suggestion.accept()
            elseif cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            elseif has_words_before() then
              cmp.complete()
            else
              fallback()
            end
          end, { "i", "s" }),

          -- Shift-Tab: Previous item or jump back
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),

        sources = cmp.config.sources({
          { name = "lazydev", group_index = 0 },
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "path" },
        }, {
          { name = "buffer" },
        }),

        formatting = {
          --- 補完アイテムの表示形式をカスタマイズする
          --- アイコンとソース名を追加して視認性を向上させる
          --- @param entry table 補完エントリ
          --- @param vim_item table 表示用のアイテム情報
          --- @return table 整形後のアイテム情報
          format = function(entry, vim_item)
            -- Kind icons
            local icons = {
              Text = " ",
              Method = " ",
              Function = " ",
              Constructor = " ",
              Field = " ",
              Variable = " ",
              Class = " ",
              Interface = " ",
              Module = " ",
              Property = " ",
              Unit = " ",
              Value = " ",
              Enum = " ",
              Keyword = " ",
              Snippet = " ",
              Color = " ",
              File = " ",
              Reference = " ",
              Folder = " ",
              EnumMember = " ",
              Constant = " ",
              Struct = " ",
              Event = " ",
              Operator = " ",
              TypeParameter = " ",
            }
            vim_item.kind = string.format("%s %s", icons[vim_item.kind] or "", vim_item.kind)

            -- Source indicator
            vim_item.menu = ({
              nvim_lsp = "[LSP]",
              luasnip = "[Snip]",
              buffer = "[Buf]",
              path = "[Path]",
              lazydev = "[Lua]",
            })[entry.source.name]

            return vim_item
          end,
        },

        experimental = {
          ghost_text = true,
        },
      })
    end,
  },
}
