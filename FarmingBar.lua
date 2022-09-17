local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)

function addon:OnDisable()
    private:ReleaseAllBars()
    private:RefreshOptions("settings")
    addon:UnregisterEvent("CURSOR_CHANGED")
    addon:UnregisterEvent("SPELL_UPDATE_COOLDOWN")
    addon:UnregisterEvent("BANKFRAME_OPENED")
    addon:UnregisterEvent("BANKFRAME_CLOSED")
end

function addon:OnEnable()
    private:InitializeBars()
    addon:RegisterEvent("CURSOR_CHANGED")
    addon:RegisterEvent("SPELL_UPDATE_COOLDOWN")
    addon:RegisterEvent("BANKFRAME_OPENED")
    addon:RegisterEvent("BANKFRAME_CLOSED")

    if private.db.global.debug.enabled then
        C_Timer.After(1, private.StartDebug)
    end
end

function addon:OnInitialize()
    private:InitializeDatabase()
    private:InitializeOptions()
    private:RegisterMedia()
    private:RegisterDataObject()
    private:InitializeTooltip()
    private:InitializeObjectiveFrame()
    private:InitializeMasque()
    private:InitializeSlashCommands()
    private.bars = {}
end

function addon:OnProfile_(...)
    addon:SetEnabledState(private.db.profile.enabled)
    private:InitializeBars()
    private:RefreshOptions("profiles")
end
