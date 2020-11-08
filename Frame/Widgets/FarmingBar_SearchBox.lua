local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

local CreateFrame, UIParent = CreateFrame, UIParent

--*------------------------------------------------------------------------

local Type = "FarmingBar_SearchBox"
local Version = 1

--*------------------------------------------------------------------------

local function frame_OnEscapePressed(self, ...)
    self.obj:Fire("OnEscapePressed", ...)
    self:SetText("")
    self:ClearFocus()
end

------------------------------------------------------------

local function frame_OnTextChanged(self, ...)
    self.obj:Fire("OnTextChanged", ...)
end

--*------------------------------------------------------------------------

local methods = {
    OnAcquire = function(self)
        self:SetText("")
    end,

    GetText = function(self)
        return self.frame:GetText()
    end,

    SetText = function(self, text)
        self.frame:SetText(text)
    end,
}

--*------------------------------------------------------------------------

local function Constructor()
    local frame = CreateFrame("EditBox", nil, UIParent, "SearchBoxTemplate")
	frame:Hide()
    frame:SetHeight(19)
    frame:SetAutoFocus(false)
    frame:SetMaxLetters(256)

    frame:SetScript("OnEscapePressed", frame_OnEscapePressed)
    frame:HookScript("OnTextChanged", frame_OnTextChanged)

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

    frame.obj = widget

    for method, func in pairs(methods) do
        widget[method] = func
    end

    ------------------------------------------------------------

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)