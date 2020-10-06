local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)
local db = FarmingBar.db

--*------------------------------------------------------------------------

--[[-----------------------------------------------------------------------------
Button Widget
Graphical Button.
-------------------------------------------------------------------------------]]
local Type, Version = "FB30_ObjectiveButton", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

-- Lua APIs
local pairs, tinsert = pairs, table.insert

-- WoW APIs
local _G = _G
local PlaySound, CreateFrame, UIParent = PlaySound, CreateFrame, UIParent

--[[-----------------------------------------------------------------------------
Scripts
-------------------------------------------------------------------------------]]
local function Button_OnClick(frame, ...)
    frame.obj:ToggleSelected()

	AceGUI:ClearFocus()
	PlaySound(852) -- SOUNDKIT.IG_MAINMENU_OPTION
	frame.obj:Fire("OnClick", ...)
end

local function Control_OnEnter(frame)
	frame.obj:Fire("OnEnter")
end

local function Control_OnLeave(frame)
	frame.obj:Fire("OnLeave")
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local methods = {
	["OnAcquire"] = function(self)
		-- restore default values
		self:SetHeight(35)
		self:SetWidth(200)
		self:SetDisabled(false)
		self:SetAutoWidth(false)
		self:SetText()
	end,

	-- ["OnRelease"] = nil,

	["SetText"] = function(self, text)
		self.text:SetText(text)
		if self.autoWidth then
			self:SetWidth(self.text:GetStringWidth() + 30)
		end
	end,

	["SetAutoWidth"] = function(self, autoWidth)
		self.autoWidth = autoWidth
		if self.autoWidth then
			self:SetWidth(self.text:GetStringWidth() + 30)
		end
	end,

	["SetDisabled"] = function(self, disabled)
		self.disabled = disabled
		if disabled then
			self.frame:Disable()
		else
			self.frame:Enable()
		end
    end,

    SetIcon = function(self, icon)
        self.icon:SetTexture(icon or 134400)
    end,

    SetStatusTable = function(self, statustable)
        self.status = statustable
        tinsert(self.status, self)
    end,

    GetStatusTable = function(self)
        return self.status
    end,

    ToggleSelected = function(self)
        local statustable = self:GetStatusTable()

        if statustable then
            if IsShiftKeyDown() then
                local first, target
                for key, objective in pairs(statustable) do
                    if objective.lastSelected then
                        first = key
                    elseif objective == self then
                        target = key
                    end
                    if first and target then
                        local offset = (first < target) and 1 or -1
                        for i = first + offset, target - offset, offset do
                            statustable[i]:SetSelected(true)
                        end
                        break
                    end
                end
            elseif not IsControlKeyDown() then
                for key, objective in pairs(statustable) do
                    objective:SetSelected(false)
                    objective.lastSelected = false
                end
            end
        end

        self:SetSelected(self.selected and false or true)
        self.lastSelected = true
    end,

    SetSelected = function(self, selected)
        self.selected = selected
        self:SetHighlight(selected)
    end,

    SetHighlight = function(self, selected)
        if selected then
            self.frame:LockHighlight()
        else
            self.frame:UnlockHighlight()
        end
    end,
}

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]
local function Constructor()
	local name = "AceGUI30Button" .. AceGUI:GetNextWidgetNum(Type)
    local frame = CreateFrame("Button", name, UIParent, "OptionsListButtonTemplate")
    frame:SetHeight(35)
	frame:SetWidth(200)
	frame:Hide()

	frame:EnableMouse(true)
	frame:SetScript("OnClick", Button_OnClick)
	frame:SetScript("OnEnter", Control_OnEnter)
    frame:SetScript("OnLeave", Control_OnLeave)
    frame:SetPushedTextOffset(0, 0)

    local background = frame:CreateTexture(nil, "BACKGROUND")
    background:SetTexture("Interface\\BUTTONS\\UI-LISTBOX-HIGHLIGHT2")
    background:SetBlendMode("ADD")
    background:SetVertexColor(0.4, 0.4, 0.4, 0.25)
    background:SetAllPoints(frame)

    local icon = frame:CreateTexture(nil, "OVERLAY")
    icon:SetWidth(25)
    icon:SetHeight(25)
    icon:SetPoint("LEFT", frame, "LEFT", 3, 0)
    icon:SetTexture(134400)

	local text = frame:GetFontString()
	text:ClearAllPoints()
    text:SetPoint("TOPLEFT", icon, "TOPRIGHT", 3, -1)
    text:SetPoint("RIGHT", -3, 0)
    text:SetJustifyH("LEFT")

    frame:GetHighlightTexture():SetVertexColor(0.5, 0.5, 0.5, .5)

	local widget = {
		text  = text,
		frame = frame,
        type  = Type,
        icon = icon,
        background = background,
	}
	for method, func in pairs(methods) do
		widget[method] = func
    end

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)