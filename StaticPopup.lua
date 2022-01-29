local addonName = ...
local addon = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

-- *------------------------------------------------------------------------

StaticPopupDialogs["FARMINGBAR_CONFIRM_OVERWRITE_TEMPLATE"] = {
	text = L.FARMINGBAR_CONFIRM_OVERWRITE_TEMPLATE,
	button1 = YES,
	button2 = NO,
	OnAccept = function(_, barID, templateName)
		addon:SaveTemplate(barID, templateName, true)
	end,
	timeout = 0,
	whileDead = true,
	enterClicksFirstButton = true,
	hideOnEscape = true,
	preferredIndex = 3,
}

StaticPopupDialogs["FARMINGBAR_INCLUDE_TEMPLATE_DATA"] = {
	text = L.FARMINGBAR_INCLUDE_TEMPLATE_DATA,
	button1 = YES,
	button2 = NO,
	button3 = CANCEL,
	OnAccept = function(_, data)
		if addon:GetDBValue("global", "settings.misc.preserveTemplateOrder") == "PROMPT" then
			local dialog = StaticPopup_Show("FARMINGBAR_SAVE_TEMPLATE_ORDER", data[2])
			if dialog then
				dialog.data = { data[1], data[2], true }
			end
		else
			addon:LoadTemplate(
				"user",
				data[1],
				data[2],
				true,
				addon:GetDBValue("global", "settings.misc.preserveTemplateOrder") == "ENABLED"
			)
		end
	end,
	OnCancel = function(_, data)
		if addon:GetDBValue("global", "settings.misc.preserveTemplateOrder") == "PROMPT" then
			local dialog = StaticPopup_Show("FARMINGBAR_SAVE_TEMPLATE_ORDER", data[2])
			if dialog then
				dialog.data = { data[1], data[2], false }
			end
		else
			addon:LoadTemplate(
				"user",
				data[1],
				data[2],
				false,
				addon:GetDBValue("global", "settings.misc.preserveTemplateOrder") == "ENABLED"
			)
		end
	end,
	timeout = 0,
	whileDead = true,
	enterClicksFirstButton = true,
	hideOnEscape = true,
	preferredIndex = 3,
}

StaticPopupDialogs["FARMINGBAR_SAVE_TEMPLATE_ORDER"] = {
	text = L.FARMINGBAR_SAVE_TEMPLATE_ORDER,
	button1 = YES,
	button2 = NO,
	button3 = CANCEL,
	OnAccept = function(_, data)
		addon:LoadTemplate("user", data[1], data[2], data[3], true)
	end,
	OnCancel = function(_, data)
		addon:LoadTemplate("user", data[1], data[2], data[3])
	end,
	timeout = 0,
	whileDead = true,
	enterClicksFirstButton = true,
	hideOnEscape = true,
	preferredIndex = 3,
}
