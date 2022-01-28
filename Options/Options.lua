local addonName = ...
local addon = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

-- *------------------------------------------------------------------------
-- Initialize options

function addon:InitializeOptions()
    local ACD = LibStub("AceConfigDialog-3.0")
    LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName, self:GetOptions())
    ACD:SetDefaultSize(addonName, 850, 600)

    --C_Timer.After(
    --    1,
    --    function()
    --        ACD:SelectGroup(addonName, "objectiveBuilder", "New")
    --        ACD:Open(addonName)
    --    end
    --)
end

function addon:GetOptions()
    self.options = {
        type = "group",
        name = L.addon,
        args = {
            config = {
                order = 1,
                type = "group",
                name = L["Config"],
                args = self:GetConfigOptions()
            },
            objectiveBuilder = {
                order = 2,
                type = "group",
                name = L["Objectives"],
                args = self:GetObjectiveBuilderOptions()
            },
            styleEditor = {
                order = 3,
                type = "group",
                name = L["Styles"],
                args = self:GetStyleEditorOptions()
            },
            globalSettings = {
                order = 4,
                type = "group",
                name = L["Global Settings"],
                childGroups = "tab",
                args = self:GetGlobalSettingsOptions()
            },
            profileSettings = {
                order = 4,
                type = "group",
                name = L["Profile Settings"],
                args = self:GetProfileSettingsOptions()
            },
            profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db),
            help = {
                order = 7,
                type = "group",
                name = L["Help"],
                args = self:GetHelpOptions()
            }
        }
    }

    self.options.args.profiles.order = 6

    return self.options
end

function addon:RefreshOptions()
    if not self.options then
        return
    end

    -- Update config options
    if self.options.args.config then
        self.options.args.config.args = self:GetConfigOptions()
    end

    -- Update objective builder options
    if self.options.args.objectiveBuilder then
        self.options.args.objectiveBuilder.args = self:GetObjectiveBuilderOptions()
    end

    LibStub("AceConfigRegistry-3.0"):NotifyChange(addonName)
    LibStub("AceConfigRegistry-3.0"):NotifyChange(addonName .. "ObjectiveEditor")
end
