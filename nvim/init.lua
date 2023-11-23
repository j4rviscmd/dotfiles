require('base')
require('maps')
require('plugins')
require('ui')

local os = vim.loop.os_uname().sysname

if os == 'Darwin' then 
  require('macos')
elseif os == 'Windows_NT' then
  require('windows')
elseif os == 'Linux' then
  require('linux')
else
  error("Unknown OS")
end
