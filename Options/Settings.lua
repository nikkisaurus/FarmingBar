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
                templates = {
                    order = 3,
                    type = "group",
                    inline = true,
                    name = L["Templates"],
                    args = {
                        removeTemplate = {
                            order = 1,
                            type = "select",
                            style = "dropdown",
                            name = L["Remove Template"],
                            values = function()
                                local templates = {}

                                for templateName, _ in pairs(private.db.global.templates) do
                                    templates[templateName] = templateName
                                end

                                return templates
                            end,
                            disabled = function()
                                return addon:tcount(private.db.global.templates) == 0
                            end,
                            confirm = function(_, value)
                                return format(L["Are you sure you want to delete the template \"%s\"?"], value)
                            end,
                            set = function(_, value)
                                private.db.global.templates[value] = nil
                            end,
                        },
                    },
                },
                style = {
                    order = 4,
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
                                abbreviateCount = {
                                    order = 3,
                                    type = "toggle",
                                    name = L["Abbreviate Count"],
                                    desc = L["Abbreviate large numbers on buttons' objective counts."],
                                    set = function(info, value)
                                        private.db.profile.style.buttons[info[#info]] = value
                                        for _, bar in pairs(private.bars) do
                                            bar:UpdateButtons()
                                        end
                                    end,
                                },
                            },
                        },
                    },
                },
                misc = {
                    order = 5,
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
                        includeAuctions = {
                            order = 2,
                            type = "toggle",
                            name = L["Include Auctions"],
                            desc = L["Include items listed on the auction house in objective counts."],
                            hidden = function()
                                return private:MissingDataStore()
                            end,
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
                                private.db.global.settings.alerts.bar.alertInfo.lost = alertInfo.oldProgress > alertInfo.newProgress
                                private.db.global.settings.alerts.bar.alertInfo.gained = alertInfo.oldProgress < alertInfo.newProgress
                                private.db.global.settings.alerts.bar.alertInfo.difference = alertInfo.newProgress - alertInfo.oldProgress
                                private.db.global.settings.alerts.bar.alertInfo.oldTotal = alertInfo.newTotal
                                private.db.global.settings.alerts.bar.alertInfo.newComplete = alertInfo.oldProgress < alertInfo.newTotal and alertInfo.newProgress == alertInfo.newTotal
                            end,
                            args = {
                                preview = {
                                    order = 1,
                                    type = "description",
                                    name = function()
                                        local alert = private:PreviewAlert("bar")
                                        local alertInfo = private.db.global.settings.alerts.bar.alertInfo
                                        return alertInfo.oldProgress ~= alertInfo.newProgress and alertInfo.newTotal > 0 and alertInfo.newProgress <= alertInfo.newTotal and alert or ""
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
                        formatType = {
                            order = 5,
                            type = "select",
                            style = "dropdown",
                            name = L["Format Type"],
                            values = {
                                STRING = L["String"],
                                FUNC = L["Function"],
                            },
                        },
                        formatStr = {
                            order = 6,
                            type = "input",
                            width = "full",
                            name = L["Format"],
                            validate = function(_, value)
                                return private:ValidateAlert("bar", value) or L["Alert formats must be a string value. Please be sure if statements are properly formatted and do not cause a Lua error."]
                            end,
                            hidden = function()
                                return private.db.global.settings.alerts.bar.formatType == "FUNC"
                            end,
                        },
                        bar = {
                            order = 6,
                            type = "input",
                            multiline = true,
                            dialogControl = "FarmingBar_LuaEditBox",
                            width = "full",
                            name = L["Format"],
                            get = function(info)
                                return private.status.luaeditbox or private.db.global.settings.alerts[info[#info]].format
                            end,
                            set = function(info, value)
                                private.db.global.settings.alerts[info[#info]].format = value
                            end,
                            validate = function(_, value)
                                return private:ValidateAlert("bar", value) or L["Alert formats must be a function returning a string value."]
                            end,
                            arg = function(value)
                                return private:ValidateAlert("bar", value) or L["Alert formats must be a function returning a string value."]
                            end,
                            hidden = function()
                                return private.db.global.settings.alerts.bar.formatType == "STRING"
                            end,
                        },
                        resetBar = {
                            order = 7,
                            type = "execute",
                            name = L["Reset Bar Alert"],
                            desc = L["Reset both string and function bar formats."],
                            func = function()
                                private.db.global.settings.alerts.bar.format = private.defaults.barAlert
                                private.db.global.settings.alerts.bar.formatStr = private.defaults.barAlertStr
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
                                private.db.global.settings.alerts.button.alertInfo.difference = alertInfo.newCount - alertInfo.oldCount
                                private.db.global.settings.alerts.button.alertInfo.lost = alertInfo.oldCount > alertInfo.newCount
                                private.db.global.settings.alerts.button.alertInfo.gained = alertInfo.oldCount < alertInfo.newCount
                                private.db.global.settings.alerts.button.alertInfo.goalMet = alertInfo.newCount >= alertInfo.goal
                                private.db.global.settings.alerts.button.alertInfo.newGoalMet = alertInfo.oldCount < alertInfo.goal
                                private.db.global.settings.alerts.button.alertInfo.reps = alertInfo.newCount >= alertInfo.goal and floor(alertInfo.newCount / alertInfo.goal) or 0
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
                        formatType = {
                            order = 5,
                            type = "select",
                            style = "dropdown",
                            name = L["Format Type"],
                            values = {
                                STRING = L["String"],
                                FUNC = L["Function"],
                            },
                        },
                        formatStr = {
                            order = 6,
                            type = "input",
                            width = "full",
                            name = L["Format"],
                            validate = function(_, value)
                                return private:ValidateAlert("button", value) or L["Alert formats must be a string value. Please be sure if statements are properly formatted and do not cause a Lua error."]
                            end,
                            hidden = function()
                                return private.db.global.settings.alerts.button.formatType == "FUNC"
                            end,
                        },
                        button = {
                            order = 6,
                            type = "input",
                            multiline = true,
                            dialogControl = "FarmingBar_LuaEditBox",
                            width = "full",
                            name = L["Format"],
                            get = function(info)
                                return private.status.luaeditbox or private.db.global.settings.alerts[info[#info]].format
                            end,
                            set = function(info, value)
                                private.db.global.settings.alerts[info[#info]].format = value
                            end,
                            validate = function(_, value)
                                return private:ValidateAlert("button", value) or L["Alert formats must be a function returning a string value."]
                            end,
                            arg = function(value)
                                return private:ValidateAlert("button", value) or L["Alert formats must be a function returning a string value."]
                            end,
                            hidden = function()
                                return private.db.global.settings.alerts.button.formatType == "STRING"
                            end,
                        },
                        resetButton = {
                            order = 7,
                            type = "execute",
                            name = L["Reset Button Alert"],
                            desc = L["Reset both string and function button formats."],
                            func = function()
                                private.db.global.settings.alerts.button.format = private.defaults.buttonAlert
                                private.db.global.settings.alerts.button.formatStr = private.defaults.buttonAlertStr
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
                                if info[#info] == "trackerGoal" then
                                    value = value >= 1 and value or 1
                                else
                                    value = value >= 0 and value or 0
                                end

                                local alertInfo = private.db.global.settings.alerts.tracker.alertInfo
                                private.db.global.settings.alerts.tracker.alertInfo[info[#info]] = value
                                private.db.global.settings.alerts.tracker.alertInfo.difference = alertInfo.newCount - alertInfo.oldCount
                                private.db.global.settings.alerts.tracker.alertInfo.lost = alertInfo.oldCount > alertInfo.newCount
                                private.db.global.settings.alerts.tracker.alertInfo.gained = alertInfo.oldCount < alertInfo.newCount
                                private.db.global.settings.alerts.tracker.alertInfo.trackerGoalTotal = alertInfo.goal * alertInfo.trackerGoal
                                private.db.global.settings.alerts.tracker.alertInfo.goalMet = alertInfo.newCount >= alertInfo.trackerGoalTotal
                                private.db.global.settings.alerts.tracker.alertInfo.newComplete = alertInfo.oldCount < alertInfo.trackerGoalTotal and alertInfo.newCount >= alertInfo.trackerGoalTotal
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
                        formatType = {
                            order = 5,
                            type = "select",
                            style = "dropdown",
                            name = L["Format Type"],
                            values = {
                                STRING = L["String"],
                                FUNC = L["Function"],
                            },
                        },
                        formatStr = {
                            order = 6,
                            type = "input",
                            width = "full",
                            name = L["Format"],
                            validate = function(_, value)
                                return private:ValidateAlert("tracker", value) or L["Alert formats must be a string value. Please be sure if statements are properly formatted and do not cause a Lua error."]
                            end,
                            hidden = function()
                                return private.db.global.settings.alerts.tracker.formatType == "FUNC"
                            end,
                        },
                        tracker = {
                            order = 6,
                            type = "input",
                            multiline = true,
                            dialogControl = "FarmingBar_LuaEditBox",
                            width = "full",
                            name = L["Format"],
                            get = function(info)
                                return private.status.luaeditbox or private.db.global.settings.alerts[info[#info]].format
                            end,
                            set = function(info, value)
                                private.db.global.settings.alerts[info[#info]].format = value
                            end,
                            validate = function(_, value)
                                return private:ValidateAlert("tracker", value) or L["Alert formats must be a function returning a string value."]
                            end,
                            arg = function(value)
                                return private:ValidateAlert("tracker", value) or L["Alert formats must be a function returning a string value."]
                            end,
                            hidden = function()
                                return private.db.global.settings.alerts.tracker.formatType == "STRING"
                            end,
                        },
                        resetTracker = {
                            order = 7,
                            type = "execute",
                            name = L["Reset Tracker Alert"],
                            func = function()
                                private.db.global.settings.alerts.tracker.format = private.defaults.trackerAlert
                                private.db.global.settings.alerts.tracker.formatStr = private.defaults.trackerAlertStr
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
                        trackerProgress = {
                            order = 7,
                            type = "select",
                            style = "dropdown",
                            name = L["Tracker Progress"],
                            desc = L["Set the sound played when progress is made towards a tracker."],
                            control = "LSM30_Sound",
                            values = AceGUIWidgetLSMlists.sound,
                        },
                        trackerComplete = {
                            order = 8,
                            type = "select",
                            style = "dropdown",
                            name = L["Tracker Complete"],
                            desc = L["Set the sound played when a tracker's goal is complete."],
                            control = "LSM30_Sound",
                            values = AceGUIWidgetLSMlists.sound,
                        },
                    },
                },

                global = {
                    order = 5,
                    type = "group",
                    inline = true,
                    name = L["Global ChatFrame"],
                    get = function(info)
                        return private.db.global.settings.chatFrame[info[#info]]
                    end,
                    set = function(info, value)
                        private.db.global.settings.chatFrame[info[#info]] = value
                        private:UpdateChatFrame()
                    end,
                    args = {
                        note = {
                            order = 1,
                            type = "description",
                            name = L["Enabling Farming Bar's global chat frame will override any chat frame preferences set by profiles."],
                        },
                        enabled = {
                            order = 2,
                            type = "toggle",
                            name = L["Enable"],
                        },
                        docked = {
                            order = 3,
                            type = "toggle",
                            name = L["Dock"],
                            desc = L["Attach to default chat dock."],
                        },
                    },
                },

                chatFrame = {
                    order = 6,
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

                        for name, frame in addon:pairs(values) do
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
    for command, enabled in addon:pairs(private.db.global.settings.commands) do
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
    for action, keybind in addon:pairs(private.db.global.settings.keybinds) do
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
