local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)

--[[ OnInitialize ]]
function addon:OnInitialize()
    private:InitializeDatabase()
    private:InitializeSlashCommands()
    private:InitializeOptions()
    private:RegisterMedia()
end

--[[ OnEnable ]]
function addon:OnEnable()
    private:InitializeTooltip()
    private:InitializeObjectiveFrame()
    private:InitializeMasque()
    private:InitializeBars()
    addon:RegisterEvent("CURSOR_CHANGED")
    addon:RegisterEvent("SPELL_UPDATE_COOLDOWN")

    if private.db.global.debug.enabled then
        C_Timer.After(5, private.StartDebug)
    end
end

--[[ StartDebug ]]
function private:StartDebug()
    private:LoadOptions()
end
