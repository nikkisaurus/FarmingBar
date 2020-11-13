local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
local LSM = LibStub("LibSharedMedia-3.0")

local _G = _G
local floor = math.floor
local format, tonumber = string.format, tonumber

--*------------------------------------------------------------------------

local Type = "FarmingBar_Button"
local Version = 1

--*------------------------------------------------------------------------

local postClickMethods = {
    clearObjective = function(self, ...)
        self.obj:ClearObjective()
    end,

    includeBank = function(self, ...)
        local widget = self.obj
        local objectiveTitle = widget:GetUserData("objectiveTitle")

        if addon:IsObjectiveAutoItem(objectiveTitle) then
            addon:SetTrackerDBInfo(objectiveTitle, 1, "includeBank", "_toggle")
            widget:UpdateLayers()
            -- TODO: Update tracker frame if visible
            -- TODO: Alert bar progress if changed
        end
    end,

    moveObjective = function(self, ...)
        local widget = self.obj
        local bar = addon.bars[widget:GetUserData("barID")]
        local objectiveTitle = widget:GetUserData("objectiveTitle")
        local objective = widget:GetUserData("objective")
        local buttonID = widget:GetUserData("buttonID")

        if objectiveTitle and not addon.moveButton then
            widget.Flash:Show()
            UIFrameFlash(widget.Flash, 0.5, 0.5, -1)
            addon.moveButton = {widget, objectiveTitle, objective}
        elseif addon.moveButton then
            widget:SwapButtons(addon.moveButton)
        end
    end,

    showObjectiveBuilder = function(self, ...)
        addon.ObjectiveBuilder:Load(self.obj:GetUserData("objectiveTitle"))
    end,

    showObjectiveEditBox = function(self, ...)
        self.obj.objectiveEditBox:Show()
    end,
}

--*------------------------------------------------------------------------

local function EditBox_OnEditFocusGained(self)
    self:SetText(self.obj:GetUserData("objective") or "")
    self:HighlightText()
    self:SetCursorPosition(strlen(self:GetText()))
end

------------------------------------------------------------

local function EditBox_OnEscapePressed(self)
    self:ClearFocus()
    self:Hide()
end

------------------------------------------------------------

local function EditBox_OnShow(self)
    local widget = self.obj
    local width = widget.frame:GetWidth()
    self:SetSize(width, width / 2)
    self:SetFocus()
end

------------------------------------------------------------

local function EditBox_OnTextChanged(self)
    self:SetText(string.gsub(self:GetText(), "[%s%c%p%a]", ""))
end

------------------------------------------------------------

local function frame_OnDragStart(self, buttonClicked, ...)
    local widget = self.obj
    if not widget:GetObjectiveTitle() then return end

    local keybinds = FarmingBar.db.global.keybinds.dragButton
    if buttonClicked == keybinds.button then
        local mod = addon:GetModifiers()

        if mod == keybinds.modifier then
            widget:SetUserData("isDragging", true)
            local objectiveTitle = widget:GetUserData("objectiveTitle")
            local objective = widget:GetUserData("objective")
            addon.moveButton = {widget, objectiveTitle, objective}
            addon.DragFrame:Load(objectiveTitle)
            widget:ClearObjective()
        end
    end
end

------------------------------------------------------------

local function frame_OnDragStop(self)
    self.obj:SetUserData("isDragging")
end

------------------------------------------------------------

local function frame_OnEvent(self, event, ...)
    local widget = self.obj
    local barID = widget:GetUserData("barID")
    if not barID then return end
    local barDB = addon.bars[barID]:GetUserData("barDB")
    local buttonID = widget:GetUserData("buttonID")
    local objectiveTitle = widget:GetUserData("objectiveTitle")
    local objectiveInfo = addon:GetObjectiveInfo(objectiveTitle)

    if event == "BAG_UPDATE" or event == "BAG_UPDATE_COOLDOWN" or event == "CURRENCY_DISPLAY_UPDATE" then
        local oldCount = widget:GetCount()
        local newCount = addon:GetObjectiveCount(widget, objectiveTitle)
        local objective = widget:GetUserData("objective")
        local alert, soundID, barAlert

        if newCount ~= oldCount then
            if not barDB.alerts.muteAll then
                if objective then
                    if barDB.alerts.completedObjectives or (not barDB.alerts.completedObjectives and ((oldCount < objective) or (newCount < oldCount and newCount < objective))) then
                        alert = FarmingBar.db.global.settings.alerts.button.format.withObjective

                        if oldCount < objective and newCount >= objective then
                            soundID = "objectiveComplete"
                            barAlert = "complete"
                        else
                            soundID = oldCount < newCount and "farmingProgress"
                            -- Have to check if we lost an objective
                            if oldCount >= objective and newCount < objective then
                                barAlert = "lost"
                            end
                        end
                    end
                else
                    alert = FarmingBar.db.global.settings.alerts.button.format.withoutObjective
                    soundID = oldCount < newCount and "progress"
                end

                local alertInfo = {
                    objectiveTitle = gsub(objectiveTitle, "^item:", ""),
                    objective = objective,
                    oldCount = oldCount,
                    newCount = newCount,
                    difference = newCount - oldCount,
                }

                -- Play alerts
                if FarmingBar.db.global.settings.alerts.button.chat and alert then
                    FarmingBar:Print(addon:ParseAlert(alert, alertInfo))
                end

                if FarmingBar.db.global.settings.alerts.button.screen and alert then
                    -- if not addon.CoroutineUpdater:IsVisible() then
                        UIErrorsFrame:AddMessage(addon:ParseAlert(alert, alertInfo), 1, 1, 1)
                    -- else
                    --     addon.CoroutineUpdater.alert:SetText(addon:ParseAlert(alert, alertInfo))
                    -- end
                end

                if FarmingBar.db.global.settings.alerts.button.sound.enabled and soundID then
                    PlaySoundFile(LSM:Fetch("sound", FarmingBar.db.global.settings.alerts.button.sound[soundID]))
                end

                if barAlert then
                    -- local progressCount, progressTotal = self:GetBar():GetProgress()

                    -- if barAlert == "complete" then
                    --     progressCount = progressCount - 1
                    -- elseif barAlert == "lost" then
                    --     progressCount = progressCount + 1
                    -- end

                    -- self:GetBar():AlertProgress(progressCount, progressTotal)
                end
            end

            widget:UpdateLayers()
        end
    elseif event == "PLAYER_REGEN_ENABLED" then
        widget:SetAttribute()
        self:UnregisterEvent(event)
        -- TODO: print combat left
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        if not objectiveInfo then return end
        local validTrackerID, trackerType = addon:ValidateObjectiveData(objectiveInfo.displayRef.trackerType, objectiveInfo.displayRef.trackerID)

        if FarmingBar.db.profile.style.buttonLayers.Cooldown and trackerType == "ITEM" and validTrackerID then
            local startTime, duration, enable = GetItemCooldown(objectiveInfo.displayRef.trackerID)
            widget.Cooldown:SetCooldown(startTime, duration)

            widget.Cooldown:GetRegions():SetFontObject(NumberFontNormalSmall)
            -- TODO: custom fonts
            -- widget.Cooldown:GetRegions():SetFont(LSM:Fetch("font", self:GetBar().db.font.face or addon.db.profile.style.font.face) or "", (self:GetBar().db.font.size or addon.db.profile.style.font.size) * 1.5, self:GetBar().db.font.outline or addon.db.profile.style.font.outline)
            widget.Cooldown:Show()
        else
            widget.Cooldown:SetCooldown(0, 0)
            widget.Cooldown:Hide()
        end
    end
end

------------------------------------------------------------

local function frame_OnLeave(self)
    GameTooltip:ClearLines()
    GameTooltip:Hide()
end

------------------------------------------------------------

local function frame_OnReceiveDrag(self)
    local widget = self.obj
    local objectiveTitle = addon.DragFrame:GetObjective()

    if objectiveTitle then
        if addon.moveButton then
            if addon.moveButton[1] == self.obj then
                addon.moveButton = nil
            else
                widget:SwapButtons(addon.moveButton)
            end
        else
            widget:SetObjectiveID(objectiveTitle)
        end
    elseif not objectiveTitle then
        objectiveTitle = addon:CreateObjectiveFromCursor()
        if objectiveTitle then
            widget:SetObjectiveID(objectiveTitle)
        end
    end

    addon.DragFrame:Clear()
end

------------------------------------------------------------

local function frame_PostClick(self, buttonClicked, ...)
    local widget = self.obj
    if widget:GetUserData("isDragging") then return end
    local cursorType, cursorID = GetCursorInfo()

    if cursorType == "item" and not IsModifierKeyDown() and buttonClicked == "LeftButton" then
        local objectiveTitle = addon:CreateObjectiveFromCursor()
        widget:SetObjectiveID(objectiveTitle)
        ClearCursor()
        return
    elseif addon.DragFrame:IsVisible() then
        if addon.moveButton then
            widget:SwapButtons(addon.moveButton)
        else
            widget:SetObjectiveID(addon.DragFrame:GetObjective())
        end
        addon.DragFrame:Clear()
        return
    end

    ClearCursor()

    ------------------------------------------------------------

    local keybinds = FarmingBar.db.global.keybinds.button

    for keybind, keybindInfo in pairs(keybinds) do
        if buttonClicked == keybindInfo.button then
            local mod = addon:GetModifiers()

            if mod == keybindInfo.modifier then
                local func = postClickMethods[keybind]
                if func then
                    func(self, keybindInfo, buttonClicked, ...)
                end
            end
        end
    end
end

------------------------------------------------------------

local function objectiveEditBox_OnEnterPressed(self)
    local objective = tonumber(self:GetText())
    objective = objective and (objective > 0 and objective)
    self.obj:SetObjective(objective)

    if FarmingBar.db.global.settings.alerts.button.sound.enabled then
        PlaySoundFile(LSM:Fetch("sound", FarmingBar.db.global.settings.alerts.button.sound[objective and "objectiveSet" or "objectiveCleared"]))
    end

    self:ClearFocus()
    self:Hide()
end

------------------------------------------------------------

local function quickAddEditBox_OnEnterPressed(self)

end

--*------------------------------------------------------------------------

local methods = {
    OnAcquire = function(self)
        self:SetUserData("tooltip", "GetButtonTooltip")

        self.frame:ClearAllPoints()
        self.frame:Show()

        self.objectiveEditBox:Hide()
        self.quickAddEditBox:Hide()
        self:UpdateLayers()
    end,

    ------------------------------------------------------------

    ClearObjective = function(self)
        self:SetUserData("objectiveTitle")
        self:SetUserData("objective")
        FarmingBar.db.char.bars[self:GetUserData("barID")].objectives[self:GetUserData("buttonID")] = nil

        self.frame:UnregisterEvent("BAG_UPDATE")
        self.frame:UnregisterEvent("BAG_UPDATE_COOLDOWN")
        --@retail@
        self.frame:UnregisterEvent("CURRENCY_DISPLAY_UPDATE")
        --@end-retail@

        self:UpdateLayers()
        addon:UpdateButtons()
    end,

    ------------------------------------------------------------

    GetButtonID = function(self)
        local barID = self:GetUserData("barID")
        local buttonID = self:GetUserData("buttonID")

        return format("%d:%d", barID, buttonID)
    end,

    ------------------------------------------------------------

    GetCount = function(self)
        return self:GetUserData("count") or 0
    end,
    ------------------------------------------------------------

    GetObjective = function(self)
        return tonumber(self:GetUserData("objective"))
    end,

    ------------------------------------------------------------

    GetObjectiveTitle = function(self)
        return self:GetUserData("objectiveTitle")
    end,

    ------------------------------------------------------------

    SetAttribute = function(self)
        local info = FarmingBar.db.global.keybinds.button.useItem
        local buttonType = (info.modifier ~= "" and (info.modifier.."-") or "").."type"..(info.button == "RightButton" and 2 or 1)
        local objectiveTitle = self:GetUserData("objectiveTitle")
        local objectiveInfo = addon:GetObjectiveInfo(objectiveTitle)

        if objectiveInfo and self.frame:GetAttribute(buttonType) == "macro" and objectiveInfo.displayRef.trackerType == "MACROTEXT" then
            if self.frame:GetAttribute("macrotext") == objectiveInfo.displayRef.trackerID then
                return
            end
        elseif objectiveInfo and self.frame:GetAttribute(buttonType) == "item" and objectiveInfo.displayRef.trackerType == "ITEM" then
            if self.frame:GetAttribute("item") == ("item"..objectiveInfo.displayRef.trackerID) then
                return
            end
        end

        if UnitAffectingCombat("player") then
            self.frame:RegisterEvent("PLAYER_REGEN_ENABLED")
            -- TODO: print combat error
            return
        end

        self.frame:SetAttribute(buttonType, nil)
        self.frame:SetAttribute("item", nil)
        self.frame:SetAttribute("macrotext", nil)

        if not objectiveInfo then return end

        if objectiveInfo.displayRef.trackerType == "ITEM" and objectiveInfo.displayRef.trackerID then
            self.frame:SetAttribute(buttonType, "item")
            self.frame:SetAttribute("item", "item:"..objectiveInfo.displayRef.trackerID)
        elseif objectiveInfo.displayRef.trackerType == "MACROTEXT" then
            self.frame:SetAttribute(buttonType, "macro")
            self.frame:SetAttribute("macrotext", objectiveInfo.displayRef.trackerID)
        end
    end,

    ------------------------------------------------------------

    SetCount = function(self)
        local objectiveTitle = self:GetUserData("objectiveTitle")
        local objectiveInfo = addon:GetObjectiveInfo(objectiveTitle)
        local style = FarmingBar.db.profile.style.font.fontStrings.count
        if objectiveTitle then
            self:SetUserData("count", addon:GetObjectiveCount(self, objectiveTitle))
        end

        self.Count:SetText(objectiveTitle and addon.iformat(self:GetCount(), 2) or "")
        self:UpdateObjective()

        if not objectiveTitle then return end

        if style.colorType == "ITEMQUALITY" and addon:IsObjectiveAutoItem(objectiveTitle) then -- and item
            local r, g, b = GetItemQualityColor(C_Item.GetItemQualityByID(objectiveInfo.trackers[1].trackerID))
            self.Count:SetTextColor(r, g, b, 1)
        elseif style.colorType == "INCLUDEBANK" and addon:IsObjectiveBankIncluded(objectiveTitle) then -- and includeBank
            self.Count:SetTextColor(1, .82, 0, 1)
        else
            self.Count:SetTextColor(unpack(style.color))
        end
    end,

    ------------------------------------------------------------

    SetIcon = function(self)
        local objectiveTitle = self:GetUserData("objectiveTitle")
        self.Icon:SetTexture(objectiveTitle and addon:GetObjectiveIcon(objectiveTitle) or "")
    end,

    ------------------------------------------------------------

    SetObjective = function(self, objective)
        objective = tonumber(objective)
        self:SetUserData("objective", objective)
        FarmingBar.db.char.bars[self:GetUserData("barID")].objectives[self:GetUserData("buttonID")].objective = objective
        self:UpdateObjective()
        addon:UpdateButtons()
    end,

    ------------------------------------------------------------

    SetObjectiveID = function(self, objectiveTitle, objective)
        if not objectiveTitle and not addon.moveButton then
            self:ClearObjective()
            return
        end

        self:SetUserData("objectiveTitle", objectiveTitle)
        self:SetUserData("objective", objective)
        FarmingBar.db.char.bars[self:GetUserData("barID")].objectives[self:GetUserData("buttonID")] = {objectiveTitle = objectiveTitle, objective = objective}

        self.frame:RegisterEvent("BAG_UPDATE")
        self.frame:RegisterEvent("BAG_UPDATE_COOLDOWN")
        --@retail@
        self.frame:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
        --@end-retail@

        self:UpdateLayers()
    end,

    ------------------------------------------------------------

    SetPoint = function(self, ...) --point, anchor, relpoint, x, y
        self.frame:SetPoint(...)
    end,

    ------------------------------------------------------------

    SetSize = function(self, ...) --width, height
        self.frame:SetSize(...)
        self.Count:SetWidth(self.frame:GetWidth())
    end,

    ------------------------------------------------------------

    SwapButtons = function(self, moveButton)
        local objectiveTitle = self:GetUserData("objectiveTitle")
        local objective = self:GetUserData("objective")
        local moveButtonWidget, moveButtonObjectiveTitle, moveButtonObjective = moveButton[1], moveButton[2], moveButton[3]
        addon.moveButton = nil

        self:SetObjectiveID(moveButtonObjectiveTitle, moveButtonObjective)
        moveButtonWidget:SetObjectiveID(objectiveTitle, objective)

        UIFrameFlashStop(moveButtonWidget.Flash)
        moveButtonWidget.Flash:Hide()
    end,

    ------------------------------------------------------------

    UpdateAutoCastable = function(self)
        local objectiveTitle = self:GetUserData("objectiveTitle")

        if objectiveTitle and FarmingBar.db.profile.style.buttonLayers.AutoCastable then
            if not addon:IsObjectiveBankIncluded(objectiveTitle) then
                self.AutoCastable:Hide()
            else
                self.AutoCastable:Show()
            end
        else
            self.AutoCastable:Hide()
        end
    end,

    ------------------------------------------------------------

    UpdateBorder = function(self)
        local objectiveTitle = self:GetUserData("objectiveTitle")
        local objectiveInfo = addon:GetObjectiveInfo(objectiveTitle)

        if objectiveInfo and FarmingBar.db.profile.style.buttonLayers.Border and objectiveInfo.trackers[1] then
            local itemQuality = C_Item.GetItemQualityByID(objectiveInfo.trackers[1].trackerID)
            if itemQuality and itemQuality > 1 then
                local r, g, b = GetItemQualityColor(itemQuality)
                self.Border:SetVertexColor(r, g, b, 1)
                self.Border:Show()
            end
        else
            self.Border:Hide()
        end
    end,

    ------------------------------------------------------------

    UpdateCooldown = function(self)
        self.Cooldown:SetDrawEdge(FarmingBar.db.profile.style.buttonLayers.CooldownEdge)
    end,

    ------------------------------------------------------------

    UpdateLayers = function(self)
        self:SetIcon()
        self:SetCount()
        self:UpdateObjective()
        self:UpdateAutoCastable()
        self:UpdateBorder()
        self:UpdateCooldown()
        self:SetAttribute()
    end,

    ------------------------------------------------------------

    UpdateObjective = function(self)
        local objectiveTitle = self:GetUserData("objectiveTitle")
        local objective = self:GetUserData("objective")

        if objective then
            local formattedObjective, objective = addon.iformat(objective, 2)
            self.Objective:SetText(formattedObjective)

            local count = addon:GetObjectiveCount(self, objectiveTitle)

            if count >= objective then
                self.Objective:SetTextColor(0, 1 , 0, 1)
                if floor(count / objective) > 1 then
                    self.Objective:SetText(formattedObjective.."*")
                end
            else
                self.Objective:SetTextColor(1, .82, 0, 1)
            end
        else
            self.Objective:SetText("")
        end
    end,
}

--*------------------------------------------------------------------------

local function Constructor()
    local frame = CreateFrame("Button", Type.. AceGUI:GetNextWidgetNum(Type), UIParent, "SecureActionButtonTemplate, SecureHandlerDragTemplate")
	frame:Hide()
    frame:RegisterForClicks("AnyUp")
    frame:RegisterForDrag("LeftButton", "RightButton")
	frame:SetScript("OnDragStart", frame_OnDragStart)
	frame:SetScript("OnDragStop", frame_OnDragStop)
	frame:SetScript("OnEvent", frame_OnEvent)
	frame:SetScript("OnLeave", frame_OnLeave)
	frame:SetScript("OnReceiveDrag", frame_OnReceiveDrag)
    frame:SetScript("PostClick", frame_PostClick)

    frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    frame:RegisterEvent("BANKFRAME_OPENED")
    frame:RegisterEvent("BANKFRAME_CLOSED")

    local FloatingBG = frame:CreateTexture("$parentFloatingBG", "BACKGROUND", nil, 1)
    FloatingBG:SetAllPoints(frame)

    local Icon = frame:CreateTexture("$parentIcon", "BACKGROUND", nil, 2)
    Icon:SetAllPoints(frame)

    local Flash = frame:CreateTexture("$parentFlash", "BACKGROUND", nil, 3)
    Flash:SetAllPoints(frame)
    Flash:Hide()

    local Border = frame:CreateTexture("$parentBorder", "BORDER", nil, 1)
    Border:SetAllPoints(frame)
    Border:Hide()

    local AutoCastable = frame:CreateTexture("$parentAutoCastable", "OVERLAY", nil, 2)
    AutoCastable:SetAllPoints(frame)

    local Count = frame:CreateFontString(nil, "OVERLAY", nil, 3)
    Count:SetFont([[Fonts\FRIZQT__.TTF]], 12, "OUTLINE")
    Count:SetPoint("BOTTOMRIGHT", -2, 2)
    Count:SetPoint("BOTTOMLEFT", 2, 2)
    Count:SetJustifyH("RIGHT")

    local Objective = frame:CreateFontString(nil, "OVERLAY", nil, 3)
    Objective:SetFont([[Fonts\FRIZQT__.TTF]], 12, "OUTLINE")
    Objective:SetPoint("TOPLEFT", 2, -2)
    Objective:SetPoint("TOPRIGHT", -2, -2)
    Objective:SetJustifyH("LEFT")

    local Cooldown = CreateFrame("Cooldown", "$parentCooldown", frame, "CooldownFrameTemplate")
    Cooldown:SetAllPoints(frame)

    local objectiveEditBox = CreateFrame("EditBox", nil, frame)
    objectiveEditBox:SetFrameStrata("TOOLTIP")
    objectiveEditBox:SetPoint("TOPLEFT")
    objectiveEditBox:SetPoint("TOPRIGHT")
    objectiveEditBox:SetAutoFocus(false)
    objectiveEditBox:SetMaxLetters(15)
    objectiveEditBox:SetFont([[Fonts\FRIZQT__.TTF]], 12, "OUTLINE")

    objectiveEditBox.background = objectiveEditBox:CreateTexture(nil, "BACKGROUND")
    objectiveEditBox.background:SetTexture([[INTERFACE\BUTTONS\WHITE8X8]])
    objectiveEditBox.background:SetVertexColor(0, 0, 0, .5)
    objectiveEditBox.background:SetAllPoints(objectiveEditBox)

    objectiveEditBox:SetScript("OnEnterPressed", objectiveEditBox_OnEnterPressed)
    objectiveEditBox:SetScript("OnEscapePressed", EditBox_OnEscapePressed)
    objectiveEditBox:SetScript("OnEditFocusGained", EditBox_OnEditFocusGained)
    objectiveEditBox:SetScript("OnEditFocusLost", EditBox_OnEscapePressed)
    objectiveEditBox:SetScript("OnShow", EditBox_OnShow)
    objectiveEditBox:SetScript("OnTextChanged", EditBox_OnTextChanged)

    local quickAddEditBox = CreateFrame("EditBox", nil, frame)
    quickAddEditBox:SetFrameStrata("TOOLTIP")
    quickAddEditBox:SetPoint("BOTTOMLEFT")
    quickAddEditBox:SetPoint("BOTTOMRIGHT")
    quickAddEditBox:SetAutoFocus(false)
    quickAddEditBox:SetMaxLetters(15)
    quickAddEditBox:SetFont([[Fonts\FRIZQT__.TTF]], 12, "OUTLINE")

    quickAddEditBox.background = quickAddEditBox:CreateTexture(nil, "BACKGROUND")
    quickAddEditBox.background:SetTexture([[INTERFACE\BUTTONS\WHITE8X8]])
    quickAddEditBox.background:SetVertexColor(0, 0, 0, .5)
    quickAddEditBox.background:SetAllPoints(quickAddEditBox)

    quickAddEditBox:SetScript("OnEnterPressed", quickAddEditBox_OnEnterPressed)
    quickAddEditBox:SetScript("OnEscapePressed", EditBox_OnEscapePressed)
    quickAddEditBox:SetScript("OnEditFocusGained", EditBox_OnEditFocusGained)
    quickAddEditBox:SetScript("OnEditFocusLost", EditBox_OnEscapePressed)
    quickAddEditBox:SetScript("OnShow", EditBox_OnShow)
    quickAddEditBox:SetScript("OnTextChanged", EditBox_OnTextChanged)


    ------------------------------------------------------------

    local widget = {
		type  = Type,
        frame = frame,
        FloatingBG = FloatingBG,
        Icon = Icon,
        Flash = Flash,
        Border = Border,
        AutoCastable = AutoCastable,
        Count = Count,
        Objective = Objective,
        Cooldown = Cooldown,
        objectiveEditBox = objectiveEditBox,
        quickAddEditBox = quickAddEditBox,
    }

    frame.obj, objectiveEditBox.obj, quickAddEditBox.obj = widget, widget, widget

    for method, func in pairs(methods) do
        widget[method] = func
    end

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)