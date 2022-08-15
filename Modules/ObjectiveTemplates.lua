local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)

--[[ Display ]]
function private:GetObjectiveIcon(objectiveInfo)
    if objectiveInfo.icon.type == "FALLBACK" then
        return objectiveInfo.icon.id
    elseif objectiveInfo.onUse.type == "ITEM" then
        return GetItemIcon(objectiveInfo.onUse.itemID)
    elseif not objectiveInfo.trackers[1] then
        return 134400
    elseif objectiveInfo.trackers[1].type == "ITEM" then
        return GetItemIcon(objectiveInfo.trackers[1].id)
    else
        return C_CurrencyInfo.GetCurrencyInfo(objectiveInfo.trackers[1].id).iconFileID
    end
end

--[[ Database ]]
function private:DeleteObjectiveTemplate(objectiveTitle)
    private.db.global.objectives[objectiveTitle] = nil
end

function private:DuplicateObjectiveTemplate(objectiveTitle)
    local newObjectiveTitle = private:IncrementString(objectiveTitle, private, "ObjectiveTemplateExists")
    private.db.global.objectives[newObjectiveTitle] = addon.CloneTable(private.db.global.objectives[objectiveTitle])
    return newObjectiveTitle
end

function private:ObjectiveTemplateExists(objectiveTitle)
    return private.db.global.objectives[objectiveTitle]
end

function private:RenameObjectiveTemplate(objectiveTitle, newObjectiveTitle)
    private.db.global.objectives[newObjectiveTitle] = addon.CloneTable(private.db.global.objectives[objectiveTitle])
    private.db.global.objectives[objectiveTitle] = nil
end

--[[ Trackers ]]
function private:AddObjectiveTemplateTracker(objectiveTitle, trackerType, trackerID)
    local trackerInfo = addon.CloneTable(private.defaults.objective.trackers[1])
    trackerInfo.type = trackerType
    trackerInfo.id = trackerID
    tinsert(private.db.global.objectives[objectiveTitle].trackers, trackerInfo)
    return #private.db.global.objectives[objectiveTitle].trackers
end

function private:DeleteObjectiveTemplateTracker(objectiveTitle, trackerKey)
    private.db.global.objectives[objectiveTitle].trackers[trackerKey] = nil
end

function private:ObjectiveTemplateTrackerExists(objectiveTitle, trackerType, trackerKey)
    for _, trackerInfo in pairs(private.db.global.objectives[objectiveTitle].trackers) do
        if trackerInfo.type == trackerType and trackerInfo.id == trackerKey then
            return true
        end
    end
end

function private:GetObjectiveTemplateTrackerName(trackerType, trackerKey)
    if trackerType == "ITEM" then
        private:CacheItem(trackerKey)
        local itemName = GetItemInfo(trackerKey)
        return itemName
    elseif trackerType == "CURRENCY" then
        local currency = C_CurrencyInfo.GetCurrencyInfo(trackerKey)
        return currency.name
    end
end

function private:GetObjectiveTemplateTrackerIcon(trackerType, trackerKey)
    if trackerType == "ITEM" then
        return GetItemIcon(trackerKey)
    elseif trackerType == "CURRENCY" then
        return C_CurrencyInfo.GetCurrencyInfo(trackerKey).iconFileID
    end
end

--[[ Alt ID ]]
function private:AddObjectiveTemplateTrackerAltID(objectiveTitle, trackerKey, altType, altID)
    tinsert(private.db.global.objectives[objectiveTitle].trackers[trackerKey].altIDs, {
        type = altType,
        id = altID,
        multiplier = 1,
    })
end

function private:DeleteObjectiveTemplateTrackerAltID(objectiveTitle, trackerKey, altKey)
    private.db.global.objectives[objectiveTitle].trackers[trackerKey].altIDs[altKey] = nil
end

function private:ObjectiveTemplateTrackerAltIDExists(objectiveTitle, trackerKey, altType, altID)
    local trackerInfo = private.db.global.objectives[objectiveTitle].trackers[trackerKey]
    local trackerType = trackerInfo.type
    local trackerID = trackerInfo.id

    if altType == trackerType and altID == trackerID then
        return true
    end

    for _, altInfo in pairs(private.db.global.objectives[objectiveTitle].trackers[trackerKey].altIDs) do
        if altInfo.type == altType and altInfo.id == altID then
            return true
        end
    end
end
