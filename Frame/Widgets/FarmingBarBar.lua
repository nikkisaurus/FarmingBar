local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

local fmod = math.fmod
local CreateFrame, UIParent = CreateFrame, UIParent

--*------------------------------------------------------------------------

local Type = "FarmingBarBar"
local Version = 1

--*------------------------------------------------------------------------

local function addButton_OnClick(self)
    local widget = self.widget
    local barDB = widget:GetUserData("barDB")
    barDB.numVisibleButtons = barDB.numVisibleButtons + 1
end

------------------------------------------------------------

local function Control_OnDragStart(self)
    self.widget.frame:StartMoving()
end

------------------------------------------------------------

local function Control_OnDragStop(self)
    self.widget.frame:StopMovingOrSizing()
end

------------------------------------------------------------

local function removeButton_OnClick(self)
    local widget = self.widget
end

--*------------------------------------------------------------------------

local anchors = {
    RIGHT = {
        anchor = "TOPLEFT",
        relativeAnchor = "TOPRIGHT",
        xOffset = 1,
        yOffset = 0,
        NORMAL = "DOWN",
        REVERSE = "UP",
    },
    LEFT = {
        anchor = "TOPRIGHT",
        relativeAnchor = "TOPLEFT",
        xOffset = -1,
        yOffset = 0,
        NORMAL = "DOWN",
        REVERSE = "UP",
    },
    UP = {
        anchor = "BOTTOMLEFT",
        relativeAnchor = "TOPLEFT",
        xOffset = 0,
        yOffset = 1,
        NORMAL = "RIGHT",
        REVERSE = "LEFT",
    },
    DOWN = {
        anchor = "TOPLEFT",
        relativeAnchor = "BOTTOMLEFT",
        xOffset = 0,
        yOffset = -1,
        NORMAL = "RIGHT",
        REVERSE = "LEFT",
    },
}

------------------------------------------------------------

local function GetAnchorPoints(grow)
    return anchors[grow].anchor, anchors[grow].relativeAnchor, anchors[grow].xOffset, anchors[grow].yOffset
end

local function GetRelativeAnchorPoints(grow)
    return GetAnchorPoints(anchors[grow[1]][grow[2]])
end

--*------------------------------------------------------------------------

local methods = {
    Acquire = function(self)
        self:SetUserData("buttons", {})
        self:SetBarDB()
    end,

    ------------------------------------------------------------

    AddButton = function(self)
        local buttons = self:GetUserData("buttons")
        tinsert(buttons, AceGUI:Create("FarmingBarButton"))
        self:DoLayout()
    end,

    ------------------------------------------------------------

    DoLayout = function(self)
        local barDB = self:GetUserData("barDB")
        local buttons = self:GetUserData("buttons")

        local anchor, relativeAnchor, xOffset, yOffset = GetAnchorPoints(barDB.grow[1])

        for key, button in pairs(buttons) do
            button:SetSize(self.frame:GetWidth(), self.frame:GetHeight())

            button:ClearAllPoints()

            if key == 1 then
                button:SetPoint(anchor, self.frame, relativeAnchor, xOffset * barDB.button.padding, yOffset * barDB.button.padding)
            else
                if fmod(key, barDB.buttonWrap) == 1 then
                    local anchor, relativeAnchor, xOffset, yOffset = GetRelativeAnchorPoints(barDB.grow)
                    button:SetPoint(anchor, buttons[key - barDB.buttonWrap].frame, relativeAnchor, xOffset * barDB.button.padding, yOffset * barDB.button.padding)
                else
                    button:SetPoint(anchor, buttons[key - 1].frame, relativeAnchor, xOffset * barDB.button.padding, yOffset * barDB.button.padding)
                end
            end
        end
    end,

    ------------------------------------------------------------

    SetAlpha = function(self, alpha)
        self.frame:SetAlpha(alpha)
    end,

    ------------------------------------------------------------

    SetBarDB = function(self, barID)
        self:SetUserData("barID", barID)
        self.barID:SetText(barID or "")

        local barDB = FarmingBar.db.char.bars[barID]
        self:SetUserData("barDB", barDB)

        self:SetAlpha(barDB and barDB.alpha or 1)
        self:SetHidden(barDB and barDB.hidden or false)
        self:SetMovable(barDB and barDB.movable or true)
        self:SetPoint(barDB and unpack(barDB.point) or "TOP")
        self:SetScale(barDB and barDB.scale or 1)
        self:SetSize(barDB and barDB.button.size or 35)

        if not barDB then
            for _, button in pairs(self:GetUserData("buttons")) do
                button:ClearAllPoints()
            end
        else
            for i = 1, barDB.numVisibleButtons do
                self:AddButton()
            end
        end

        self:ApplySkin()
    end,

    ------------------------------------------------------------

    SetHidden = function(self, hidden)
        if hidden then
            self.frame:Hide()
        else
            self.frame:Show()
        end
    end,

    ------------------------------------------------------------

    SetMovable = function(self, movable)
        self.frame:SetMovable(movable)
    end,

    ------------------------------------------------------------

    SetPoint = function(self, ...) --point, anchor, relpoint, x, y
        self.frame:SetPoint(...)
    end,

    ------------------------------------------------------------

    SetScale = function(self, scale)
        self.frame:SetScale(scale)
    end,

    ------------------------------------------------------------

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

    ------------------------------------------------------------

    ApplySkin = function(self)
        local skin = FarmingBar.db.profile.style.skin
        addon:SkinBar(self, skin)
        for _, button in pairs(self:GetUserData("buttons")) do
            addon:SkinButton(button, skin)
        end
    end,
}

--*------------------------------------------------------------------------

local function Constructor()
    local frame = CreateFrame("Frame", Type..AceGUI:GetNextWidgetNum(Type), UIParent)
    frame:SetClampedToScreen(true)

    local backdrop = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    backdrop:EnableMouse(true)

    local anchor = CreateFrame("Button", "$parentAnchor", frame)
    anchor:SetAllPoints(frame)
    anchor:SetClampedToScreen(true)
    anchor:EnableMouse(true)
    anchor:RegisterForClicks("AnyUp")
    anchor:SetMovable(true)
    anchor:RegisterForDrag("LeftButton")

    anchor:SetScript("OnDragStart", Control_OnDragStart)
    anchor:SetScript("OnDragStop", Control_OnDragStop)

    local FloatingBG = anchor:CreateTexture("$parentFloatingBG", "BACKGROUND")
    FloatingBG:SetAllPoints(anchor)

    local addButton = CreateFrame("Button", nil, anchor)
    addButton:SetNormalTexture([[INTERFACE\ADDONS\FARMINGBAR\MEDIA\PLUS]])
    addButton:SetDisabledTexture([[INTERFACE\ADDONS\FARMINGBAR\MEDIA\PLUS-DISABLED]])

    addButton:SetScript("OnClick", addButton_OnClick)

    local removeButton = CreateFrame("Button", nil, anchor)
    removeButton:SetNormalTexture([[INTERFACE\ADDONS\FARMINGBAR\MEDIA\MINUS]])
    removeButton:SetDisabledTexture([[INTERFACE\ADDONS\FARMINGBAR\MEDIA\MINUS-DISABLED]])

    removeButton:SetScript("OnClick", removeButton_OnClick)

    local barID = anchor:CreateFontString(nil, "OVERLAY")
    barID:SetFont([[Fonts\FRIZQT__.TTF]], 12, "NORMAL")

    ------------------------------------------------------------

    local widget = {
        frame = frame,
        backdrop = backdrop,
        anchor = anchor,
        FloatingBG = FloatingBG,
        addButton = addButton,
        removeButton = removeButton,
        barID = barID,
    }

    anchor.widget, addButton.widget, removeButton.widget = widget, widget, widget

    for method, func in pairs(methods) do
        widget[method] = func
    end

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)