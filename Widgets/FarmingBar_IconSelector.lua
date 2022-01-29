local addonName = ...
local addon = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

-- Optional libraries
local ACD = LibStub("AceConfigDialog-3.0")
local AceGUI = LibStub("AceGUI-3.0", true)
local LSM = LibStub("LibSharedMedia-3.0")

local Type = "FarmingBar_IconSelector"
local Version = 1

-- *------------------------------------------------------------------------
-- Widget methods

local methods = {
	OnAcquire = function(self)
		self.frame:Show()
	end,

	LoadObjective = function(self, objectiveTitle)
		self.window:SetTitle(format("%s %s - %s", L.addon, L["Icon Selector"], objectiveTitle))
	end,
}

-- *------------------------------------------------------------------------
-- Constructor

local function Constructor()
	local window = AceGUI:Create("Window")
	window:SetTitle(L.addon)
	window:SetLayout("Flow")

	local frame = window.frame

	local icon = AceGUI:Create("Icon")
	icon:SetFullWidth(true)
	icon:SetImage(134400)
	icon:SetLabel("")
	icon:SetImageSize(35, 35)
	window:AddChild(icon)

	local widget = {
		type = Type,
		window = window,
		frame = frame,
		icon = icon,
		-- iconName = iconName,
		-- searchbox = searchbox,
	}

	window.obj = widget

	for method, func in pairs(methods) do
		widget[method] = func
	end

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
