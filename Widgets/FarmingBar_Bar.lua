local addonName = ...
local addon = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

-- Optional libraries
local ACD = LibStub("AceConfigDialog-3.0")
local AceGUI = LibStub("AceGUI-3.0", true)
local LSM = LibStub("LibSharedMedia-3.0")
local utils = LibStub("LibAddonUtils-1.0")

local red = utils.ChatColors["RED"]
local gold = utils.ChatColors["GOLD"]
local green = utils.ChatColors["GREEN"]

local Type = "FarmingBar_Bar"
local Version = 2

-- *------------------------------------------------------------------------
-- Keybinds

local postClickMethods = {
	configBar = function(self, ...)
		local barID = self.obj:GetBarID()
		ACD:SelectGroup(addonName, "config", "container", "bar" .. barID)
		ACD:Open(addonName)
	end,
	toggleMovable = function(self, ...)
		local widget = self.obj
		widget:SetDBValue("movable", "_TOGGLE_")
		widget:SetMovable()

		addon:Print(L.ToggleMovable(widget:GetBarTitle(), widget:GetUserData("barDB").movable))
	end,
	openSettings = function(self, ...)
		ACD:SelectGroup(addonName, "globalSettings")
		ACD:Open(addonName)
	end,
	showObjectiveBuilder = function(self, ...)
		ACD:SelectGroup(addonName, "objectiveBuilder")
		ACD:Open(addonName)
	end,
	openHelp = function(self, ...)
		ACD:SelectGroup(addonName, "help")
		ACD:Open(addonName)
	end,
}

-- *------------------------------------------------------------------------
-- Frame methods

local function addButton_OnClick(self)
	local widget = self.obj
	local barDB = widget:GetUserData("barDB")

	if barDB.numVisibleButtons < addon.maxButtons then
		barDB.numVisibleButtons = barDB.numVisibleButtons + 1
		widget:AddButton(barDB.numVisibleButtons)
		addon:RefreshOptions()
	end
end

local function anchor_OnDragStart(self, clickedButton)
	local frame = self.obj.frame
	if not frame:IsMovable() then
		return
	end

	local keybindInfo = addon:GetDBValue("global", "settings.keybinds.bar.moveBar")
	local modifier, button = keybindInfo.modifier, keybindInfo.button
	if modifier == addon:GetModifierString() and clickedButton == button then
		frame:StartMoving()
	end
end

local function anchor_OnDragStop(self)
	local widget = self.obj
	local frame = widget.frame
	if not frame:IsMovable() then
		return
	end
	frame:StopMovingOrSizing()
	widget:SetDBValue("point", { frame:GetPoint() })
end

local function anchor_OnEnter(self)
	local widget = self.obj
	local barDB = widget:GetBarDB()

	widget:SetAlpha(true)

	local tooltip = widget:GetUserData("tooltip")
	if tooltip and not addon.DragFrame:GetObjective() then
		addon.tooltipFrame:SetScript("OnUpdate", function()
			addon.tooltipFrame:Load(self, "ANCHOR_BOTTOMRIGHT", 0, 0, addon[tooltip](addon, widget, addon.tooltipFrame))
		end)
		addon.tooltipFrame:GetScript("OnUpdate")()
	end
end

local function anchor_OnLeave(self)
	local widget = self.obj
	local barDB = widget:GetBarDB()

	widget:SetAlpha(false)

	local tooltip = widget:GetUserData("tooltip")
	if tooltip and not addon.DragFrame:GetObjective() then
		addon.tooltipFrame.Clear()
		addon.tooltipFrame:SetScript("OnUpdate", nil)
	end
end

local function anchor_PostClick(self, buttonClicked, ...)
	if addon.DragFrame:GetObjective() then
		addon.DragFrame:Clear()
	end

	ClearCursor()

	local keybinds = addon:GetDBValue("global", "settings.keybinds.bar")
	for keybind, keybindInfo in pairs(keybinds) do
		if buttonClicked == keybindInfo.button then
			local mod = addon:GetModifierString()

			if mod == keybindInfo.modifier then
				local func = postClickMethods[keybind]
				if func then
					func(self, keybindInfo, buttonClicked, ...)
				end
			end
		end
	end
end

local function frame_OnEvent(self, event)
	local widget = self.obj
	local barDB = widget:GetBarDB()

	if event == "PLAYER_REGEN_DISABLED" then
		widget.addButton:Disable()
		widget.removeButton:Disable()
	elseif event == "PLAYER_REGEN_ENABLED" then
		widget:SetQuickButtonStates()
	elseif barDB then
		widget:SetHidden()
	end
end

local function removeButton_OnClick(self)
	local widget = self.obj
	local barDB = widget:GetUserData("barDB")

	if barDB.numVisibleButtons > 0 then
		barDB.numVisibleButtons = barDB.numVisibleButtons - 1
		widget:RemoveButton()
		addon:RefreshOptions()
	end
end

-- *------------------------------------------------------------------------
-- Widget methods

local methods = {
	OnAcquire = function(self)
		self:SetUserData("tooltip", "GetBarTooltip")
		self:SetUserData("buttons", {})
	end,
	OnRelease = function(self)
		if not self:GetUserData("buttons") then
			return
		end
		for _, button in pairs(self:GetUserData("buttons")) do
			button:Release()
		end
	end,
	AddButton = function(self, buttonID)
		local button = AceGUI:Create("FarmingBar_Button")
		tinsert(self:GetUserData("buttons"), button)
		button:SetBar(self, buttonID)
		self:SetQuickButtonStates()
	end,
	AlertProgress = function(self, alertType, newCompletion)
		local barDB = self:GetBarCharDB()
		if barDB.alerts.barProgress then
			local barIDName = format("%s %d", L["Bar"], self:GetBarID())
			local progressCount, progressTotal = self:GetProgress()

			if progressTotal == 0 then
				return
			end

			local alertInfo = {
				progressCount = progressCount,
				progressTotal = progressTotal,
				barIDName = barIDName,
				barNameLong = format("%s (%s)", barIDName, barDB.title),
				progressColor = (alertType ~= "removed" and newCompletion == "lost" and red)
					or (progressCount < progressTotal and gold)
					or green,
				objectiveSet = alertType == "added" or alertType == "removed",
				difference = {
					sign = newCompletion == "lost" and "-" or "+",
					color = newCompletion == "lost" and "|cffff0000" or "|cff00ff00",
				},
			}

			-- Validate format func
			local success, formatFunc = pcall(addon.alerts.bar.progress)
			if not success then
				return
			end

			local alertSettings = addon:GetDBValue("global", "settings.alerts.bar")

			-- Get parsed alert
			local parsedAlert = formatFunc(alertInfo)
			if parsedAlert then
				-- Send alert
				if alertSettings.chat then
					addon:Print(parsedAlert)
				elseif alertSettings.screen then
					UIErrorsFrame:AddMessage(parsedAlert, 1, 1, 1)
				end
			end

			-- Send sound alert
			if alertSettings.sound.enabled and newCompletion ~= "lost" then
				PlaySoundFile(
					LSM:Fetch("sound", alertSettings.sound[progressCount >= progressTotal and "complete" or "progress"])
				)
			end
		end
	end,
	AnchorButtons = function(self)
		for _, button in pairs(self:GetUserData("buttons")) do
			button:Anchor()
		end
	end,
	ApplySkin = function(self)
		addon:SkinBar(self, addon:GetDBValue("profile", "style.skin"))
	end,
	GetBarID = function(self)
		return self:GetUserData("barID")
	end,
	GetBarDB = function(self)
		return self:GetUserData("barDB")
	end,
	GetBarCharDB = function(self)
		return addon:GetDBValue("char", "bars")[self:GetBarID()]
	end,
	GetBarTitle = function(self)
		return addon:GetBarTitle(self:GetBarID())
	end,
	GetButtons = function(self)
		return self:GetUserData("buttons")
	end,
	GetProgress = function(self)
		local complete, total = 0, 0
		for _, button in pairs(self:GetButtons()) do
			total = button:HasObjective() and total + 1 or total
			complete = button:IsObjectiveComplete() and complete + 1 or complete
		end

		return complete, total
	end,
	RemoveButton = function(self)
		local buttons = self:GetUserData("buttons")

		buttons[#buttons]:Release()
		tremove(buttons)

		self:SetQuickButtonStates()
	end,
	SetAlpha = function(self, hasFocus)
		local db = self:GetBarDB()
		local alpha = (hasFocus or (not db.mouseover and not db.anchorMouseover)) and db.alpha or 0
		if not (hasFocus == "hasObjective" and db.anchorMouseover) then
			self.anchor:SetAlpha(alpha)
		end

		local cursorType, cursorID = GetCursorInfo()
		local objectiveTitle, objectiveInfo = addon.DragFrame and addon.DragFrame:GetObjective()
		for _, button in pairs(self:GetUserData("buttons")) do
			local isDragging = cursorType or objectiveTitle or addon.isMoving

			local showButton = (db.showEmpty or not button:IsEmpty() or isDragging)
				and (hasFocus or not db.mouseover or db.anchorMouseover)

			button:SetAlpha(showButton and db.alpha or 0)
		end
	end,
	SetBackdropAnchor = function(self)
		local barDB = self:GetBarDB()
		local buttons = self:GetUserData("buttons")

		local firstButton = buttons[1]
		local padding = barDB.backdropPadding
		local buttonWrap = barDB.buttonWrap
		local lastButton = buttons[#buttons]
		local wrapButton = (#buttons <= buttonWrap and lastButton) or buttons[buttonWrap]

		self:SetUserData("anchors", lastButton and {
			RIGHT = {
				DOWN = {
					[1] = { "TOP", self.anchor, "TOP", 0, padding },
					[2] = { "LEFT", buttons[1].frame, "LEFT", -padding, 0 },
					[3] = { "RIGHT", wrapButton.frame, "RIGHT", padding, 0 },
					[4] = { "BOTTOM", lastButton.frame, "BOTTOM", 0, -padding },
				},
				UP = {
					[1] = { "TOP", lastButton.frame, "TOP", 0, padding },
					[2] = { "LEFT", buttons[1].frame, "LEFT", -padding, 0 },
					[3] = { "RIGHT", wrapButton.frame, "RIGHT", padding, 0 },
					[4] = { "BOTTOM", buttons[1].frame, "BOTTOM", 0, -padding },
				},
			},
			LEFT = {
				DOWN = {
					[1] = { "TOP", self.anchor, "TOP", 0, padding },
					[2] = { "LEFT", wrapButton.frame, "LEFT", -padding, 0 },
					[3] = { "RIGHT", buttons[1].frame, "RIGHT", padding, 0 },
					[4] = { "BOTTOM", lastButton.frame, "BOTTOM", 0, -padding },
				},
				UP = {
					[1] = { "TOP", lastButton.frame, "TOP", 0, padding },
					[2] = { "LEFT", wrapButton.frame, "LEFT", -padding, 0 },
					[3] = { "RIGHT", buttons[1].frame, "RIGHT", padding, 0 },
					[4] = { "BOTTOM", buttons[1].frame, "BOTTOM", 0, -padding },
				},
			},
			UP = {
				DOWN = {
					[1] = { "TOP", wrapButton.frame, "TOP", 0, padding },
					[2] = { "LEFT", buttons[1].frame, "LEFT", -padding, 0 },
					[3] = { "RIGHT", lastButton.frame, "RIGHT", padding, 0 },
					[4] = { "BOTTOM", buttons[1].frame, "BOTTOM", 0, -padding },
				},
				UP = {
					[1] = { "TOP", wrapButton.frame, "TOP", 0, padding },
					[2] = { "LEFT", lastButton.frame, "LEFT", -padding, 0 },
					[3] = { "RIGHT", buttons[1].frame, "RIGHT", padding, 0 },
					[4] = { "BOTTOM", buttons[1].frame, "BOTTOM", 0, -padding },
				},
			},
			DOWN = {
				DOWN = {
					[1] = { "TOP", buttons[1].frame, "TOP", 0, padding },
					[2] = { "LEFT", buttons[1].frame, "LEFT", -padding, 0 },
					[3] = { "RIGHT", lastButton.frame, "RIGHT", padding, 0 },
					[4] = { "BOTTOM", wrapButton.frame, "BOTTOM", 0, -padding },
				},
				UP = {
					[1] = { "TOP", buttons[1].frame, "TOP", 0, padding },
					[2] = { "LEFT", lastButton.frame, "LEFT", -padding, 0 },
					[3] = { "RIGHT", buttons[1].frame, "RIGHT", padding, 0 },
					[4] = { "BOTTOM", wrapButton.frame, "BOTTOM", 0, -padding },
				},
			},
		})

		self:UpdateBackdrop()
	end,
	SetBarDB = function(self, barID)
		self:SetUserData("barID", barID)
		self.barID:SetText(barID or "")

		local barDB = addon:GetDBValue("profile", "bars")[barID]
		self:SetUserData("barDB", barDB)

		for i = 1, barDB.numVisibleButtons do
			self:AddButton(i)
		end

		self:ApplySkin()
		self:SetAlpha()
		self:SetHidden()
		self:SetMovable()
		self:SetBackdropAnchor()
		self:SetSize()
		self:SetPoint(unpack(barDB.point))
		self:SetQuickButtonStates()
	end,
	SetDBValue = function(self, key, value, isCharDB)
		addon:SetBarDBValue(key, value, self:GetBarID(), isCharDB)
	end,
	SetHidden = function(self)
		local preview, err = addon:CustomHide(self)
		if self:GetUserData("barDB").hidden or (preview and not err) then
			self.frame:Hide()
		else
			self.frame:Show()
		end

		for _, button in pairs(self:GetUserData("buttons")) do
			button:SetHidden()
		end
	end,
	SetMovable = function(self)
		self.frame:SetMovable(self:GetUserData("barDB").movable)
		addon:RefreshOptions()
	end,
	SetPoint = function(self, ...) -- point, anchor, relpoint, x, y
		self.frame:ClearAllPoints()
		self.frame:SetPoint(...)
	end,
	SetQuickButtonStates = function(self)
		local addButton = self.addButton
		local removeButton = self.removeButton
		local barDB = self:GetUserData("barDB")
		if not barDB then
			return
		end
		local numVisibleButtons = barDB.numVisibleButtons

		if numVisibleButtons == 0 then
			removeButton:Disable()
			addButton:Enable()
		elseif numVisibleButtons == 1 then
			removeButton:Enable()
		elseif numVisibleButtons == addon.maxButtons then
			addButton:Disable()
			removeButton:Enable()
		elseif numVisibleButtons == addon.maxButtons - 1 then
			addButton:Enable()
		else
			addButton:Enable()
			removeButton:Enable()
		end

		-- Update backdrop
		self:SetBackdropAnchor()
	end,
	SetSize = function(self)
		local frameSize = self:GetUserData("barDB").button.size
		local paddingSize = (2 / 20 * frameSize)
		local buttonSize = ((frameSize - (paddingSize * 3)) / 2) * 0.9
		local fontSize = frameSize / 3

		self.frame:SetSize(frameSize * 0.9, frameSize * 0.9)

		self.addButton:SetSize(buttonSize, buttonSize)
		self.addButton:SetPoint("TOPLEFT", paddingSize, -paddingSize)

		self.removeButton:SetSize(buttonSize, buttonSize)
		self.removeButton:SetPoint("TOPRIGHT", -paddingSize, -paddingSize)

		local fontDB = addon:GetDBValue("profile", "style.font")
		self.barID:SetFont(LSM:Fetch("font", fontDB.face), fontSize, fontDB.outline)
		self.barID:SetPoint("BOTTOM", 0, paddingSize)

		for _, button in pairs(self:GetUserData("buttons")) do
			button:SetSize(frameSize, frameSize)
		end
	end,
	UpdateBackdrop = function(self)
		local backdrop, backdropTexture = self.backdrop, self.backdropTexture
		backdrop:ClearAllPoints()
		backdropTexture:ClearAllPoints()
		backdropTexture:SetTexture("")

		local numVisibleButtons = #self:GetUserData("buttons")
		if numVisibleButtons == 0 then
			return
		else
			local barDB = self:GetBarDB()

			backdropTexture:SetTexture(LSM:Fetch("background", barDB.backdrop))
			backdropTexture:SetAllPoints(backdrop)
			if barDB.backdrop == "Solid" then
				backdropTexture:SetVertexColor(unpack(barDB.backdropColor))
			else
				backdropTexture:SetVertexColor(1, 1, 1, 1)
			end

			local grow = barDB.grow
			local hDirection, vDirection = grow[1], grow[2]
			local anchors = self:GetUserData("anchors")

			if not anchors then
				return
			end

			backdrop:SetPoint(unpack(anchors[hDirection][vDirection][1]))
			backdrop:SetPoint(unpack(anchors[hDirection][vDirection][2]))
			backdrop:SetPoint(unpack(anchors[hDirection][vDirection][3]))
			backdrop:SetPoint(unpack(anchors[hDirection][vDirection][4]))
		end
	end,
	UpdateVisibleButtons = function(self)
		local buttons = self:GetUserData("buttons")
		local difference = self:GetUserData("barDB").numVisibleButtons - #buttons

		if difference > 0 then
			for i = 1, difference do
				self:AddButton(#buttons + 1)
			end
		elseif difference < 0 then
			for i = 1, abs(difference) do
				self:RemoveButton()
			end
		end
	end,
}

-- *------------------------------------------------------------------------
-- Constructor

local function Constructor()
	local frame = CreateFrame("Frame", Type .. AceGUI:GetNextWidgetNum(Type), UIParent)
	frame:SetScale(UIParent:GetEffectiveScale())
	frame:Hide()
	frame:SetClampedToScreen(true)

	frame:SetScript("OnEvent", frame_OnEvent)

	local backdrop = CreateFrame("Frame", "$parentBackdrop", frame, BackdropTemplateMixin and "BackdropTemplate")
	backdrop:SetFrameStrata("BACKGROUND")
	backdrop:EnableMouse(true)

	local backdropTexture = backdrop:CreateTexture("$parentTexture", "BACKGROUND")
	backdropTexture:SetAllPoints(backdrop)

	local anchor = CreateFrame("Button", "$parentAnchor", frame)
	anchor:SetAllPoints(frame)
	anchor:SetClampedToScreen(true)
	anchor:EnableMouse(true)
	anchor:RegisterForClicks("AnyUp")
	anchor:SetMovable(true)
	anchor:RegisterForDrag("LeftButton", "RightButton")

	anchor:SetScript("OnDragStart", anchor_OnDragStart)
	anchor:SetScript("OnDragStop", anchor_OnDragStop)
	anchor:SetScript("PostClick", anchor_PostClick)
	anchor:SetScript("OnEnter", anchor_OnEnter)
	anchor:SetScript("OnLeave", anchor_OnLeave)

	anchor:SetFrameStrata("MEDIUM")

	local FloatingBG = anchor:CreateTexture("$parentFloatingBG", "BACKGROUND")
	FloatingBG:SetAllPoints(anchor)

	local OnLeave = function()
		frame.obj:SetAlpha()
	end

	local addButton = CreateFrame("Button", "$parentAddButton", anchor)
	addButton:SetNormalTexture([[INTERFACE\ADDONS\FARMINGBAR\MEDIA\PLUS]])
	addButton:SetDisabledTexture([[INTERFACE\ADDONS\FARMINGBAR\MEDIA\PLUS-DISABLED]])

	addButton:SetScript("OnClick", addButton_OnClick)
	addButton:SetScript("OnEnter", function(self)
		frame.obj:SetAlpha(true)
	end)
	addButton:SetScript("OnLeave", OnLeave)

	local removeButton = CreateFrame("Button", "$parentRemoveButton", anchor)
	removeButton:SetNormalTexture([[INTERFACE\ADDONS\FARMINGBAR\MEDIA\MINUS]])
	removeButton:SetDisabledTexture([[INTERFACE\ADDONS\FARMINGBAR\MEDIA\MINUS-DISABLED]])

	removeButton:SetScript("OnClick", removeButton_OnClick)
	removeButton:SetScript("OnEnter", function(self)
		frame.obj:SetAlpha(true)
	end)
	removeButton:SetScript("OnLeave", OnLeave)

	local barID = anchor:CreateFontString("$parentBarIDButton", "OVERLAY")
	barID:SetFont([[Fonts\FRIZQT__.TTF]], 12, "DOWN")

	local widget = {
		type = Type,
		frame = frame,
		backdrop = backdrop,
		backdropTexture = backdropTexture,
		anchor = anchor,
		FloatingBG = FloatingBG,
		addButton = addButton,
		removeButton = removeButton,
		barID = barID,
	}

	frame.obj, anchor.obj, addButton.obj, removeButton.obj, backdrop.obj = widget, widget, widget, widget, widget

	backdrop:SetScript("OnEnter", function(self)
		local barDB = self.obj:GetUserData("barDB")
		if not barDB.anchorMouseover then
			widget:SetAlpha(true)
		end
	end)

	backdrop:SetScript("OnLeave", OnLeave)

	for method, func in pairs(methods) do
		widget[method] = func
	end

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
