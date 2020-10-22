local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

local CreateFrame, UIParent = CreateFrame, UIParent

--*------------------------------------------------------------------------

local Type = "FarmingBarBar"
local Version = 1

--*------------------------------------------------------------------------

local function Control_OnDragStart(self)
    self:StartMoving()
end

------------------------------------------------------------

local function Control_OnDragStop(self)
    self:StopMovingOrSizing()
end

--*------------------------------------------------------------------------

local methods = {
    Acquire = function(self)
        self:SetSize(35)
        self:SetPoint("CENTER")
        self:SetSkin("FarmingBar_Default")
        self:SetBarID()
    end,

    SetBarID = function(self, barID)
        self:SetUserData("barID", barID)
        self.barID:SetText(barID or "")
    end,

    SetPoint = function(self, ...) --point, anchor, relpoint, x, y
        self.frame:SetPoint(...)
    end,

    SetSize = function(self, frameSize)
        self.frame:SetSize(frameSize, frameSize)
        local paddingSize = (3/20 * frameSize)
        local buttonSize = (frameSize - (paddingSize * 3)) / 2
        local fontSize = frameSize / 3

        self.addButton:SetSize(buttonSize, buttonSize)
        self.addButton:SetPoint("TOPLEFT", paddingSize, -paddingSize)

        self.removeButton:SetSize(buttonSize, buttonSize)
        self.removeButton:SetPoint("TOPRIGHT", -paddingSize, -paddingSize)

        self.barID:SetFont([[Fonts\FRIZQT__.TTF]], fontSize, "NORMAL")
        self.barID:SetPoint("BOTTOM", 0, paddingSize * 1.5)
    end,

    SetSkin = function(...) --self, skin
        addon:SkinBar(...)
    end,
}

--*------------------------------------------------------------------------

local function Constructor(...)
    local frame = CreateFrame("Frame", Type..AceGUI:GetNextWidgetNum(Type), UIParent)
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")

    frame:SetScript("OnDragStart", Control_OnDragStart)
    frame:SetScript("OnDragStop", Control_OnDragStop)

    local backdrop = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    backdrop:EnableMouse(true)

    local anchor = frame:CreateTexture("$parentFloatingBG", "BACKGROUND")
    anchor:SetAllPoints(frame)

    local addButton = CreateFrame("Button", nil, frame)
    addButton:SetNormalTexture([[INTERFACE\ADDONS\FARMINGBAR\MEDIA\PLUS]])
    addButton:SetDisabledTexture([[INTERFACE\ADDONS\FARMINGBAR\MEDIA\PLUS-DISABLED]])
--
    local removeButton = CreateFrame("Button", nil, frame)
    removeButton:SetNormalTexture([[INTERFACE\ADDONS\FARMINGBAR\MEDIA\MINUS]])
    removeButton:SetDisabledTexture([[INTERFACE\ADDONS\FARMINGBAR\MEDIA\MINUS-DISABLED]])

    local barID = frame:CreateFontString(nil, "OVERLAY")
    barID:SetFont([[Fonts\FRIZQT__.TTF]], 12, "NORMAL")

    ------------------------------------------------------------

    local widget = {
        frame = frame,
        backdrop = backdrop,
        anchor = anchor,
        addButton = addButton,
        removeButton = removeButton,
        barID = barID,
    }

    for method, func in pairs(methods) do
        widget[method] = func
    end

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)