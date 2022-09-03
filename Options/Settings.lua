local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)

function private:GetSettingsOptions()
    local options = {
        general = {
            order = 1,
            type = "group",
            name = L["General"],
            args = {
                tooltips = {
                    order = 1,
                    type = "group",
                    inline = true,
                    name = L["Tooltips"],
                    get = function(info)
                        return private.db.global.settings.tooltips[info[#info]]
                    end,
                    set = function(info, value)
                        private.db.global.settings.tooltips[info[#info]] = value
                    end,
                    args = {
                        useGameTooltip = {
                            order = 1,
                            type = "toggle",
                            name = L["Use GameTooltip"],
                        },
                        showLink = {
                            order = 2,
                            type = "toggle",
                            name = L["Show Hyperlink"],
                            desc = L["Show item hyperlink on button tooltips."],
                        },
                        showDetails = {
                            order = 3,
                            type = "toggle",
                            name = L["Show Details"],
                            desc = L["Show all details on tooltips without holding the modifier key."],
                        },
                        modifier = {
                            order = 4,
                            type = "select",
                            style = "dropdown",
                            name = L["Modifier"],
                            desc = L["Hold this key down while hovering over a button to view additional tooltip details."],
                            values = private.lists.Modifiers,
                        },
                    },
                },
                commands = {
                    order = 2,
                    type = "group",
                    inline = true,
                    name = L["Slash Commands"],
                    args = {},
                },
            },
        },
        alerts = {
            order = 2,
            type = "group",
            name = L["Alerts"],
            args = {},
        },
        keybinds = {
            order = 3,
            type = "group",
            name = L["Keybinds"],
            args = {},
        },
        profile = {
            order = 4,
            type = "group",
            name = L["Profile"],
            args = {},
        },
    }

    local i = 1
    for command, enabled in addon.pairs(private.db.global.settings.commands) do
        options.general.args.commands.args[command] = {
            order = i,
            type = "toggle",
            name = command,
            get = function()
                return private.db.global.settings.commands[command]
            end,
            set = function(_, value)
                private.db.global.settings.commands[command] = value
                private:InitializeSlashCommands()
            end,
        }
        i = i + 1
    end

    i = 1
    for action, keybind in addon.pairs(private.db.global.settings.keybinds) do
        options.keybinds.args[action] = {
            order = i,
            type = "group",
            inline = true,
            name = L[action],
            args = {
                mouseButton = {
                    order = 1,
                    type = "select",
                    style = "dropdown",
                    name = L["Mouse Button"],
                    values = private.lists.mouseButtons,
                    get = function(_, value)
                        return keybind.button
                    end,
                    set = function(_, value)
                        private.db.global.settings.keybinds[action].button = value
                    end,
                },
                mod = {
                    order = 2,
                    type = "multiselect",
                    name = L["Modifier"],
                    values = private.lists.modifiers,
                    get = function(_, modifier)
                        local mods = { strsplit("-", keybind.modifier) }
                        return tContains(mods, modifier)
                    end,
                    set = function(info, value, enabled)
                        local shift = info.option.get(info, "shift")
                        local ctrl = info.option.get(info, "ctrl")
                        local alt = info.option.get(info, "alt")

                        if value == "shift" then
                            shift = enabled
                        elseif value == "ctrl" then
                            ctrl = enabled
                        elseif value == "alt" then
                            alt = enabled
                        end

                        local modifier = ""
                        if shift then
                            modifier = "shift"
                        end
                        if ctrl then
                            modifier = "ctrl" .. (modifier ~= "" and "-" or "") .. modifier
                        end
                        if alt then
                            modifier = "alt" .. (modifier ~= "" and "-" or "") .. modifier
                        end

                        private.db.global.settings.keybinds[action].modifier = modifier
                    end,
                },
            },
        }
        i = i + 2
    end

    return options
end
