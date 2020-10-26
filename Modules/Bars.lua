local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

local tinsert, pairs, wipe = table.insert, pairs, table.wipe

--*------------------------------------------------------------------------

function addon:Initialize_Bars()
    local bars = FarmingBar.db.char.bars

    ------------------------------------------------------------
    --Debug-----------------------------------------------------
    ------------------------------------------------------------
    if FarmingBar.db.global.debug.barDB then
        wipe(bars)
    end
    ------------------------------------------------------------
    ------------------------------------------------------------

    if #bars == 0 and FarmingBar.db.char.enabled then
        self:CreateBar()
        self:LoadBar(1)
    else
        for barID, _ in pairs(bars) do
            self:LoadBar(barID)
        end
    end
end

--*------------------------------------------------------------------------

function addon:CreateBar()
    tinsert(FarmingBar.db.char.bars, addon:GetDefaultBar())
end

------------------------------------------------------------

function addon:LoadBar(barID)
    local bar = AceGUI:Create("FarmingBar_Bar")
    bar:SetBarDB(barID)
    local barDB = bar:GetUserData("barDB")
    self.bars[barID] = bar
end