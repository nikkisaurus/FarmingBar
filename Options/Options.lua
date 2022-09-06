local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)
local ACD = LibStub("AceConfigDialog-3.0")

function private:CloseOptions()
    ACD:Close(addonName)
end

function private:GetOptions()
    private.options = {
        type = "group",
        name = L.addonName,
        args = {
            config = {
                order = 1,
                type = "group",
                name = L["Config"],
                disabled = function()
                    return not addon:IsEnabled()
                end,
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
                args = private:GetSettingsOptions(),
            },
            skins = {
                order = 4,
                type = "group",
                name = L["Skins"],
                args = private:GetSkinsOptions(),
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

    LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName .. "ObjectiveEditor", private:GetObjectiveEditor())
    ACD:SetDefaultSize(addonName .. "ObjectiveEditor", 650, 600)
end

function private:LoadOptions(...)
    private:SelectOptionsPath(...)
    ACD:Open(addonName)
end

function private:NotifyChange()
    LibStub("AceConfigRegistry-3.0"):NotifyChange(addonName)
    LibStub("AceConfigRegistry-3.0"):NotifyChange(addonName .. "ObjectiveEditor")
end

function private:RefreshOptions(...)
    if self.options.args.config then
        self.options.args.config.args = self:GetConfigOptions()
    end
    if self.options.args.skins then
        self.options.args.skins.args = self:GetSkinsOptions()
    end
    if self.options.args.objectiveTemplates then
        self.options.args.objectiveTemplates.args = self:GetObjectiveTemplatesOptions()
    end

    if ... then
        private:SelectOptionsPath(...)
    end

    private:NotifyChange()
end

function private:SelectOptionsPath(...)
    ACD:SelectGroup(addonName, ...)
end

function private:RegisterDataObject()
    local dataObject = LibStub("LibDataBroker-1.1"):NewDataObject(addonName, {
        type = "launcher",
        icon = [[INTERFACE/ADDONS/FARMINGBAR/MEDIA/FARMINGBAR-ICON]],
        label = addonName,
        OnTooltipShow = function(self)
            self:AddLine(addonName)
            self:AddLine(
                addon:IsEnabled() and "Enabled" or "Disabled",
                addon:IsEnabled() and 0 or 1,
                addon:IsEnabled() and 1 or 0,
                0,
                1
            )
            self:AddLine(addon.ColorFontString("Left-click", "TORQUISEBLUE") .. L[" to configure bars."], 1, 1, 1, 1)
            self:AddLine(
                addon.ColorFontString("Right-click", "TORQUISEBLUE") .. L[" to configure settings."],
                1,
                1,
                1,
                1
            )
            self:AddLine(addon.ColorFontString("Control+left-click", "TORQUISEBLUE") .. L[" for help."], 1, 1, 1, 1)
            self:AddLine(
                addon.ColorFontString("Alt+right-click", "TORQUISEBLUE") .. L[" to enable/disable the active profile."],
                1,
                1,
                1,
                1
            )
        end,
        OnClick = function(_, button)
            if IsAltKeyDown() and button == "RightButton" then
                if addon:IsEnabled() then
                    private.db.profile.enabled = false
                    addon:Disable()
                else
                    private.db.profile.enabled = true
                    addon:Enable()
                end
            elseif button == "LeftButton" and IsControlKeyDown() then
                private:LoadOptions("help")
            elseif button == "LeftButton" then
                private:LoadOptions(addon:IsEnabled() and "config" or "settings")
            elseif button == "RightButton" then
                private:LoadOptions("settings")
            end
        end,
    })
    print(dataObject)
end
