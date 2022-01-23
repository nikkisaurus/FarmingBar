local addonName = ...
local addon = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

-- Optional libraries
local ACD = LibStub("AceConfigDialog-3.0")

addon.editors = {}

-- *------------------------------------------------------------------------

function addon:GetSettingsOptions()
    local options = {
        global = {
            order = 1,
            type = "group",
            childGroups = "tab",
            name = L["Global"],
            args = {
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
                                return addon:GetDBValue("global", "settings.tooltips." .. info[#info])
                            end,
                            set = function(info, value)
                                self:SetDBValue("global", "settings.tooltips." .. info[#info], value)
                            end,
                            args = {
                                bar = {
                                    order = 1,
                                    type = "toggle",
                                    name = L["Bar"],
                                    desc = L.Options_settings_global_general_tooltips_bar,
                                },
                                button = {
                                    order = 2,
                                    type = "toggle",
                                    name = L["Button"],
                                    desc = L.Options_settings_global_general_tooltips_button,
                                },
                                useGameTooltip = {
                                    order = 3,
                                    type = "toggle",
                                    name = L["Use Game Tooltip"],
                                    desc = L.Options_settings_global_general_tooltips_useGameTooltip,
                                },
                                condensedTooltip = {
                                    order = 4,
                                    type = "toggle",
                                    name = L["Condensed Tooltip"],
                                    desc = L.Options_settings_global_general_hints_condensedTooltip,
                                },
                                modifier = {
                                    order = 5,
                                    type = "select",
                                    style = "dropdown",
                                    name = L["Modifier"],
                                    desc = L.Options_settings_global_general_hints_modifier,
                                    values = function(info)
                                        local info = {
                                            Alt = L["Alt"],
                                            Control = L["Control"],
                                            Shift = L["Shift"],
                                        }

                                        return info
                                    end,
                                    sorting = {"Alt", "Control", "Shift"},
                                },
                            },
                        },
                        hints = {
                            order = 2,
                            type = "group",
                            inline = true,
                            name = L["Hints"],
                            get = function(info)
                                return addon:GetDBValue("global", "settings.hints." .. info[#info])
                            end,
                            set = function(info, value)
                                self:SetDBValue("global", "settings.hints." .. info[#info], value)
                            end,
                            args = {
                                bars = {
                                    order = 1,
                                    type = "toggle",
                                    name = L["Bars"],
                                    desc = L.Options_settings_global_general_hints_bars,
                                },
                                buttons = {
                                    order = 2,
                                    type = "toggle",
                                    name = L["Buttons"],
                                    desc = L.Options_settings_global_general_hints_buttons,
                                },
                            },
                        },
                        templates = {
                            order = 3,
                            type = "group",
                            inline = true,
                            get = function(info)
                                return addon:GetDBValue("global", "settings.misc." .. info[#info])
                            end,
                            set = function(info, value)
                                self:SetDBValue("global", "settings.misc." .. info[#info], value)
                            end,
                            name = L["Templates"],
                            args = {
                                deleteTemplate = {
                                    order = 1,
                                    type = "select",
                                    style = "dropdown",
                                    name = L["Delete Template"],
                                    desc = L.Options_settings_global_templates_deleteTemplate,
                                    confirm = function(_, value)
                                        return format(L.Options_settings_global_templates_deleteTemplateConfirm, value)
                                    end,
                                    disabled = function()
                                        return self.tcount(addon:GetDBValue("global", "templates")) == 0
                                    end,
                                    values = function(info)
                                        local info = {}

                                        for templateName, _ in pairs(addon:GetDBValue("global", "templates")) do
                                            info[templateName] = templateName
                                        end

                                        return info
                                    end,
                                    set = function(_, value)
                                        self:DeleteTemplate(value)
                                    end,
                                },
                                preserveTemplateData = {
                                    order = 2,
                                    type = "select",
                                    style = "dropdown",
                                    name = L["Preserve Template Data"],
                                    desc = L.Options_settings_global_templates_preserveTemplateData,
                                    values = function(info)
                                        local info = {
                                            ENABLED = L["ENABLED"],
                                            DISABLED = L["DISABLED"],
                                            PROMPT = L["PROMPT"],
                                        }

                                        return info
                                    end,
                                    sorting = {"ENABLED", "DISABLED", "PROMPT"},
                                },
                                preserveTemplateOrder = {
                                    order = 3,
                                    type = "select",
                                    style = "dropdown",
                                    name = L["Preserve Template Order"],
                                    desc = L.Options_settings_global_templates_preserveTemplateOrder,
                                    values = function(info)
                                        local info = {
                                            ENABLED = L["ENABLED"],
                                            DISABLED = L["DISABLED"],
                                            PROMPT = L["PROMPT"],
                                        }

                                        return info
                                    end,
                                    sorting = {"ENABLED", "DISABLED", "PROMPT"},
                                },
                            },
                        },
                        misc = {
                            order = 4,
                            type = "group",
                            inline = true,
                            get = function(info)
                                return addon:GetDBValue("global", "settings.misc." .. info[#info])
                            end,
                            set = function(info, value)
                                self:SetDBValue("global", "settings.misc." .. info[#info], value)
                            end,
                            name = L["Miscellaneous"],
                            args = {
                                autoLootOnUse = {
                                    order = 1,
                                    type = "toggle",
                                    width = "full",
                                    disabled = true, -- ! temporary until implemented
                                    name = L["Auto loot items on use"],
                                    desc = L.Options_settings_global_misc_autoLootOnUse,
                                },
                            },
                        },
                        commands = {
                            order = 5,
                            type = "group",
                            inline = true,
                            name = L["Slash Commands"],
                            get = function(info)
                                return addon:GetDBValue("global", "settings.commands." .. info[#info])
                            end,
                            set = function(info, value)
                                self:SetDBValue("global", "settings.commands." .. info[#info], value)
                                self:RegisterSlashCommands()
                            end,
                            args = {
                                farmingbar = {
                                    order = 1,
                                    type = "toggle",
                                    name = "/farmingbar",
                                },
                                farmbar = {
                                    order = 2,
                                    type = "toggle",
                                    name = "/farmbar",
                                },
                                farm = {
                                    order = 3,
                                    type = "toggle",
                                    name = "/farm",
                                },
                                fbar = {
                                    order = 4,
                                    type = "toggle",
                                    name = "/fbar",
                                },
                                fb = {
                                    order = 5,
                                    type = "toggle",
                                    name = "/fb",
                                },
                            },
                        },
                        debug = {
                            order = 99,
                            type = "group",
                            inline = true,
                            name = L["Debug"],
                            get = function(info)
                                return addon:GetDBValue("global", "settings.debug." .. info[#info])
                            end,
                            set = function(info, value)
                                self:SetDBValue("global", "settings.debug." .. info[#info], value)
                            end,
                            args = {},
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
                                return addon:GetDBValue("global", "settings.alerts.bar." .. info[#info])
                            end,
                            set = function(info, value)
                                self:SetDBValue("global", "settings.alerts.bar." .. info[#info], value)
                            end,
                            args = {
                                chat = {
                                    order = 1,
                                    type = "toggle",
                                    name = L["Chat"],
                                },
                                screen = {
                                    order = 2,
                                    type = "toggle",
                                    name = L["Screen"],
                                },
                                sound = {
                                    order = 3,
                                    type = "toggle",
                                    name = L["Sound"],
                                    get = function()
                                        return addon:GetDBValue("global", "settings.alerts.bar.sound.enabled")
                                    end,
                                    set = function(_, value)
                                        self:SetDBValue("global", "settings.alerts.bar.sound.enabled", value)
                                    end,
                                },
                                format = {
                                    order = 4,
                                    type = "group",
                                    name = L["Formats"],
                                    inline = true,
                                    args = {
                                        progress = {
                                            order = 1,
                                            type = "input",
                                            name = L["Progress Format"],
                                            width = "full",
                                            multiline = true,
                                            dialogControl = "FarmingBar_LuaEditBox",
                                            get = function(info)
                                                return addon:GetDBValue("global", "settings.alerts.bar.format.progress")
                                            end,
                                            set = function(info, value)
                                                addon:SetDBValue("global", "settings.alerts.bar.format.progress", value)
                                                addon:UpdateAlert("bar", "progress", value)
                                            end,
                                            arg = {"global", "settings.alerts.bar.format.progress", "PreviewAlert", {"bar"}},
                                        },
                                        previewSettings = {
                                            order = 2,
                                            type = "header",
                                            name = L["Preview Settings"],
                                        },
                                        previewCount = {
                                            order = 3,
                                            type = "range",
                                            name = L["Completed Objectives"],
                                            min = 0,
                                            max = addon.maxButtons,
                                            step = 1,
                                            get = function()
                                                return addon:GetDBValue("global", "settings.alerts.bar.preview.count")
                                            end,
                                            set = function(_, value)
                                                addon:SetDBValue("global", "settings.alerts.bar.preview.count", value)
                                            end,
                                        },
                                        previewTotal = {
                                            order = 4,
                                            type = "range",
                                            name = L["Total Objectives"],
                                            min = 0,
                                            max = addon.maxButtons,
                                            step = 1,
                                            get = function()
                                                return addon:GetDBValue("global", "settings.alerts.bar.preview.total")
                                            end,
                                            set = function(_, value)
                                                addon:SetDBValue("global", "settings.alerts.bar.preview.total", value)
                                            end,
                                        },
                                        alertType = {
                                            order = 5,
                                            type = "select",
                                            style = "dropdown",
                                            name = L["Alert Type"],
                                            values = function()
                                                return {
                                                    complete = L["Gain"],
                                                    lost = L["Loss"],
                                                }
                                            end,
                                            get = function()
                                                return addon:GetDBValue("global", "settings.alerts.bar.preview.alertType")
                                            end,
                                            set = function(_, value)
                                                addon:SetDBValue("global", "settings.alerts.bar.preview.alertType", value)
                                            end,
                                        },
                                        toggle = {
                                            order = 6,
                                            type = "toggle",
                                            name = L["Use Long Name"],
                                            get = function()
                                                return addon:GetDBValue("global", "settings.alerts.bar.preview.withTitle")
                                            end,
                                            set = function(_, value)
                                                addon:SetDBValue("global", "settings.alerts.bar.preview.withTitle", value)
                                            end,
                                        },
                                    },
                                },
                                sounds = {
                                    order = 5,
                                    type = "group",
                                    name = L["Sounds"],
                                    inline = true,
                                    get = function(info)
                                        return addon:GetDBValue("global", "settings.alerts.bar.sound." .. info[#info])
                                    end,
                                    set = function(info, value)
                                        self:SetDBValue("global", "settings.alerts.bar.sound." .. info[#info], value)
                                    end,
                                    args = {
                                        progress = {
                                            order = 1,
                                            type = "select",
                                            style = "dropdown",
                                            name = L["Bar Progress"],
                                            control = "LSM30_Sound",
                                            values = AceGUIWidgetLSMlists.sound,
                                        },
                                        complete = {
                                            order = 2,
                                            type = "select",
                                            style = "dropdown",
                                            name = L["Bar Complete"],
                                            control = "LSM30_Sound",
                                            values = AceGUIWidgetLSMlists.sound,
                                        },
                                    },
                                },
                            },
                        },
                        button = {
                            order = 1,
                            type = "group",
                            name = L["Button"],
                            get = function(info)
                                return addon:GetDBValue("global", "settings.alerts.button." .. info[#info])
                            end,
                            set = function(info, value)
                                self:SetDBValue("global", "settings.alerts.button." .. info[#info], value)
                            end,
                            args = {
                                chat = {
                                    order = 1,
                                    type = "toggle",
                                    name = L["Chat"],
                                },
                                screen = {
                                    order = 2,
                                    type = "toggle",
                                    name = L["Screen"],
                                },
                                sound = {
                                    order = 3,
                                    type = "toggle",
                                    name = L["Sound"],
                                    get = function(info)
                                        return addon:GetDBValue("global", "settings.alerts.button.sound.enabled")
                                    end,
                                    set = function(_, value)
                                        self:SetDBValue("global", "settings.alerts.button.sound.enabled", value)
                                    end,
                                },
                                format = {
                                    order = 4,
                                    type = "group",
                                    name = L["Formats"],
                                    inline = true,
                                    args = {
                                        withObjective = {
                                            order = 1,
                                            type = "input",
                                            name = L["Format With Objective"],
                                            width = "full",
                                            multiline = true,
                                            dialogControl = "FarmingBar_LuaEditBox",
                                            get = function(info)
                                                return addon:GetDBValue("global", "settings.alerts.button.format.withObjective")
                                            end,
                                            set = function(info, value)
                                                addon:SetDBValue("global", "settings.alerts.button.format.withObjective", value)
                                                addon:UpdateAlert("button", "withObjective", value)
                                            end,
                                            arg = {"global", "settings.alerts.button.format.withObjective", "PreviewAlert", {"button"}},
                                        },
                                        withObjectivePreview = {
                                            order = 2,
                                            type = "description",
                                            name = function(text)
                                                return text
                                            end,
                                            width = "full",
                                        },
                                        withoutObjective = {
                                            order = 3,
                                            type = "input",
                                            name = L["Format Without Objective"],
                                            width = "full",
                                            multiline = true,
                                            dialogControl = "FarmingBar_LuaEditBox",
                                            get = function(info)
                                                return addon:GetDBValue("global", "settings.alerts.button.format.withoutObjective")
                                            end,
                                            set = function(info, value)
                                                addon:SetDBValue("global", "settings.alerts.button.format.withoutObjective", value)
                                                addon:UpdateAlert("button", "withoutObjective", value)
                                            end,
                                            arg = {"global", "settings.alerts.button.format.withoutObjective", "PreviewAlert", {"button"}},
                                        },
                                        previewSettings = {
                                            order = 4,
                                            type = "header",
                                            name = L["Preview Settings"],
                                        },
                                        oldCount = {
                                            order = 5,
                                            type = "input",
                                            name = L["Old Count"],
                                            width = 0.5,
                                            validate = function(_, value)
                                                local count = tonumber(value)
                                                return count and count >= 0
                                            end,
                                            get = function()
                                                return tostring(addon:GetDBValue("global", "settings.alerts.button.preview.oldCount"))
                                            end,
                                            set = function(_, value)
                                                addon:SetDBValue("global", "settings.alerts.button.preview.oldCount", tonumber(value))
                                            end,
                                        },
                                        newCount = {
                                            order = 6,
                                            type = "input",
                                            name = L["New Count"],
                                            width = 0.5,
                                            validate = function(_, value)
                                                local count = tonumber(value)
                                                return count and count >= 0
                                            end,
                                            get = function()
                                                return tostring(addon:GetDBValue("global", "settings.alerts.button.preview.newCount"))
                                            end,
                                            set = function(_, value)
                                                addon:SetDBValue("global", "settings.alerts.button.preview.newCount", tonumber(value))
                                            end,
                                        },
                                        objective = {
                                            order = 7,
                                            type = "input",
                                            name = L["Objective"],
                                            width = 0.5,
                                            validate = function(_, value)
                                                local count = tonumber(value)
                                                return count and count >= 1
                                            end,
                                            get = function()
                                                return tostring(addon:GetDBValue("global", "settings.alerts.button.preview.objective"))
                                            end,
                                            set = function(_, value)
                                                addon:SetDBValue("global", "settings.alerts.button.preview.objective", tonumber(value))
                                            end,
                                        },
                                    },
                                },
                                sounds = {
                                    order = 5,
                                    type = "group",
                                    name = L["Sounds"],
                                    inline = true,
                                    get = function(info)
                                        return addon:GetDBValue("global", "settings.alerts.button.sound." .. info[#info])
                                    end,
                                    set = function(info, value)
                                        self:SetDBValue("global", "settings.alerts.button.sound." .. info[#info], value)
                                    end,
                                    args = {
                                        objectiveSet = {
                                            order = 1,
                                            type = "select",
                                            style = "dropdown",
                                            name = L["Objective Set"],
                                            control = "LSM30_Sound",
                                            values = AceGUIWidgetLSMlists.sound,
                                        },
                                        objectiveCleared = {
                                            order = 2,
                                            type = "select",
                                            style = "dropdown",
                                            name = L["Objective Cleared"],
                                            control = "LSM30_Sound",
                                            values = AceGUIWidgetLSMlists.sound,
                                        },
                                        progress = {
                                            order = 3,
                                            type = "select",
                                            style = "dropdown",
                                            name = L["Progress"],
                                            control = "LSM30_Sound",
                                            values = AceGUIWidgetLSMlists.sound,
                                        },
                                        objectiveComplete = {
                                            order = 4,
                                            type = "select",
                                            style = "dropdown",
                                            name = L["Objective Complete"],
                                            control = "LSM30_Sound",
                                            values = AceGUIWidgetLSMlists.sound,
                                        },
                                    },
                                },
                            },
                        },

                        tracker = {
                            order = 1,
                            type = "group",
                            name = L["Tracker"],
                            args = {
                                chat = {
                                    order = 1,
                                    type = "toggle",
                                    name = L["Chat"],
                                },
                                screen = {
                                    order = 2,
                                    type = "toggle",
                                    name = L["Screen"],
                                },
                                sound = {
                                    order = 3,
                                    type = "toggle",
                                    name = L["Sound"],
                                    get = function(info)
                                        return addon:GetDBValue("global", "settings.alerts.tracker.sound.enabled")
                                    end,
                                    set = function(_, value)
                                        self:SetDBValue("global", "settings.alerts.tracker.sound.enabled", value)
                                    end,
                                },
                                format = {
                                    order = 4,
                                    type = "group",
                                    name = L["Formats"],
                                    inline = true,
                                    args = {                                        
                                        progress = {
                                            order = 1,
                                            type = "input",
                                            name = L["Progress Format"],
                                            width = "full",
                                            multiline = true,
                                            dialogControl = "FarmingBar_LuaEditBox",
                                            get = function(info)
                                                return addon:GetDBValue("global", "settings.alerts.tracker.format.progress")
                                            end,
                                            set = function(info, value)
                                                addon:SetDBValue("global", "settings.alerts.tracker.format.progress", value)
                                                addon:UpdateAlert("tracker", "progress", value)
                                            end,
                                            arg = {"global", "settings.alerts.tracker.format.progress", "PreviewAlert", {"tracker"}},
                                        },
                                        previewSettings = {
                                            order = 2,
                                            type = "header",
                                            name = L["Preview Settings - Tracker"],
                                        },
                                        oldCount = {
                                            order = 3,
                                            type = "input",
                                            name = L["Old Count"],
                                            width = 0.5,
                                            validate = function(_, value)
                                                local count = tonumber(value)
                                                return count and count >= 0
                                            end,
                                            get = function()
                                                return tostring(addon:GetDBValue("global", "settings.alerts.tracker.preview.oldCount"))
                                            end,
                                            set = function(_, value)
                                                addon:SetDBValue("global", "settings.alerts.tracker.preview.oldCount", tonumber(value))
                                            end,
                                        },
                                        newCount = {
                                            order = 4,
                                            type = "input",
                                            name = L["New Count"],
                                            width = 0.5,
                                            validate = function(_, value)
                                                local count = tonumber(value)
                                                return count and count >= 0
                                            end,
                                            get = function()
                                                return tostring(addon:GetDBValue("global", "settings.alerts.tracker.preview.newCount"))
                                            end,
                                            set = function(_, value)
                                                addon:SetDBValue("global", "settings.alerts.tracker.preview.newCount", tonumber(value))
                                            end,
                                        },
                                        objective = {
                                            order = 5,
                                            type = "input",
                                            name = L["Objective"],
                                            width = 0.5,
                                            validate = function(_, value)
                                                local count = tonumber(value)
                                                return count and count >= 1
                                            end,
                                            get = function()
                                                return tostring(addon:GetDBValue("global", "settings.alerts.tracker.preview.objective"))
                                            end,
                                            set = function(_, value)
                                                addon:SetDBValue("global", "settings.alerts.tracker.preview.objective", tonumber(value))
                                            end,
                                        },
                                        objectivePreviewSettings = {
                                            order = 6,
                                            type = "header",
                                            name = L["Preview Settings - Objective"],
                                        },
                                        objectiveOldCount = {
                                            order = 7,
                                            type = "input",
                                            name = L["Old Count"],
                                            width = 0.5,
                                            validate = function(_, value)
                                                local count = tonumber(value)
                                                return count and count >= 0
                                            end,
                                            get = function()
                                                return tostring(addon:GetDBValue("global", "settings.alerts.tracker.preview.objectiveInfo.oldCount"))
                                            end,
                                            set = function(_, value)
                                                addon:SetDBValue("global", "settings.alerts.tracker.preview.objectiveInfo.oldCount", tonumber(value))
                                            end,
                                        },
                                        objectiveNewCount = {
                                            order = 8,
                                            type = "input",
                                            name = L["New Count"],
                                            width = 0.5,
                                            validate = function(_, value)
                                                local count = tonumber(value)
                                                return count and count >= 0
                                            end,
                                            get = function()
                                                return tostring(addon:GetDBValue("global", "settings.alerts.tracker.preview.objectiveInfo.newCount"))
                                            end,
                                            set = function(_, value)
                                                addon:SetDBValue("global", "settings.alerts.tracker.preview.objectiveInfo.newCount", tonumber(value))
                                            end,
                                        },
                                        objectiveObjective = {
                                            order = 9,
                                            type = "input",
                                            name = L["Objective"],
                                            width = 0.5,
                                            validate = function(_, value)
                                                local count = tonumber(value)
                                                return count and count >= 1
                                            end,
                                            get = function()
                                                return tostring(addon:GetDBValue("global", "settings.alerts.tracker.preview.objectiveInfo.objective"))
                                            end,
                                            set = function(_, value)
                                                addon:SetDBValue("global", "settings.alerts.tracker.preview.objectiveInfo.objective", tonumber(value))
                                            end,
                                        },
                                    },
                                },
                                sounds = {
                                    order = 5,
                                    type = "group",
                                    name = L["Sounds"],
                                    inline = true,
                                    get = function(info)
                                        return addon:GetDBValue("global", "settings.alerts.tracker.sound." .. info[#info])
                                    end,
                                    set = function(info, value)
                                        self:SetDBValue("global", "settings.alerts.tracker.sound." .. info[#info], value)
                                    end,
                                    args = {
                                        progress = {
                                            order = 1,
                                            type = "select",
                                            style = "dropdown",
                                            name = L["Progress"],
                                            control = "LSM30_Sound",
                                            values = AceGUIWidgetLSMlists.sound,
                                        },
                                    },
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
            },
        },
        profile = {
            order = 2,
            type = "group",
            name = L["Profile"],
            args = {
                skin = {
                    order = 1,
                    type = "select",
                    style = "dropdown",
                    width = "full",
                    name = L["Skin"],
                    desc = L.Options_settings_profile_skin,
                    values = function(info)
                        local info = {
                            FarmingBar_Default = "FarmingBar_Default",
                            FarmingBar_Minimal = "FarmingBar_Minimal",
                        }

                        for k, _ in pairs(addon:GetDBValue("global", "skins")) do
                            info[k] = k
                        end

                        return info
                    end,
                    sorting = function(info)
                        local info = {"FarmingBar_Default", "FarmingBar_Minimal"}

                        for k, _ in self.pairs(addon:GetDBValue("global", "skins")) do
                            tinsert(info, k)
                        end

                        return info
                    end,
                    get = function(...)
                        return addon:GetDBValue("profile", "style.skin")
                    end,
                    set = function(_, value)
                        self:SetDBValue("profile", "style.skin", value)
                        self:UpdateBars()
                    end,
                },
                count = {
                    order = 2,
                    type = "group",
                    inline = true,
                    name = L["Count Fontstring"],
                    args = {
                        style = {
                            order = 1,
                            type = "select",
                            name = L["Style"],
                            desc = L.Options_settings_profile_count_style,
                            values = {
                                ["CUSTOM"] = L["CUSTOM"],
                                ["INCLUDEAUTOLAYERS"] = L["INCLUDE ACCOUNT AND BANK"],
                                ["INCLUDEALLCHARS"] = L["ACCOUNT COUNTS"],
                                ["INCLUDEBANK"] = L["BANK INCLUSION"],
                                ["ITEMQUALITY"] = L["ITEM QUALITY"],
                            },
                            sorting = {"CUSTOM", "INCLUDEAUTOLAYERS", "INCLUDEALLCHARS", "INCLUDEBANK", "ITEMQUALITY"},
                            get = function(info)
                                return addon:GetDBValue("profile", "style.font.fontStrings.count.style")
                            end,
                            set = function(info, value)
                                self:SetDBValue("profile", "style.font.fontStrings.count.style", value)
                                self:UpdateBars()
                            end,
                        },
                        color = {
                            order = 2,
                            type = "color",
                            hasAlpha = true,
                            name = "  " .. L["Color"], -- I don't like how close the label is to the color picker so I've added extra space to the start of the name
                            desc = L.Options_settings_profile_count_color,
                            get = function(info)
                                return unpack(self:GetDBValue("profile", "style.font.fontStrings.count.color"))
                            end,
                            set = function(info, ...)
                                self:SetDBValue("profile", "style.font.fontStrings.count.color", {...})
                                self:UpdateBars()
                            end,
                        },
                    },
                },
                buttonLayers = {
                    order = 3,
                    type = "group",
                    inline = true,
                    name = L["Button Layers"],
                    get = function(info)
                        return addon:GetDBValue("profile", "style.buttonLayers." .. info[#info])
                    end,
                    set = function(info, value)
                        self:SetDBValue("profile", "style.buttonLayers." .. info[#info], value)
                        self:UpdateBars()
                    end,
                    args = {
                        AccountOverlay = {
                            order = 1,
                            type = "toggle",
                            name = L["Account Counts Overlay"],
                            desc = L.Options_settings_profile_buttonLayers_AccountOverlay,
                        },
                        AutoCastable = {
                            order = 1,
                            type = "toggle",
                            name = L["Bank Overlay"],
                            desc = L.Options_settings_profile_buttonLayers_AutoCastable,
                        },
                        Border = {
                            order = 2,
                            type = "toggle",
                            name = L["Item Quality"],
                            desc = L.Options_settings_profile_buttonLayers_Border,
                        },
                        Cooldown = {
                            order = 3,
                            type = "toggle",
                            name = L["Cooldown"],
                            desc = L.Options_settings_profile_buttonLayers_Cooldown,
                        },
                        CooldownEdge = {
                            order = 4,
                            type = "toggle",
                            name = L["Cooldown Edge"],
                            desc = L.Options_settings_profile_buttonLayers_CooldownEdge,
                        },
                    },
                },
                fonts = {
                    order = 4,
                    type = "group",
                    inline = true,
                    name = L["Fonts"],
                    get = function(info)
                        return addon:GetDBValue("profile", "style.font." .. info[#info])
                    end,
                    set = function(info, value)
                        self:SetDBValue("profile", "style.font." .. info[#info], value)
                        self:UpdateBars()
                    end,
                    args = {
                        face = {
                            order = 1,
                            type = "select",
                            name = L["Face"],
                            desc = L.Options_settings_profile_fonts_face,
                            dialogControl = "LSM30_Font",
                            values = AceGUIWidgetLSMlists.font,
                        },
                        outline = {
                            order = 2,
                            type = "select",
                            name = L["Outline"],
                            desc = L.Options_settings_profile_fonts_size,
                            values = {
                                ["MONOCHROME"] = L["MONOCHROME"],
                                ["OUTLINE"] = L["OUTLINE"],
                                ["THICKOUTLINE"] = L["THICKOUTLINE"],
                                ["NONE"] = L["NONE"],
                            },
                            sorting = {"MONOCHROME", "OUTLINE", "THICKOUTLINE", "NONE"},
                        },
                        size = {
                            order = 3,
                            type = "range",
                            name = L["Size"],
                            desc = L.Options_settings_profile_fonts_outline,
                            min = self.minFontSize,
                            max = self.maxFontSize,
                            step = 1,
                        },
                    },
                },
            },
        },
    }

    for k, v in pairs(self:GetDBValue("global", "settings.debug")) do
        if k ~= "enabled" then
            options.global.args.general.args.debug.args[k] = {
                type = "toggle",
                name = k,
            }
        end
    end

    if not self:GetDBValue("global", "settings.debug.enabled") then
        options.global.args.general.args.debug = nil
    end

    return options
end
