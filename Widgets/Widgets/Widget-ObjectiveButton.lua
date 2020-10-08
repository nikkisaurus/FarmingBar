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
    if buttonClicked == "RightButton" then
        addon.MenuFrame = addon.MenuFrame or CreateFrame("Frame", "FarmingBarMenuFrame", UIParent, "UIDropDownMenuTemplate")
        EasyMenu(frame.obj.menu, addon.MenuFrame, frame, 0, 0, "MENU")
    end

    local loadPrevious = frame.obj:ToggleSelected(buttonClicked == "RightButton")

    if not loadPrevious then
        AceGUI:ClearFocus()
        PlaySound(852) -- SOUNDKIT.IG_MAINMENU_OPTION
        frame.obj:Fire("OnClick", ...)
    else
        frame.obj.container.selected[#frame.obj.container.selected].frame.obj:Fire("OnClick", ...)
    end
end

local function Control_OnEnter(frame)
	frame.obj:Fire("OnEnter")
end

local function Control_OnLeave(frame)
	frame.obj:Fire("OnLeave")
end

local function Control_OnDragStart(frame)
	frame.obj:Fire("OnDragStart")
end

local function Control_OnDragStop(frame)
	frame.obj:Fire("OnDragStop")
end

--*------------------------------------------------------------------------

local methods = {
	["OnAcquire"] = function(self)
		-- restore default values
		self:SetHeight(35)
		self:SetWidth(200)
		self:SetDisabled(false)
		self:SetIcon()
		self:SetMenu()
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
        local selected = self.container and self.container.selected
        if not selected then return end

        for _, objective in pairs(selected) do
            if objective == selectedButton then
                return
            end
        end

        tinsert(selected, selectedButton)
    end,

    ["SetContainer"] = function(self, container)
        self.container = container
        self.container.selected = container.selected or {}
        self.container.children = container.children or {}
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

    ["SetMenu"] = function(self, menu)
        self.menu = menu
    end,

    ["SetSelected"] = function(self, selected)
        self.selected = selected
        self:SetHighlight(selected)
    end,

    ["ToggleSelected"] = function(self, openedContext)
        local container = self.container and self.container.children
        local selected = self.container and self.container.selected

        if container then
            if IsShiftKeyDown() then
                local first, target

                for key, objective in pairs(container) do
                    if objective.button == selected[#selected] then
                        first = key
                    elseif objective.button == self then
                        target = key
                    end
                end

                if first and target then
                    local offset = (first < target) and 1 or -1
                    for i = first + offset, target - offset, offset do
                        container[i].button:SetSelected(true)
                        self:CacheSelected(container[i].button)
                    end
                end
            elseif IsControlKeyDown() then
                local key = addon.GetTableKey(selected, self)
                if key and #selected > 1 and not openedContext then
                    self:SetSelected(false)
                    tremove(selected, key)
                    return true -- trigger to load the last selected button
                end
            elseif not openedContext then
                for key, objective in pairs(container) do
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