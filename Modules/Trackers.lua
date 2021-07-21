local addonName = ...
local addon = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)


-- Optional libraries
local AceGUI = LibStub("AceGUI-3.0", true)


--*------------------------------------------------------------------------
-- Create tracker

function addon:CreateTracker(objectiveInfo, trackerType, trackerID)
    local trackers = objectiveInfo.trackers
    local trackerKey = strupper(trackerType)..":"..trackerID
    local tracker =  trackers[trackerKey]

    -- Create tracker
    local lastIndex = 0
    for k, v in pairs(trackers) do
        lastIndex = max(v.order, lastIndex)
    end
    tracker.order = lastIndex + 1

    ------------------------------------------------------------
    --Debug-----------------------------------------------------
    ------------------------------------------------------------
    if tracker.order == lastIndex + 1 then
        print(format("DEBUG: Tracker successfully created: %s", trackerKey))
    else
        print(format("DEBUG: There was an error creating: %s", trackerKey))
    end
    ------------------------------------------------------------
    ------------------------------------------------------------

    self:RefreshOptions()

    return trackerKey
end


function addon:ValidateTrackerData(trackerType, trackerID)
    if not trackerID then return end

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


--*------------------------------------------------------------------------
-- Tracker info


function addon:GetFirstTracker(widget, isTemplate)
    local buttonDB = isTemplate and self:GetDBValue("global", "objectives")[widget] or widget:GetButtonDB()

    local firstOrder, firstTracker = 0
    for k, v in pairs(buttonDB.trackers) do
        firstOrder = firstTracker and min(v.order, firstOrder) or v.order
        firstTracker = firstTracker and (firstOrder == v.order and k or firstTracker) or k
    end

    return firstTracker
end


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
        local currency = C_CurrencyInfo.GetCurrencyInfo(tonumber(dataID) or 0)
        local data = {conditionInfo = buttonDB.conditionInfo, name = currency and currency.name or L["Invalid Tracker"], icon = currency and currency.iconFileID or 134400, label = self:GetTrackerTypeLabel(dataType), trackerType = dataType, trackerID = dataID}

        if callback then
            callback(data)
        else
            return data
        end
    end
end


function addon:GetTrackerKey(widget, trackerSort)
    local trackers = widget:GetButtonDB().trackers

    for trackerKey, trackerInfo in pairs(trackers) do
        if trackerInfo.order == trackerSort then
            return trackerKey
        end
    end
end


function addon:GetTrackerTypeLabel(trackerType)
    --@retail@
    return trackerType == "ITEM" and L["Item ID/Name/Link"] or L["Currency ID/Link"]
    --@end-retail@
    --[===[@non-retail@
    return L["Item ID/Name/Link"]
    --@end-non-retail@]===]
end


function addon:ParseTrackerKey(trackerID)
    if not trackerID then return end
    local trackerType, trackerID = strsplit(":", trackerID)
    return trackerType, tonumber(trackerID)
end


function addon:TrackerExists(objectiveInfo, trackerID)
    for key, tracker in pairs(objectiveInfo.trackers) do
        if key == trackerID then
            return true
        end
    end
end


--*------------------------------------------------------------------------
-- Manage


function addon:DeleteTracker(trackers, trackerKey)
    trackers[trackerKey] = nil
    self:RefreshOptions()
end