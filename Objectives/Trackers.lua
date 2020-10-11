local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

--*------------------------------------------------------------------------

function addon:GetObjectiveDataLabel(trackerType)
    --@retail@
    return trackerType == "ITEM" and L["Item ID/Name/Link"] or L["Currency ID"]
    --@end-retail@
    --[===[@non-retail@
    return L["Item ID/Name/Link"]
    --@end-non-retail@]===]
end

------------------------------------------------------------

function addon:GetObjectiveDataTable(...)
    local dataType = select(1, ...)
    local dataID = select(2, ...)
    local callback = select(3, ...)

    if dataType == "ITEM" then
        self:CacheItem(dataID, function(dataType, dataID, callback)
            local name, _, _, _, _, _, _, _, _, icon = GetItemInfo(dataID)
            local data = {name = name, icon = icon, label = addon:GetObjectiveDataLabel(dataType), trackerType = dataType, trackerID = dataID}

            if callback then
                callback(data)
            else
                return data
            end
        end, ...)
    elseif dataType == "CURRENCY" then
        local name, _, icon = GetCurrencyInfo(dataID)
        local data = {name = name, icon = icon, label = addon:GetObjectiveDataLabel(dataType), trackerType = dataType, trackerID = dataID}

        if callback then
            callback(data)
        else
            return data
        end
    end
end

------------------------------------------------------------

function addon:ValidateObjectiveData(trackerType, trackerID)
    if trackerType == "ITEM" then
        return (GetItemInfoInstant(trackerID))
    elseif trackerType == "CURRENCY" then
        return GetCurrencyInfo(trackerID) ~= "" and GetCurrencyInfo(trackerID)
    end
end