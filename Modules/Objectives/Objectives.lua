local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

local pairs = pairs
local type = type

--*------------------------------------------------------------------------

function addon:DeleteObjective(objectiveTitle)
    if type(objectiveTitle) == "table" then
        for _, objective in pairs(objectiveTitle) do
            FarmingBar.db.global.objectives[objective.frame:GetText()] = nil
        end
    else
        FarmingBar.db.global.objectives[objectiveTitle] = nil
    end

    addon.ObjectiveBuilder:LoadObjectives()
end

function addon:DeleteSelectedObjectives()
    local selected = addon.ObjectiveBuilder.objectives.selected
    if #selected > 1 then
        local dialog = StaticPopup_Show("FARMINGBAR_CONFIRM_DELETE_MULTIPLE_OBJECTIVES", #selected)
        if dialog then
            dialog.data = selected
        end
    else
        local objectiveTitle = selected[1].frame:GetText()
        local dialog = StaticPopup_Show("FARMINGBAR_CONFIRM_DELETE_OBJECTIVE", objectiveTitle)
        if dialog then
            dialog.data = objectiveTitle
        end
    end
end

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

--*------------------------------------------------------------------------

StaticPopupDialogs["FARMINGBAR_CONFIRM_DELETE_MULTIPLE_OBJECTIVES"] = {
    text = "You are about to delete %d objectives. Do you want to continue?",
    button1 = YES,
    button2 = NO,
    OnAccept = function(_, selected)
        addon:DeleteObjective(selected)
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3
}

StaticPopupDialogs["FARMINGBAR_CONFIRM_DELETE_OBJECTIVE"] = {
    text = "You are about to delete the objective \"%s\". Do you want to continue?",
    button1 = YES,
    button2 = NO,
    OnAccept = function(_, objectiveTitle)
        addon:DeleteObjective(objectiveTitle)
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3
}