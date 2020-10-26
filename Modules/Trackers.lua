local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)
local AceGUI = LibStub("AceGUI-3.0", true)

local strupper, tonumber = string.upper, tonumber
local floor, min = math.floor, math.min

--*------------------------------------------------------------------------

function addon:CreateTracker(fromCursor)
    local ObjectiveBuilder = self.ObjectiveBuilder
    local objectiveTitle = self:GetSelectedObjectiveInfo()
    local trackersTable = FarmingBar.db.global.objectives[objectiveTitle].trackers
    local trackerStatus = ObjectiveBuilder.trackerList.status

    ------------------------------------------------------------

    local defaultTracker = addon:GetDefaultTracker()

    if fromCursor then
        -- Create tracker from cursor
        local cursorType, cursorID = GetCursorInfo()
        ClearCursor()

        if cursorType == "item" and not self:TrackerExists(cursorID) then
            defaultTracker.trackerType = "ITEM"
            defaultTracker.trackerID = cursorID
        else
            addon:ReportError(L.TrackerIDExists(cursorID))
            return
        end
    end

    tinsert(trackersTable, defaultTracker)

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

function addon:GetTrackerCount(trackerInfo)
    local count

    if trackerInfo.trackerType == "ITEM" then
        count = GetItemCount(trackerInfo.trackerID, trackerInfo.includeBank)
    elseif trackerInfo.trackerType == "CURRENCY" then
        count = C_CurrencyInfo.GetCurrencyInfo(trackerInfo.trackerID) and C_CurrencyInfo.GetCurrencyInfo(trackerInfo.trackerID).quantity
    end

    if #trackerInfo.exclude > 0 then
        for _, objectiveTitle in pairs(trackerInfo.exclude) do
            local objectiveInfo = addon:GetObjectiveInfo(objectiveTitle)
            -- Only exclude if enabled and an objective is set (otherwise, how do we know how many to exclude?)
            if addon:IsTrackingObjective(objectiveTitle) and objectiveInfo.objective and objectiveInfo.objective > 0 then
                for _, eTrackerInfo in pairs(objectiveInfo.trackers) do
                    if eTrackerInfo.trackerID == trackerInfo.trackerID then
                        -- Get the max amount used for the objective: either the objective itself or the count
                        local max = min(addon:GetObjectiveCount(objectiveTitle), objectiveInfo.objective)
                        -- The number of of this tracker required for the objective is the tracker objective x max
                        count = count - (eTrackerInfo.objective * max)
                    end
                end
            end
        end
    end

    return count
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

    return floor(addon:GetTrackerCount(trackerInfo) / trackerInfo.objective) or 0
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
    if value == "_toggle" then
        local val = path[keys[#keys]]
        if val then
            path[keys[#keys]] = false
        else
            path[keys[#keys]] = true
        end
    else
        path[keys[#keys]] = value
    end
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