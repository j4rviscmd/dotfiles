-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- x86_64-pc-windows-msvc - Windows
-- x86_64-apple-darwin - macOS (Intel)
-- aarch64-apple-darwin - macOS (Apple Silicon)
-- x86_64-unknown-linux-gnu - Linux
local os = wezterm.target_triple

local default_cwd

-- Config of MacOS
if os == "aarch64-apple-darwin" then
	-- Spawn a fish shell in login mode
	config.default_prog = { "/opt/homebrew/bin/fish", "-l" }
	default_cwd = "/Users/maedatakurou/work/development"
	config.font_size = 14

	-- Background opacity
	config.window_background_opacity = 0.8
	config.macos_window_background_blur = 20
end

-- Config of Windows
if os == "x86_64-pc-windows-msvc" then
	-- Spawn a power shell in login mode
	config.default_prog = { "C:\\Program Files\\PowerShell\\7\\pwsh.exe", "-l", "-NoLogo" }
	default_cwd = "C:\\work"
	config.font_size = 10
	-- Background opacity
	config.window_background_opacity = 0.9
	-- config.macos_window_background_blur = 20
	-- config.win32_system_backdrop = "Acrylic"
end

config.default_cwd = default_cwd

-- ###############################
-- # Start up                    #
-- ###############################

-- Maximize windows & start tmux
local mux = wezterm.mux
wezterm.on("gui-startup", function(cmd)
	local tab, pane, window = mux.spawn_window(cmd or {})
	window:gui_window():maximize()
	-- startup exec command
	if os == "aarch64-apple-darwin" then
		pane:send_text("tmux\n")
	end
	if os == "x86_64-pc-windows-msvc" then
		-- 会社PCでは "auto_activate_base Falseが無効化されないため"
		pane:send_text("tmux && conda deactivate\n")
	end
end)

-- local mux = wezterm.mux

-- -- Adjust startup window position
-- wezterm.on("gui-startup", function(cmd)
-- 	local tab, pane, window = mux.spawn_window(cmd or { position = { x = 0, y = 0 } })
-- end)

-- ###############################
-- # User Interface              #
-- ###############################

-- Set font
config.font = wezterm.font("Hack Nerd Font Mono", { weight = "Regular", stretch = "Normal", italic = false })
-- config.font = wezterm.font('Noto Sans Mono CJK JP')

config.bold_brightens_ansi_colors = false
config.cell_width = 1.1

config.window_padding = {
	left = 10,
	right = 10,
	top = 0,
	bottom = 0,
}

-- Solarized theme
config.color_scheme = "Solarized (dark) (terminal.sexy)"

-- Tabbar
config.hide_tab_bar_if_only_one_tab = true

-- ###############################
-- # ShortcutKey                 #
-- ###############################

-- timeout_milliseconds defaults to 1000 and can be omitted
-- leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 },

config.disable_default_key_bindings = true
config.debug_key_events = true

local act = wezterm.action
config.keys = {
	-- paste from the clipboard
	{ key = "v", mods = "CTRL|CMD", action = act.PasteFrom("Clipboard") },
	{
		-- Create new tab
		key = "q",
		mods = "CMD",
		action = act.QuitApplication,
	},
}

-- Bind mouse right-click with Copy & Paste
-- <https://github.com/wez/wezterm/discussions/3541#discussioncomment-5633570>
config.mouse_bindings = {
	{
		event = { Down = { streak = 1, button = "Right" } },
		mods = "NONE",
		action = wezterm.action_callback(function(window, pane)
			local has_selection = window:get_selection_text_for_pane(pane) ~= ""
			if has_selection then
				window:perform_action(act.CopyTo("ClipboardAndPrimarySelection"), pane)
				window:perform_action(act.ClearSelection, pane)
			else
				window:perform_action(act({ PasteFrom = "Clipboard" }), pane)
			end
		end),
	},
}

-- and finally, return the configuration to wezterm
return config
