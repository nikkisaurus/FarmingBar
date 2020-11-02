local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

local CreateFrame, UIParent = CreateFrame, UIParent

--*------------------------------------------------------------------------

local Type = "FarmingBar_Sizer"
local Version = 1

--*------------------------------------------------------------------------

local function dragger_OnEnter(self)
    self:GetNormalTexture():SetVertexColor(1, 1, 1, .25)
end

------------------------------------------------------------

local function dragger_OnLeave(self)
    self:GetNormalTexture():SetVertexColor(1, 1, 1, 0)
end

------------------------------------------------------------

local function dragger_OnMouseDown(self)
    local widget = self.widget:GetUserData("widget")
    if not widget then return end
    widget.frame:SetResizable(true)
    widget.frame:StartSizing("RIGHT")
    self:SetScript("OnUpdate", function(self)
        widget:SetUserData("relWidth", widget.frame:GetWidth() / widget.parent.frame:GetWidth())
        widget.parent:DoLayout()
    end)
end

------------------------------------------------------------

local function dragger_OnMouseUp(self)
    local widget = self.widget:GetUserData("widget")
    if not widget then return end
    widget.frame:StopMovingOrSizing()
    widget.frame:SetResizable(false)
    self:SetScript("OnUpdate", nil)
    widget.parent:DoLayout()
end


--*------------------------------------------------------------------------

local methods = {
	OnAcquire = function(self)
    end,

    SetWidget = function(self, widget)
        self:SetUserData("widget", widget)
    end,
}

--*------------------------------------------------------------------------

local function Constructor()
    local frame = CreateFrame("Button", nil, frame)

    frame:SetNormalTexture(130871)
    frame:GetNormalTexture():SetVertexColor(1, 1, 1, 0)

    frame:SetScript("OnEnter", dragger_OnEnter)
    frame:SetScript("OnLeave", dragger_OnLeave)
    frame:SetScript("OnMouseDown", dragger_OnMouseDown)
    frame:SetScript("OnMouseUp", dragger_OnMouseUp)

    ------------------------------------------------------------

	local widget = {
		type = Type,
		frame = frame,
    }

	for method, func in pairs(methods) do
		widget[method] = func
    end

    frame.widget = widget

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
