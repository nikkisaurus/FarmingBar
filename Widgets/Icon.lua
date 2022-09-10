local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)
local AceGUI = LibStub("AceGUI-3.0")
local LSM = LibStub("LibSharedMedia-3.0")

local Type = "FarmingBar_Icon"
local Version = 1

local scripts = {
    OnClick = function(button, mouseButton)
        button.obj:Fire("OnClick", mouseButton)
    end,

    OnEnter = function(button)
        local label = button.obj:GetLabel()
        if label == "" or label == " " then
            return
        end

        button.obj:Fire("OnEnter")
    end,

    OnLeave = function(frame)
        frame.obj:Fire("OnLeave")
    end,
}

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

    OnWidthSet = function(widget, width)
        widget:SetHeight(width + widget.label:GetHeight())
        widget.button:SetSize(width, width)
        widget.label:SetWidth(width)
    end,

    SetImage = function(widget, img)
        widget.button:SetNormalTexture(img)
    end,

    SetImageSize = function(widget, width, height)
        widget.frame:SetSize(width, height)
    end,

    SetLabel = function(widget, label)
        widget.label:SetText(label)
    end,

    SetText = function(widget, label)
        widget.label:SetText(label)
    end,
}

local function Constructor()
    --[[ Frame ]]
    local frame = CreateFrame("Frame", Type .. AceGUI:GetNextWidgetNum(Type), UIParent)
    local button = CreateFrame("Button", "$parentIcon", frame)
    button:SetPoint("TOP")
    button:SetNormalTexture(134400)
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button:EnableMouse()

    for script, func in pairs(scripts) do
        button:SetScript(script, func)
    end

    local label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("BOTTOM")
    label:SetJustifyH("CENTER")
    label:SetJustifyV("BOTTOM")
    label:SetWordWrap()

    --[[ Widget ]]
    local widget = {
        frame = frame,
        button = button,
        label = label,
        type = Type,
    }

    frame.obj = widget
    button.obj = widget

    for method, func in pairs(methods) do
        widget[method] = func
    end

    AceGUI:RegisterAsWidget(widget)

    return widget
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
