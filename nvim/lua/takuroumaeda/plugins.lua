local status, packer = pcall(require, "packer")
if not status then
	print("Packer is not installed")
	return
end

-- When is vscdoe then return 1.
local notCode = function()
	return vim.g.vscode == nil
end

vim.cmd([[packadd packer.nvim]])

packer.startup(function(use)
	use("wbthomason/packer.nvim")

	-- Enable git command to neovim
	use({
		"tpope/vim-fugitive",
		cond = { notCode },
	})

	-- Show file icons
	use({
		"ryanoasis/vim-devicons",
		cond = { notCode },
	})

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
			vim.g["mkdp_open_ip"] = ""
			vim.g["mkdp_browser"] = ""
			vim.g["mkdp_echo_preview_url"] = 0
			vim.g["mkdp_browserfunc"] = ""
			vim.g["mkdp_preview_options"] = {
				["mkit"] = {},
				["katex"] = {},
				["uml"] = {},
				["maid"] = {},
				["disable_sync_scroll"] = 0,
				["sync_scroll_type"] = "relative",
				["hide_yaml_meta"] = 1,
				["sequence_diagrams"] = {},
				["flowchart_diagrams"] = {},
				["content_editable"] = "v:false",
				["disable_filename"] = 0,
				["toc"] = {},
			}
			vim.g["mkdp_markdown_css"] = ""
			vim.g["mkdp_highlight_css"] = ""
			vim.g["mkdp_page_title"] = ""
			vim.g["mkdp_filetypes"] = { "markdown" }
			vim.g["mkdp_theme"] = "dark"
		end,
	})

	use("windwp/nvim-autopairs")

	use({
		"nvim-treesitter/nvim-treesitter",
		run = function()
			require("nvim-treesitter.install").update({ with_sync = true })
		end,
		cond = { notCode },
	})

	use("windwp/nvim-ts-autotag")
	require("nvim-treesitter.configs").setup({
		autotag = {
			enable = true,
		},
	})

	use({
		"nvim-telescope/telescope.nvim",
		tag = "0.1.4",
		requires = { { "nvim-lua/plenary.nvim" } },
		cond = { notCode },
	})
	use({
		"nvim-telescope/telescope-file-browser.nvim",
		cond = { notCode },
	})

	-- icon
	use("kyazdani42/nvim-web-devicons")

	-- Show git diff sign leftmost column
	use({
		"lewis6991/gitsigns.nvim",
		cond = { notCode },
	})

	-- Commentary
	use({
		"tpope/vim-commentary",
		cond = { notCode },
	})

	-- Theme
	use({
		"svrana/neosolarized.nvim", -- Colorscheme
		requires = { "tjdevries/colorbuddy.nvim" },
		cond = { notCode },
	})

	use({
		"akinsho/bufferline.nvim",
		tag = "v4.4.0",
		requires = "nvim-tree/nvim-web-devicons",
		cond = { notCode },
	})

	-- Theme for editor bottom
	use({
		"nvim-lualine/lualine.nvim",
		cond = { notCode },
	}) -- Statusline

	-- When if you yanked, highlight
	use("machakann/vim-highlightedyank")
end)
