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
                        bar = {
                            order = 1,
                            type = "toggle",
                            name = L["Bar Tooltips"],
                            desc = L["Show tooltips when hovering over a bar's anchor."],
                        },
                        button = {
                            order = 2,
                            type = "toggle",
                            name = L["Button Tooltips"],
                            desc = L["Show tooltips when hovering over a button."],
                        },
                        useGameTooltip = {
                            order = 3,
                            type = "toggle",
                            name = L["Use GameTooltip"],
                            desc = L["Use the GameTooltip for bar and button tooltips instead of Farming Bar's default tooltip."],
                        },
                        showLink = {
                            order = 4,
                            type = "toggle",
                            name = L["Show Hyperlink"],
                            desc = L["Show item hyperlink on button tooltips."],
                        },
                        showDetails = {
                            order = 5,
                            type = "toggle",
                            name = L["Show Details"],
                            desc = L["Show all details on tooltips without holding the modifier key."],
                        },
                        showHints = {
                            order = 6,
                            type = "toggle",
                            name = L["Show Hints"],
                            desc = L["Show hints on tooltips without holding the modifier key."],
                        },
                        modifier = {
                            order = 7,
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
                                    desc = L["Set the default padding of bar buttons."],
                                },
                                size = {
                                    order = 2,
                                    type = "range",
                                    min = private.CONST.MIN_BUTTON_SIZE,
                                    max = private.CONST.MAX_BUTTON_SIZE,
                                    step = 1,
                                    name = L["Button Size"],
                                    desc = L["Set the default size of bar buttons."],
                                },
                            },
                        },
                    },
                },
                misc = {
                    order = 4,
                    type = "group",
                    inline = true,
                    name = L["Miscellaneous"],
                    get = function(info)
                        return private.db.global.settings[info[#info]]
                    end,
                    set = function(info, value)
                        private.db.global.settings[info[#info]] = value
                    end,
                    args = {
                        autoLoot = {
                            order = 1,
                            type = "toggle",
                            name = L["Auto Loot"],
                            desc = L["Automatically loot items when using an objective, regardless of whether auto loot is enabled in game settings."],
                        },
                    },
                },
            },
        },
        alerts = {
            order = 2,
            type = "group",
            name = L["Alerts"],
            args = {
                bar = {
                    order = 1,
                    type = "group",
                    name = L["Bar"],
                    get = function(info)
                        return private.db.global.settings.alerts.bar[info[#info]]
                    end,
                    set = function(info, value)
                        private.db.global.settings.alerts.bar[info[#info]] = value
                    end,
                    args = {
                        chat = {
                            order = 1,
                            type = "toggle",
                            name = L["Chat"],
                            desc = L["Enable chat alerts."],
                        },
                        screen = {
                            order = 2,
                            type = "toggle",
                            name = L["Screen"],
                            desc = L["Enable screen alerts."],
                        },
                        sound = {
                            order = 3,
                            type = "toggle",
                            name = L["Sound"],
                            desc = L["Enable sound alerts."],
                        },
                        preview = {
                            order = 4,
                            type = "group",
                            inline = true,
                            name = L["Preview"],
                            get = function(info)
                                return tostring(private.db.global.settings.alerts.bar.alertInfo[info[#info]])
                            end,
                            set = function(info, value)
                                value = tonumber(value) or 0
                                value = value >= 0 and value or 0

                                local alertInfo = private.db.global.settings.alerts.bar.alertInfo
                                private.db.global.settings.alerts.bar.alertInfo[info[#info]] = value
                                private.db.global.settings.alerts.bar.alertInfo.lost = alertInfo.oldProgress
                                    > alertInfo.newProgress
                                private.db.global.settings.alerts.bar.alertInfo.gained = alertInfo.oldProgress
                                    < alertInfo.newProgress
                                private.db.global.settings.alerts.bar.alertInfo.difference = alertInfo.newProgress
                                    - alertInfo.oldProgress
                                private.db.global.settings.alerts.bar.alertInfo.oldTotal = alertInfo.newTotal
                                private.db.global.settings.alerts.bar.alertInfo.newComplete = alertInfo.oldProgress
                                        < alertInfo.newTotal
                                    and alertInfo.newProgress == alertInfo.newTotal
                            end,
                            args = {
                                preview = {
                                    order = 1,
                                    type = "description",
                                    name = function()
                                        local alert = private:PreviewAlert("bar")
                                        local alertInfo = private.db.global.settings.alerts.bar.alertInfo
                                        return alertInfo.oldProgress ~= alertInfo.newProgress
                                                and alertInfo.newTotal > 0
                                                and alertInfo.newProgress <= alertInfo.newTotal
                                                and alert
                                            or ""
                                    end,
                                },
                                oldProgress = {
                                    order = 2,
                                    type = "input",
                                    name = "info.oldProgress",
                                    desc = L["Set the old goal progress for the bar."],
                                },
                                newProgress = {
                                    order = 3,
                                    type = "input",
                                    name = "info.newProgress",
                                    desc = L["Set the new goal progress for the bar."],
                                },
                                newTotal = {
                                    order = 4,
                                    type = "input",
                                    name = "info.newTotal",
                                    desc = L["Set the number of goals for the bar."],
                                },
                            },
                        },
                        bar = {
                            order = 5,
                            type = "input",
                            multiline = true,
                            dialogControl = "FarmingBar_LuaEditBox",
                            width = "full",
                            name = L["Format"],
                            get = function(info)
                                return private.status.luaeditbox
                                    or private.db.global.settings.alerts[info[#info]].format
                            end,
                            set = function(info, value)
                                private.db.global.settings.alerts[info[#info]].format = value
                            end,
                            validate = function(_, value)
                                return private:ValidateAlert("bar", value)
                                    or L["Alert formats must be a function returning a string value."]
                            end,
                            arg = function(value)
                                return private:ValidateAlert("bar", value)
                                    or L["Alert formats must be a function returning a string value."]
                            end,
                        },
                        resetBar = {
                            order = 6,
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
                    name = L["Button"],
                    get = function(info)
                        return private.db.global.settings.alerts.button[info[#info]]
                    end,
                    set = function(info, value)
                        private.db.global.settings.alerts.button[info[#info]] = value
                    end,
                    args = {
                        chat = {
                            order = 1,
                            type = "toggle",
                            name = L["Chat"],
                            desc = L["Enable chat alerts."],
                        },
                        screen = {
                            order = 2,
                            type = "toggle",
                            name = L["Screen"],
                            desc = L["Enable screen alerts."],
                        },
                        sound = {
                            order = 3,
                            type = "toggle",
                            name = L["Sound"],
                            desc = L["Enable sound alerts."],
                        },
                        preview = {
                            order = 4,
                            type = "group",
                            inline = true,
                            name = L["Preview"],
                            get = function(info)
                                return tostring(private.db.global.settings.alerts.button.alertInfo[info[#info]])
                            end,
                            set = function(info, value)
                                value = tonumber(value) or 0
                                value = value >= 0 and value or 0

                                local alertInfo = private.db.global.settings.alerts.button.alertInfo
                                private.db.global.settings.alerts.button.alertInfo[info[#info]] = value
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
                                    desc = L["Set the old count for the objective."],
                                },
                                newCount = {
                                    order = 3,
                                    type = "input",
                                    name = "info.newCount",
                                    desc = L["Set the new count for the objective."],
                                },
                                goal = {
                                    order = 4,
                                    type = "input",
                                    name = "info.goal",
                                    desc = L["Set the goal for the objective."],
                                },
                            },
                        },
                        button = {
                            order = 5,
                            type = "input",
                            multiline = true,
                            dialogControl = "FarmingBar_LuaEditBox",
                            width = "full",
                            name = L["Format"],
                            get = function(info)
                                return private.status.luaeditbox
                                    or private.db.global.settings.alerts[info[#info]].format
                            end,
                            set = function(info, value)
                                private.db.global.settings.alerts[info[#info]].format = value
                            end,
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
                            order = 6,
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

                tracker = {
                    order = 3,
                    type = "group",
                    name = L["Trackers"],
                    get = function(info)
                        return private.db.global.settings.alerts.tracker[info[#info]]
                    end,
                    set = function(info, value)
                        private.db.global.settings.alerts.tracker[info[#info]] = value
                    end,
                    args = {
                        chat = {
                            order = 1,
                            type = "toggle",
                            name = L["Chat"],
                            desc = L["Enable chat alerts."],
                        },
                        screen = {
                            order = 2,
                            type = "toggle",
                            name = L["Screen"],
                            desc = L["Enable screen alerts."],
                        },
                        sound = {
                            order = 3,
                            type = "toggle",
                            name = L["Sound"],
                            desc = L["Enable sound alerts."],
                        },
                        preview = {
                            order = 4,
                            type = "group",
                            inline = true,
                            name = L["Preview"],
                            get = function(info)
                                return tostring(private.db.global.settings.alerts.tracker.alertInfo[info[#info]])
                            end,
                            set = function(info, value)
                                value = tonumber(value) or 0
                                value = value >= 0 and value or 0

                                local alertInfo = private.db.global.settings.alerts.tracker.alertInfo
                                private.db.global.settings.alerts.tracker.alertInfo[info[#info]] = value
                                private.db.global.settings.alerts.tracker.alertInfo.difference = alertInfo.newCount
                                    - alertInfo.oldCount
                                private.db.global.settings.alerts.tracker.alertInfo.lost = alertInfo.oldCount
                                    > alertInfo.newCount
                                private.db.global.settings.alerts.tracker.alertInfo.gained = alertInfo.oldCount
                                    < alertInfo.newCount
                                private.db.global.settings.alerts.tracker.alertInfo.trackerGoal = alertInfo.objective
                                    * alertInfo.trackerObjective
                                private.db.global.settings.alerts.tracker.alertInfo.objectiveMet = alertInfo.newCount
                                    >= alertInfo.trackerGoal
                                private.db.global.settings.alerts.tracker.alertInfo.newComplete = alertInfo.oldCount
                                        < alertInfo.trackerGoal
                                    and alertInfo.newCount >= alertInfo.trackerGoal
                            end,
                            args = {
                                preview = {
                                    order = 1,
                                    type = "description",
                                    name = function()
                                        local alert = private:PreviewAlert("tracker")
                                        local alertInfo = private.db.global.settings.alerts.tracker.alertInfo
                                        return alertInfo.oldCount ~= alertInfo.newCount and alert or ""
                                    end,
                                },
                                oldCount = {
                                    order = 2,
                                    type = "input",
                                    name = "info.oldCount",
                                    desc = L["Set the old count for the tracker."],
                                },
                                newCount = {
                                    order = 3,
                                    type = "input",
                                    name = "info.newCount",
                                    desc = L["Set the new count for the tracker."],
                                },
                                goal = {
                                    order = 4,
                                    type = "input",
                                    name = "info.goal",
                                    desc = L["Set the goal for the objective."],
                                },
                                trackerGoal = {
                                    order = 5,
                                    type = "input",
                                    name = "info.trackerGoal",
                                    desc = L["Set the goal for the tracker."],
                                },
                            },
                        },
                        tracker = {
                            order = 5,
                            type = "input",
                            multiline = true,
                            dialogControl = "FarmingBar_LuaEditBox",
                            width = "full",
                            name = L["Format"],
                            get = function(info)
                                return private.status.luaeditbox
                                    or private.db.global.settings.alerts[info[#info]].format
                            end,
                            set = function(info, value)
                                private.db.global.settings.alerts[info[#info]].format = value
                            end,
                            validate = function(_, value)
                                return private:ValidateAlert("tracker", value)
                                    or L["Alert formats must be a function returning a string value."]
                            end,
                            arg = function(value)
                                return private:ValidateAlert("tracker", value)
                                    or L["Alert formats must be a function returning a string value."]
                            end,
                        },
                        resetTracker = {
                            order = 6,
                            type = "execute",
                            name = L["Reset Tracker Alert"],
                            func = function()
                                private.db.global.settings.alerts.tracker.format = private.defaults.trackerAlert
                            end,
                            confirm = function()
                                return L["Are you sure you want to reset tracker alerts format?"]
                            end,
                        },
                    },
                },

                sounds = {
                    order = 4,
                    type = "group",
                    inline = true,
                    name = L["Sounds"],
                    get = function(info)
                        return private.db.global.settings.alerts.sounds[info[#info]]
                    end,
                    set = function(info, value)
                        private.db.global.settings.alerts.sounds[info[#info]] = value
                    end,
                    args = {
                        progress = {
                            order = 1,
                            type = "select",
                            style = "dropdown",
                            name = L["Farming Progress"],
                            desc = L["Set the sound played when progress is made toward an objective."],
                            control = "LSM30_Sound",
                            values = AceGUIWidgetLSMlists.sound,
                        },
                        objectiveSet = {
                            order = 2,
                            type = "select",
                            style = "dropdown",
                            name = L["Goal Set"],
                            desc = L["Set the sound played when a goal is set for an objective."],
                            control = "LSM30_Sound",
                            values = AceGUIWidgetLSMlists.sound,
                        },
                        objectiveMet = {
                            order = 3,
                            type = "select",
                            style = "dropdown",
                            name = L["Goal Complete"],
                            desc = L["Set the sound played when a goal is met for an objective."],
                            control = "LSM30_Sound",
                            values = AceGUIWidgetLSMlists.sound,
                        },
                        objectiveCleared = {
                            order = 4,
                            type = "select",
                            style = "dropdown",
                            name = L["Goal Cleared"],
                            desc = L["Set the sound played when a goal is cleared from an objective."],
                            control = "LSM30_Sound",
                            values = AceGUIWidgetLSMlists.sound,
                        },
                        barProgress = {
                            order = 5,
                            type = "select",
                            style = "dropdown",
                            name = L["Bar Progress"],
                            desc = L["Set the sound played when progress is made towards a bar's goals."],
                            control = "LSM30_Sound",
                            values = AceGUIWidgetLSMlists.sound,
                        },
                        barComplete = {
                            order = 6,
                            type = "select",
                            style = "dropdown",
                            name = L["Bar Complete"],
                            desc = L["Set the sound played when all goals are met on a bar."],
                            control = "LSM30_Sound",
                            values = AceGUIWidgetLSMlists.sound,
                        },
                    },
                },

                chatFrame = {
                    order = 5,
                    type = "select",
                    name = L["Chat Frame"],
                    desc = L["Default chat frame for chat alerts. * Profile"],
                    get = function()
                        return private.db.profile.chatFrame
                    end,
                    set = function(_, value)
                        private.db.profile.chatFrame = value
                    end,
                    values = function()
                        local values = {}
                        for i = 1, NUM_CHAT_WINDOWS do
                            local name = GetChatWindowInfo(i)
                            if name ~= "" then
                                values["ChatFrame" .. i] = name
                            end
                        end
                        return values
                    end,
                    sorting = function()
                        local values = {}
                        local sorting = {}

                        for i = 1, NUM_CHAT_WINDOWS do
                            local name = GetChatWindowInfo(i)
                            if name ~= "" then
                                values[name] = "ChatFrame" .. i
                            end
                        end

                        for name, frame in addon.pairs(values) do
                            tinsert(sorting, frame)
                        end

                        return sorting
                    end,
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
            desc = L["Enable this slash command."],
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
