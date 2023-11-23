vim.opt.clipboard:append { 'unnamedplus' }
vim.cmd([[autocmd InsertLeave * :silent !/usr/local/bin/im-select com.apple.keylayout.ABC]])

