local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

local CreateFrame, UIParent = CreateFrame, UIParent

--*------------------------------------------------------------------------

local Type = "FarmingBar_TreeGroup"
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
    self.widget.treeFrame:StartSizing("RIGHT")
end

------------------------------------------------------------

local function dragger_OnMouseUp(self)
    local treeFrame = self.widget.treeFrame
    treeFrame:StopMovingOrSizing()
	treeFrame:ClearAllPoints()
	treeFrame:SetPoint("TOPLEFT")
    treeFrame:SetPoint("BOTTOMLEFT")
    self.widget:SetUserData("treeWidthOffset", treeFrame:GetWidth() - (self.widget.frame:GetWidth() / 3))
end

--*------------------------------------------------------------------------

local methods = {
    OnAcquire = function(self)
        AceGUI.WidgetContainerBase.AddChild(self, self.contentScrollFrame)
        self.frame:SetSize(300, 300)
        self:SetUserData("treeWidthOffset", 0)
    end,

    AddChild = function(self, child)
        self.contentScrollFrame:AddChild(child)
    end,

    OnWidthSet = function(self, width)
        local frame = self.frame
        local treeFrame = self.treeFrame

        local defaultTreeWidth = (width - 5) / 3
        local minTreeWidth = (width - 5) / 4
        local maxTreeWidth = (width - 5) / 2

        local treeWidth = defaultTreeWidth + self:GetUserData("treeWidthOffset")
        treeWidth = treeWidth < minTreeWidth and minTreeWidth or treeWidth
        treeWidth = treeWidth > maxTreeWidth and maxTreeWidth or treeWidth

        treeFrame:SetMinResize(minTreeWidth, 1)
        treeFrame:SetMaxResize(maxTreeWidth, 1600)

        treeFrame:SetWidth(treeWidth)

		local content = self.content
		content.width = width - (self.scrollBarShown and 20 or 0)
		content.original_width = width
    end,
}

--*------------------------------------------------------------------------

local function Constructor()
    local frame = CreateFrame("Frame", nil, UIParent)

    ------------------------------------------------------------

    local treeFrame = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    treeFrame:SetPoint("TOPLEFT", frame, "TOPLEFT")
    treeFrame:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT")
    treeFrame:SetResizable(true)

    addon:SetPanelBackdrop(treeFrame)

    ------------------------------------------------------------

    local treeScrollFrame = AceGUI:Create("ScrollFrame")
    treeScrollFrame:SetLayout("Flow")

    ------------------------------------------------------------

    local contentBG = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    contentBG:SetPoint("TOPLEFT", treeFrame, "TOPRIGHT", 3, 0)
    contentBG:SetPoint("BOTTOMRIGHT")

    addon:SetPanelBackdrop(contentBG)

    ------------------------------------------------------------

    local content = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    content:SetPoint("TOPLEFT", contentBG, "TOPLEFT", 10, -10)
    content:SetPoint("BOTTOMRIGHT", contentBG, "BOTTOMRIGHT", -10, 10)

    ------------------------------------------------------------

    local contentScrollFrame = AceGUI:Create("ScrollFrame")
    contentScrollFrame:SetLayout("Flow")

    ------------------------------------------------------------

    local dragger = CreateFrame("Button", nil, frame)
    dragger:SetPoint("TOPLEFT", treeFrame, "TOPRIGHT", 0, -5)
    dragger:SetPoint("BOTTOMRIGHT", contentBG, "BOTTOMLEFT", 0, 5)

    dragger:SetNormalTexture(130871)
    dragger:GetNormalTexture():SetVertexColor(1, 1, 1, 0)

    dragger:SetScript("OnEnter", dragger_OnEnter)
    dragger:SetScript("OnLeave", dragger_OnLeave)
    dragger:SetScript("OnMouseDown", dragger_OnMouseDown)
    dragger:SetScript("OnMouseUp", dragger_OnMouseUp)

    ------------------------------------------------------------

    if IsAddOnLoaded("ElvUI") then
        local E = unpack(_G["ElvUI"])
        local S = E:GetModule('Skins')

        content:StripTextures()
        content:SetTemplate("Transparent")

        treeFrame:StripTextures()
        treeFrame:SetTemplate("Transparent")
    end

    ------------------------------------------------------------

    local widget = {
		type  = Type,
        frame = frame,
        treeFrame = treeFrame,
        treeScrollFrame = treeScrollFrame,
        content = content,
        contentScrollFrame = contentScrollFrame,
    }

    frame.widget, dragger.widget = widget, widget

    for method, func in pairs(methods) do
        widget[method] = func
    end

    ------------------------------------------------------------

	return AceGUI:RegisterAsContainer(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)

