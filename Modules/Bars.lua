local addonName = ...
local addon = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

------------------------------------------------------------

local sort, tinsert, pairs, wipe = table.sort, table.insert, pairs, table.wipe

--*------------------------------------------------------------------------

function addon:InitializeBars()
    local profile = self:GetDBValue("profile")
    local bars = profile.bars

    ------------------------------------------------------------
    --Debug-----------------------------------------------------
    ------------------------------------------------------------
    if self:GetDBValue("global", "settings.debug.barDB") then
        wipe(bars)
    end
    ------------------------------------------------------------
    ------------------------------------------------------------

    if self.tcount(bars, nil, "enabled") == 0 and profile.enabled then
        self:CreateBar()
    else
        for barID, barDB in pairs(bars) do
            if barDB.enabled then
                self:LoadBar(barID)
            end
        end
    end
end

------------------------------------------------------------

function addon:GetBarDBValue(key, barID, isCharDB)
    local path = self:GetDBValue(isCharDB and "char" or "profile", "bars")[barID]
    if not key then return path end
    local keys = {strsplit(".", key)}

    for k, key in pairs(keys) do
        if k < #keys then
            path = path[key]
        end
    end

    return path[keys[#keys]]
end

------------------------------------------------------------

function addon:SetBarDBValue(key, value, barID, isCharDB)
    local keys = {strsplit(".", key)}
    local path = self:GetDBValue(isCharDB and "char" or "profile", "bars")[barID]

    for k, key in pairs(keys) do
        if k < #keys then
            path = path[key]
        end
    end

    if value == "_TOGGLE_" then
        if path[keys[#keys]] then
            value = false
        else
            value = true
        end
    end

    path[keys[#keys]] = value
end

--*------------------------------------------------------------------------

function addon:CreateBar()
    local bars = self:GetDBValue("profile", "bars")
    local numBars = #bars

    bars[numBars + 1].enabled = true
    self:LoadBar(numBars + 1)
    self:SetDBValue("profile", "enabled", true)
    self:RefreshConfigOptions()
end

------------------------------------------------------------

function addon:ClearBar(barID)
    local bar = self.bars[barID]
    local buttons = bar:GetUserData("buttons")

    for buttonID, _ in pairs(self:GetBarDBValue(nil, barID, true).objectives) do
        if buttons[buttonID] then
            buttons[buttonID]:ClearObjective()
        else
            self.db.char.bars[barID].objectives[buttonID] = nil
        end
    end
end

------------------------------------------------------------

function addon:GetBarTitle(barID)
    if barID == 0 then return L["All Bars"] end

    local barDB = self:GetDBValue("char", "bars")[barID]
    if not barDB then return end

    local title = L["Bar"].." "..barID..(barDB.title ~= "" and (" ("..barDB.title..")") or "")
    return title
end

------------------------------------------------------------

function addon:LoadBar(barID)
    if barID == 0 then return end
    local bar = AceGUI:Create("FarmingBar_Bar")
    bar:SetBarDB(barID)
    self.bars[barID] = bar
end

------------------------------------------------------------

function addon:ReindexButtons(barID)
    local bar = self.bars[barID]
    local buttons = bar:GetButtons()
    local objectives = {}

    ------------------------------------------------------------

    -- Sort objectives
    local counter = 1
    for buttonID, button in pairs(buttons) do
        if not button:IsEmpty() then
            objectives[counter] = self:CloneTable(button:GetButtonDB())
            counter = counter + 1
            button:ClearObjective()
        end
    end

    sort(objectives, function(a, b)
        return a.title == b.title and ((b.objective or 0) < (a.objective or 0)) or (a.title < b.title)
    end)

    ------------------------------------------------------------

    -- Add objectives back to bar
    for buttonID, buttonDB in pairs(objectives) do
        addon:CreateObjectiveFromUserTemplate(buttons[buttonID], buttonDB, true)
    end

    ------------------------------------------------------------

    -- Return #objectives for SizeBarToButtons
    return self.tcount(objectives)
end

------------------------------------------------------------

function addon:RemoveAllBars()
    for barID, bar in pairs(self.bars) do
        self:RemoveBar(barID)
    end
end

------------------------------------------------------------

function addon:RemoveBar(barID)
    -- Release widget
    self.bars[barID]:Release()

    -- Remove bar
    tremove(self.db.profile.bars, barID)
    -- tremove(self.db.char.bars, barID)
    tremove(self.bars, barID)

    -- Update bars for existing widgets
    -- There was a link left when just updating the barIDs on the widgets and when two bars were deleted in the middle of the bars, it would clear buttons after the second delete. Instead I'm releasing and loading new bars. They will be updated in self.bars during the LoadBar method.
    for k, bar in pairs(self.bars) do
        if k >= barID then
            bar:Release()
            self:LoadBar(k)
        end
    end

    -- If all bars were manually deleted, be sure to disable profile
    self:SetDBValue("profile", "enabled", self.tcount(self:GetDBValue("profile", "bars")) > 0)

    self:RefreshConfigOptions()
end

------------------------------------------------------------

function addon:SetBarDisabled(barID, enabled)
    local bars = self:GetDBValue("profile", "bars")
    if enabled == "_TOGGLE_" then
        if bars[barID].enabled then
            enabled = false
        else
            enabled = true
        end
    end
    bars[barID].enabled = enabled
    if not enabled then
        self.bars[barID]:Release()
    else
        self:LoadBar(barID)
    end
    self:RefreshConfigOptions()
end

------------------------------------------------------------

function addon:SizeBarToButtons(barID)
    local numObjectives = self:ReindexButtons(barID)
    self:SetBarDBValue("numVisibleButtons", numObjectives, barID)
    self.bars[barID]:UpdateVisibleButtons()
end

------------------------------------------------------------

function addon:UpdateBars()
    for _, bar in pairs(self.bars) do
        bar:ApplySkin()
        bar:SetSize()
        for _, button in pairs(bar:GetUserData("buttons")) do
            button:UpdateLayers()
        end
    end
end