local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)

function private:ConvertDB_V2()
    private.db.global.backup = private.backup

    -- Settings
    if private.backup.global then
        -- Commands
        if private.backup.global.commands then
            for command, enabled in pairs(private.backup.global.commands) do
                private.db.global.settings.commands[command] = enabled and true or false
            end
        end

        -- Alerts
        if private.backup.global.alerts then
            -- Button
            local alerts = private.backup.global.alerts
            if alerts.chat ~= nil then
                private.db.global.settings.alerts.button.chat = alerts.chat
                private.db.global.settings.alerts.tracker.chat = alerts.chat
            end

            if alerts.screen ~= nil then
                private.db.global.settings.alerts.button.screen = alerts.screen
                private.db.global.settings.alerts.tracker.screen = alerts.screen
            end

            if alerts.sound ~= nil then
                private.db.global.settings.alerts.button.sound = alerts.sound
                private.db.global.settings.alerts.tracker.sound = alerts.sound
            end

            -- Bar
            if alerts.barChat ~= nil then
                private.db.global.settings.alerts.bar.chat = alerts.barChat
            end

            if alerts.barScreen ~= nil then
                private.db.global.settings.alerts.bar.screen = alerts.barScreen
            end

            if alerts.barSound ~= nil then
                private.db.global.settings.alerts.bar.sound = alerts.barSound
            end

            private.db.profile.chatFrame = alerts.chatFrame
        end

        -- Sounds
        local sounds = private.backup.global.sounds
        if sounds then
            if sounds.objectiveSet then
                private.db.global.settings.alerts.sounds.objectiveSet = sounds.objectiveSet
            end

            if sounds.objectiveCleared then
                private.db.global.settings.alerts.sounds.objectiveCleared = sounds.objectiveCleared
            end

            if sounds.barProgress then
                private.db.global.settings.alerts.sounds.barProgress = sounds.barProgress
            end

            if sounds.barComplete then
                private.db.global.settings.alerts.sounds.barComplete = sounds.barComplete
            end

            if sounds.farmingProgress then
                private.db.global.settings.alerts.sounds.progress = sounds.farmingProgress
            end

            if sounds.objectiveComplete then
                private.db.global.settings.alerts.sounds.objectiveMet = sounds.objectiveComplete
            end
        end

        -- Tooltips
        local tooltips = private.backup.global.tooltips
        if tooltips then
            if tooltips.enableMod ~= nil then
                private.db.global.settings.tooltips.showDetails = not tooltips.enableMod
            end

            if tooltips.mod then
                private.db.global.settings.tooltips.modifier = tooltips.mod
            end

            if tooltips.bar ~= nil then
                private.db.global.settings.tooltips.bar = tooltips.bar
            end

            if tooltips.button ~= nil then
                private.db.global.settings.tooltips.button = tooltips.button
            end
        end
    end

    if private.backup.global.templates then
        for templateName, template in pairs(private.backup.global.templates) do
            private.db.global.templates[templateName] = {}
            for buttonID, objective in pairs(template) do
                buttonID = tonumber(buttonID)
                local Type = objective.type
                if buttonID <= private.CONST.MAX_BUTTONS and Type then
                    local template = addon:CloneTable(private.defaults.objective)

                    if Type == "mixedItems" then -- ANY
                        template.condition.type = "ANY"
                        template.title = objective.title or ""
                        template.icon.type = "FALLBACK"
                        template.icon.id = objective.icon or 134400

                        for _, itemID in pairs(objective.items) do
                            local tracker = addon:CloneTable(private.defaults.tracker)
                            tracker.id = itemID
                            tinsert(template.trackers, tracker)
                        end
                    elseif Type == "shoppingList" then -- ALL
                        template.condition.type = "ALL"
                        template.title = objective.title or ""
                        template.icon.type = "FALLBACK"
                        template.icon.id = objective.icon or 134400

                        for itemID, count in pairs(objective.items) do
                            local tracker = addon:CloneTable(private.defaults.tracker)
                            tracker.id = itemID
                            tracker.objective = count or 1
                            tinsert(template.trackers, tracker)
                        end
                    elseif Type == "item" then
                        template.condition.type = "ALL"
                        template.title = objective.title ~= "" and objective.title or L["Converted Item"]
                        template.icon.type = "FALLBACK"
                        template.icon.id = GetItemIcon(objective.itemID) or 134400
                        local tracker = addon:CloneTable(private.defaults.tracker)
                        tracker.id = objective.itemID
                        tracker.objective = objective.objective or 1
                        tinsert(template.trackers, tracker)
                    elseif Type == "currency" then
                        template.condition.type = "ALL"
                        template.title = objective.title ~= "" and objective.title or L["Converted Currency"]
                        template.icon.type = "FALLBACK"
                        local currency = C_CurrencyInfo.GetCurrencyInfo(objective.currencyID)
                        template.icon.id = currency and currency.iconFileID or 134400
                        local tracker = addon:CloneTable(private.defaults.tracker)
                        tracker.type = "CURRENCY"
                        tracker.id = objective.currencyID
                        tracker.objective = objective.objective or 1
                        tinsert(template.trackers, tracker)
                    end

                    private.db.global.templates[templateName][buttonID] = addon:CloneTable(template)
                end
            end
        end
    end

    -- Bars
    if private.backup.char then
        for char, charDB in pairs(private.backup.char) do
            C_Timer.After(1, function()
                print(char)
            end)
            -- Get profile specific info that should now be bar specific
            local profileKey = private.backup.profileKeys[char]
            local profile = private.backup.profiles[profileKey]

            local showCooldown, showCooldownEdge, skin
            if profile.style then
                if profile.style.layers then
                    showCooldown = profile.style.layers.Cooldown
                    showCooldownEdge = profile.style.layers.CooldownEdge
                end
                if profile.style.skin then
                    skin = profile.style.skin.name == "default" and "FarmingBar_Default" or "FarmingBar_Minimal"
                end
            end

            private.db.profiles[char .. profileKey] = {}
            FarmingBarDB.profileKeys = FarmingBarDB.profileKeys or {}
            FarmingBarDB.profileKeys[char] = char .. profileKey
            profile = private.db.profiles[char .. profileKey]
            profile.bars = profile.bars or {}

            for barID, barDB in pairs(charDB.bars) do
                -- Add bar to profile
                local bar = addon:CloneTable(private.defaults.bar)
                if barDB.trackProgress then
                    bar.alerts.barProgress = barDB.trackProgress
                end
                if barDB.trackCompletedObjectives then
                    bar.alerts.completedObjectives = barDB.trackCompletedObjectives
                end
                if barDB.muteAlerts then
                    bar.alerts.muteAll = barDB.muteAlerts
                end
                if barDB.alpha then
                    bar.alpha = barDB.alpha
                end
                if barDB.direction == 1 then -- UP
                    if barDB.rowDirection == 1 then -- NORMAL
                        bar.barAnchor = "BOTTOMLEFT"
                        bar.buttonGrowth = "COL"
                    else -- REVERSE
                        bar.barAnchor = "BOTTOMRIGHT"
                        bar.buttonGrowth = "COL"
                    end
                elseif barDB.direction == 2 then -- RIGHT
                    if barDB.rowDirection == 1 then -- NORMAL
                        bar.barAnchor = "TOPLEFT"
                        bar.buttonGrowth = "ROW"
                    else -- REVERSE
                        bar.barAnchor = "TOPRIGHT"
                        bar.buttonGrowth = "ROW"
                    end
                elseif barDB.direction == 3 then -- DOWN
                    if barDB.rowDirection == 1 then -- NORMAL
                        bar.barAnchor = "TOPLEFT"
                        bar.buttonGrowth = "COL"
                    else -- REVERSE
                        bar.barAnchor = "TOPRIGHT"
                        bar.buttonGrowth = "COL"
                    end
                elseif barDB.direction == 4 then -- LEFT
                    if barDB.rowDirection == 1 then -- NORMAL
                        bar.barAnchor = "TOPRIGHT"
                        bar.buttonGrowth = "ROW"
                    else -- REVERSE
                        bar.barAnchor = "TOPLEFT"
                        bar.buttonGrowth = "ROW"
                    end
                end
                if barDB.buttonPadding then
                    bar.buttonPadding = barDB.buttonPadding
                end
                if barDB.buttonsPerRow then
                    bar.buttonsPerAxis = barDB.buttonsPerRow
                end
                if barDB.buttonSize then
                    bar.buttonSize = barDB.buttonSize
                end
                if not showCooldown then
                    bar.fontstrings.Cooldown.enabled = false
                end
                if showCooldownEdge then
                    bar.fontstrings.Cooldown.showEdge = true
                end
                if barDB.font then
                    if barDB.font.face then
                        bar.fontstrings.Cooldown.face = barDB.font.face
                        bar.fontstrings.Count.face = barDB.font.face
                        bar.fontstrings.Objective.face = barDB.font.face
                    end
                    if barDB.font.outline then
                        bar.fontstrings.Cooldown.outline = barDB.font.outline
                        bar.fontstrings.Count.outline = barDB.font.outline
                        bar.fontstrings.Objective.outline = barDB.font.outline
                    end
                    if barDB.font.size then
                        bar.fontstrings.Cooldown.size = barDB.font.size
                        bar.fontstrings.Count.size = barDB.font.size
                        bar.fontstrings.Objective.size = barDB.font.size
                    end
                end
                if barDB.hidden then
                    bar.overrideHidden = barDB.hidden
                end
                if barDB.desc then
                    bar.label = barDB.desc
                end
                if barDB.mouseover then
                    bar.mouseover = barDB.mouseover
                end
                if barDB.movable then
                    bar.movable = barDB.movable
                end
                if barDB.visibleButtons then
                    bar.numButtons = min(barDB.visibleButtons, private.CONST.MAX_BUTTONS)
                end
                if barDB.position then
                    C_Timer.After(1, function()
                        print("POS")
                    end)
                    bar.point = addon:CloneTable(barDB.position)
                end
                if barDB.scale then
                    bar.scale = barDB.scale
                end
                if barDB.showEmpties then
                    bar.showEmpty = barDB.showEmpties
                end
                bar.skin = skin or "FarmingBar_Default"

                profile.bars[barID] = addon:CloneTable(bar)

                -- Save objectives as templates
                if barDB.objectives then
                    for buttonID, objective in addon:pairs(barDB.objectives) do
                        local Type = objective.type

                        local template = addon:CloneTable(private.defaults.objective)

                        if Type == "mixedItems" then -- ANY
                            template.condition.type = "ANY"
                            template.title = objective.title or ""
                            template.icon.type = "FALLBACK"
                            template.icon.id = objective.icon or 134400

                            for _, itemID in pairs(objective.items) do
                                local tracker = addon:CloneTable(private.defaults.tracker)
                                tracker.id = itemID
                                tinsert(template.trackers, tracker)
                            end
                        elseif Type == "shoppingList" then -- ALL
                            template.condition.type = "ALL"
                            template.title = objective.title or ""
                            template.icon.type = "FALLBACK"
                            template.icon.id = objective.icon or 134400

                            for itemID, count in pairs(objective.items) do
                                local tracker = addon:CloneTable(private.defaults.tracker)
                                tracker.id = itemID
                                tracker.objective = count or 1
                                tinsert(template.trackers, tracker)
                            end
                        elseif Type == "item" then
                            template.condition.type = "ALL"
                            template.title = objective.title ~= "" and objective.title or L["Converted Item"]
                            template.icon.type = "FALLBACK"
                            template.icon.id = GetItemIcon(objective.itemID) or 134400
                            local tracker = addon:CloneTable(private.defaults.tracker)
                            tracker.id = objective.itemID
                            tracker.objective = objective.objective or 1
                            tinsert(template.trackers, tracker)
                        elseif Type == "currency" then
                            template.condition.type = "ALL"
                            template.title = objective.title ~= "" and objective.title or L["Converted Currency"]
                            template.icon.type = "FALLBACK"
                            local currency = C_CurrencyInfo.GetCurrencyInfo(objective.currencyID)
                            template.icon.id = currency and currency.iconFileID or 134400
                            local tracker = addon:CloneTable(private.defaults.tracker)
                            tracker.type = "CURRENCY"
                            tracker.id = objective.currencyID
                            tracker.objective = objective.objective or 1
                            tinsert(template.trackers, tracker)
                        end

                        private:AddObjectiveTemplate(template, template.title)

                        -- Add objective to bar
                        profile.bars[barID].buttons[buttonID] = addon:CloneTable(template)
                    end
                end
            end

            -- If we're on the active toon, trigger to refresh profile
            local realmKey = GetRealmName()
            local charKey = UnitName("player") .. " - " .. realmKey
            if char == charKey then
                private.loadProfile = char .. profileKey
            end
        end
    end
end
