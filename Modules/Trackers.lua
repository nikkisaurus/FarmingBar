local addonName = ...
local addon = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

------------------------------------------------------------

local AceGUI = LibStub("AceGUI-3.0", true)

local select, type = select, type
local floor, min, max = math.floor, math.min, math.max
local format, strsplit, strupper, tonumber = string.format, strsplit, string.upper, tonumber
local pairs, tinsert, tremove, wipe = pairs, table.insert, table.remove, table.wipe
local GetItemCount = GetItemCount
--@retail@
local GetCurrencyInfo, GetCurrencyInfoFromLink, GetCurrencyIDFromLink = C_CurrencyInfo.GetCurrencyInfo, C_CurrencyInfo.GetCurrencyInfoFromLink, C_CurrencyInfo.GetCurrencyIDFromLink
--@end-retail@

--*------------------------------------------------------------------------

function addon:GetTrackerDBInfo(trackers, trackerKey, key)
    local keys = {strsplit(".", key)}
    local path = trackers[trackerKey]
    for k, key in pairs(keys) do
        if k < #keys then
            path = path[key]
        end
    end

    return path[keys[#keys]]
end

------------------------------------------------------------

function addon:SetTrackerDBValue(trackers, trackerKey, key, value)
    local keys = {strsplit(".", key)}
    local path = trackers[trackerKey]

    for k, key in pairs(keys) do
        if k < #keys then
            path = path[key]
        end
    end

    if value == "_TOGGLE_" then
        local val = path[keys[#keys]]
        if val then
            path[keys[#keys]] = false
        else
            path[keys[#keys]] = true
        end
    else
        path[keys[#keys]] = value
    end

    self:RefreshOptions()
    -- addon:UpdateButtons(objectiveTitle)
end

--*------------------------------------------------------------------------

function addon:CreateTracker(trackers, trackerType, trackerID)
    local trackerKey = strupper(trackerType)..":"..trackerID
    local tracker =  trackers[trackerKey]
    local lastIndex = 0
    for k, v in pairs(trackers) do
        lastIndex = max(v.order, lastIndex)
    end
    tracker.order = lastIndex + 1
    self:RefreshObjectiveBuilderOptions()
    return trackerKey
end

------------------------------------------------------------

function addon:DeleteTracker(trackers, trackerKey)
    trackers[trackerKey] = nil
    self:RefreshObjectiveBuilderOptions()
end

--*------------------------------------------------------------------------

function addon:GetFirstTemplateTracker(objectiveTitle)
    local objectiveInfo = self:GetDBValue("global", "objectives")[objectiveTitle]

    local firstOrder, firstTracker = 0
    for k, v in pairs(objectiveInfo.trackers) do
        firstOrder = firstTracker and min(v.order, firstOrder) or v.order
        firstTracker = firstTracker and (firstOrder == v.order and k or firstTracker) or k
    end

    return firstTracker
end

------------------------------------------------------------

function addon:GetFirstTracker(widget)
    local buttonDB = widget:GetButtonDB()

    local firstOrder, firstTracker = 0
    for k, v in pairs(buttonDB.trackers) do
        firstOrder = firstTracker and min(v.order, firstOrder) or v.order
        firstTracker = firstTracker and (firstOrder == v.order and k or firstTracker) or k
    end

    return firstTracker
end

------------------------------------------------------------

function addon:GetTrackerCount(widget, trackerKey, overrideObjective)
    local trackerType, trackerID = self:ParseTrackerKey(trackerKey)
    local trackerInfo = widget:GetButtonDB().trackers[trackerKey]
    local count

    if trackerType == "ITEM" then
        -- count = GetItemCount(trackerID, trackerInfo.includeBank)
        count = trackerInfo.includeAllChars and self:GetDataStoreCount(trackerID, trackerInfo.includeBank) or GetItemCount(trackerID, trackerInfo.includeBank)
    elseif trackerType == "CURRENCY" then
        count = GetCurrencyInfo(trackerID) and GetCurrencyInfo(trackerID).quantity
    end

    if not count then
        return 0
    end

    -- if #trackerInfo.exclude > 0 then
    --     for _, eObjectiveTitle in pairs(trackerInfo.exclude) do
    --         local eObjectiveInfo = addon:GetObjectiveInfo(eObjectiveTitle)
    --         local eObjective, eObjectiveButton = addon:GetMaxTrackerObjective(eObjectiveTitle)

    --         -- Only exclude if an objective is set (otherwise, how do we know how many to exclude?)
    --         if eObjective then
    --             for _, eTrackerInfo in pairs(eObjectiveInfo.trackers) do
    --                 if eTrackerInfo.trackerID == trackerInfo.trackerID then
    --                     -- Get the max amount used for the objective: either the objective itself or the count
    --                     local maxCount = min(addon:GetObjectiveCount(eObjectiveButton, eObjectiveTitle), eObjective)
    --                     -- The number of of this tracker required for the objective is the tracker objective x max
    --                     count = count - maxCount
    --                 end
    --             end
    --         end
    --     end
    -- end

    count = floor(count / (overrideObjective or trackerInfo.objective or 1))

    -- -- If objective is excluded, get max objective
    -- -- If count > max objective while excluded, return max objective
    -- -- Surplus above objective goes toward the objective excluding this one
    -- -- Ex: if A has an objective of 20 and a count of 25 and B excludes A, A will show a count of 20 with objective complete and B will show a count of 5
    local objective
    -- for _, eObjectiveInfo in pairs(addon.db.global.objectives) do
    --     for _, eTrackerInfo in pairs(eObjectiveInfo.trackers) do
    --         if self:ObjectiveIsExcluded(eTrackerInfo.exclude, objectiveTitle) then
    --             objective = addon:GetMaxTrackerObjective(objectiveTitle)
    --             break
    --         end
    --     end
    -- end

    count = (count > 0 and count or 0) * (trackerInfo.countsFor or 1)

    return objective and min(count, objective) or count
end

------------------------------------------------------------

function addon:GetTrackerKey(widget, trackerSort)
    local trackers = widget:GetButtonDB().trackers

    for trackerKey, trackerInfo in pairs(trackers) do
        if trackerInfo.order == trackerSort then
            return trackerKey
        end
    end
end

------------------------------------------------------------

function addon:ParseTrackerKey(trackerID)
    if not trackerID then return end
    local trackerType, trackerID = strsplit(":", trackerID)
    return trackerType, tonumber(trackerID)
end

------------------------------------------------------------

function addon:TrackerExists(objectiveInfo, trackerID)
    for _, tracker in pairs(objectiveInfo.trackers) do
        if tracker.trackerID == trackerID then
            return true
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

--*------------------------------------------------------------------------

-- function addon:CreateTracker(objectiveTitle, tracker)
--     local defaultTracker = self:GetDefaultTracker()

--     if tracker then
--         local trackerType, trackerID
--         if type(tracker) == "table" then
--             trackerType = tracker.trackerType
--             trackerID = tracker.trackerID
--         else
--             -- Create tracker from cursor
--             local cursorType, cursorID = GetCursorInfo()
--             ClearCursor()

--             if cursorType == "item" then
--                 trackerType = "ITEM"
--                 trackerID = cursorID
--             end
--         end

--         if not self:TrackerExists(objectiveTitle, trackerID) then
--             defaultTracker.trackerType = trackerType
--             defaultTracker.trackerID = trackerID
--         else
--             addon:ReportError(format(L.TrackerIDExists, trackerID))
--             return
--         end
--     end

--     tinsert(addon.db.global.objectives[objectiveTitle].trackers, defaultTracker)
--     local newTracker = #addon.db.global.objectives[objectiveTitle].trackers

--     ------------------------------------------------------------

--     -- local trackerList = ObjectiveBuilder:GetUserData("trackerList")
--     -- local button = addon:AddTrackerButton(newTracker, defaultTracker)

--     -- for _, button in pairs(trackerList.children) do
--     --     button:SetSelected(false)
--     -- end

--     -- ObjectiveBuilder:SelectTracker(newTracker)
--     -- button:SetSelected(true)
--     -- trackerList.scrollbar:SetValue(1000)

--     ------------------------------------------------------------

--     self:UpdateButtons(objectiveTitle)
--     self:RefreshObjectiveBuilderOptions(objectiveTitle)
-- end

-- ------------------------------------------------------------

-- function addon:DeleteTracker(objectiveTitle, tracker)
--     addon.db.global.objectives[objectiveTitle].trackers[tracker] = nil
--     self:UpdateButtons(objectiveTitle)
--     self:RefreshObjectiveBuilderOptions()

--     -- local ObjectiveBuilder = self.ObjectiveBuilder
--     -- local trackerList = ObjectiveBuilder:GetUserData("trackerList")
--     -- local objectiveTitle, objectiveInfo = ObjectiveBuilder:GetSelectedObjectiveInfo()

--     -- ------------------------------------------------------------

--     -- local releaseKeys = {}
--     -- for key, button in pairs(trackerList.children) do
--     --     if button:GetUserData("selected") then
--     --         if ObjectiveBuilder:GetSelectedTracker() == key then
--     --             ObjectiveBuilder:ClearSelectedTracker()
--     --         end

--     --         addon.db.global.objectives[objectiveTitle].trackers[key] = nil
--     --         tinsert(releaseKeys, key)
--     --     end
--     -- end

--     -- -- Release buttons after the initial loop, backwards, to ensure all buttons are properly released
--     -- for _, key in addon.pairs(releaseKeys, function(a, b) return b < a end) do
--     --     ObjectiveBuilder:ReleaseChild(trackerList.children[key])
--     -- end

--     -- ------------------------------------------------------------

--     -- -- Reindex trackers table so trackerList buttons aren't messed up
--     -- local trackers = {}
--     -- for _, trackerInfo in pairs(objectiveInfo.trackers) do
--     --     tinsert(trackers, trackerInfo)
--     -- end

--     -- addon.db.global.objectives[objectiveTitle].trackers = trackers

--     -- ------------------------------------------------------------

--     -- -- Update tracker button keys
--     -- for key, button in pairs(trackerList.children) do
--     --     button:SetUserData("trackerKey", key)
--     -- end

--     -- ------------------------------------------------------------

--     -- trackerList:DoLayout()
--     -- self:UpdateButtons(objectiveTitle)
--     -- ObjectiveBuilder:RefreshObjectives()
-- end

------------------------------------------------------------

-- function addon:GetMaxTrackerObjective(objectiveTitle)
--     local objective, objectiveButton
--     for _, bar in pairs(self.bars) do
--         for _, button in pairs(bar:GetUserData("buttons")) do
--             local buttonObjectiveTitle = button:GetUserData("objectiveTitle")
--             if buttonObjectiveTitle == objectiveTitle then
--                 local buttonObjective = button:GetObjective()
--                 if not objective then
--                     objective = buttonObjective
--                 else
--                     objective = max(objective or 0, buttonObjective or 0)
--                     objectiveButton = objective == buttonObjective and button or objectiveButton
--                 end
--             end
--         end
--     end
--     return objective, objectiveButton
-- end


------------------------------------------------------------

function addon:GetTrackerDataTable(...)
    local buttonDB = select(1, ...)
    local dataType = select(2, ...)
    local dataID = select(3, ...)
    local callback = select(4, ...)

    if dataType == "ITEM" then
        self:CacheItem(dataID, function(buttonDB, dataType, dataID, callback)
            local name, _, _, _, _, _, _, _, _, icon = GetItemInfo(dataID)
            local data = {conditionInfo = buttonDB.conditionInfo, name = (not name or name == "") and L["Invalid Tracker"] or name, icon = icon or 134400, label = addon:GetTrackerTypeLabel(dataType), trackerType = dataType, trackerID = dataID}

            if callback then
                callback(data)
            else
                return data
            end
        end, ...)
    elseif dataType == "CURRENCY" then
        local currency = GetCurrencyInfo(tonumber(dataID) or 0)
        local data = {conditionInfo = buttonDB.conditionInfo, name = currency and currency.name or L["Invalid Tracker"], icon = currency and currency.iconFileID or 134400, label = addon:GetTrackerTypeLabel(dataType), trackerType = dataType, trackerID = dataID}

        if callback then
            callback(data)
        else
            return data
        end
    end
end

-- ------------------------------------------------------------

-- function addon:GetTrackerDBInfo(objectiveTitle, tracker, key)
--     local keys = {strsplit(".", key)}
--     local path = addon.db.global.objectives[objectiveTitle].trackers[tracker]
--     for k, key in pairs(keys) do
--         if k < #keys then
--             path = path[key]
--         end
--     end

--     return path[keys[#keys]]
-- end

-- ------------------------------------------------------------

-- function addon:GetTrackerInfo(objectiveTitle, tracker)
--     return addon.db.global.objectives[objectiveTitle] and addon.db.global.objectives[objectiveTitle].trackers[tracker]
-- end

------------------------------------------------------------

function addon:GetTrackerTypeLabel(trackerType)
    --@retail@
    return trackerType == "ITEM" and L["Item ID/Name/Link"] or L["Currency ID/Link"]
    --@end-retail@
    --[===[@non-retail@
    return L["Item ID/Name/Link"]
    --@end-non-retail@]===]
end

-- ------------------------------------------------------------

-- function addon:MoveTracker(currentKey, direction)
--     local ObjectiveBuilder = self.ObjectiveBuilder
--     local objectiveTitle, objectiveInfo = ObjectiveBuilder:GetSelectedObjectiveInfo()

--     local currentInfo = objectiveInfo.trackers[currentKey]
--     local currentButton = ObjectiveBuilder:GetTrackerButton(currentInfo)

--     local destinationKey = currentKey + direction
--     local destinationInfo = objectiveInfo.trackers[destinationKey]
--     local destinationButton = ObjectiveBuilder:GetTrackerButton(destinationInfo)

--     ------------------------------------------------------------

--     -- Swap trackerInfo in the database
--     addon.db.global.objectives[objectiveTitle].trackers[currentKey] = destinationInfo
--     addon.db.global.objectives[objectiveTitle].trackers[destinationKey] = currentInfo

--     ------------------------------------------------------------

--     -- Update the trackers on buttons to make sure they have the correct information
--     for tracker, trackerInfo in pairs(objectiveInfo.trackers) do
--         ObjectiveBuilder:GetUserData("trackerList").children[tracker]:SetTracker(tracker, trackerInfo)
--     end

--     -- Reselect the current tracker
--     destinationButton:Select()

--     ------------------------------------------------------------

--     -- Refresh counts
--     addon:UpdateButtons(objectiveTitle)
--     ObjectiveBuilder:RefreshObjectives()
-- end

------------------------------------------------------------

-- function addon:UpdateExclusions(objectiveTitle, newObjectiveTitle)
--     for _, objectiveInfo in pairs(addon.db.global.objectives) do
--         for _, trackerInfo in pairs(objectiveInfo.trackers) do
--             local removeKey = self.GetTableKey(trackerInfo.exclude, objectiveTitle)
--             if removeKey then
--                 tremove(trackerInfo.exclude, removeKey)
--                 if newObjectiveTitle then
--                     tinsert(trackerInfo.exclude, newObjectiveTitle)
--                 end
--             end
--         end
--     end
-- end