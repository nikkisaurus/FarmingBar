local addonName = ...
local addon = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)


-- Optional libraries
local ACD = LibStub("AceConfigDialog-3.0")
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
local LSM = LibStub("LibSharedMedia-3.0")


local Type = "FarmingBar_Bar"
local Version = 2


--*------------------------------------------------------------------------
-- Keybinds


local postClickMethods = {
    configBar = function(self, ...)
        local barID = self.obj:GetBarID()
        ACD:SelectGroup(addonName, "config", "bar"..barID)
        ACD:Open(addonName)
    end,

    toggleMovable = function(self, ...)
        local widget = self.obj
        widget:SetDBValue("movable", "_TOGGLE_")
        widget:SetMovable()

        addon:Print(L.ToggleMovable(widget:GetBarTitle(), widget:GetUserData("barDB").movable))
    end,

    openSettings = function(self, ...)
        ACD:SelectGroup(addonName, "settings")
        ACD:Open(addonName)
    end,

    showObjectiveBuilder = function(self, ...)
        ACD:SelectGroup(addonName, "objectiveBuilder")
        ACD:Open(addonName)
    end,

    openHelp = function(self, ...)
        ACD:SelectGroup(addonName, "help")
        ACD:Open(addonName)
    end,
}


--*------------------------------------------------------------------------
-- Frame methods


local function addButton_OnClick(self)
    local widget = self.obj
    local barDB = widget:GetUserData("barDB")

    if barDB.numVisibleButtons < addon.maxButtons then
        barDB.numVisibleButtons = barDB.numVisibleButtons + 1
        widget:AddButton(barDB.numVisibleButtons)
        addon:RefreshOptions()
    end
end


local function anchor_OnDragStart(self)
    local frame = self.obj.frame
    if not frame:IsMovable() then return end
    frame:StartMoving()
end


local function anchor_OnDragStop(self)
    local widget = self.obj
    local frame = widget.frame
    if not frame:IsMovable() then return end
    frame:StopMovingOrSizing()
    widget:SetDBValue("point", {frame:GetPoint()})
end


local function anchor_OnUpdate(self)
    local widget = self.obj
    local frame = widget.frame
    local barID = widget:GetBarID()
    
    -- Check mouseover
    local focus = GetMouseFocus() and GetMouseFocus():GetName() or ""    
    if strfind(focus, "^FarmingBar_") then
        local focusFrame = _G[focus].obj
        if focusFrame:GetBarID() == barID then
            widget:SetAlpha(focus)
        end
    else
        widget:SetAlpha()
    end
end


local function anchor_PostClick(self, buttonClicked, ...)
    ClearCursor()

    local keybinds = addon:GetDBValue("global", "settings.keybinds.bar")
    for keybind, keybindInfo in pairs(keybinds) do
        if buttonClicked == keybindInfo.button then
            local mod = addon:GetModifierString()

            if mod == keybindInfo.modifier then
                local func = postClickMethods[keybind]
                if func then
                    func(self, keybindInfo, buttonClicked, ...)
                end
            end
        end
    end
end


local function frame_OnEvent(self, event)
    local widget = self.obj
    if event == "PLAYER_REGEN_DISABLED" then
        widget.addButton:Disable()
        widget.removeButton:Disable()
    elseif event == "PLAYER_REGEN_ENABLED" then
        widget:SetQuickButtonStates()
    end
end


local function removeButton_OnClick(self)
    local widget = self.obj
    local barDB = widget:GetUserData("barDB")

    if barDB.numVisibleButtons > 0 then
        barDB.numVisibleButtons = barDB.numVisibleButtons - 1
        widget:RemoveButton()
        addon:RefreshOptions()
    end
end


--*------------------------------------------------------------------------
-- Widget methods


local methods = {
    OnAcquire = function(self)
        self:SetUserData("tooltip", "GetBarTooltip")
        self:SetUserData("buttons", {})
    end,

    OnRelease = function(self)
        if not self:GetUserData("buttons") then return end
        for _, button in pairs(self:GetUserData("buttons")) do
            button:Release()
        end
    end,

    AddButton = function(self, buttonID)
        local button = AceGUI:Create("FarmingBar_Button")
        tinsert(self:GetUserData("buttons"), button)
        button:SetBar(self, buttonID)
        self:SetQuickButtonStates()
    end,

    AnchorButtons = function(self)
        for _, button in pairs(self:GetUserData("buttons")) do
            button:Anchor()
        end
    end,

    ApplySkin = function(self)
        addon:SkinBar(self, addon:GetDBValue("profile", "style.skin"))
    end,

    GetBarID = function(self)
        return self:GetUserData("barID")
    end,

    GetBarDB = function(self)
        return self:GetUserData("barDB")
    end,

    GetBarTitle = function(self)
        return addon:GetBarTitle(self:GetBarID())
    end,

    GetButtons = function(self)
        return self:GetUserData("buttons")
    end,

    RemoveButton = function(self)
        local buttons = self:GetUserData("buttons")

        buttons[#buttons]:Release()
        tremove(buttons)

        self:SetQuickButtonStates()
    end,

    SetAlpha = function(self, focus)
        local anchor = self.anchor
        local frame = self.frame
        local db = self:GetBarDB()

        local mouseoverAnchor = db.anchorMouseover and strfind(focus or "", self.anchor:GetName())
        local mouseover = not db.anchorMouseover and db.mouseover
        local mouseoverFocus = mouseover and focus
        local noMouseover = not db.anchorMouseover and not db.mouseover

        -- Anchor alpha
        if mouseoverAnchor or mouseoverFocus or noMouseover then
            -- Show
            anchor:SetAlpha(db.alpha)
        else
            -- Hide
            anchor:SetAlpha(0)
        end

        local alpha = (mouseover and not focus) and 0 or db.alpha

        frame:SetAlpha(alpha)
        for _, button in pairs(self:GetUserData("buttons")) do
            local showEmpty = db.showEmpty or not button:IsEmpty() or addon.cursorItem
            button:SetAlpha(showEmpty and alpha or 0)
        end
    end,

    SetBarDB = function(self, barID)
        self:SetUserData("barID", barID)
        self.barID:SetText(barID or "")

        local barDB = addon:GetDBValue("profile", "bars")[barID]
        self:SetUserData("barDB", barDB)

        for i = 1, barDB.numVisibleButtons do
            self:AddButton(i)
        end

        self:ApplySkin()
        self:SetAlpha()
        self:SetHidden()
        self:SetMovable()
        self:SetSize()
        self:SetPoint(unpack(barDB.point))
        self:SetQuickButtonStates()
    end,

    SetDBValue = function(self, key, value, isCharDB)
        addon:SetBarDBValue(key, value, self:GetBarID(), isCharDB)
    end,

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

    SetMovable = function(self)
        self.frame:SetMovable(self:GetUserData("barDB").movable)
        addon:RefreshOptions()
    end,

    SetPoint = function(self, ...) --point, anchor, relpoint, x, y
        self.frame:ClearAllPoints()
        self.frame:SetPoint(...)
    end,

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

        -- Update backdrop
        local buttons = self:GetUserData("buttons")
        if buttons and buttons[numVisibleButtons] then
            self:UpdateBackdrop(buttons[numVisibleButtons])
        end
    end,

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


        local fontDB = addon:GetDBValue("profile", "style.font")
        self.barID:SetFont(LSM:Fetch("font", fontDB.face), fontSize, fontDB.outline)
        self.barID:SetPoint("BOTTOM", 0, paddingSize)

        for _, button in pairs(self:GetUserData("buttons")) do
            button:SetSize(frameSize, frameSize)
        end
    end,

    UpdateBackdrop = function(self, lastButton)
        self.backdropTexture:SetTexture(self:GetBarDB().backdrop)

        local backdrop = self.backdrop
        backdrop:ClearAllPoints()

        local numVisibleButtons = self:GetBarDB().numVisibleButtons
        if numVisibleButtons == 0 then return end

        local grow = self:GetBarDB().grow
        local hDirection, vDirection = grow[1], grow[2]        
        local padding = self:GetBarDB().backdropPadding
        local firstButton = self:GetUserData("buttons")[1]
        
        if hDirection == "RIGHT" then
            if vDirection == "NORMAL" then
                backdrop:SetPoint("TOPLEFT", firstButton.frame, "TOPLEFT", -padding, padding)
                backdrop:SetPoint("BOTTOMRIGHT", lastButton.frame, "BOTTOMRIGHT", padding, -padding)
            elseif vDirection == "REVERSE" then
                backdrop:SetPoint("BOTTOMLEFT", firstButton.frame, "BOTTOMLEFT", -padding, -padding)
                backdrop:SetPoint("TOPRIGHT", lastButton.frame, "TOPRIGHT", padding, padding)
            end
        elseif hDirection == "LEFT" then
            if vDirection == "NORMAL" then
                backdrop:SetPoint("TOPRIGHT", firstButton.frame, "TOPRIGHT", padding, padding)
                backdrop:SetPoint("BOTTOMLEFT", lastButton.frame, "BOTTOMLEFT", -padding, -padding)
            elseif vDirection == "REVERSE" then
                backdrop:SetPoint("BOTTOMRIGHT", firstButton.frame, "BOTTOMRIGHT", padding, -padding)
                backdrop:SetPoint("TOPLEFT", lastButton.frame, "TOPLEFT", -padding, padding)
            end
        elseif hDirection == "UP" then
            if vDirection == "NORMAL" then
                backdrop:SetPoint("BOTTOMLEFT", firstButton.frame, "BOTTOMLEFT", -padding, -padding)
                backdrop:SetPoint("TOPRIGHT", lastButton.frame, "TOPRIGHT", padding, padding)
            elseif vDirection == "REVERSE" then
                backdrop:SetPoint("BOTTOMRIGHT", firstButton.frame, "BOTTOMRIGHT", padding, -padding)
                backdrop:SetPoint("TOPLEFT", lastButton.frame, "TOPLEFT", -padding, padding)
            end
        elseif hDirection == "DOWN" then
            if vDirection == "NORMAL" then
                backdrop:SetPoint("TOPLEFT", firstButton.frame, "TOPLEFT", -padding, padding)
                backdrop:SetPoint("BOTTOMRIGHT", lastButton.frame, "BOTTOMRIGHT", padding, -padding)
            elseif vDirection == "REVERSE" then
                backdrop:SetPoint("TOPRIGHT", firstButton.frame, "TOPRIGHT", padding, padding)
                backdrop:SetPoint("BOTTOMLEFT", lastButton.frame, "BOTTOMLEFT", -padding, -padding)
            end
        end
        
    end,

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
-- Constructor


local function Constructor()
    local frame = CreateFrame("Frame", Type..AceGUI:GetNextWidgetNum(Type), UIParent)
    frame:SetScale(UIParent:GetEffectiveScale())
	frame:Hide()
    frame:SetClampedToScreen(true)

    frame:RegisterEvent("PLAYER_REGEN_ENABLED")
    frame:RegisterEvent("PLAYER_REGEN_DISABLED")

    frame:SetScript("OnEvent", frame_OnEvent)

    local backdrop = CreateFrame("Frame", "$parentBackdrop", frame, BackdropTemplateMixin and "BackdropTemplate")
    backdrop:SetFrameStrata("BACKGROUND")
    backdrop:EnableMouse(true)

    local backdropTexture = backdrop:CreateTexture("$parentTexture", "BACKGROUND")
    backdropTexture:SetAllPoints(backdrop)

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
    anchor:SetScript("OnUpdate", anchor_OnUpdate)

    anchor:SetFrameStrata("MEDIUM")

    local FloatingBG = anchor:CreateTexture("$parentFloatingBG", "BACKGROUND")
    FloatingBG:SetAllPoints(anchor)

    local addButton = CreateFrame("Button", "$parentAddButton", anchor)
    addButton:SetNormalTexture([[INTERFACE\ADDONS\FARMINGBAR\MEDIA\PLUS]])
    addButton:SetDisabledTexture([[INTERFACE\ADDONS\FARMINGBAR\MEDIA\PLUS-DISABLED]])

    addButton:SetScript("OnClick", addButton_OnClick)

    local removeButton = CreateFrame("Button", "$parentRemoveButton", anchor)
    removeButton:SetNormalTexture([[INTERFACE\ADDONS\FARMINGBAR\MEDIA\MINUS]])
    removeButton:SetDisabledTexture([[INTERFACE\ADDONS\FARMINGBAR\MEDIA\MINUS-DISABLED]])

    removeButton:SetScript("OnClick", removeButton_OnClick)

    local barID = anchor:CreateFontString("$parentBarIDButton", "OVERLAY")
    barID:SetFont([[Fonts\FRIZQT__.TTF]], 12, "NORMAL")


    local widget = {
		type  = Type,
        frame = frame,
        backdrop = backdrop,
        backdropTexture = backdropTexture,
        anchor = anchor,
        FloatingBG = FloatingBG,
        addButton = addButton,
        removeButton = removeButton,
        barID = barID,
    }

    frame.obj, anchor.obj, addButton.obj, removeButton.obj, backdrop.obj = widget, widget, widget, widget, widget

    for method, func in pairs(methods) do
        widget[method] = func
    end

	return AceGUI:RegisterAsWidget(widget)
end


AceGUI:RegisterWidgetType(Type, Constructor, Version)