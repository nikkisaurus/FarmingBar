local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

local pairs = pairs
local type = type
local tonumber = tonumber

local GetCursorInfo, ClearCursor = GetCursorInfo, ClearCursor

--*------------------------------------------------------------------------

function addon:CreateObjective(objectiveTitle, objectiveInfo, suppressLoad, finished, fromCursor)
    -- Create objective from cursor
    if fromCursor then
        local cursorType, cursorID = GetCursorInfo()
        if cursorType == "item" then
            ClearCursor()
            self:CacheItem(cursorID, function(itemID)
                local newObjective = self:CreateObjective((select(1, GetItemInfo(itemID))), {
                    ["enabled"] = true,
                    ["objective"] = false,
                    ["autoIcon"] = true,
                    ["icon"] = C_Item.GetItemIconByID(itemID),
                    ["displayRef"] = {
                        ["trackerType"] = "ITEM",
                        ["trackerID"] = itemID,
                    },
                    ["trackCondition"] = "ALL",
                    ["trackFunc"] = "",
                    ["trackers"] = {
                        {
                            ["trackerType"] = "ITEM",
                            ["trackerID"] = itemID,
                            ["objective"] = 1,
                            ["includeBank"] = false,
                            ["includeAllChars"] = false,
                            ["exclude"] = {
                            },
                        }
                    },
                })
            end, cursorID)
            return
        end
    end

    ------------------------------------------------------------

    local defaultTitle = L["New"]
    local defaultInfo = {
        ["enabled"] = true,
        ["objective"] = false,
        ["autoIcon"] = true,
        ["icon"] = "134400",
        ["displayRef"] = {
            ["trackerType"] = false,
            ["trackerID"] = false,
        },
        ["trackCondition"] = "ALL",
        ["trackFunc"] = "",
        ["trackers"] = {},
    }

    local newObjective = addon:GetObjectiveInfo(objectiveTitle or defaultTitle)

    local newObjectiveTitle
    if newObjective then
        local i = 2
        while not newObjectiveTitle do
            local title = string.format("%s %d", objectiveTitle or defaultTitle, i)
            if not addon:GetObjectiveInfo(title) then
                newObjectiveTitle = title
            else
                i = i + 1
            end
        end
    end

    newObjectiveTitle = newObjectiveTitle or objectiveTitle or defaultTitle
    FarmingBar.db.global.objectives[newObjectiveTitle] = objectiveInfo or defaultInfo
    if not suppressLoad or finished then
        -- Call when adding multiple at a time and then manually load objectives when done
        self.ObjectiveBuilder:LoadObjectives(newObjectiveTitle)
    end
    return newObjectiveTitle
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
    local selected = self.ObjectiveBuilder.status.selected
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

function addon:GetObjectiveIcon(objectiveTitle)
    local objectiveInfo = addon:GetObjectiveInfo(objectiveTitle)

    local icon
    if objectiveInfo.autoIcon then
        local lookupTable = objectiveInfo.displayRef.trackerType and objectiveInfo.displayRef or objectiveInfo.trackers[1]
        local trackerType, trackerID = lookupTable and lookupTable.trackerType, lookupTable and lookupTable.trackerID

        if trackerType == "ITEM" then
            icon = C_Item.GetItemIconByID(tonumber(trackerID) or 1412) -- TODO: Remove/revise placeholder icon once trackers are implemented
        elseif trackerType == "CURRENCY" then
            local currency = C_CurrencyInfo.GetCurrencyInfo(tonumber(trackerID) or 0)
            icon = currency and currency.iconFileID or 1719 -- TODO: Remove/revise placeholder icon once trackers are implemented
        end
    else
        if objectiveInfo.icon then
            -- Convert db icon value to number if it's a file ID, otherwise use the string value
            icon = (tonumber(objectiveInfo.icon) and tonumber(objectiveInfo.icon) ~= objectiveInfo.icon) and tonumber(objectiveInfo.icon) or objectiveInfo.icon
            icon = (icon == "" or not icon) and 134400 or icon
        else
            icon = 134400
        end
    end

    return icon
end

------------------------------------------------------------

function addon:GetObjectiveInfo(objectiveTitle)
    return FarmingBar.db.global.objectives[objectiveTitle]
end

------------------------------------------------------------

function addon:ObjectiveExists(objective)
    for objectiveTitle, _ in pairs(FarmingBar.db.global.objectives) do
        if strupper(objectiveTitle) == strupper(objective) then
            return objectiveTitle
        end
    end
end

------------------------------------------------------------

function addon:ObjectiveIsExcluded(excluded, objective)
    for _, objectiveTitle in pairs(excluded) do
        if strupper(objectiveTitle) == strupper(objective) then
            return objectiveTitle
        end
    end
end

------------------------------------------------------------

function addon:RenameObjective(objectiveTitle, newObjectiveTitle)
    if addon:GetObjectiveInfo(newObjectiveTitle) then
        print("ERROR") -- TODO: Show StaticPopup to confirm overwrite OR reselect and reset
        return
    end

    FarmingBar.db.global.objectives[newObjectiveTitle] = FarmingBar.db.global.objectives[objectiveTitle]
    FarmingBar.db.global.objectives[objectiveTitle] = nil

    self.ObjectiveBuilder:LoadObjectives(newObjectiveTitle)
end

------------------------------------------------------------

function addon:SetObjectiveDBInfo(objectiveTitle, key, value)
    local keys = {strsplit(".", key)}
    local path = FarmingBar.db.global.objectives[objectiveTitle]
    for k, key in pairs(keys) do
        if k < #keys then
            path = path[key]
        end
    end
    path[keys[#keys]] = value
end