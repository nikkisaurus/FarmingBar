local addonName = ...
local addon = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)


--*------------------------------------------------------------------------
-- Create templates

function addon:CreateObjectiveTemplate(objectiveTitle, overwrite, supressSelect)
    local defaultTitle, newObjectiveTitle = L["New"]

    -- Template exists, so we need to add a number to the end
    if self:ObjectiveTemplateExists(objectiveTitle or defaultTitle) and not overwrite then
        local i = 2
        while not newObjectiveTitle do
            local title = format("%s %d", objectiveTitle or defaultTitle, i)

            if not self:ObjectiveTemplateExists(title) then
                newObjectiveTitle = title
            else
                i = i + 1
            end
        end
    end

    newObjectiveTitle = newObjectiveTitle or objectiveTitle or defaultTitle

    -- Create template
    local objectiveTemplate = self:GetDBValue("global", "objectives")[newObjectiveTitle]
    objectiveTemplate.title = newObjectiveTitle

    ------------------------------------------------------------
    --Debug-----------------------------------------------------
    ------------------------------------------------------------
    if objectiveTemplate.title == newObjectiveTitle then
        print(format("DEBUG: Template successfully created: %s", newObjectiveTitle))
    else
        print(format("DEBUG: There was an error creating: %s", newObjectiveTitle))
    end
    ------------------------------------------------------------
    ------------------------------------------------------------

    -- Refresh options
    self:RefreshOptions()
    if not supressSelect then
        LibStub("AceConfigDialog-3.0"):SelectGroup(addonName, "objectiveBuilder", newObjectiveTitle)
    end

    return newObjectiveTitle
end


--*------------------------------------------------------------------------
-- Template info


function addon:GetObjectiveTemplateIcon(objectiveTitle)
    local objectiveInfo = self:GetDBValue("global", "objectives")[objectiveTitle]

    local icon
    if objectiveInfo.autoIcon then
        local trackerType, trackerID
        if objectiveInfo.action == "ITEM" or objectiveInfo.action == "CURRENCY" then
            trackerType, trackerID = objectiveInfo.action, objectiveInfo.actionInfo
        else
            trackerType, trackerID = self:ParseTrackerKey(self:GetFirstTracker(objectiveTitle, true))
        end

        if trackerType == "ITEM" then
            icon = C_Item.GetItemIconByID(tonumber(trackerID) or 0)
        elseif trackerType == "CURRENCY" then
            local currency = C_CurrencyInfo.GetCurrencyInfo(tonumber(trackerID) or 0)
            icon = currency and currency.iconFileID
        end
    else
        if objectiveInfo.icon then
            -- Convert db icon value to number if it's a file ID, otherwise use the string value
            icon = (tonumber(objectiveInfo.icon) and tonumber(objectiveInfo.icon) ~= objectiveInfo.icon) and tonumber(objectiveInfo.icon) or objectiveInfo.icon
            icon = (icon == "" or not icon) and 134400 or icon
        end
    end

    return icon or 134400
end


function addon:GetObjectiveTemplateLinks(template)
    return self:GetDBValue("global", "objectives")[template].instances
end


function addon:ObjectiveTemplateExists(objectiveTitle)
    return self:GetDBValue("global", "objectives")[objectiveTitle].title ~= ""
end


--*------------------------------------------------------------------------
-- Manage


function addon:CreateObjectiveTemplateInstance(template, buttonID)
    print(format("Created instance from %s on %s", template, buttonID))
    local charKey = self:GetCharKey()
    local templateLinks = self:GetObjectiveTemplateLinks(template)
    templateLinks[charKey][buttonID] = true
end


function addon:DeleteObjectiveTemplate(objectiveTitle, confirmed)
    self:GetDBValue("global", "objectives")[objectiveTitle] = nil
    -- self:UpdateExclusions(objectiveTitle)
    -- self:ClearDeletedObjectives(objectiveTitle)
    self:RefreshOptions()
end


function addon:RemoveObjectiveTemplateInstance(template, buttonID)
    print(format("Removed instance from %s on %s", template, buttonID))
    local charKey = self:GetCharKey()
    local templateLinks = self:GetObjectiveTemplateLinks(template)
    templateLinks[charKey][buttonID] = nil
end


function addon:RenameObjectiveTemplate(objectiveTitle, newObjectiveTitle)
    local objectives = self:GetDBValue("global", "objectives")
    objectives[newObjectiveTitle] = objectives[objectiveTitle]
    objectives[newObjectiveTitle].title = newObjectiveTitle
    objectives[objectiveTitle] = nil

    -- self:UpdateExclusions(objectiveTitle, newObjectiveTitle)
    -- self:UpdateRenamedObjectiveButtons(objectiveTitle, newObjectiveTitle)

    self:RefreshOptions()
end