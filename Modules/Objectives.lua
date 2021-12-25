local addonName = ...
local addon = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

-- *------------------------------------------------------------------------
-- Create objectives

function addon:CreateObjectiveFromCursor(widget)
    local cursorType, cursorID = GetCursorInfo()
    ClearCursor()

    if cursorType == "item" then
        local buttonDB = widget:GetButtonDB()

        buttonDB.title = GetItemInfo(cursorID) -- don't need to cache since this is from our bags, we know the info is available
        buttonDB.icon = C_Item.GetItemIconByID(cursorID)
        buttonDB.action = "ITEM"
        buttonDB.actionInfo = cursorID

        local tracker = buttonDB.trackers["ITEM:" .. cursorID]
        tracker.order = 1

        widget:UpdateLayers()
    end
end

function addon:CreateObjectiveFromDragFrame(widget, objectiveInfo)
    widget:ClearObjective() -- Remove template link when clearing objective
    local buttonDB = widget:GetButtonDB()

    for k, v in pairs(objectiveInfo) do
        if k ~= "instances" then
            if k == "trackers" then
                for key, value in pairs(v) do
                    buttonDB.trackers[key] = nil
                end
                for key, value in pairs(objectiveInfo.trackers) do
                    buttonDB.trackers[key] = {}
                    for a, b in pairs(value) do
                        buttonDB.trackers[key][a] = b
                    end
                end
            else
                buttonDB[k] = objectiveInfo[k]
            end
        end
    end

    if buttonDB.template then
        self:CreateObjectiveTemplateInstance(buttonDB.template, widget:GetButtonID())
    end

    -- for k, v in pairs(buttonDB) do
    --     if k ~= "template" and k ~= "links" then
    --         if k == "trackers" then
    --             for key, value in pairs(v) do
    --                buttonDB.trackers[key]  = nil
    --             end
    --             for key, value in pairs(objectiveInfo.trackers) do
    --                 buttonDB.trackers[key] = {}
    --                 for a, b in pairs(value) do
    --                     buttonDB.trackers[key][a] = b
    --                 end
    --             end
    --         else
    --             buttonDB[k] = objectiveInfo[k]
    --         end
    --     end
    -- end

    -- if objectiveInfo.template then
    --     buttonDB.template = objectiveInfo.template
    -- end

    widget:UpdateLayers()
end

function addon:CreateObjectiveFromCurrencyID(widget, currencyID)
    local buttonDB = widget:GetButtonDB()
    local currency = C_CurrencyInfo.GetCurrencyInfo(currencyID)

    buttonDB.title = currency.name
    buttonDB.icon = currency.iconFileID
    buttonDB.action = "CURRENCY"
    buttonDB.actionInfo = currencyID

    local tracker = buttonDB.trackers["CURRENCY:" .. currencyID]
    tracker.order = 1

    widget:UpdateLayers()
end

function addon:CreateObjectiveFromItemID(widget, itemID)
    local buttonDB = widget:GetButtonDB()

    buttonDB.icon = C_Item.GetItemIconByID(itemID)
    buttonDB.action = "ITEM"
    buttonDB.actionInfo = itemID

    local tracker = buttonDB.trackers["ITEM:" .. itemID]
    tracker.order = 1

    self:CacheItem(itemID, function(widget, buttonDB, itemID)
        buttonDB.title = (GetItemInfo(itemID))
        widget:UpdateLayers()
    end, widget, buttonDB, itemID)
end

function addon:CreateObjectiveFromTemplate(widget, template)
    local buttonDB = widget:GetButtonDB()

    buttonDB.title = template.objectiveTitle
    buttonDB.icon = C_Item.GetItemIconByID(template.itemID)
    buttonDB.action = "ITEM"
    buttonDB.actionInfo = template.itemID

    local tracker = buttonDB.trackers["ITEM:" .. template.itemID]
    tracker.order = 1

    widget:UpdateLayers()
end

function addon:CreateObjectiveFromUserTemplate(widget, template, withData)
    local buttonDB = widget:GetButtonDB()

    for k, v in pairs(template) do
        if k == "trackers" then
            for trackerID, trackerInfo in pairs(v) do
                buttonDB.trackers[trackerID] = {}
                for key, value in pairs(trackerInfo) do
                    if withData or (key ~= "includeAllChars" and key ~= "includeBank") then -- Only import data if withData is enabled
                        buttonDB.trackers[trackerID][key] = value
                    end
                end
            end
        elseif withData or k ~= "objective" then
            buttonDB[k] = v
        end
    end

    widget:UpdateLayers()
end

-- *------------------------------------------------------------------------
-- Objective info

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
            icon = C_Item.GetItemIconByID(tonumber(trackerID) or 0)
        elseif trackerType == "CURRENCY" then
            local currency = C_CurrencyInfo.GetCurrencyInfo(tonumber(trackerID) or 0)
            icon = currency and currency.iconFileID
        end
    else
        if buttonDB.icon then
            -- Convert db icon value to number if it's a file ID, otherwise use the string value
            icon = (tonumber(buttonDB.icon) and tonumber(buttonDB.icon) ~= buttonDB.icon) and tonumber(buttonDB.icon) or
                       buttonDB.icon
            icon = (icon == "" or not icon) and 134400 or icon
        end
    end

    return icon or 134400
end

function addon:GetObjectiveIncludedLayers(widget, layer)
    local total, included, notIncluded = 0, 0, 0

    for _, v in pairs(widget:GetButtonDB().trackers) do
        if v[layer] then
            included = included + 1
        else
            notIncluded = notIncluded + 1
        end
        total = total + 1
    end

    return total, included, notIncluded
end
