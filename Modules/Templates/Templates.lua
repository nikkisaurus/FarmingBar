local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)

function private:LoadTemplate(barID, templateName)
    local bar = private.bars[barID]
    local template = private.templates[templateName]

    bar:Clear()
    private.db.profile.bars[barID].numButtons = max(bar:GetDB().numButtons, addon.tcount(template))
    bar:DrawButtons()
    bar:LayoutButtons()
    for key, item in addon.pairs(template) do
        private:CacheItem(item.itemID)
        local itemName, itemIcon = private:GetTrackerInfo("ITEM", item.itemID)

        local objectiveTemplate = addon.CloneTable(private.defaults.objective)
        objectiveTemplate.icon.id = itemIcon
        objectiveTemplate.onUse.type = "ITEM"
        objectiveTemplate.onUse.itemID = item.itemID
        objectiveTemplate.title = itemName

        local tracker = addon.CloneTable(private.defaults.tracker)
        tracker.type = "ITEM"
        tracker.id = item.itemID
        tinsert(objectiveTemplate.trackers, tracker)

        bar:GetButtons()[key]:SetObjectiveInfo(objectiveTemplate)
    end
    bar:UpdateButtons()
end

function private:SaveTemplate(barID, templateName)
    local widget = private.bars[barID]
    local barDB = widget:GetDB()
    private.db.global.templates[templateName] = addon.CloneTable(barDB.buttons)
end

function private:TemplateExists(templateName)
    return private.db.global.templates[templateName]
end
