local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)

function private:AddObjective(widget, Type, id, alert)
    return addon:Cache(strlower(Type), id, function(success, id, private, widget, Type, id, alert)
        if success then
            local name, icon = private:GetTrackerInfo(Type, id)

            local template = addon:CloneTable(private.defaults.objective)
            template.title = name
            template.icon.id = icon
            template.onUse.type = Type == "ITEM" and Type or "NONE"
            template.onUse.itemID = Type == "ITEM" and id or "NONE"

            local tracker = addon:CloneTable(private.defaults.tracker)
            tracker.type = Type
            tracker.id = id
            tracker.name = name or ""
            tinsert(template.trackers, tracker)

            widget:SetObjectiveInfo(template)
        elseif alert then
            addon:Print(alert)
        end
    end, { private, widget, Type, id, alert })
end

function private:AddObjectiveTemplate(objectiveInfo, title)
    local newObjectiveTitle = addon:IncrementString(title or (objectiveInfo and objectiveInfo.title) or L["New"], function(str, private)
        return private:ObjectiveTemplateExists(str)
    end, { private })
    private.db.global.objectives[newObjectiveTitle] = addon:CloneTable(objectiveInfo or private.defaults.objective)
    private.db.global.objectives[newObjectiveTitle].title = newObjectiveTitle
    private:RefreshOptions()
    return newObjectiveTitle
end

function private:AddObjectiveTracker(objective, trackerType, trackerID)
    local tracker = addon:CloneTable(private.defaults.tracker)
    tracker.type = trackerType
    tracker.id = trackerID

    local trackerKey
    if type(objective) == "string" then
        tinsert(private.db.global.objectives[objective].trackers, tracker)
        trackerKey = #private.db.global.objectives[objective].trackers
    else
        local _, buttonDB = objective:GetDB()
        trackerKey = #buttonDB.trackers + 1
    end

    addon:Cache(strlower(tracker.type), tracker.id, function(success, id, private, objective, trackerType, trackerKey)
        if success then
            local tracker
            if type(objective) == "string" then
                tracker = private.db.global.objectives[objective].trackers[trackerKey]
            else
                _, tracker = objective:AddTracker(trackerType, id)
            end

            local name = private:GetTrackerInfo(tracker.type, id)
            tracker.name = name or ""
        end
    end, { private, objective, tracker.type, trackerKey })

    return trackerKey
end

function private:AddObjectiveTrackerAltID(objectiveTitle, trackerKey, altType, altID)
    tinsert(private.db.global.objectives[objectiveTitle].trackers[trackerKey].altIDs, {
        type = altType,
        id = altID,
        multiplier = 1,
    })
    local altIDKey = #private.db.global.objectives[objectiveTitle].trackers[trackerKey].altIDs
    addon:Cache(strlower(altType), altID, function(success, id, private, objectiveTitle, trackerKey, altIDKey)
        local altID = private.db.global.objectives[objectiveTitle].trackers[trackerKey].altIDs[altIDKey]
        local name = private:GetTrackerInfo(altID.type, id)
        altID.name = name or ""
    end, { private, objectiveTitle, trackerKey, altIDKey })
end

function private:DeleteObjectiveTemplate(objectiveTitle)
    private.db.global.objectives[objectiveTitle] = nil
    private:RefreshOptions()
end

function private:DeleteObjectiveTemplateTracker(objectiveTitle, trackerKey)
    private.db.global.objectives[objectiveTitle].trackers[trackerKey] = nil
end

function private:DeleteObjectiveTemplateTrackerAltID(objectiveTitle, trackerKey, altKey)
    private.db.global.objectives[objectiveTitle].trackers[trackerKey].altIDs[altKey] = nil
end

function private:DuplicateObjectiveTemplate(objectiveTitle)
    local newObjectiveTitle = addon:IncrementString(objectiveTitle, function(str, private)
        return private:ObjectiveTemplateExists(str)
    end, { private })
    private.db.global.objectives[newObjectiveTitle] = addon:CloneTable(private.db.global.objectives[objectiveTitle])
    private.db.global.objectives[newObjectiveTitle].title = newObjectiveTitle
    private:RefreshOptions()
    return newObjectiveTitle
end

function private:GetObjectiveIcon(objectiveInfo)
    if objectiveInfo.icon.type == "FALLBACK" then
        return objectiveInfo.icon.id
    elseif objectiveInfo.onUse.type == "ITEM" then
        return objectiveInfo.onUse.itemID and C_Item.GetItemIconByID(objectiveInfo.onUse.itemID) or 134400
    elseif not objectiveInfo.trackers[1] then
        return 134400
    elseif objectiveInfo.trackers[1].type == "ITEM" then
        return objectiveInfo.trackers[1].id and C_Item.GetItemIconByID(objectiveInfo.trackers[1].id) or 134400
    else
        return C_CurrencyInfo.GetCurrencyInfo(objectiveInfo.trackers[1].id).iconFileID
    end
end

function private:GetObjectiveTemplateTrackerIcon(trackerType, trackerKey)
    if trackerType == "ITEM" then
        return C_Item.GetItemIconByID(trackerKey)
    elseif trackerType == "CURRENCY" then
        return C_CurrencyInfo.GetCurrencyInfo(trackerKey).iconFileID
    end
end

function private:GetTrackerInfo(Type, id)
    local name, icon
    if Type == "ITEM" then
        name = GetItemInfo(id)
        icon = C_Item.GetItemIconByID(id)
    elseif Type == "CURRENCY" then
        local currency = C_CurrencyInfo.GetCurrencyInfo(id or tonumber(id) or 0)
        name = currency and currency.name
        icon = currency and currency.iconFileID
    end

    return name, icon
end

function private:ObjectiveTemplateExists(objectiveTitle)
    return private.db.global.objectives[objectiveTitle]
end

function private:ObjectiveTemplateTrackerExists(objectiveTitle, trackerType, trackerID)
    for _, trackerInfo in pairs(private.db.global.objectives[objectiveTitle].trackers) do
        if trackerInfo.type == trackerType and trackerInfo.id == trackerID then
            return true
        end
    end
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

function private:PickupObjectiveTemplate(objectiveTitle)
    private.ObjectiveFrame:LoadObjective(private.db.global.objectives[objectiveTitle], objectiveTitle)
end

function private:RemoveObjectiveTemplateTracker(objectiveTemplateName, trackerKey)
    tremove(private.db.global.objectives[objectiveTemplateName].trackers, trackerKey)
end

function private:RenameObjectiveTemplate(objectiveTitle, newObjectiveTitle)
    private.db.global.objectives[newObjectiveTitle] = addon:CloneTable(private.db.global.objectives[objectiveTitle])
    private.db.global.objectives[newObjectiveTitle].title = newObjectiveTitle
    private.db.global.objectives[objectiveTitle] = nil
    return newObjectiveTitle
end

function private:UpdateTrackerKeys(objectiveTemplateName, trackerKey, newTrackerKey)
    local trackers = private.db.global.objectives[objectiveTemplateName].trackers
    if trackerKey > addon:tcount(trackers) then
        return trackerKey
    end

    local trackerInfo = addon:CloneTable(trackers[trackerKey])
    tremove(private.db.global.objectives[objectiveTemplateName].trackers, trackerKey)
    tinsert(private.db.global.objectives[objectiveTemplateName].trackers, newTrackerKey, trackerInfo)

    return newTrackerKey
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

    if type(objectiveTemplateName) == "string" then
        return not private:ObjectiveTemplateTrackerExists(objectiveTemplateName, trackerType, isValid) and isValid or L["Tracker already exists for this objective."]
    else
        return not objectiveTemplateName:TrackerExists(trackerType, isValid) and isValid or L["Tracker already exists for this objective."]
    end
end
