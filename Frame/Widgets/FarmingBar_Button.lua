local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

local _G = _G


--*------------------------------------------------------------------------

local Type = "FarmingBar_Button"
local Version = 1

--*------------------------------------------------------------------------

local postClickMethods = {
    clearObjective = function(self, ...)
        self.widget:ClearObjective()
    end,
}

------------------------------------------------------------

local function Control_PostClick(self, buttonClicked, ...)
    local widget = self.widget
    local keybinds = FarmingBar.db.global.keybinds.button

    for keybind, keybindInfo in pairs(keybinds) do
        if buttonClicked == keybindInfo.button then
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

local function Control_OnEnter(self)
    if addon.DragFrame:IsVisible() then
        self.widget:SetUserData("dragTitle", addon.DragFrame.text:GetText())
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
        widget:SetObjective(objectiveTitle)
        widget:SetUserData("dragTitle", nil)
    elseif not objectiveTitle then
        objectiveTitle = addon:CreateObjectiveFromCursor()
        widget:SetObjective(objectiveTitle)
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
}

--*------------------------------------------------------------------------

local function Constructor()
    local frame = CreateFrame("Button", nil, UIParent, "SecureActionButtonTemplate, SecureHandlerDragTemplate")
    frame:RegisterForClicks("AnyUp")
	frame:SetScript("PostClick", Control_PostClick)
	frame:SetScript("OnEnter", Control_OnEnter)
	frame:SetScript("OnLeave", Control_OnLeave)
	frame:SetScript("OnReceiveDrag", Control_OnReceiveDrag)

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
    Count:SetFont([[Fonts\FRIZQT__.TTF]], 12, "NORMAL")
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