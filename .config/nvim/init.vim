" synchoronize saving and applying
autocmd BufWritePost  ~/.config/nvim/init.vim  so ~/.config/nvim/init.vim


" read config files
runtime ./plug.vim
runtime ./markdown-preview-plug.vim

if has('wsl')
  runtime ./windows.vim
endif

if has('mac')
  runtime ./mac.vim
endif

" key binds
if exists('g:vscode')
  xmap gc  <Plug>VSCodeCommentary
  nmap gc  <Plug>VSCodeCommentary
  omap gc  <Plug>VSCodeCommentary
  nmap gcc <Plug>VSCodeCommentaryLine
endif

set list
set showmatch
set listchars=tab:»-,trail:-,eol:↲,extends:»,precedes:«,nbsp:%
set clipboard+=unnamed
set helplang=ja
set title
set number
set ignorecase
set virtualedit=onemore
set autoread
set wildmenu
set backspace=indent,eol,start
set autoindent
set smartindent
set smarttab
set nobackup
set noswapfile
set expandtab
set tabstop=2
set shiftwidth=2
set cursorline
set nowrap
set encoding=utf-8
scriptencoding utf-8


if !exists('g:vscode')
  autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
  autocmd StdinReadPre * let s:std_in=1
  autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
  nmap <C-o> :NERDTreeToggle<CR>

  " editor-theme
  colorscheme molokai
  syntax on
  set t_Co=256
  set termguicolors
  set background=dark

  " editor transparent
  highlight Normal ctermbg=NONE guibg=NONE
  highlight NonText ctermbg=NONE guibg=NONE
  highlight SpecialKey ctermbg=NONE guibg=NONE
  highlight EndOfBuffer ctermbg=NONE guibg=NONE

  " editor font
  set guifont=Droid\ Sans\ Mono\ for\ Powerline\ Nerd\ Font\ Complete\ 12

  " prettier
  let g:prettier#autoformat = 1
  let g:prettier#autoformat_require_pragma = 0
  let g:prettier#quickfix_enabled = 1
  let g:prettier#quickfix_auto_focus = 0

  " NERDTree
  let g:NERDTreeShowBookmarks=1
  let g:NERDTreeShowHidden=1
  let g:NERDTreeQuitOnOpen=1
  let NERDTreeIgnore=['.DS_Store', '\.git$',]
  let g:NERDTreeWinSize=200

  " vim-airline
  set ttimeoutlen=50
  let g:airline#extensions#tabline#enabled = 1
  let g:airline#extensions#tabline#buffer_idx_mode = 1
  " let g:airline_section_z = '%2l/%L☰%2v'
  let g:airline_theme = 'luna'
  let g:airline#extensions#tabline#formatter = 'unique_tail'
  let g:airline#extensions#default#layout = [
  \ [ 'a', 'b', 'c'],
  \ [ 'error', 'warning', 'y', 'x' ],
  \ ]
  nmap <C-p> <Plug>AirlineSelectPrevTab
  nmap <C-n> <Plug>AirlineSelectNextTab

  " cursor shape
  let &t_SI = "\<Esc>]50;CursorShape=1\x7"
  let &t_EI = "\<Esc>]50;CursorShape=0\x7"
  let &t_EI .= "\e[2 q"

endif

" easymotion
if exists('g:vscode')
  "  nmap f <Plug>(easymotion-s2)
  nmap f <Plug>(easymotion-bd-w)
else
  nmap f <Plug>(easymotion-overwin-w)
endif
let g:EasyMotion_do_mattping = 0
let g:EasyMotion_smartcase = 1

if !exists('g:vscode')
lua << EOF
  require("nvim-autopairs").setup{}
  require('nvim-ts-autotag').setup{}
EOF
endif
