local wezterm                  = require 'wezterm'
local act                      = wezterm.action

----------------------------------------------------------------------
-- POWERLINE GLYPHS FROM OFFICIAL NERD FONTS API
----------------------------------------------------------------------
local SOLID_LEFT_ARROW         = wezterm.nerdfonts.pl_right_hard_divider
local SOLID_RIGHT_ARROW        = wezterm.nerdfonts.pl_left_hard_divider

----------------------------------------------------------------------
-- CHOOSE YOUR THEME HERE
----------------------------------------------------------------------
local active_theme             = "catppuccin_mocha"

local theme_candidates         = {
    catppuccin_mocha     = { "Catppuccin Mocha", "Catppuccin-Mocha-Custom" },
    catppuccin_macchiato = { "Catppuccin Macchiato", "catppuccin-macchiato", "Catppuccin Macchiato (Gogh)" },
    dracula              = { "Dracula", "Dracula (base16)", "Dracula (Gogh)" },
    gruvbox_dark         = { "GruvboxDark", "Gruvbox Dark", "Gruvbox Dark (Gogh)" },
    gruvbox_material     = { "Gruvbox Material" },
    tokyo_night          = { "Tokyo Night Moon", "TokyoNight-Storm", "tokyonight_storm" },
    nord                 = { "Nord" },
    solarized_dark       = { "Solarized (dark)" },
}

local builtin                  = wezterm.get_builtin_color_schemes() or {}

-- === CUSTOM SCHEMES MERGE ===
-- Safely pick up the builtin Catppuccin Mocha table (if present) for reuse
local catppuccin_mocha_builtin = builtin["Catppuccin Mocha"] or {}

-- custom_color_schemes from your earlier snippet, adapted safely
local custom_color_schemes     = {
    ["Catppuccin-Mocha-Custom"] = {
        foreground = catppuccin_mocha_builtin.foreground or "#c6c6c6",
        background = catppuccin_mocha_builtin.background or "#1e1e2e",
        cursor_bg = catppuccin_mocha_builtin.cursor_bg or catppuccin_mocha_builtin.foreground or "#c6c6c6",
        cursor_fg = catppuccin_mocha_builtin.cursor_fg or catppuccin_mocha_builtin.background or "#1e1e2e",
        cursor_border = catppuccin_mocha_builtin.cursor_border or catppuccin_mocha_builtin.cursor_bg or "#c6c6c6",
        selection_bg = catppuccin_mocha_builtin.selection_bg or "#334155",
        selection_fg = catppuccin_mocha_builtin.selection_fg or "#c6c6c6",
        ansi = catppuccin_mocha_builtin.ansi or
            { "#24273A", "#F28FAD", "#ABE9B3", "#F8BD96", "#95E6FF", "#DDB6F2", "#BFE6FD", "#C6C8D1" },
        brights = catppuccin_mocha_builtin.brights or
            { "#333244", "#F28FAD", "#ABE9B3", "#F8BD96", "#95E6FF", "#DDB6F2", "#BFE6FD", "#E6E9F2" },
    },

    ["TokyoNight-Storm"] = {
        foreground = "#c0caf5",
        background = "#1a1b26",
        cursor_bg = "#c0caf5",
        cursor_fg = "#1a1b26",
        selection_bg = "#33467c",
        selection_fg = "#c0caf5",
        ansi = { "#16161D", "#f7768e", "#9ece6a", "#e0af68", "#7aa2f7", "#bb9af7", "#7dcfff", "#a9b1d6" },
        brights = { "#414868", "#f7768e", "#9ece6a", "#e0af68", "#7aa2f7", "#bb9af7", "#7dcfff", "#c0caf5" },
    },
}

-- Merge the custom schemes into the builtin table so they are discoverable
for name, scheme in pairs(custom_color_schemes) do
    builtin[name] = scheme
end

----------------------------------------------------------------------
-- helper to pick from candidates (unchanged)
----------------------------------------------------------------------
local function pick(cands)
    if not cands then return nil end
    for _, name in ipairs(cands) do
        if builtin[name] then return name end
    end
    return nil
end

local resolved = pick(theme_candidates[active_theme])

if not resolved then
    local token = active_theme:gsub("_", ""):lower()
    for name, _ in pairs(builtin) do
        if name:lower():gsub("%s", ""):gsub("%-", ""):find(token, 1, true) then
            resolved = name
            break
        end
    end
end

if not resolved then
    resolved = pick({ "Catppuccin Mocha", "Catppuccin-Mocha-Custom", "TokyoNight-Storm", "Builtin Solarized Dark",
        "Builtin Dark" })
end

if not resolved then resolved = "Builtin Dark" end

----------------------------------------------------------------------
-- TAB TITLE HELPERS
----------------------------------------------------------------------

local function tab_title(tab_info)
    if tab_info.tab_title and #tab_info.tab_title > 0 then
        return tab_info.tab_title
    end
    return tab_info.active_pane.title
end

wezterm.on("format-tab-title", function(tab, _, _, _, hover, max_width)
    local title       = tab_title(tab)
    title             = wezterm.truncate_right(title, max_width - 2)

    local active_bg   = "#689d6a"
    local active_fg   = "#1d2021"
    local inactive_bg = "#3c3836"
    local inactive_fg = "#d5c4a1"
    local edge_bg     = "#282828"

    if tab.is_active then
        return {
            { Background = { Color = edge_bg } },
            { Foreground = { Color = active_bg } },
            { Text = SOLID_LEFT_ARROW },
            { Background = { Color = active_bg } },
            { Foreground = { Color = active_fg } },
            { Text = " 🧙‍♂️ " .. title .. " " },
            { Background = { Color = edge_bg } },
            { Foreground = { Color = active_bg } },
            { Text = SOLID_RIGHT_ARROW },
        }
    elseif hover then
        return {
            { Background = { Color = edge_bg } },
            { Foreground = { Color = inactive_bg } },
            { Text = SOLID_LEFT_ARROW },
            { Background = { Color = inactive_bg } },
            { Foreground = { Color = "#ebdbb2" } },
            { Text = " 🧙‍♂️ " .. title .. " " },
            { Background = { Color = edge_bg } },
            { Foreground = { Color = inactive_bg } },
            { Text = SOLID_RIGHT_ARROW },
        }
    else
        return {
            { Background = { Color = edge_bg } },
            { Foreground = { Color = inactive_bg } },
            { Text = SOLID_LEFT_ARROW },
            { Background = { Color = inactive_bg } },
            { Foreground = { Color = inactive_fg } },
            { Text = " 🧙‍♂️ " .. title .. " " },
            { Background = { Color = edge_bg } },
            { Foreground = { Color = inactive_bg } },
            { Text = SOLID_RIGHT_ARROW },
        }
    end
end)

----------------------------------------------------------------------
-- MAIN CONFIG
----------------------------------------------------------------------

return {
    front_end = "WebGpu",
    enable_wayland = false,
    check_for_updates = false,
    initial_cols = 140,
    initial_rows = 40,

    color_scheme = resolved,

    window_padding = {
        left = 2,
        right = 2,
        top = 0, -- << move cursor area up
        bottom = 0,
    },

    font = wezterm.font_with_fallback({
        "FiraCode Nerd Font",
        "Fira Code",
        "Noto Color Emoji",
    }),
    font_size = 12.0,

    window_background_opacity = 0.90,
    hide_tab_bar_if_only_one_tab = false,
    use_fancy_tab_bar = true,
    tab_max_width = 36,
    window_decorations = "RESIZE",
    enable_scroll_bar = false,
    ------------------------------------------------------
    -- window frame (titlebar)
    window_frame = {
        active_titlebar_bg = "#32302f",
        inactive_titlebar_bg = "#282828",
    },
    ---------------------------------------------------------
    colors = {
        tab_bar = {
            background = "#282828",
            inactive_tab_edge = "None",
            inactive_tab_edge_hover = "None",
        },
    },

    default_prog = { "/usr/bin/zsh", "-l" },

    keys = {
        { key = "r", mods = "CTRL|SHIFT", action = act.ReloadConfiguration },
        { key = "c", mods = "CTRL|SHIFT", action = act.CopyTo("Clipboard") },
        { key = "v", mods = "CTRL|SHIFT", action = act.PasteFrom("Clipboard") },
        { key = "n", mods = "CTRL|SHIFT", action = act.SpawnWindow },


        {
            key = "t",
            mods = "CTRL|SHIFT",
            action = wezterm.action_callback(function(window, pane)
                -- get the foreground process name for the active pane
                local fg = pane.foreground_process_name or ""
                fg = fg:lower()

                -- if the foreground process name contains "tmux", act as "inside tmux"
                if fg:find("tmux") then
                    -- spawn a new tab that opens a new tmux window and attach to the session
                    window:perform_action(
                        act.SpawnCommandInNewTab {
                            args = { "/usr/bin/zsh", "-lc",
                                "tmux new-window && tmux attach"
                            },
                        },
                        pane
                    )
                else
                    -- spawn a normal login shell in a new tab
                    window:perform_action(
                        act.SpawnCommandInNewTab {
                            args = { "/usr/bin/zsh", "-l" },
                        },
                        pane
                    )
                end
            end)
        },


        { key = "LeftArrow",  mods = "CTRL|SHIFT", action = act.ActivateTabRelative(-1) },
        { key = "RightArrow", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(1) },

        { key = "LeftArrow",  mods = "CTRL|ALT",   action = act.ActivatePaneDirection("Left") },
        { key = "RightArrow", mods = "CTRL|ALT",   action = act.ActivatePaneDirection("Right") },
        { key = "UpArrow",    mods = "CTRL|ALT",   action = act.ActivatePaneDirection("Up") },
        { key = "DownArrow",  mods = "CTRL|ALT",   action = act.ActivatePaneDirection("Down") },
    },

    scrollback_lines = 10000,
}
