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
    self:GetNormalTexture():SetVertexColor(1, 1, 1, .05)
end

------------------------------------------------------------

local function dragger_OnMouseDown(self, ...)
    local widget = self.obj:GetUserData("widget")
    if not widget then return end
    local point = widget:GetUserData("resizePoint")
    widget.frame:StartSizing(point)
    self.obj:StartDragging()
    self.obj:Fire("OnMouseDown", ...)
end

------------------------------------------------------------

local function dragger_OnMouseUp(self, ...)
    local widget = self.obj:GetUserData("widget")
    if not widget then return end
    widget.frame:StopMovingOrSizing()
    self.obj:StopDragging()
    self.obj:Fire("OnMouseUp", ...)
end

------------------------------------------------------------

local function dragger_OnUpdate(self, ...)
    local widget = self.obj:GetUserData("widget")
    if not widget or not self.obj:GetUserData("isDragging") then return end
    local frame = widget.frame
    local minWidth, minHeight = frame:GetMinResize()
    minWidth = minWidth > 0 and minWidth or 100
    minHeight = minHeight > 0 and minHeight or 100

    if frame:GetWidth() < minWidth then
        frame:SetWidth(minWidth)
        frame:StopMovingOrSizing()
        self.obj:SetUserData("isDragging", nil)
        self.obj:Fire("OnMouseUp", ...)
    end

    if frame:GetHeight() < minHeight then
        frame:SetHeight(minHeight)
        frame:StopMovingOrSizing()
        self.obj:SetUserData("isDragging", nil)
        self.obj:Fire("OnMouseUp", ...)
    end

    self.obj:Fire("OnUpdate", ...)
end

--*------------------------------------------------------------------------

local methods = {
	OnAcquire = function(self)
    end,

    ------------------------------------------------------------

    OnRelease = function(self)
        local widget = self:GetUserData("widget")
        widget:SetUserData("resizePoint", nil)
        if not widget:GetUserData("resizable") then
            widget.frame:SetResizable(false)
        end
    end,

    ------------------------------------------------------------

    SetWidget = function(self, widget, resizePoint)
        self:SetUserData("widget", widget)
        widget:SetUserData("resizePoint", resizePoint)
        widget:SetUserData("resizable", widget.frame:IsResizable())
        widget.frame:SetResizable(true)
    end,

    ------------------------------------------------------------

    StartDragging = function(self)
        self:SetUserData("isDragging", true)
        self.frame:GetNormalTexture():SetVertexColor(1, 1, 1, 0)
    end,

    ------------------------------------------------------------

    StopDragging = function(self)
        self:SetUserData("isDragging", nil)
        self.frame:GetNormalTexture():SetVertexColor(1, 1, 1, .05)
    end,
}

--*------------------------------------------------------------------------

local function Constructor()
    local frame = CreateFrame("Button", nil, frame)

    frame:SetNormalTexture(130871)
    frame:GetNormalTexture():SetVertexColor(1, 1, 1, .05)

    frame:SetScript("OnEnter", dragger_OnEnter)
    frame:SetScript("OnLeave", dragger_OnLeave)
    frame:SetScript("OnMouseDown", dragger_OnMouseDown)
    frame:SetScript("OnMouseUp", dragger_OnMouseUp)
    frame:SetScript("OnUpdate", dragger_OnUpdate)

    ------------------------------------------------------------

	local widget = {
		type = Type,
		frame = frame,
    }

	for method, func in pairs(methods) do
		widget[method] = func
    end

    frame.obj = widget

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)