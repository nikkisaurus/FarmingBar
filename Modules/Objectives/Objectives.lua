local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

local pairs = pairs
local type = type

local GetCursorInfo, ClearCursor = GetCursorInfo, ClearCursor

--*------------------------------------------------------------------------

function addon:CreateObjective(objectiveTitle, objectiveInfo, suppressLoad, suppressRename)
    local defaultTitle = L["New"]
    local defaultInfo = {
        ["enabled"] = true,
        ["autoIcon"] = true,
        ["icon"] = "134400",
        ["displayRef"] = {
            ["trackerType"] = false,
            ["trackerID"] = false,
        },
        ["trackCondition"] = "ALL",
        ["trackers"] = {},
    }

    local newObjective = FarmingBar.db.global.objectives[objectiveTitle or defaultTitle]

    local newObjectiveTitle
    if newObjective then
        local i = 2
        while not newObjectiveTitle do
            local title = string.format("%s %d", objectiveTitle or defaultTitle, i)
            if not FarmingBar.db.global.objectives[title] then
                newObjectiveTitle = title
            else
                i = i + 1
            end
        end
    end

    newObjectiveTitle = newObjectiveTitle or objectiveTitle or defaultTitle
    FarmingBar.db.global.objectives[newObjectiveTitle] = objectiveInfo or defaultInfo
    if not suppressLoad then
        self.ObjectiveBuilder:LoadObjectives(newObjectiveTitle)
    end
    if not suppressRename then
        for _, objective in pairs(self.ObjectiveBuilder.objectives.children) do
            if objective.objectiveTitle == newObjectiveTitle then
                objective.button:RenameObjective()
            end
        end
    end

    return newObjectiveTitle
end

function addon:CreateObjectiveFromCursor()
    local cursorType, cursorID = GetCursorInfo()
    if cursorType == "item" then
        ClearCursor()
        self:CacheItem(cursorID, function(itemID)
            local newObjective = self:CreateObjective((select(1, GetItemInfo(itemID))), {
                ["enabled"] = true,
                ["autoIcon"] = true,
                ["icon"] = C_Item.GetItemIconByID(itemID),
                ["displayRef"] = {
                    ["trackerType"] = "ITEM",
                    ["trackerID"] = itemID,
                },
                ["trackCondition"] = "ALL",
                ["trackers"] = {
                    {
                        ["objective"] = 0,
                        ["exclude"] = {},
                        ["includeAllChars"] = false,
                        ["trackerID"] = itemID,
                        ["includeBank"] = false,
                        ["trackerType"] = "ITEM",
                    }
                },
            }, nil, true)
        end, cursorID)
    end
end

------------------------------------------------------------

function addon:DeleteObjective(objectiveTitle)
    if type(objectiveTitle) == "table" then
        for _, objective in pairs(objectiveTitle) do
            FarmingBar.db.global.objectives[objective:GetObjectiveTitle()] = nil
        end
    else
        FarmingBar.db.global.objectives[objectiveTitle] = nil
    end

    self.ObjectiveBuilder:LoadObjectives()
end

function addon:DeleteSelectedObjectives()
    local selected = self.ObjectiveBuilder.objectives.selected
    if #selected > 1 then
        local dialog = StaticPopup_Show("FARMINGBAR_CONFIRM_DELETE_MULTIPLE_OBJECTIVES", #selected)
        if dialog then
            dialog.data = selected
        end
    else
        local objectiveTitle = selected[1]:GetObjectiveTitle()
        local dialog = StaticPopup_Show("FARMINGBAR_CONFIRM_DELETE_OBJECTIVE", objectiveTitle)
        if dialog then
            dialog.data = objectiveTitle
        end
    end
end

------------------------------------------------------------

function addon:GetIcon(objectiveTitle)
    local objectiveInfo = FarmingBar.db.global.objectives[objectiveTitle]

    local icon
    if objectiveInfo.autoIcon then
        local lookupTable = objectiveInfo.displayRef.trackerType and objectiveInfo.displayRef or objectiveInfo.trackers[1]
        local trackerType, trackerID = lookupTable and lookupTable.trackerType, lookupTable and lookupTable.trackerID

        if trackerType == "ITEM" then
            icon = C_Item.GetItemIconByID(tonumber(trackerID) or 1412) -- TODO: Remove/revise placeholder icon once trackers are implemented
        elseif trackerType == "CURRENCY" then
            -- !Revise once Shadowlands/prepatch is live.
            if C_CurrencyInfo.GetCurrencyInfo then
                icon = C_CurrencyInfo.GetCurrencyInfo(tonumber(trackerID)).iconFileID
            else
                icon = (select(3, GetCurrencyInfo(tonumber(trackerID) or 1719))) -- TODO: Remove/revise placeholder icon once trackers are implemented
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

------------------------------------------------------------

function addon:RenameObjective(objectiveTitle, newObjectiveTitle)
    if FarmingBar.db.global.objectives[newObjectiveTitle] then
        print("ERROR") -- TODO: Show StaticPopup to confirm overwrite OR reselect and reset
        return
    end

    FarmingBar.db.global.objectives[newObjectiveTitle] = FarmingBar.db.global.objectives[objectiveTitle]
    FarmingBar.db.global.objectives[objectiveTitle] = nil

    self.ObjectiveBuilder:LoadObjectives(newObjectiveTitle)
end

------------------------------------------------------------

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