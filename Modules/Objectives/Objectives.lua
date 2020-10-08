local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

--*------------------------------------------------------------------------

function addon:GetIcon(objectiveTitle)
    local objectiveInfo = FarmingBar.db.global.objectives[objectiveTitle]

    local icon
    if objectiveInfo.autoIcon then
        local lookupTable = objectiveInfo.displayRef.trackerType and objectiveInfo.displayRef or objectiveInfo.trackers[1]
        local trackerType, trackerID = lookupTable and lookupTable.trackerType, lookupTable and lookupTable.trackerID

        if trackerType == "ITEM" then
            icon = C_Item.GetItemIconByID(tonumber(trackerID) or 1412)
        elseif trackerType == "CURRENCY" then
            -- !Revise once Shadowlands/prepatch is live.
            if C_CurrencyInfo.GetCurrencyInfo then
                icon = C_CurrencyInfo.GetCurrencyInfo(tonumber(trackerID)).iconFileID
            else
                icon = (select(3, GetCurrencyInfo(tonumber(trackerID) or 1719)))
            end
            -- !
        end
    else
        if objectiveInfo.icon then
            icon = (tonumber(objectiveInfo.icon) and tonumber(objectiveInfo.icon) ~= objectiveInfo.icon) and tonumber(objectiveInfo.icon) or objectiveInfo.icon
            icon = (icon == "" or not icon) and 134400 or icon
        else
            icon = 134400
        end
    end

    return icon
end

function addon:ValidateTracker(trackerType, trackerID)
    if trackerType == "ITEM" then
        return (GetItemInfoInstant(trackerID))
    elseif trackerType == "CURRENCY" then
        return GetCurrencyInfo(trackerID) ~= "" and GetCurrencyInfo(trackerID)
    end
end