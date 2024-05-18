
local status, solarized = pcall(require, "solarized")
if not status then
	return end

solarized.setup({
    highlights = function(colors)
      return {
        -- Error = { fg = '#FF0000', bg = '#2aa198' },
        ErrorMsg = { fg = '#FF0000', bg = '#FFFFFF' },
      }
    end,
  transparent = true,
  styles = {
    comments = { italic = true, bold = false },
    functions = { italic = false },
    variables = { italic = false },

  }
})

vim.o.background = 'dark'
vim.cmd.colorscheme 'solarized'

