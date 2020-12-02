local addonName = ...
local U = LibStub("LibAddonUtils-1.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)
local addon = LibStub("AceAddon-3.0"):GetAddon(L.addonName)
local LSM = LibStub("LibSharedMedia-3.0")

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function addon:AddBar(desc)
    local i = 1
    while self.db.char.bars[i].enabled do
        i = i + 1
    end

    self.db.char.bars[i].enabled = true
    self.db.char.numBars = U.tcount(self.db.char.bars, nil, "enabled")

    if self.bars[i] then
        self.bars[i]:ClearItems()
    end

    -- Create the new bar and update all bars
    self:CreateBar(i)

    -- Add the name/desc to the bar
    local newBarID = self.db.char.numBars
    if desc then
        self.db.char.bars[newBarID].desc = desc
    end

    -- Refresh config
    self:UpdateBars()
    addon:Refresh()
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function addon:CreateBar(id)
    if self.bars[id] then
        self.bars[id]:Refresh()
        return
    end

    local bar = CreateFrame("Frame", string.format("%sBar%d", addonName, id), UIParent, "FarmingBarBarTemplate")

    self.bars[id] = bar
    bar.id = id
    bar.db = self.db.char.bars[id]

    bar.anchor.name:SetText(id)
    self:ApplyButtonSkin(bar.anchor, self.skins[self.db.profile.style.skin.name].anchor or self.db.global.skins[self.db.profile.style.skin.name].anchor)
    bar.anchor:ApplyFont()

    SecureHandlerSetFrameRef(bar.anchor.quickAdd, "quickRemove", bar.anchor.quickRemove)
    SecureHandlerSetFrameRef(bar.anchor.quickRemove, "quickAdd", bar.anchor.quickAdd)

    bar.buttons = {}
    for i = 1, bar.db.visibleButtons do
        self:CreateButton(bar, i)
    end

    bar:Anchor()
    bar:Size()
    bar:SetTransformations()
    bar:UpdateQuickButtons()
    bar:LoadItems()

    bar.counter = bar.db.visibleButtons
    bar.timer = self:ScheduleRepeatingTimer(function()
        bar.counter = bar.counter + 1
        if bar.counter <= self.maxButtons and not bar.buttons[bar.counter] then
            self:CreateButton(bar, bar.counter)
        end
        if bar.counter == self.maxButtons then
            bar.counter = 0
            self:CancelTimer(bar.timer)
            if self.MSQ then
                self:UpdateMasque()
            end
        end
    end, .01)
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function addon:ParseBarAlert(alert, alertInfo)
    local barIDName = L.GetBarIDString(alertInfo.id)
    local barNameLong = string.format("%s%s", barIDName, alertInfo.desc ~= "" and string.format(" (%s)", alertInfo.desc) or "")
    local barName = alertInfo.desc == "" and barIDName or alertInfo.desc

    local percent = math.floor((alertInfo.count / alertInfo.total) * 100)
    local remainder =  alertInfo.total - alertInfo.count

    local progressColor = alertInfo.count == alertInfo.total and "|cff00ff00" or "|cffffcc00"

    -- -- Replaces placeholders with data: colors come first so things like %c and %p don't get changed before colors can be evaluated
    alert = alert:gsub("%%color%%", "|r"):gsub("%%progressColor%%", progressColor):gsub("%%b", barIDName):gsub("%%B", barNameLong):gsub("%%c", alertInfo.count):gsub("%%n", barName):gsub("%%p", percent):gsub("%%r", remainder):gsub("%%t", alertInfo.total)

    alert = self:ParseIfStatement(alert)

    return alert
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function addon:ParseIfStatement(alert)
    -- Loop checks for multiple if statements
    while alert:find("if%%") do
        -- Replacing the end of the first loop with something different so we can narrow it down to the shortest match
        alert = alert:gsub("if%%", "!!", 1)

        -- Storing condition,text,elseText in matches table
        local matches = {alert:match("%%if%((.+),(.+),(.*)%)!!")}

        -- Evalutes the if statement and makes the replacement
        alert = alert:gsub("%%if%((.+),(.+),(.*)%)!!", assert(loadstring("return " .. matches[1]))() and matches[2] or matches[3])
    end

    return alert
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function FarmingBarBarTemplate_OnLoad(self, ...)
    self.anchor:RegisterForDrag("LeftButton")
    self.backdrop:SetFrameStrata("BACKGROUND")

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    function self.backdrop:GetBar()
        return self:GetParent()
    end

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    function self.anchor:ApplyFont()
        self.name:SetFont(LSM:Fetch("font", self:GetBar().db.font.face or addon.db.profile.style.font.face), (self:GetBar().db.font.size or addon.db.profile.style.font.size) * .75, self:GetBar().db.font.outline or addon.db.profile.style.font.outline)
    end

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    function self:AlertProgress(oldCount, oldTotal, newObjectiveComplete)
        if not self.db.trackProgress then return end

        local barAlert = addon.db.global.alertFormats.barProgress
        local progressCount, progressTotal = self:GetProgress()
        local barDB = self.db
        local barAlertInfo = {id = self.id, desc = barDB.desc, count = progressCount, total = progressTotal}

        if addon.db.global.alerts.barChat then
            addon:Print(_G[addon.db.global.alerts.chatFrame], addon:ParseBarAlert(barAlert, barAlertInfo))
        end

        if addon.db.global.alerts.barScreen then
            if not addon.CoroutineUpdater:IsVisible() then
                UIErrorsFrame:AddMessage(addon:ParseBarAlert(barAlert, barAlertInfo), 1, 1, 1)
            else
                addon.CoroutineUpdater.alert:SetText(addon:ParseBarAlert(barAlert, barAlertInfo))
            end
        end

        if addon.db.global.alerts.barSound then
            -- if objective is complete previously but an objective is removed, no sound
            -- if objective is complete previously but an objective is added and not complete, no sound
            -- if objective is previously incomplete and an objective is removed and the whole is still incomplete, no sound
            -- if objective is previously incomplete and an objective is added and not complete, no sound

            -- if objective is complete previously but an objective is added and complete (now currentlyComplete), alert complete
            -- if objective is previously incomplete and an objective is removed and the whole is now complete, alert complete
            -- if objective is previously incomplete but now whole is complete, alert complete

            -- if objective is previously incomplete and an objective is added and complete but the whole is still incomplete, alert progress
            -- if objective is previously incomplete and is still incomplete but the counts are diff, alert progress

            local previouslyComplete = oldCount == oldTotal
            local currentlyComplete = progressCount == progressTotal

            local complete = (previouslyComplete and oldTotal < progressTotal and currentlyComplete) or (not previouslyComplete and oldTotal > progressTotal and currentlyComplete) or (not previouslyComplete and currentlyComplete)
            local progress = (not previouslyComplete and oldTotal < progressTotal and newObjectiveComplete) or (not previouslyComplete and not currentlyComplete and oldCount < progressCount)
            local soundID = (complete and "barComplete") or (progress and "barProgress")

            -- local soundID =
            PlaySoundFile(LSM:Fetch("sound", addon.db.global.sounds[soundID]))
        end
    end

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    function self:Anchor()
        self:ClearAllPoints()
        self:SetPoint(U.unpack(self.db.position))
    end

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    function self:ClearItems()
        for buttonID, objectiveTable in pairs(self.db.objectives) do
            self.buttons[buttonID]:SetObjectiveID()
        end
    end

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    function self:GetProgress()
        local count = 0
        local numObjectives = 0
        for buttonID, objectiveTable in pairs(self.db.objectives) do
            if objectiveTable.objective then
                numObjectives = numObjectives + 1
                if self.buttons[buttonID]:GetCount() >= objectiveTable.objective then
                    count = count + 1
                end
            end
        end
        return count, numObjectives
    end

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    function self:LoadItems()
        for buttonID, objectiveTable in pairs(self.db.objectives) do
            if not self.buttons[buttonID] then
                addon:CreateButton(self, buttonID)
            end
            addon:SetObjectiveID(self.buttons[buttonID], objectiveTable)
        end
    end

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    function self:Refresh()
        self.db = addon.db.char.bars[self.id]
        self.anchor:ApplyFont()
        self:Anchor()
        self:Size()
        self:SetTransformations()
        self:UpdateButtons("Update")
        self:LoadItems()
    end

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    function self:ReindexButtons(resize)
        local temp = {}
        for k, v in pairs(self.db.objectives) do
            if v.type then
                tinsert(temp, v)
            end
        end

        addon:SortObjectives(temp)

        -- Load items onto buttons and clear old items
        for buttonID, button in pairs(self.buttons) do
            local tempButton = temp[buttonID]
            if tempButton then
                if tempButton.type == "item" then
                    button:SetObjectiveID(tempButton.type, tempButton.itemID, nil, tempButton)
                elseif tempButton.type == "currency" then
                    button:SetObjectiveID(tempButton.type, tempButton.currencyID, nil, tempButton)
                elseif tempButton.type == "mixedItems" or tempButton.type == "shoppingList" then
                    -- Note that we don't need to pass a flags table because we've passed in an objective table instead
                    button:SetObjectiveID(tempButton.type, tempButton.items, nil, tempButton)
                end
            elseif not tempButton and button.objective then
                button:SetObjectiveID()
            end
        end

        -- Resize the bar's visibleButtons to the number of items on the bar
        if resize then
            self.db.visibleButtons = U.tcount(self.db.objectives, nil, "type")
            self:UpdateButtons("SetVisible")
            self:SetBackdrop()
        end
    end

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    function self:SetBackdrop()
        local directionInfo = addon.directionInfo[tonumber(self.db.direction)].button
        local rowInfo = addon.directionInfo[tonumber(self.db.direction)][tonumber(self.db.rowDirection)]

        if self.db.visibleButtons == 0 then
            self.backdrop:ClearAllPoints()
            self.backdrop:SetAllPoints(self.anchor)
            return
        end

        self.backdrop:ClearAllPoints()
        self.backdrop:SetPoint(rowInfo.point, self.buttons[1], rowInfo.point)
        self.backdrop:SetPoint(directionInfo.point, self.buttons[1], directionInfo.point)
        self.backdrop:SetPoint(rowInfo.relativePoint, self.buttons[self.db.visibleButtons], rowInfo.relativePoint)
        self.backdrop:SetPoint(directionInfo.relativePoint, self.db.visibleButtons > self.db.buttonsPerRow and self.buttons[self.db.buttonsPerRow] or self.buttons[self.db.visibleButtons], directionInfo.relativePoint)
    end

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    function self:SetHidden()
        if self.db.hidden then
            self:Hide()
        else
            self:Show()
        end
    end

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    function self:SetMouseover()
        if self.db.mouseover then
            self:SetAlpha(0)
            self.anchor:SetAlpha(self.db.alpha)
        elseif self.db.anchorMouseover then
            self.anchor:SetAlpha(0)
            self:SetAlpha(self.db.alpha)
        else
            self:SetAlpha(self.db.alpha)
            self.anchor:SetAlpha(self.db.alpha)
        end
    end

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    function self:SetTransformations()
        self:SetScale(self.db.scale)
        self:SetAlpha(self.db.alpha)
        self:SetHidden()
        self:SetMouseover()
    end

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    function self:Size()
        self:SetSize(self.db.buttonSize * .75, self.db.buttonSize * .75)
        self.anchor:SetSize(self.db.buttonSize * .75, self.db.buttonSize * .75)

        self.anchor.quickAdd:SetSize((self.anchor:GetWidth() / 2) - 6, (self.anchor:GetWidth() / 2 - 6))
        self.anchor.quickAdd:SetPoint("TOPRIGHT", self, "TOP", -3, -4)

        self.anchor.quickRemove:SetSize(self.anchor.quickAdd:GetWidth(), self.anchor.quickAdd:GetHeight())
        self.anchor.quickRemove:SetPoint("TOPLEFT", self, "TOP", 3, -4)

        self:SetBackdrop()
    end

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    function self:Update(newID)
        self.id = newID
        self.anchor.name:SetText(newID)
    end

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    function self:UpdateButtons(callback)
        for buttonID, button in pairs(self.buttons) do
            button[callback](button)
        end
    end

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    function self:UpdateQuickButtons()
        if UnitAffectingCombat("player") then
            self:RegisterEvent("PLAYER_REGEN_ENABLED")
            return
        end

        if self.db.visibleButtons >= addon.maxButtons then
            self.anchor.quickRemove:Enable()
            self.anchor.quickAdd:Disable()
        elseif self.db.visibleButtons == 0 then
            self.anchor.quickAdd:Enable()
            self.anchor.quickRemove:Disable()
        else
            self.anchor.quickAdd:Enable()
            self.anchor.quickRemove:Enable()
        end
    end

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    self:SetScript("OnEvent", function(self, event)
        if event == "PLAYER_REGEN_ENABLED" then
            self:UnregisterEvent(event)
            self:UpdateQuickButtons()
        end
    end)
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function FarmingBarBarTemplate_OnUpdate(self, ...)
    local frame = GetMouseFocus()
    if (frame and not frame:IsForbidden() and frame:GetName() and not frame:GetName():find("^FarmingBar")) or not frame then
        if self.db.mouseover then
            if self.isMoving then
                self:SetAlpha(self.db.alpha)
            else
                self:SetAlpha(0)
            end
        elseif self.db.anchorMouseover then
            if self.isMoving then
                self.anchor:SetAlpha(self.db.alpha)
            else
                self.anchor:SetAlpha(0)
            end
        end

        if GameTooltip[addonName] then
            GameTooltip[addonName] = nil
            GameTooltip:Hide()
        end
    elseif self.anchor:IsMouseOver() then
        if self.db.mouseover then
            self:SetAlpha(self.db.alpha)
        elseif self.db.anchorMouseover then
            self.anchor:SetAlpha(self.db.alpha)
        end
        if addon.db.global.tooltips.bar then
            addon:ShowTooltip(self.id)
        end
    elseif self.backdrop:IsMouseOver() then
        if self.db.mouseover then
            self:SetAlpha(self.db.alpha)
        end
        if addon.db.global.tooltips.button and frame and frame.id then
            addon:ShowTooltip(self.id, frame.id)
        else
            GameTooltip[addonName] = nil
            GameTooltip:Hide()
        end
    end
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function FarmingBarBarTemplateAnchor_OnClick(self, button, ...)
    if button == "LeftButton" then
        if IsShiftKeyDown() then
            -- Lock or unlock bar.
            addon:SetDBValue("char.bars", "movable", "_toggle", self:GetBar().id)
            addon:Refresh()
            addon:Print(L.BarMovableChanged(self:GetBar().id, addon:GetDBValue("char.bars", "movable", self:GetBar().id)))
        elseif IsAltKeyDown() then
            -- Open settings.
            addon:Open("settings")
        elseif IsControlKeyDown() then
            -- Toggle bar progress.
            addon:SetDBValue("char.bars", "trackProgress", "_toggle", self:GetBar().id)
            addon:Refresh()
            addon:Print(L.BarTrackingChanged(self:GetBar().id, addon:GetDBValue("char.bars", "trackProgress", self:GetBar().id)))
        end
    elseif button == "RightButton" then
        if IsShiftKeyDown() then
            -- Open bar config.
            addon:Open("bars", "bar" .. self:GetBar().id)
        elseif IsControlKeyDown() then
            -- Open editbox to enter button ID for objective builder.
            self.ButtonIDEditBox:Show()
        else
            -- Open help.
            addon:Open("help")
        end
    end
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function FarmingBarBarTemplateAnchor_OnDragStart(self, ...)
    if self:GetBar().db.movable then
        self:GetBar():SetMovable(true)
        self:GetBar():StartMoving()
        self:GetBar().isMoving = true
    end

    if self:GetBar().db.mouseover then
        self:GetBar():SetAlpha(self:GetBar().db.alpha)
    end
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function FarmingBarBarTemplateAnchor_OnDragStop(self, ...)
    if self:GetBar().db.movable then
        self:GetBar():StopMovingOrSizing()
        self:GetBar():SetMovable(false)
        self:GetBar().isMoving = false
        self:GetBar().db.position = {self:GetBar():GetPoint()}
    end

    if self:GetBar().db.mouseover then
        self:GetBar():SetAlpha(0)
    end
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function FarmingBarBarTemplateAnchor_OnLoad(self, ...)
    function self:GetBar()
        return self:GetParent()
    end
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function FarmingBarTemplateEditBox_OnFocusGained(self, ...)
    self:HighlightText()
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function FarmingBarTemplateEditBox_OnEscapePressed(self, ...)
    self:ClearFocus()
    self:Hide()
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function FarmingBarTemplateEditBox_OnShow(self, ...)
    self:SetSize(self:GetParent():GetWidth(), self:GetParent():GetWidth() / 2)
    self:SetFocus()
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function FarmingBarTemplateEditBox_OnTextChanged(self, ...)
    self:SetText(string.gsub(self:GetText(), "[%s%c%p%a]", ""))
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function FarmingBarBarTemplateButtonIDEditBox_OnEnterPressed(self, ...)
    local buttonID = tonumber(self:GetText()) > addon.maxButtons and addon.maxButtons or tonumber(self:GetText())
    addon.ObjectiveBuilder:Load(self:GetParent():GetParent().buttons[buttonID])

    self:SetText("")
    self:ClearFocus()
    self:Hide()
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function FarmingBarBarTemplateQuick_PostClick(self, ...)
    self:GetBar():SetBackdrop()
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function FarmingBarBarTemplateQuickAdd_OnLoad(self, ...)
    function self:GetBar()
        return self:GetParent():GetParent()
    end

    SecureHandlerSetFrameRef(self, "bar", self:GetBar())
    self:SetAttribute("_onclick", [=[
        local buttons = table.new(self:GetFrameRef("bar"):GetChildren())

        local visible, total = 0, 0
        for k, v in pairs(buttons) do
            if v:IsVisible() then
                visible = visible + 1
            end
            total = total + 1
        end

        buttons[visible + 1]:Show()

        if visible == (total - 1) then -- total - newly shown button
            self:Disable()
        end

        self:GetFrameRef("quickRemove"):Enable()
    ]=])
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function FarmingBarBarTemplateQuickAdd_PreClick(self, ...)
    if self:GetBar().db.visibleButtons < addon.maxButtons then
        addon:SetDBValue("char.bars", "visibleButtons", self:GetBar().db.visibleButtons + 1, self:GetBar().id)
    end
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function FarmingBarBarTemplateQuickRemove_OnLoad(self, ...)
    function self:GetBar()
        return self:GetParent():GetParent()
    end

    SecureHandlerSetFrameRef(self, "bar", self:GetBar())
    self:SetAttribute("_onclick", [=[
        local buttons = table.new(self:GetFrameRef("bar"):GetChildren())

        local visible = 0
        for k, v in pairs(buttons) do
            if v:IsVisible() then
                visible = visible + 1
            end
        end

        buttons[visible]:Hide()

        if visible == 3 then -- anchor, backdrop + the button we just hid
            self:Disable()
        end

        self:GetFrameRef("quickAdd"):Enable()
    ]=])
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function FarmingBarBarTemplateQuickRemove_PreClick(self, ...)
    if self:GetBar().db.visibleButtons > 0 then
        addon:SetDBValue("char.bars", "visibleButtons", self:GetBar().db.visibleButtons - 1, self:GetBar().id)
    end
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function addon:LoadBars()
    for k, v in pairs(self.db.char.bars) do
        self:CreateBar(k)
    end
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

local tempBar
function addon:ReindexBars()
    for barID, bar in pairs(self.bars) do
        if bar.db ~= self.db.char.bars[barID] then
            local newKey = U.GetTableKey(self.db.char.bars, bar.db)
            if newKey then
                tempBar = self.bars[newKey]
                self.bars[newKey] = bar
                self.bars[barID] = tempBar
                tempBar = nil

                self.bars[newKey]:Update(newKey)
                self.bars[barID]:Update(barID)
            end
        end
    end
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function addon:RemoveBar(barID, overwrite)
    barID = tonumber(barID)

    if self.bars[barID] and overwrite ~= "true" then
        -- Confirm overwrite
        StaticPopupDialogs.FARMINGBAR_CONFIRM_REMOVE_BAR.text = L._Bars("removeBarConfirm", barID)
        local dialog = StaticPopup_Show("FARMINGBAR_CONFIRM_REMOVE_BAR", barID)
        if dialog then
            dialog.data = barID
        end
    else
        -- Clear items off the bar to prevent count text from being active when bar is reused
        self.bars[barID]:ClearItems()

        -- Remove the bar from the database and reset the bar count
        self.db.char.bars[barID].enabled = false
        tremove(self.db.char.bars, barID)
        self.db.char.numBars = U.tcount(self.db.char.bars, nil, "enabled")

        -- Hide the removed bar
        self.bars[barID]:Hide()
        self.bars[barID]:ClearAllPoints()

        -- Reindex bars for reuse and refresh the configuration window
        self:ReindexBars()
        self:UpdateBars()
        addon:Refresh()
    end
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function addon:ResetProfile(overwrite)
    if overwrite ~= "true" then
        -- Confirm overwrite
        StaticPopupDialogs.FARMINGBAR_CONFIRM_RESET_PROFILE.text = L._Bars("resetCharExecuteConfirm")
        StaticPopup_Show("FARMINGBAR_CONFIRM_RESET_PROFILE")
    else

        for barID, bar in pairs(self.bars) do
            bar:ClearItems()
        end

        for barID, barDB in pairs(self.db.char.bars) do
            barDB.enabled = false
        end
        wipe(self.db.char.bars)
        self.db.char.numBars = 0

        for barID, bar in pairs(self.bars) do
            bar:Hide()
            bar:ClearAllPoints()
        end

        self:AddBar()
        self:UpdateBars()
        self:Refresh()
    end
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

StaticPopupDialogs["FARMINGBAR_CONFIRM_REMOVE_BAR"] = {
    button1 = L["Yes"],
    button2 = L["No"],
    OnAccept = function(_, barID)
        addon:RemoveBar(barID, "true")
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

StaticPopupDialogs["FARMINGBAR_CONFIRM_RESET_PROFILE"] = {
    button1 = L["Yes"],
    button2 = L["No"],
    OnAccept = function()
        addon:ResetProfile("true")
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}