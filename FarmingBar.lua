local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)

--[[ OnInitialize ]]
function addon:OnInitialize()
    private:InitializeDatabase()
    private:InitializeSlashCommands()
    private:InitializeTooltip()
    private:RegisterMedia()
end

--[[ OnEnable ]]
function addon:OnEnable()
    if private.db.global.debug.enabled then
        C_Timer.After(1, private.StartDebug)
    end

    private:InitializeBars()
end

--[[ StartDebug ]]
function private:StartDebug()
    private:LoadOptions()
end
