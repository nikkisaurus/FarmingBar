local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)
local AceGUI = LibStub("AceGUI-3.0")
local LSM = LibStub("LibSharedMedia-3.0")

local Type = "FarmingBar_Button"
local Version = 1

--[[ PostClick Methods ]]
local postClickMethods = {
    onUse = function(frame)
        local widget = frame.obj
        if widget:IsEmpty() then -- TODO: or not action item
            return
        end
    end,
    clearObjective = function(frame)
        frame.obj:Clear()
    end,
    moveObjective = function(frame)
        local widget = frame.obj
        if not widget:IsEmpty() then
            local _, buttonDB = widget:GetDB()
            private.ObjectiveFrame:LoadObjective(buttonDB)
            private.ObjectiveFrame:SetAltWidget(widget)
        end
    end,
}

-- [[ Scripts ]]
local scripts = {
    PostClick = function(frame, buttonClicked, ...)
        local widget = frame.obj
        local barID, buttonID = widget:GetID()
        local cursorType, itemID = GetCursorInfo()
        local isEmpty = widget:IsEmpty()
        local objectiveInfo, altWidget = private.ObjectiveFrame:GetObjective()

        if objectiveInfo then
            if altWidget then
                if not isEmpty then
                    local _, buttonDB = widget:GetDB()
                    altWidget:SetObjectiveInfo(addon.CloneTable(buttonDB))
                else
                    altWidget:Clear()
                end
            end

            widget:SetObjectiveInfo(addon.CloneTable(objectiveInfo))
            private.ObjectiveFrame:Clear()

            return
        elseif cursorType == "item" and itemID then
            private.CacheItem(itemID)

            local template = addon.CloneTable(private.defaults.objective)
            template.icon.id = GetItemIcon(itemID)
            template.onUse.type = "ITEM"
            template.onUse.itemID = itemID

            local tracker = addon.CloneTable(private.defaults.tracker)
            tracker.type = "ITEM"
            tracker.id = itemID
            tinsert(template.trackers, tracker)

            widget:SetObjectiveInfo(template)
            ClearCursor()

            return
        end

        for keybind, keybindInfo in pairs(private.db.global.settings.keybinds) do
            if buttonClicked == keybindInfo.button then
                local mod = private:GetModifierString()

                if mod == keybindInfo.modifier then
                    local func = postClickMethods[keybind]
                    if func then
                        func(frame, keybindInfo, buttonClicked, ...)
                    end
                end
            end
        end
    end,

    OnEnter = function(frame, ...)
        local bar = frame.obj:GetBar()
        bar:CallScript("OnEnter", bar.frame, ...)
    end,

    OnLeave = function(frame, ...)
        local bar = frame.obj:GetBar()
        bar:CallScript("OnLeave", bar.frame, ...)
    end,
}

--[[ Methods ]]
local methods = {
    --[[ Widget ]]
    OnAcquire = function(widget)
        widget:Show()
    end,

    --[[ Frame ]]
    Hide = function(widget)
        widget.frame:Hide()
    end,

    SetAlpha = function(widget, alpha)
        widget.frame:SetAlpha(alpha)
    end,

    SetAttributes = function(widget)
        local info = private.db.global.settings.keybinds.onUse
        local buttonType = (info.modifier ~= "" and (info.modifier .. "-") or "")
            .. "type"
            .. (info.button == "RightButton" and 2 or 1)
        local isEmpty = widget:IsEmpty()
        local _, buttonDB = widget:GetDB()

        if not isEmpty and widget.frame:GetAttribute(buttonType) == "macro" and buttonDB.onUse.type == "MACROTEXT" then
            if widget.frame:GetAttribute("macrotext") == buttonDB.onUse.macrotext then
                return
            end
        elseif not isEmpty and widget.frame:GetAttribute(buttonType) == "item" and buttonDB.onUse.type == "ITEM" then
            if widget.frame:GetAttribute("item") == ("item" .. buttonDB.onUse.itemID) then
                return
            end
        end

        widget.frame:SetAttribute(buttonType, nil)
        widget.frame:SetAttribute("item", nil)
        widget.frame:SetAttribute("macrotext", nil)

        if isEmpty then
            return
        end

        if UnitAffectingCombat("player") then
            return
        end

        if buttonDB.onUse.type == "ITEM" and buttonDB.onUse.itemID then
            widget.frame:SetAttribute(buttonType, "item")
            widget.frame:SetAttribute("item", "item:" .. buttonDB.onUse.itemID)
        elseif buttonDB.onUse.type == "MACROTEXT" then
            widget.frame:SetAttribute(buttonType, "macro")
            widget.frame:SetAttribute("macrotext", buttonDB.onUse.macrotext)
        end
    end,

    SetHeight = function(widget, height)
        widget.frame:SetHeight(height)
    end,

    SetPoint = function(widget, ...)
        widget.frame:SetPoint(...)
    end,

    SetSize = function(widget, width, height)
        widget:SetWidth(width)
        widget:SetHeight(height or width)
    end,

    SetWidth = function(widget, width)
        widget.frame:SetWidth(width)
    end,

    Show = function(widget)
        widget.frame:Show()
    end,

    --[[ Fontstrings ]]
    SetCount = function(widget)
        widget.count:SetText(20) -- TODO
    end,

    SetObjective = function(widget, objective)
        if widget:IsEmpty() or not objective or objective == 0 then
            widget.objective:SetText()
            widget.objective:Hide()
        else
            widget.objective:SetText(objective)
            widget.objective:Show()
        end
    end,

    SetFontstrings = function(widget)
        local barDB, buttonDB = widget:GetDB()
        local isEmpty = widget:IsEmpty()

        for fontName, fontDB in pairs(barDB.fontstrings) do
            local fontstring = widget[strlower(fontName)]
            fontstring = fontstring.SetFont and fontstring or fontstring:GetRegions()

            fontstring:ClearAllPoints()

            if fontDB.enabled and not isEmpty then
                fontstring:Show()
                fontstring:SetPoint(fontDB.anchor, fontDB.x, fontDB.y)
                fontstring:SetFont(LSM:Fetch("font", fontDB.face), fontDB.size, fontDB.outline)
                fontstring:SetTextColor(unpack(fontDB.color))
            else
                fontstring:Hide()
            end
        end
    end,

    --[[ Textures ]]
    SetTextures = function(widget)
        local barDB = widget:GetDB()

        for layerName, textureInfo in pairs(barDB.buttonTextures) do
            local layer = widget[layerName]
            local texture = LSM:Fetch(LSM.MediaType.BACKGROUND, textureInfo.texture)

            layer:ClearAllPoints()

            if private.MSQ and not private.MSQ.button.db.Disabled then
                layer:SetTexture()
                layer:SetVertexColor(1, 1, 1, 1)
                layer:SetTexCoord(0, 1, 0, 1)
                layer:SetAllPoints(widget.frame)
                layer:Show()

                private.MSQ.button:AddButton(widget.frame)
                private.MSQ.button:ReSkin(true)
            else
                layer:SetTexture(texture)
                layer:SetVertexColor(addon.unpack(textureInfo.color, { 1, 1, 1, 1 }))
                layer:SetTexCoord(addon.unpack(textureInfo.texCoords, { 0, 1, 0, 1 }))
                layer:SetBlendMode(textureInfo.blendMode)
                layer:SetDrawLayer(textureInfo.drawLayer, textureInfo.layer)

                if textureInfo.hidden then
                    layer:Hide()
                else
                    layer:Show()
                end

                if textureInfo.insets then
                    layer:SetPoint("LEFT", textureInfo.insets.left, 0)
                    layer:SetPoint("RIGHT", textureInfo.insets.right, 0)
                    layer:SetPoint("TOP", 0, textureInfo.insets.top)
                    layer:SetPoint("BOTTOM", 0, textureInfo.insets.bottom)
                else
                    layer:SetAllPoints(widget.frame)
                end
            end
        end
    end,

    SetIconTextures = function(widget)
        local barDB, buttonDB = widget:GetDB()
        local isEmpty = widget:IsEmpty()

        if isEmpty then
            widget.icon:SetTexture()
            widget.iconBorder:Hide()
        else
            local icon, color = private:GetObjectiveIcon(buttonDB)
            widget.icon:SetTexture(icon)
            if not barDB.buttonTextures.iconBorder.hidden and color then
                widget.iconBorder:Show()
                widget.iconBorder:SetVertexColor(unpack(color))
            else
                widget.iconBorder:Hide()
            end
        end
    end,

    --[[ Database ]]
    Clear = function(widget)
        local barID, buttonID = widget:GetID()
        private.db.profile.bars[barID].buttons[buttonID] = nil
        widget:UpdateAttributes()
    end,

    GetBar = function(widget)
        return private.bars[widget:GetID()]
    end,

    GetDB = function(widget)
        local barID, buttonID = widget:GetID()
        local barDB = private.db.profile.bars[barID]

        return barDB, barDB.buttons[buttonID]
    end,

    GetID = function(widget)
        return widget:GetUserData("barID"), widget:GetUserData("buttonID")
    end,

    IsEmpty = function(widget)
        local barDB, buttonDB = widget:GetDB()
        return not buttonDB, buttonDB
    end,

    SetID = function(widget, barID, buttonID)
        if widget:GetID() then
            if private.db.global.debug.enabled then
                error(format(L["Button is already assigned an ID: %d:%d"], widget:GetID()))
            end
            return
        end

        widget:SetUserData("barID", barID)
        widget:SetUserData("buttonID", buttonID)
        widget:Update()
    end,

    SetObjectiveInfo = function(widget, objectiveInfo)
        local barID, buttonID = widget:GetID()
        private.db.profile.bars[barID].buttons[buttonID] = objectiveInfo
        widget:UpdateAttributes()
    end,

    Update = function(widget)
        widget:DrawButton()
        widget:SetTextures()
        widget:UpdateAttributes()
    end,

    UpdateAttributes = function(widget)
        widget:SetIconTextures()
        widget:SetAttributes()
        widget:SetFontstrings()
        widget:SetCount()
        widget:SetObjective()
    end,

    --[[ Button ]]
    DrawButton = function(widget)
        local barDB, buttonDB = widget:GetDB()
        widget:SetSize(barDB.buttonSize)
    end,
}

--[[ Constructor ]]
local function Constructor()
    --[[ Frame ]]
    local frame = CreateFrame(
        "Button",
        Type .. AceGUI:GetNextWidgetNum(Type),
        UIParent,
        "BackdropTemplate, SecureActionButtonTemplate"
    )
    frame:SetFrameStrata("MEDIUM")
    frame:SetFrameLevel(1)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("AnyUp")
    frame:RegisterForClicks("AnyUp")

    local backdrop = frame:CreateTexture("$parentBackdrop")
    local cooldown = CreateFrame("Cooldown", "$parentCooldown", frame, "CooldownFrameTemplate")
    local count = frame:CreateFontString("$parentCount", "OVERLAY", "GameFontHighlight")
    local gloss = frame:CreateTexture("$parentGloss")
    local highlight = frame:CreateTexture("$parentHighlight")
    local icon = frame:CreateTexture("$parentIcon")
    local iconBorder = frame:CreateTexture("$parentIconBorder")
    local mask = frame:CreateTexture("$parentMask")
    local normal = frame:CreateTexture("$parentNormal")
    local objective = frame:CreateFontString("$parentObjective", "OVERLAY", "GameFontHighlight")
    local pushed = frame:CreateTexture("$parentPushed")
    local shadow = frame:CreateTexture("$parentShadow")

    for script, func in pairs(scripts) do
        frame:SetScript(script, func)
    end

    --[[ Widget ]]
    local widget = {
        frame = frame,
        backdrop = backdrop,
        cooldown = cooldown,
        count = count,
        gloss = gloss,
        highlight = highlight,
        icon = icon,
        iconBorder = iconBorder,
        mask = mask,
        normal = normal,
        objective = objective,
        pushed = pushed,
        shadow = shadow,
        type = Type,
    }

    frame.obj = widget

    for method, func in pairs(methods) do
        widget[method] = func
    end

    AceGUI:RegisterAsWidget(widget)

    return widget
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
