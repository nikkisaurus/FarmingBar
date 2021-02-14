local addonName = ...
local addon = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

------------------------------------------------------------

local loadstring, select, type = loadstring, select, type
local min = math.min
local format, strfind, strmatch, strsplit, strupper, tonumber = string.format, string.find, string.match, strsplit, string.upper, tonumber
local pairs, tinsert = pairs, table.insert

local GetCursorInfo, ClearCursor = GetCursorInfo, ClearCursor
local GetItemIconByID = C_Item.GetItemIconByID
--@retail@
local GetCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo
--@end-retail@
local StaticPopup_Show = StaticPopup_Show

--*------------------------------------------------------------------------

function addon:GetObjectiveDBValue(key, objectiveTitle)
    local keys = {strsplit(".", key)}
    local path = self:GetDBValue("global", "objectives")[objectiveTitle]

    for k, key in pairs(keys) do
        if k < #keys then
            path = path[key]
        end
    end

    return path[keys[#keys]]
end

------------------------------------------------------------

function addon:SetObjectiveDBValue(key, value, objectiveTitle)
    local keys = {strsplit(".", key)}
    local path = self:GetDBValue("global", "objectives")[objectiveTitle]

    for k, key in pairs(keys) do
        if k < #keys then
            path = path[key]
        end
    end

    if value == "_TOGGLE_" then
        if path[keys[#keys]] then
            value = false
        else
            value = true
        end
    end

    path[keys[#keys]] = value

    -- self:UpdateButtons(objectiveTitle)
end

--*------------------------------------------------------------------------

function addon:CreateObjectiveFromCursor(widget)
    local cursorType, cursorID = GetCursorInfo()
    ClearCursor()

    if cursorType == "item" then
        local buttonDB = widget:GetButtonDB()

        buttonDB.title = GetItemInfo(cursorID) -- don't need to cache since this is from our bags, we know the info is available
        buttonDB.icon = GetItemIconByID(cursorID)
        buttonDB.action = "ITEM"
        buttonDB.actionInfo = cursorID

        local tracker =  buttonDB.trackers["ITEM:"..cursorID]
        tracker.order = 1

        widget:UpdateLayers()
    end
end

------------------------------------------------------------

function addon:CreateObjectiveFromTemplate()

end

------------------------------------------------------------

function addon:CreateObjectiveTemplate(objectiveTitle, overwrite, supressSelect)
    local defaultTitle, newObjectiveTitle = L["New"]
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

    ------------------------------------------------------------

    local objectiveTemplate = self:GetDBValue("global", "objectives")[newObjectiveTitle]
    objectiveTemplate.title = newObjectiveTitle

    self:RefreshObjectiveBuilderOptions()
    if not supressSelect then
        LibStub("AceConfigDialog-3.0"):SelectGroup(addonName, "objectiveBuilder", newObjectiveTitle)
    end

    ------------------------------------------------------------

    return newObjectiveTitle
end

--*------------------------------------------------------------------------

function addon:GetObjectiveCount(widget, objectiveTitle)
    local buttonDB = widget:GetButtonDB()

    local count = 0
    if buttonDB.condition == "ANY" then
        for _, trackerInfo in pairs(buttonDB.trackers) do
            count = count + addon:GetTrackerCount(objectiveTitle, trackerInfo)
        end
    elseif buttonDB.condition == "ALL" then
        local pendingCount
        for trackerKey, _ in pairs(buttonDB.trackers) do
            if not pendingCount then
                pendingCount = addon:GetTrackerCount(widget, trackerKey)
            else
                pendingCount = min(pendingCount, addon:GetTrackerCount(widget, trackerKey))
            end
        end
        count = count + pendingCount
    elseif buttonDB.condition == "CUSTOM" then
        -- -- Custom conditions should be a table with nested tables inside
        -- -- Each nested table is an objectiveGroup which will be evaluated like an objective with an ALL condition
        -- -- The first nested tables will use item counts before following tables; this means the order matters!
        -- -- E.g. if you want to make as many of your least material required, put that first and then any remaining mats can go toward the following table
        -- -- Nested tables should be key value pairs where key is in the format t%d, where %d is the tracker number, and value is the required count
        -- -- Objective saved in trackerInfo will not be used in custom conditions
        -- local customCondition = addon:ValidateCustomCondition(buttonDB.customCondition)

        -- if customCondition and customCondition ~= "" then
        --     local countsUsed = {}
        --     for key, objectiveGroup in pairs(customCondition) do
        --         local pendingCount
        --         for trackerID, objective in pairs(objectiveGroup) do
        --             trackerID = tonumber(strmatch(trackerID, "^t(%d+)$"))
        --             local trackerInfo = buttonDB.trackers[trackerID]
        --             if trackerInfo then
        --                 local info = {}
        --                 for k, v in pairs(trackerInfo) do
        --                     info[k] = k ~= "objective" and v or objective
        --                 end
        --                 local trackerCount = addon:GetTrackerCount(objectiveTitle, info)
        --                 local used = countsUsed[trackerID]

        --                 if used then
        --                     trackerCount = ((trackerCount * objective) - used) / objective
        --                     trackerCount = trackerCount > 0 and trackerCount or 0
        --                 end

        --                 if not pendingCount then
        --                     pendingCount = trackerCount
        --                 else
        --                     pendingCount = min(pendingCount, trackerCount)
        --                 end

        --                 countsUsed[trackerID] = (used or 0) + (pendingCount * objective)
        --             end
        --         end
        --         count = count + (pendingCount or 0)
        --     end
        -- end
    end

    return count > 0 and count or 0
end

------------------------------------------------------------

function addon:GetObjectiveIcon(widget)
    local buttonDB = widget:GetButtonDB()

    local icon
    if buttonDB.autoIcon then
        local trackerType, trackerID
        if buttonDB.action == "ITEM" or buttonDB.action == "CURRENCY" then
            trackerType, trackerID = buttonDB.action, buttonDB.actionInfo
        else
            trackerType, trackerID = self:ParseTrackerKey(self:GetFirstTracker(widget))
        end

        if trackerType == "ITEM" then
            icon = GetItemIconByID(tonumber(trackerID) or 0)
        elseif trackerType == "CURRENCY" then
            local currency = GetCurrencyInfo(tonumber(trackerID) or 0)
            icon = currency and currency.iconFileID
        end
    else
        if buttonDB.icon then
            -- Convert db icon value to number if it's a file ID, otherwise use the string value
            icon = (tonumber(buttonDB.icon) and tonumber(buttonDB.icon) ~= buttonDB.icon) and tonumber(buttonDB.icon) or buttonDB.icon
            icon = (icon == "" or not icon) and 134400 or icon
        end
    end

    return icon or 134400
end

------------------------------------------------------------

function addon:GetObjectiveTemplateIcon(objectiveTitle)
    local objectiveInfo = self:GetDBValue("global", "objectives")[objectiveTitle]

    local icon
    if objectiveInfo.autoIcon then
        local trackerType, trackerID
        if objectiveInfo.action == "ITEM" or objectiveInfo.action == "CURRENCY" then
            trackerType, trackerID = objectiveInfo.action, objectiveInfo.actionInfo
        else
            trackerType, trackerID = self:ParseTrackerKey(self:GetFirstTemplateTracker(objectiveTitle))
        end

        if trackerType == "ITEM" then
            icon = GetItemIconByID(tonumber(trackerID) or 0)
        elseif trackerType == "CURRENCY" then
            local currency = GetCurrencyInfo(tonumber(trackerID) or 0)
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

function addon:IsObjectiveBankIncluded(widget)
    local total, included, notIncluded = 0, 0, 0
    for _, v in pairs(widget:GetButtonDB().trackers) do
        if v.includeBank then
            included = included + 1
        else
            notIncluded = notIncluded + 1
        end
        total = total + 1
    end

    return total, included, notIncluded
end

------------------------------------------------------------

function addon:ObjectiveTemplateExists(objectiveTitle)
    return self:GetDBValue("global", "objectives")[objectiveTitle].title ~= ""
end

--*------------------------------------------------------------------------

-- function addon:CleanupQuickObjectives()
--     local count = 0
--     for objectiveTitle, _ in pairs(addon.db.global.objectives) do
--         if self:IsObjectiveAutoItem(objectiveTitle) and self:GetNumButtonsContainingObjective(objectiveTitle) == 0 then
--             self:DeleteObjective(objectiveTitle)
--             count = count + 1
--         end
--     end

--     StaticPopup_Show("FARMINGBAR_OBJECTIVE_CLEANUP_FINISHED", count)
-- end

------------------------------------------------------------

-- function addon:CreateObjectiveTemplate(objectiveTitle, objectiveInfo, overwrite, supressSelect)
--     local defaultInfo = self:GetDefaultObjective()
--     if objectiveInfo then
--         -- If we don't do it this way, the table ref to the duplicated objective will remain and changes will happen to both
--         for k, v in pairs(objectiveInfo) do
--             defaultInfo[k] = v
--         end
--     end

--     ------------------------------------------------------------

--     local defaultTitle, newObjectiveTitle = L["New"]
--     local newObjective = addon:GetObjectiveInfo(objectiveTitle or defaultTitle)
--     local isNew = not newObjective

--     if newObjective and not overwrite then
--         local i = 2
--         while not newObjectiveTitle do
--             local title = format("%s %d", objectiveTitle or defaultTitle, i)
--             if not addon:GetObjectiveInfo(title) then
--                 newObjectiveTitle = title
--             else
--                 i = i + 1
--             end
--         end
--     end

--     newObjectiveTitle = newObjectiveTitle or objectiveTitle or defaultTitle
--     addon.db.global.objectives[newObjectiveTitle] = defaultInfo

--     ------------------------------------------------------------

--     self:UpdateButtons()
--     self:RefreshObjectiveBuilderOptions()
--     if not supressSelect then
--         LibStub("AceConfigDialog-3.0"):SelectGroup(addonName, "objectiveBuilder", newObjectiveTitle) -- TODO: reenable add suppress
--     end

--     ------------------------------------------------------------

--     return newObjectiveTitle
-- end

------------------------------------------------------------

-- function addon:CreateObjectiveFromID(objectiveTitle, itemID, widget, suppressSelect)
--     local defaultInfo = self:GetDefaultObjective()
--     defaultInfo.icon = GetItemIconByID(itemID)
--     defaultInfo.displayRef.trackerType = "ITEM"
--     defaultInfo.displayRef.trackerID = itemID

--     local tracker = addon:GetDefaultTracker()
--     tracker.trackerType = "ITEM"
--     tracker.trackerID = itemID

--     tinsert(defaultInfo.trackers, tracker)

--     ------------------------------------------------------------

--     self:CreateQuickObjective(objectiveTitle, defaultInfo, widget, suppressSelect)
-- end

------------------------------------------------------------

-- function addon:CreateQuickObjective(objectiveTitle, defaultInfo, widget, suppressSelect)
--     local overwriteQuickObjectives = addon.db.global.settings.newQuickObjectives

--     if self:GetObjectiveInfo(objectiveTitle) and overwriteQuickObjectives == "PROMPT" then -- PROMPT
--         local dialog = StaticPopup_Show("FARMINGBAR_CONFIRM_NEW_QUICK_OBJECTIVE_PROMPT", objectiveTitle)
--         if dialog then
--             dialog.data = {widget = widget, objectiveTitle = objectiveTitle, defaultInfo = defaultInfo}
--         end
--     elseif overwriteQuickObjectives == "OVERWRITE" then -- OVERWRITE
--         self:CreateObjectiveTemplate(objectiveTitle, defaultInfo, true, suppressSelect)
--     elseif overwriteQuickObjectives == "NEW" then -- CREATE NEW
--         objectiveTitle = self:CreateObjectiveTemplate(objectiveTitle, defaultInfo, nil, suppressSelect)
--     elseif not self:GetObjectiveInfo(objectiveTitle) then
--         objectiveTitle = self:CreateObjectiveTemplate(objectiveTitle, defaultInfo, nil, suppressSelect)
--     end

--     if widget then
--         widget:SetObjectiveID(objectiveTitle)
--     end

--     return objectiveTitle
-- end

------------------------------------------------------------

-- function addon:DeleteObjective(objectiveTitle, confirmed)
--     -- Check if objective is used in a template and confirm deletion
--     local templateContainsObjective = self:TemplateContainsObjective(objectiveTitle)
--     if not confirmed and templateContainsObjective > 0 then
--         local dialog = StaticPopup_Show("FARMINGBAR_CONFIRM_DELETE_OBJECTIVE_USED_IN_TEMPLATE", objectiveTitle, templateContainsObjective)
--         if dialog then
--             dialog.data = objectiveTitle
--         end
--         return
--     end

--     -- Delete objective
--     addon.db.global.objectives[objectiveTitle] = nil
--     self:UpdateExclusions(objectiveTitle)
--     self:ClearDeletedObjectives(objectiveTitle)
--     self:RefreshObjectiveBuilderOptions()
-- end

------------------------------------------------------------

-- function addon:DeleteSelectedObjectives()
--     local selectedButton
--     local numSelectedButtons = 0
--     local tracked = 0
--     for _, button in pairs(self.ObjectiveBuilder:GetUserData("objectiveList").children) do
--         if button:GetUserData("selected") and not button:GetUserData("filtered") then
--             numSelectedButtons = numSelectedButtons + 1
--             selectedButton = button
--             tracked = tracked + addon:GetNumButtonsContainingObjective(button:GetObjective())
--         end
--     end

--     if numSelectedButtons > 1 then

--         local dialog = StaticPopup_Show("FARMINGBAR_CONFIRM_DELETE_MULTIPLE_OBJECTIVES", numSelectedButtons, tracked)
--     else
--         local objectiveTitle = selectedButton:GetUserData("objectiveTitle")
--         local dialog = StaticPopup_Show("FARMINGBAR_CONFIRM_DELETE_OBJECTIVE", objectiveTitle, self:GetNumButtonsContainingObjective(objectiveTitle))
--         if dialog then
--             dialog.data = objectiveTitle
--         end
--     end
-- end

------------------------------------------------------------

-- function addon:DuplicateSelectedObjectives()
--     local ObjectiveBuilder = self.ObjectiveBuilder
--     local buttons = ObjectiveBuilder:GetUserData("objectiveList").children

--     local pendingSelect
--     for key, button in pairs(buttons) do
--         local objectiveTitle = button:GetObjective()
--         if button:GetUserData("selected") then
--             button:SetSelected(false)
--             pendingSelect = self:CreateObjectiveTemplate(objectiveTitle, self:GetObjectiveInfo(objectiveTitle), nil, true)
--         end
--     end

--     ObjectiveBuilder:ClearSelectedObjective()
--     ObjectiveBuilder:SelectObjective(pendingSelect)
-- end

------------------------------------------------------------

-- function addon:GetNumButtonsContainingObjective(objectiveTitle)
--     local count = 0
--     for _, charDB in pairs(FarmingBarDB.char) do
--         for _, bar in pairs(charDB.bars) do
--             for _, objective in pairs(bar.objectives) do
--                 -- print(objective, objectiveTitle)
--                 if objective.objectiveTitle == objectiveTitle then
--                     count = count + 1
--                 end
--             end
--         end
--     end
--     return count
-- end

------------------------------------------------------------

-- function addon:GetObjectiveInfo(objectiveTitle, tracker)
--     local objectiveInfo = addon.db.global.objectives[objectiveTitle]
--     local trackerInfo = objectiveInfo and tracker and self:GetTrackerInfo(objectiveTitle, tracker)

--     return objectiveInfo, trackerInfo
-- end

------------------------------------------------------------

-- function addon:GetSelectedObjectiveInfo()
--     local ObjectiveBuilder = self.ObjectiveBuilder
--     local objectiveTitle = ObjectiveBuilder:GetSelectedObjective()
--     local objectiveInfo = self:GetObjectiveInfo(objectiveTitle)
--     local tracker = ObjectiveBuilder:GetSelectedTracker()
--     local trackerInfo = tracker and self:GetTrackerInfo(objectiveTitle, tracker)

--     return objectiveTitle, objectiveInfo, tracker, trackerInfo
-- end

------------------------------------------------------------

-- function addon:IsObjectiveAutoItem(objectiveTitle)
--     return objectiveTitle and strfind(objectiveTitle, "^item:")
-- end

------------------------------------------------------------

-- function addon:ObjectiveExists(objective)
--     for objectiveTitle, _ in pairs(addon.db.global.objectives) do
--         if strupper(objectiveTitle) == strupper(objective) then
--             return objectiveTitle
--         end
--     end
-- end

------------------------------------------------------------

-- function addon:ObjectiveIsExcluded(excluded, objective)
--     for _, objectiveTitle in pairs(excluded) do
--         if strupper(objectiveTitle) == strupper(objective) then
--             return objectiveTitle
--         end
--     end
-- end
------------------------------------------------------------

-- function addon:RenameObjective(objectiveTitle, newObjectiveTitle)
--     addon.db.global.objectives[newObjectiveTitle] = addon.db.global.objectives[objectiveTitle]
--     addon.db.global.objectives[objectiveTitle] = nil

--     self:UpdateExclusions(objectiveTitle, newObjectiveTitle)
--     self:UpdateRenamedObjectiveButtons(objectiveTitle, newObjectiveTitle)

--     self:RefreshObjectiveBuilderOptions()
-- end

------------------------------------------------------------

-- function addon:ValidateCustomCondition(condition)
--     -- return {{t1 = 10, t2 = 2, t3 = 3}, {t1 = 5}}

--     if condition == "" then
--         -- Clearing custom condition; return blank table to prevent errors in GetObjectiveCount
--         return {}
--     elseif not strfind(condition, "return") then
--         -- Invalid format, missing return
--         return false, L.InvalidCustomConditionReturn
--     end

--     local func, err = loadstring(condition)
--     -- Syntax error
--     if err then
--         return false, L.invalidSyntax(err)
--     end

--     local tbl = func()
--     -- Return isn't a table
--     if type(tbl) ~= "table" then
--         return false, L.InvalidCustomConditionReturn
--     end

--     for _, trackerGroup in pairs(tbl) do
--         if type(trackerGroup) ~= "table" then
--             -- trackerGroup is not a table
--             return false, L.InvalidCustomConditionTable
--         else
--             for trackerID, objective in pairs(trackerGroup) do
--                 local validKey = tonumber(strmatch(trackerID, "^t(%d+)$"))
--                 if not validKey then
--                     -- trackerID is not properly formatted
--                     return false, L.InvalidCustomConditionID
--                 elseif type(objective) ~= "number" or not objective or objective < 1 then
--                     -- objective is not a number
--                     return false, L.InvalidCustomConditionObjective
--                 end
--             end
--         end
--     end

--     return tbl
-- end