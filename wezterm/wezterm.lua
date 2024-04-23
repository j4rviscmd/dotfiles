-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- Spawn a fish shell in login mode
config.default_prog = { "C:\\Program Files\\PowerShell\\7\\pwsh.exe", "-l", "-NoLogo" }
config.default_cwd = "C:\\work"

-- ###############################
-- # Start up                    #
-- ###############################

-- Background opacity
config.window_background_opacity = 1.0
config.win32_system_backdrop = "Auto"

-- Full screen window at startup
-- local mux = wezterm.mux
-- wezterm.on("gui-startup", function(cmd)
-- 	local tab, pane, window = mux.spawn_window(cmd or {})
-- 	window:gui_window():toggle_fullscreen()
-- end)
--

local mux = wezterm.mux

-- Adjust startup window position
wezterm.on("gui-startup", function(cmd)
	local tab, pane, window = mux.spawn_window(cmd or { position = { x = 0, y = 0 } })
	-- local tab, pane, window = mux.spawn_window(cmd or { position = { x = 1915, y = 0 } })
end)

-- Adjust startup windows position
config.initial_cols = 117
config.initial_rows = 61

-- ###############################
-- # User Interface              #
-- ###############################

-- Set font
config.font = wezterm.font("Hack Nerd Font Mono", { weight = "Regular", stretch = "Normal", italic = false })
config.font_size = 10
config.bold_brightens_ansi_colors = false

config.window_padding = {
	left = 10,
	right = 10,
	top = 10,
	bottom = 10,
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

local act = wezterm.action
config.keys = {
	-- Paste from clipboard
	{ key = "v", mods = "CTRL", action = act.PasteFrom("Clipboard") },
	{
		-- Create new tab
		key = "t",
		mods = "ALT",
		action = act.SpawnTab("CurrentPaneDomain"),
	},
	{
		-- Split horizontal
		key = "d",
		mods = "CTRL",
		action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		-- Split horizontal
		key = "d",
		mods = "CTRL|SHIFT",
		action = act.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	-- Switch activate tab for Windows
	{
		-- Switch active tab 1
		key = "1",
		mods = "ALT",
		action = act.ActivateTab(0),
	},
	{
		-- Switch active tab 2
		key = "2",
		mods = "ALT",
		action = act.ActivateTab(1),
	},
	{
		-- Switch active tab 3
		key = "3",
		mods = "ALT",
		action = act.ActivateTab(2),
	},
	{
		-- Switch active tab 4
		key = "4",
		mods = "ALT",
		action = act.ActivateTab(3),
	},
	{
		-- Switch active tab 5
		key = "5",
		mods = "ALT",
		action = act.ActivateTab(4),
	},
	-- Switch activate tab for MAC
	{
		-- Switch active tab 1
		key = "1",
		mods = "CMD",
		action = act.ActivateTab(0),
	},
	{
		-- Switch active tab 2
		key = "2",
		mods = "CMD",
		action = act.ActivateTab(1),
	},
	{
		-- Switch active tab 3
		key = "3",
		mods = "CMD",
		action = act.ActivateTab(2),
	},
	{
		-- Switch active tab 4
		key = "4",
		mods = "CMD",
		action = act.ActivateTab(3),
	},
	{
		-- Switch active tab 5
		key = "5",
		mods = "CMD",
		action = act.ActivateTab(4),
	},
	-- Activate Pane Direction for Windows
	{
		key = "h",
		mods = "ALT",
		action = act.ActivatePaneDirection("Left"),
	},
	{
		key = "l",
		mods = "ALT",
		action = act.ActivatePaneDirection("Right"),
	},
	{
		key = "k",
		mods = "ALT",
		action = act.ActivatePaneDirection("Up"),
	},
	{
		key = "j",
		mods = "ALT",
		action = act.ActivatePaneDirection("Down"),
	},
	-- Activate Pane Direction for MAC
	{
		key = "h",
		mods = "CMD",
		action = act.ActivatePaneDirection("Left"),
	},
	{
		key = "l",
		mods = "CMD",
		action = act.ActivatePaneDirection("Right"),
	},
	{
		key = "k",
		mods = "CMD",
		action = act.ActivatePaneDirection("Up"),
	},
	{
		key = "j",
		mods = "CMD",
		action = act.ActivatePaneDirection("Down"),
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
