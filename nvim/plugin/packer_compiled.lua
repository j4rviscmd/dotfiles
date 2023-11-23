-- Automatically generated packer.nvim plugin loader code

if vim.api.nvim_call_function('has', {'nvim-0.5'}) ~= 1 then
  vim.api.nvim_command('echohl WarningMsg | echom "Invalid Neovim version for packer.nvim! | echohl None"')
  return
end

vim.api.nvim_command('packadd packer.nvim')

local no_errors, error_msg = pcall(function()

_G._packer = _G._packer or {}
_G._packer.inside_compile = true

local time
local profile_info
local should_profile = false
if should_profile then
  local hrtime = vim.loop.hrtime
  profile_info = {}
  time = function(chunk, start)
    if start then
      profile_info[chunk] = hrtime()
    else
      profile_info[chunk] = (hrtime() - profile_info[chunk]) / 1e6
    end
  end
else
  time = function(chunk, start) end
end

local function save_profiles(threshold)
  local sorted_times = {}
  for chunk_name, time_taken in pairs(profile_info) do
    sorted_times[#sorted_times + 1] = {chunk_name, time_taken}
  end
  table.sort(sorted_times, function(a, b) return a[2] > b[2] end)
  local results = {}
  for i, elem in ipairs(sorted_times) do
    if not threshold or threshold and elem[2] > threshold then
      results[i] = elem[1] .. ' took ' .. elem[2] .. 'ms'
    end
  end
  if threshold then
    table.insert(results, '(Only showing plugins that took longer than ' .. threshold .. ' ms ' .. 'to load)')
  end

  _G._packer.profile_output = results
end

time([[Luarocks path setup]], true)
local package_path_str = "/Users/maedatakurou/.cache/nvim/packer_hererocks/2.1.1697887905/share/lua/5.1/?.lua;/Users/maedatakurou/.cache/nvim/packer_hererocks/2.1.1697887905/share/lua/5.1/?/init.lua;/Users/maedatakurou/.cache/nvim/packer_hererocks/2.1.1697887905/lib/luarocks/rocks-5.1/?.lua;/Users/maedatakurou/.cache/nvim/packer_hererocks/2.1.1697887905/lib/luarocks/rocks-5.1/?/init.lua"
local install_cpath_pattern = "/Users/maedatakurou/.cache/nvim/packer_hererocks/2.1.1697887905/lib/lua/5.1/?.so"
if not string.find(package.path, package_path_str, 1, true) then
  package.path = package.path .. ';' .. package_path_str
end

if not string.find(package.cpath, install_cpath_pattern, 1, true) then
  package.cpath = package.cpath .. ';' .. install_cpath_pattern
end

time([[Luarocks path setup]], false)
time([[try_loadstring definition]], true)
local function try_loadstring(s, component, name)
  local success, result = pcall(loadstring(s), name, _G.packer_plugins[name])
  if not success then
    vim.schedule(function()
      vim.api.nvim_notify('packer.nvim: Error running ' .. component .. ' for ' .. name .. ': ' .. result, vim.log.levels.ERROR, {})
    end)
  end
  return result
end

time([[try_loadstring definition]], false)
time([[Defining packer_plugins]], true)
_G.packer_plugins = {
  darcula = {
    config = { "\27LJ\2\n7\0\0\3\0\3\0\0056\0\0\0009\0\1\0'\2\2\0B\0\2\1K\0\1\0\24colorscheme darcula\bcmd\bvim\0" },
    loaded = true,
    path = "/Users/maedatakurou/.local/share/nvim/site/pack/packer/start/darcula",
    url = "https://github.com/blueshirts/darcula"
  },
  ["markdown-preview.nvim"] = {
    config = { "\27LJ\2\nß\6\0\0\3\0\30\0O6\0\0\0009\0\1\0)\1\0\0=\1\2\0006\0\0\0009\0\1\0)\1\1\0=\1\3\0006\0\0\0009\0\1\0)\1\0\0=\1\4\0006\0\0\0009\0\1\0)\1\0\0=\1\5\0006\0\0\0009\0\1\0)\1\0\0=\1\6\0006\0\0\0009\0\1\0'\1\b\0=\1\a\0006\0\0\0009\0\1\0'\1\b\0=\1\t\0006\0\0\0009\0\1\0)\1\0\0=\1\n\0006\0\0\0009\0\1\0'\1\b\0=\1\v\0006\0\0\0009\0\1\0005\1\r\0004\2\0\0=\2\14\0014\2\0\0=\2\15\0014\2\0\0=\2\16\0014\2\0\0=\2\17\0014\2\0\0=\2\18\0014\2\0\0=\2\19\0014\2\0\0=\2\20\1=\1\f\0006\0\0\0009\0\1\0'\1\b\0=\1\21\0006\0\0\0009\0\1\0'\1\b\0=\1\22\0006\0\0\0009\0\1\0'\1\24\0=\1\23\0006\0\0\0009\0\1\0'\1\b\0=\1\25\0006\0\0\0009\0\1\0005\1\27\0=\1\26\0006\0\0\0009\0\1\0'\1\29\0=\1\28\0K\0\1\0\tdark\15mkdp_theme\1\2\0\0\rmarkdown\19mkdp_filetypes\20mkdp_page_title\18„Äå${name}„Äç\14mkdp_port\23mkdp_highlight_css\22mkdp_markdown_css\btoc\23flowchart_diagrams\22sequence_diagrams\tmaid\buml\nkatex\tmkit\1\0\5\21disable_filename\3\0\21content_editable\fv:false\19hide_yaml_meta\3\1\21sync_scroll_type\rrelative\24disable_sync_scroll\3\0\25mkdp_preview_options\21mkdp_browserfunc\26mkdp_echo_preview_url\17mkdp_browser\5\17mkdp_open_ip\27mkdp_open_to_the_world\28mkdp_command_for_global\22mkdp_refresh_slow\20mkdp_auto_close\20mkdp_auto_start\6g\bvim\0" },
    loaded = true,
    path = "/Users/maedatakurou/.local/share/nvim/site/pack/packer/start/markdown-preview.nvim",
    url = "https://github.com/iamcco/markdown-preview.nvim"
  },
  nerdtree = {
    config = { "\27LJ\2\n—\1\0\0\2\0\b\0\0216\0\0\0009\0\1\0)\1\1\0=\1\2\0006\0\0\0009\0\1\0)\1\1\0=\1\3\0006\0\0\0009\0\1\0)\1\1\0=\1\4\0006\0\0\0009\0\1\0)\1»\0=\1\5\0006\0\0\0009\0\1\0005\1\a\0=\1\6\0K\0\1\0\1\3\0\0\14.DS_Store\v\\.git$\19NERDTreeIgnore\20NERDTreeWinSize\23NERDTreeQuitOnOpen\23NERDTreeShowHidden\26NERDTreeShowBookmarks\6g\bvim\0" },
    loaded = true,
    path = "/Users/maedatakurou/.local/share/nvim/site/pack/packer/start/nerdtree",
    url = "https://github.com/scrooloose/nerdtree"
  },
  ["nvim-autopairs"] = {
    config = { "\27LJ\2\n@\0\0\3\0\3\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0004\2\0\0B\0\2\1K\0\1\0\nsetup\19nvim-autopairs\frequire\0" },
    loaded = true,
    path = "/Users/maedatakurou/.local/share/nvim/site/pack/packer/start/nvim-autopairs",
    url = "https://github.com/windwp/nvim-autopairs"
  },
  ["nvim-treesitter"] = {
    loaded = true,
    path = "/Users/maedatakurou/.local/share/nvim/site/pack/packer/start/nvim-treesitter",
    url = "https://github.com/nvim-treesitter/nvim-treesitter"
  },
  ["nvim-ts-autotag"] = {
    loaded = true,
    path = "/Users/maedatakurou/.local/share/nvim/site/pack/packer/start/nvim-ts-autotag",
    url = "https://github.com/windwp/nvim-ts-autotag"
  },
  ["packer.nvim"] = {
    loaded = true,
    path = "/Users/maedatakurou/.local/share/nvim/site/pack/packer/start/packer.nvim",
    url = "https://github.com/wbthomason/packer.nvim"
  },
  ["plenary.nvim"] = {
    loaded = true,
    path = "/Users/maedatakurou/.local/share/nvim/site/pack/packer/start/plenary.nvim",
    url = "https://github.com/nvim-lua/plenary.nvim"
  },
  syntastic = {
    loaded = true,
    path = "/Users/maedatakurou/.local/share/nvim/site/pack/packer/start/syntastic",
    url = "https://github.com/scrooloose/syntastic"
  },
  ["telescope.nvim"] = {
    loaded = true,
    path = "/Users/maedatakurou/.local/share/nvim/site/pack/packer/start/telescope.nvim",
    url = "https://github.com/nvim-telescope/telescope.nvim"
  },
  ["vim-airline"] = {
    config = { "\27LJ\2\nÂ\2\0\0\3\0\r\0\0296\0\0\0009\0\1\0)\0012\0=\1\2\0006\0\0\0009\0\3\0)\1\1\0=\1\4\0006\0\0\0009\0\3\0'\1\6\0=\1\5\0006\0\0\0009\0\3\0)\1\1\0=\1\a\0006\0\0\0009\0\3\0'\1\t\0=\1\b\0006\0\0\0009\0\3\0004\1\3\0005\2\v\0>\2\1\0015\2\f\0>\2\2\1=\1\n\0K\0\1\0\1\5\0\0\nerror\fwarning\6y\6x\1\4\0\0\6a\6b\6c&airline#extensions#default#layout\tluna\18airline_theme/airline#extensions#tabline#buffer_idx_mode\16unique_tail)airline#extensions#tabline#formatter'airline#extensions#tabline#enabled\6g\16ttimeoutlen\bopt\bvim\0" },
    loaded = true,
    path = "/Users/maedatakurou/.local/share/nvim/site/pack/packer/start/vim-airline",
    url = "https://github.com/vim-airline/vim-airline"
  },
  ["vim-airline-themes"] = {
    loaded = true,
    path = "/Users/maedatakurou/.local/share/nvim/site/pack/packer/start/vim-airline-themes",
    url = "https://github.com/vim-airline/vim-airline-themes"
  },
  ["vim-devicons"] = {
    loaded = true,
    path = "/Users/maedatakurou/.local/share/nvim/site/pack/packer/start/vim-devicons",
    url = "https://github.com/ryanoasis/vim-devicons"
  },
  ["vim-fugitive"] = {
    loaded = true,
    path = "/Users/maedatakurou/.local/share/nvim/site/pack/packer/start/vim-fugitive",
    url = "https://github.com/tpope/vim-fugitive"
  },
  ["vim-gitgutter"] = {
    loaded = true,
    path = "/Users/maedatakurou/.local/share/nvim/site/pack/packer/start/vim-gitgutter",
    url = "https://github.com/airblade/vim-gitgutter"
  },
  ["vim-highlightedyank"] = {
    loaded = true,
    path = "/Users/maedatakurou/.local/share/nvim/site/pack/packer/start/vim-highlightedyank",
    url = "https://github.com/machakann/vim-highlightedyank"
  },
  ["vim-prettier"] = {
    config = { "\27LJ\2\nø\1\0\0\2\0\6\0\0176\0\0\0009\0\1\0)\1\1\0=\1\2\0006\0\0\0009\0\1\0)\1\0\0=\1\3\0006\0\0\0009\0\1\0)\1\1\0=\1\4\0006\0\0\0009\0\1\0)\1\0\0=\1\5\0K\0\1\0!prettier_quickfix_auto_focus\30prettier_quickfix_enabled'prettier_autoformat_require_pragma\24prettier_autoformat\6g\bvim\0" },
    loaded = true,
    path = "/Users/maedatakurou/.local/share/nvim/site/pack/packer/start/vim-prettier",
    url = "https://github.com/prettier/vim-prettier"
  }
}

time([[Defining packer_plugins]], false)
-- Config for: darcula
time([[Config for darcula]], true)
try_loadstring("\27LJ\2\n7\0\0\3\0\3\0\0056\0\0\0009\0\1\0'\2\2\0B\0\2\1K\0\1\0\24colorscheme darcula\bcmd\bvim\0", "config", "darcula")
time([[Config for darcula]], false)
-- Config for: vim-airline
time([[Config for vim-airline]], true)
try_loadstring("\27LJ\2\nÂ\2\0\0\3\0\r\0\0296\0\0\0009\0\1\0)\0012\0=\1\2\0006\0\0\0009\0\3\0)\1\1\0=\1\4\0006\0\0\0009\0\3\0'\1\6\0=\1\5\0006\0\0\0009\0\3\0)\1\1\0=\1\a\0006\0\0\0009\0\3\0'\1\t\0=\1\b\0006\0\0\0009\0\3\0004\1\3\0005\2\v\0>\2\1\0015\2\f\0>\2\2\1=\1\n\0K\0\1\0\1\5\0\0\nerror\fwarning\6y\6x\1\4\0\0\6a\6b\6c&airline#extensions#default#layout\tluna\18airline_theme/airline#extensions#tabline#buffer_idx_mode\16unique_tail)airline#extensions#tabline#formatter'airline#extensions#tabline#enabled\6g\16ttimeoutlen\bopt\bvim\0", "config", "vim-airline")
time([[Config for vim-airline]], false)
-- Config for: vim-prettier
time([[Config for vim-prettier]], true)
try_loadstring("\27LJ\2\nø\1\0\0\2\0\6\0\0176\0\0\0009\0\1\0)\1\1\0=\1\2\0006\0\0\0009\0\1\0)\1\0\0=\1\3\0006\0\0\0009\0\1\0)\1\1\0=\1\4\0006\0\0\0009\0\1\0)\1\0\0=\1\5\0K\0\1\0!prettier_quickfix_auto_focus\30prettier_quickfix_enabled'prettier_autoformat_require_pragma\24prettier_autoformat\6g\bvim\0", "config", "vim-prettier")
time([[Config for vim-prettier]], false)
-- Config for: markdown-preview.nvim
time([[Config for markdown-preview.nvim]], true)
try_loadstring("\27LJ\2\nß\6\0\0\3\0\30\0O6\0\0\0009\0\1\0)\1\0\0=\1\2\0006\0\0\0009\0\1\0)\1\1\0=\1\3\0006\0\0\0009\0\1\0)\1\0\0=\1\4\0006\0\0\0009\0\1\0)\1\0\0=\1\5\0006\0\0\0009\0\1\0)\1\0\0=\1\6\0006\0\0\0009\0\1\0'\1\b\0=\1\a\0006\0\0\0009\0\1\0'\1\b\0=\1\t\0006\0\0\0009\0\1\0)\1\0\0=\1\n\0006\0\0\0009\0\1\0'\1\b\0=\1\v\0006\0\0\0009\0\1\0005\1\r\0004\2\0\0=\2\14\0014\2\0\0=\2\15\0014\2\0\0=\2\16\0014\2\0\0=\2\17\0014\2\0\0=\2\18\0014\2\0\0=\2\19\0014\2\0\0=\2\20\1=\1\f\0006\0\0\0009\0\1\0'\1\b\0=\1\21\0006\0\0\0009\0\1\0'\1\b\0=\1\22\0006\0\0\0009\0\1\0'\1\24\0=\1\23\0006\0\0\0009\0\1\0'\1\b\0=\1\25\0006\0\0\0009\0\1\0005\1\27\0=\1\26\0006\0\0\0009\0\1\0'\1\29\0=\1\28\0K\0\1\0\tdark\15mkdp_theme\1\2\0\0\rmarkdown\19mkdp_filetypes\20mkdp_page_title\18„Äå${name}„Äç\14mkdp_port\23mkdp_highlight_css\22mkdp_markdown_css\btoc\23flowchart_diagrams\22sequence_diagrams\tmaid\buml\nkatex\tmkit\1\0\5\21disable_filename\3\0\21content_editable\fv:false\19hide_yaml_meta\3\1\21sync_scroll_type\rrelative\24disable_sync_scroll\3\0\25mkdp_preview_options\21mkdp_browserfunc\26mkdp_echo_preview_url\17mkdp_browser\5\17mkdp_open_ip\27mkdp_open_to_the_world\28mkdp_command_for_global\22mkdp_refresh_slow\20mkdp_auto_close\20mkdp_auto_start\6g\bvim\0", "config", "markdown-preview.nvim")
time([[Config for markdown-preview.nvim]], false)
-- Config for: nerdtree
time([[Config for nerdtree]], true)
try_loadstring("\27LJ\2\n—\1\0\0\2\0\b\0\0216\0\0\0009\0\1\0)\1\1\0=\1\2\0006\0\0\0009\0\1\0)\1\1\0=\1\3\0006\0\0\0009\0\1\0)\1\1\0=\1\4\0006\0\0\0009\0\1\0)\1»\0=\1\5\0006\0\0\0009\0\1\0005\1\a\0=\1\6\0K\0\1\0\1\3\0\0\14.DS_Store\v\\.git$\19NERDTreeIgnore\20NERDTreeWinSize\23NERDTreeQuitOnOpen\23NERDTreeShowHidden\26NERDTreeShowBookmarks\6g\bvim\0", "config", "nerdtree")
time([[Config for nerdtree]], false)
-- Config for: nvim-autopairs
time([[Config for nvim-autopairs]], true)
try_loadstring("\27LJ\2\n@\0\0\3\0\3\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0004\2\0\0B\0\2\1K\0\1\0\nsetup\19nvim-autopairs\frequire\0", "config", "nvim-autopairs")
time([[Config for nvim-autopairs]], false)

_G._packer.inside_compile = false
if _G._packer.needs_bufread == true then
  vim.cmd("doautocmd BufRead")
end
_G._packer.needs_bufread = false

if should_profile then save_profiles() end

end)

if not no_errors then
  error_msg = error_msg:gsub('"', '\\"')
  vim.api.nvim_command('echohl ErrorMsg | echom "Error in packer_compiled: '..error_msg..'" | echom "Please check your config for correctness" | echohl None')
end
