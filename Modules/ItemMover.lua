local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)

function private:MoveObjectiveToBank(widget)
    -- local _, buttonDB = widget:GetDB()
    -- if not buttonDB.objective then
    --     return
    -- end

    -- local slots = {}
    -- local pending = 0
    -- for trackerKey, tracker in pairs(buttonDB.trackers) do
    --     local objective = private:GetTrackerObjectiveCount(widget, trackerKey)
    --     if tracker.type == "ITEM" and GetItemCount(tracker.id) > 0 then
    --         for bag = 0, NUM_BAG_SLOTS do
    --             for slot = 1, GetContainerNumSlots(bag) do
    --                 if GetContainerItemID(bag, slot) == tracker.id then
    --                     local _, count = GetContainerItemInfo(bag, slot)
    --                     if pending < objective then
    --                         if count < objective then
    --                             print("Get partial")
    --                             SplitContainerItem(bag, slot, count)
    --                             pending = pending + count
    --                         elseif count > objective then
    --                             SplitContainerItem(bag, slot, objective - pending)
    --                         else
    --                             print("get all")
    --                             PickupContainerItem(bag, slot)
    --                         end
    --                         break
    --                     end
    --                 end
    --             end
    --         end
    --     end
    -- end
end
