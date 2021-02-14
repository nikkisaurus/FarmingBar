local addonName = ...
local addon = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

------------------------------------------------------------

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

    for _, button in pairs(buttons) do
        button:ClearObjective()
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
    -- local bar = self.bars[barID]
    -- local buttons = bar:GetUserData("buttons")
    -- local objectives = {}

    -- ------------------------------------------------------------

    -- -- Sort objectives
    -- for buttonID, button in pairs(buttons) do
    --     local objectiveTitle = button:GetObjectiveTitle()
    --     if objectiveTitle then
    --         tinsert(objectives, self.db.char.bars[barID].objectives[buttonID])
    --         button:ClearObjective()
    --     end
    -- end

    -- sort(objectives, function(a, b)
    --     return a.objectiveTitle == b.objectiveTitle and ((b.objective or 0) < (a.objective or 0)) or (a.objectiveTitle < b.objectiveTitle)
    -- end)

    -- ------------------------------------------------------------

    -- -- Add objectives back to bar
    -- for i = 1, #objectives do
    --     buttons[i]:SetObjectiveID(objectives[i].objectiveTitle, objectives[i].objective)
    -- end

    -- ------------------------------------------------------------

    -- -- Return #objectives for SizeBarToButtons
    -- return #objectives
end

------------------------------------------------------------

function addon:RemoveAllBars()
    -- for key, button in addon.pairs(self.Config:GetUserData("barList").children, function(a, b) return b < a end) do
    --     self:SetBarDisabled(button:GetBarID())
    --     if key == 2 then return end
    -- end
end

------------------------------------------------------------

function addon:RemoveBar(barID)
    -- Clear bar
    self:ClearBar(barID)

    -- Release widget
    self.bars[barID]:Release()

    -- Remove bar
    tremove(self.db.profile.bars, barID)
    tremove(self.db.char.bars, barID)
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

function addon:RemoveSelectedBars(confirmed)
    -- local barButtons = self.Config:GetUserData("barList").children

    -- ------------------------------------------------------------

    -- if confirmed then
    --     for _, button in addon.pairs(barButtons, function(a, b) return b < a end) do
    --         if button:GetUserData("selected") then
    --             self:SetBarDisabled(button:GetBarID())
    --         end
    --     end
    --     return
    -- end

    -- ------------------------------------------------------------

    -- local selectedButton
    -- local numSelectedButtons = 0
    -- for _, button in pairs(barButtons) do
    --     if button:GetUserData("selected") then
    --         numSelectedButtons = numSelectedButtons + 1
    --         selectedButton = button
    --     end
    -- end

    -- ------------------------------------------------------------

    -- if numSelectedButtons > 1 then
    --     local dialog = StaticPopup_Show("FARMINGBAR_CONFIRM_REMOVE_MULTIPLE_BARS", numSelectedButtons)
    -- else
    --     local dialog = StaticPopup_Show("FARMINGBAR_CONFIRM_REMOVE_BAR", selectedButton:GetBarTitle())
    --     if dialog then
    --         dialog.data = selectedButton:GetBarID()
    --     end
    -- end
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
    -- local numObjectives = self:ReindexButtons(barID)
    -- self:SetBarDBValue("numVisibleButtons", numObjectives, barID)
    -- self.bars[barID]:UpdateVisibleButtons()
end

------------------------------------------------------------

function addon:UpdateBars()
    -- for _, bar in pairs(self.bars) do
    --     bar:ApplySkin()
    --     bar:SetSize()
    --     for _, button in pairs(bar:GetUserData("buttons")) do
    --         button:UpdateLayers()
    --     end
    -- end
end