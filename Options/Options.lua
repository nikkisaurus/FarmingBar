local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

--*------------------------------------------------------------------------

function addon:Initialize_Options()
    LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName, self:GetOptions())
    LibStub("AceConfigDialog-3.0"):SetDefaultSize(addonName, 800, 500)
end

--*------------------------------------------------------------------------

function addon:GetOptions()
    self.options = {
        type = "group",
        name = L.addon,
        args = {
            config = {
                order = 1,
                type = "group",
                name = L["Config"],
                childGroups = "select",
                args = self:GetConfigOptions(),
            },

            ------------------------------------------------------------

            objectiveBuilder = {
                order = 2,
                type = "group",
                name = L["Objectives"],
                childGroups = "select",
                args = self:GetObjectiveBuilderOptions(),
            },

            ------------------------------------------------------------

            settings = {
                order = 3,
                type = "group",
                name = L["Settings"],
                childGroups = "select",
                args = self:GetSettingsOptions(),
            },

            ------------------------------------------------------------

            styleEditor = {
                order = 4,
                type = "group",
                name = L["Styles"],
                args = self:GetStyleEditorOptions(),
            },

            ------------------------------------------------------------

            profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(FarmingBar.db),

            ------------------------------------------------------------

            help = {
                order = 6,
                type = "group",
                name = L["Help"],
                args = self:GetHelpOptions(),
            },
        },
    }

    self.options.args.profiles.order = 5

    return self.options
end

------------------------------------------------------------

function addon:RefreshOptions()
    LibStub("AceConfigRegistry-3.0"):NotifyChange(addonName)
end