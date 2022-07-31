local addonName = ...
local addon = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

-- Optional libraries
local ACD = LibStub("AceConfigDialog-3.0")
local AceGUI = LibStub("AceGUI-3.0", true)
local LSM = LibStub("LibSharedMedia-3.0")

local Type = "FarmingBar_LuaEditor"
local Version = 1

-- *------------------------------------------------------------------------
-- Widget methods

local methods = {
	OnAcquire = function(self)
		self.frame:Hide()

		local editbox = self.editBox
		addon.indent.enable(editbox, _, 4) -- adds syntax highlighting
		self:SetUserData("OnUpdate", editbox:GetScript("OnUpdate"))
		editbox:SetScript("OnUpdate", function(this)
			self:GetUserData("OnUpdate")(this)
			this.obj.button:Enable()
		end)
	end,
	OnRelease = function(self)
		local editbox = self.editBox
		addon.indent.disable(self.editBox)
		editbox:SetScript("OnUpdate", self:GetUserData("OnUpdate"))

		self.window.obj:Release()
		self.editbox.obj:Release()
	end,
	LoadCode = function(self, info, widget, set)
		self.editbox:SetUserData("info", info)
		self.editbox:SetText(widget:GetText())
		self.editbox:Fire("OnTextChanged")
		self.frame:Show()
		self.editbox.button:HookScript("OnClick", function()
			set(_, self.editbox:GetText())
		end)
	end,
	SetStatusText = function(self, text)
		self.window:SetStatusText(text)
	end,
	SetTitle = function(self, title)
		self.window:SetTitle(title)
	end,
}

-- *------------------------------------------------------------------------
-- Constructor

local function Constructor()
	local window = AceGUI:Create("Frame")
	window:SetLayout("FILL")

	local frame = window.frame
	frame:SetClampedToScreen(true)
	frame:SetPoint("CENTER", 0, 0)
	frame:Show()

	local editbox = AceGUI:Create("MultiLineEditBox")
	editbox:SetLabel("")
	window:AddChild(editbox)

	editbox:SetCallback("OnEnterPressed", function(self, _, text)
		local success, err = pcall(loadstring("return " .. text))
		if not success then
			window:SetStatusText(L["Error"] .. ": " .. err)
			return
		end

		local info = self:GetUserData("info")
		if info[5] then
			addon:SetBarDBValue(info[2], text, info[5])
		else
			addon:SetDBValue(info[1], info[2], text)
		end
		self.obj:Release()
	end)

	editbox:SetCallback("OnTextChanged", function(self)
		local info = self:GetUserData("info")
		local scope, key, func, args = unpack(info)
		if not func or not addon[func] then
			return
		else
			func = addon[func]
		end

		-- Update preview while typing
		local preview, err = func(addon, addon.unpack(args, {}), self:GetText())
		window:SetStatusText(preview or err)
	end)

	local widget = {
		type = Type,
		window = window,
		frame = frame,
		editbox = editbox,
		editBox = editbox.editBox,
		statustext = window.statustext,
	}

	window.obj, frame.obj, editbox.obj = widget, widget, widget

	for method, func in pairs(methods) do
		widget[method] = func
	end

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
