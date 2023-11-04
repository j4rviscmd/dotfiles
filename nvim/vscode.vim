" key binds
xmap gc  <Plug>VSCodeCommentary
nmap gc  <Plug>VSCodeCommentary
omap gc  <Plug>VSCodeCommentary
nmap gcc <Plug>VSCodeCommentaryLine

" set showmatch
" set smartcase
" set clipboard+=unnamed
" set helplang=ja
" set title
" set number
" set ignorecase
" set virtualedit=onemore
" set autoread
" set wildmenu
" set backspace=indent,eol,start
" set autoindent
" set smartindent
" set smarttab
" set nobackup
" set noswapfile
" set expandtab
" set tabstop=2
" set shiftwidth=2
" set cursorline
" set nowrap
" set encoding=utf-8
" scriptencoding utf-8

set clipboard=unnamed
let g:clipboard = {
        \   'name': 'myClipboard',
        \   'copy': {
        \      '+': 'win32yank.exe -i',
        \      '*': 'win32yank.exe -i',
        \    },
        \   'paste': {
        \      '+': 'win32yank.exe -o',
        \      '*': 'win32yank.exe -o',
        \   },
        \   'cache_enabled': 1,
        \ }