local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

local tinsert, pairs = table.insert, pairs

--*------------------------------------------------------------------------

function addon:Initialize_Bars()
    local bars = FarmingBar.db.char.bars

    if #bars == 0 and FarmingBar.db.char.enabled then
        self:CreateBar()
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
    if not self.bars[barID] then
        local bar = AceGUI:Create("FarmingBarBar")
        bar:SetBarID(barID)
    end
end