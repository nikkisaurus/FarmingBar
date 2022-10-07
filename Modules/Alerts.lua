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
    local alertType = alertSettings.formatType
    local alert = alertType == "FUNC" and alertSettings.format or alertSettings.formatStr

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
        reps = (buttonDB.objective and buttonDB.objective > 0) and (newCount >= buttonDB.objective and floor(newCount / buttonDB.objective) or 0) or 0,
    }

    if alertType == "FUNC" then
        local func = loadstring("return " .. alert)
        if type(func) == "function" then
            local success, userFunc = pcall(func)
            if success and type(userFunc) == "function" then
                alert = userFunc(alertInfo, private.lists.alertColors)
            else
                return
            end
        end
    else
        alert = private:ParseAlert(alert, alertInfo)
    end

    if not barDB.alerts.completedObjectives and alertInfo.objectiveMet and not alertInfo.newObjectiveMet or not alert then
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

function private:AlertBar(widget, progress, total, newProgress, newTotal)
    local alertSettings = private.db.global.settings.alerts.bar
    local alertType = alertSettings.formatType
    local alert = alertType == "FUNC" and alertSettings.format or alertSettings.formatStr
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

    if alertType == "FUNC" then
        local func = loadstring("return " .. alert)
        if type(func) == "function" then
            local success, userFunc = pcall(func)
            if success and type(userFunc) == "function" then
                alert = userFunc(alertInfo, private.lists.alertColors)
            else
                return
            end
        end
    else
        alert = private:ParseBarAlert(alert, alertInfo)
    end

    if not barDB.alerts.completedObjectives and alertInfo.objectiveMet and not alertInfo.newObjectiveMet or not alert then
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

function private:AlertTracker(widget, trackerKey, oldCount, newCount)
    local alertSettings = private.db.global.settings.alerts.tracker
    local alertType = alertSettings.formatType
    local alert = alertType == "FUNC" and alertSettings.format or alertSettings.formatStr
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

    if alertType == "FUNC" then
        local func = loadstring("return " .. alert)
        if type(func) == "function" then
            local success, userFunc = pcall(func)
            if success and type(userFunc) == "function" then
                alert = userFunc(alertInfo, private.lists.alertColors)
            else
                return
            end
        end
    else
        alert = private:ParseTrackerAlert(alert, alertInfo)
    end

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

function private:ParseAlert(alert, alertInfo)
    local percent = alertInfo.goal and alertInfo.goal > 0 and (math.floor((alertInfo.newCount / alertInfo.goal) * 100)) or ""
    local remainder = alertInfo.goal and alertInfo.goal > 0 and (alertInfo.goal - alertInfo.newCount) or ""

    local diffColor = alertInfo.difference > 0 and "|cff00ff00" or "|cffff0000"
    local progressColor = alertInfo.goal and alertInfo.goal > 0 and (alertInfo.newCount >= alertInfo.goal and "|cff00ff00" or "|cffffcc00") or ""

    -- Replaces placeholders with data: colors come first so things like %c, %d, and %p don't get changed before colors can be evaluated
    alert = alert:gsub("%%color%%", "|r"):gsub("%%diffColor%%", diffColor):gsub("%%progressColor%%", progressColor):gsub("%%green%%", private.lists.alertColors.green):gsub("%%gold%%", private.lists.alertColors.gold):gsub("%%red%%", private.lists.alertColors.red):gsub("%%c", alertInfo.newCount):gsub("%%C", alertInfo.oldCount):gsub("%%d", (alertInfo.difference > 0 and "+" or "") .. alertInfo.difference):gsub("%%g", alertInfo.goal or ""):gsub("%%O", alertInfo.reps or 0):gsub("%%p", percent):gsub("%%r", remainder):gsub("%%t", alertInfo.title or "")

    alert = private:ParseIfStatement(alert)

    return alert
end

function private:ParseBarAlert(alert, alertInfo)
    local barIDName = L["Bar"] .. " " .. alertInfo.barID
    local barNameLong = string.format("%s%s", barIDName, alertInfo.label ~= "" and string.format(" (%s)", alertInfo.label) or "")
    local barName = alertInfo.label == "" and barIDName or alertInfo.label

    local percent = math.floor((alertInfo.newProgress / alertInfo.newTotal) * 100)
    local remainder = alertInfo.newTotal - alertInfo.newProgress

    local progressColor = alertInfo.newProgress == alertInfo.newTotal and "|cff00ff00" or "|cffffcc00"
    local diffColor = alertInfo.difference > 0 and "|cff00ff00" or "|cffff0000"

    -- -- Replaces placeholders with data: colors come first so things like %c and %p don't get changed before colors can be evaluated
    alert = alert:gsub("%%color%%", "|r"):gsub("%%diffColor%%", diffColor):gsub("%%progressColor%%", progressColor):gsub("%%green%%", private.lists.alertColors.green):gsub("%%gold%%", private.lists.alertColors.gold):gsub("%%red%%", private.lists.alertColors.red):gsub("%%b", barIDName):gsub("%%B", barNameLong):gsub("%%c", alertInfo.newProgress):gsub("%%d", (alertInfo.difference > 0 and "+" or "") .. alertInfo.difference):gsub("%%n", barName):gsub("%%p", percent):gsub("%%r", remainder):gsub("%%t", alertInfo.newTotal)

    alert = private:ParseIfStatement(alert)

    return alert
end

function private:ParseIfStatement(alert)
    -- Loop checks for multiple if statements
    while alert:find("if%%") do
        -- Replacing the end of the first loop with something different so we can narrow it down to the shortest match
        alert = alert:gsub("if%%", "!!", 1)

        -- Storing condition,text,elseText in matches table
        local matches = { alert:match("%%if%((.+),(.+),(.*)%)!!") }

        -- Evalutes the if statement and makes the replacement
        alert = alert:gsub("%%if%((.+),(.+),(.*)%)!!", assert(loadstring("return " .. matches[1]))() and matches[2] or matches[3])
    end

    return alert
end

function private:ParseTrackerAlert(alert, alertInfo)
    local percent = alertInfo.goal and (math.floor((alertInfo.newCount / alertInfo.trackerGoalTotal) * 100)) or ""
    local remainder = alertInfo.goal and (alertInfo.trackerGoalTotal - alertInfo.newCount) or ""

    local diffColor = alertInfo.difference > 0 and "|cff00ff00" or "|cffff0000"
    local progressColor = alertInfo.trackerGoal >= alertInfo.trackerGoalTotal and "|cff00ff00" or "|cffffcc00"

    -- Replaces placeholders with data: colors come first so things like %c, %d, and %p don't get changed before colors can be evaluated
    alert = alert:gsub("%%color%%", "|r"):gsub("%%diffColor%%", diffColor):gsub("%%progressColor%%", progressColor):gsub("%%green%%", private.lists.alertColors.green):gsub("%%gold%%", private.lists.alertColors.gold):gsub("%%red%%", private.lists.alertColors.red):gsub("%%c", alertInfo.newCount):gsub("%%C", alertInfo.oldCount):gsub("%%d", (alertInfo.difference > 0 and "+" or "") .. alertInfo.difference):gsub("%%g", alertInfo.goal or ""):gsub("%%G", alertInfo.trackerGoalTotal or ""):gsub("%%p", percent):gsub("%%r", remainder):gsub("%%t", alertInfo.title or ""):gsub("%%T", alertInfo.trackerName)

    alert = private:ParseIfStatement(alert)

    return alert
end

function private:PreviewAlert(Type)
    local alert = private.db.global.settings.alerts[Type]
    local alertType = alert.formatType
    if alertType == "FUNC" then
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
    else
        return (Type == "button" and private:ParseAlert(alert.formatStr, alert.alertInfo)) or (Type == "bar" and private:ParseBarAlert(alert.formatStr, alert.alertInfo)) or (Type == "tracker" and private:ParseTrackerAlert(alert.formatStr, alert.alertInfo))
    end
end

function private:ValidateAlert(Type, alert)
    if private.db.global.settings.alerts[Type].formatType == "FUNC" then
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
    else
        local success, ret = pcall(Type == "button" and private.ParseAlert or Type == "bar" and private.ParseBarAlert or Type == "tracker" and private.ParseTrackerAlert, private, alert, private.db.global.settings.alerts[Type].alertInfo)

        if success and type(ret) == "string" then
            return true
        end
    end
end
