local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)

function private:GetSettingsOptions()
    local options = {
        general = {
            order = 1,
            type = "group",
            name = L["General"],
            args = {},
        },
        keybinds = {
            order = 2,
            type = "group",
            name = L["Keybinds"],
            args = {},
        },
        profile = {
            order = 3,
            type = "group",
            name = L["Profile"],
            args = {},
        },
    }

    local i = 1
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
