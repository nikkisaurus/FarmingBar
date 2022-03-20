local addonName = ...
local addon = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

function addon:InitializeTooltips()
	self.tooltip = FarmingBar_Tooltip
		or CreateFrame("GameTooltip", "FarmingBar_Tooltip", UIParent, "GameTooltipTemplate")
	self.tooltipFrame = self:GetDBValue("global", "settings.tooltips.useGameTooltip") and GameTooltip or self.tooltip
	local tooltipFrame = self.tooltipFrame
	tooltipFrame:ClearLines()

	function tooltipFrame:Load(owner, anchor, x, y, lines)
		if not lines or type(lines) ~= "table" then
			return
		end

		tooltipFrame:ClearLines()
		tooltipFrame:SetOwner(owner, anchor, x, y)
		for _, line in pairs(lines) do
			if line.link then
				tooltipFrame:SetHyperlink(line.line)
			elseif line.texture then
				tooltipFrame:AddTexture(line.line, line.size)
			elseif line.double then
				tooltipFrame:AddDoubleLine(line.k, line.v, unpack(line.color))
			else
				tooltipFrame:AddLine(line.line, unpack(line.color))
			end
		end
		tooltipFrame:Show()
	end

	function tooltipFrame:Clear()
		tooltipFrame:ClearLines()
		tooltipFrame:Hide()
	end
end
