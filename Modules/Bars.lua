local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)
local AceGUI = LibStub("AceGUI-3.0")

function addon:SPELL_UPDATE_COOLDOWN()
    for _, bar in pairs(private.bars) do
        for _, button in pairs(bar:GetButtons()) do
            local barDB, buttonDB = button:GetDB()
            if not button:IsEmpty() and barDB.showCooldown and buttonDB.onUse.type == "ITEM" then
                local startTime, duration, enable = GetItemCooldown(buttonDB.onUse.itemID)
                button.cooldown:SetCooldown(startTime, duration)
                button.cooldown:Show()
            else
                button.cooldown:SetCooldown(0, 0)
                button.cooldown:Hide()
            end
        end
    end
end

local function UpdateBarAlphas()
    for _, bar in pairs(private.bars) do
        bar:SetMouseover()
    end
end

function private:InitializeBars()
    addon:RegisterEvent("CURSOR_CHANGED", UpdateBarAlphas)
    addon:RegisterEvent("SPELL_UPDATE_COOLDOWN")

    private.bars = {}

    for barID, barDB in pairs(private.db.profile.bars) do
        local bar = AceGUI:Create("FarmingBar_Bar")
        bar:SetID(barID)
        private.bars[barID] = bar
    end

    -- Initialize cooldowns
    addon:SPELL_UPDATE_COOLDOWN()
end
