" using windows clipboard with yunk
set clipboard=unnamed
let g:clipboard = {
\   'name': 'WslClipboard',
\   'copy': {
\      '+': 'win32yank.exe -i --crlf',
\      '*': 'win32yank.exe -i --crlf',
\    },
\   'paste': {
\      '+': 'win32yank.exe -o --lf',
\      '*': 'win32yank.exe -o --lf',
\   },
\   'cache_enabled': 0,
\ }
autocmd InsertLeave * :silent !/usr/local/bin/im-select com.apple.keylayout.ABC
