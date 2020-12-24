local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

local pairs, unpack = pairs, unpack
local format, strlen, strlower, strsub = string.format, string.len, string.lower, string.sub
local GameTooltip_AddBlankLinesToTooltip = GameTooltip_AddBlankLinesToTooltip

local GetItemCount, GetCurrencyInfo = GetItemCount, C_CurrencyInfo and C_CurrencyInfo.GetCurrencyInfo

--*------------------------------------------------------------------------

local barCommandSort = {
    moveBar = 1,
    configBar = 2,
    toggleMovable = 3,
    openSettings = 4,
    openHelp = 5,
}

local buttonCommandSort = {
    useItem = 1,
    clearObjective = 2,
    moveObjective = 3,
    dragObjective = 4,
    includeBank = 5,
    showObjectiveEditBox = 6,
    showObjectiveBuilder = 7,
}

--*------------------------------------------------------------------------

local tooltipScanner = CreateFrame("Frame")

local showTooltip
tooltipScanner:SetScript("OnUpdate", function(self)
    local frame = GetMouseFocus()
    local widget = frame and frame.obj
    local tooltip = widget and widget.GetUserData and widget:GetUserData("tooltip")
    if tooltip and addon[tooltip] then
        showTooltip = true
        GameTooltip:ClearLines()
        GameTooltip:SetOwner(frame, "ANCHOR_BOTTOMRIGHT", 0, 0)
        addon[tooltip](addon, widget, GameTooltip)
        GameTooltip:Show()
    elseif showTooltip then
        showTooltip = false
        GameTooltip:ClearLines()
        GameTooltip:Hide()
    end
end)

--*------------------------------------------------------------------------

function addon:IsTooltipMod()
    if not FarmingBar.db.global.hints.enableModifier then
        return true
    else
        return _G["Is" .. FarmingBar.db.global.hints.modifier .. "KeyDown"]()
    end
end

--*------------------------------------------------------------------------

function addon:GetBarTooltip(widget, tooltip)
    if not FarmingBar.db.global.tooltips.bar then return end
    local barDB = widget:GetUserData("barDB")

    tooltip:AddLine(self:GetBarTitle(widget:GetBarID()), 0, 1, 0, 1)

    GameTooltip_AddBlankLinesToTooltip(tooltip, 1)

    -- local progressCount, progressTotal = bar:GetProgress()
    local progressCount, progressTotal = 0, 0 --!

    tooltip:AddDoubleLine(L["Progress"], barDB.trackProgress and string.format("%s/%s", progressCount, progressTotal) or L["FALSE"], unpack(self.tooltip_keyvalue))
    tooltip:AddDoubleLine(L["Growth Direction"], L[strsub(barDB.grow[1], 1, 1)..strlower(strsub(barDB.grow[1], 2))], unpack(self.tooltip_keyvalue))
    tooltip:AddDoubleLine(L["Growth Type"], L[strsub(barDB.grow[2], 1, 1)..strlower(strsub(barDB.grow[2], 2))], unpack(self.tooltip_keyvalue))
    tooltip:AddDoubleLine(L["Number of Buttons"], barDB.numVisibleButtons.."/"..self.maxButtons, unpack(self.tooltip_keyvalue))
    tooltip:AddDoubleLine(L["Alpha"], self.round(barDB.alpha * 100, 2).."%", unpack(self.tooltip_keyvalue))
    tooltip:AddDoubleLine(L["Scale"], self.round(barDB.scale * 100, 2).."%", unpack(self.tooltip_keyvalue))
    tooltip:AddDoubleLine(L["Movable"], barDB.movable and L["TRUE"] or L["FALSE"], unpack(self.tooltip_keyvalue))

    if FarmingBar.db.global.hints.bars then
        GameTooltip_AddBlankLinesToTooltip(GameTooltip, 1)
        if self:IsTooltipMod() then
            GameTooltip:AddLine(format("%s:", L["Hints"]))
            for k, v in self.pairs(FarmingBar.db.global.keybinds.bar, function(a, b) return barCommandSort[a] < barCommandSort[b] end) do
                GameTooltip:AddLine(L.BarHints(k, v), unpack(self.tooltip_description))
            end
        else
            tooltip:AddDoubleLine(L["Show Hints"]..":", L[FarmingBar.db.global.hints.modifier], unpack(self.tooltip_keyvalue))
        end
    end
end

------------------------------------------------------------

function addon:GetButtonTooltip(widget, tooltip)
    if not FarmingBar.db.global.tooltips.button then return end
    local objectiveTitle = widget:GetUserData("objectiveTitle")
    local objectiveInfo = self:GetObjectiveInfo(objectiveTitle)

    ------------------------------------------------------------

    if objectiveInfo then
        local numTrackers = #objectiveInfo.trackers
        local count = widget:GetCount()
        local objective = widget:GetObjective()

        if objectiveInfo.displayRef.trackerType and objectiveInfo.displayRef.trackerID and (objectiveInfo.displayRef.trackerType == "ITEM" or objectiveInfo.displayRef.trackerType == "CURRENCY") then
            tooltip:SetHyperlink(format("%s:%s", string.lower(objectiveInfo.displayRef.trackerType), objectiveInfo.displayRef.trackerID))

            -- Divider
            GameTooltip_AddBlankLinesToTooltip(GameTooltip, 1)
            GameTooltip_AddBlankLinesToTooltip(GameTooltip, 1)
            GameTooltip:AddTexture(389194, {width = 200, height = 10})
        end

        tooltip:AddLine(objectiveTitle, 0, 1, 0, 1)

        if not FarmingBar.db.global.tooltips.hideObjectiveInfo then
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

            tooltip:AddDoubleLine(L["Count"], self.iformat(count, 1), unpack(self.tooltip_keyvalue))

            tooltip:AddDoubleLine(L["Objective"], objective or L["FALSE"], unpack(self.tooltip_description))

            if objective then
                tooltip:AddDoubleLine(L["Objective Complete"], count >= objective and floor(count / objective).."x" or L["FALSE"], unpack(self.tooltip_description))
            end

            GameTooltip_AddBlankLinesToTooltip(tooltip, 1)

            tooltip:AddDoubleLine(L["Trackers"], numTrackers, unpack(self.tooltip_keyvalue))

            for key, trackerInfo in pairs(objectiveInfo.trackers) do
                if key > 10 then
                    tooltip:AddLine(format("%d %s...", numTrackers - 10, L["more"]), unpack(self.tooltip_description))
                    tooltip:AddTexture(134400)
                    break
                else
                    self:GetTrackerDataTable(trackerInfo.trackerType, trackerInfo.trackerID, function(data)
                        local trackerCount = self:GetTrackerCount(objectiveTitle, trackerInfo)

                        local trackerRawCount
                        if trackerInfo.trackerType == "ITEM" then
                            trackerRawCount = GetItemCount(trackerInfo.trackerID, trackerInfo.includeBank)
                        elseif trackerInfo.trackerType == "CURRENCY" and trackerInfo.trackerID ~= "" then
                            trackerRawCount = GetCurrencyInfo(trackerInfo.trackerID) and GetCurrencyInfo(trackerInfo.trackerID).quantity
                        end

                        tooltip:AddDoubleLine(data.name, format("%d/%d", trackerCount, trackerRawCount), unpack(self.tooltip_description))
                        tooltip:AddTexture(data.icon or 134400)
                    end)
                end
            end

        end

        GameTooltip_AddBlankLinesToTooltip(tooltip, 1)
    end

    ------------------------------------------------------------

    tooltip:AddDoubleLine("Button ID", widget:GetButtonID(), unpack(self.tooltip_keyvalue))

    if FarmingBar.db.global.hints.buttons then
        GameTooltip_AddBlankLinesToTooltip(GameTooltip, 1)
        if self:IsTooltipMod() then
            GameTooltip:AddLine(format("%s:", L["Hints"]))
            for k, v in self.pairs(FarmingBar.db.global.keybinds.button, function(a, b) return buttonCommandSort[a] < buttonCommandSort[b] end) do
                if objectiveInfo or v.showOnEmpty then
                    GameTooltip:AddLine(L.ButtonHints(k, v), unpack(self.tooltip_description))
                end
            end
        else
            tooltip:AddDoubleLine(L["Show Hints"]..":", L[FarmingBar.db.global.hints.modifier], unpack(self.tooltip_keyvalue))
        end
    end
end

------------------------------------------------------------

function addon:GetExcludeListLabelTooltip(widget, tooltip)
    if FarmingBar.db.global.hints.ObjectiveBuilder then
        if self:IsTooltipMod() then
            tooltip:AddLine(format("%s:", L["Hint"]))
            tooltip:AddLine(L.RemoveExcludeHint, unpack(self.tooltip_description))
        else
            tooltip:AddDoubleLine(L["Show Hints"]..":", L[FarmingBar.db.global.hints.modifier], unpack(self.tooltip_keyvalue))
        end
    end
end

------------------------------------------------------------

function addon:GetFilterAutoItemsTooltip(widget, tooltip)
    if FarmingBar.db.global.hints.ObjectiveBuilder then
        if self:IsTooltipMod() then
            GameTooltip:AddLine(format("%s:", L["Hint"]))
            GameTooltip:AddLine(L.FilterAutoItemsHint, unpack(self.tooltip_description))
        else
            tooltip:AddDoubleLine(L["Show Hints"]..":", L[FarmingBar.db.global.hints.modifier], unpack(self.tooltip_keyvalue))
        end
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

    if FarmingBar.db.global.hints.ObjectiveBuilder then
        GameTooltip_AddBlankLinesToTooltip(tooltip, 1)
        if self:IsTooltipMod() then
            tooltip:AddLine(format("%s:", L["Hint"]))
            tooltip:AddLine(L.ObjectiveContextMenuHint, unpack(self.tooltip_description))
        else
            tooltip:AddDoubleLine(L["Show Hints"]..":", L[FarmingBar.db.global.hints.modifier], unpack(self.tooltip_keyvalue))
        end
    end
end

------------------------------------------------------------

function addon:GetNewObjectiveButtonTooltip(widget, tooltip)
    if FarmingBar.db.global.hints.ObjectiveBuilder then
        if self:IsTooltipMod() then
            tooltip:AddLine(format("%s:", L["Hint"]))
            tooltip:AddLine(L.NewObjectiveHint, unpack(self.tooltip_description))
        else
            tooltip:AddDoubleLine(L["Show Hints"]..":", L[FarmingBar.db.global.hints.modifier], unpack(self.tooltip_keyvalue))
        end
    end
end

------------------------------------------------------------

function addon:GetTrackerButtonTooltip(widget, tooltip)
    local _, objectiveInfo = self.ObjectiveBuilder:GetSelectedObjectiveInfo()
    local tracker = widget:GetTrackerKey()
    local trackerInfo = objectiveInfo.trackers[tracker]
    if not trackerInfo then return end
    local numExcluded = #trackerInfo.exclude

    ------------------------------------------------------------

    tooltip:SetHyperlink(format("%s:%s", string.lower(trackerInfo.trackerType), trackerInfo.trackerID))

    GameTooltip_AddBlankLinesToTooltip(tooltip, 1)
    tooltip:AddDoubleLine(L["Objective"], trackerInfo.objective or L["FALSE"], unpack(self.tooltip_keyvalue))
    tooltip:AddDoubleLine(L["Include Bank"], trackerInfo.includeBank and L["TRUE"] or L["FALSE"], unpack(self.tooltip_keyvalue))
    tooltip:AddDoubleLine(L["Include All Characters"], trackerInfo.includeAllCharacters and L["TRUE"] or L["FALSE"], unpack(self.tooltip_keyvalue))

    GameTooltip_AddBlankLinesToTooltip(tooltip, 1)
    tooltip:AddDoubleLine(L["Excluded"], numExcluded, unpack(self.tooltip_keyvalue))
    for key, excludedTitle in pairs(trackerInfo.exclude) do
        if key > 10 then
            tooltip:AddLine(format("%d %s...", numExcluded - 10, L["more"]), unpack(self.tooltip_description))
            tooltip:AddTexture(134400)
            break
        else
            tooltip:AddLine(excludedTitle)
            tooltip:AddTexture(self:GetObjectiveIcon(excludedTitle))
        end
    end

    ------------------------------------------------------------

    if FarmingBar.db.global.hints.ObjectiveBuilder then
        GameTooltip_AddBlankLinesToTooltip(tooltip, 1)
        if self:IsTooltipMod() then
            tooltip:AddLine(format("%s:", L["Hint"]))
            tooltip:AddLine(L.TrackerContextMenuHint, unpack(self.tooltip_description))
        else
            tooltip:AddDoubleLine(L["Show Hints"]..":", L[FarmingBar.db.global.hints.modifier], unpack(self.tooltip_keyvalue))
        end
    end
end