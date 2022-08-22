local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)
local AceGUI = LibStub("AceGUI-3.0")
local LSM = LibStub("LibSharedMedia-3.0")

local Type = "FarmingBar_Icon"
local Version = 1

--[[ Scripts ]]
local scripts = {
    OnClick = function(frame, mouseButton)
        frame.obj:Fire("OnClick", mouseButton)
    end,

    OnEnter = function(frame)
        local label = frame.obj:GetLabel()
        if label == "" or label == " " then
            return
        end

        frame.obj:Fire("OnEnter")
    end,

    OnLeave = function(frame)
        frame.obj:Fire("OnLeave")
    end,
}

--[[ Methods ]]
local methods = {
    OnAcquire = function(widget)
        widget:SetWidth(40)
    end,

    GetLabel = function(widget)
        return widget.label:GetText()
    end,

    GetText = function(widget)
        return widget.label:GetText()
    end,

    OnWidthSet = function(widget)
        local frame = widget.frame
        local width = frame:GetWidth()

        frame:SetHeight(width + widget.label:GetHeight())
        widget.icon:SetPoint("BOTTOM", frame, "TOP", 0, -width)
    end,

    SetImage = function(widget, img)
        widget.frame:SetNormalTexture(img)
    end,

    SetImageSize = function(widget, width, height)
        widget.frame:SetSize(width, height)
    end,

    SetLabel = function(widget, txt)
        widget.label:SetText(txt)
    end,

    SetText = function(widget, txt)
        widget.label:SetText(txt)
    end,
}

--[[ Constructor ]]
local function Constructor()
    --[[ Frame ]]
    local frame = CreateFrame("Button", Type .. AceGUI:GetNextWidgetNum(Type), UIParent)
    frame:SetNormalTexture(134400)
    frame:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    frame:EnableMouse()

    for script, func in pairs(scripts) do
        frame:SetScript(script, func)
    end

    local label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetAllPoints(frame)
    label:SetJustifyH("CENTER")
    label:SetJustifyV("BOTTOM")
    label:SetWordWrap()

    --[[ Widget ]]
    local widget = {
        frame = frame,
        label = label,
        icon = frame:GetNormalTexture(),
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
