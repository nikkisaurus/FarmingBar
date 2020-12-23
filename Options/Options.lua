local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)
local ACD = LibStub("AceConfigDialog-3.0")

--*------------------------------------------------------------------------

function addon:InitializeOptions()
    LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName, self:GetOptions())
end

--*------------------------------------------------------------------------

function addon:GetOptions()
    local options = {
        type = "group",
        name = "Farming Bar",
        args = {
            modules = {
                order = 1,
                type = "group",
                name = L["Modules"],
                args = self:GetModulesOptions(),
            },

            ------------------------------------------------------------

            settings = {
                order = 2,
                type = "group",
                name = L["Settings"],
                childGroups = "tab",
                args = self:GetSettingsOptions(),
            },

            ------------------------------------------------------------

            profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(FarmingBar.db),

            ------------------------------------------------------------

            help = {
                order = 4,
                type = "group",
                name = L["Help"],
                args = self:GetHelpOptions(),
            },
        },
    }

    options.args.profiles.order = 3

    return options
end

--*------------------------------------------------------------------------

function addon:GetHelpOptions()
    -- About/Bars (& Buttons), Commands, Alert Formats, Objectives, Templates
    local options = {
        commands = {
            order = 1,
            type = "group",
            name = L["Commands"],
            args = {},
        },

        ------------------------------------------------------------

        objectives = {
            order = 2,
            type = "group",
            name = L["Objectives"],
            args = {},
        },

        ------------------------------------------------------------

        alerts = {
            order = 3,
            type = "group",
            name = L["Alerts"],
            args = {},
        },

        ------------------------------------------------------------

        templates = {
            order = 4,
            type = "group",
            name = L["Templates"],
            args = {},
        },
    }

    return options
end

------------------------------------------------------------

function addon:GetModulesOptions()
    local options = {
        config = {
            order = 1,
            width = "full",
            type = "execute",
            name = L["Config"],
            func = function()
                self.Config:Load()
                ACD:Close(addonName)
            end,
        },
        objectiveBuilder = {
            order = 1,
            width = "full",
            type = "execute",
            name = L["Objective Builder"],
            func = function()
                self.ObjectiveBuilder:Load()
                ACD:Close(addonName)
            end,
        },
        styleEditor = {
            order = 1,
            width = "full",
            type = "execute",
            name = L["Style Editor"],
            func = function()
                print("Load style editor")
                ACD:Close(addonName)
            end,
            disabled = true, -- ! temporary until implemented
        },
    }

    return options
end


------------------------------------------------------------

function addon:GetSettingsOptions()
    local options = {
        global = {
            order = 1,
            type = "group",
            name = L["Global"],
            args = {

            },
        },

        ------------------------------------------------------------

        profile = {
            order = 2,
            type = "group",
            name = L["Profile"],
            args = {
                bars = {
                    order = 1,
                    type = "group",
                    inline = true,
                    name = L["Bars"],
                    args = {
                        -- numBars = {
                        --     order = 1,
                        --     type = "description",
                        --     width = "full",
                        --     name = "Number of bars: ",
                        -- },
                    },
                },

                ------------------------------------------------------------

                style = {
                    order = 1,
                    type = "group",
                    inline = true,
                    name = L["Style"],
                    args = {
                        skin = {
                            order = 1,
                            type = "select",
                            style = "dropdown",
                            width = "full",
                            name = L["Skin"],
                            desc = L.Options_settings_profile_style_skin,
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
                                self:UpdateBarSkins()
                            end,
                        },
                    },
                },

            },
        },
    }

    return options
end
