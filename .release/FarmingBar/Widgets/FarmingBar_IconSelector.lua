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

local function PageButton_OnClick(button, buttonID)
	local widget = button.obj
	local page, newPage = widget:GetUserData("page")

	if buttonID == 1 then
		newPage = 1
	elseif buttonID == 2 then
		newPage = page - 1
	elseif buttonID == 3 then
		newPage = page + 1
	elseif buttonID == 4 then
		newPage = widget:GetUserData("numPages")
	end

	widget:LoadPage(newPage)
end

local function SelectIcon(widget, iconID)
	addon:SetObjectiveDBValue("icon", iconID, widget:GetUserData("objectiveTitle"))
	addon:UpdateButtons()
	widget:Fire("OnClose")
end

-- *------------------------------------------------------------------------
-- Widget methods

local methods = {
	OnAcquire = function(self)
		self.status = {}
		self.frame:Show()
		self.searchbox:SetText("")
		self.searchbox:SetFocus()
		self:LoadIcons()
	end,

	OnRelease = function(self)
		self.status = nil
	end,

	LoadIcons = function(self, filter)
		-- Get displayed icons
		local icons = {}
		for iconID, iconName in pairs(addon.fileData) do
			if not filter or filter == "" or strfind(strlower(iconName), strlower(filter)) then
				tinsert(icons, { iconID = iconID, iconName = iconName })
			end
		end
		self:SetUserData("icons", icons)

		-- Determine the number of icons per page
		local numIcons = addon.tcount(icons)
		local numPages = ceil(numIcons / addon.maxIcons)
		self:SetUserData("page", 1)
		self:SetUserData("numPages", numPages)

		self:SetPageText()

		self:LoadPage(1)
	end,

	LoadObjective = function(self, objectiveTitle)
		self:SetUserData("objectiveTitle", objectiveTitle)
		self.window:SetTitle(format("%s %s - %s", L.addon, L["Icon Selector"], objectiveTitle))
		self:SetIcon(objectiveTitle)
	end,

	LoadPage = function(self, page)
		self.iconGroup:ReleaseChildren()

		local icons = self:GetUserData("icons")
		self:SetUserData("page", page)
		self:UpdateButtons()
		self:SetPageText()

		for i = 1, 500 do
			local iconInfo = icons[i * page]
			if iconInfo then
				-- Create widget
				local iconID = iconInfo.iconID
				local icon = AceGUI:Create("Icon")
				icon:SetImageSize(35, 35)
				icon:SetWidth(40)
				icon:SetImage(iconID)
				self.iconGroup:AddChild(icon)

				-- Setup func
				icon:SetCallback("OnClick", function()
					if IsShiftKeyDown() then
						SelectIcon(self, iconID)
					else
						self:SetIcon(_, iconID)
					end
				end)

				-- Setup tooltip
				icon:SetCallback("OnEnter", function()
					addon.tooltipFrame:Load(icon.frame, "ANCHOR_BOTTOMRIGHT", 0, 0, {
						{
							line = addon.fileData[iconID],
							color = { 1, 0.82, 0, 1 },
						},
						{
							line = L.SelectIcon,
							color = { 1, 1, 1, 1 },
						},
					})
				end)

				icon:SetCallback("OnLeave", function()
					addon.tooltipFrame:Clear()
				end)
			else
				return
			end
		end
	end,

	SetIcon = function(self, objectiveTitle, iconID)
		local objectiveInfo = addon:GetDBValue("global", "objectives")[objectiveTitle]
		local icon = objectiveInfo and objectiveInfo.icon or iconID

		self.icon:SetImage(icon)
		self.icon:SetText(format("%d (%s)", icon, addon.fileData[icon]))

		self:SetUserData("iconID", icon)
	end,

	SetPageText = function(self)
		self.iconScrollFrame:SetTitle(
			format("%s %d/%d", L["Page"], self:GetUserData("page"), self:GetUserData("numPages"))
		)
	end,

	UpdateButtons = function(self)
		local page = self:GetUserData("page")
		local numPages = self:GetUserData("numPages")

		self.first:SetDisabled(page == 1)
		self.previous:SetDisabled((page - 1) == 0)
		self.next:SetDisabled((page + 1) > numPages)
		self.last:SetDisabled(page == numPages)
	end,
}

-- *------------------------------------------------------------------------
-- Constructor

local function Constructor()
	local window = AceGUI:Create("Frame")
	window:SetTitle(L.addon)
	window:SetLayout("Flow")

	local frame = window.frame

	local icon = AceGUI:Create("InteractiveLabel")
	icon:SetFullWidth(true)
	icon:SetImageSize(35, 35)
	icon:SetImage(134400)
	window:AddChild(icon)

	icon:SetCallback("OnClick", function(self)
		if IsShiftKeyDown() then
			SelectIcon(self.obj, self.obj:GetUserData("iconID"))
		end
	end)

	icon:SetCallback("OnEnter", function()
		addon.tooltipFrame:Load(icon.frame, "ANCHOR_TOPLEFT", 0, 0, {
			{
				line = L.SelectIcon,
				color = { 1, 1, 1, 1 },
			},
		})
	end)

	icon:SetCallback("OnLeave", function()
		addon.tooltipFrame:Clear()
	end)

	local searchbox = AceGUI:Create("EditBox")
	searchbox:SetFullWidth(true)
	searchbox:SetLabel(L["Search"])
	searchbox:DisableButton(true)
	window:AddChild(searchbox)

	searchbox:SetCallback("OnEnterPressed", function(self)
		self:ClearFocus()
	end)

	searchbox:SetCallback("OnTextChanged", function(self)
		self.obj:LoadIcons(self:GetText())
	end)

	local first = AceGUI:Create("Button")
	first:SetText(L["First"])
	first:SetRelativeWidth(1 / 4)
	window:AddChild(first)

	first:SetCallback("OnClick", function(self)
		PageButton_OnClick(self, 1)
	end)

	local previous = AceGUI:Create("Button")
	previous:SetText(L["Previous"])
	previous:SetRelativeWidth(1 / 4)
	window:AddChild(previous)

	previous:SetCallback("OnClick", function(self)
		PageButton_OnClick(self, 2)
	end)

	local next = AceGUI:Create("Button")
	next:SetText(L["Next"])
	next:SetRelativeWidth(1 / 4)
	window:AddChild(next)

	next:SetCallback("OnClick", function(self)
		PageButton_OnClick(self, 3)
	end)

	local last = AceGUI:Create("Button")
	last:SetText(L["Last"])
	last:SetRelativeWidth(1 / 4)
	window:AddChild(last)

	last:SetCallback("OnClick", function(self)
		PageButton_OnClick(self, 4)
	end)

	local iconScrollFrame = AceGUI:Create("InlineGroup")
	iconScrollFrame:SetFullWidth(true)
	iconScrollFrame:SetFullHeight(true)
	iconScrollFrame:SetLayout("Fill")
	iconScrollFrame:SetTitle(L["Page"])
	window:AddChild(iconScrollFrame)

	local iconGroup = AceGUI:Create("ScrollFrame")
	iconGroup:SetLayout("Flow")
	iconScrollFrame:AddChild(iconGroup)

	local widget = {
		type = Type,
		window = window,
		frame = frame,
		icon = icon,
		searchbox = searchbox,
		iconScrollFrame = iconScrollFrame,
		iconGroup = iconGroup,
		first = first,
		previous = previous,
		next = next,
		last = last,
	}

	for key, value in pairs(widget) do
		if key ~= "type" then
			value.obj = widget
		end
	end

	for method, func in pairs(methods) do
		widget[method] = func
	end

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
