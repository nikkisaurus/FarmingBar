local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

local CreateFrame, UIParent = CreateFrame, UIParent

--*------------------------------------------------------------------------

local Type = "FarmingBar_SearchBox"
local Version = 1

--*------------------------------------------------------------------------

local methods = {
    OnAcquire = function(self)
    end,
}

--*------------------------------------------------------------------------

local function Constructor()
    local frame = CreateFrame("EditBox", nil, UIParent, "SearchBoxTemplate")
    frame:SetAutoFocus(false)
    frame:SetHeight(19)

    ------------------------------------------------------------

    if IsAddOnLoaded("ElvUI") then
        local E = unpack(_G["ElvUI"])
        local S = E:GetModule('Skins')

        S:HandleEditBox(frame)
    end

    ------------------------------------------------------------

    local widget = {
		type  = Type,
        frame = frame,
    }

    frame.widget = widget

    for method, func in pairs(methods) do
        widget[method] = func
    end

    ------------------------------------------------------------

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)

