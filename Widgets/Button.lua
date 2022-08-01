local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)
local AceGUI = LibStub("AceGUI-3.0")

local Type = "FarmingBar_Button"
local Version = 1

-- [[ Scripts ]]
local scripts = {
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
        widget:SetBackdrop()
        widget:SetSize(private.defaults.bar.buttonSize)
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

    --[[ Backdrop ]]
    SetBackdrop = function(widget, backdropInfo, bgColor, borderColor)
        widget.frame:SetBackdrop(backdropInfo or private.defaults.bar.buttonBackdrop.bgFile)
        widget.frame:SetBackdropColor(addon.unpack(bgColor, private.defaults.bar.buttonBackdrop.bgColor))
        widget.frame:SetBackdropBorderColor(addon.unpack(borderColor, private.defaults.bar.buttonBackdrop.borderColor))
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

    SetID = function(widget, barID, buttonID)
        if widget:GetID() then
            if private.db.global.debug.enabled then
                error(format(L["Button is already assigned an ID: %d:%d"], widget:GetID()))
            end
            return
        end

        widget:SetUserData("barID", barID)
        widget:SetUserData("buttonID", buttonID)
        widget:DrawButton()
    end,

    --[[ Button ]]
    DrawButton = function(widget)
        local barDB, buttonDB = widget:GetDB()
        widget:SetSize(barDB.buttonSize)

        -- ! Temporary for layout visualization; remove when done:
        widget.count:SetText(select(2, widget:GetID()))
    end,
}

--[[ Constructor ]]
local function Constructor()
    --[[ Frame ]]
    local frame = CreateFrame("Frame", Type .. AceGUI:GetNextWidgetNum(Type), UIParent, "BackdropTemplate")
    frame:SetFrameStrata("MEDIUM")
    frame:SetFrameLevel(1)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")

    local count = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    count:SetPoint("CENTER")

    for script, func in pairs(scripts) do
        frame:SetScript(script, func)
    end

    --[[ Widget ]]
    local widget = {
        frame = frame,
        count = count,
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
