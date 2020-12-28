local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
local ACD = LibStub("AceConfigDialog-3.0")
local LSM = LibStub("LibSharedMedia-3.0")

local abs, fmod = math.abs, math.fmod
local CreateFrame, UIParent = CreateFrame, UIParent

--*------------------------------------------------------------------------

local Type = "FarmingBar_Bar"
local Version = 1

--*------------------------------------------------------------------------

local postClickMethods = {
    configBar = function(self, ...)
        local barID = self.obj:GetBarID()
        ACD:SelectGroup(addonName, "config", "bar"..barID)
        ACD:Open(addonName)
    end,

    ------------------------------------------------------------

    toggleMovable = function(self, ...)
        local widget = self.obj
        local barID = widget:GetBarID()

        addon:SetBarDBInfo("movable", "_TOGGLE_", barID)
        widget:SetMovable()
        FarmingBar:Print(L.ToggleMovable(addon:GetBarTitle(barID), widget:GetUserData("barDB").movable))
    end,

    ------------------------------------------------------------

    openSettings = function(self, ...)
        ACD:SelectGroup(addonName, "settings")
        ACD:Open(addonName)
    end,

    ------------------------------------------------------------

    openHelp = function(self, ...)
        ACD:SelectGroup(addonName, "help")
        ACD:Open(addonName)
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

local function anchor_OnDragStart(self)
    if not self.obj.frame:IsMovable() then return end
    self.obj.frame:StartMoving()
end

------------------------------------------------------------

local function anchor_OnDragStop(self)
    if not self.obj.frame:IsMovable() then return end
    local widget = self.obj
    local barDB = widget:GetUserData("barDB")

    widget.frame:StopMovingOrSizing()
    barDB.point = {widget.frame:GetPoint()}
end

------------------------------------------------------------

local function anchor_PostClick(self, buttonClicked, ...)
    ClearCursor()

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

local function frame_OnEvent(self, event)
    if event == "PLAYER_REGEN_DISABLED" then
        self.obj.addButton:Disable()
        self.obj.removeButton:Disable()
    elseif event == "PLAYER_REGEN_ENABLED" then
        self.obj:SetQuickButtonStates()
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

local methods = {
    OnAcquire = function(self)
        self:SetUserData("tooltip", "GetBarTooltip")
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
        local button = AceGUI:Create("FarmingBar_Button")
        tinsert(self:GetUserData("buttons"), button)
        button:SetBar(self, buttonID)
        self:SetQuickButtonStates()
    end,

    ------------------------------------------------------------

    AnchorButtons = function(self)
        for _, button in pairs(self:GetUserData("buttons")) do
            button:Anchor()
        end
    end,

    ------------------------------------------------------------

    ApplySkin = function(self)
        addon:SkinBar(self, FarmingBar.db.profile.style.skin)
    end,

    ------------------------------------------------------------

    GetBarID = function(self)
        return self:GetUserData("barID")
    end,

    ------------------------------------------------------------

    RemoveButton = function(self)
        local barDB = self:GetUserData("barDB")
        local buttons = self:GetUserData("buttons")

        buttons[#buttons]:Release()
        tremove(buttons)

        self:SetQuickButtonStates()
    end,

    ------------------------------------------------------------

    SetAlpha = function(self)
        self.frame:SetAlpha(self:GetUserData("barDB").alpha)
        for _, button in pairs(self:GetUserData("buttons")) do
            button:SetAlpha()
        end
    end,

    ------------------------------------------------------------

    SetBarDB = function(self, barID)
        self:SetUserData("barID", barID)
        self.barID:SetText(barID or "")

        ------------------------------------------------------------

        local barDB = FarmingBar.db.profile.bars[barID]
        self:SetUserData("barDB", barDB)

        ------------------------------------------------------------

        for i = 1, barDB.numVisibleButtons do
            self:AddButton(i)
        end

        ------------------------------------------------------------

        self:ApplySkin()
        self:SetAlpha()
        self:SetHidden()
        self:SetMovable()
        self:SetScale()
        self:SetSize()
        self:SetPoint(unpack(barDB.point))
        self:SetQuickButtonStates()
    end,

    ------------------------------------------------------------

    SetHidden = function(self)
        if self:GetUserData("barDB").hidden then
            self.frame:Hide()
        else
            self.frame:Show()
        end

        for _, button in pairs(self:GetUserData("buttons")) do
            button:SetHidden()
        end
    end,

    ------------------------------------------------------------

    SetMovable = function(self)
        self.frame:SetMovable(self:GetUserData("barDB").movable)
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

    SetScale = function(self)
        self.frame:SetScale(self:GetUserData("barDB").scale)
        for _, button in pairs(self:GetUserData("buttons")) do
            button:SetScale()
        end
    end,

    ------------------------------------------------------------

    SetSize = function(self)
        local frameSize = self:GetUserData("barDB").button.size
        local paddingSize = (2/20 * frameSize)
        local buttonSize = ((frameSize - (paddingSize * 3)) / 2) * .9
        local fontSize = frameSize / 3

        self.frame:SetSize(frameSize * .9, frameSize * .9)

        self.addButton:SetSize(buttonSize, buttonSize)
        self.addButton:SetPoint("TOPLEFT", paddingSize, -paddingSize)

        self.removeButton:SetSize(buttonSize, buttonSize)
        self.removeButton:SetPoint("TOPRIGHT", -paddingSize, -paddingSize)


        local fontDB = FarmingBar.db.profile.style.font
        self.barID:SetFont(LSM:Fetch("font", fontDB.face), fontSize, fontDB.outline)
        self.barID:SetPoint("BOTTOM", 0, paddingSize)

        for _, button in pairs(self:GetUserData("buttons")) do
            button:SetSize(frameSize, frameSize)
        end
    end,

    ------------------------------------------------------------

    UpdateVisibleButtons = function(self)
        local buttons = self:GetUserData("buttons")
        local difference = self:GetUserData("barDB").numVisibleButtons - #buttons

        if difference > 0 then
            for i = 1, difference do
                self:AddButton(#buttons + 1)
            end
        elseif difference < 0 then
            for i = 1, abs(difference) do
                self:RemoveButton()
            end
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

    anchor:SetScript("OnDragStart", anchor_OnDragStart)
    anchor:SetScript("OnDragStop", anchor_OnDragStop)
    anchor:SetScript("PostClick", anchor_PostClick)

    anchor:SetFrameStrata("MEDIUM")

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