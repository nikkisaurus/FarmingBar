local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = private.L

function private:ConvertDB_V2()
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

    -- Objectives
    if private.backup.char then
        for char, charDB in pairs(private.backup.char) do
            for barID, barDB in pairs(charDB.bars) do
                for _, objective in pairs(barDB.objectives) do
                    local Type = objective.type

                    if Type ~= "currency" and Type ~= "item" then
                        local template = addon.CloneTable(private.defaults.objective)

                        if Type == "mixedItems" then -- ANY
                            template.condition.type = "ANY"
                            template.title = objective.title or ""
                            template.icon.type = "FALLBACK"
                            template.icon.id = objective.icon or 134400

                            for _, itemID in pairs(objective.items) do
                                local tracker = addon.CloneTable(private.defaults.tracker)
                                tracker.id = itemID
                                tinsert(template.trackers, tracker)
                            end
                        elseif Type == "shoppingList" then -- ALL
                            template.condition.type = "ALL"
                            template.title = objective.title or ""
                            template.icon.type = "FALLBACK"
                            template.icon.id = objective.icon or 134400

                            for itemID, count in pairs(objective.items) do
                                local tracker = addon.CloneTable(private.defaults.tracker)
                                tracker.id = itemID
                                tracker.objective = count or 1
                                tinsert(template.trackers, tracker)
                            end
                        end

                        private:AddObjectiveTemplate(template, template.title)
                    end
                end
            end
        end
    end
end
