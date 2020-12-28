local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)
local AceGUI = LibStub("AceGUI-3.0", true)

local select, type = select, type
local floor, min, max = math.floor, math.min, math.max
local format, strsplit, strupper, tonumber = string.format, strsplit, string.upper, tonumber
local pairs, tinsert, tremove, wipe = pairs, table.insert, table.remove, table.wipe

local GetItemCount, GetCurrencyInfo, GetCurrencyInfoFromLink, GetCurrencyIDFromLink = GetItemCount, C_CurrencyInfo and C_CurrencyInfo.GetCurrencyInfo, C_CurrencyInfo and C_CurrencyInfo.GetCurrencyInfoFromLink, C_CurrencyInfo and C_CurrencyInfo.GetCurrencyIDFromLink

--*------------------------------------------------------------------------

function addon:CreateTracker(objectiveTitle, tracker)
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

        if not self:TrackerExists(objectiveTitle, trackerID) then
            defaultTracker.trackerType = trackerType
            defaultTracker.trackerID = trackerID
        else
            addon:ReportError(format(L.TrackerIDExists, trackerID))
            return
        end
    end

    tinsert(FarmingBar.db.global.objectives[objectiveTitle].trackers, defaultTracker)
    local newTracker = #FarmingBar.db.global.objectives[objectiveTitle].trackers

    ------------------------------------------------------------

    -- local trackerList = ObjectiveBuilder:GetUserData("trackerList")
    -- local button = addon:AddTrackerButton(newTracker, defaultTracker)

    -- for _, button in pairs(trackerList.children) do
    --     button:SetSelected(false)
    -- end

    -- ObjectiveBuilder:SelectTracker(newTracker)
    -- button:SetSelected(true)
    -- trackerList.scrollbar:SetValue(1000)

    ------------------------------------------------------------

    self:UpdateButtons(objectiveTitle)
    self:RefreshObjectiveBuilderTrackerOptions(objectiveTitle)
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
    ObjectiveBuilder:RefreshObjectives()
end

------------------------------------------------------------

function addon:GetMaxTrackerObjective(objectiveTitle)
    local objective, objectiveButton
    for _, bar in pairs(self.bars) do
        for _, button in pairs(bar:GetUserData("buttons")) do
            local buttonObjectiveTitle = button:GetUserData("objectiveTitle")
            if buttonObjectiveTitle == objectiveTitle then
                local buttonObjective = button:GetObjective()
                if not objective then
                    objective = buttonObjective
                else
                    objective = max(objective or 0, buttonObjective or 0)
                    objectiveButton = objective == buttonObjective and button or objectiveButton
                end
            end
        end
    end
    return objective, objectiveButton
end

------------------------------------------------------------

function addon:GetTrackerCount(objectiveTitle, trackerInfo)
    local ObjectiveBuilder = addon.ObjectiveBuilder
    local objectiveInfo = self:GetObjectiveInfo(objectiveTitle)

    if not trackerInfo then return 0 end
    local count

    if trackerInfo.trackerType == "ITEM" then
        count = trackerInfo.includeAllChars and self:GetDataStoreCount(trackerInfo.trackerID, trackerInfo.includeBank) or GetItemCount(trackerInfo.trackerID, trackerInfo.includeBank)
    elseif trackerInfo.trackerType == "CURRENCY" and trackerInfo.trackerID ~= "" then
        count = GetCurrencyInfo(trackerInfo.trackerID) and GetCurrencyInfo(trackerInfo.trackerID).quantity
    end

    if not count then
        return 0
    end

    if #trackerInfo.exclude > 0 then
        for _, eObjectiveTitle in pairs(trackerInfo.exclude) do
            local eObjectiveInfo = addon:GetObjectiveInfo(eObjectiveTitle)
            local eObjective, eObjectiveButton = addon:GetMaxTrackerObjective(eObjectiveTitle)

            -- Only exclude if an objective is set (otherwise, how do we know how many to exclude?)
            if eObjective then
                for _, eTrackerInfo in pairs(eObjectiveInfo.trackers) do
                    if eTrackerInfo.trackerID == trackerInfo.trackerID then
                        -- Get the max amount used for the objective: either the objective itself or the count
                        local maxCount = min(addon:GetObjectiveCount(eObjectiveButton, eObjectiveTitle), eObjective)
                        -- The number of of this tracker required for the objective is the tracker objective x max
                        count = count - maxCount
                    end
                end
            end
        end
    end

    count = floor(count / trackerInfo.objective)

    -- If objective is excluded, get max objective
    -- If count > max objective while excluded, return max objective
    -- Surplus above objective goes toward the objective excluding this one
    -- Ex: if A has an objective of 20 and a count of 25 and B excludes A, A will show a count of 20 with objective complete and B will show a count of 5
    local objective
    for _, eObjectiveInfo in pairs(FarmingBar.db.global.objectives) do
        for _, eTrackerInfo in pairs(eObjectiveInfo.trackers) do
            if self:ObjectiveIsExcluded(eTrackerInfo.exclude, objectiveTitle) then
                objective = addon:GetMaxTrackerObjective(objectiveTitle)
                break
            end
        end
    end

    count = (count > 0 and count or 0) * (trackerInfo.countsFor or 1)

    return objective and min(count, objective) or count
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
        local currency = GetCurrencyInfo(tonumber(dataID) or 0)
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
    ObjectiveBuilder:RefreshObjectives()
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

function addon:TrackerExists(objectiveTitle, trackerID)
    for _, tracker in pairs(FarmingBar.db.global.objectives[objectiveTitle].trackers) do
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
    if not trackerID then return end
    if trackerType == "ITEM" then
        return (GetItemInfoInstant(trackerID or 0)), "ITEM"
    elseif trackerType == "CURRENCY" then
        local isLink = GetCurrencyInfoFromLink(trackerID)
        trackerID = isLink and GetCurrencyIDFromLink(trackerID) or tonumber(trackerID) or 0
        local currency = GetCurrencyInfo(trackerID)

        return currency and trackerID, "CURRENCY"
    elseif trackerID == "" then
        return true, "NONE"
    end
end