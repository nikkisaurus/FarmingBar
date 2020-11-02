local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

local pairs, unpack = pairs, unpack
local strupper = string.upper
local CreateFrame, UIParent = CreateFrame, UIParent

--*------------------------------------------------------------------------

local Type = "FarmingBar_InteractiveLabel"
local Version = 1


--*------------------------------------------------------------------------

local function frame_OnClick(self, button)
	self.obj:Fire("OnClick", button)
	AceGUI:ClearFocus()
end

------------------------------------------------------------

local function frame_OnEnter(self)
    local widget = self.obj
    local highlightColor = widget:GetUserData("highlightColor")
    local iconHighlightColor = widget:GetUserData("iconHighlightColor")
    local tooltip = widget:GetUserData("tooltip")

    if highlightColor then
        widget.text:SetTextColor(unpack(highlightColor))
    end

    if iconHighlightColor then
        widget.icon:SetVertexColor(unpack(iconHighlightColor))
    end

    if tooltip then
        GameTooltip:SetOwner(self, widget:GetUserData("tooltipAnchor") or "ANCHOR_BOTTOMRIGHT", 0, 0)
        tooltip(_, widget, GameTooltip)
        GameTooltip:Show()
    end
end

------------------------------------------------------------

local function frame_OnLeave(self)
    local widget = self.obj
    local tooltip = widget:GetUserData("tooltip")

    if widget:GetUserData("highlightColor") then
        local textColor = widget:GetUserData("textColor") or {1, 1, 1, 1}
        widget.text:SetTextColor(unpack(textColor))
    end

    if widget:GetUserData("iconHighlightColor") then
        local vertexColor = widget:GetUserData("iconColor") or {1, 1, 1, 1}
        widget.icon:SetVertexColor(unpack(vertexColor))
    end

    if tooltip then
        GameTooltip:ClearLines()
        GameTooltip:Hide()
    end
end

--*------------------------------------------------------------------------

local methods = {
    OnAcquire = function(self)
        self:SetWidth(100)
        self:SetHeight(20)
        self:SetWordWrap(true)
        self:SetJustifyH("MIDDLE")
        self:SetIconColor(1, 1, 1, 1)
        self:SetIcon()
        self:SetText("")
    end,

    ------------------------------------------------------------

    AnchorTextures = function(self)
        local frame = self.frame
        local icon = self.icon
        local text = self.text
        local padding = self:GetUserData("padding") or 5
        local hTextOffset = self:GetUserData("hTextOffset") or 0
        local vTextOffset = self:GetUserData("vTextOffset") or 0

        if self:GetUserData("iconVisible") then
            local point = strupper(self:GetUserData("iconPoint"))
            if point == "LEFT" then
                icon:SetPoint("LEFT", padding, 0)
                text:ClearAllPoints()
                text:SetPoint("LEFT", icon, "RIGHT", padding + hTextOffset, vTextOffset)
                text:SetPoint("RIGHT", -padding, 0)
                text:SetJustifyH("LEFT")
            elseif point == "RIGHT" then
                icon:SetPoint("RIGHT", -padding, 0)
                text:ClearAllPoints()
                text:SetPoint("RIGHT", icon, "LEFT", -(padding + hTextOffset), vTextOffset)
                text:SetPoint("LEFT", padding, 0)
                text:SetJustifyH("RIGHT")
            elseif point == "TOP" then
                icon:SetPoint("TOP", 0, -padding)
                text:ClearAllPoints()
                text:SetPoint("TOP", icon, "BOTTOM", hTextOffset, -(padding + vTextOffset))
                text:SetPoint("LEFT", padding, 0)
                text:SetPoint("RIGHT", -padding, 0)
                text:SetJustifyH("MIDDLE")
            elseif point == "BOTTOM" then
                icon:SetPoint("BOTTOM", 0, padding)
                text:ClearAllPoints()
                text:SetPoint("BOTTOM", icon, "TOP", hTextOffset, padding + vTextOffset)
                text:SetPoint("LEFT", padding, 0)
                text:SetPoint("RIGHT", -padding, 0)
                text:SetJustifyH("MIDDLE")
            end
        else
            text:ClearAllPoints()
            text:SetPoint("LEFT", padding, 0)
            text:SetPoint("RIGHT", -padding, 0)
            text:SetJustifyH("MIDDLE")
        end

        self:UpdateWidth()
    end,

    ------------------------------------------------------------

    GetText = function(self)
        return self.text:GetText()
    end,

    ------------------------------------------------------------

    SetAutoWidth = function(self, enabled)
        self:SetUserData("noAutoWidth", not enabled)
    end,

    ------------------------------------------------------------

    SetDisabled = function(self, disabled, texture)
        if disabled then
            self.frame:Disable(true)
            self.text:SetTextColor(.5, .5, .5, 1)
            self.icon:SetVertexColor(.5, .5, .5, 1)
        else
            local textColor = widget:GetUserData("textColor") or {1, 1, 1, 1}
            local vertexColor = widget:GetUserData("iconColor") or {1, 1, 1, 1}

            self.frame:Enable(true)
            self.text:SetTextColor(unpack(textColor))
            self.icon:SetVertexColor(unpack(vertexColor))
        end
    end,

    ------------------------------------------------------------

    SetFont = function(self, font, height, flags)
		self.text:SetFont(font, height, flags)
    end,

    ------------------------------------------------------------

    SetIcon = function(self, iconTexture, point, width, height)
        local icon = self.icon

        icon:ClearAllPoints()

        if iconTexture then
            self:SetUserData("iconVisible", true)
            icon:SetTexture(iconTexture)
            icon:SetSize(width or 15, height or 15)
            icon:Show()
        else
            self:SetUserData("iconVisible", false)
            icon:SetTexture()
            icon:Hide()
        end

        self:SetUserData("iconPoint", point or "LEFT")

        self:AnchorTextures()
    end,

    ------------------------------------------------------------

    SetIconColor = function(self, ...)
        self:SetUserData("iconColor", {...})
        self.icon:SetVertexColor(...)
    end,

    ------------------------------------------------------------

    SetIconHighlightColor = function(self, ...)
        self:SetUserData("iconHighlightColor", {...})
    end,

    ------------------------------------------------------------

    SetIconSize = function(self, width, height)
        self.icon:SetSize(width, height)
    end,

    ------------------------------------------------------------

    SetHighlightTexture = function(self, texture)
        self.frame:SetHighlightTexture(texture)
    end,

    ------------------------------------------------------------

    SetJustifyH = function(self, justify)
        self.text:SetJustifyH(justify)
    end,

    ------------------------------------------------------------

    SetJustifyV = function(self, justify)
        self.text:SetJustifyV(justify)
    end,

    ------------------------------------------------------------

    SetText = function(self, text)
        self.text:SetText(text)
        self:AnchorTextures()
    end,

    ------------------------------------------------------------

    SetTextColor = function(self, ...)
        self:SetUserData("textColor", {...})
        self.text:SetTextColor(...)
    end,

    ------------------------------------------------------------

    SetTextFlags = function(self, flag, value)
        self:SetUserData(flag, value)
        self:AnchorTextures()
    end,

    ------------------------------------------------------------

    SetTextHighlight = function(self, ...)
        self:SetUserData("highlightColor", {...})
    end,

    ------------------------------------------------------------

    SetTooltip = function(self, func, anchor)
        self:SetUserData("tooltip", func)
        self:SetUserData("tooltipAnchor", anchor)
    end,

    ------------------------------------------------------------

    SetWordWrap = function(self, enabled)
        self.text:SetWordWrap(enabled)
    end,

    ------------------------------------------------------------

    UpdateWidth = function(self)
        if not self:GetUserData("noAutoWidth") then
            local padding = self:GetUserData("padding") or 5
            local hTextOffset = self:GetUserData("hTextOffset") or 0

            self:SetWidth(self.text:GetStringWidth() + self.icon:GetWidth() + hTextOffset + (padding * 3))
        end
    end,
}

--*------------------------------------------------------------------------

local function Constructor()
    local frame = CreateFrame("Button", nil, UIParent)
    frame:SetScript("OnClick", frame_OnClick)
    frame:SetScript("OnEnter", frame_OnEnter)
    frame:SetScript("OnLeave", frame_OnLeave)

    local icon = frame:CreateTexture(nil, "ARTWORK")
    local text = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")

    ------------------------------------------------------------

    local widget = {
		type  = Type,
        frame = frame,
        text = text,
        icon = icon,
    }

    frame.obj, text.obj = widget, widget

    for method, func in pairs(methods) do
        widget[method] = func
    end

    ------------------------------------------------------------

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)

