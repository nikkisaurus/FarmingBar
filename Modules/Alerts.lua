local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)
local LSM = LibStub("LibSharedMedia-3.0")

function private:Alert(widget, ...)
    local barDB, buttonDB = widget:GetDB()

    if not widget.frame:IsVisible() or barDB.alerts.muteAll or buttonDB.mute then
        return
    end

    local alertSettings = private.db.global.settings.alerts.button
    local alert = alertSettings.format

    local oldCount, oldTrackers = ...
    local newCount, newTrackers = private:GetObjectiveWidgetCount(widget)

    if not oldCount or oldCount == newCount then
        for trackerKey, trackerCount in pairs(oldTrackers) do
            if trackerCount ~= newTrackers[trackerKey] then
                private:AlertTracker(widget, trackerKey, trackerCount, newTrackers[trackerKey])
            end
        end
        return
    end

    local alertInfo = {
        title = buttonDB.title,
        oldCount = oldCount,
        newCount = newCount,
        difference = newCount - oldCount,
        lost = oldCount > newCount,
        gained = oldCount < newCount,
        goal = buttonDB.objective,
        goalMet = newCount >= buttonDB.objective,
        newGoalMet = newCount >= buttonDB.objective and oldCount < buttonDB.objective,
        reps = (buttonDB.objective and buttonDB.objective > 0)
            and (newCount >= buttonDB.objective and floor(newCount / buttonDB.objective) or 0),
    }

    local func = loadstring("return " .. alert)
    if type(func) == "function" then
        local success, userFunc = pcall(func)
        if success and type(userFunc) == "function" then
            alert = userFunc(alertInfo, private.lists.alertColors)
            if
                not barDB.alerts.completedObjectives and alertInfo.objectiveMet and not alertInfo.newObjectiveMet
                or not alert
            then
                return
            end

            if alertSettings.chat then
                addon:Print(_G[barDB.alerts.chatFrame], alert)
            end

            if alertSettings.screen then
                UIErrorsFrame:AddMessage(alert, 1, 1, 1)
            end

            if alertSettings.sound then
                if alertInfo.newObjectiveMet then
                    PlaySoundFile(LSM:Fetch(LSM.MediaType.SOUND, private.db.global.settings.alerts.sounds.objectiveMet))
                elseif alertInfo.gained then
                    PlaySoundFile(LSM:Fetch(LSM.MediaType.SOUND, private.db.global.settings.alerts.sounds.progress))
                end
            end

            if barDB.alerts.barProgress then
                widget:GetBar():SetProgress()
            end
        end
    end
end

function private:AlertBar(widget, progress, total, newProgress, newTotal)
    local alertSettings = private.db.global.settings.alerts.bar
    local alert = alertSettings.format
    local barDB = widget:GetDB()
    local barID = widget:GetID()

    local alertInfo = {
        barID = barID,
        label = barDB.label,
        difference = newProgress - progress,
        lost = progress > newProgress,
        gained = progress < newProgress,
        oldProgress = progress,
        oldTotal = total,
        newProgress = newProgress,
        newTotal = newTotal,
        newComplete = progress < newTotal and newProgress == newTotal,
    }

    local func = loadstring("return " .. alert)
    if type(func) == "function" then
        local success, userFunc = pcall(func)
        if success and type(userFunc) == "function" then
            alert = userFunc(alertInfo, private.lists.alertColors)
            if
                not barDB.alerts.completedObjectives and alertInfo.objectiveMet and not alertInfo.newObjectiveMet
                or not alert
            then
                return
            end

            if alertSettings.chat then
                addon:Print(_G[barDB.alerts.chatFrame], alert)
            end

            if alertSettings.screen then
                UIErrorsFrame:AddMessage(alert, 1, 1, 1)
            end

            if alertSettings.sound then
                if alertInfo.newComplete then
                    PlaySoundFile(LSM:Fetch(LSM.MediaType.SOUND, private.db.global.settings.alerts.sounds.barComplete))
                elseif alertInfo.gained then
                    PlaySoundFile(LSM:Fetch(LSM.MediaType.SOUND, private.db.global.settings.alerts.sounds.barProgress))
                end
            end
        end
    end
end

function private:AlertTracker(widget, trackerKey, oldCount, newCount)
    local alertSettings = private.db.global.settings.alerts.tracker
    local alert = alertSettings.format
    local barDB, buttonDB = widget:GetDB()
    local tracker = buttonDB.trackers[trackerKey]

    if tracker.type == "ITEM" then
        private:CacheItem(tracker.id)
    end
    local name = private:GetTrackerInfo(tracker.type, tracker.id)
    local trackerGoal = (buttonDB.objective > 0 and buttonDB.objective or 1) * tracker.objective

    local alertInfo = {
        title = buttonDB.title,
        trackerName = name,
        oldCount = oldCount,
        newCount = newCount,
        difference = newCount - oldCount,
        lost = oldCount > newCount,
        gained = oldCount < newCount,
        goal = buttonDB.objective,
        trackerGoal = tracker.objective,
        trackerGoalTotal = trackerGoal,
        objectiveMet = newCount >= trackerGoal,
        newComplete = oldCount < trackerGoal and newCount >= trackerGoal,
    }

    local func = loadstring("return " .. alert)
    if type(func) == "function" then
        local success, userFunc = pcall(func)
        if success and type(userFunc) == "function" then
            alert = userFunc(alertInfo, private.lists.alertColors)
            if not alert then
                return
            end

            if alertSettings.chat then
                addon:Print(_G[barDB.alerts.chatFrame], alert)
            end

            if alertSettings.screen then
                UIErrorsFrame:AddMessage(alert, 1, 1, 1)
            end

            if alertSettings.sound then
                if alertInfo.newComplete then
                    PlaySoundFile(LSM:Fetch(LSM.MediaType.SOUND, private.db.global.settings.alerts.sounds.barComplete))
                elseif alertInfo.gained then
                    PlaySoundFile(LSM:Fetch(LSM.MediaType.SOUND, private.db.global.settings.alerts.sounds.barProgress))
                end
            end
        end
    end
end

function private:PreviewAlert(Type)
    local alert = private.db.global.settings.alerts[Type]
    local func = loadstring("return " .. alert.format)
    if type(func) == "function" then
        local success, userFunc = pcall(func)
        if success and type(userFunc) == "function" then
            local ret = userFunc(alert.alertInfo, private.lists.alertColors)
            if ret and type(ret) == "string" then
                return ret
            end
        end
    end
end

function private:ValidateAlert(Type, alert)
    local func = loadstring("return " .. alert)
    if type(func) == "function" then
        local success, userFunc = pcall(func)
        if success and type(userFunc) == "function" then
            local ret = userFunc(private.db.global.settings.alerts[Type].alertInfo, private.lists.alertColors)
            if ret and type(ret) == "string" then
                return true
            end
        end
    end
end
