local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)
local ACD = LibStub("AceConfigDialog-3.0")

function private:GetOptions()
    private.options = {
        type = "group",
        name = L.addonName,
        args = {
            config = {
                order = 1,
                type = "group",
                name = L["Config"],
                args = private:GetConfigOptions(),
            },
            objectiveTemplates = {
                order = 2,
                type = "group",
                name = L["Objective Templates"],
                args = private:GetObjectiveTemplatesOptions(),
            },
            settings = {
                order = 3,
                type = "group",
                name = L["Settings"],
                childGroups = "tab",
                -- args = private:GetSettingsOptions(),
                args = {},
            },
            skins = {
                order = 4,
                type = "group",
                name = L["Skins"],
                -- args = private:GetSettingsOptions(),
                args = {},
            },
            profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(private.db),
            help = {
                order = 6,
                type = "group",
                name = L["Help"],
                childGroups = "tab",
                -- args = private:GetHelpOptions(),
                args = {},
            },
        },
    }

    private.options.args.profiles.order = 5

    return private.options
end

function private:InitializeOptions()
    LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName, private:GetOptions())
    ACD:SetDefaultSize(addonName, 850, 600)
end

function private:SelectOptionsPath(...)
    ACD:SelectGroup(addonName, ...)
end

function private:CloseOptions()
    ACD:Close(addonName)
end

function private:LoadOptions(...)
    private:SelectOptionsPath(...)
    ACD:Open(addonName)
end

function private:RefreshOptions(...)
    if self.options.args.config then
        self.options.args.config.args = self:GetConfigOptions()
    end
    if self.options.args.objectiveTemplates then
        self.options.args.objectiveTemplates.args = self:GetObjectiveTemplatesOptions()
    end

    if ... then
        private:SelectOptionsPath(...)
    end

    private:NotifyChange()
end

function private:NotifyChange()
    LibStub("AceConfigRegistry-3.0"):NotifyChange(addonName)
end
