local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)
local AceGUI = LibStub("AceGUI-3.0")
local LSM = LibStub("LibSharedMedia-3.0")

local Type = "FarmingBar_Button"
local Version = 1

-- [[ Scripts ]]
local scripts = {
    OnClick = function(frame)
        local cursorType, itemID = GetCursorInfo()

        if private.ObjectiveFrame:GetObjective() then
            print("place objective template")
        elseif cursorType == "item" and itemID then
            print("place item")
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

        widget:SetIconTextures()
    end,

    SetIconTextures = function(widget)
        local barDB, buttonDB = widget:GetDB()
        local isEmpty = widget:IsEmpty()

        if isEmpty then
            widget.icon:SetTexture()
            widget.iconBorder:Hide()
        else
            -- local itemID = buttonDB.icon.action
            -- private:CacheItem(itemID)
            -- local _, _, rarity, _, _, _, _, _, _, icon = GetItemInfo(itemID)

            -- widget.icon:SetTexture(icon)
            -- if not barDB.buttonTextures.iconBorder.hidden then
            --     widget.iconBorder:Show()
            -- end
            -- widget.iconBorder:SetVertexColor(GetItemQualityColor(rarity))
        end
    end,

    --[[ Database ]]
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

    Update = function(widget)
        widget:DrawButton()
        widget:SetTextures()
    end,

    --[[ Button ]]
    DrawButton = function(widget)
        local barDB, buttonDB = widget:GetDB()
        widget:SetSize(barDB.buttonSize)
    end,

    SetCount = function(widget) end,
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
    frame:RegisterForDrag("LeftButton")

    local backdrop = frame:CreateTexture("$parentBackdrop")
    -- -- local cooldown
    local count = frame:CreateFontString("$parentCount", "OVERLAY", "GameFontHighlight")
    local gloss = frame:CreateTexture("$parentGloss")
    local highlight = frame:CreateTexture("$parentHighlight")
    local icon = frame:CreateTexture("$parentIcon")
    local iconBorder = frame:CreateTexture("$parentIconBorder")
    local mask = frame:CreateTexture("$parentMask")
    local normal = frame:CreateTexture("$parentNormal")
    local pushed = frame:CreateTexture("$parentPushed")
    local shadow = frame:CreateTexture("$parentShadow")

    for script, func in pairs(scripts) do
        frame:SetScript(script, func)
    end

    --[[ Widget ]]
    local widget = {
        frame = frame,
        backdrop = backdrop,
        -- cooldown = cooldown,
        count = count,
        gloss = gloss,
        highlight = highlight,
        icon = icon,
        iconBorder = iconBorder,
        mask = mask,
        normal = normal,
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
