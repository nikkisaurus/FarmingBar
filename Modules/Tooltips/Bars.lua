local addonName, ns = ...
local addon = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

-- *------------------------------------------------------------------------

local barCommandSort = {
	moveBar = 1,
	toggleMovable = 2,
	configBar = 3,
	showObjectiveBuilder = 4,
	openSettings = 5,
	openHelp = 6,
}

function addon:GetBarTooltip(widget, tooltip)
	if not self:GetDBValue("global", "settings.tooltips.bar") then
		return
	end

	local barDB = widget:GetBarDB()
	if not barDB then
		return
	end

	-- Title
	tooltip:AddLine(self:GetBarTitle(widget:GetBarID()), 0, 1, 0, 1)

	-- Spacer
	GameTooltip_AddBlankLinesToTooltip(tooltip, 1)

	-- Bar info
	local progressCount, progressTotal = widget:GetProgress()
	local charBarDB = addon:GetDBValue("char", "bars")[widget:GetBarID()]

	tooltip:AddDoubleLine(
		L["Muted"],
		charBarDB.alerts.muteAll and L["TRUE"] or L["FALSE"],
		unpack(self.tooltip_keyvalue)
	)
	tooltip:AddDoubleLine(
		L["Progress"],
		charBarDB.alerts.barProgress and string.format("%s/%s", progressCount, progressTotal) or L["Disabled"],
		unpack(self.tooltip_keyvalue)
	)
	tooltip:AddDoubleLine(
		L["Completed Objectives"],
		charBarDB.alerts.completedObjectives and L["Enabled"] or L["Disabled"],
		unpack(self.tooltip_keyvalue)
	)

	GameTooltip_AddBlankLinesToTooltip(tooltip, 1)

	tooltip:AddDoubleLine(
		L["Number of Buttons"],
		barDB.numVisibleButtons .. "/" .. self.maxButtons,
		unpack(self.tooltip_keyvalue)
	)
	tooltip:AddDoubleLine(
		L["Growth Direction"],
		L[strsub(barDB.grow[1], 1, 1) .. strlower(strsub(barDB.grow[1], 2))],
		unpack(self.tooltip_keyvalue)
	)
	tooltip:AddDoubleLine(
		L["Anchor"],
		barDB.grow[2] == "DOWN" and L["Normal"] or L["Reverse"],
		unpack(self.tooltip_keyvalue)
	)
	tooltip:AddDoubleLine(L["Movable"], barDB.movable and L["TRUE"] or L["FALSE"], unpack(self.tooltip_keyvalue))

	GameTooltip_AddBlankLinesToTooltip(tooltip, 1)

	tooltip:AddDoubleLine(L["Alpha"], self.round(barDB.alpha * 100, 2) .. "%", unpack(self.tooltip_keyvalue))

	-- Hints
	if self:GetDBValue("global", "settings.hints.bars") then
		-- Spacer
		GameTooltip_AddBlankLinesToTooltip(self.tooltipFrame, 1)

		if self:IsTooltipMod() then
			self.tooltipFrame:AddLine(format("%s:", L["Hints"]))

			for k, v in self.pairs(self:GetDBValue("global", "settings.keybinds.bar"), function(a, b)
				return barCommandSort[a] < barCommandSort[b]
			end) do
				self.tooltipFrame:AddLine(L.BarHints(k, v), unpack(self.tooltip_description))
			end
		else
			tooltip:AddDoubleLine(
				L["Expand Tooltip"] .. ":",
				L[self:GetDBValue("global", "settings.tooltips.modifier")],
				unpack(self.tooltip_keyvalue)
			)
		end
	end
end
