local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

local _G = _G


--*------------------------------------------------------------------------

local Type = "FarmingBar_Button"
local Version = 1

--*------------------------------------------------------------------------

local function GetModifiers()
    local mod = ""
    if IsShiftKeyDown() then
        mod = "shift"
    end
    if IsControlKeyDown() then
        mod = "ctrl"..(mod ~= "" and "-" or "")..mod
    end
    if IsAltKeyDown() then
        mod = "alt"..(mod ~= "" and "-" or "")..mod
    end
    return mod
end

--*------------------------------------------------------------------------

local postClickMethods = {
    clearObjective = function(self, ...)
        self.widget:ClearObjective()
    end,

    moveObjective = function(self, ...)
        local widget = self.widget
        local bar = addon.bars[widget:GetUserData("barID")]
        local objectiveTitle = widget:GetUserData("objectiveTitle")
        local buttonID = widget:GetUserData("buttonID")

        if objectiveTitle and not addon.moveButton then
            widget.Flash:Show()
            UIFrameFlash(widget.Flash, 0.5, 0.5, -1)
            addon.moveButton = {widget, objectiveTitle}
        elseif addon.moveButton then
            widget:SwapButtons(addon.moveButton)
        end
    end,

    showObjectiveBuilder = function(self, ...)
        addon.ObjectiveBuilder:Load(self.widget:GetUserData("objectiveTitle"))
    end,
}

--*------------------------------------------------------------------------

local function Control_OnDragStart(self, buttonClicked, ...)
    local widget = self.widget
    local keybinds = FarmingBar.db.global.keybinds.dragButton

    widget:SetUserData("isDragging", true)

    if buttonClicked == keybinds.button then
        local mod = GetModifiers()

        if mod == keybinds.modifier then
            local objectiveTitle = widget:GetUserData("objectiveTitle")
            addon.moveButton = {widget, objectiveTitle}
            addon.DragFrame:Load(objectiveTitle)
            widget:ClearObjective()
        end
    end
end

------------------------------------------------------------

local function Control_OnDragStop(self)
    self.widget:SetUserData("isDragging", nil)
end

------------------------------------------------------------

local function Control_OnEnter(self)
    if addon.DragFrame:IsVisible() then
        self.widget:SetUserData("dragTitle", addon.DragFrame:GetObjective())
    end
end

------------------------------------------------------------

local function Control_OnEvent(self, event, ...)
    local widget = self.widget
    local barID = widget:GetUserData("barID")
    local barDB = addon.bars[barID]:GetUserData("barDB")
    local buttonID = widget:GetUserData("buttonID")
    local objectiveTitle = widget:GetUserData("objectiveTitle")

    if event == "BAG_UPDATE" or event == "BAG_UPDATE_COOLDOWN" then
        if not barDB.alerts.muteAll then
            local count = addon:GetObjectiveCount(objectiveTitle)
            if count ~= widget:GetCount() then
                widget:SetCount(count)
            end
        end
    end
end

------------------------------------------------------------

local function Control_OnLeave(self)
    self.widget:SetUserData("dragTitle")
end

------------------------------------------------------------

local function Control_OnReceiveDrag(self)
    local widget = self.widget
    local objectiveTitle = widget:GetUserData("dragTitle")

    if objectiveTitle then
        if addon.moveButton then
            widget:SwapButtons(addon.moveButton)
        else
            widget:SetObjective(objectiveTitle)
        end

        widget:SetUserData("dragTitle", nil)
    elseif not objectiveTitle then
        objectiveTitle = addon:CreateObjectiveFromCursor()
        widget:SetObjective(objectiveTitle)
    end

    addon.DragFrame:Clear()
end

------------------------------------------------------------

local function Control_PostClick(self, buttonClicked, ...)
    local widget = self.widget
    if widget:GetUserData("isDragging") then return end
    local cursorType, cursorID = GetCursorInfo()

    if cursorType == "item" and not IsModifierKeyDown() and buttonClicked == "LeftButton" then
        local objectiveTitle = addon:CreateObjectiveFromCursor()
        widget:SetObjective(objectiveTitle)
        ClearCursor()
        return
    elseif addon.DragFrame:IsVisible() then
        if addon.moveButton then
            widget:SwapButtons(addon.moveButton)
        else
            widget:SetObjective(addon.DragFrame:GetObjective())
        end
        addon.DragFrame:Clear()
        return
    end

    ClearCursor()

    ------------------------------------------------------------

    local keybinds = FarmingBar.db.global.keybinds.button

    for keybind, keybindInfo in pairs(keybinds) do
        if buttonClicked == keybindInfo.button then
            local mod = GetModifiers()

            if mod == keybindInfo.modifier then
                local func = postClickMethods[keybind]
                if func then
                    func(self, keybindInfo, buttonClicked, ...)
                end
            end
        end
    end
end

--*------------------------------------------------------------------------

local methods = {
    OnAcquire = function(self)
        self.frame:ClearAllPoints()
        self.frame:Show()
    end,

    ------------------------------------------------------------

    ClearObjective = function(self)
        self:SetUserData("objectiveTitle", nil)
        FarmingBar.db.char.bars[self:GetUserData("barID")].objectives[self:GetUserData("buttonID")] = nil

        self:SetIcon("")
        self:SetCount("")

        self.frame:UnregisterEvent("BAG_UPDATE")
        self.frame:UnregisterEvent("BAG_UPDATE_COOLDOWN")
    end,

    ------------------------------------------------------------

    GetCount = function(self)
        return self.Count:GetText()
    end,

    ------------------------------------------------------------

    SetAttribute = function(self)
        local info = FarmingBar.db.global.keybinds.button.useItem
        local buttonType = (info.modifier ~= "" and (info.modifier.."-") or "").."type"..(info.button == "RightButton" and 2 or 1)
        local objectiveTitle = self:GetUserData("objectiveTitle")
        local objectiveInfo = addon:GetObjectiveInfo(objectiveTitle)

        self.frame:SetAttribute(buttonType, nil)
        self.frame:SetAttribute("item", nil)
        self.frame:SetAttribute("macrotext", nil)

        if objectiveInfo.displayRef.trackerType == "ITEM" and objectiveInfo.displayRef.trackerID then
            self.frame:SetAttribute(buttonType, "item")
            self.frame:SetAttribute("item", "item:"..objectiveInfo.displayRef.trackerID)
        elseif objectiveInfo.displayRef.trackerType == "MACROTEXT" then
            self.frame:SetAttribute(buttonType, "macro")
            self.frame:SetAttribute("macrotext", objectiveInfo.displayRef.trackerID)
        end

        self.frame:RegisterEvent("BAG_UPDATE")
        self.frame:RegisterEvent("BAG_UPDATE_COOLDOWN")
    end,

    ------------------------------------------------------------

    SetCount = function(self, count)
        self.Count:SetText(count)
    end,

    ------------------------------------------------------------

    SetIcon = function(self, icon)
        self.Icon:SetTexture(icon)
    end,

    ------------------------------------------------------------

    SetObjective = function(self, objectiveTitle)
        if not objectiveTitle then
            self:ClearObjective()
            return
        end

        self:SetUserData("objectiveTitle", objectiveTitle)
        FarmingBar.db.char.bars[self:GetUserData("barID")].objectives[self:GetUserData("buttonID")] = objectiveTitle

        self:SetIcon(addon:GetObjectiveIcon(objectiveTitle))
        self:SetCount(addon:GetObjectiveCount(objectiveTitle))
        self:SetAttribute()
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
        local moveButtonWidget, moveButtonObjectiveTitle = moveButton[1], moveButton[2]
        addon.moveButton = nil

        self:SetObjective(moveButtonObjectiveTitle)
        moveButtonWidget:SetObjective(objectiveTitle)

        UIFrameFlashStop(moveButtonWidget.Flash)
        moveButtonWidget.Flash:Hide()
    end,
}

--*------------------------------------------------------------------------

local function Constructor()
    local frame = CreateFrame("Button", Type.. AceGUI:GetNextWidgetNum(Type), UIParent, "SecureActionButtonTemplate, SecureHandlerDragTemplate")
    frame:RegisterForClicks("AnyUp")
    frame:RegisterForDrag("LeftButton", "RightButton")
	frame:SetScript("OnDragStart", Control_OnDragStart)
	frame:SetScript("OnDragStop", Control_OnDragStop)
	frame:SetScript("OnEnter", Control_OnEnter)
	frame:SetScript("OnEvent", Control_OnEvent)
	frame:SetScript("OnLeave", Control_OnLeave)
	frame:SetScript("OnReceiveDrag", Control_OnReceiveDrag)
    frame:SetScript("PostClick", Control_PostClick)

    local FloatingBG = frame:CreateTexture("$parentFloatingBG", "BACKGROUND", nil, -7)
    FloatingBG:SetAllPoints(frame)

    local Icon = frame:CreateTexture("$parentIcon", "BACKGROUND", nil, -6)
    Icon:SetAllPoints(frame)

    local Flash = frame:CreateTexture("$parentFlash", "BACKGROUND", nil, -5)
    Flash:SetAllPoints(frame)
    Flash:Hide()

    local Border = frame:CreateTexture("$parentBorder", "BORDER")
    Border:SetAllPoints(frame)
    Border:Hide()

    local AutoCastable = frame:CreateTexture("$parentAutoCastable", "OVERLAY")
    AutoCastable:SetAllPoints(frame)
    AutoCastable:Hide()

    local Count = frame:CreateFontString(nil, "OVERLAY")
    Count:SetFont([[Fonts\FRIZQT__.TTF]], 12, "OUTLINE")
    Count:SetPoint("BOTTOMRIGHT", -2, 2)

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
    }

    frame.widget = widget

    for method, func in pairs(methods) do
        widget[method] = func
    end

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)