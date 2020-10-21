local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)
local AceGUI = LibStub("AceGUI-3.0", true)

local strupper, tonumber = string.upper, tonumber

--*------------------------------------------------------------------------

function addon:CreateTracker(fromCursor)
    local ObjectiveBuilder = self.ObjectiveBuilder
    local objectiveTitle = self:GetSelectedObjectiveInfo()
    local trackersTable = FarmingBar.db.global.objectives[objectiveTitle].trackers
    local trackerStatus = ObjectiveBuilder.trackerList.status

    ------------------------------------------------------------

    if fromCursor then
        -- Create tracker from cursor
        local cursorType, cursorID = GetCursorInfo()
        ClearCursor()

        if cursorType == "item" and not self:TrackerExists(cursorID) then
            tinsert(trackersTable, {
                ["trackerType"] = "ITEM",
                ["trackerID"] = cursorID,
                ["objective"] = 1,
                ["includeBank"] = false,
                ["includeAllChars"] = false,
                ["exclude"] = {
                },
            })
        else
            addon:ReportError(L.TrackerIDExists(cursorID))
            return
        end
    else
        tinsert(trackersTable, {
            ["trackerType"] = "ITEM",
            ["trackerID"] = "",
            ["objective"] = 1,
            ["includeBank"] = false,
            ["includeAllChars"] = false,
            ["exclude"] = {
            },
        })
    end

    ------------------------------------------------------------

    ObjectiveBuilder:LoadTrackers()
    trackerStatus.children[#trackersTable].button.frame:Click()
    if not fromCursor then
        C_Timer.After(.01, function()
            trackerStatus.trackerID:SetFocus()
        end)
    end
end

------------------------------------------------------------

function addon:DeleteTracker()
    local ObjectiveBuilder = self.ObjectiveBuilder
    local trackersTable = FarmingBar.db.global.objectives[(self:GetSelectedObjectiveInfo())].trackers

    ------------------------------------------------------------

    local trackers = {}
    for k, v in pairs(ObjectiveBuilder.trackerList.status.children) do
        if v.button.selected then
            trackersTable[k] = nil
        end
    end

    ------------------------------------------------------------

    -- Reindex trackers table so trackerList buttons aren't messed up
    for k, v in pairs(trackersTable) do
        tinsert(trackers, v)
    end
    trackersTable = trackers

    ------------------------------------------------------------

    ObjectiveBuilder:LoadTrackers()
    self:ObjectiveBuilder_LoadTrackerInfo()
end

------------------------------------------------------------

function addon:GetTrackerCount(trackerType, trackerID)
    if trackerType == "ITEM" then
        return GetItemCount(trackerID)
    elseif trackerType == "CURRENCY" then
        return C_CurrencyInfo.GetCurrencyInfo(trackerID) and C_CurrencyInfo.GetCurrencyInfo(trackerID).quantity
    end
end

------------------------------------------------------------

function addon:GetTrackerDataTable(...)
    local dataType = select(1, ...)
    local dataID = select(2, ...)
    local callback = select(3, ...)

    if dataType == "ITEM" then
        self:CacheItem(dataID, function(dataType, dataID, callback)
            local name, _, _, _, _, _, _, _, _, icon = GetItemInfo(dataID)
            local data = {name = name == "" and L["Invalid Tracker"] or name, icon = icon, label = addon:GetTrackerTypeLabel(dataType), trackerType = dataType, trackerID = dataID}

            if callback then
                callback(data)
            else
                return data
            end
        end, ...)
    elseif dataType == "CURRENCY" then
        local currency = C_CurrencyInfo.GetCurrencyInfo(tonumber(dataID) or 0)
        local data = {name = currency and currency.name or L["Invalid Tracker"], icon = currency and currency.iconFileID or 134400, label = addon:GetTrackerTypeLabel(dataType), trackerType = dataType, trackerID = dataID}

        if callback then
            callback(data)
        else
            return data
        end
    end
end

------------------------------------------------------------

function addon:GetTrackerInfo(objectiveTitle, tracker)
    return FarmingBar.db.global.objectives[objectiveTitle].trackers[tracker]
end

------------------------------------------------------------

function addon:GetTrackerTypeLabel(trackerType)
    --@retail@
    return trackerType == "ITEM" and L["Item ID/Name/Link"] or L["Currency ID"]
    --@end-retail@
    --[===[@non-retail@
    return L["Item ID/Name/Link"]
    --@end-non-retail@]===]
end

------------------------------------------------------------

function addon:IsTrackerComplete(objectiveTitle, tracker)
    local trackerInfo = self:GetTrackerInfo(objectiveTitle, tracker)

    return addon:GetTrackerCount(trackerInfo.trackerType, trackerInfo.trackerID) >= trackerInfo.objective
end

------------------------------------------------------------

function addon:SetTrackerDBInfo(objectiveTitle, tracker, key, value)
    local keys = {strsplit(".", key)}
    local path = FarmingBar.db.global.objectives[objectiveTitle].trackers[tracker]
    for k, key in pairs(keys) do
        if k < #keys then
            path = path[key]
        end
    end
    path[keys[#keys]] = value
end

------------------------------------------------------------

function addon:TrackerExists(trackerID)
    for _, tracker in pairs(FarmingBar.db.global.objectives[(self:GetSelectedObjectiveInfo())].trackers) do
        if tracker.trackerID == trackerID then
            return true
        end
    end
end

------------------------------------------------------------

function addon:UpdateExclusions(objectiveTitle, newObjectiveTitle)
    for _, objectiveInfo in pairs(FarmingBar.db.global.objectives) do
        for _, trackerInfo in pairs(objectiveInfo.trackers) do
            local removeKey = self.GetTableKey(trackerInfo.exclude, objectiveTitle)
            if removeKey then
                tremove(trackerInfo.exclude, removeKey)
                if newObjectiveTitle then
                    tinsert(trackerInfo.exclude, newObjectiveTitle)
                end
            end
        end
    end
end

------------------------------------------------------------

function addon:ValidateObjectiveData(trackerType, trackerID)
    if trackerType == "ITEM" then
        return (GetItemInfoInstant(trackerID))
    elseif trackerType == "CURRENCY" then
        local currency = C_CurrencyInfo.GetCurrencyInfo(tonumber(trackerID) or 0)
        return currency and currency.name
    end
end