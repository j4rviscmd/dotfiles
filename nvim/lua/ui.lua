
-- Editor transparent
vim.cmd([[highlight Normal ctermbg=NONE guibg=NONE]])
vim.cmd([[highlight NonText ctermbg=NONE guibg=NONE]])
vim.cmd([[highlight SpecialKey ctermbg=NONE guibg=NONE]])
vim.cmd([[highlight EndOfBuffer ctermbg=NONE guibg=NONE]])

-- Editor font
vim.opt.guifont = "Droid Sans Mono for Powerline Nerd Font Complete 12"

-- Cursor shape
vim.cmd [[let &t_SI = "\<Esc>]50;CursorShape=1\x7"]]
vim.cmd [[let &t_EI = "\<Esc>]50;CursorShape=0\x7"]]
vim.cmd [[let &t_EI = &t_EI .. "\e[2 q"]]

-- Undercurl
vim.cmd([[let &t_Cs = "\e[4:3m"]])
vim.cmd([[let &t_Ce = "\e[4:0m"]])
