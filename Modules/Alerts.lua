local addonName = ...
local addon = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

-- Optional libraries
local LSM = LibStub("LibSharedMedia-3.0")

-- *------------------------------------------------------------------------

function addon:PreviewBarAlert(input)
    local barIDName = format("%s %s", L["Bar"], 1)
    local progressCount = self:GetDBValue("global", "settings.alerts.bar.preview.count")
    local progressTotal = self:GetDBValue("global", "settings.alerts.bar.preview.total")
    local alertType = self:GetDBValue("global", "settings.alerts.bar.preview.alertType")

    local alertInfo = {
        progressCount = progressCount,
        progressTotal = progressTotal,
        barIDName = barIDName,
        barNameLong = format("%s (%s)", barIDName, L["My Bar Name"]),
        progressColor = (progressCount == progressTotal and alertType ~= "lost") and "|cff00ff00" or alertType == "complete" and "|cffffcc00" or alertType == "lost" and "|cffff0000",
    }

    if alertType == "complete" and progressCount == 0 then
        return ""
    elseif progressTotal < progressCount then
        return format("%s: %s", L.Error, L.InvalidBarPreviewTotal)
    else
        local func, err = loadstring("return " .. (input or self:GetDBValue("global", "settings.alerts.bar.format.progress") or ""))
        local success, error = pcall(func, addon, alertInfo)

        -- Syntax error
        if not success then
            return L.invalidSyntax(error), true
        elseif not assert(func)() then 
            return L.InvalidFunction, true
        elseif not assert(func)()(alertInfo) or type(assert(func)()(alertInfo)) ~= "string" then
            return L.InvalidReturn, true
        else
            return "|cffffffff" .. assert(func)()(alertInfo) .. "|r"
        end
    end
end


function addon:PreviewAlert(input, info)
    local objective = self:GetDBValue("global", "settings.alerts.button.preview.objective")
    local oldCount = self:GetDBValue("global", "settings.alerts.button.preview.oldCount")
    local newCount = self:GetDBValue("global", "settings.alerts.button.preview.newCount")
    local difference = newCount - oldCount

    local alertInfo = {
        objectiveTitle = L["Hearthstone"],
        objective = {
            color = (objective and objective > 0) and
                (newCount >= objective and "|cff00ff00" or "|cffffcc00") or "",
            count = objective
        },
        oldCount = oldCount,
        newCount = newCount,
        difference = {
            sign = difference > 0 and "+" or difference < 0 and "",
            color = difference > 0 and "|cff00ff00" or difference < 0 and "|cffff0000",
            count = difference
        }
    }
    
    local func, err = loadstring("return " .. (input or self:GetDBValue(info[1], info[2]) or ""))
    local success, error = pcall(func, addon, alertInfo)

    -- Syntax error
    if not success then
        return L.invalidSyntax(error), true
    elseif not assert(func)() then 
        return L.InvalidFunction, true
    elseif not assert(func)()(alertInfo) or type(assert(func)()(alertInfo)) ~= "string" then
        return L.InvalidReturn, true
    else
        return "|cffffffff" .. assert(func)()(alertInfo) .. "|r"
    end
end

function addon:SendAlert(alertType, alert, alertInfo, soundID, bar, isTracker, barAlert)
    local barDB = self:GetDBValue("char", "bars")[bar:GetBarID()]

    -- Return if tracking completed objectives is disabled
    local objective = isTracker and alertInfo.trackerObjective.count or alertInfo.objective.count
    local oldCount = isTracker and alertInfo.oldTrackerCount or alertInfo.oldCount
    local newCount = isTracker and alertInfo.newTrackerCount or alertInfo.newCount

    local newCompletion = oldCount < objective and newCount > objective
    local lostCompletion = oldCount > objective and newCount < objective
    if not barDB.alerts.completedObjectives and not newCompletion and not lostCompletion then
        return
    end

    -- Send alert
    local parsedAlert = assert(loadstring("return " .. alert))()(alertInfo)

    -- Chat
    if self:GetDBValue("global", "settings.alerts")[alertType].chat and alert then
        self:Print(parsedAlert)
    end

    -- Screen
    if self:GetDBValue("global", "settings.alerts")[alertType].screen and alert then
        -- if not self.CoroutineUpdater:IsVisible() then
        UIErrorsFrame:AddMessage(parsedAlert, 1, 1, 1)
        -- else
        --     self.CoroutineUpdater.alert:SetText(parsedAlert)
        -- end
    end

    -- Sound
    if self:GetDBValue("global", "settings.alerts")[alertType].sound.enabled and soundID then
        PlaySoundFile(LSM:Fetch("sound", self:GetDBValue("global", "settings.alerts.button.sound")[soundID]))
    end

    if not isTracker then
        bar:AlertProgress(bar, barAlert)
    end
end
