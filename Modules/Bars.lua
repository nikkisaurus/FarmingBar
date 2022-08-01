local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)
local AceGUI = LibStub("AceGUI-3.0")

function private:InitializeBars()
    private.bars = {}

    for barID, barDB in pairs(private.db.profile.bars) do
        local bar = AceGUI:Create("FarmingBar_Bar")
        bar:SetID(barID)
        private.bars[barID] = bar
    end
end
