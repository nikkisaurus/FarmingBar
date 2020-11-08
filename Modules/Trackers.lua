local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)
local AceGUI = LibStub("AceGUI-3.0", true)

local strupper, tonumber = string.upper, tonumber
local floor, min = math.floor, math.min
local wipe = table.wipe

--*------------------------------------------------------------------------

function addon:CreateTracker(tracker)
    local ObjectiveBuilder = self.ObjectiveBuilder
    local objectiveTitle, objectiveInfo = ObjectiveBuilder:GetSelectedObjectiveInfo()

    ------------------------------------------------------------

    local defaultTracker = self:GetDefaultTracker()

    if tracker then
        local trackerType, trackerID
        if type(tracker) == "table" then
            trackerType = tracker.trackerType
            trackerID = tracker.trackerID
        else
            -- Create tracker from cursor
            local cursorType, cursorID = GetCursorInfo()
            ClearCursor()

            if cursorType == "item" then
                trackerType = "ITEM"
                trackerID = cursorID
            end
        end

        if not self:TrackerExists(trackerID) then
            defaultTracker.trackerType = trackerType
            defaultTracker.trackerID = trackerID
        else
            addon:ReportError(L.TrackerIDExists(trackerID))
            return
        end
    end

    tinsert(FarmingBar.db.global.objectives[objectiveTitle].trackers, defaultTracker)
    local newTracker = #FarmingBar.db.global.objectives[objectiveTitle].trackers

    ------------------------------------------------------------

    local trackerList = ObjectiveBuilder:GetUserData("trackerList")
    local button = addon:AddTrackerButton(newTracker, defaultTracker)

    for _, button in pairs(trackerList.children) do
        button:SetSelected(false)
    end

    ObjectiveBuilder:SelectTracker(newTracker)
    button:SetSelected(true)
    trackerList.scrollbar:SetValue(1000)

    ------------------------------------------------------------

    self:UpdateButtons(objectiveTitle)
end

------------------------------------------------------------

function addon:DeleteTracker()
    local ObjectiveBuilder = self.ObjectiveBuilder
    local trackerList = ObjectiveBuilder:GetUserData("trackerList")
    local objectiveTitle, objectiveInfo = ObjectiveBuilder:GetSelectedObjectiveInfo()

    ------------------------------------------------------------

    local releaseKeys = {}
    for key, button in pairs(trackerList.children) do
        if button:GetUserData("selected") then
            if ObjectiveBuilder:GetSelectedTracker() == key then
                ObjectiveBuilder:ClearSelectedTracker()
            end

            FarmingBar.db.global.objectives[objectiveTitle].trackers[key] = nil
            tinsert(releaseKeys, key)
        end
    end

    -- Release buttons after the initial loop, backwards, to ensure all buttons are properly released
    for _, key in addon.pairs(releaseKeys, function(a, b) return b < a end) do
        ObjectiveBuilder:ReleaseChild(trackerList.children[key])
    end

    ------------------------------------------------------------

    -- Reindex trackers table so trackerList buttons aren't messed up
    local trackers = {}
    for _, trackerInfo in pairs(objectiveInfo.trackers) do
        tinsert(trackers, trackerInfo)
    end

    FarmingBar.db.global.objectives[objectiveTitle].trackers = trackers

    ------------------------------------------------------------

    -- Update tracker button keys
    for key, button in pairs(trackerList.children) do
        button:SetUserData("trackerKey", key)
    end

    ------------------------------------------------------------

    trackerList:DoLayout()
    self:UpdateButtons(objectiveTitle)
end

------------------------------------------------------------

function addon:GetTrackerCount(trackerInfo)
    if not trackerInfo then return 0 end
    local count

    if trackerInfo.trackerType == "ITEM" then
        count = GetItemCount(trackerInfo.trackerID, trackerInfo.includeBank)
    elseif trackerInfo.trackerType == "CURRENCY" and trackerInfo.trackerID ~= "" then
        count = C_CurrencyInfo.GetCurrencyInfo(trackerInfo.trackerID) and C_CurrencyInfo.GetCurrencyInfo(trackerInfo.trackerID).quantity
    end

    if not count then
        return 0
    end

    count = math.floor(count / trackerInfo.objective)

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

    return count > 0 and count or 0
end

------------------------------------------------------------

function addon:GetTrackerDataTable(...)
    local dataType = select(1, ...)
    local dataID = select(2, ...)
    local callback = select(3, ...)

    if dataType == "ITEM" then
        self:CacheItem(dataID, function(dataType, dataID, callback)
            local name, _, _, _, _, _, _, _, _, icon = GetItemInfo(dataID)
            local data = {name = (not name or name == "") and L["Invalid Tracker"] or name, icon = icon or 134400, label = addon:GetTrackerTypeLabel(dataType), trackerType = dataType, trackerID = dataID}

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
    return FarmingBar.db.global.objectives[objectiveTitle] and FarmingBar.db.global.objectives[objectiveTitle].trackers[tracker]
end

------------------------------------------------------------

function addon:GetTrackerTypeLabel(trackerType)
    --@retail@
    return trackerType == "ITEM" and L["Item ID/Name/Link"] or L["Currency ID/Link"]
    --@end-retail@
    --[===[@non-retail@
    return L["Item ID/Name/Link"]
    --@end-non-retail@]===]
end

------------------------------------------------------------

function addon:MoveTracker(currentKey, direction)
    local ObjectiveBuilder = self.ObjectiveBuilder
    local objectiveTitle, objectiveInfo = ObjectiveBuilder:GetSelectedObjectiveInfo()

    local currentInfo = objectiveInfo.trackers[currentKey]
    local currentButton = ObjectiveBuilder:GetTrackerButton(currentInfo)

    local destinationKey = currentKey + direction
    local destinationInfo = objectiveInfo.trackers[destinationKey]
    local destinationButton = ObjectiveBuilder:GetTrackerButton(destinationInfo)

    ------------------------------------------------------------

    -- Swap trackerInfo in the database
    FarmingBar.db.global.objectives[objectiveTitle].trackers[currentKey] = destinationInfo
    FarmingBar.db.global.objectives[objectiveTitle].trackers[destinationKey] = currentInfo

    ------------------------------------------------------------

    -- Update the trackers on buttons to make sure they have the correct information
    for tracker, trackerInfo in pairs(objectiveInfo.trackers) do
        ObjectiveBuilder:GetUserData("trackerList").children[tracker]:SetTracker(tracker, trackerInfo)
    end

    -- Reselect the current tracker
    destinationButton:Select()

    ------------------------------------------------------------

    -- Refresh counts
    addon:UpdateButtons(objectiveTitle)
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

    addon:UpdateButtons(objectiveTitle)
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
        return (GetItemInfoInstant(trackerID or 0)), "ITEM"
    elseif trackerType == "CURRENCY" then
        local isLink = C_CurrencyInfo.GetCurrencyInfoFromLink(trackerID)
        trackerID = isLink and C_CurrencyInfo.GetCurrencyIDFromLink(trackerID) or tonumber(trackerID) or 0
        local currency = C_CurrencyInfo.GetCurrencyInfo(trackerID)

        return currency and trackerID, "CURRENCY"
    elseif trackerID == "" then
        return true, "NONE"
    end
end