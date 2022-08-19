local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)
local AceGUI = LibStub("AceGUI-3.0")
local LSM = LibStub("LibSharedMedia-3.0")

function addon:SPELL_UPDATE_COOLDOWN()
    for _, bar in pairs(private.bars) do
        for _, button in pairs(bar:GetButtons()) do
            local barDB, buttonDB = button:GetDB()
            if not button:IsEmpty() and barDB.showCooldown and buttonDB.onUse.type == "ITEM" then
                local startTime, duration, enable = GetItemCooldown(buttonDB.onUse.itemID)
                button.cooldown:SetDrawEdge(barDB.fontstrings.Cooldown.showEdge)
                button.cooldown:SetCooldown(startTime, duration)
                button.cooldown:Show()
            else
                button.cooldown:SetCooldown(0, 0)
                button.cooldown:Hide()
            end
        end
    end
end

function addon:CURSOR_CHANGED()
    for _, bar in pairs(private.bars) do
        bar:SetMouseover()
    end
end

function private:InitializeBars()
    private.bars = {}

    for barID, barDB in pairs(private.db.profile.bars) do
        local bar = AceGUI:Create("FarmingBar_Bar")
        bar:SetID(barID)
        private.bars[barID] = bar
    end

    addon:SPELL_UPDATE_COOLDOWN()
end

function private:AddBar()
    local barDB = addon.CloneTable(private.defaults.bar)
    local styleDB = private.db.profile.style

    barDB.buttonSize = styleDB.buttons.size
    barDB.buttonPadding = styleDB.buttons.padding

    barDB.font.face = styleDB.font.face
    barDB.font.outline = styleDB.font.outline
    barDB.font.size = styleDB.font.size

    local pos = tinsert(private.db.profile.bars, barDB)
    local barID = #private.db.profile.bars

    local bar = AceGUI:Create("FarmingBar_Bar")
    bar:SetID(barID)
    private.bars[barID] = bar

    addon:SPELL_UPDATE_COOLDOWN()
    private:UpdateMenu(private.options:GetUserData("menu"))

    return barID
end

function private:RemoveBar(barID)
    for _, bar in pairs(private.bars) do
        bar:Release()
    end
    tremove(private.db.profile.bars, barID)
    private:InitializeBars()
    private:UpdateMenu(private.options:GetUserData("menu"))
end
