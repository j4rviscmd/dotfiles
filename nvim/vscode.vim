set encoding=utf-8
scriptencoding utf-8

let $LANG='en_US.UTF-8'

set nobackup
set noswapfile
set autoread
set virtualedit=onemore
set cursorline
set nowrap
set ignorecase
set smartcase
set hlsearch
set incsearch

set clipboard=unnamedplus

if has("win32")
  if executable('python')
    " Why: g:python3_host_progはフルパス指定が必須(nvim runtime doc provider.txt)で~は自動展開されないため、expand()での展開が必須(~のままではプロバイダが起動しない)
    " Note: ユーザ名入り絶対パスを排除する可搬化方針(opencode/opencode.jsonのMCP command設定も同方針)
    let g:python3_host_prog = expand('~/AppData/Local/Programs/Python/Python312/python.exe')
  endif

  if executable('zenhan')
    autocmd InsertLeave * :call system('zenhan 0')
    autocmd CmdlineLeave * :call system('zenhan 0')
  endif
endif

if has('mac')
  set shell=/bin/zsh
  let g:im_select_default = 'com.apple.keylayout.ABC'
  autocmd InsertLeave * :call system('/usr/local/bin/im-select com.apple.keylayout.ABC')
  autocmd CmdlineLeave * :call system('/usr/local/bin/im-select com.apple.keylayout.ABC')
endif

