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
                        showHints = {
                            order = 4,
                            type = "toggle",
                            name = L["Show Hints"],
                            desc = L["Show hints on tooltips without holding the modifier key."],
                        },
                        modifier = {
                            order = 5,
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
                style = {
                    order = 3,
                    type = "group",
                    inline = true,
                    name = L["Style"],
                    args = {
                        note = {
                            order = 1,
                            type = "description",
                            name = L["* The following settings are profile specific."],
                        },
                        font = {
                            order = 1,
                            type = "group",
                            inline = true,
                            name = L["Fonts"],
                            get = function(info)
                                return private.db.profile.style.font[info[#info]]
                            end,
                            set = function(info, value)
                                private.db.profile.style.font[info[#info]] = value
                            end,
                            args = {
                                face = {
                                    order = 1,
                                    type = "select",
                                    style = "dropdown",
                                    dialogControl = "LSM30_Font",
                                    name = L["Font Face"],
                                    values = AceGUIWidgetLSMlists.font,
                                },
                                outline = {
                                    order = 2,
                                    type = "select",
                                    style = "dropdown",
                                    name = L["Font Outline"],
                                    values = private.lists.outlines,
                                },
                                size = {
                                    order = 3,
                                    type = "range",
                                    min = private.CONST.MIN_FONT_SIZE,
                                    max = private.CONST.MAX_FONT_SIZE,
                                    step = 1,
                                    name = L["Font Size"],
                                },
                            },
                        },
                        buttons = {
                            order = 2,
                            type = "group",
                            inline = true,
                            name = L["Buttons"],
                            get = function(info)
                                return private.db.profile.style.buttons[info[#info]]
                            end,
                            set = function(info, value)
                                private.db.profile.style.buttons[info[#info]] = value
                            end,
                            args = {
                                padding = {
                                    order = 1,
                                    type = "range",
                                    min = private.CONST.MIN_PADDING,
                                    max = private.CONST.MAX_PADDING,
                                    step = 1,
                                    name = L["Button Padding"],
                                },
                                size = {
                                    order = 2,
                                    type = "range",
                                    min = private.CONST.MIN_BUTTON_SIZE,
                                    max = private.CONST.MAX_BUTTON_SIZE,
                                    step = 1,
                                    name = L["Button Size"],
                                },
                            },
                        },
                    },
                },
            },
        },
        alerts = {
            order = 2,
            type = "group",
            name = L["Alerts"],
            get = function(info)
                return private.db.global.settings.alerts[info[#info]].format
            end,
            set = function(info, value)
                private.db.global.settings.alerts[info[#info]].format = value
            end,
            args = {
                bar = {
                    order = 1,
                    type = "group",
                    inline = true,
                    name = L["Bar"],
                    args = {
                        bar = {
                            order = 2,
                            type = "input",
                            multiline = true,
                            dialogControl = "FarmingBar_LuaEditBox",
                            width = "full",
                            name = L["Format"],
                        },
                        resetBar = {
                            order = 3,
                            type = "execute",
                            name = L["Reset Bar Alert"],
                            func = function()
                                private.db.global.settings.alerts.bar.format = private.defaults.barAlert
                            end,
                            confirm = function()
                                return L["Are you sure you want to reset bar alerts format?"]
                            end,
                        },
                    },
                },
                button = {
                    order = 2,
                    type = "group",
                    inline = true,
                    name = L["Button"],
                    args = {
                        alertInfo = {
                            order = 1,
                            type = "group",
                            inline = true,
                            name = L["Preview"],
                            get = function(info)
                                return tostring(private.db.global.settings.alerts.button.alertInfo[info[#info]])
                            end,
                            set = function(info, value)
                                local alertInfo = private.db.global.settings.alerts.button.alertInfo
                                private.db.global.settings.alerts.button.alertInfo[info[#info]] = tonumber(value)
                                private.db.global.settings.alerts.button.alertInfo.difference = alertInfo.newCount
                                    - alertInfo.oldCount
                                private.db.global.settings.alerts.button.alertInfo.lost = alertInfo.oldCount
                                    > alertInfo.newCount
                                private.db.global.settings.alerts.button.alertInfo.gained = alertInfo.oldCount
                                    < alertInfo.newCount
                                private.db.global.settings.alerts.button.alertInfo.objectiveMet = alertInfo.newCount
                                    >= alertInfo.objective
                                private.db.global.settings.alerts.button.alertInfo.newObjectiveMet = alertInfo.oldCount
                                    < alertInfo.objective
                                private.db.global.settings.alerts.button.alertInfo.reps = alertInfo.newCount
                                            >= alertInfo.objective
                                        and floor(alertInfo.newCount / alertInfo.objective)
                                    or 0
                            end,
                            validate = function(_, value)
                                value = tonumber(value)
                                return value and value >= 0
                            end,
                            args = {
                                preview = {
                                    order = 1,
                                    type = "description",
                                    name = function()
                                        local alert = private:PreviewAlert("button")
                                        local alertInfo = private.db.global.settings.alerts.button.alertInfo
                                        return alertInfo.oldCount ~= alertInfo.newCount and alert or ""
                                    end,
                                },
                                oldCount = {
                                    order = 2,
                                    type = "input",
                                    name = "info.oldCount",
                                },
                                newCount = {
                                    order = 3,
                                    type = "input",
                                    name = "info.newCount",
                                },
                                objective = {
                                    order = 4,
                                    type = "input",
                                    name = "info.objective",
                                },
                            },
                        },
                        button = {
                            order = 2,
                            type = "input",
                            multiline = true,
                            dialogControl = "FarmingBar_LuaEditBox",
                            width = "full",
                            name = L["Format"],
                            validate = function(_, value)
                                return private:ValidateAlert("button", value)
                                    or L["Alert formats must be a function returning a string value."]
                            end,
                            arg = function(value)
                                return private:ValidateAlert("button", value)
                                    or L["Alert formats must be a function returning a string value."]
                            end,
                        },
                        resetButton = {
                            order = 3,
                            type = "execute",
                            name = L["Reset Button Alert"],
                            func = function()
                                private.db.global.settings.alerts.button.format = private.defaults.buttonAlert
                            end,
                            confirm = function()
                                return L["Are you sure you want to reset button alerts format?"]
                            end,
                        },
                    },
                },
            },
        },
        keybinds = {
            order = 3,
            type = "group",
            name = L["Keybinds"],
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
