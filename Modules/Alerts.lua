local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)

function private:Alert(Type, widget, oldCount)
    local barDB, buttonDB = widget:GetDB()
    local barID, buttonID = widget:GetID()
    local bar = private.bars[barID]

    if not widget.frame:IsVisible() or barDB.alerts.muteAll or (Type == "bar" and not barDB.alerts.barProgress) then
        return
    end

    local alertSettings = private.db.global.settings.alerts[Type]
    local alert = alertSettings.format
    local alertInfo = {}

    if buttonID then
        if widget:IsEmpty() then
            return
        end

        local newCount = private:GetObjectiveWidgetCount(widget)

        alertInfo = {
            title = buttonDB.title,
            oldCount = oldCount,
            newCount = newCount,
            difference = newCount - oldCount,
            lost = oldCount > newCount,
            gained = oldCount < newCount,
            objective = buttonDB.objective,
            objectiveMet = newCount >= buttonDB.objective,
            newObjectiveMet = oldCount < buttonDB.objective,
            reps = newCount >= buttonDB.objective and floor(newCount / buttonDB.objective) or 0,
        }

        if oldCount == newCount then
            return
        end
    end

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
                addon:Print(alert)
            end

            if alertSettings.screen then
                UIErrorsFrame:AddMessage(alert, 1, 1, 1)
            end

            if alertSettings.sound then
                -- play sound
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
