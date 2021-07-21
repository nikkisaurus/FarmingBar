local addonName, ns = ...
local addon = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)


--*------------------------------------------------------------------------


local barCommandSort = {
    moveBar = 1,
    toggleMovable = 2,
    configBar = 3,
    showObjectiveBuilder = 4,
    openSettings = 5,
    openHelp = 6,
}


function addon:GetBarTooltip(widget, tooltip)
    if not addon.db.global.settings.tooltips.bar then return end

    local barDB = widget:GetBarDB()
    if not barDB then return end

    -- Title
    tooltip:AddLine(self:GetBarTitle(widget:GetBarID()), 0, 1, 0, 1)

    -- Spacer
    GameTooltip_AddBlankLinesToTooltip(tooltip, 1)

    -- local progressCount, progressTotal = bar:GetProgress()
    local progressCount, progressTotal = 0, 0 --!

    -- Bar info
    tooltip:AddDoubleLine(L["Progress"], barDB.trackProgress and string.format("%s/%s", progressCount, progressTotal) or L["FALSE"], unpack(self.tooltip_keyvalue))
    tooltip:AddDoubleLine(L["Growth Direction"], L[strsub(barDB.grow[1], 1, 1)..strlower(strsub(barDB.grow[1], 2))], unpack(self.tooltip_keyvalue))
    tooltip:AddDoubleLine(L["Growth Type"], L[strsub(barDB.grow[2], 1, 1)..strlower(strsub(barDB.grow[2], 2))], unpack(self.tooltip_keyvalue))
    tooltip:AddDoubleLine(L["Number of Buttons"], barDB.numVisibleButtons.."/"..self.maxButtons, unpack(self.tooltip_keyvalue))
    tooltip:AddDoubleLine(L["Alpha"], self.round(barDB.alpha * 100, 2).."%", unpack(self.tooltip_keyvalue))
    tooltip:AddDoubleLine(L["Scale"], self.round(barDB.scale * 100, 2).."%", unpack(self.tooltip_keyvalue))
    tooltip:AddDoubleLine(L["Movable"], barDB.movable and L["TRUE"] or L["FALSE"], unpack(self.tooltip_keyvalue))

    -- Hints
    if addon.db.global.settings.hints.bars then
        -- Spacer
        GameTooltip_AddBlankLinesToTooltip(FarmingBar_Tooltip, 1)

        if self:IsTooltipMod() then
            FarmingBar_Tooltip:AddLine(format("%s:", L["Hints"]))

            for k, v in self.pairs(addon.db.global.settings.keybinds.bar, function(a, b) return barCommandSort[a] < barCommandSort[b] end) do
                FarmingBar_Tooltip:AddLine(L.BarHints(k, v), unpack(self.tooltip_description))
            end
        else
            tooltip:AddDoubleLine(L["Show Hints"]..":", L[addon.db.global.settings.hints.modifier], unpack(self.tooltip_keyvalue))
        end
    end
end