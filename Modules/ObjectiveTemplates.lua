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
