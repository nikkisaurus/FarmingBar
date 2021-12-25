local addonName = ...
local addon = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)


-- Optional libraries
local LSM = LibStub("LibSharedMedia-3.0")


--*------------------------------------------------------------------------
-- Send alerts


function addon:SendAlert(alertType, alert, alertInfo, soundID, bar, isTracker)
    -- Return if tracking completed objectives is disabled
    local objective = isTracker and alertInfo.trackerObjective.count or alertInfo.objective.count
    local oldCount = isTracker and alertInfo.oldTrackerCount or alertInfo.oldCount
    local newCount = isTracker and alertInfo.newTrackerCount or alertInfo.newCount
    local completedObjectives = self:GetDBValue("char", "bars")[bar:GetBarID()].alerts.completedObjectives

    local newCompletion = oldCount < objective and newCount > objective
    local lostCompletion = oldCount > objective and newCount < objective
    if not completedObjectives and not newCompletion and not lostCompletion then return end

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
end