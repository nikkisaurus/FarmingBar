local addonName = ...
local addon = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

-- Optional libraries
local AceGUI = LibStub("AceGUI-3.0", true)

-- *------------------------------------------------------------------------
-- Bar initialization

addon.cursorFrame = CreateFrame("Frame", nil, UIParent)
addon.cursorFrame:Hide()

function addon:InitializeBars()
    local profile = self:GetDBValue("profile")
    local bars = profile.bars

    ------------------------------------------------------------
    -- Debug-----------------------------------------------------
    ------------------------------------------------------------
    if self:GetDBValue("global", "settings.debug.barDB") then
        wipe(bars)
    end
    ------------------------------------------------------------
    ------------------------------------------------------------

    if self.tcount(bars, nil, "enabled") == 0 and profile.enabled then
        -- New profile; create first bar
        self:CreateBar()
    else
        -- Load enabled bars
        for barID, barDB in pairs(bars) do
            if barDB.enabled then
                self:LoadBar(barID)
            end
        end
    end

    self:RegisterEvent("CURSOR_UPDATE")
end

function addon:CreateBar()
    local bars = self:GetDBValue("profile", "bars")
    local numBars = #bars

    -- Keeps track of whether the profile is disabled because all bars were deleted
    self:SetDBValue("profile", "enabled", true)

    -- Create and load the bar
    bars[numBars + 1].enabled = true
    self:LoadBar(numBars + 1)

    self:RefreshOptions()
end

function addon:LoadBar(barID)
    if barID == 0 then
        return
    end -- barID == 0 is used in config to config all bars

    local bar = AceGUI:Create("FarmingBar_Bar")
    bar:SetBarDB(barID)

    -- Add to bar container
    self.bars[barID] = bar
end

function addon:CURSOR_UPDATE()
    local cursorType, cursorID = GetCursorInfo()

    for _, bar in pairs(self.bars) do        
        bar:SetAlpha(cursorType == "item" and "hasObjective")
    end
end

-- *------------------------------------------------------------------------
-- Remove bars

function addon:ReleaseAllBars()
    for _, bar in pairs(self.bars) do
        bar:Release()
    end

    wipe(self.bars)
end

function addon:RemoveBar(barID)
    -- Release widget
    if self.bars[barID] then
        self.bars[barID]:Release()
    end

    -- Remove bar
    tremove(self.db.profile.bars, barID)
    tremove(self.bars, barID)

    -- Update bars for existing widgets
    -- There was a link left when just updating the barIDs on the widgets and when two bars were deleted in the middle of the bars, it would clear buttons after the second delete. Instead I'm releasing and loading new bars. They will be updated in self.bars during the LoadBar method.
    for k, bar in pairs(self.bars) do
        if k >= barID and bar.enabled then
            bar:Release()
            self:LoadBar(k)
        end
    end

    -- If all bars were manually deleted, be sure to disable profile
    self:SetDBValue("profile", "enabled", self.tcount(self:GetDBValue("profile", "bars")) > 0)

    self:RefreshOptions()
end

-- *------------------------------------------------------------------------
-- Bar info

function addon:GetBarTitle(barID)
    if barID == 0 then
        return L["All Bars"]
    end

    local barDB = self:GetDBValue("char", "bars")[barID]
    if not barDB then
        return
    end

    return format("%s %d%s", L["Bar"], barID, barDB.title ~= "" and format(" (%s)", barDB.title) or "")
end

-- *------------------------------------------------------------------------
-- Methods

function addon:ClearBar(barID)
    local bar = self.bars[barID]
    local objectives = self:GetBarDBValue("objectives", barID, true)
    local buttons = bar:GetUserData("buttons")

    for buttonID, _ in pairs(objectives) do
        if buttons[buttonID] then
            buttons[buttonID]:ClearObjective()
        else -- Button is hidden with an objective on it
            objectives[buttonID] = nil
        end
    end
end

function addon:CustomHide(bar)
    local barDB = bar:GetBarDB()
    if not barDB then return end
    local customHide = barDB.customHide

    local frame = bar.frame
    frame:UnregisterAllEvents()

    -- Register events
    for _, event in pairs(customHide.events) do
        frame:RegisterEvent(event)
    end    

    frame:RegisterEvent("PLAYER_REGEN_ENABLED")
    frame:RegisterEvent("PLAYER_REGEN_DISABLED")
    
    -- Transform the string into a function
    local userFunc, err = loadstring("return " .. customHide.func)
    if not userFunc then
        return L.InvalidSyntax(err), true
    end

    -- Verify that userFunc is actually a valid function
    local success, userParseFunc = pcall(userFunc)
    if success and userParseFunc then
        return userParseFunc()
    end
end

function addon:ReindexButtons(barID)
    local bar = self.bars[barID]
    local buttons = bar:GetButtons()
    local charButtons = self:GetBarDBValue("objectives", barID, true)
    local objectives = {}

    -- Enable all buttons to make sure we don't miss hidden objectives
    local numVisibleButtons = bar:GetBarDB().numVisibleButtons
    self:SetBarDBValue("numVisibleButtons", self.maxButtons, barID)
    bar:UpdateVisibleButtons()

    -- Sort objectives
    for buttonID = 1, self.maxButtons do
        local button = buttons[buttonID]
        if button and not button:IsEmpty() then
            tinsert(objectives, self:CloneTable(button:GetButtonDB()))
            button:ClearObjective()
        end
    end

    sort(objectives, function(a, b)
        return a.title == b.title and ((b.objective or 0) < (a.objective or 0)) or (a.title < b.title)
    end)

    -- Add objectives back to bar
    for buttonID, buttonDB in pairs(objectives) do
        self:CreateObjectiveFromUserTemplate(buttons[buttonID], buttonDB, true)
    end

    -- Restore numVisibleButtons
    self:SetBarDBValue("numVisibleButtons", numVisibleButtons, barID)
    bar:UpdateVisibleButtons()

    -- Return #objectives for SizeBarToButtons
    return self.tcount(objectives)
end

function addon:SetBarDisabled(barID, enabled)
    local bars = self:GetDBValue("profile", "bars")

    -- Get toggle value
    if enabled == "_TOGGLE_" then
        if bars[barID].enabled then
            enabled = false
        else
            enabled = true
        end
    end

    bars[barID].enabled = enabled

    -- Release or load bar
    if not enabled then
        self.bars[barID]:Release()
        self.bars[barID] = nil
    else
        self:LoadBar(barID)
    end

    self:SetDBValue("profile", "enabled", self.tcount(self.bars) > 0)

    self:RefreshOptions()
end

function addon:SizeBarToButtons(barID)
    -- Reindex button and get numObjectives
    local numObjectives = self:ReindexButtons(barID)

    -- Update visible buttons
    self:SetBarDBValue("numVisibleButtons", numObjectives, barID)
    self.bars[barID]:UpdateVisibleButtons()
end

function addon:UpdateBars(callback, ...)
    -- Update bar visuals
    for _, bar in pairs(self.bars) do
        bar:ApplySkin()
        bar:SetSize()
        bar:SetAlpha()
        if callback then
           bar[callback](bar, ...)
        end
        for _, button in pairs(bar:GetUserData("buttons")) do
            button:UpdateLayers()
        end
    end
end
