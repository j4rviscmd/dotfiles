-- using windows clipboard with yunk
-- vim.opt.clipboard:prepend { 'unnamed', 'unnamedplus' }

-- vim.g.clipboard = {
--   name = 'WslClipboard',
--   copy = {
--     ['+'] = 'win32yank.exe -i --crlf',
--     ['*'] = 'win32yank.exe -i --crlf',
--   },
--   paste = {
--     ['+'] = 'win32yank.exe -o --lf',
--     ['*'] = 'win32yank.exe -o --lf',
--   },
--   cache_enabled = 0,
-- }
vim.opt.clipboard:append({ "unnamedplus" })
