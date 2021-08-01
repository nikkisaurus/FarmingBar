local addonName, ns = ...
local addon = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)


--*------------------------------------------------------------------------


local buttonCommandSort = {
    useItem = 1, -- right
    clearObjective = 2, -- shift+right
    moveObjective = 3, -- left
    dragObjective = 4, -- shift+left drag
    showObjectiveEditBox = 5, -- ctrl+left
    showQuickAddEditBox = 6, -- alt+left
    showQuickAddCurrencyEditBox = 7, -- alt+right
    showObjectiveEditor = 8, -- ctrl+right
    moveObjectiveToBank = 9, -- alt+ctrl+right
    moveAllToBank = 10, -- alt+ctrl+left
}


function addon:GetButtonTooltip(widget, tooltip)
    if not self:GetDBValue("global", "settings.tooltips.button") then return end

    local buttonDB = widget:GetButtonDB()
    if not buttonDB then return end

    -- Button has an objective
    if not widget:IsEmpty() then

        --  Set item or currency hyperlink
        if buttonDB.action and buttonDB.actionInfo and (buttonDB.action == "ITEM" or buttonDB.action == "CURRENCY") then
            tooltip:SetHyperlink(format("%s:%s", string.lower(buttonDB.action), buttonDB.actionInfo))

            -- Divider
            GameTooltip_AddBlankLinesToTooltip(FarmingBar_Tooltip, 1)
            GameTooltip_AddBlankLinesToTooltip(FarmingBar_Tooltip, 1)
            FarmingBar_Tooltip:AddTexture(389194, {width = 200, height = 10})
        end

        -- Objective title
        tooltip:AddDoubleLine(L["Title"], buttonDB.title, unpack(self.tooltip_keyvalue))
        -- Template
        tooltip:AddDoubleLine(L["Template"], buttonDB.template or L["NONE"], unpack(self.tooltip_keyvalue))

        -- Only show if hideObjectiveInfo is disabled
        if not self:GetDBValue("global", "settings.tooltips.hideObjectiveInfo") then
            self:GetButtonObjectiveInfo(widget, tooltip, buttonDB)
        end

        -- Spacer
        GameTooltip_AddBlankLinesToTooltip(tooltip, 1)
    end

    -- Button ID
    tooltip:AddDoubleLine("Button ID", widget:GetButtonID(), unpack(self.tooltip_keyvalue))

    -- Hints
    if self:GetDBValue("global", "settings.hints.buttons") then
        -- Spacer
        GameTooltip_AddBlankLinesToTooltip(FarmingBar_Tooltip, 1)

        if self:IsTooltipMod() then
            FarmingBar_Tooltip:AddLine(format("%s:", L["Hints"]))

            -- Button doesn't have objective
            if widget:IsEmpty() then
                FarmingBar_Tooltip:AddLine(L.ButtonHints("showQuickAddEditBox", self:GetDBValue("global", "settings.keybinds.button.showQuickAddEditBox")), unpack(self.tooltip_description))
            else
                for k, v in self.pairs(self:GetDBValue("global", "settings.keybinds.button"), function(a, b) return buttonCommandSort[a] < buttonCommandSort[b] end) do
                    if buttonDB or v.showOnEmpty then --! Not sure why we're checking for v.showOnEmpty?
                        FarmingBar_Tooltip:AddLine(L.ButtonHints(k, v), unpack(self.tooltip_description))
                    end
                end
            end
        else
            tooltip:AddDoubleLine(L["Show Hints"]..":", L[self:GetDBValue("global", "settings.hints.modifier")], unpack(self.tooltip_keyvalue))
        end
    end
end


function addon:GetButtonObjectiveInfo(widget, tooltip, buttonDB)
    --  Display action type and info
    if buttonDB.action and buttonDB.actionInfo then
        if  buttonDB.action == "MACROTEXT" then -- MACROTEXT
            tooltip:AddDoubleLine(L["Action"], strsub(buttonDB.actionInfo, 1, 15)..(strlen(buttonDB.actionInfo) > 15 and "..." or ""), unpack(self.tooltip_keyvalue))
        else
            self:GetTrackerDataTable(buttonDB, buttonDB.action, buttonDB.actionInfo, function(data) -- OTHERS
                tooltip:AddDoubleLine(L["Action"],  strsub(data.name, 1, 15)..(strlen(data.name) > 15 and "..." or ""), unpack(self.tooltip_keyvalue))
            end)
        end
    else -- NONE
        tooltip:AddDoubleLine(L["Action"], L["None"], unpack(self.tooltip_keyvalue))
    end
    -- Tracker condition
    tooltip:AddDoubleLine(L["Condition"], L[strsub(buttonDB.condition, 1, 1)..strlower(strsub(buttonDB.condition, 2))], unpack(self.tooltip_keyvalue))

    -- Spacer
    GameTooltip_AddBlankLinesToTooltip(tooltip, 1)

    -- Count
    local count = widget:GetCount()
    tooltip:AddDoubleLine(L["Count"], self.iformat(count, 1), unpack(self.tooltip_keyvalue))
    -- Include ...
    local numTrackers = self.tcount(buttonDB.trackers)
    if numTrackers == 1 then
        tooltip:AddDoubleLine(L["Include All Characters"], buttonDB.trackers[self:GetFirstTracker(widget)].includeAllChars and L["TRUE"] or L["FALSE"], unpack(self.tooltip_description))
        tooltip:AddDoubleLine(L["Include Bank"], buttonDB.trackers[self:GetFirstTracker(widget)].includeBank and L["TRUE"] or L["FALSE"], unpack(self.tooltip_description))
        tooltip:AddDoubleLine(L["Include Guild Bank"], buttonDB.trackers[self:GetFirstTracker(widget)].includeGuildBank and L["TRUE"] or L["FALSE"], unpack(self.tooltip_description))
    else
        -- TODO: multi-tracker includes
        -- number of trackers enabled / total number of trackers
    end
    -- Objective
    local objective = widget:GetObjective()
    tooltip:AddDoubleLine(L["Objective"], (objective and objective > 0) and objective or L["FALSE"], unpack(self.tooltip_keyvalue))
    if objective and objective > 0 then
        tooltip:AddDoubleLine(L["Objective Complete"], count >= objective and floor(count / objective).."x" or L["FALSE"], unpack(self.tooltip_description))
    end

    -- Spacer
    GameTooltip_AddBlankLinesToTooltip(tooltip, 1)

    -- Trackers
    tooltip:AddDoubleLine(L["Trackers"], numTrackers, unpack(self.tooltip_keyvalue))
    local trackerCount = 0
    for key, trackerInfo in pairs(buttonDB.trackers) do
        trackerCount = trackerCount + 1

        if trackerCount > self.maxTooltipTrackers then -- Shorten list
            tooltip:AddLine(format("%d %s...", numTrackers - self.maxTooltipTrackers, L["more"]), unpack(self.tooltip_description))
            tooltip:AddTexture(134400)
            break
        else
            local trackerType, trackerID = self:ParseTrackerKey(key)

            self:GetTrackerDataTable(buttonDB, trackerType, trackerID, function(data)
                -- Get count
                local trackerCount = self:GetTrackerCount(widget, key)
                local trackerRawCount

                if trackerType == "ITEM" then
                    trackerRawCount = trackerInfo.includeAllChars and self:GetDataStoreItemCount(trackerID, trackerInfo.includeBank) or GetItemCount(trackerID, trackerInfo.includeBank)
                elseif trackerType == "CURRENCY" and trackerID ~= "" then
                    trackerRawCount = C_CurrencyInfo.GetCurrencyInfo(trackerID) and C_CurrencyInfo.GetCurrencyInfo(trackerID).quantity
                end

                -- If custom condition, display trackerRawCount instead of the default counter
                if data.conditionInfo == "" then
                    tooltip:AddDoubleLine(data.name, format("%d%s (%d / %d)", trackerCount, (objective and objective > 0) and " / "..(objective * trackerInfo.objective) or "", trackerRawCount, trackerInfo.objective and trackerInfo.objective > 0 and trackerInfo.objective or 1), unpack(self.tooltip_description))
                else
                    tooltip:AddDoubleLine(data.name, trackerRawCount, unpack(self.tooltip_description))
                end

                tooltip:AddTexture(data.icon or 134400)
            end)
        end
    end

end