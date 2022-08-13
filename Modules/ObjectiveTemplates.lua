local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)

--[[ Display ]]
function private:GetObjectiveIcon(objectiveInfo)
    if objectiveInfo.icon.type == "FALLBACK" then
        return objectiveInfo.icon.id
    elseif objectiveInfo.onUse.type == "ITEM" then
        return GetItemIcon(objectiveInfo.onUse.itemID)
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

function private:DeleteObjectiveTemplateTracker(objectiveTitle, trackerID)
    private.db.global.objectives[objectiveTitle].trackers[trackerID] = nil
end

function private:ObjectiveTemplateTrackerExists(objectiveTitle, trackerType, trackerID)
    for _, trackerInfo in pairs(private.db.global.objectives[objectiveTitle].trackers) do
        if trackerInfo.type == trackerType and trackerInfo.id == trackerID then
            return true
        end
    end
end

function private:GetObjectiveTemplateTrackerName(trackerType, trackerID)
    if trackerType == "ITEM" then
        private:CacheItem(trackerID)
        local itemName = GetItemInfo(trackerID)
        return itemName
    elseif trackerType == "CURRENCY" then
        local currency = C_CurrencyInfo.GetCurrencyInfo(trackerID)
        return currency.name
    end
end

function private:GetObjectiveTemplateTrackerIcon(trackerType, trackerID)
    if trackerType == "ITEM" then
        return GetItemIcon(trackerID)
    elseif trackerType == "CURRENCY" then
        return C_CurrencyInfo.GetCurrencyInfo(trackerID).iconFileID
    end
end
