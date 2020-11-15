local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

local fmod = math.fmod
local CreateFrame, UIParent = CreateFrame, UIParent

--*------------------------------------------------------------------------

local Type = "FarmingBar_Bar"
local Version = 1
--*------------------------------------------------------------------------

local postClickMethods = {
    openSettings = function(self, ...)
        addon.Config:Load(self.obj:GetUserData("barID"))
    end,
}

--*------------------------------------------------------------------------

local function addButton_OnClick(self)
    local widget = self.obj
    local barDB = widget:GetUserData("barDB")

    if barDB.numVisibleButtons < addon.maxButtons then
        barDB.numVisibleButtons = barDB.numVisibleButtons + 1
        widget:AddButton(barDB.numVisibleButtons)
    end
end

------------------------------------------------------------

local function frame_OnDragStart(self)
    if not self.obj.frame:IsMovable() then return end
    self.obj.frame:StartMoving()
end

------------------------------------------------------------

local function frame_OnDragStop(self)
    if not self.obj.frame:IsMovable() then return end
    local widget = self.obj
    local barDB = widget:GetUserData("barDB")

    widget.frame:StopMovingOrSizing()
    barDB.point = {widget.frame:GetPoint()}
end

------------------------------------------------------------

local function frame_OnEvent(self, event)
    if event == "PLAYER_REGEN_DISABLED" then
        self.obj.addButton:Disable()
        self.obj.removeButton:Disable()
    elseif event == "PLAYER_REGEN_ENABLED" then
        self.obj:SetQuickButtonStates()
    end
end

------------------------------------------------------------

local function anchor_PostClick(self, buttonClicked, ...)
    -- local widget = self.obj
    -- if widget:GetUserData("isDragging") then return end
    -- local cursorType, cursorID = GetCursorInfo()

    -- if cursorType == "item" and not IsModifierKeyDown() and buttonClicked == "LeftButton" then
    --     local objectiveTitle = addon:CreateObjectiveFromCursor()
    --     widget:SetObjectiveID(objectiveTitle)
    --     ClearCursor()
    --     return
    -- elseif addon.DragFrame:IsVisible() then
    --     if addon.moveButton then
    --         widget:SwapButtons(addon.moveButton)
    --     else
    --         widget:SetObjectiveID(addon.DragFrame:GetObjective())
    --     end
    --     addon.DragFrame:Clear()
    --     return
    -- end

    -- ClearCursor()

    ------------------------------------------------------------

    local keybinds = FarmingBar.db.global.keybinds.bar

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

local function removeButton_OnClick(self)
    local widget = self.obj
    local barDB = widget:GetUserData("barDB")

    if barDB.numVisibleButtons > 0 then
        barDB.numVisibleButtons = barDB.numVisibleButtons - 1
        widget:RemoveButton()
    end
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
    OnAcquire = function(self)
        self:SetUserData("buttons", {})
    end,

    ------------------------------------------------------------

    OnRelease = function(self)
        for _, button in pairs(self:GetUserData("buttons")) do
            button:Release()
        end
    end,

    ------------------------------------------------------------

    AddButton = function(self, buttonID)
        local buttons = self:GetUserData("buttons")
        local button = AceGUI:Create("FarmingBar_Button")
        tinsert(buttons, button)

        button:SetUserData("barID", self:GetUserData("barID"))
        button:SetUserData("buttonID", buttonID)

        self:DoLayout()
    end,

    ------------------------------------------------------------

    AnchorButtons = function(self)
        local barDB = self:GetUserData("barDB")
        local buttons = self:GetUserData("buttons")

        local anchor, relativeAnchor, xOffset, yOffset = GetAnchorPoints(barDB.grow[1])

        for key, button in pairs(buttons) do
            button:ClearAllPoints()

            if key == 1 then
                button:SetPoint(anchor, self.frame, relativeAnchor, xOffset * barDB.button.padding, yOffset * barDB.button.padding)
            else
                if fmod(key, barDB.buttonWrap) == 1 or barDB.buttonWrap == 1 then
                    local anchor, relativeAnchor, xOffset, yOffset = GetRelativeAnchorPoints(barDB.grow)
                    button:SetPoint(anchor, buttons[key - barDB.buttonWrap].frame, relativeAnchor, xOffset * barDB.button.padding, yOffset * barDB.button.padding)
                else
                    button:SetPoint(anchor, buttons[key - 1].frame, relativeAnchor, xOffset * barDB.button.padding, yOffset * barDB.button.padding)
                end
            end
        end
    end,

    ------------------------------------------------------------

    ApplySkin = function(self)
        local skin = FarmingBar.db.profile.style.skin
        addon:SkinBar(self, skin)
        for _, button in pairs(self:GetUserData("buttons")) do
            addon:SkinButton(button, skin)
        end
    end,

    ------------------------------------------------------------

    DoLayout = function(self)
        local barDB = self:GetUserData("barDB")
        self:AnchorButtons()
        self:SetAlpha(barDB.alpha)
        self:SetHidden(barDB.hidden)
        self:SetMovable(barDB.movable)
        self:SetScale(barDB.scale)
        self:SetSize(barDB.button.size)
        self:SetPoint(unpack(barDB.point))
        self:SetQuickButtonStates()
        self:ApplySkin()
        self:LoadObjectives()
    end,

    ------------------------------------------------------------

    LoadObjectives = function(self)
        for _, button in pairs(self:GetUserData("buttons")) do
            local objectiveInfo = FarmingBar.db.char.bars[self:GetUserData("barID")].objectives[button:GetUserData("buttonID")]
            if objectiveInfo then
                button:SetObjectiveID(objectiveInfo.objectiveTitle, objectiveInfo.objective)
            else
                button:SetObjectiveID()
            end
        end
    end,

    ------------------------------------------------------------

    RemoveButton = function(self)
        local barDB = self:GetUserData("barDB")
        local buttons = self:GetUserData("buttons")

        buttons[#buttons]:Release()
        tremove(buttons)

        self:DoLayout()
    end,

    ------------------------------------------------------------

    SetAlpha = function(self, alpha)
        self.frame:SetAlpha(alpha)

        local buttons = self:GetUserData("buttons")
        for _, button in pairs(buttons) do
            button.frame:SetAlpha(alpha)
        end
    end,

    ------------------------------------------------------------

    SetBarDB = function(self, barID)
        self:SetUserData("barID", barID)
        self.barID:SetText(barID or "")

        local barDB = FarmingBar.db.char.bars[barID]
        self:SetUserData("barDB", barDB)

        for i = 1, barDB.numVisibleButtons do
            self:AddButton(i)
        end

        self:DoLayout()
    end,

    ------------------------------------------------------------

    SetHidden = function(self, hidden)
        local buttons = self:GetUserData("buttons")
        if hidden then
            self.frame:Hide()
            for _, button in pairs(buttons) do
                button.frame:Hide()
            end
        else
            self.frame:Show()
            for _, button in pairs(buttons) do
                button.frame:Show()
            end
        end
    end,

    ------------------------------------------------------------

    SetMovable = function(self, movable)
        self.frame:SetMovable(movable)
    end,

    ------------------------------------------------------------

    SetPoint = function(self, ...) --point, anchor, relpoint, x, y
        self.frame:ClearAllPoints()
        self.frame:SetPoint(...)
    end,

    ------------------------------------------------------------

    SetQuickButtonStates = function(self)
        local addButton = self.addButton
        local removeButton = self.removeButton
        local numVisibleButtons = self:GetUserData("barDB").numVisibleButtons

        if numVisibleButtons == 0 then
            removeButton:Disable()
            addButton:Enable()
        elseif numVisibleButtons == 1 then
            removeButton:Enable()
        elseif numVisibleButtons == addon.maxButtons then
            addButton:Disable()
            removeButton:Enable()
        elseif numVisibleButtons == addon.maxButtons - 1 then
            addButton:Enable()
        else
            addButton:Enable()
            removeButton:Enable()
        end
    end,

    ------------------------------------------------------------

    SetScale = function(self, scale)
        self.frame:SetScale(scale)

        local buttons = self:GetUserData("buttons")
        for _, button in pairs(buttons) do
            button.frame:SetScale(scale)
        end
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

        local buttons = self:GetUserData("buttons")
        for _, button in pairs(buttons) do
            button:SetSize(self.frame:GetWidth(), self.frame:GetHeight())
        end
    end,
}

--*------------------------------------------------------------------------

local function Constructor()
    local frame = CreateFrame("Frame", Type..AceGUI:GetNextWidgetNum(Type), UIParent)
	frame:Hide()
    frame:SetClampedToScreen(true)

    frame:RegisterEvent("PLAYER_REGEN_ENABLED")
    frame:RegisterEvent("PLAYER_REGEN_DISABLED")

    frame:SetScript("OnEvent", frame_OnEvent)

    local backdrop = CreateFrame("Frame", nil, frame, BackdropTemplateMixin and "BackdropTemplate")
    backdrop:EnableMouse(true)

    local anchor = CreateFrame("Button", "$parentAnchor", frame)
    anchor:SetAllPoints(frame)
    anchor:SetClampedToScreen(true)
    anchor:EnableMouse(true)
    anchor:RegisterForClicks("AnyUp")
    anchor:SetMovable(true)
    anchor:RegisterForDrag("LeftButton")

    anchor:SetScript("OnDragStart", frame_OnDragStart)
    anchor:SetScript("OnDragStop", frame_OnDragStop)
    anchor:SetScript("PostClick", anchor_PostClick)

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
		type  = Type,
        frame = frame,
        backdrop = backdrop,
        anchor = anchor,
        FloatingBG = FloatingBG,
        addButton = addButton,
        removeButton = removeButton,
        barID = barID,
    }

    frame.obj, anchor.obj, addButton.obj, removeButton.obj = widget, widget, widget, widget

    for method, func in pairs(methods) do
        widget[method] = func
    end

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)