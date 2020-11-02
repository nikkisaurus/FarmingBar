local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

local CreateFrame, UIParent = CreateFrame, UIParent

--*------------------------------------------------------------------------

local Type = "FarmingBar_Sidebar"
local Version = 1

--*------------------------------------------------------------------------

local function frame_OnUpdate(self)
    -- If we don't call this when dragging, the frame won't resize unless the parent has been resized first
    self.widget.parent:DoLayout()
end

------------------------------------------------------------

local function dragger_OnEnter(self)
    self:GetNormalTexture():SetVertexColor(1, 1, 1, .25)
end

------------------------------------------------------------

local function dragger_OnLeave(self)
    self:GetNormalTexture():SetVertexColor(1, 1, 1, 0)
end

------------------------------------------------------------

local function dragger_OnMouseDown(self)
    local frame = self.widget.frame
    frame:StartSizing("RIGHT")
    frame:SetScript("OnUpdate", frame_OnUpdate)
end

------------------------------------------------------------

local function dragger_OnMouseUp(self)
    local frame = self.widget.frame
    frame:StopMovingOrSizing()
    frame:SetScript("OnUpdate", nil)

    -- If we don't do this, the sidebar doesn't stay anchored correctly to its parent when the parent is resized
	frame:SetUserPlaced(false)
	frame:ClearAllPoints()
	frame:SetPoint("TOPLEFT", self.widget.parent.type == "FarmingBar_SimpleGroup" and 0 or 5, 0)

    local relWidth = frame:GetWidth() / self.widget.parent.content:GetWidth()
    self.widget:SetRelativeWidth(relWidth > 1 and 1 or relWidth)
end

--*------------------------------------------------------------------------

local methods = {
    OnAcquire = function(self)
        self:SetRelativeWidth(1/3)
    end,

    OnWidthSet = function(self, width)
        local contentWidth = self.parent.content:GetWidth()
        local frame = self.frame
        frame:SetMinResize(contentWidth / 4, 1)
        frame:SetMaxResize(contentWidth / 1.9, 1600)

        if self.parent:GetUserData("columnRatio") then
            self.parent:SetUserData("columnRatio", {frame:GetWidth(), contentWidth - frame:GetWidth()})
        end
    end,
}

--*------------------------------------------------------------------------

local function Constructor()
    local frame = CreateFrame("Frame", nil, UIParent)
    frame:SetResizable(true)

    ------------------------------------------------------------

    local dragger = CreateFrame("Button", nil, frame)
    dragger:SetPoint("TOPRIGHT", -5, -5)
    dragger:SetPoint("BOTTOMLEFT", frame, "BOTTOMRIGHT", -12, 5)

    dragger:SetNormalTexture(130871)
    dragger:GetNormalTexture():SetVertexColor(1, 1, 1, 0)

    dragger:SetScript("OnEnter", dragger_OnEnter)
    dragger:SetScript("OnLeave", dragger_OnLeave)
    dragger:SetScript("OnMouseDown", dragger_OnMouseDown)
    dragger:SetScript("OnMouseUp", dragger_OnMouseUp)

    ------------------------------------------------------------

    local background = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    background:SetPoint("TOPLEFT")
    background:SetPoint("BOTTOMRIGHT", dragger, "BOTTOMLEFT", 0, -5)

    addon:SetPanelBackdrop(background)

    ------------------------------------------------------------

    local content = CreateFrame("Frame", nil, background)
    content:SetPoint("TOPLEFT", 10, -10)
    content:SetPoint("BOTTOMRIGHT", -10, 10)

    ------------------------------------------------------------

    if IsAddOnLoaded("ElvUI") then
        local E = unpack(_G["ElvUI"])
        local S = E:GetModule('Skins')

        background:StripTextures()
        background:SetTemplate("Transparent")
    end

    ------------------------------------------------------------

    local widget = {
		type  = Type,
        frame = frame,
        content = content,
    }

    frame.widget, dragger.widget = widget, widget
    frame.obj = widget

    for method, func in pairs(methods) do
        widget[method] = func
    end

    ------------------------------------------------------------

	return AceGUI:RegisterAsContainer(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)

