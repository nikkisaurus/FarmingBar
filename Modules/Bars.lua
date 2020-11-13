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
    else
        for barID, _ in pairs(bars) do
            self:LoadBar(barID)
        end
    end
end

--*------------------------------------------------------------------------

function addon:CreateBar()
    tinsert(FarmingBar.db.char.bars, addon:GetDefaultBar())
    self:LoadBar(#FarmingBar.db.char.bars)
end

------------------------------------------------------------

function addon:GetBarTitle(barID)
    if barID == 0 then return L["All Bars"] end

    local barDB = FarmingBar.db.char.bars[barID]
    if not barDB then return end

    local title = L["Bar"].." "..barID..(barDB.title ~= "" and (" ("..barDB.title..")") or "")
    return title
end

------------------------------------------------------------

function addon:LoadBar(barID)
    FarmingBar.db.char.enabled = true

    ------------------------------------------------------------

    local bar = AceGUI:Create("FarmingBar_Bar")
    bar:SetBarDB(barID)

    local barDB = bar:GetUserData("barDB")
    self.bars[barID] = bar

    ------------------------------------------------------------

    local Config = addon.Config
    if Config then
        Config:RefreshBars()
    end
end

------------------------------------------------------------

function addon:RemoveAllBars()
    for key, button in addon.pairs(self.Config:GetUserData("barList").children, function(a, b) return b < a end) do
        self:RemoveBar(button:GetBarID())
        if key == 2 then return end
    end
end

------------------------------------------------------------

function addon:RemoveBar(barID)
    local bars = FarmingBar.db.char.bars

    -- Release all bars from the removed one and on
    for i = barID, #bars do
        self.bars[i]:Release()
        self.bars[i] = nil
    end

    -- Remove from the database
    tremove(FarmingBar.db.char.bars, barID)

    -- Reload the remaining bars that were reindexed
    for i = barID, #bars do
        self:LoadBar(i)
    end

    if addon.tcount(FarmingBar.db.char.bars) == 0 then
        FarmingBar.db.char.enabled = false
    end

    ------------------------------------------------------------

    addon.Config:RefreshBars()
end

------------------------------------------------------------

function addon:RemoveSelectedBars(confirmed)
    local barButtons = self.Config:GetUserData("barList").children

    ------------------------------------------------------------

    if confirmed then
        for _, button in addon.pairs(barButtons, function(a, b) return b < a end) do
            if button:GetUserData("selected") then
                self:RemoveBar(button:GetBarID())
            end
        end
        return
    end

    ------------------------------------------------------------

    local selectedButton
    local numSelectedButtons = 0
    for _, button in pairs(barButtons) do
        if button:GetUserData("selected") then
            numSelectedButtons = numSelectedButtons + 1
            selectedButton = button
        end
    end

    ------------------------------------------------------------

    if numSelectedButtons > 1 then
        local dialog = StaticPopup_Show("FARMINGBAR_CONFIRM_REMOVE_MULTIPLE_BARS", numSelectedButtons)
    else
        local dialog = StaticPopup_Show("FARMINGBAR_CONFIRM_REMOVE_BAR", selectedButton:GetBarTitle())
        if dialog then
            dialog.data = selectedButton:GetBarID()
        end
    end
end

------------------------------------------------------------

function addon:SetBarDBInfo(key, value, barID)
    local keys = {strsplit(".", key)}
    local path = FarmingBar.db.char.bars[barID]

    for k, key in pairs(keys) do
        if k < #keys then
            path = path[key]
        end
    end

    path[keys[#keys]] = value

    ------------------------------------------------------------

    self.Config:RefreshBars()
    self.bars[barID]:DoLayout()
end