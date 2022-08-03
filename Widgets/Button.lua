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
        print("COW")
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
            layer:SetTexture(texture)
            layer:SetVertexColor(unpack(textureInfo.color))
            layer:SetTexCoord(unpack(textureInfo.texCoords))
            layer:SetBlendMode(textureInfo.blendMode)

            if textureInfo.insets then
                layer:SetPoint("LEFT", textureInfo.insets.left, 0)
                layer:SetPoint("RIGHT", textureInfo.insets.right, 0)
                layer:SetPoint("TOP", 0, textureInfo.insets.top)
                layer:SetPoint("BOTTOM", 0, textureInfo.insets.bottom)
            else
                layer:SetAllPoints(widget.frame)
            end
        end
    end,

    SetIconTextures = function(widget)
        local isEmpty, buttonDB = widget:IsEmpty()

        if isEmpty then
            widget.icon:SetTexture()
            widget.iconBorder:Hide()
        else
            widget.icon:SetTexture(buttonDB.iconID)
            widget.iconBorder:Show()
            widget.iconBorder:SetVertexColor(GetItemQualityColor(buttonDB.itemQuality))
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
        widget:SetIconTextures()
    end,

    --[[ Button ]]
    DrawButton = function(widget)
        local barDB, buttonDB = widget:GetDB()
        widget:SetSize(barDB.buttonSize)
    end,

    SetCount = function(widget)
    end,
}

--[[ Constructor ]]
local function Constructor()
    --[[ Frame ]]
    local frame = CreateFrame("Button", Type .. AceGUI:GetNextWidgetNum(Type), UIParent,
        "BackdropTemplate, SecureActionButtonTemplate")
    frame:SetFrameStrata("MEDIUM")
    frame:SetFrameLevel(1)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")

    local backdrop = frame:CreateTexture()
    backdrop:SetDrawLayer("BACKGROUND", -1)

    -- -- local Cooldown

    local count = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")

    local gloss = frame:CreateTexture()
    gloss:SetDrawLayer("OVERLAY", 0)

    local icon = frame:CreateTexture()
    icon:SetDrawLayer("BACKGROUND", 0)

    local iconBorder = frame:CreateTexture()
    iconBorder:SetDrawLayer("OVERLAY", 1)

    local mask = frame:CreateTexture()

    local normal = frame:CreateTexture()
    normal:SetDrawLayer("ARTWORK", 0)

    local shadow = frame:CreateTexture()
    shadow:SetDrawLayer("ARTWORK", -1)

    local highlight = frame:CreateTexture()
    highlight:SetDrawLayer("HIGHLIGHT", 0)

    local pushed = frame:CreateTexture()
    pushed:SetDrawLayer("ARTWORK", 0)

    for script, func in pairs(scripts) do
        frame:SetScript(script, func)
    end

    --[[ Widget ]]
    local widget = {
        frame = frame,
        count = count,
        backdrop = backdrop,
        gloss = gloss,
        icon = icon,
        iconBorder = iconBorder,
        mask = mask,
        normal = normal,
        shadow = shadow,
        highlight = highlight,
        pushed = pushed,
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
