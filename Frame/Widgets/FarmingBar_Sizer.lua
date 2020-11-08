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
    self.obj:StopDragging()
    widget.frame:StopMovingOrSizing()
	widget.frame:SetUserPlaced(false)
    widget.frame:ClearAllPoints()
    widget.parent:DoLayout()
    self.obj:Fire("OnMouseUp", ...)
end

------------------------------------------------------------

local function dragger_OnUpdate(self, ...)
    local widget = self.obj:GetUserData("widget")
    if not widget or not self.obj:GetUserData("isDragging") then return end
    local frame = widget.frame

    local minWidth, minHeight = frame:GetMinResize()
    minWidth = minWidth > 0 and minWidth or (widget:GetUserData("defaultSize")[1] - 1)
    minHeight = minHeight > 0 and minHeight or (widget:GetUserData("defaultSize")[2] - 1)

    ------------------------------------------------------------

    if frame:GetWidth() < minWidth then
        frame:SetWidth(minWidth)
    end

    if frame:GetHeight() < minHeight then
        frame:SetHeight(minHeight)
    end

    ------------------------------------------------------------

    widget.parent:DoLayout()
    self.obj:Fire("OnUpdate", ...)
end

--*------------------------------------------------------------------------

local methods = {
	OnAcquire = function(self)
    end,

    ------------------------------------------------------------

    OnRelease = function(self)
        local widget = self:GetUserData("widget")

        widget:SetUserData("resizePoint")
        if not widget:GetUserData("resizable") then
            widget.frame:SetResizable(false)
        end

        widget:SetUserData("defaultSize")
    end,

    ------------------------------------------------------------

    SetWidget = function(self, widget, resizePoint, defaultSize)
        self:SetUserData("widget", widget)

        widget:SetUserData("resizePoint", resizePoint)
        widget:SetUserData("resizable", widget.frame:IsResizable())
        widget.frame:SetResizable(true)

        -- Prevent overwriting the defaultSize after resizing
        if not widget:GetUserData("defaultSize") then
            widget:SetUserData("defaultSize", defaultSize or {widget.frame:GetWidth(), widget.frame:GetHeight()})
        end
    end,

    ------------------------------------------------------------

    StartDragging = function(self)
        self:SetUserData("isDragging", true)
    end,

    ------------------------------------------------------------

    StopDragging = function(self)
        self:SetUserData("isDragging")
    end,
}

--*------------------------------------------------------------------------

local function Constructor()
    local frame = CreateFrame("Button", nil, frame)
	frame:Hide()

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