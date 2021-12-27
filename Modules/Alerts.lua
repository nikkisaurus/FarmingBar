local addonName = ...
local addon = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

-- Optional libraries
local LSM = LibStub("LibSharedMedia-3.0")

-- *------------------------------------------------------------------------

function addon:PreviewBarAlert()
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
        return "|cffffffff" .. assert(loadstring("return " .. self:GetDBValue("global", "settings.alerts.bar.format.progress")))()(alertInfo) .. "|r"
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
