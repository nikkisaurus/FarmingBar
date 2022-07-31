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

-- *------------------------------------------------------------------------

function addon:GetBarTooltip(widget, tooltip)
	local barDB = widget:GetBarDB()
	if not self:GetDBValue("global", "settings.tooltips.bar") or not barDB then
		return
	end

	local kv = self.tooltip_keyvalue
	local desc = self.tooltip_desc

	-- Bar info
	local progressCount, progressTotal = widget:GetProgress()
	local charBarDB = addon:GetDBValue("char", "bars")[widget:GetBarID()]

	local lines = {
		{
			line = self:GetBarTitle(widget:GetBarID()),
			color = { 0, 1, 0, 1 },
		},
		{
			line = " ",
			color = desc,
		},
		{
			double = true,
			k = L["Muted"],
			v = charBarDB.alerts.muteAll and L["TRUE"] or L["FALSE"],
			color = kv,
		},
		{
			double = true,
			k = L["Progress"],
			v = charBarDB.alerts.barProgress and string.format("%s/%s", progressCount, progressTotal) or L["Disabled"],
			color = kv,
		},
		{
			double = true,
			k = L["Completed Objectives"],
			v = charBarDB.alerts.completedObjectives and L["Enabled"] or L["Disabled"],
			color = kv,
		},
		{
			line = " ",
			color = desc,
		},
		{
			double = true,
			k = L["Number of Buttons"],
			v = barDB.numVisibleButtons .. "/" .. self.maxButtons,
			color = kv,
		},
		{
			double = true,
			k = L["Growth Direction"],
			v = L[strsub(barDB.grow[1], 1, 1) .. strlower(strsub(barDB.grow[1], 2))],
			color = kv,
		},
		{
			double = true,
			k = L["Anchor"],
			v = barDB.grow[2] == "DOWN" and L["Normal"] or L["Reverse"],
			color = kv,
		},
		{
			double = true,
			k = L["Movable"],
			v = barDB.movable and L["TRUE"] or L["FALSE"],
			color = kv,
		},
		{
			line = " ",
			color = desc,
		},
		{
			double = true,
			k = L["Alpha"],
			v = self.round(barDB.alpha * 100, 2) .. "%",
			color = kv,
		},
		{
			line = " ",
			color = desc,
		},
	}

	if self:IsTooltipMod() then
		tinsert(lines, {
			line = format("%s:", L["Hints"]),
			color = desc,
		})

		for k, v in self.pairs(self:GetDBValue("global", "settings.keybinds.bar"), function(a, b)
			return barCommandSort[a] < barCommandSort[b]
		end) do
			tinsert(lines, {
				line = L.BarHints(k, v),
				color = desc,
			})
		end
	else
		tinsert(lines, {
			double = true,
			k = L["Expand Tooltip"] .. ":",
			v = L[self:GetDBValue("global", "settings.tooltips.modifier")],
			color = kv,
		})
	end

	return lines
end
