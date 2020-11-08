local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

local pairs = pairs
local type = type
local strfind, tonumber = string.find, tonumber

local GetCursorInfo, ClearCursor = GetCursorInfo, ClearCursor

--*------------------------------------------------------------------------

function addon:CreateObjective(objectiveTitle, objectiveInfo, overwrite, supressSelect)
    local ObjectiveBuilder = self.ObjectiveBuilder
    local defaultInfo = self:GetDefaultObjective()

    ------------------------------------------------------------

    local defaultTitle, newObjectiveTitle = L["New"]
    local newObjective = addon:GetObjectiveInfo(objectiveTitle or defaultTitle)

    if newObjective and not overwrite then
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

    ------------------------------------------------------------

    local button = addon:AddObjectiveButton(newObjectiveTitle)
    if not overwrite and ObjectiveBuilder:IsVisible() then
        button:RenameObjective()
    end
    if not supressSelect then
        ObjectiveBuilder:ClearSelectedObjective()
        ObjectiveBuilder:SelectObjective(newObjectiveTitle)
        button:SetSelected(true)
    end

    ------------------------------------------------------------

    return newObjectiveTitle
end

------------------------------------------------------------

function addon:CreateObjectiveFromCursor()
    local cursorType, cursorID = GetCursorInfo()
    ClearCursor()

    if cursorType == "item" then
        local defaultInfo = self:GetDefaultObjective()
        defaultInfo.icon = C_Item.GetItemIconByID(cursorID)
        defaultInfo.displayRef.trackerType = "ITEM"
        defaultInfo.displayRef.trackerID = cursorID

        local tracker = addon:GetDefaultTracker()
        tracker.trackerType = "ITEM"
        tracker.trackerID = cursorID

        tinsert(defaultInfo.trackers, tracker)

        local objectiveTitle = "item:"..(select(1, GetItemInfo(cursorID)))
        local overwriteQuickObjectives = FarmingBar.db.global.settings.objectives.overwriteQuickObjectives

        if addon:GetObjectiveInfo(objectiveTitle) and overwriteQuickObjectives.prompt then
            local dialog = StaticPopup_Show("FARMINGBAR_CONFIRM_OVERWRITE_OBJECTIVE", objectiveTitle)
            if dialog then
                dialog.data = objectiveTitle
                dialog.data2 = defaultInfo
            end
        elseif not overwriteQuickObjectives.useExisting then
            self:CreateObjective(objectiveTitle, defaultInfo, overwriteQuickObjectives.enabled)
        end

        return objectiveTitle
    end
end

------------------------------------------------------------

function addon:DeleteObjective(objectiveTitle)
    local ObjectiveBuilder = self.ObjectiveBuilder
    local objectiveList = ObjectiveBuilder:GetUserData("objectiveList")

    if not objectiveTitle then
        local releaseKeys = {}
        for key, button in pairs(objectiveList.children) do
            if button:GetUserData("selected") and not button:GetUserData("filtered") then
                local objectiveTitle = button:GetObjective()

                FarmingBar.db.global.objectives[objectiveTitle] = nil
                tinsert(releaseKeys, key)

                if ObjectiveBuilder:GetSelectedObjective() == objectiveTitle then
                    ObjectiveBuilder:ClearSelectedObjective()
                end

                self:UpdateExclusions(objectiveTitle)
                self:ClearDeletedObjectives(objectiveTitle)
            end
        end

        -- Release buttons after the initial loop, backwards, to ensure all buttons are properly released
        for _, key in addon.pairs(releaseKeys, function(a, b) return b < a end) do
            ObjectiveBuilder:ReleaseChild(objectiveList.children[key])
        end
    else
        FarmingBar.db.global.objectives[objectiveTitle] = nil
        if ObjectiveBuilder:GetSelectedObjective() == objectiveTitle then
            ObjectiveBuilder:ClearSelectedObjective()
        end
        ObjectiveBuilder:ReleaseChild(ObjectiveBuilder:GetObjectiveButton(objectiveTitle))
        self:UpdateExclusions(objectiveTitle)
        self:ClearDeletedObjectives(objectiveTitle)
    end

    ObjectiveBuilder:RefreshObjectives()
end

------------------------------------------------------------

function addon:DeleteSelectedObjectives()
    local selectedButton
    local numSelectedButtons = 0
    for _, button in pairs(self.ObjectiveBuilder:GetUserData("objectiveList").children) do
        if button:GetUserData("selected") and not button:GetUserData("filtered") then
            numSelectedButtons = numSelectedButtons + 1
            selectedButton = button
        end
    end

    if numSelectedButtons > 1 then
        local dialog = StaticPopup_Show("FARMINGBAR_CONFIRM_DELETE_MULTIPLE_OBJECTIVES", numSelectedButtons)
        if dialog then
            dialog.data = selected
        end
    else
        local objectiveTitle = selectedButton:GetUserData("objectiveTitle")
        local dialog = StaticPopup_Show("FARMINGBAR_CONFIRM_DELETE_OBJECTIVE", objectiveTitle)
        if dialog then
            dialog.data = objectiveTitle
        end
    end
end

------------------------------------------------------------

function addon:DuplicateSelectedObjectives()
    local ObjectiveBuilder = self.ObjectiveBuilder
    local buttons = ObjectiveBuilder:GetUserData("objectiveList").children

    local pendingSelect
    for key, button in pairs(buttons) do
        local objectiveTitle = button:GetObjective()
        if button:GetUserData("selected") then
            button:SetSelected(false)
            pendingSelect = self:CreateObjective(objectiveTitle, self:GetObjectiveInfo(objectiveTitle), _, true)
        end
    end

    ObjectiveBuilder:ClearSelectedObjective()
    ObjectiveBuilder:SelectObjective(pendingSelect)
end

------------------------------------------------------------

function addon:GetObjectiveIcon(objectiveTitle)
    local objectiveInfo = addon:GetObjectiveInfo(objectiveTitle)
    if not objectiveInfo then return end

    local icon
    if objectiveInfo.autoIcon then
        local lookupTable = (objectiveInfo.displayRef.trackerType and objectiveInfo.displayRef.trackerType ~= "MACROTEXT") and objectiveInfo.displayRef or objectiveInfo.trackers[1]
        local trackerType, trackerID = lookupTable and lookupTable.trackerType, lookupTable and lookupTable.trackerID

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

------------------------------------------------------------

function addon:GetObjectiveInfo(objectiveTitle, tracker)
    local objectiveInfo = FarmingBar.db.global.objectives[objectiveTitle]
    local trackerInfo = objectiveInfo and tracker and self:GetTrackerInfo(objectiveTitle, tracker)

    return objectiveInfo, trackerInfo
end

------------------------------------------------------------

function addon:GetSelectedObjectiveInfo()
    local ObjectiveBuilder = self.ObjectiveBuilder
    local objectiveTitle = ObjectiveBuilder:GetSelectedObjective()
    local objectiveInfo = self:GetObjectiveInfo(objectiveTitle)
    local tracker = ObjectiveBuilder:GetSelectedTracker()
    local trackerInfo = tracker and self:GetTrackerInfo(objectiveTitle, tracker)

    return objectiveTitle, objectiveInfo, tracker, trackerInfo
end

------------------------------------------------------------

function addon:IsObjectiveAutoItem(objectiveTitle)
    return objectiveTitle and strfind(objectiveTitle, "^item:")
end

------------------------------------------------------------

function addon:IsObjectiveBankIncluded(objectiveTitle)
    return self:IsObjectiveAutoItem(objectiveTitle) and self:GetTrackerInfo(objectiveTitle, 1).includeBank
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

function addon:GetObjectiveCount(button, objectiveTitle)
    local objectiveInfo = self:GetObjectiveInfo(objectiveTitle)
    if not objectiveInfo then return end

    if #objectiveInfo.trackers == 0 then return 0 end

    local count = 0
    if objectiveInfo.trackerCondition == "ANY" then
        for _, trackerInfo in pairs(objectiveInfo.trackers) do
            count = count + addon:GetTrackerCount(trackerInfo)
        end
    elseif objectiveInfo.trackerCondition == "ALL" then
        local pendingCount
        for _, trackerInfo in pairs(objectiveInfo.trackers) do
            if not pendingCount then
                pendingCount = addon:GetTrackerCount(trackerInfo)
            else
                pendingCount = min(pendingCount, addon:GetTrackerCount(trackerInfo))
            end
        end
        count = count + pendingCount
    elseif objectiveInfo.trackerCondition == "CUSTOM" then
        -- Custom conditions should be a table with nested tables inside
        -- Each nested table is an objectiveGroup which will be evaluated like an objective with an ALL condition
        -- The first nested tables will use item counts before following tables; this means the order matters!
        -- E.g. if you want to make as many of your least material required, put that first and then any remaining mats can go toward the following table
        -- Nested tables should be key value pairs where key is in the format t%d, where %d is the tracker number, and value is the required count
        -- Objective saved in trackerInfo will not be used in custom conditions
        local customCondition = addon:ValidateCustomCondition(objectiveInfo.customCondition)

        if customCondition and customCondition ~= "" then
            local countsUsed = {}
            for key, objectiveGroup in pairs(customCondition) do
                local pendingCount
                for trackerID, objective in pairs(objectiveGroup) do
                    trackerID = tonumber(strmatch(trackerID, "^t(%d+)$"))
                    local trackerInfo = objectiveInfo.trackers[trackerID]
                    if trackerInfo then
                        local info = {}
                        for k, v in pairs(trackerInfo) do
                            info[k] = k ~= "objective" and v or objective
                        end
                        local trackerCount = addon:GetTrackerCount(info)
                        local used = countsUsed[trackerID]

                        if used then
                            trackerCount = ((trackerCount * objective) - used) / objective
                            trackerCount = trackerCount > 0 and trackerCount or 0
                        end

                        if not pendingCount then
                            pendingCount = trackerCount
                        else
                            pendingCount = min(pendingCount, trackerCount)
                        end

                        countsUsed[trackerID] = (used or 0) + (pendingCount * objective)
                    end
                end
                count = count + (pendingCount or 0)
            end
        end
    end

    return count > 0 and count or 0
end

------------------------------------------------------------

function addon:RenameObjective(objectiveTitle, newObjectiveTitle)
    if addon:GetObjectiveInfo(newObjectiveTitle) then
        print("ERROR") -- TODO: Show StaticPopup to confirm overwrite OR reselect and reset
        return
    end

    FarmingBar.db.global.objectives[newObjectiveTitle] = FarmingBar.db.global.objectives[objectiveTitle]
    FarmingBar.db.global.objectives[objectiveTitle] = nil

    self:UpdateExclusions(objectiveTitle, newObjectiveTitle)
    self:UpdateRenamedObjectiveButtons(objectiveTitle, newObjectiveTitle)
end

------------------------------------------------------------

function addon:SetObjectiveDBInfo(key, value, objectiveTitle)
    local title = objectiveTitle or addon.ObjectiveBuilder:GetSelectedObjective()
    local keys = {strsplit(".", key)}
    local path = FarmingBar.db.global.objectives[title]

    for k, key in pairs(keys) do
        if k < #keys then
            path = path[key]
        end
    end

    path[keys[#keys]] = value

    ------------------------------------------------------------

    addon:UpdateButtons(title)

    -- if not objectiveTitle then
        self.ObjectiveBuilder:RefreshObjectives()
    -- end
end

------------------------------------------------------------

function addon:ValidateCustomCondition(condition)
    -- return {{t1 = 10, t2 = 2, t3 = 3}, {t1 = 5}}

    if condition == "" then
        -- Clearing custom condition; return blank table to prevent errors in GetObjectiveCount
        return {}
    elseif not strfind(condition, "return") then
        -- Invalid format, missing return
        return false, L.InvalidCustomConditionReturn
    end

    local func, err = loadstring(condition)
    -- Syntax error
    if err then
        return false, L.invalidSyntax(err)
    end

    local tbl = func()
    -- Return isn't a table
    if type(tbl) ~= "table" then
        return false, L.InvalidCustomConditionReturn
    end

    for _, trackerGroup in pairs(tbl) do
        if type(trackerGroup) ~= "table" then
            -- trackerGroup is not a table
            return false, L.InvalidCustomConditionTable
        else
            for trackerID, objective in pairs(trackerGroup) do
                local validKey = tonumber(strmatch(trackerID, "^t(%d+)$"))
                if not validKey then
                    -- trackerID is not properly formatted
                    return false, L.InvalidCustomConditionID
                elseif type(objective) ~= "number" or not objective or objective < 1 then
                    -- objective is not a number
                    return false, L.InvalidCustomConditionObjective
                end
            end
        end
    end

    return tbl
end