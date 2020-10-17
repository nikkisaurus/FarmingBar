local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)
local db = FarmingBar.db

--*------------------------------------------------------------------------

local Type, Version = "FB30_ObjectiveButton", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

local pairs, tinsert, tremove, wipe = pairs, table.insert, table.remove, table.wipe

local PlaySound, CreateFrame, UIParent, EasyMenu = PlaySound, CreateFrame, UIParent, EasyMenu

--*------------------------------------------------------------------------

local function Button_OnClick(frame, ...)
    local buttonClicked = (select(1, ...))

    local loadPrevious = frame.obj:ToggleSelected(buttonClicked == "RightButton")

    if not loadPrevious then
        AceGUI:ClearFocus()
        PlaySound(852) -- SOUNDKIT.IG_MAINMENU_OPTION
        frame.obj:Fire("OnClick", ...)
    else
        frame.obj.statustable.selected[#frame.obj.statustable.selected].frame.obj:Fire("OnClick", ...)
    end

    if buttonClicked == "RightButton" then
        addon.MenuFrame = addon.MenuFrame or CreateFrame("Frame", "FarmingBarMenuFrame", UIParent, "UIDropDownMenuTemplate")
        EasyMenu(frame.obj:GetMenu(), addon.MenuFrame, frame, 0, 0, "MENU")
    end
end

local function Control_OnEnter(frame)
    if frame.obj.tooltip then
        GameTooltip:SetOwner(frame, "ANCHOR_BOTTOMRIGHT", 0, 0)
        frame.obj:tooltip(GameTooltip)
        GameTooltip:Show()
    end
end

local function Control_OnLeave(frame)
    if frame.obj.tooltip then
        GameTooltip:ClearLines()
        GameTooltip:Hide()
    end
end

local function Control_OnDragStart(frame)
	frame.obj:Fire("OnDragStart")
end

local function Control_OnDragStop(frame)
	frame.obj:Fire("OnDragStop")
end

local function EditBox_OnEscapePressed(frame)
	frame:ClearFocus()
    frame:Hide()
end

local function EditBox_OnEnterPressed(frame)
    addon:RenameObjective(frame.obj:GetObjectiveTitle(), frame:GetText())
    frame:Hide()

    local statustable = frame.obj.statustable.children
    if not statustable then return end
    for _, objective in pairs(statustable) do
        local editbox = objective.button.editbox
        if editbox:IsVisible() then
            editbox:SetFocus()
            editbox:HighlightText()
        end
    end
end

local function EditBox_OnHide(frame)
	AceGUI:ClearFocus()
    frame.obj.text:Show()
end

local function EditBox_OnShow(frame)
    frame.obj.text:Hide()
    frame:SetText(frame.obj:GetObjectiveTitle())
    frame:SetFocus()
    frame:HighlightText()
end

--*------------------------------------------------------------------------

local methods = {
	["OnAcquire"] = function(self)
		-- restore default values
		self:SetHeight(35)
		self:SetWidth(200)
		self:SetDisabled(false)
		self:SetIcon()
		self:SetMenuFunc()
		self:SetSelected(false)
		self:SetAutoWidth(false)
		self:SetText()
	end,

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

    ------------------------------------------------------------

    ["CacheSelected"] = function(self, selectedButton)
        local selected = self.statustable and self.statustable.selected
        if not selected then return end

        for _, objective in pairs(selected) do
            if objective == selectedButton then
                return
            end
        end

        tinsert(selected, selectedButton)
    end,

    ["GetMenu"] = function(self)
        return self.menuFunc()
    end,

    ["GetObjectiveTitle"] = function(self)
        return self.frame:GetText()
    end,

    ["RenameObjective"] = function(self)
        self.text:Hide()
        self.editbox:Show()
    end,

    ["SetStatus"] = function(self, statustable)
        self.statustable = statustable
        self.statustable.selected = statustable.selected or {}
        self.statustable.children = statustable.children or {}
    end,

    ["SetHighlight"] = function(self, selected)
        if selected then
            self.frame:LockHighlight()
        else
            self.frame:UnlockHighlight()
        end
    end,

    ["SetIcon"] = function(self, icon)
        self.icon:SetTexture(icon or 134400)
    end,

    ["SetMenuFunc"] = function(self, menuFunc)
        self.menuFunc = menuFunc
    end,

    ["SetSelected"] = function(self, selected)
        self.selected = selected
        self:SetHighlight(selected)
    end,

    ["SetTooltip"] = function(self, tooltip)
        self.tooltip = tooltip
    end,

    ["ToggleSelected"] = function(self, openedContext)
        local statustable = self.statustable and self.statustable.children
        local selected = self.statustable and self.statustable.selected

        if statustable then
            if IsShiftKeyDown() then
                local first, target

                for key, objective in pairs(statustable) do
                    if objective.button == selected[#selected] then
                        first = key
                    elseif objective.button == self then
                        target = key
                    end
                end

                if first and target then
                    local offset = (first < target) and 1 or -1
                    for i = first + offset, target - offset, offset do
                        statustable[i].button:SetSelected(true)
                        self:CacheSelected(statustable[i].button)
                    end
                end
            elseif IsControlKeyDown() then
                local key = addon.GetTableKey(selected, self)
                if key and #selected > 1 and not openedContext then
                    self:SetSelected(false)
                    tremove(selected, key)
                    return true -- trigger to load the last selected button
                end
            elseif not openedContext or not self.selected then
                for key, objective in pairs(statustable) do
                    objective.button:SetSelected(false)
                end
                wipe(selected)
            end
        end

        self:SetSelected(self.selected and false or true)
        if selected and self.selected then
            self:CacheSelected(self)
        end
    end,
}

--*------------------------------------------------------------------------

local function Constructor()
	local name = "AceGUI30Button" .. AceGUI:GetNextWidgetNum(Type)
    local frame = CreateFrame("Button", name, UIParent, "OptionsListButtonTemplate")
    frame:SetHeight(35)
	frame:SetWidth(200)
	frame:Hide()

    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnClick", Button_OnClick)
	frame:SetScript("OnEnter", Control_OnEnter)
    frame:SetScript("OnLeave", Control_OnLeave)
    frame:SetScript("OnDragStart", Control_OnDragStart)
    frame:SetScript("OnDragStop", Control_OnDragStop)
    frame:SetPushedTextOffset(0, 0)
    frame:GetHighlightTexture():SetVertexColor(0.5, 0.5, 0.5, .5)

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

	local editbox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
	editbox:SetAutoFocus(false)
	editbox:SetFontObject(ChatFontNormal)
	editbox:SetScript("OnEscapePressed", EditBox_OnEscapePressed)
	editbox:SetScript("OnEnterPressed", EditBox_OnEnterPressed)
	editbox:SetScript("OnHide", EditBox_OnHide)
	editbox:SetScript("OnShow", EditBox_OnShow)
	editbox:SetTextInsets(0, 0, 3, 3)
	editbox:SetMaxLetters(256)
	editbox:SetPoint("LEFT", icon, "RIGHT", 7, 0)
	editbox:SetPoint("RIGHT", -5, 5)
    editbox:SetHeight(19)
    editbox:Hide()

	local widget = {
		text  = text,
		frame = frame,
        type  = Type,
        icon = icon,
        editbox = editbox,
        background = background,
	}
	for method, func in pairs(methods) do
		widget[method] = func
    end
    editbox.obj = widget

    if IsAddOnLoaded("ElvUI") then
        local E = unpack(_G["ElvUI"])
        local S = E:GetModule('Skins')

		S:HandleEditBox(widget.editbox)
    end

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)