local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

local pairs, unpack = pairs, unpack
local strlen, strformat, strsub = string.len, string.format, string.sub
local GameTooltip_AddBlankLinesToTooltip = GameTooltip_AddBlankLinesToTooltip

-- !Note: tooltip functions from AceGUI widgets will not have a self reference

--*------------------------------------------------------------------------

function addon:GetExcludeListLabelTooltip(widget, tooltip)
    if FarmingBar.db.global.hints.ObjectiveBuilder then
        tooltip:AddLine(strformat("%s:", L["Hint"]))
        tooltip:AddLine(L.RemoveExcludeHint, unpack(addon.tooltip_description))
    end
end

------------------------------------------------------------

function addon:GetObjectiveButtonTooltip(widget, tooltip)
    local objectiveTitle = widget:GetUserData("objectiveTitle")
    local objectiveInfo = addon:GetObjectiveInfo(objectiveTitle)
    if not objectiveInfo then return end
    local numTrackers = #objectiveInfo.trackers

    ------------------------------------------------------------

    tooltip:AddLine(objectiveTitle)

    GameTooltip_AddBlankLinesToTooltip(tooltip, 1)
    tooltip:AddDoubleLine(L["Enabled"], objectiveInfo.enabled and L["TRUE"] or L["FALSE"], unpack(addon.tooltip_keyvalue))
    tooltip:AddDoubleLine(L["Objective"], objectiveInfo.objective or L["FALSE"], unpack(addon.tooltip_keyvalue))

    GameTooltip_AddBlankLinesToTooltip(tooltip, 1)
    if objectiveInfo.displayRef.trackerType and objectiveInfo.displayRef.trackerID then
        if  objectiveInfo.displayRef.trackerType == "MACROTEXT" then
            tooltip:AddDoubleLine(L["Display Ref"], strsub(objectiveInfo.displayRef.trackerID, 1, 10)..(strlen(objectiveInfo.displayRef.trackerID) > 10 and "..." or ""), unpack(addon.tooltip_keyvalue))
        else
            addon:GetTrackerDataTable(objectiveInfo.displayRef.trackerType, objectiveInfo.displayRef.trackerID, function(data)
                tooltip:AddDoubleLine(L["Display Ref"], data.name, unpack(addon.tooltip_keyvalue))
            end)
        end
    else
        tooltip:AddDoubleLine(L["Display Ref"], L["NONE"], unpack(addon.tooltip_keyvalue))
    end

    GameTooltip_AddBlankLinesToTooltip(tooltip, 1)
    tooltip:AddDoubleLine(L["Trackers"], numTrackers, unpack(addon.tooltip_keyvalue))
    for key, trackerInfo in pairs(objectiveInfo.trackers) do
        if key > 10 then
            tooltip:AddLine(strformat("%d %s...", numTrackers - 10, L["more"]), unpack(addon.tooltip_description))
            tooltip:AddTexture(134400)
            break
        else
            addon:GetTrackerDataTable(trackerInfo.trackerType, trackerInfo.trackerID, function(data)
                tooltip:AddDoubleLine(data.name, trackerInfo.objective, unpack(addon.tooltip_description))
                tooltip:AddTexture(data.icon or 134400)
            end)
        end
    end

    ------------------------------------------------------------

    GameTooltip_AddBlankLinesToTooltip(tooltip, 1)
    if FarmingBar.db.global.hints.ObjectiveBuilder then
        tooltip:AddLine(string.format("%s:", L["Hint"]))
        tooltip:AddLine(L.ObjectiveContextMenuHint, unpack(addon.tooltip_description))
    end
end

------------------------------------------------------------

function addon:GetNewObjectiveButtonTooltip(widget, tooltip)
    tooltip:AddLine(strformat("%s:", L["Hint"]))
    tooltip:AddLine(L.NewObjectiveHint, unpack(addon.tooltip_description))
end

------------------------------------------------------------

function addon:GetTrackerButtonTooltip(widget, tooltip)
    local _, _, tracker, trackerInfo = addon:GetSelectedObjectiveInfo()
    if not trackerInfo then return end
    local numExcluded = #trackerInfo.exclude

    ------------------------------------------------------------

    tooltip:SetHyperlink(string.format("%s:%s", string.lower(trackerInfo.trackerType), trackerInfo.trackerID))

    GameTooltip_AddBlankLinesToTooltip(tooltip, 1)
    tooltip:AddDoubleLine(L["Objective"], trackerInfo.objective or L["FALSE"], unpack(addon.tooltip_keyvalue))
    tooltip:AddDoubleLine(L["Include Bank"], trackerInfo.includeBank and L["TRUE"] or L["FALSE"], unpack(addon.tooltip_keyvalue))
    tooltip:AddDoubleLine(L["Include All Characters"], trackerInfo.includeAllCharacters and L["TRUE"] or L["FALSE"], unpack(addon.tooltip_keyvalue))

    GameTooltip_AddBlankLinesToTooltip(tooltip, 1)
    tooltip:AddDoubleLine(L["Excluded"], numExcluded, unpack(addon.tooltip_keyvalue))
    for key, excludedTitle in pairs(trackerInfo.exclude) do
        if key > 10 then
            tooltip:AddLine(string.format("%d %s...", numExcluded - 10, L["more"]), unpack(addon.tooltip_description))
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
        tooltip:AddLine(string.format("%s:", L["Hint"]))
        tooltip:AddLine(L.TrackerContextMenuHint, unpack(addon.tooltip_description))
    end
end