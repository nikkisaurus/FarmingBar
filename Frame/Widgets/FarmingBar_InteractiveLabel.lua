local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

local max, min = math.max, math.min
local pairs, unpack = pairs, unpack
local strupper = string.upper
local CreateFrame, UIParent = CreateFrame, UIParent

--*------------------------------------------------------------------------

-- Similar to AceGUI InteractiveLabel
-- Automatically sizes widget to fit text
-- Flexibility to position icon where you want, instead of based on the text
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

------------------------------------------------------------

local function frame_OnReceiveDrag(self)
	self.obj:Fire("OnReceiveDrag")
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
        -- !
        -- !
        -- !

        -- TODO: Need to fix vertical and horizontal offset
        -- For point LEFT, both offsets seem okay

        -- !
        -- !
        -- !
        local frame = self.frame
        local icon = self.icon
        local text = self.text

        local padding = self:GetUserData("padding") or 5
        local hTextOffset = self:GetUserData("hTextOffset") or 0
        local hOffset = padding + hTextOffset
        local vTextOffset = self:GetUserData("vTextOffset") or 0
        local vOffset = padding + vTextOffset

        local vResize = not self:GetUserData("noAutoHeight")
        local hResize = not self:GetUserData("noAutoWidth")

        if self:GetUserData("iconVisible") then
            local point = strupper(self:GetUserData("iconPoint"))
            local isHorizontal = point == "LEFT" or point == "RIGHT"
            local isLeft = point == "LEFT"
            local isBottom = point == "BOTTOM"

            icon:SetPoint(point, (isLeft or isBottom) and padding or -padding)
            text:ClearAllPoints()
            text:SetJustifyH(isHorizontal and point or "MIDDLE")

            if hResize then
                local defaultWidth = self.icon:GetWidth() + text:GetWidth() + hTextOffset + (padding * 3)
                if defaultWidth > frame:GetWidth() then
                    self:SetWidth(defaultWidth)
                else
                    self:SetWidth(min(defaultWidth, frame:GetWidth()))
                end
            end

            if isHorizontal then
                local relPoint = isLeft and "RIGHT" or "LEFT"
                text:SetPoint(point, icon, relPoint, isLeft and hOffset or -hOffset, 0)
                text:SetPoint(relPoint, isLeft and -padding or padding, 0)

                if vResize then
                    -- ! Not sure that it's resizing how I want with the vOffset
                    local defaultHeight = text:GetHeight() + (padding * 2) + vOffset
                    if defaultHeight > frame:GetHeight() then
                        self:SetHeight(defaultHeight)
                        icon:SetPoint("TOP", 0, -padding)
                    else
                        self:SetHeight(max(defaultHeight, icon:GetHeight() + (padding * 2)))
                    end
                end

                text:SetPoint("TOP", icon, "TOP", 0, -vTextOffset)
                text:SetPoint("BOTTOM", 0, padding)
            else
                text:SetPoint("LEFT", padding, 0)
                text:SetPoint("RIGHT", -padding, 0)

                if vResize then
                    if text:GetHeight() > frame:GetHeight() then
                        self:SetHeight(icon:GetHeight() + text:GetHeight() + ((padding + vTextOffset) * 2))
                    else
                        self:SetHeight(max(text:GetHeight(), icon:GetHeight()) + ((padding + vTextOffset) * 2))
                    end
                end

                icon:SetPoint("TOP", 0, vOffset - padding)
                text:SetPoint(point, 0, -(icon:GetHeight() + (padding * 2)) - vOffset)
                text:SetPoint(isBottom and "TOP" or "BOTTOM", 0, isBottom and -padding or padding)
                -- text:SetPoint(point, icon, isBottom and "TOP" or "BOTTOM", 0, isBottom and vOffset or -vOffset)
                -- text:SetPoint(isBottom and "TOP" or "BOTTOM", 0, isBottom and -padding or padding)
            end
        else
            text:ClearAllPoints()
            text:SetJustifyH("MIDDLE")

            if text:GetHeight() > frame:GetHeight() and vResize then
                self:SetHeight(text:GetHeight() + ((padding + vTextOffset) * 2))
            end

            text:SetPoint("LEFT", padding, 0)
            text:SetPoint("RIGHT", -padding, 0)
        end
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

    SetAutoHeight = function(self, enabled)
        self:SetUserData("noAutoHeight", not enabled)
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

    SetFontObject = function(self, fontObj)
		self.text:SetFontObject(fontObj)
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

    SetOffsetH = function(self, offset)
        self:SetUserData("hTextOffset", offset)
        self:AnchorTextures()
    end,

    ------------------------------------------------------------

    SetOffsetV = function(self, offset)
        self:SetUserData("vTextOffset", offset)
        self:AnchorTextures()
    end,

    ------------------------------------------------------------

    SetText = function(self, text)
        self.text:SetText(text)
        self:AnchorTextures()
        if self.text:GetText() then
            self:SetHeight(self.frame:GetHeight())
        end
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
}

--*------------------------------------------------------------------------

local function Constructor()
    local frame = CreateFrame("Button", nil, UIParent)
	frame:Hide()
    frame:SetScript("OnClick", frame_OnClick)
    frame:SetScript("OnEnter", frame_OnEnter)
    frame:SetScript("OnLeave", frame_OnLeave)
	frame:SetScript("OnReceiveDrag", frame_OnReceiveDrag)

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

