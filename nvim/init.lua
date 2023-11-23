require("takuroumaeda.base")
require("takuroumaeda.maps")
require("takuroumaeda.plugins")
require("takuroumaeda.highlights")

local os = vim.loop.os_uname().sysname

if os == "Darwin" then
	require("takuroumaeda.macos")
elseif os == "Windows_NT" then
	require("takuroumaeda.windows")
elseif os == "Linux" then
	require("takuroumaeda.linux")
else
	error("Unknown OS")
end


