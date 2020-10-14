local addonName = ...
local U = LibStub("LibAddonUtils-1.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)
local addon = LibStub("AceAddon-3.0"):GetAddon(L.addonName)
local LSM = LibStub("LibSharedMedia-3.0")

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

addon.directionInfo = {
    [1] = {
        displayText = L["Top"],
        validateText = strupper(L["Up"]),
        button = {
            point = "BOTTOM",
            relativePoint = "TOP",
            x = 0,
            y = 1,
        },
        [1] = {
            point = "LEFT",
            relativePoint = "RIGHT",
            x = 1,
            y = 0,
        },
        [2] = {
            point = "RIGHT",
            relativePoint = "LEFT",
            x = -1,
            y = 0,
        },
    },
    [2] = {
        displayText = L["Right"],
        validateText = strupper(L["Right"]),
        button = {
            point = "LEFT",
            relativePoint = "RIGHT",
            x = 1,
            y = 0,
        },
        [1] = {
            point = "TOP",
            relativePoint = "BOTTOM",
            x = 0,
            y = -1,
        },
        [2] = {
            point = "BOTTOM",
            relativePoint = "TOP",
            x = 0,
            y = 1,
        },
    },
    [3] = {
        displayText = L["Bottom"],
        validateText = strupper(L["Down"]),
        button = {
            point = "TOP",
            relativePoint = "BOTTOM",
            x = 0,
            y = -1,
        },
        [1] = {
            point = "LEFT",
            relativePoint = "RIGHT",
            x = 1,
            y = 0,
        },
        [2] = {
            point = "RIGHT",
            relativePoint = "LEFT",
            x = -1,
            y = 0,
        },
    },
    [4] = {
        displayText = L["Left"],
        validateText = strupper(L["Left"]),
        button = {
            point = "RIGHT",
            relativePoint = "LEFT",
            x = -1,
            y = 0,
        },
        [1] = {
            point = "TOP",
            relativePoint = "BOTTOM",
            x = 0,
            y = -1,
        },
        [2] = {
            point = "BOTTOM",
            relativePoint = "TOP",
            x = 0,
            y = 1,
        },
    },
}


function addon:GetDirection(input, column)
    for k, v in pairs(self.directionInfo) do
        if v.validateText == strupper(input) then
            return (column and k > 2) and (k - 2) or k
        end
    end

    return
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function addon:CreateButton(bar, id)
    local skin = self.skins[self.db.profile.style.skin.name] or self.db.global.skins[self.db.profile.style.skin.name]
    local button = CreateFrame("Button", string.format("$parentButton%d", id), bar, "FarmingBarButtonTemplate")
    bar.buttons[id] = button
    button.id = id

    self:ApplyButtonSkin(button, skin.button)
    button:Update()
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function addon:SetObjectiveID(button, objectiveTable, suppressMsg)
    if not objectiveTable then
        button:SetObjectiveID()
    elseif objectiveTable.type == "item" then
        button:SetObjectiveID(objectiveTable.type, objectiveTable.itemID, {title = objectiveTable.title}, objectiveTable, suppressMsg)
    elseif objectiveTable.type == "currency" then
        button:SetObjectiveID(objectiveTable.type, objectiveTable.currencyID, nil, objectiveTable, suppressMsg)
    elseif objectiveTable.type == "mixedItems" or objectiveTable.type == "shoppingList" then
       button:SetObjectiveID(objectiveTable.type, objectiveTable.items, {title = objectiveTable.title, icon = objectiveTable.icon, objective = objectiveTable.objective}, objectiveTable, suppressMsg)
    end
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function FarmingBarButtonTemplateItemIDEditBox_OnEnterPressed(self, ...)
    local objectiveID = tonumber(self:GetText())

    if not objectiveID or objectiveID == "" then
        self:SetText("")
        self:ClearFocus()
        self:Hide()
        return
    elseif self and self.type == "currency" and not C_CurrencyInfo.GetCurrencyInfo(objectiveID) then
        print(L.GetErrorMessage("invalidCurrency", self:GetText()))

        self:SetText("")
        self:ClearFocus()
        self:Hide()

        return
    elseif self and self.type == "item" and not GetItemInfo(objectiveID) then
        print(L.GetErrorMessage("invalidItemID", objectiveID))

        self:SetText("")
        self:ClearFocus()
        self:Hide()

        return
    end

    self:GetParent():SetObjectiveID(self.type, objectiveID)

    self:SetText("")
    self:ClearFocus()
    self:Hide()
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function FarmingBarButtonTemplateObjectiveEditBox_OnEnterPressed(self, ...)
    self:GetParent():SetObjective(tonumber(self:GetText()))

    self:SetText("")
    self:ClearFocus()
    self:Hide()
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function FarmingBarButtonTemplate_OnDragStart(self, ...)
    if not self.objective or not self.objective.type or self.objective.type ~= "item" then return end
    if IsShiftKeyDown() then
        -- Move item to a new button or pick it up to delete it.
        local itemID = self.objective.type == "item" and self.objective.itemID
        addon.button1 = {
            button = self,
            objectiveTable = self.objective,

        }
        self:SetObjectiveID()

        addon.isDragging = true
        PickupItem(itemID)
    end
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function FarmingBarButtonTemplate_OnEvent(self, event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        -- Watching for cooldown frame
        self:SetCooldown()
    elseif event == "PLAYER_REGEN_ENABLED" then
       -- Assigning an item when initiated in combat.
        local objectiveTable = self:GetBar().db.objectives[self.id]

        self:SetObjectiveID(objectiveTable.type, (objectiveTable.type == "item" and self.objective.itemID) or (objectiveTable.type == "currency" and self.objective.currencyID) or (not objectiveTable.type and nil) or self.objective.items, nil, objectiveTable)

        if not self.suppressCombatEndedMsg then
            addon:Print(L.ButtonAttributesAccessible(self:GetBar().id, self.id))
            -- Attempts to prevent spam.
            self.suppressCombatEndedMsg = true
            C_Timer.After(1, function()
                self.suppressCombatEndedMsg = false
            end)
        end

        self:UnregisterEvent(event)
    end
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function FarmingBarButtonTemplate_OnLoad(self, ...)
    self.FloatingBG:SetDrawLayer("BACKGROUND", 1)
    self.Icon:SetDrawLayer("BACKGROUND", 2)
    self.Flash:SetDrawLayer("BACKGROUND", 3)
    self.Border:SetDrawLayer("BORDER", 1)
    self.AutoCastable:SetDrawLayer("OVERLAY", 2)
    self.Count:SetDrawLayer("OVERLAY", 3)
    self.Objective:SetDrawLayer("OVERLAY", 3)

    self.Cooldown:SetDrawEdge(addon.db.profile.style.layers.CooldownEdge)

    self:RegisterForDrag("LeftButton")
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    self:RegisterEvent("BANKFRAME_OPENED")
    self:RegisterEvent("BANKFRAME_CLOSED")

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    function self:Anchor()
        local directionInfo = addon.directionInfo[tonumber(self:GetBar().db.direction)].button
        local rowInfo = addon.directionInfo[tonumber(self:GetBar().db.direction)][tonumber(self:GetBar().db.rowDirection)]

        self:ClearAllPoints()
        if self.id > self:GetBar().db.buttonsPerRow and mod(self.id - 1, self:GetBar().db.buttonsPerRow) == 0 then
            self:SetPoint(
                rowInfo.point,
                self:GetBar().buttons[self.id - self:GetBar().db.buttonsPerRow],
                rowInfo.relativePoint,
                rowInfo.x * self:GetBar().db.buttonPadding,
                rowInfo.y * self:GetBar().db.buttonPadding
            )
        else
            self:SetPoint(
                directionInfo.point,
                self.id > 1 and self:GetBar().buttons[self.id - 1] or self:GetBar().anchor,
                directionInfo.relativePoint,
                directionInfo.x * self:GetBar().db.buttonPadding,
                directionInfo.y * self:GetBar().db.buttonPadding
            )
        end
    end

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    function self:ApplyFont()
        self.Count:SetFont(LSM:Fetch("font", self:GetBar().db.font.face or addon.db.profile.style.font.face), self:GetBar().db.font.size or addon.db.profile.style.font.size, self:GetBar().db.font.outline or addon.db.profile.style.font.outline)
        self:ColorCountText()
        self.Objective:SetFont(LSM:Fetch("font", self:GetBar().db.font.face or addon.db.profile.style.font.face), self:GetBar().db.font.size or addon.db.profile.style.font.size, self:GetBar().db.font.outline or addon.db.profile.style.font.outline)
    end

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    function self:BAG_UPDATE()
        if not self.objective or not self.objective.type then return end

        if not self:GetBar().db.muteAlerts then
            local objectiveTable = self:GetBar().db.objectives[self.id]
            local objectiveName = (objectiveTable.type == "currency" and (C_CurrencyInfo.GetCurrencyInfo and C_CurrencyInfo.GetCurrencyInfo(objectiveTable.currencyID).name or GetCurrencyInfo(objectiveTable.currencyID))) or (objectiveTable.type == "item" and select(2, GetItemInfo(objectiveTable.itemID))) or objectiveTable.title
            local oldCount, newCount = self.count, self:GetCount()
            local difference = newCount - oldCount
            local alert, soundID, barAlert

            -- If count is different, then update progress
            if oldCount ~= newCount then
                -- If there's an objective, compare it to the objective
                if objectiveTable.objective then
                    if self:GetBar().db.trackCompletedObjectives or (not self:GetBar().db.trackCompletedObjectives and ((oldCount < objectiveTable.objective) or (newCount < oldCount and newCount < objectiveTable.objective))) then
                        alert = addon.db.global.alertFormats.hasObjective

                        if oldCount < objectiveTable.objective and newCount >= objectiveTable.objective then
                            soundID = "objectiveComplete"
                            barAlert = "complete"
                        else
                            soundID = oldCount < newCount and "farmingProgress"
                            -- Have to check if we lost an objective
                            if oldCount >= objectiveTable.objective and newCount < objectiveTable.objective then
                                barAlert = "lost"
                            end
                        end
                    end
                else
                    alert = addon.db.global.alertFormats.noObjective
                    soundID = oldCount < newCount and "farmingProgress"
                end
            end

            local alertInfo = {objectiveTitle = objectiveTable.type == "item" and objectiveTable.title, objective = objectiveTable.objective, objectiveName = objectiveName, oldCount = oldCount, newCount = newCount, difference = difference}

            -- Play alerts
            if addon.db.global.alerts.chat and alert then
                addon:Print(addon:ParseAlert(alert, alertInfo))
            end

            if addon.db.global.alerts.screen and alert then
                if not addon.CoroutineUpdater:IsVisible() then
                    UIErrorsFrame:AddMessage(addon:ParseAlert(alert, alertInfo), 1, 1, 1)
                else
                    addon.CoroutineUpdater.alert:SetText(addon:ParseAlert(alert, alertInfo))
                end
            end

            if addon.db.global.alerts.sound and soundID then
                PlaySoundFile(LSM:Fetch("sound", addon.db.global.sounds[soundID]))
            end

            if barAlert then
                local progressCount, progressTotal = self:GetBar():GetProgress()

                if barAlert == "complete" then
                    progressCount = progressCount - 1
                elseif barAlert == "lost" then
                    progressCount = progressCount + 1
                end

                self:GetBar():AlertProgress(progressCount, progressTotal)
            end
        end

        -- Update button
        self:UpdateCountText()
        self:UpdateAutoCastable()
        self:UpdateObjectiveText()
    end

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    self.BAG_UPDATE_COOLDOWN = self.BAG_UPDATE

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    function self:BANKFRAME_OPENED()
        addon.bankOpen = true
    end

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    function self:BANKFRAME_CLOSED()
        addon.bankOpen = false
    end

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    function self:ColorCountText()
        local objectiveTable = self:GetBar().db.objectives[self.id]
        if not objectiveTable then return end

        if addon.db.profile.style.count.type == "oGlow" and objectiveTable.type == "item" then -- quality color
            U.CacheItem(objectiveTable.itemID, function(self, itemID)
                local r, g, b = GetItemQualityColor(select(3, GetItemInfo(itemID)))
                self.Count:SetTextColor(r, g, b, 1)
            end, self, objectiveTable.itemID)
        elseif addon.db.profile.style.count.type == "includeBank" and objectiveTable.includeBank then -- includeBank: gold
            self.Count:SetTextColor(1, 1, 0, 1)
        else
            self.Count:SetTextColor(U.unpack(addon.db.profile.style.count.color))
        end
    end

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    function self:COMBAT_LOG_EVENT_UNFILTERED()
        -- Watching for cooldown frame
        self:SetCooldown()
    end

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    self.CURRENCY_DISPLAY_UPDATE = self.BAG_UPDATE

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    function self:GetBar()
        return self:GetParent()
    end


    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    function self:GetCount(includeBank)
        local objectiveTable = self:GetBar().db.objectives[self.id]
        local count
        if includeBank == nil then
            includeBank = objectiveTable.includeBank
        end

        if objectiveTable.type == "item" then
            count = GetItemCount(objectiveTable.itemID, includeBank)
        elseif objectiveTable.type == "currency" then
            count = C_CurrencyInfo.GetCurrencyInfo and C_CurrencyInfo.GetCurrencyInfo(objectiveTable.currencyID).quantity or select(2, GetCurrencyInfo(objectiveTable.currencyID))
        elseif objectiveTable.type == "mixedItems" then
            count = 0
            for k, v in pairs(objectiveTable.items) do
                count = count + GetItemCount(v, includeBank)
            end
        elseif objectiveTable.type == "shoppingList" then
            -- Find out how many times the objective has been completed
            -- Need to get the number of times each item's objective has been completed and then find the min amount between those
            local timesComplete = {}
            for k, v in pairs(objectiveTable.items) do
                tinsert(timesComplete, math.floor(GetItemCount(k, includeBank) / v))
            end

            local timesObjectiveCompleted = math.min(unpack(timesComplete))

            -- Get the actual count
            count = 0
            for k, v in pairs(objectiveTable.items) do
                -- maxCount = if objective is completed at least once, v * times completed + 1, because we want the count toward the next goal but don't want to count more than that per item or it can mess up the objective complete; otherwise v
                local maxCount = timesObjectiveCompleted > 0 and (v * (timesObjectiveCompleted + 1)) or v
                local itemCount = GetItemCount(k, includeBank)

                count = count + (itemCount > maxCount and maxCount or itemCount)
            end
        end

        return count
    end

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    function self:PLAYER_REGEN_ENABLED(event)
        -- Assigning an item when initiated in combat.
        local objectiveTable = self:GetBar().db.objectives[self.id]

        self:SetObjectiveID(objectiveTable.type, (objectiveTable.type == "item" and self.objective.itemID) or (objectiveTable.type == "currency" and self.objective.currencyID) or (not objectiveTable.type and nil) or self.objective.items, nil, objectiveTable)

        if not self.suppressCombatEndedMsg then
            addon:Print(L.ButtonAttributesAccessible(self:GetBar().id, self.id))
            -- Attempts to prevent spam.
            self.suppressCombatEndedMsg = true
            C_Timer.After(1, function()
                self.suppressCombatEndedMsg = false
            end)
        end

        self:UnregisterEvent(event)
    end

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    function self:SetCooldown()
        if addon.db.profile.style.layers.Cooldown and self.objective and self.objective.type == "item" then
            local startTime, duration, enable = GetItemCooldown(self.objective.itemID)
            self.Cooldown:SetCooldown(startTime, duration)
            self.Cooldown:GetRegions():SetFontObject(NumberFontNormalSmall)
            self.Cooldown:GetRegions():SetFont(LSM:Fetch("font", self:GetBar().db.font.face or addon.db.profile.style.font.face) or "", (self:GetBar().db.font.size or addon.db.profile.style.font.size) * 1.5, self:GetBar().db.font.outline or addon.db.profile.style.font.outline)
            self.Cooldown:Show()
        else
            self.Cooldown:SetCooldown(0, 0)
            self.Cooldown:Hide()
        end
    end

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    function self:SetObjective(objective)
        local oldObjective = addon.db.char.bars[self:GetBar().id].objectives[self.id].objective
        local progressCount, progressTotal = self:GetBar():GetProgress()

        -- Set objective
        if objective and objective > 0 then
            addon.db.char.bars[self:GetBar().id].objectives[self.id].objective = objective
            if addon.db.global.alerts.sound then
                PlaySoundFile(LSM:Fetch("sound", addon.db.global.sounds.objectiveSet))
            end
        elseif addon.db.char.bars[self:GetBar().id].objectives[self.id].type ~= "mixedItems" then
            addon.db.char.bars[self:GetBar().id].objectives[self.id].objective = false
            if addon.db.global.alerts.sound then
                PlaySoundFile(LSM:Fetch("sound", addon.db.global.sounds.objectiveCleared))
            end
        else
            addon:Print(L.GetErrorMessage("invalidObjectiveQuantity"))
            return
        end

        -- Update objective count and send chat message.
        if self.objective.type == "item" then
            U.CacheItem(self.objective.itemID, function(itemID)
                addon:Print(L.FarmingObjectiveSet(objective, select(1, GetItemInfo(itemID))))
                self:UpdateObjectiveText()
                return
            end, self.objective.itemID)
        elseif self.objective.type == "currency" then
            addon:Print(L.FarmingObjectiveSet(objective, C_CurrencyInfo.GetCurrencyInfo and C_CurrencyInfo.GetCurrencyInfo(self.objective.currencyID).name or select(1, GetCurrencyInfo(self.objective.currencyID))))
        else
            addon:Print(L.FarmingObjectiveSet(objective, self.objective.title))
        end

        self:UpdateObjectiveText()

        -- We don't need to alert for mixed items or shopping lists because they always have objectives
        local noChange = not oldObjective and (not objective or objective == 0)
        noChange = noChange and noChange or (oldObjective and oldObjective == objective)

        if self.objective.type == "mixedItems" or self.objective.type == "shoppingList" or noChange then return end

        self:GetBar():AlertProgress(progressCount, progressTotal, objective and (self:GetCount() >= objective))
    end

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    function self:SetObjectiveID(objectiveType, objectiveID, objectiveFlags, objectiveTable, suppressInCombatMsg)
        ClearCursor()

        -- prevObjectiveCount is a hack to make sure it doesn't keep refreshing the config frame when clearing items, because for some reason the count is 0 every time, despite removing items one at a time
        local prevObjectiveCount = U.tcount(self:GetBar().db.objectives, nil, "type")

        -- Save item to database.
        if objectiveID then
            if objectiveTable then
                addon.db.char.bars[self:GetBar().id].objectives[self.id] = objectiveTable
            else
                addon.db.char.bars[self:GetBar().id].objectives[self.id] = {
                    type = objectiveType,
                }

                if objectiveType == "item" then
                    addon.db.char.bars[self:GetBar().id].objectives[self.id].itemID = objectiveID
                    addon.db.char.bars[self:GetBar().id].objectives[self.id].title = objectiveFlags and objectiveFlags.title or ""
                    addon.db.char.bars[self:GetBar().id].objectives[self.id].includeBank = false
                elseif objectiveType == "currency" then
                    addon.db.char.bars[self:GetBar().id].objectives[self.id].currencyID = objectiveID
                elseif objectiveType == "mixedItems" then
                    addon.db.char.bars[self:GetBar().id].objectives[self.id].items = objectiveID
                    addon.db.char.bars[self:GetBar().id].objectives[self.id].icon = objectiveFlags.icon
                    addon.db.char.bars[self:GetBar().id].objectives[self.id].title = objectiveFlags.title
                    addon.db.char.bars[self:GetBar().id].objectives[self.id].objective = objectiveFlags.objective
                    addon.db.char.bars[self:GetBar().id].objectives[self.id].includeBank = false
                elseif objectiveType == "shoppingList" then
                    addon.db.char.bars[self:GetBar().id].objectives[self.id].items = objectiveID
                    addon.db.char.bars[self:GetBar().id].objectives[self.id].icon = objectiveFlags.icon
                    addon.db.char.bars[self:GetBar().id].objectives[self.id].title = objectiveFlags.title
                    addon.db.char.bars[self:GetBar().id].objectives[self.id].objective = objectiveFlags.objective
                    addon.db.char.bars[self:GetBar().id].objectives[self.id].includeBank = false
                end
            end
        else
            addon.db.char.bars[self:GetBar().id].objectives[self.id] = nil
        end
        self.objective = addon.db.char.bars[self:GetBar().id].objectives[self.id]

        -- Unregister events here since they either need cleared or updated based on which type is being tracked.
        self:UnregisterEvent("BAG_UPDATE")
        self:UnregisterEvent("BAG_UPDATE_COOLDOWN")
        --@retail@
        self:UnregisterEvent("CURRENCY_DISPLAY_UPDATE")
        --@end-retail@

        -- Apply visuals to self
        if not self.objective or not self.objective.type then
            -- Clear old items.
            self.AutoCastable:Hide()
            self.Border:Hide()
            self.Icon:SetTexture()
            self.Count:SetText("")
            self.Objective:SetText("")
        else
            if objectiveType == "item" then
                -- Caching the item to make sure we have all the info.
                U.CacheItem(self.objective.itemID, function(self) self.Icon:SetTexture(select(10, GetItemInfo(self.objective.itemID))) end, self)
            elseif objectiveType == "currency" then
                self.Icon:SetTexture(C_CurrencyInfo.GetCurrencyInfo and C_CurrencyInfo.GetCurrencyInfo(self.objective.currencyID).iconFileID or select(3, GetCurrencyInfo(self.objective.currencyID)))
            else
                self.Icon:SetTexture(self:GetBar().db.objectives[self.id].icon)
            end

            if objectiveType == "currency" then
                --@retail@
                self:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
                --@end-retail@
            else
                self:RegisterEvent("BAG_UPDATE")
                self:RegisterEvent("BAG_UPDATE_COOLDOWN")
            end
        end

        self:UpdateCountText()
        self:UpdateAutoCastable()
        self:UpdateBorder()
        self:UpdateObjectiveText()
        self:SetCooldown()

        -- Check if objective builder is open for this button and reload
        if addon.ObjectiveBuilder:IsVisible() and addon.ObjectiveBuilder.button == self then
            addon.ObjectiveBuilder:Load(self)
        end

        -- Refresh config frame
        if (not objectiveID and prevObjectiveCount ~= 0 and U.tcount(self:GetBar().db.objectives, nil, "type") == 0) or (objectiveID and U.tcount(self:GetBar().db.objectives, nil, "type") == 1) then
            -- Not objectiveID and count 0 means we just cleared the last button and we need to disable some interface buttons
            -- If objectiveID and count 1 means the interface was previously disabled
            addon:Refresh()
        end

        -- Set button attributes.
        if UnitAffectingCombat("player") and (self:GetAttribute("item") or objectiveType == "item") then
            -- Warn users about changing items during combat.
            if not suppressInCombatMsg then
                addon:Print(L.CombatWarning)
            end
            self:RegisterEvent("PLAYER_REGEN_ENABLED")
        elseif objectiveID and objectiveType == "item" then
            self:SetAttribute("type2", "item")
            self:SetAttribute("item", "item:" .. objectiveID)
        elseif self:GetAttribute("item") then
            self:SetAttribute("type", nil)
            self:SetAttribute("item", nil)
        end
    end

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    function self:SetVisible()
        if self.id > self:GetBar().db.visibleButtons then
            self:Hide()
        else
            self:Show()
        end

        self:GetBar():UpdateQuickButtons()
    end

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    function self:Size()
        local bar = self:GetBar()

        self:SetSize(bar.db.buttonSize, bar.db.buttonSize)

        self.Count:ClearAllPoints()
        self.Count:SetSize(0, 0)

        self.Count:SetPoint(bar.db.count.anchor, self, bar.db.count.anchor, bar.db.count.xOffset, bar.db.count.yOffset)
        self.Count:SetJustifyH((bar.db.count.anchor:find("RIGHT") and "RIGHT") or (bar.db.count.anchor:find("LEFT") and "LEFT") or "CENTER")

        self.Objective:ClearAllPoints()
        self.Objective:SetSize(0, 0)

        self.Objective:SetPoint(bar.db.objective.anchor, self, bar.db.objective.anchor, bar.db.objective.xOffset, bar.db.objective.yOffset)
        self.Objective:SetJustifyH((bar.db.objective.anchor:find("RIGHT") and "RIGHT") or (bar.db.objective.anchor:find("LEFT") and "LEFT") or "CENTER")
    end

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    function self:Update()
        self:Anchor()
        self:Size()
        self:SetVisible()
        self:ApplyFont()
        self:UpdateObjectiveText()
        self:SetCooldown()
    end

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    function self:UpdateAutoCastable()
        local objectiveTable = self:GetBar().db.objectives[self.id]

        if addon.db.profile.style.layers.AutoCastable then
            if not objectiveTable or not objectiveTable.includeBank then
                self.AutoCastable:Hide()
            else
                self.AutoCastable:Show()
            end
        else
            self.AutoCastable:Hide()
        end
    end

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    function self:UpdateBorder()
        local objectiveTable = self:GetBar().db.objectives[self.id]
        if not objectiveTable or objectiveTable.type ~= "item" then return end

        if addon.db.profile.style.layers.Border then
            U.CacheItem(objectiveTable.itemID, function(self, itemID)
                local itemQuality = (select(3, GetItemInfo(itemID)))
                local r, g, b = GetItemQualityColor(itemQuality)
                self.Border:SetVertexColor(r, g, b, 1)

                if itemQuality > 1 then
                    self.Border:Show()
                end
            end, self, objectiveTable.itemID)
        else
            self.Border:Hide()
        end
    end

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    function self:UpdateCountText()
        local objectiveTable = self:GetBar().db.objectives[self.id]
        if not objectiveTable then return end

        self.Count:SetText(U.iformat(self:GetCount(), 1))
        self.count = self:GetCount()
        self:ColorCountText()
    end

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    function self:UpdateObjectiveText()
        local objectiveTable = self:GetBar().db.objectives[self.id]

        if objectiveTable.objective then
            local formattedObjective, objective = U.iformat(objectiveTable.objective, 2)
            self.Objective:SetText(formattedObjective)

            -- Update objective color if objective is complete
            if self:GetCount() and self:GetCount() >= objective then
                self.Objective:SetTextColor(0, 1, 0, 1)
                if math.floor(self:GetCount() / objective) > 1 then
                    self.Objective:SetText(formattedObjective .. "*")
                end
            else
                self.Objective:SetTextColor(1, .82, 0, 1)
            end
        else
            self.Objective:SetText("")
        end
    end
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function FarmingBarButtonTemplate_OnReceiveDrag(self)
    if addon.button1 then
        -- We're moving buttons and need to switch.
        addon.button2 = {
            button = self,
            objectiveTable = (self.objective and self.objective.type) and self.objective,
        }


        addon:SetObjectiveID(addon.button1.button, addon.button2.objectiveTable, true)
        addon:SetObjectiveID(addon.button2.button, addon.button1.objectiveTable)

        addon.button1 = nil
        addon.button2 = nil
        addon.isDragging = nil
    else
        -- Assign button from cursor drop.
        local cursorType, cursorID = GetCursorInfo()
        if cursorType == "item" then
            self:SetObjectiveID("item", cursorID)
        end
    end
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function FarmingBarButtonTemplate_OnUpdate(self, ...)
    if addon.isDragging and not addon.button2 and not GetCursorInfo() then
        addon.button1 = nil
        addon.button2 = nil
        addon.isDragging = nil
    end

    if not self:GetBar().db.showEmpties and (not self.objective or not self.objective.type) then
        self:SetAlpha((GetCursorInfo() == "item" or addon.button1) and self:GetBar().db.alpha or 0)
    else
        self:SetAlpha(self:GetBar().db.alpha)
    end
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function FarmingBarButtonTemplate_PostClick(self, mouseButton, ...)
    local cursorType, cursorID = GetCursorInfo()

    if not addon.button1 and cursorType == "item" then
        -- Assign cursor item to the button
        self:SetObjectiveID("item", cursorID, {title = false})
    elseif mouseButton == "RightButton" then
        if IsAltKeyDown() then
            if not addon.bankOpen or not self.objective or not self.objective.type or self.objective.type == "currency" then return end

            if self.objective.type == "item" then
                U.CacheItem(self.objective.itemID, function(itemID)
                    addon.CoroutineUpdater:StartMoving(L._ItemMover("moveStarted", "item", (GetItemInfo(itemID))))
                end, self.objective.itemID)

                if IsShiftKeyDown() then
                    addon:MoveItem(addon.bagIDs, self, self.objective.itemID, nil, nil, true)
                elseif IsControlKeyDown() or not self.objective.objective then
                    addon:MoveItem(addon.bankIDs, self, self.objective.itemID)
                elseif self.objective.objective and GetItemCount(self.objective.itemID) < self.objective.objective then
                    addon:MoveItem(addon.bankIDs, self, self.objective.itemID, self.objective.objective)
                else
                    addon.CoroutineUpdater:StopMoving()
                end
            else
                addon.CoroutineUpdater:StartMoving(L._ItemMover("moveStarted", "items", self.objective.title))

                if IsShiftKeyDown() then
                    -- Move all items from bags to bank
                    addon:MoveItems(addon.bagIDs, self, nil, true)
                elseif IsControlKeyDown() or not self.objective.objective then
                    -- Move all items from bank to bags
                    addon:MoveItems(addon.bankIDs, self)
                else
                    -- Move only enough items from bank to bags to meet objective
                    addon:MoveItems(addon.bankIDs, self, true)
                end
            end
        elseif IsControlKeyDown() and IsShiftKeyDown() then
            -- Quick add item
            self.ItemIDEditBox.type = "item"
            self.ItemIDEditBox:Show()
        elseif IsShiftKeyDown() then
            if not self.objective or not self.objective.type then return end
            -- Clear item off the button
            self:SetObjectiveID()
        elseif IsControlKeyDown() then
            -- Show objective builder frame
            addon.ObjectiveBuilder:Load(self)
        elseif self.objective and self.objective.type then
            if self.objective.type ~= "item" then return end
            -- Using item
            if GetItemSpell(self.objective.itemID) then
                if not GetCVar("autoLootDefault") and true and GetNumLootItems() > 0 then -- change true to db setting
                    for i = 1, GetNumLootItems() do
                        LootSlot(i)
                    end
                end

                U.CacheItem(self.objective.itemID, function(objectiveID)
                    if self:GetAttribute("item") == string.format("item:%d", objectiveID) then
                        addon:Print(L.UsingItem(objectiveID))
                    end
                end, self.objective.itemID)
            end
        end
    elseif mouseButton == "LeftButton" then
        if IsAltKeyDown() then
            if not self.objective or not self.objective.type or self.objective.type == "currency" then return end
            local progressCount, progressTotal = self:GetBar():GetProgress()
            local objective = self.objective.objective
            local oldCount = self:GetCount()

            -- Toggle bank inclusion
            addon:SetDBValue("char.bars.objectives", "includeBank", "_toggle", self:GetBar().id, self.id)

            self:UpdateCountText()
            self:UpdateAutoCastable()
            self:UpdateObjectiveText()

            addon:Print(L.IncludeBankChanged(self:GetBar().id, self.id, addon:GetDBValue("char.bars.objectives", "includeBank", self:GetBar().id, self.id)))

            -- Check if objective has changed and update bar progress
            self:GetBar():AlertProgress(progressCount, progressTotal, objective and (oldCount >= objective))
        --@retail@
        elseif IsControlKeyDown() and IsShiftKeyDown() then
            -- Quick add currency
            self.ItemIDEditBox.type = "currency"
            self.ItemIDEditBox:Show()

        --@end-retail@
        elseif IsControlKeyDown() then
            if not self.objective or not self.objective.type then
                return
            elseif self.objective.type == "shoppingList" then
                addon.ObjectiveBuilder:Load(self)
                return
            end
            -- Show ObjectiveEditBox to set a objective goal
            self.ObjectiveEditBox:Show()
        elseif not IsShiftKeyDown() then
            -- Move the item to another button
            if self.objective and self.objective.type and not addon.button1 then
                addon.button1 = {
                    button = self,
                    objectiveTable = (self.objective and self.objective.type) and self.objective,
                }

                self.Flash:Show()
                UIFrameFlash(self.Flash, 0.5, 0.5, -1)
            elseif addon.button1 then
                addon.button2 = {
                    button = self,
                    objectiveTable = (self.objective and self.objective.type) and self.objective,
                }

                UIFrameFlashStop(addon.button1.button.Flash)
                addon.button1.button.Flash:Hide()

                addon:SetObjectiveID(addon.button1.button, addon.button2.objectiveTable, true)
                addon:SetObjectiveID(addon.button2.button, addon.button1.objectiveTable)

                addon.button1 = nil
                addon.button2 = nil
            end
        end
    end
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function FarmingBarButtonTemplate_PreClick(self, mouseButton, ...)
    local cursorType, cursorID = GetCursorInfo()
    if not UnitAffectingCombat("player") and (cursorID and cursorID ~= self.itemID) then
        self:SetAttribute("type", nil)
    end

    -- Enable auto loot
    if self:GetAttribute("item") and addon.db.global.autoLootItems then
        local autoLootDefault = GetCVar("autoLootDefault")
        SetCVar("autoLootDefault", 1)
        C_Timer.After(0.5, function()
            SetCVar("autoLootDefault", autoLootDefault)
        end)
    end
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function addon:ParseAlert(alert, alertInfo)
    local objectiveReps = alertInfo.objective and math.floor(alertInfo.newCount / alertInfo.objective) or ""
    local percent = alertInfo.objective and (math.floor((alertInfo.newCount / alertInfo.objective) * 100)) or ""
    local remainder =  alertInfo.objective and (alertInfo.objective - alertInfo.newCount) or ""

    local diffColor = alertInfo.difference > 0 and "|cff00ff00" or "|cffff0000"
    local progressColor = alertInfo.objective and (alertInfo.newCount >= alertInfo.objective and "|cff00ff00" or "|cffffcc00") or ""

    -- Replaces placeholders with data: colors come first so things like %c, %d, and %p don't get changed before colors can be evaluated
    alert = alert:gsub("%%color%%", "|r"):gsub("%%diffColor%%", diffColor):gsub("%%progressColor%%", progressColor):gsub("%%c", alertInfo.newCount):gsub("%%C", alertInfo.oldCount):gsub("%%d", (alertInfo.difference > 0 and "+" or "") .. alertInfo.difference):gsub("%%n", alertInfo.objectiveName):gsub("%%o", alertInfo.objective or ""):gsub("%%O", objectiveReps):gsub("%%p", percent):gsub("%%r", remainder):gsub("%%t", alertInfo.objectiveTitle or "")

    alert = self:ParseIfStatement(alert)

    return alert
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function addon:UpdateMasque()
    -- Add buttons to Masque groups
    for barID, bar in pairs(self.bars) do
        self.masque.anchor:AddButton(bar.anchor, {Count = false})
        for buttonID, button in pairs(bar.buttons) do
            self.masque.button:AddButton(button)
        end
    end

    -- Reskin buttons
    self.masque.anchor:ReSkin()
    self.masque.button:ReSkin()

    -- Update buttons to restore FB's offset settings
    for barID, bar in pairs(self.bars) do
        bar:UpdateButtons("Size")
    end
end