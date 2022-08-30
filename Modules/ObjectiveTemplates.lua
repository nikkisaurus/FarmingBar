local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)

--[[ Display ]]
function private:GetObjectiveIcon(objectiveInfo)
    if objectiveInfo.icon.type == "FALLBACK" then
        return objectiveInfo.icon.id
    elseif objectiveInfo.onUse.type == "ITEM" then
        local id = objectiveInfo.onUse.itemID
        local colors
        if id then
            private.CacheItem(id)
            local _, _, rarity = GetItemInfo(id)
            colors = rarity and rarity >= 2 and { GetItemQualityColor(rarity) }
        end
        return GetItemIcon(id), colors
    elseif not objectiveInfo.trackers[1] then
        return 134400
    elseif objectiveInfo.trackers[1].type == "ITEM" then
        local id = objectiveInfo.trackers[1].id
        local colors
        if id then
            private.CacheItem(id)
            local _, _, rarity = GetItemInfo(id)
            colors = rarity and rarity >= 2 and { GetItemQualityColor(rarity) }
        end
        return GetItemIcon(id), colors
    else
        return C_CurrencyInfo.GetCurrencyInfo(objectiveInfo.trackers[1].id).iconFileID
    end
end

function private:PickupObjectiveTemplate(objectiveTitle)
    private.ObjectiveFrame:LoadObjective(private.db.global.objectives[objectiveTitle], objectiveTitle)
end

--[[ Database ]]
function private:AddObjectiveTemplate(objectiveInfo)
    local newObjectiveTitle =
        private:IncrementString(objectiveInfo and objectiveInfo.title or L["New"], private, "ObjectiveTemplateExists")
    private.db.global.objectives[newObjectiveTitle] = addon.CloneTable(objectiveInfo or private.defaults.objective)
    private.db.global.objectives[newObjectiveTitle].title = newObjectiveTitle
    private:RefreshOptions()
    return newObjectiveTitle
end

function private:DeleteObjectiveTemplate(objectiveTitle)
    private.db.global.objectives[objectiveTitle] = nil
    private:RefreshOptions()
end

function private:DuplicateObjectiveTemplate(objectiveTitle)
    local newObjectiveTitle = private:IncrementString(objectiveTitle, private, "ObjectiveTemplateExists")
    private.db.global.objectives[newObjectiveTitle] = addon.CloneTable(private.db.global.objectives[objectiveTitle])
    private.db.global.objectives[newObjectiveTitle].title = newObjectiveTitle
    private:RefreshOptions()
    return newObjectiveTitle
end

function private:ObjectiveTemplateExists(objectiveTitle)
    return private.db.global.objectives[objectiveTitle]
end

function private:RenameObjectiveTemplate(objectiveTitle, newObjectiveTitle)
    private.db.global.objectives[newObjectiveTitle] = addon.CloneTable(private.db.global.objectives[objectiveTitle])
    private.db.global.objectives[newObjectiveTitle].title = newObjectiveTitle
    private.db.global.objectives[objectiveTitle] = nil
    return newObjectiveTitle
end

--[[ Trackers ]]
function private:AddObjectiveTemplateTracker(objectiveTitle, trackerType, trackerID)
    local trackerInfo = addon.CloneTable(private.defaults.tracker)
    trackerInfo.type = trackerType
    trackerInfo.id = trackerID
    tinsert(private.db.global.objectives[objectiveTitle].trackers, trackerInfo)
    return #private.db.global.objectives[objectiveTitle].trackers
end

function private:DeleteObjectiveTemplateTracker(objectiveTitle, trackerKey)
    private.db.global.objectives[objectiveTitle].trackers[trackerKey] = nil
end

function private:ObjectiveTemplateTrackerExists(objectiveTitle, trackerType, trackerID)
    for _, trackerInfo in pairs(private.db.global.objectives[objectiveTitle].trackers) do
        if trackerInfo.type == trackerType and trackerInfo.id == trackerID then
            return true
        end
    end
end

function private:UpdateTrackerKeys(objectiveTemplateName, trackerKey, newTrackerKey)
    local trackers = private.db.global.objectives[objectiveTemplateName].trackers
    if trackerKey > addon.tcount(trackers) then
        return trackerKey
    end

    local trackerInfo = addon.CloneTable(trackers[trackerKey])
    tremove(private.db.global.objectives[objectiveTemplateName].trackers, trackerKey)
    tinsert(private.db.global.objectives[objectiveTemplateName].trackers, newTrackerKey, trackerInfo)

    return newTrackerKey
end

function private:RemoveObjectiveTemplateTracker(objectiveTemplateName, trackerKey)
    tremove(private.db.global.objectives[objectiveTemplateName].trackers, trackerKey)
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

function private:ValidateTracker(objectiveTemplateName, trackerType, trackerID)
    local isValid
    if trackerType == "ITEM" then
        isValid = private:ValidateItem(trackerID)
        if not isValid then
            return L["Invalid Tracker/Alt ID"]
        end
    elseif trackerType == "CURRENCY" then
        isValid = private:ValidateCurrency(trackerID)
        if not isValid then
            return L["Invalid Tracker/Alt ID"]
        end
    else
        return L["Invalid Tracker/Alt Type"]
    end

    return not private:ObjectiveTemplateTrackerExists(objectiveTemplateName, trackerType, isValid) and isValid
        or L["Tracker already exists for this objective."]
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
