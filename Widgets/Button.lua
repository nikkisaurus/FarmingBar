local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)
local AceGUI = LibStub("AceGUI-3.0")
local LSM = LibStub("LibSharedMedia-3.0")

local Type = "FarmingBar_Button"
local Version = 1

local function PickupObjectiveInfo(widget)
    if not widget:IsEmpty() then
        local _, buttonDB = widget:GetDB()
        private.ObjectiveFrame:LoadObjective(buttonDB)
        private.ObjectiveFrame:SetAltWidget(widget)
        widget.icon:SetDesaturated(true)
    end
end

local function PlaceObjectiveInfo(widget)
    local isEmpty = widget:IsEmpty()
    local objectiveInfo, altWidget = private.ObjectiveFrame:GetObjective()

    if objectiveInfo then
        if altWidget then
            if not isEmpty then
                local _, buttonDB = widget:GetDB()
                altWidget:SetObjectiveInfo(addon:CloneTable(buttonDB))
            else
                altWidget:Clear()
            end
        end

        widget:SetObjectiveInfo(addon:CloneTable(objectiveInfo))
        private.ObjectiveFrame:Clear()

        return true
    end
end

local postClickMethods = {
    clearObjective = function(frame)
        local widget = frame.obj
        if private.editor and private.editor.widget == widget then
            private:CloseObjectiveEditor()
        end
        widget:Clear()
    end,

    dragObjective = function(frame)
        PickupObjectiveInfo(frame.obj)
    end,

    moveObjective = function(frame)
        PickupObjectiveInfo(frame.obj)
    end,

    moveObjectiveToBank = function(frame)
        local widget = frame.obj
        local _, buttonDB = widget:GetDB()
        if not buttonDB.objective or buttonDB.objective == 0 then
            return
        end

        private:MoveObjectiveToBank(widget)
    end,

    moveAllToBank = function(frame)
        private:MoveObjectiveToBank(frame.obj)
    end,

    onUse = function(frame)
        local widget = frame.obj
        local _, buttonDB = widget:GetDB()
        local itemID = buttonDB and buttonDB.onUse.itemID

        if widget:IsEmpty() or buttonDB.onUse.type == "NONE" or not itemID or not GetItemSpell(itemID) then
            return
        end

        if not GetCVar("autoLootDefault") and private.db.global.settings.autoLoot and GetNumLootItems() > 0 then
            C_Timer.After(0.5, function()
                for i = 1, GetNumLootItems() do
                    LootSlot(i)
                end
            end)
        end
    end,

    showObjectiveEditBox = function(frame)
        local widget = frame.obj
        if not widget:IsEmpty() then
            widget:SetUserData("editType", "objective")
            widget.editbox:Show()
        end
    end,

    showObjectiveEditor = function(frame)
        local widget = frame.obj
        private:LoadObjectiveEditor(widget)
    end,

    showQuickAddCurrencyEditBox = function(frame)
        if not private:IsCurrencySupported() then
            return
        end

        local widget = frame.obj
        widget:SetUserData("editType", "currency")
        widget.editbox:Show()
    end,

    showQuickAddEditBox = function(frame)
        local widget = frame.obj
        widget:SetUserData("editType", "item")
        widget.editbox:Show()
    end,
}

local function ProcessKeybinds(frame, buttonClicked, down)
    if not down then
        return
    end

    for keybind, keybindInfo in pairs(private.db.global.settings.keybinds) do
        if buttonClicked == keybindInfo.button then
            local modifier = addon:GetModifierString()
            local isDragging = frame.obj:GetUserData("dragging")

            if modifier == keybindInfo.modifier and (keybindInfo.type == "drag" and isDragging or not isDragging) then
                local func = postClickMethods[keybind]
                if func then
                    func(frame, keybindInfo, buttonClicked, down)
                    return
                end
            end
        end
    end
end

local editboxScripts = {
    OnEditFocusGained = function(editbox)
        editbox:HighlightText()
    end,

    OnEnterPressed = function(editbox)
        local widget = editbox.obj
        local barDB = widget:GetDB()
        local barID, buttonID = widget:GetID()
        local editType = widget:GetUserData("editType")
        local input = tonumber(editbox:GetText())

        if editType == "objective" then
            local objective = input or 0
            private.db.profile.bars[barID].buttons[buttonID].objective = objective
            widget:SetObjective()

            if barDB.limitMats then
                widget:GetBar():UpdateButtons()
            end

            if private.db.global.settings.alerts.button.sound then
                if objective == 0 then
                    PlaySoundFile(LSM:Fetch(LSM.MediaType.SOUND, private.db.global.settings.alerts.sounds.objectiveCleared))
                else
                    PlaySoundFile(LSM:Fetch(LSM.MediaType.SOUND, private.db.global.settings.alerts.sounds.objectiveSet))
                end
            end
        elseif editType == "item" then
            private:AddObjective(widget, "ITEM", tonumber(input), L["Invalid item ID."])
        elseif editType == "currency" then
            local currencyID = private:ValidateCurrency(input or 0)
            if currencyID then
                private:AddObjective(widget, "CURRENCY", currencyID)
            else
                addon:Print(private.defaultChatFrame, L["Invalid currency ID."])
            end
        end

        editbox:ClearFocus()
        editbox:Hide()
    end,

    OnEscapePressed = function(editbox)
        editbox:ClearFocus()
        editbox:Hide()
    end,

    OnHide = function(editbox)
        editbox.obj:SetUserData("editType")
    end,

    OnShow = function(editbox)
        local widget = editbox.obj
        local editType = widget:GetUserData("editType")

        if editType == "objective" then
            editbox:SetText(private:GetObjectiveWidgetObjective(widget))
        else
            editbox:SetText("")
        end

        editbox:SetFocus()
    end,
}

local scripts = {
    OnDragStart = function(frame, buttonClicked, ...)
        local widget = frame.obj
        if widget:IsEmpty() then
            return
        end

        widget:SetUserData("dragging", true)
        ProcessKeybinds(frame, buttonClicked, ...)
    end,

    OnDragStop = function(frame, ...)
        C_Timer.After(0.2, function()
            frame.obj:SetUserData("dragging")
        end)
    end,

    OnEnter = function(frame, ...)
        if not addon:IsHooked(frame, "OnUpdate") then
            addon:HookScript(frame, "OnUpdate", function()
                private:LoadTooltip(frame, "ANCHOR_BOTTOMRIGHT", 0, 0, private:GetButtonTooltip(frame.obj))
            end)
        end

        -- Update mouseover
        local bar = frame.obj:GetBar()
        bar:CallScript("OnEnter", bar.frame, ...)
    end,

    OnEvent = function(frame, ...)
        local widget = frame.obj
        local barDB = widget:GetDB()
        if not widget:IsEmpty() then
            local oldCount, oldTrackers = widget:GetUserData("count"), widget:GetUserData("trackers")
            private:Alert(widget, oldCount, oldTrackers)
        end
        widget:SetCount()
    end,

    OnLeave = function(frame, ...)
        private:ClearTooltip()
        if addon:IsHooked(frame, "OnUpdate") then
            addon:Unhook(frame, "OnUpdate")
        end

        -- Update mouseover
        local bar = frame.obj:GetBar()
        bar:CallScript("OnLeave", bar.frame, ...)
    end,

    OnReceiveDrag = function(frame, ...)
        PlaceObjectiveInfo(frame.obj)
    end,

    PostClick = function(frame, buttonClicked, down)
        if not down then
            return
        end

        local widget = frame.obj
        local cursorType, itemID = GetCursorInfo()

        if PlaceObjectiveInfo(widget) then
            return
        elseif cursorType == "item" and itemID then
            private:AddObjective(widget, "ITEM", itemID)
            ClearCursor()

            return
        end

        C_Timer.After(0.2, function()
            ProcessKeybinds(frame, buttonClicked, down)
        end)
    end,
}

local methods = {
    OnAcquire = function(widget)
        widget:Show()
        widget.frame:RegisterEvent("BAG_UPDATE_DELAYED")
        widget.frame:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
    end,

    OnRelease = function(widget)
        widget.frame:UnregisterEvent("BAG_UPDATE_DELAYED")
        widget.frame:UnregisterEvent("CURRENCY_DISPLAY_UPDATE")
    end,

    AddTracker = function(widget, trackerType, trackerID)
        local barID, buttonID = widget:GetID()
        local tracker = addon:CloneTable(private.defaults.tracker)
        tracker.type = trackerType
        tracker.id = trackerID
        tinsert(private.db.profile.bars[barID].buttons[buttonID].trackers, tracker)
        local trackerKey = #private.db.profile.bars[barID].buttons[buttonID].trackers
        return trackerKey, private.db.profile.bars[barID].buttons[buttonID].trackers[trackerKey]
    end,

    AddTrackerAltID = function(widget, trackerKey, altType, altID)
        local barID, buttonID = widget:GetID()
        tinsert(private.db.profile.bars[barID].buttons[buttonID].trackers[trackerKey].altIDs, {
            type = altType,
            id = altID,
            multiplier = 1,
        })
        local altIDKey = #private.db.profile.bars[barID].buttons[buttonID].trackers[trackerKey].altIDs
        addon:Cache(strlower(altType), altID, function(success, id, private, barID, buttonID, trackerKey, altIDKey)
            local altID = private.db.profile.bars[barID].buttons[buttonID].trackers[trackerKey].altIDs[altIDKey]
            local name = private:GetTrackerInfo(altID.type, id)
            altID.name = name or ""
        end, { private, barID, buttonID, trackerKey, altIDKey })
    end,

    Clear = function(widget)
        local barID, buttonID = widget:GetID()
        private.db.profile.bars[barID].buttons[buttonID] = nil
        widget:UpdateAttributes()
    end,

    DrawButton = function(widget)
        local barDB, buttonDB = widget:GetDB()
        widget:SetSize(barDB.buttonSize)
    end,

    GetBar = function(widget)
        return private.bars[widget:GetID()]
    end,

    GetDB = function(widget)
        local barID, buttonID = widget:GetID()
        local barDB = private.db.profile.bars[barID]

        return barDB, barDB.buttons[buttonID]
    end,

    GetHyperlink = function(widget)
        if widget:IsEmpty() then
            return
        end
        local _, buttonDB = widget:GetDB()
        if buttonDB.onUse.type == "ITEM" and buttonDB.onUse.itemID then
            return strjoin(":", strlower(buttonDB.onUse.type), buttonDB.onUse.itemID)
        elseif buttonDB.trackers[1] and buttonDB.trackers[1].type == "CURRENCY" and buttonDB.trackers[1].id ~= 0000 then
            -- Currencies typically won't have an onUse item set, so we need to check the first tracker to see if it's a currency. I don't think there's a need to show the tooltip for item trackers without an onUse set at this point, as to not change existing behavior, and to give the user more control over items being shown. I could see in the future adding the option to specify a currency "onUse", simply for using it as the tooltip. Or, maybe an option to select a specific tracker to use on tooltips.
            return strjoin(":", strlower(buttonDB.trackers[1].type), buttonDB.trackers[1].id)
        end
    end,

    GetID = function(widget)
        return widget:GetUserData("barID"), widget:GetUserData("buttonID")
    end,

    GetProfessionQuality = function(widget)
        local _, buttonDB = widget:GetDB()

        local quality
        for _, tracker in pairs(buttonDB.trackers) do
            if tracker.id then
                local trackerQuality = C_TradeSkillUI.GetItemReagentQualityByItemInfo(tracker.id)
                if not quality then
                    quality = trackerQuality
                elseif trackerQuality ~= quality then
                    return 0
                end
            end
        end

        return quality or C_TradeSkillUI.GetItemReagentQualityByItemInfo(buttonDB.onUse.itemID)
    end,

    Hide = function(widget)
        widget.frame:Hide()
    end,

    IsEmpty = function(widget)
        local _, buttonDB = widget:GetDB()
        return not buttonDB, buttonDB
    end,

    IsObjectiveComplete = function(widget)
        if widget:IsEmpty() then
            return
        end

        local barDB, buttonDB = widget:GetDB()

        return private:GetObjectiveWidgetCount(widget) >= buttonDB.objective
    end,

    SetAlpha = function(widget, alpha)
        widget.frame:SetAlpha(alpha)
    end,

    SetAttributes = function(widget)
        local info = private.db.global.settings.keybinds.onUse
        local buttonType = (info.modifier ~= "" and (info.modifier .. "-") or "") .. "type" .. (info.button == "RightButton" and 2 or 1)
        local isEmpty = widget:IsEmpty()
        local _, buttonDB = widget:GetDB()

        if not isEmpty and widget.frame:GetAttribute(buttonType) == "macro" and buttonDB.onUse.type == "MACROTEXT" then
            if widget.frame:GetAttribute("macrotext") == buttonDB.onUse.macrotext then
                return
            end
        elseif not isEmpty and widget.frame:GetAttribute(buttonType) == "item" and buttonDB.onUse.type == "ITEM" then
            if widget.frame:GetAttribute("item") == ("item" .. buttonDB.onUse.itemID) then
                return
            end
        end

        widget.frame:SetAttribute(buttonType, nil)
        widget.frame:SetAttribute("item", nil)
        widget.frame:SetAttribute("macrotext", nil)

        if isEmpty then
            return
        end

        if UnitAffectingCombat("player") then
            return
        end

        if buttonDB.onUse.type == "ITEM" and buttonDB.onUse.itemID then
            widget.frame:SetAttribute(buttonType, "item")
            widget.frame:SetAttribute("item", "item:" .. buttonDB.onUse.itemID)
        elseif buttonDB.onUse.type == "MACROTEXT" then
            widget.frame:SetAttribute(buttonType, "macro")
            widget.frame:SetAttribute("macrotext", buttonDB.onUse.macrotext)
        end
    end,

    SetCount = function(widget)
        local count, trackers = private:GetObjectiveWidgetCount(widget)
        widget:SetUserData("count", count)
        widget:SetUserData("trackers", trackers)
        widget.count:SetText(private.db.profile.style.buttons.abbreviateCount and addon:iformat(count, 2, true) or count)
        widget:SetObjective()
    end,

    SetDBValue = function(widget, key, value, nested)
        local barID, buttonID = widget:GetID()
        if nested ~= nil then
            private.db.profile.bars[barID].buttons[buttonID][key][value] = nested
        else
            private.db.profile.bars[barID].buttons[buttonID][key] = value
        end
    end,

    SetFontstrings = function(widget)
        local barDB, buttonDB = widget:GetDB()
        local isEmpty = widget:IsEmpty()

        for fontName, fontDB in pairs(barDB.fontstrings) do
            local fontstring = widget[strlower(fontName)]
            fontstring = fontstring.SetFont and fontstring or fontstring:GetRegions()

            fontstring:ClearAllPoints()

            if fontDB.enabled and not isEmpty then
                fontstring:Show()
                fontstring:SetPoint(fontDB.anchor, fontDB.x, fontDB.y)
                fontstring:SetFont(LSM:Fetch("font", fontDB.face), fontDB.size, fontDB.outline)
                fontstring:SetTextColor(unpack(fontDB.color))
            else
                fontstring:Hide()
            end
        end

        local fontDB = private.db.profile.style.font
        widget.editbox:SetFont(LSM:Fetch("font", fontDB.face), fontDB.size, fontDB.outline)
    end,

    SetHeight = function(widget, height)
        widget.frame:SetHeight(height)
    end,

    SetIconTextures = function(widget)
        local barDB, buttonDB = widget:GetDB()
        local isEmpty = widget:IsEmpty()

        widget.icon:SetDesaturated(false)

        if isEmpty then
            widget.icon:SetTexture()
            widget.iconBorder:Hide()
            widget.iconTier:SetTexCoord(0, 1, 0, 1)
            widget.iconTier:Hide()
        else
            -- Icon
            local icon = private:GetObjectiveIcon(buttonDB)
            widget.icon:SetTexture(icon)

            -- Icon Border
            local skin = private.db.global.skins[barDB.skin]
            if not skin.buttonTextures.iconBorder.hidden and buttonDB.onUse.type == "ITEM" then
                addon:CacheItem(buttonDB.onUse.itemID, function(success, id, widget)
                    if success then
                        local _, _, rarity = GetItemInfo(id)
                        if rarity and rarity >= 2 then
                            local r, g, b = GetItemQualityColor(rarity)
                            widget.iconBorder:Show()
                            widget.iconBorder:SetVertexColor(r, g, b, 1)
                        else
                            widget.iconBorder:Hide()
                        end
                    end
                end, { widget })
            else
                widget.iconBorder:Hide()
            end

            -- Icon Tier
            if private:GetGameVersion() < 110000 then
                return
            end

            local tier = private.iconTiers[widget:GetProfessionQuality()]
            if tier and barDB.iconTier.enabled then
                widget.iconTier:SetTexCoord(unpack(tier))
                widget.iconTier:ClearAllPoints()
                widget.iconTier:SetSize(barDB.buttonSize * barDB.iconTier.scale, barDB.buttonSize * barDB.iconTier.scale)
                widget.iconTier:SetPoint(barDB.iconTier.anchor, widget.frame, barDB.iconTier.anchor, barDB.iconTier.x, barDB.iconTier.y)

                widget.iconTier:Show()
            else
                widget.iconTier:Hide()
            end
        end
    end,

    SetID = function(widget, barID, buttonID)
        if widget:GetID() then
            if private.db.global.debug.enabled then
                error(format(L["Button is already assigned an ID: %d:%d"], widget:GetID()))
            end
            return
        end

        widget:SetUserData("barID", barID)
        widget:SetUserData("buttonID", buttonID)
        widget:Update()
    end,

    SetObjective = function(widget)
        local barDB, buttonDB = widget:GetDB()
        local objective = buttonDB and buttonDB.objective or 0

        if widget:IsEmpty() or not objective or objective == 0 then
            widget.objective:SetText()
            widget.objective:Hide()
        else
            local count = private:GetObjectiveWidgetCount(widget)
            local color = count >= objective and { 0, 1, 0, 1 } or barDB.fontstrings.Objective.color

            widget.objective:SetTextColor(unpack(color))
            widget.objective:SetText(addon:iformat(objective, 2))
            widget.objective:Show()
        end
    end,

    SetObjectiveInfo = function(widget, objectiveInfo)
        local barID, buttonID = widget:GetID()
        private.db.profile.bars[barID].buttons[buttonID] = objectiveInfo
        widget:UpdateAttributes()
    end,

    SetPoint = function(widget, ...)
        widget.frame:SetPoint(...)
    end,

    SetSize = function(widget, width, height)
        widget:SetWidth(width)
        widget:SetHeight(height or width)
        widget.editbox:SetSize(width, width / 2)
    end,

    SetTextures = function(widget)
        local barDB = widget:GetDB()
        local skin = private.db.global.skins[barDB.skin]

        for layerName, textureInfo in pairs(skin.buttonTextures) do
            local layer = widget[layerName]
            local texture = LSM:Fetch(LSM.MediaType.BACKGROUND, textureInfo.texture)

            layer:ClearAllPoints()

            if private.MSQ and not private.MSQ.button.db.Disabled then
                layer:SetTexture()
                layer:SetVertexColor(1, 1, 1, 1)
                layer:SetTexCoord(0, 1, 0, 1)
                layer:SetAllPoints(widget.frame)
                layer:Show()

                private.MSQ.button:AddButton(widget.frame)
                private.MSQ.button:ReSkin(true)
            else
                layer:SetTexture(texture)
                layer:SetVertexColor(addon:unpack(textureInfo.color, { 1, 1, 1, 1 }))
                layer:SetTexCoord(addon:unpack(textureInfo.texCoords, { 0, 1, 0, 1 }))
                layer:SetBlendMode(textureInfo.blendMode)
                layer:SetDrawLayer(textureInfo.drawLayer, textureInfo.layer)

                if textureInfo.hidden then
                    layer:Hide()
                else
                    layer:Show()
                end

                if textureInfo.insets then
                    layer:SetPoint("LEFT", textureInfo.insets.left, 0)
                    layer:SetPoint("RIGHT", textureInfo.insets.right, 0)
                    layer:SetPoint("TOP", 0, textureInfo.insets.top)
                    layer:SetPoint("BOTTOM", 0, textureInfo.insets.bottom)
                else
                    layer:SetAllPoints(widget.frame)
                end
            end
        end
    end,

    SetTrackerDBValue = function(widget, trackerKey, key, value, nested)
        local barID, buttonID = widget:GetID()
        if nested ~= nil then
            private.db.profile.bars[barID].buttons[buttonID].trackers[trackerKey][key][value] = nested
        else
            private.db.profile.bars[barID].buttons[buttonID].trackers[trackerKey][key] = value
        end
    end,

    SetWidth = function(widget, width)
        widget.frame:SetWidth(width)
    end,

    Show = function(widget)
        widget.frame:Show()
    end,

    TrackerAltIDExists = function(widget, trackerKey, altType, altID)
        local _, buttonDB = widget:GetDB()
        local trackerInfo = buttonDB.trackers[trackerKey]
        local trackerType = trackerInfo.type
        local trackerID = trackerInfo.id

        if altType == trackerType and altID == trackerID then
            return true
        end

        for _, altInfo in pairs(trackerInfo.altIDs) do
            if altInfo.type == altType and altInfo.id == altID then
                return true
            end
        end
    end,

    TrackerExists = function(widget, trackerType, trackerID)
        local _, buttonDB = widget:GetDB()
        for _, trackerInfo in pairs(buttonDB.trackers) do
            if trackerInfo.type == trackerType and trackerInfo.id == trackerID then
                return true
            end
        end
    end,

    Update = function(widget)
        widget:DrawButton()
        widget:SetTextures()
        widget:UpdateAttributes()
    end,

    UpdateAttributes = function(widget)
        widget:SetIconTextures()
        widget:SetAttributes()
        widget:SetFontstrings()
        widget:SetCount()
    end,

    UpdateTrackerKeys = function(widget, trackerKey, newTrackerKey)
        local _, buttonDB = widget:GetDB()
        local barID, buttonID = widget:GetID()

        if trackerKey > addon:tcount(buttonDB.trackers) then
            return trackerKey
        end

        local trackerInfo = addon:CloneTable(buttonDB.trackers[trackerKey])
        tremove(private.db.profile.bars[barID].buttons[buttonID].trackers, trackerKey)
        tinsert(private.db.profile.bars[barID].buttons[buttonID].trackers, newTrackerKey, trackerInfo)

        return newTrackerKey
    end,
}

local function Constructor()
    --[[ Frame ]]
    local frame = CreateFrame("Button", Type .. AceGUI:GetNextWidgetNum(Type), UIParent, "BackdropTemplate, SecureActionButtonTemplate, SecureHandlerStateTemplate")
    frame:SetFrameStrata("MEDIUM")
    frame:SetFrameLevel(1)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton", "RightButton")
    if private:GetGameVersion() < 100000 then
        frame:RegisterForClicks("AnyDown")
    else
        frame:RegisterForClicks("AnyUp", "AnyDown")
    end

    for script, func in pairs(scripts) do
        frame:SetScript(script, func)
    end

    local editbox = CreateFrame("EditBox", "$parentEditbox", frame)
    editbox:SetPoint("TOPLEFT")
    editbox:SetAutoFocus(false)
    editbox:Hide()

    for script, func in pairs(editboxScripts) do
        editbox:SetScript(script, func)
    end

    local editboxBG = editbox:CreateTexture()
    editboxBG:SetAllPoints(editbox)
    editboxBG:SetTexture([[INTERFACE\BUTTONS\WHITE8X8]])
    editboxBG:SetVertexColor(0, 0, 0, 0.33)

    local backdrop = frame:CreateTexture("$parentBackdrop")
    local cooldown = CreateFrame("Cooldown", "$parentCooldown", frame, "CooldownFrameTemplate")
    local count = frame:CreateFontString("$parentCount", "OVERLAY", "GameFontHighlight")
    local gloss = frame:CreateTexture("$parentGloss")
    local highlight = frame:CreateTexture("$parentHighlight")
    local icon = frame:CreateTexture("$parentIcon")
    local iconBorder = frame:CreateTexture("$parentIconBorder")
    local iconTier = frame:CreateTexture("$parentIconTier")
    local mask = frame:CreateTexture("$parentMask")
    local normal = frame:CreateTexture("$parentNormal")
    local objective = frame:CreateFontString("$parentObjective", "OVERLAY", "GameFontHighlight")
    local pushed = frame:CreateTexture("$parentPushed")
    local shadow = frame:CreateTexture("$parentShadow")

    --[[ Widget ]]
    local widget = {
        frame = frame,
        backdrop = backdrop,
        cooldown = cooldown,
        count = count,
        gloss = gloss,
        highlight = highlight,
        icon = icon,
        iconBorder = iconBorder,
        iconTier = iconTier,
        mask = mask,
        normal = normal,
        objective = objective,
        editbox = editbox,
        pushed = pushed,
        shadow = shadow,
        type = Type,
    }

    frame.obj = widget
    editbox.obj = widget

    for method, func in pairs(methods) do
        widget[method] = func
    end

    AceGUI:RegisterAsWidget(widget)

    return widget
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
