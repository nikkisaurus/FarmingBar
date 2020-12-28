local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

local pairs, tinsert, unpack = pairs, table.insert, unpack
local format = string.format

--*------------------------------------------------------------------------

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
                                return self:GetDBValue("global", "tooltips."..info[#info])
                            end,
                            set = function(info, value)
                                self:SetDBValue("global", "tooltips."..info[#info], value)
                            end,
                            args = {
                                bar = {
                                    order = 1,
                                    type = "toggle",
                                    name = L["Bar"],
                                    desc = L.Options_settings_global_general_tooltips_bar,
                                },

                                ------------------------------------------------------------

                                button = {
                                    order = 1,
                                    type = "toggle",
                                    name = L["Button"],
                                    desc = L.Options_settings_global_general_tooltips_button,
                                },

                                ------------------------------------------------------------

                                hideObjectiveInfo = {
                                    order = 1,
                                    type = "toggle",
                                    name = L["Hide Objective Info"],
                                    desc = L.Options_settings_global_general_tooltips_hideObjectiveInfo,
                                },
                            },
                        },

                        ------------------------------------------------------------

                        hints = {
                            order = 2,
                            type = "group",
                            inline = true,
                            name = L["Hints"],
                            get = function(info)
                                return self:GetDBValue("global", "hints."..info[#info])
                            end,
                            set = function(info, value)
                                self:SetDBValue("global", "hints."..info[#info], value)
                            end,
                            args = {
                                bars = {
                                    order = 1,
                                    type = "toggle",
                                    name = L["Bars"],
                                    desc = L.Options_settings_global_general_hints_bars,
                                },

                                ------------------------------------------------------------

                                buttons = {
                                    order = 2,
                                    type = "toggle",
                                    name = L["Buttons"],
                                    desc = L.Options_settings_global_general_hints_buttons,
                                },

                                ------------------------------------------------------------

                                ObjectiveBuilder = {
                                    order = 3,
                                    type = "toggle",
                                    name = L["Objective Builder"],
                                    desc = L.Options_settings_global_general_hints_ObjectiveBuilder,
                                },

                                ------------------------------------------------------------

                                enableModifier = {
                                    order = 4,
                                    type = "toggle",
                                    name = L["Enable Modifier"],
                                    desc = L.Options_settings_global_general_hints_enableModifier,
                                },

                                ------------------------------------------------------------

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

                        ------------------------------------------------------------

                        templates = {
                            order = 3,
                            type = "group",
                            inline = true,
                            get = function(info)
                                return self:GetDBValue("global", "settings."..info[#info])
                            end,
                            set = function(info, value)
                                self:SetDBValue("global", "settings."..info[#info], value)
                            end,
                            name = L["Templates"],
                            args = {
                                deleteTemplate = {
                                    order = 1,
                                    type = "select",
                                    style = "dropdown",
                                    name = L["Delete Template"],
                                    desc = L.Options_settings_global_templates_deleteTemplate,
                                    confirm = function(_, value) return format(L.Options_settings_global_templates_deleteTemplateConfirm, value) end,
                                    disabled = function()
                                        return self.tcount(FarmingBar.db.global.templates) == 0
                                    end,
                                    values = function(info)
                                        local info = {}

                                        for templateName, _ in pairs(FarmingBar.db.global.templates) do
                                            info[templateName] = templateName
                                        end

                                        return info
                                    end,
                                    set = function(_, value)
                                        self:DeleteTemplate(value)
                                    end,
                                },

                                ------------------------------------------------------------

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

                                ------------------------------------------------------------

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

                        ------------------------------------------------------------

                        misc = {
                            order = 4,
                            type = "group",
                            inline = true,
                            get = function(info)
                                return self:GetDBValue("global", "settings."..info[#info])
                            end,
                            set = function(info, value)
                                self:SetDBValue("global", "settings."..info[#info], value)
                            end,
                            name = L["Miscellaneous"],
                            args = {
                                newQuickObjectives = {
                                    order = 1,
                                    type = "select",
                                    style = "dropdown",
                                    name = L["New Quick Objectives"],
                                    desc = L.Options_settings_global_misc_newQuickObjectives,
                                    values = function(info)
                                        local info = {
                                            NEW = L["CREATE NEW"],
                                            OVERWRITE = L["OVERWRITE"],
                                            USEEXISTING = L["USE EXISTING"],
                                            PROMPT = L["PROMPT"],
                                        }

                                        return info
                                    end,
                                    sorting = {"NEW", "OVERWRITE", "USEEXISTING", "PROMPT"},
                                },

                                ------------------------------------------------------------

                                autoLootOnUse = {
                                    order = 4,
                                    type = "toggle",
                                    width = "full",
                                    disabled = true, -- ! temporary until implemented
                                    name = L["Auto loot items on use"],
                                    desc = L.Options_settings_global_misc_autoLootOnUse,
                                },
                            },
                        },

                        ------------------------------------------------------------

                        commands = {
                            order = 5,
                            type = "group",
                            inline = true,
                            name = L["Slash Commands"],
                            get = function(info)
                                return self:GetDBValue("global", "commands."..info[#info])
                            end,
                            set = function(info, value)
                                self:SetDBValue("global", "commands."..info[#info], value)
                                self:RegisterSlashCommands()
                            end,
                            args = {
                                farmingbar = {
                                    order = 1,
                                    type = "toggle",
                                    name = "/farmingbar",
                                },

                                ------------------------------------------------------------

                                farmbar = {
                                    order = 2,
                                    type = "toggle",
                                    name = "/farmbar",
                                },

                                ------------------------------------------------------------

                                farm = {
                                    order = 3,
                                    type = "toggle",
                                    name = "/farm",
                                },

                                ------------------------------------------------------------

                                fbar = {
                                    order = 4,
                                    type = "toggle",
                                    name = "/fbar",
                                },

                                ------------------------------------------------------------

                                fb = {
                                    order = 5,
                                    type = "toggle",
                                    name = "/fb",
                                },
                            },
                        },

                        ------------------------------------------------------------

                        debug = {
                            order = 99,
                            type = "group",
                            inline = true,
                            name = L["Debug"],
                            get = function(info)
                                return self:GetDBValue("global", "debug."..info[#info])
                            end,
                            set = function(info, value)
                                self:SetDBValue("global", "debug."..info[#info], value)
                            end,
                            args = {},
                        },
                    },
                },

                ------------------------------------------------------------

                alerts = {
                    order = 2,
                    type = "group",
                    name = L["Alerts"],
                    args = {},
                },

                ------------------------------------------------------------

                keybinds = {
                    order = 3,
                    type = "group",
                    name = L["Keybinds"],
                    args = {},
                },
            },
        },

        ------------------------------------------------------------

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

                        for k, _ in pairs(FarmingBar.db.global.skins) do
                            info[k] = k
                        end

                        return info
                    end,
                    sorting = function(info)
                        local info = {"FarmingBar_Default", "FarmingBar_Minimal"}

                        for k, _ in self.pairs(FarmingBar.db.global.skins) do
                            tinsert(info, k)
                        end

                        return info
                    end,
                    get = function(...)
                        return self:GetDBValue("profile", "style.skin")
                    end,
                    set = function(_, value)
                        self:SetDBValue("profile", "style.skin", value)
                        self:UpdateBars()
                    end,
                },

                ------------------------------------------------------------

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
                                ["INCLUDEBANK"] = L["BANK INCLUSION"],
                                ["ITEMQUALITY"] = L["ITEM QUALITY"],
                            },
                            sorting = {"CUSTOM", "INCLUDEBANK", "ITEMQUALITY"},
                            get = function(info)
                                return self:GetDBValue("profile", "style.font.fontStrings.count.style")
                            end,
                            set = function(info, value)
                                self:SetDBValue("profile", "style.font.fontStrings.count.style", value)
                                self:UpdateBars()
                            end,
                        },

                        ------------------------------------------------------------

                        color = {
                            order = 2,
                            type = "color",
                            hasAlpha = true,
                            name = "  "..L["Color"], -- I don't like how close the label is to the color picker so I've added extra space to the start of the name
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

                ------------------------------------------------------------

                buttonLayers = {
                    order = 3,
                    type = "group",
                    inline = true,
                    name = L["Button Layers"],
                    get = function(info)
                        return self:GetDBValue("profile", "style.buttonLayers."..info[#info])
                    end,
                    set = function(info, value)
                        self:SetDBValue("profile", "style.buttonLayers."..info[#info], value)
                        self:UpdateBars()
                    end,
                    args = {
                        AutoCastable = {
                            order = 1,
                            type = "toggle",
                            name = L["Bank Overlay"],
                            desc = L.Options_settings_profile_buttonLayers_AutoCastable,
                        },

                        ------------------------------------------------------------

                        Border = {
                            order = 2,
                            type = "toggle",
                            name = L["Item Quality"],
                            desc = L.Options_settings_profile_buttonLayers_Border,
                        },

                        ------------------------------------------------------------

                        Cooldown = {
                            order = 3,
                            type = "toggle",
                            name = L["Cooldown"],
                            desc = L.Options_settings_profile_buttonLayers_Cooldown,
                        },

                        ------------------------------------------------------------

                        CooldownEdge = {
                            order = 4,
                            type = "toggle",
                            name = L["Cooldown Edge"],
                            desc = L.Options_settings_profile_buttonLayers_CooldownEdge,
                        },
                    },
                },

                ------------------------------------------------------------

                fonts = {
                    order = 4,
                    type = "group",
                    inline = true,
                    name = L["Fonts"],
                    get = function(info)
                        return self:GetDBValue("profile", "style.font."..info[#info])
                    end,
                    set = function(info, value)
                        self:SetDBValue("profile", "style.font."..info[#info], value)
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

                        ------------------------------------------------------------

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

                        ------------------------------------------------------------

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

    ------------------------------------------------------------

    for k, v in pairs(FarmingBar.db.global.debug) do
        options.global.args.general.args.debug.args[k] = {
            type = "toggle",
            name = k,
        }
    end

    if not FarmingBar.db.global.debugMode then
         options.global.args.general.args.debug = nil
    end

    ------------------------------------------------------------

    return options
end