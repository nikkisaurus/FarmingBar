local addonName = ...
local addon = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)


--*------------------------------------------------------------------------
-- Counts


function addon:BAG_UPDATE_DELAYED(...)
    for trackerID, buttonIDs in pairs(self.trackers) do
        for _, buttonID in pairs(buttonIDs) do
            -- Get old count, then update count
            local button = self.bars[buttonID[1]]:GetButtons()[buttonID[2]]
            local oldCount, oldTrackerCounts = button:GetCount()
            button:SetCount()

            local alerts = self:GetBarDBValue("alerts", buttonID[1], true)
            if not alerts.muteAll then
                 -- Get info for alerts
                local buttonDB = button:GetButtonDB()
                local newCount, trackerCounts = button:GetCount()
                local objective = button:GetObjective()
                local alertInfo, alert, soundID, barAlert

                -- Change in objective count
                if oldCount ~= newCount then
                    if objective > 0 then
                        if alerts.completedObjectives or (not alerts.completedObjectives and ((oldCount < objective) or (newCount < oldCount and newCount < objective))) then
                            alert = self:GetDBValue("global", "settings.alerts.button.format.withObjective")

                            if oldCount < objective and newCount >= objective then
                                soundID = "objectiveComplete"
                                barAlert = "complete"
                            else
                                soundID = oldCount < newCount and "progress"
                                -- Have to check if we lost an objective
                                if oldCount >= objective and newCount < objective then
                                    barAlert = "lost"
                                end
                            end
                        end
                    else
                        -- No objective
                        alert = self:GetDBValue("global", "settings.alerts.button.format.withoutObjective")
                        soundID = oldCount < newCount and "progress"
                    end

                    -- Setup alertInfo
                    local difference = newCount - oldCount
                    alertInfo = {
                        objectiveTitle = buttonDB.title,
                        objective = {
                            color = objective > 0 and (newCount >= objective and "|cff00ff00" or "|cffffcc00") or "",
                            count = objective,
                        },
                        oldCount = oldCount,
                        newCount = newCount,
                        difference = {
                            sign = difference > 0 and "+" or difference < 0 and "",
                            color =  difference > 0 and "|cff00ff00" or difference < 0 and "|cffff0000",
                            count = difference,
                        },
                    }
                end

                if alertInfo then
                    self:SendAlert("button", alert, alertInfo, soundID)

                    if barAlert then
                        -- local progressCount, progressTotal = self:GetBar():GetProgress()

                        -- if barAlert == "complete" then
                        --     progressCount = progressCount - 1
                        -- elseif barAlert == "lost" then
                        --     progressCount = progressCount + 1
                        -- end

                        -- self:GetBar():AlertProgress(progressCount, progressTotal)
                    end
                elseif trackerCounts then -- CHange in tracker count
                    for trackerKey, newTrackerCount in pairs(trackerCounts) do
                        oldTrackerCount = oldTrackerCounts[trackerKey]
                        if oldTrackerCount and oldTrackerCount ~= newTrackerCount then
                            alert = self:GetDBValue("global", "settings.alerts.tracker.format.progress")
                            soundID = oldTrackerCount < newTrackerCount and "progress"

                            local trackerObjective = self:GetTrackerDBInfo(buttonDB.trackers, trackerKey, "objective")
                            local difference, trackerDifference = newCount - oldCount, newTrackerCount - oldTrackerCount

                            alertInfo = {
                                objectiveTitle = buttonDB.title,
                                objective = {
                                    color = objective > 0 and (newCount >= objective and "|cff00ff00" or "|cffffcc00") or "",
                                    count = objective,
                                },
                                trackerObjective = {
                                    color = trackerObjective and (newTrackerCount >= trackerObjective and "|cff00ff00" or "|cffffcc00") or "",
                                    count = trackerObjective,
                                },
                                oldTrackerCount = oldTrackerCount,
                                newTrackerCount = newTrackerCount,
                                trackerDifference = {
                                    sign = trackerDifference > 0 and "+" or trackerDifference < 0 and "",
                                    color =  trackerDifference > 0 and "|cff00ff00" or trackerDifference < 0 and "|cffff0000",
                                    count = trackerDifference,
                                },
                            }

                            local trackerType, trackerID = self:ParseTrackerKey(trackerKey)

                            if trackerType == "ITEM" then
                                self.CacheItem(trackerID, function(itemID, alert, alertInfo, soundID)
                                    alertInfo.trackerTitle = (GetItemInfo(itemID))
                                    addon:SendAlert("tracker", alert, alertInfo, soundID)
                                end, trackerID, alert, alertInfo, soundID)
                            else
                                alertInfo.trackerTitle = C_CurrencyInfo.GetCurrencyInfo(trackerID).name
                                self:SendAlert("tracker", alert, alertInfo, soundID)
                            end
                        end
                    end
                end
            end
        end
    end
end


function addon:GetDataStoreItemCount(itemID, includeBank)
    if #self:IsDataStoreLoaded() > 0 then return end -- Missing dependencies

    local count = 0
    for k, character in pairs(DataStore:GetCharacters(GetRealmName(), "Default")) do
        local bags, bank = DataStore:GetContainerItemCount(character, itemID)
        local mail = DataStore:GetMailItemCount(character, itemID) or 0
        local auction = DataStore:GetAuctionHouseItemCount(character, itemID) or 0
        local inventory = DataStore:GetInventoryItemCount(character, itemID) or 0

        count = count + bags + (includeBank and bank or 0) + mail + auction + inventory
    end

    return count
end

function addon:GetObjectiveCount(widget, objectiveTitle)
    local buttonDB = widget:GetButtonDB()
    local trackers = {}

    local count = 0
    if buttonDB.condition == "ANY" then
        for trackerKey, _ in pairs(buttonDB.trackers) do
            trackerCount = self:GetTrackerCount(widget, trackerKey)
            count = count + trackerCount
            trackers[trackerKey] = self:GetTrackerCount(widget, trackerKey, 1)
        end
    elseif buttonDB.condition == "ALL" then
        local pendingCount
        for trackerKey, _ in pairs(buttonDB.trackers) do
            trackerCount = self:GetTrackerCount(widget, trackerKey)
            if not pendingCount then
                pendingCount = trackerCount
            else
                pendingCount = min(pendingCount, trackerCount)
            end
            trackers[trackerKey] = self:GetTrackerCount(widget, trackerKey, 1)
        end
        count = count + (pendingCount or 0)
    elseif buttonDB.condition == "CUSTOM" then
        -- Custom conditions should be a table with nested tables inside
        -- Each nested table is an objectiveGroup which will be evaluated like an objective with an ALL condition
        -- The first nested tables will use item counts before following tables; this means the order matters!
        -- E.g. if you want to make as many of your least material required, put that first and then any remaining mats can go toward the following table
        -- Nested tables should be key value pairs where key is in the format t%d, where %d is the tracker number, and value is the required count
        -- Alternatively, keys may be an equivalency in the format %dt%d:%dt%d, such that, for example, 10t1:1t2 represents the equivalency between 10 of tracker 1 and 1 of tracker 2
        -- return {
        --     {
        --         t1 = 1,
        --         ["1t2:1t6"] = 5,
        --         t3 = 5,
        --         t4 = 5,
        --         t5 = 5,
        --     }
        -- }

        -- Distribute equivalency evenly among multiple trackers:
        -- return {
        --     {
        --         t1 = 1,
        --         ["(10t2, 10t3, 10t4, 10t5):1t6"] = 5,
        --     }
        -- }

        -- Distribute equivalency evenly among multiple trackers:
        -- return {
        --     {
        --         t1 = 1,
        --         ["(10t2, 10t3, 10t4, 10t5):1t6"] = 5,
        --     }
        -- }

        -- Usage example: 1 Blood of Sargeras is equal to 10 Dreamleaf, Fjarnskaggl, Foxflower, or Aethril
        -- To
        -- Objective saved in trackerInfo will not be used in custom conditions

        -- Validate custom condition
        local customCondition = self:ValidateCustomCondition(buttonDB.conditionInfo)
        if customCondition and customCondition ~= "" then
            local countsUsed = {} -- Keeps track of items already counted toward the objective

            for key, objectiveGroup in pairs(customCondition) do
                local pendingCount -- Count to be added to running total

                for trackerKey, overrideObjective in self.pairs(objectiveGroup) do
                    local ratio1, key1, ratio2, key2 = strmatch(trackerKey, "^(%d+)t(%d+):(%d+)t(%d+)$")
                    key1 = self:GetTrackerKey(widget, tonumber(key1) or tonumber(strmatch(trackerKey, "^t(%d+)$")))

                    -- Get the count for key1, which is the initial tracker
                    local trackerCount = self:GetTrackerCount(widget, key1, overrideObjective)
                    trackers[key1] = self:GetTrackerCount(widget, key1, 1)

                    -- Track in countsUsed so we don't double dip:
                    -- Get the current count, if it exists
                    local used = countsUsed[key1]
                    -- If it does exist, subtract the amount already used
                    if used then
                        trackerCount = ((trackerCount * overrideObjective) - used) / overrideObjective
                        trackerCount = trackerCount > 0 and trackerCount or 0
                    end

                    -- Check if there's an equivalence set and if so, get the additional counts
                    local equivPending = 0
                    if ratio1 then
                        key2 = self:GetTrackerKey(widget, tonumber(key2))
                        -- Get the count for key2
                        local key2Count = self:GetTrackerCount(widget, key2)
                        trackers[key2] = self:GetTrackerCount(widget, key2, 1)

                        -- Track in countsUsed so we don't double dip:
                        -- Get the current count, if it exists
                        local used = countsUsed[key2]
                        -- If it does exist, subtract the amount already used
                        if used then
                            key2Count = key2Count - used
                            key2Count = key2Count > 0 and key2Count or 0
                        end

                        -- Get the scaled amount
                        local key1Count = key2Count  * (ratio1 / ratio2)

                        -- Find out how many can go toward key
                        equivPending = key1Count / overrideObjective

                        countsUsed[key2] = (used or 0) + key2Count
                    end

                    -- Add count to the pendingCount
                    if not pendingCount then
                        pendingCount = trackerCount + equivPending
                    else
                        pendingCount = min(pendingCount, trackerCount + equivPending)
                    end

                    -- Add the counts we just used to the countsUsed table
                    countsUsed[key1] = (used or 0) + (pendingCount * overrideObjective)
                end
                count = count + (pendingCount or 0)
            end
        end
    end

    return count > 0 and count or 0, trackers
end


function addon:GetTrackerCount(widget, trackerKey, overrideObjective)
    local trackerType, trackerID = self:ParseTrackerKey(trackerKey)
    local trackerInfo = widget:GetButtonDB().trackers[trackerKey]
    local count

    if trackerType == "ITEM" then
        count = trackerInfo.includeAllChars and self:GetDataStoreItemCount(trackerID, trackerInfo.includeBank) or GetItemCount(trackerID, trackerInfo.includeBank)
    elseif trackerType == "CURRENCY" then
        count = C_CurrencyInfo.GetCurrencyInfo(trackerID) and C_CurrencyInfo.GetCurrencyInfo(trackerID).quantity
    end

    if not count then
        return 0
    end

    -- if #trackerInfo.exclude > 0 then
    --     for _, eObjectiveTitle in pairs(trackerInfo.exclude) do
    --         local eObjectiveInfo = self:GetObjectiveInfo(eObjectiveTitle)
    --         local eObjective, eObjectiveButton = self:GetMaxTrackerObjective(eObjectiveTitle)

    --         -- Only exclude if an objective is set (otherwise, how do we know how many to exclude?)
    --         if eObjective then
    --             for _, eTrackerInfo in pairs(eObjectiveInfo.trackers) do
    --                 if eTrackerInfo.trackerID == trackerInfo.trackerID then
    --                     -- Get the max amount used for the objective: either the objective itself or the count
    --                     local maxCount = min(self:GetObjectiveCount(eObjectiveButton, eObjectiveTitle), eObjective)
    --                     -- The number of of this tracker required for the objective is the tracker objective x max
    --                     count = count - maxCount
    --                 end
    --             end
    --         end
    --     end
    -- end

    count = floor(count / (overrideObjective or trackerInfo.objective or 1))

    -- -- If objective is excluded, get max objective
    -- -- If count > max objective while excluded, return max objective
    -- -- Surplus above objective goes toward the objective excluding this one
    -- -- Ex: if A has an objective of 20 and a count of 25 and B excludes A, A will show a count of 20 with objective complete and B will show a count of 5
    local objective
    -- for _, eObjectiveInfo in pairs(self:GetDBValue("global", "objectives")) do
    --     for _, eTrackerInfo in pairs(eObjectiveInfo.trackers) do
    --         if self:ObjectiveIsExcluded(eTrackerInfo.exclude, objectiveTitle) then
    --             objective = self:GetMaxTrackerObjective(objectiveTitle)
    --             break
    --         end
    --     end
    -- end

    count = (count > 0 and count or 0) * (trackerInfo.countsFor or 1)

    return objective and min(count, objective) or count
end

--*------------------------------------------------------------------------
-- Validation


local missing = {}
function addon:IsDataStoreLoaded()
    wipe(missing)

    if not IsAddOnLoaded("DataStore") then
        tinsert(missing, "DataStore")
    end

    if not IsAddOnLoaded("DataStore_Auctions") then
        tinsert(missing, "DataStore_Auctions")
    end

    if not IsAddOnLoaded("DataStore_Containers") then
        tinsert(missing, "DataStore_Containers")
    end

    if not IsAddOnLoaded("DataStore_Characters") then
        tinsert(missing, "DataStore_Characters")
    end

    --@retail@
    -- if not IsAddOnLoaded("DataStore_Currencies") then
    --     tinsert(missing, "DataStore_Currencies")
    -- end
    --@end-retail@

    if not IsAddOnLoaded("DataStore_Inventory") then
        tinsert(missing, "DataStore_Inventory")
    end

    if not IsAddOnLoaded("DataStore_Mails") then
        tinsert(missing, "DataStore_Mails")
    end

    return missing
end


function addon:ValidateCustomCondition(condition)
    -- return {{t1 = 10, t2 = 2, t3 = 3}, {t1 = 5}}
    -- return {{t1 = 10, ["10t1:1t2"] = 2, t3 = 3}, {t1 = 5}}

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
                local equivKey = strmatch(trackerID, "^(%d+)t(%d+):(%d+)t(%d+)$")

                if not equivKey and not tonumber(strmatch(trackerID, "^t(%d+)$")) then
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