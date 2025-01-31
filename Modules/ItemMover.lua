local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)

function addon:BAG_UPDATE_DELAYED()
    if private.status.pendingMove == 0 then
        private.status.itemMover = nil
        private.status.pendingMove = nil
    elseif private.status.itemMover then
        private:MoveObjectiveToBank(private.status.itemMover)
    end
end

function private:MoveObjectiveToBank(widget)
    local _, buttonDB = widget:GetDB()
    if not private.status.bankOpen then
        addon:Print(L["Move canceled; please open bank frame."])
        return
    elseif not buttonDB then
        return
    end

    -- Get number of free bank slots
    local freeSlots = GetContainerNumFreeSlots(BANK_CONTAINER)
    for bagID = NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do
        freeSlots = freeSlots + GetContainerNumFreeSlots(bagID)
    end

    -- Loop over trackers
    local stackSlots = {}
    local slots = {}
    for trackerKey, tracker in pairs(buttonDB.trackers) do
        local objective = private:GetTrackerObjectiveCount(widget, trackerKey)
        if tracker.type == "ITEM" and C_Item.GetItemCount(tracker.id) > 0 then
            addon.CacheItem(tracker.id, function(itemID)
                private.status.itemMover = widget
                local _, _, _, _, _, _, _, itemStackCount = GetItemInfo(itemID)
                local itemCount = C_Item.GetItemCount(itemID)

                -- Find bag slots with item
                for bagID = 0, NUM_BAG_SLOTS do
                    for slotID = 1, GetContainerNumSlots(bagID) do
                        if GetContainerItemID(bagID, slotID) == itemID then
                            local _, count = GetContainerItemInfo(bagID, slotID)
                            tinsert(slots, { bagID = bagID, slotID = slotID, count = count })
                            if count < itemStackCount then
                                tinsert(stackSlots, { bagID = bagID, slotID = slotID, count = count })
                            end
                        end
                    end
                end

                -- Combine stacks
                if #stackSlots > 1 then
                    for k, slot in pairs(stackSlots) do
                        PickupContainerItem(slot.bagID, slot.slotID)
                        if stackSlots[k + 1] then
                            PickupContainerItem(stackSlots[k + 1].bagID, stackSlots[k + 1].slotID)
                            return
                        end
                    end
                end

                wipe(stackSlots)

                -- Find bank slots with item
                for bagID = -1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do
                    if bagID == -1 or bagID > NUM_BAG_SLOTS then
                        for slotID = 1, GetContainerNumSlots(bagID) do
                            if GetContainerItemID(bagID, slotID) == itemID then
                                local _, count = GetContainerItemInfo(bagID, slotID)
                                tinsert(slots, { bagID = bagID, slotID = slotID, count = count })
                                if count < itemStackCount then
                                    tinsert(stackSlots, { bagID = bagID, slotID = slotID, count = count })
                                end
                            end
                        end
                    end
                end

                -- Combine bank stacks
                if #stackSlots > 1 then
                    for k, slot in pairs(stackSlots) do
                        PickupContainerItem(slot.bagID, slot.slotID)
                        if stackSlots[k + 1] then
                            PickupContainerItem(stackSlots[k + 1].bagID, stackSlots[k + 1].slotID)
                            return
                        end
                    end
                end

                local pendingMove = private.status.pendingMove or (buttonDB.objective ~= 0 and min(private:GetTrackerObjectiveCount(widget, trackerKey), itemCount) or itemCount)

                if ceil(pendingMove / itemStackCount) > freeSlots then
                    addon:Print(L["Bank does not have enough slots to move items."])
                    private.status.itemMover = nil
                    return
                elseif pendingMove == 0 then
                    private.status.itemMover = nil
                    return
                end

                -- Move items
                for k, slot in pairs(slots) do
                    if slot.count > pendingMove then
                        private.status.itemMover = nil
                        private.status.pendingMove = nil
                        SplitContainerItem(slot.bagID, slot.slotID, pendingMove)

                        -- Find free bag slot to place item
                        for bagSlot = 1, GetContainerNumSlots(BANK_CONTAINER) do
                            local hasItem = GetContainerItemID(BANK_CONTAINER, bagSlot)
                            if not hasItem then
                                PickupContainerItem(BANK_CONTAINER, bagSlot)
                                return
                            end
                        end

                        for bagID = NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do
                            for bagSlot = 1, GetContainerNumSlots(bagID) do
                                local hasItem = GetContainerItemID(bagID, bagSlot)
                                if not hasItem then
                                    PickupContainerItem(bagID, bagSlot)
                                    return
                                end
                            end
                        end
                    else
                        pendingMove = pendingMove - slot.count
                        private.status.pendingMove = pendingMove
                        UseContainerItem(slot.bagID, slot.slotID)
                        return
                    end
                end
            end)
        end
    end
end
