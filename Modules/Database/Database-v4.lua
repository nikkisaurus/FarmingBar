local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)

function private:ConvertDB_V4()
    -- Settings
    if private.backup.global.settings then
        -- Commands
        if private.backup.global.settings.commands then
            for command, enabled in pairs(private.backup.global.settings.commands) do
                private.db.global.settings.commands[command] = enabled
            end
        end

        -- Alerts
        if private.backup.global.settings.alerts then
            -- Button
            local buttonAlerts = private.backup.global.settings.alerts.button
            if buttonAlerts then
                if buttonAlerts.chat ~= nil then
                    private.db.global.settings.alerts.button.chat = buttonAlerts.chat
                end
                if buttonAlerts.screen ~= nil then
                    private.db.global.settings.alerts.button.screen = buttonAlerts.screen
                end
                if buttonAlerts.sound then
                    if buttonAlerts.sound.enabled ~= nil then
                        private.db.global.settings.alerts.button.sound = buttonAlerts.sound.enabled
                    end
                    if buttonAlerts.sound.objectiveSet then
                        private.db.global.settings.alerts.sounds.objectiveSet = buttonAlerts.sound.objectiveSet
                    end
                    if buttonAlerts.sound.objectiveCleared then
                        private.db.global.settings.alerts.sounds.objectiveCleared = buttonAlerts.sound.objectiveCleared
                    end
                    if buttonAlerts.sound.progress then
                        private.db.global.settings.alerts.sounds.progress = buttonAlerts.sound.progress
                    end
                    if buttonAlerts.sound.objectiveComplete then
                        private.db.global.settings.alerts.sounds.objectiveMet = buttonAlerts.sound.objectiveComplete
                    end
                end
            end

            -- Bar
            local barAlerts = private.backup.global.settings.alerts.bar
            if barAlerts then
                if barAlerts.chat ~= nil then
                    private.db.global.settings.alerts.bar.chat = barAlerts.chat
                end
                if barAlerts.screen ~= nil then
                    private.db.global.settings.alerts.bar.screen = barAlerts.screen
                end
                if barAlerts.sound then
                    if barAlerts.sound.enabled ~= nil then
                        private.db.global.settings.alerts.bar.sound = barAlerts.sound.enabled
                    end
                    if barAlerts.sound.progress then
                        private.db.global.settings.alerts.sounds.barProgress = barAlerts.sound.progress
                    end
                    if barAlerts.sound.complete then
                        private.db.global.settings.alerts.sounds.barComplete = barAlerts.sound.complete
                    end
                end
            end
        end

        -- Keybinds
        if private.backup.global.settings.keybinds then
            -- Button
            for action, info in pairs(private.backup.global.settings.keybinds.button) do
                private.db.global.settings.keybinds[action == "useItem" and "onUse" or action] = addon.CloneTable(info)
            end
        end

        -- Tooltips
        local tooltips = private.backup.global.settings.tooltips
        if tooltips then
            if tooltips.condensedTooltip ~= nil then
                private.db.global.settings.tooltips.showDetails = tooltips.condensedTooltip
            end
            if tooltips.useGameTooltip ~= nil then
                private.db.global.settings.tooltips.useGameTooltip = tooltips.useGameTooltip
            end
            if tooltips.modifier then
                private.db.global.settings.tooltips.modifier = tooltips.modifier
            end
        end

        -- Hints
        local hints = private.backup.global.settings.hints
        if hints then
            if hints.buttons ~= nil then
                private.db.global.settings.tooltips.showHints = hints.buttons
            end
        end
    end

    -- Objectives
    if private.backup.global.objectives then
        for objectiveTitle, objective in pairs(private.backup.global.objectives) do
            print(objectiveTitle, objective.autoIcon)
            local objectiveInfo = {
                title = objectiveTitle,
                objective = 0,
                mute = false,
                icon = {
                    type = (objective.autoIcon == false) and "FALLBACK" or "AUTO",
                    id = objective.icon or 134400,
                },
                onUse = {
                    type = objective.action or "NONE",
                    itemID = objective.action == "ITEM" and tonumber(objective.actionInfo) or false,
                    macrotext = objective.action == "MACROTEXT" and objective.actionInfo or "",
                },
                condition = {
                    type = objective.condition or "ALL",
                    func = private.defaults.objective.condition.func,
                },
                trackers = {},
            }

            if objective.trackers then
                for trackerKey, tracker in pairs(objective.trackers) do
                    local Type, id = strsplit(":", trackerKey)
                    objectiveInfo.trackers[tracker.order] = {
                        type = Type,
                        id = tonumber(id),
                        objective = tracker.objective or 1,
                        includeAlts = false,
                        includeBank = false,
                        includeGuildBank = {},
                        altIDs = {},
                    }
                end
            end

            private:AddObjectiveTemplate(objectiveInfo, objectiveTitle)
        end
    end
end
