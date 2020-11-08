local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

local pairs, unpack = pairs, unpack
local format, strlen, strlower, strsub = string.format, string.len, string.lower, string.sub
local GameTooltip_AddBlankLinesToTooltip = GameTooltip_AddBlankLinesToTooltip

--! Note: tooltip functions from AceGUI widgets will not have a self reference

--*------------------------------------------------------------------------

function addon:GetButtonTooltip(widget, tooltip)
    local objectiveTitle = widget:GetUserData("objectiveTitle")
    local objectiveInfo = self:GetObjectiveInfo(objectiveTitle)
    if not objectiveInfo then return end

    if objectiveInfo.displayRef.trackerType and objectiveInfo.displayRef.trackerID and (objectiveInfo.displayRef.trackerType == "ITEM" or objectiveInfo.displayRef.trackerType == "CURRENCY") then
        tooltip:SetHyperlink(format("%s:%s", string.lower(objectiveInfo.displayRef.trackerType), objectiveInfo.displayRef.trackerID))
    end
end

------------------------------------------------------------

function addon:GetExcludeListLabelTooltip(widget, tooltip)
    if FarmingBar.db.global.hints.ObjectiveBuilder then
        tooltip:AddLine(format("%s:", L["Hint"]))
        tooltip:AddLine(L.RemoveExcludeHint, unpack(addon.tooltip_description))
    end
end

------------------------------------------------------------

function addon:GetObjectiveButtonTooltip(widget, tooltip)
    local objectiveTitle = widget:GetUserData("objectiveTitle")
    local objectiveInfo = self:GetObjectiveInfo(objectiveTitle)
    if not objectiveInfo then return end
    local numTrackers = #objectiveInfo.trackers

    ------------------------------------------------------------

    tooltip:AddLine(objectiveTitle)

    GameTooltip_AddBlankLinesToTooltip(tooltip, 1)
    if objectiveInfo.displayRef.trackerType and objectiveInfo.displayRef.trackerID then
        if  objectiveInfo.displayRef.trackerType == "MACROTEXT" then
            tooltip:AddDoubleLine(L["Display Ref"], strsub(objectiveInfo.displayRef.trackerID, 1, 15)..(strlen(objectiveInfo.displayRef.trackerID) > 15 and "..." or ""), unpack(self.tooltip_keyvalue))
        else
            self:GetTrackerDataTable(objectiveInfo.displayRef.trackerType, objectiveInfo.displayRef.trackerID, function(data)
                tooltip:AddDoubleLine(L["Display Ref"],  strsub(data.name, 1, 15)..(strlen(data.name) > 15 and "..." or ""), unpack(self.tooltip_keyvalue))
            end)
        end
    else
        tooltip:AddDoubleLine(L["Display Ref"], L["None"], unpack(self.tooltip_keyvalue))
    end
    tooltip:AddDoubleLine(L["Tracker Condition"], L[strsub(objectiveInfo.trackerCondition, 1, 1)..strlower(strsub(objectiveInfo.trackerCondition, 2))], unpack(self.tooltip_keyvalue))

    GameTooltip_AddBlankLinesToTooltip(tooltip, 1)
    tooltip:AddDoubleLine(L["Trackers"], numTrackers, unpack(self.tooltip_keyvalue))
    for key, trackerInfo in pairs(objectiveInfo.trackers) do
        if key > 10 then
            tooltip:AddLine(format("%d %s...", numTrackers - 10, L["more"]), unpack(self.tooltip_description))
            tooltip:AddTexture(134400)
            break
        else
            self:GetTrackerDataTable(trackerInfo.trackerType, trackerInfo.trackerID, function(data)
                tooltip:AddDoubleLine(data.name, trackerInfo.objective, unpack(self.tooltip_description))
                tooltip:AddTexture(data.icon or 134400)
            end)
        end
    end

    ------------------------------------------------------------

    GameTooltip_AddBlankLinesToTooltip(tooltip, 1)
    if FarmingBar.db.global.hints.ObjectiveBuilder then
        tooltip:AddLine(format("%s:", L["Hint"]))
        tooltip:AddLine(L.ObjectiveContextMenuHint, unpack(addon.tooltip_description))
    end
end

------------------------------------------------------------

function addon:GetNewObjectiveButtonTooltip(widget, tooltip)
    tooltip:AddLine(format("%s:", L["Hint"]))
    tooltip:AddLine(L.NewObjectiveHint, unpack(addon.tooltip_description))
end

------------------------------------------------------------

function addon:GetTrackerButtonTooltip(widget, tooltip)
    local _, objectiveInfo = addon.ObjectiveBuilder:GetSelectedObjectiveInfo()
    local tracker = widget:GetTrackerKey()
    local trackerInfo = objectiveInfo.trackers[tracker]
    if not trackerInfo then return end
    local numExcluded = #trackerInfo.exclude

    ------------------------------------------------------------

    tooltip:SetHyperlink(format("%s:%s", string.lower(trackerInfo.trackerType), trackerInfo.trackerID))

    GameTooltip_AddBlankLinesToTooltip(tooltip, 1)
    tooltip:AddDoubleLine(L["Objective"], trackerInfo.objective or L["FALSE"], unpack(addon.tooltip_keyvalue))
    tooltip:AddDoubleLine(L["Include Bank"], trackerInfo.includeBank and L["TRUE"] or L["FALSE"], unpack(addon.tooltip_keyvalue))
    tooltip:AddDoubleLine(L["Include All Characters"], trackerInfo.includeAllCharacters and L["TRUE"] or L["FALSE"], unpack(addon.tooltip_keyvalue))

    GameTooltip_AddBlankLinesToTooltip(tooltip, 1)
    tooltip:AddDoubleLine(L["Excluded"], numExcluded, unpack(addon.tooltip_keyvalue))
    for key, excludedTitle in pairs(trackerInfo.exclude) do
        if key > 10 then
            tooltip:AddLine(format("%d %s...", numExcluded - 10, L["more"]), unpack(addon.tooltip_description))
            tooltip:AddTexture(134400)
            break
        else
            tooltip:AddLine(excludedTitle)
            tooltip:AddTexture(addon:GetObjectiveIcon(excludedTitle))
        end
    end

    ------------------------------------------------------------

    GameTooltip_AddBlankLinesToTooltip(tooltip, 1)
    if FarmingBar.db.global.hints.ObjectiveBuilder then
        tooltip:AddLine(format("%s:", L["Hint"]))
        tooltip:AddLine(L.TrackerContextMenuHint, unpack(addon.tooltip_description))
    end
end