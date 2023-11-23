local keymap = vim.keymap

vim.g.mapleader = "m"
-- keymap.set('n', '<C-o>', ':NERDTreeToggle<CR>')
keymap.set('n','<C-p>', '<Plug>AirlineSelectPrevTab')
keymap.set('n','<C-n>', '<Plug>AirlineSelectNextTab')
