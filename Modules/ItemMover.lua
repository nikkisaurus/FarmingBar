local addonName = ...
local U = LibStub("LibAddonUtils-1.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)
local addon = LibStub("AceAddon-3.0"):GetAddon(L.addonName)

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function addon:MoveItem(...)
    local containers, button, buttonItemID, buttonObjective, hasMoreItems, toBank = ...

    if not containers then
        -- Not sure where this is being called without any arguments, but in any case, we need to exit to avoid errors
        self.CoroutineUpdater:StopMoving()
        return
    end

    -- If hasMoreItems, countInBags needs to check the objective count, not individual item count
    local countInBags = (hasMoreItems and hasMoreItems == "mixed") and button:GetCount(false) or GetItemCount(buttonItemID)
    -- countInBank always needs to check individual item count
    local countInBank = GetItemCount(buttonItemID, true) - GetItemCount(buttonItemID)
    -- countToMove is either all items or only enough to meet objective
    local countToMove = buttonObjective and (buttonObjective - countInBags) or (toBank and countInBags or countInBank)
    -- Need to adjust countToMove if it's based off a mixed items objective
    countToMove = (not toBank and countToMove > countInBank) and countInBank or countToMove

    -- Check if the item is a reagent by scanning the tooltip and looking for "Crafting Reagent"
    local isReagent
    for i = 1, GameTooltip:NumLines() do
        if _G[GameTooltip:GetName() .. "TextLeft" .. i]:GetText() == PROFESSIONS_USED_IN_COOKING  or _G[GameTooltip:GetName() .. "TextRight" .. i]:GetText() == PROFESSIONS_USED_IN_COOKING  then
            isReagent = true
            break
        end
    end

    --@retail@
    isReagent = IsReagentBankUnlocked() and isReagent or false
    --@end-retail@

    local stackSize = tonumber((select(8, GetItemInfo(buttonItemID))))
    -- Number of full stacks there should be in the bank if clean
    local numFullStacksInBank = math.floor(countInBank / stackSize)
    -- Number of total stacks there should be in the bank if clean
    local numStacksInBank = math.ceil(countInBank / stackSize)
    -- Actual number of full stacks in the bank (to help determine if we need to clean)
    local numFullStacks = 0

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- Finding items in bank

    local bankSlots = {}
    local counter = 0 -- Using this to keep indexes in order when sorting bankSlots

    for _, containerID in pairs(containers) do
        --@retail@
        -- I don't think there's actually an ignore bags feature in Classic, yet a bag seems to be flagged
        -- So I'm just gonna strip this from Classic
        if not GetBagSlotFlag(containerID, LE_BAG_FILTER_FLAG_IGNORE_CLEANUP) then -- Ignoring bags flagged to ignore clenaups
        --@end-retail@
            for slotID = 1, GetContainerNumSlots(containerID) do
                local _, itemCount, locked, _, _, _, _, _, _, itemID = GetContainerItemInfo(containerID, slotID)

                if not locked and itemID and itemID == buttonItemID then
                    if countToMove >= countInBank then
                        -- We need to move everything, so we go ahead and do that instead of adding it to the table.
                        UseContainerItem(containerID, slotID, nil, isReagent)
                    else
                        -- Add the slot to the table so we can clean it up and whatnot
                        if itemCount == stackSize then
                            numFullStacks = numFullStacks + 1
                        end
                        counter = counter + 1
                        bankSlots[counter] = {containerID, slotID, itemCount}
                    end
                end
            end
        --@retail@
        end
        --@end-retail@
    end

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    if countToMove >= countInBank then

        -- We withdrew everything because we didn't have enought o hit objective
        -- We can return now
        if not hasMoreItems then
            self.CoroutineUpdater:StopMoving()
        elseif hasMoreItems == "mixed" then
            self.resumeMoveItems = true
        elseif hasMoreItems == "shopping" then
            self.resumeShoppingList = true
        end

        return countToMove

    elseif numFullStacks ~= numFullStacksInBank or #bankSlots ~= numStacksInBank then

        -- Stacks are split up and not completely combined in bank
        -- Clean up the bank so we can withdraw full stacks without the split error
        self.StackBankItemsCo = coroutine.create(self.StackBankItems)
        coroutine.resume(self.StackBankItemsCo, self, bankSlots, stackSize, containers, button, buttonItemID, buttonObjective)

    else

        -- We have to withdraw a partial amount, but we're first going to try to get as many full stacks as possible
        local withdrawn = 0
        while countToMove > stackSize do
            for k, v in pairs(bankSlots) do
                if v[3] == stackSize and countToMove > v[3] then
                    countToMove = countToMove - v[3]
                    withdrawn = withdrawn + v[3]

                    UseContainerItem(v[1], v[2])
                    tremove(bankSlots, k)
                end
            end

            -- If we only needed complete stacks to hit countToMove, we can return here
            if countToMove == 0 then

                if not hasMoreItems then
                    self.CoroutineUpdater:StopMoving()
                elseif hasMoreItems == "mixed" then
                    self.resumeMoveItems = true
                elseif hasMoreItems == "shopping" then
                    self.resumeShoppingList = true
                end

                return withdrawn
            end
        end

        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- Withdrawing the partial stack

        -- Delay to make sure that all of the full stacks are done withdrawing, otherwise counts will be off
        C_Timer.After(self.moveDelay, function()
            -- Check if there's a partial in the bag
            -- If not, we can skip all this weird stuff and just split the stack
            local bagHasPartial = math.fmod(GetItemCount(buttonItemID), stackSize) > 0 and true

            if bagHasPartial then
                -- Make sure there's a free slot to do this hack
                local freeSlots = 0
                for _, containerID in pairs(containers) do
                    if isReagent and containerID == -3 then
                        freeSlots = GetContainerNumFreeSlots(containerID)
                        break
                    elseif not isReagent then
                        freeSlots = freeSlots + GetContainerNumFreeSlots(containerID)
                    end
                end

                -- If there isn't a free slot, we're just going to attempt to split the item anyway
                if freeSlots == 0 then
                    -- We don't need to return anything since SplitItem will return the count instead
                    self:SplitItem(bankSlots, countToMove, button, buttonItemID, buttonObjective, hasMoreItems)
                    return
                end

                -- Find the partial stack and deposit it into the bank
                for bagContainerID = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
                    for bagSlotID = 1, GetContainerNumSlots(bagContainerID) do
                        local _, itemCount, locked, _, _, _, _, _, _, itemID = GetContainerItemInfo(bagContainerID, bagSlotID)

                        if not locked and itemID and itemID == buttonItemID and itemCount < stackSize then
                            UseContainerItem(bagContainerID, bagSlotID, nil, isReagent)

                            -- Delay to make sure the item is deposited, then we're going to call the function again to withdraw what we need
                            -- We're calling this again instead of splitting in case we need to restack the items within the bank
                            C_Timer.After(self.moveDelay, function(...)
                                self:MoveItem(...)
                            end)
                        end
                    end
                end
            else
                -- The bag doesn't have a partial, so go ahead and split the bank item
                self:SplitItem(bankSlots, countToMove, button, buttonItemID, buttonObjective, hasMoreItems)
            end
        end)

    end
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function addon:MoveItems(...)
    local _, button, _, _ = ...

    -- For multiple items, we need a coroutine to make sure we have enough time to get the updated objective counts before moving to the next item
    if button.objective.type == "mixedItems" then
        self.MoveMixedItemsCo = coroutine.create(self.MoveMixedItems)
        coroutine.resume(self.MoveMixedItemsCo, self, ...)
    elseif button.objective.type == "shoppingList" then
        self.MoveShoppingListCo = coroutine.create(self.MoveShoppingList)
        coroutine.resume(self.MoveShoppingListCo, self, ...)
    end
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function addon:MoveMixedItems(containers, button, moveToObjective)
    local objective = button.objective.objective
    local numItemsMoved = 0

    for k, itemID in pairs(button.objective.items) do
        if not moveToObjective or button:GetCount(false) ~= objective then
            if moveToObjective then
                -- Adjust the objective based on how many we've withdrawn so far
                objective = objective - numItemsMoved
            end

            numItemsMoved = self:MoveItem(containers, button, itemID, moveToObjective and objective, k < U.tcount(button.objective.items) and "mixed")

            -- Pause to give enough time to move the item before moving on, so we have the correct objective count
            coroutine.yield()
        end
    end

    -- We won't call StopMoving at each item for MixedItems, so we need to call it here
    self.CoroutineUpdater:StopMoving()
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function addon:MoveShoppingList(containers, button, moveToObjective, moveToBank)

        -- Using a counter since the table has named keys
        local counter = 0
        local numItemsMoved = 0

        for itemID, objective in pairs(button.objective.items) do
            counter = counter + 1

            if not moveToObjective or GetItemCount(itemID) ~= objective then
                local itemsMoved = self:MoveItem(containers, button, itemID, moveToObjective and objective, counter < U.tcount(button.objective.items) and "shopping")

                numItemsMoved = (itemsMoved and itemsMoved > 0) and (numItemsMoved + 1) or numItemsMoved

                coroutine.yield()
            end
        end

        -- If no items get moved, well never get a MoveComplete message; numItemsMoved tracks how many items get moved so we can complete the move here instead
        if not moveToBank and numItemsMoved == 0 then
            self.CoroutineUpdater:StopMoving()
        end

end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function addon:SplitItem(bankSlots, countToMove, button, buttonItemID, buttonObjective, hasMoreItems)
    -- Find a stack that we can split
    for k, v in pairs(bankSlots) do
        if v[3] >= countToMove then
            SplitContainerItem(v[1], v[2], countToMove)
            break
        end
    end

    -- Find a bag with a free slot to move to and move the item
    for i = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
        if GetContainerNumFreeSlots(i) > 0 then
            if i == BACKPACK_CONTAINER then
                PutItemInBackpack()
            else
                PutItemInBag(i + 19)
            end
        end
    end

    -- Checking to make sure the move was successful and throwing an error if not
    -- Again, at this point, I'm over trying to figure out what's going on and they can just try again
    C_Timer.After(self.moveDelay * 2, function()
        if ((hasMoreItems and hasMoreItems == "mixed") and button:GetCount(false) or GetItemCount(buttonItemID)) < buttonObjective then
            -- The move failed, so we need to complete with an error
            U.CacheItem(buttonItemID, function(buttonItemID)
                self.CoroutineUpdater:StopMoving(L._ItemMover("itemMoveFailed", (GetItemInfo(buttonItemID))))
            end, buttonItemID)
        elseif not hasMoreItems or (hasMoreItems == "mixed" and countToMove == buttonObjective) then
            -- The extra check makes sure we don't move on to next item and withdraw more than needed if we met the objective already
            self.CoroutineUpdater:StopMoving()
        elseif hasMoreItems == "mixed" then
            self.resumeMoveItems = true
        elseif hasMoreItems == "shopping" then
            self.resumeShoppingList = true
        end

        return countToMove
    end)
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function addon:StackBankItems(bankSlots, stackSize, ...)
    local keysToRemove = {}

    for k, v in pairs(bankSlots) do
        if v[3] > 0 and v[3] < stackSize and k < #bankSlots then

            for key, value in pairs(bankSlots) do
                if key > k and v[3] < stackSize and value[3] < stackSize then
                    local oldValueCount = value[3]
                    local oldVCount = v[3]

                    value[3] = oldValueCount + oldVCount
                    value[3] = (value[3] > stackSize) and (value[3] - stackSize) or 0

                    v[3] = oldVCount + oldValueCount
                    v[3] = (v[3] > stackSize) and stackSize or v[3]

                    PickupContainerItem(value[1], value[2])
                    PickupContainerItem(v[1], v[2])

                    -- Delay to make sure stacks had time to combine
                    C_Timer.After(self.moveDelay, function()
                        self.resumeStackBankItems = true
                    end)
                else
                    self.resumeStackBankItems = true
                end

                if not self.bankOpen then
                    self.CoroutineUpdater:StopMoving(L._ItemMover("bankNotOpen"))
                    return
                end

                coroutine.yield()
            end
        end
    end

    -- Now that the bank is clean, proceed as normal with withdrawing
    self:MoveItem(...)
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --


function addon:CreateCoFrame()
    local coFrame = CreateFrame("Frame", string.format("%sCoroutineUpdater", addonName), UIParent, BackdropTemplateMixin and "BackdropTemplate")
    coFrame:SetSize(350, 100)
    coFrame:SetPoint("CENTER", 0, 350)
    coFrame:Hide()

    coFrame.alert = coFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    coFrame.alert:SetPoint("TOP", 0, -20)
    coFrame.alert:SetWidth(coFrame:GetWidth() - 40, coFrame:GetHeight() - 40)
    coFrame.alert:SetWordWrap(true)
    coFrame.alert:SetText("")

    coFrame.status = coFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    coFrame.status:SetPoint("TOP", coFrame.alert, "BOTTOM", 0, -5)
    coFrame.status:SetWidth(coFrame:GetWidth() - 40, coFrame:GetHeight() - 40)
    coFrame.status:SetWordWrap(true)
    coFrame.status:SetText("")

    self:ApplyFrameSkin(coFrame)

    addon.CoroutineUpdater = coFrame

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    coFrame:SetScript("OnUpdate", function(self, ...)
        -- Continue moving mixed items
        if addon.MoveMixedItemsCo and addon.resumeMoveItems then
            addon.resumeMoveItems = false
            coroutine.resume(addon.MoveMixedItemsCo)
        end

        -- Continue moving shopping list
        if addon.MoveShoppingListCo and addon.resumeShoppingList then
            addon.resumeShoppingList = false
            coroutine.resume(addon.MoveShoppingListCo)
        end

        -- Continue stacking bank items
        if addon.StackBankItemsCo and addon.resumeStackBankItems then
            addon.resumeStackBankItems = false
            coroutine.resume(addon.StackBankItemsCo)
        end
    end)

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    function coFrame:StartMoving(msg)
        self:Show()
        self.status:SetText(msg)
    end

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    function coFrame:StopMoving(error)
        C_Timer.After(addon.moveDelay, function()
            local msg = L._ItemMover(not error and "moveSuccessful" or "moveFailed", error)
            self.status:SetText(msg)

            -- Delay to give user time to read message
            -- Double the time if there's an error
            C_Timer.After(addon.moveDelay * (error and 4 or 2), function()
                self:Hide()
            end)
        end)
    end
end