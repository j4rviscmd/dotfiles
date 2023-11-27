local status, packer = pcall(require, 'packer')
if(not status) then
  print('Packer is not installed')
  return
end

vim.cmd [[packadd packer.nvim]]

packer.startup(function(use)
  use 'wbthomason/packer.nvim'

  -- When if you yanked, highlight
  use 'machakann/vim-highlightedyank'

  -- Enable git command to neovim
  use 'tpope/vim-fugitive'

  -- Show file icons
  use 'ryanoasis/vim-devicons'

  -- Icon
	use("kyazdani42/nvim-web-devicons")

	-- Show git diff sign leftmost column
	use("lewis6991/gitsigns.nvim")


  -- Commentary
	use({
		"tpope/vim-commentary",
	})

  -- Editor theme
  use({
    'blueshirts/darcula',
    config = function()
      vim.cmd([[colorscheme darcula]])
    end
  })

  
	use({
		"akinsho/bufferline.nvim",
		tag = "v4.4.0",
		requires = "nvim-tree/nvim-web-devicons",
	})

	-- Theme for editor bottom
	use("nvim-lualine/lualine.nvim") -- Statusline


  -- Preview for markdown file
  use({
    "iamcco/markdown-preview.nvim",
    run = function()
      vim.fn["mkdp#util#install"]()
    end,
    config = function()
      vim.g["mkdp_auto_start"] = 0
      vim.g["mkdp_auto_close"] = 1
      vim.g["mkdp_refresh_slow"] = 0
      vim.g["mkdp_command_for_global"] = 0
      vim.g["mkdp_open_to_the_world"] = 0
      vim.g["mkdp_open_ip"] = ''
      vim.g["mkdp_browser"] = ''
      vim.g["mkdp_echo_preview_url"] = 0
      vim.g["mkdp_browserfunc"] = ''
      vim.g["mkdp_preview_options"] = {
        ['mkit'] = {},
        ['katex'] = {},
        ['uml'] = {},
        ['maid'] = {},
        ['disable_sync_scroll'] = 0,
        ['sync_scroll_type'] = 'relative',
        ['hide_yaml_meta'] = 1,
        ['sequence_diagrams'] = {},
        ['flowchart_diagrams'] = {},
        ['content_editable'] = 'v:false',
        ['disable_filename'] = 0,
        ['toc'] = {}
      }
      vim.g["mkdp_markdown_css"] = ''
      vim.g["mkdp_highlight_css"] = ''
      vim.g["mkdp_page_title"] = ''
      vim.g["mkdp_filetypes"] = {'markdown'}
      vim.g["mkdp_theme"] = 'dark'
    end
  })

  -- prettier
  use {
    'prettier/vim-prettier',
    branch = 'release/0.x',
    run = 'npm install',
    config = function()
      vim.g["prettier_autoformat"] = 1
      vim.g["prettier_autoformat_require_pragma"] = 0
      vim.g["prettier_quickfix_enabled"] = 1
      vim.g["prettier_quickfix_auto_focus"] = 0
    end
  }

  -- Nerdtree
  use {'scrooloose/nerdtree',
    config= function()
      vim.g["NERDTreeShowBookmarks"] = 1
      vim.g["NERDTreeShowHidden"] = 1
      vim.g["NERDTreeQuitOnOpen"] = 1
      vim.g["NERDTreeWinSize"] = 200
      vim.g["NERDTreeIgnore"] = { '.DS_Store', '\\.git$', }
    end
  }

  use {
	"windwp/nvim-autopairs",
    config = function() require("nvim-autopairs").setup {} end
  }

  use {
    'nvim-treesitter/nvim-treesitter',
    run = function()
      require('nvim-treesitter.install').update({ with_sync = true })
    end
  }

  use 'windwp/nvim-ts-autotag'
    require'nvim-treesitter.configs'.setup {
    autotag = {
      enable = true,
    }
  }

  use {
    "nvim-telescope/telescope.nvim",
    tag = '0.1.4',
    requires = { {'nvim-lua/plenary.nvim'} },
  }
  use 'nvim-telescope/telescope-file-browser.nvim'

  -- im-select
  use 'keaising/im-select.nvim'

end)
