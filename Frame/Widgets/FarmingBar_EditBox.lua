local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

local _G = _G
local tostring, pairs = tostring, pairs
local GetCursorInfo, ClearCursor, GetSpellInfo, PlaySound = GetCursorInfo, ClearCursor, GetSpellInfo, PlaySound
local CreateFrame, UIParent = CreateFrame, UIParent

-- Global vars/functions that we don't upvalue since they might get hooked, or upgraded
-- List them here for Mikk's FindGlobals script
-- GLOBALS: AceGUIEditBoxInsertLink, ChatFontNormal, OKAY

--*------------------------------------------------------------------------

-- Based on AceGUI EditBox v28
-- Allows callback for OnEscapePressed
-- Modifies _G.AceGUIEditBoxInsertLink to enable replacing editbox contents with link instead of inserting
local Type = "FarmingBar_EditBox"
local Version = 1

--*------------------------------------------------------------------------

local function HideButton(self)
	self.button:Hide()
	self.editbox:SetTextInsets(0, 0, 3, 3)
end

------------------------------------------------------------

local function EditBox_OnEnterPressed(frame)
	local self = frame.obj
	local value = frame:GetText()
	local cancel = self:Fire("OnEnterPressed", value)
	if not cancel then
		PlaySound(856) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON
		HideButton(self)
	end
end

--*------------------------------------------------------------------------

if not AceGUIEditBoxInsertLink then
	-- upgradeable hook
	hooksecurefunc("ChatEdit_InsertLink", function(...) return _G.AceGUIEditBoxInsertLink(...) end)
end

------------------------------------------------------------

function _G.AceGUIEditBoxInsertLink(text)
	for i = 1, AceGUI:GetWidgetCount(Type) do
		local editbox = _G[Type..i]
        if editbox and editbox:IsVisible() and editbox:HasFocus() then
            if editbox.obj:GetUserData("setLink") then
                editbox:SetText(text)
                EditBox_OnEnterPressed(editbox)
            else
                editbox:Insert(text)
            end
			return true
		end
	end
end

--*------------------------------------------------------------------------

local function ShowButton(self)
	if not self.disablebutton then
		self.button:Show()
		self.editbox:SetTextInsets(0, 20, 3, 3)
	end
end

--*------------------------------------------------------------------------

local function Button_OnClick(frame)
	local editbox = frame.obj.editbox
	editbox:ClearFocus()
	EditBox_OnEnterPressed(editbox)
end

------------------------------------------------------------

local function Control_OnEnter(frame)
	frame.obj:Fire("OnEnter")
end

------------------------------------------------------------

local function Control_OnLeave(frame)
	frame.obj:Fire("OnLeave")
end

------------------------------------------------------------

local function EditBox_OnEscapePressed(frame)
	AceGUI:ClearFocus()
	frame.obj:Fire("OnEscapePressed")
end

------------------------------------------------------------

local function EditBox_OnFocusGained(frame)
	AceGUI:SetFocus(frame.obj)
end

------------------------------------------------------------

local function EditBox_OnReceiveDrag(frame)
	local self = frame.obj
	local type, id, info = GetCursorInfo()
	local name
	if type == "item" then
		name = info
	elseif type == "spell" then
		name = GetSpellInfo(id, info)
	elseif type == "macro" then
		name = GetMacroInfo(id)
	end
    if name then
		self:SetText(name)
		self:Fire("OnEnterPressed", name)
		ClearCursor()
		HideButton(self)
        AceGUI:ClearFocus()

        C_Timer.After(.01, function()
            frame:ClearFocus()
        end)
    end
end

------------------------------------------------------------

local function EditBox_OnTextChanged(frame)
	local self = frame.obj
	local value = frame:GetText()
	if tostring(value) ~= tostring(self.lasttext) then
		self:Fire("OnTextChanged", value)
		self.lasttext = value
		ShowButton(self)
	end
end

------------------------------------------------------------

local function Frame_OnShowFocus(frame)
	frame.obj.editbox:SetFocus()
	frame:SetScript("OnShow", nil)
end

--*------------------------------------------------------------------------

local methods = {
	OnAcquire = function(self)
		-- height is controlled by SetLabel
		self:SetWidth(200)
		self:SetDisabled(false)
		self:SetLabel()
		self:SetText()
		self:DisableButton(false)
		self:SetMaxLetters(0)
	end,

    ------------------------------------------------------------

	OnRelease = function(self)
		self:ClearFocus()
	end,

    ------------------------------------------------------------

	ClearFocus = function(self)
		self.editbox:ClearFocus()
		self.frame:SetScript("OnShow", nil)
	end,

    ------------------------------------------------------------

	DisableButton = function(self, disabled)
		self.disablebutton = disabled
		if disabled then
			HideButton(self)
		end
	end,

    ------------------------------------------------------------

	GetText = function(self, text)
		return self.editbox:GetText()
	end,

    ------------------------------------------------------------

	HighlightText = function(self, from, to)
		self.editbox:HighlightText(from, to)
	end,

    ------------------------------------------------------------

	SetDisabled = function(self, disabled)
		self.disabled = disabled
		if disabled then
			self.editbox:EnableMouse(false)
			self.editbox:ClearFocus()
			self.editbox:SetTextColor(0.5,0.5,0.5)
			self.label:SetTextColor(0.5,0.5,0.5)
		else
			self.editbox:EnableMouse(true)
			self.editbox:SetTextColor(1,1,1)
			self.label:SetTextColor(1,.82,0)
		end
	end,

    ------------------------------------------------------------

	SetFocus = function(self)
		self.editbox:SetFocus()
		if not self.frame:IsShown() then
			self.frame:SetScript("OnShow", Frame_OnShowFocus)
		end
	end,

    ------------------------------------------------------------

	SetLabel = function(self, text)
		if text and text ~= "" then
			self.label:SetText(text)
			self.label:Show()
			self.editbox:SetPoint("TOPLEFT",self.frame,"TOPLEFT",7,-18)
			self:SetHeight(44)
			self.alignoffset = 30
		else
			self.label:SetText("")
			self.label:Hide()
			self.editbox:SetPoint("TOPLEFT",self.frame,"TOPLEFT",7,0)
			self:SetHeight(26)
			self.alignoffset = 12
		end
    end,

    ------------------------------------------------------------

    SetLink = function(self, enabled)
        self:SetUserData("setLink", enabled)
    end,

    ------------------------------------------------------------

	SetMaxLetters = function (self, num)
		self.editbox:SetMaxLetters(num or 0)
    end,

    ------------------------------------------------------------

	SetText = function(self, text)
		self.lasttext = text or ""
		self.editbox:SetText(text or "")
		self.editbox:SetCursorPosition(0)
		HideButton(self)
	end,
}

--*------------------------------------------------------------------------

local function Constructor()
	local frame = CreateFrame("Frame", nil, UIParent)
	frame:Hide()

	local editbox = CreateFrame("EditBox", Type..AceGUI:GetNextWidgetNum(Type), frame, "InputBoxTemplate")
	editbox:SetAutoFocus(false)
	editbox:SetFontObject(ChatFontNormal)
	editbox:SetTextInsets(0, 0, 3, 3)
	editbox:SetMaxLetters(256)
	editbox:SetPoint("BOTTOMLEFT", 0, 0)
	editbox:SetPoint("BOTTOMRIGHT")
    editbox:SetHeight(19)

	editbox:SetScript("OnEnter", Control_OnEnter)
	editbox:SetScript("OnLeave", Control_OnLeave)
	editbox:SetScript("OnEscapePressed", EditBox_OnEscapePressed)
	editbox:SetScript("OnEnterPressed", EditBox_OnEnterPressed)
	editbox:SetScript("OnTextChanged", EditBox_OnTextChanged)
	editbox:SetScript("OnReceiveDrag", EditBox_OnReceiveDrag)
	editbox:SetScript("OnMouseDown", EditBox_OnReceiveDrag)
	editbox:SetScript("OnEditFocusGained", EditBox_OnFocusGained)

    ------------------------------------------------------------

	local label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	label:SetPoint("TOPLEFT", 0, -2)
	label:SetPoint("TOPRIGHT", 0, -2)
	label:SetJustifyH("LEFT")
	label:SetHeight(18)

    ------------------------------------------------------------

	local button = CreateFrame("Button", nil, editbox, "UIPanelButtonTemplate")
	button:SetWidth(40)
	button:SetHeight(20)
	button:SetPoint("RIGHT", -2, 0)
	button:SetText(OKAY)
	button:SetScript("OnClick", Button_OnClick)
	button:Hide()

    ------------------------------------------------------------

    if IsAddOnLoaded("ElvUI") then
        local E = unpack(_G["ElvUI"])
        local S = E:GetModule('Skins')

        S:HandleEditBox(editbox)
        S:HandleButton(button)
    end

    ------------------------------------------------------------

	local widget = {
		alignoffset = 30,
		editbox     = editbox,
		label       = label,
		button      = button,
		frame       = frame,
		type        = Type
    }

	for method, func in pairs(methods) do
		widget[method] = func
    end

	editbox.obj, button.obj = widget, widget

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
