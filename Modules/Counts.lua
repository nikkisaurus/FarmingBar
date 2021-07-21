local addonName = ...
local addon = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)


--*------------------------------------------------------------------------
-- Counts


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

    local count = 0
    if buttonDB.condition == "ANY" then
        for trackerKey, _ in pairs(buttonDB.trackers) do
            count = count + addon:GetTrackerCount(widget, trackerKey)
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
        local customCondition = addon:ValidateCustomCondition(buttonDB.conditionInfo)
        if customCondition and customCondition ~= "" then
            local countsUsed = {} -- Keeps track of items already counted toward the objective

            for key, objectiveGroup in pairs(customCondition) do
                local pendingCount -- Count to be added to running total

                for trackerKey, overrideObjective in self.pairs(objectiveGroup) do
                    local ratio1, key1, ratio2, key2 = strmatch(trackerKey, "^(%d+)t(%d+):(%d+)t(%d+)$")
                    key1 = self:GetTrackerKey(widget, tonumber(key1) or tonumber(strmatch(trackerKey, "^t(%d+)$")))

                    -- Get the count for key1, which is the initial tracker
                    local trackerCount = addon:GetTrackerCount(widget, key1, overrideObjective)

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
                        local key2Count = addon:GetTrackerCount(widget, key2)

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

    return count > 0 and count or 0
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