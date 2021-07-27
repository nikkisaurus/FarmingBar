local addonName = ...
local addon = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)


-- Optional libraries
local LSM = LibStub("LibSharedMedia-3.0")


--*------------------------------------------------------------------------
-- Parse alerts

function addon:ParseAlert(alert, alertInfo)
    -- Info
    local objectiveReps = alertInfo.objective and floor(alertInfo.newCount / alertInfo.objective) or ""
    local percent = alertInfo.objective and (floor((alertInfo.newCount / alertInfo.objective) * 100)) or ""
    local remainder =  alertInfo.objective and (alertInfo.objective - alertInfo.newCount) or ""

    -- Colors
    local diffColor = alertInfo.difference > 0 and "|cff00ff00" or "|cffff0000"
    local progressColor = alertInfo.objective and (alertInfo.newCount >= alertInfo.objective and "|cff00ff00" or "|cffffcc00") or ""

    -- Replaces placeholders with data: colors come first so things like %c, %d, and %p don't get changed before colors can be evaluated
    alert = gsub(alert, "%%color%%", "|r")
    alert = gsub(alert, "%%diffColor%%", diffColor)
    alert = gsub(alert, "%%progressColor%%", progressColor)
    alert = gsub(alert, "%%c", alertInfo.newCount)
    alert = gsub(alert, "%%C", alertInfo.oldCount)
    alert = gsub(alert, "%%d", (alertInfo.difference > 0 and "+" or "") .. alertInfo.difference)
    alert = gsub(alert, "%%o", alertInfo.objective or "")
    alert = gsub(alert, "%%O", objectiveReps)
    alert = gsub(alert, "%%p", percent)
    alert = gsub(alert, "%%r", remainder)
    alert = gsub(alert, "%%t", alertInfo.objectiveTitle or "")
    alert = gsub(alert, "%%T", alertInfo.trackerTitle or "")
    alert = gsub(alert, "%%R", alertInfo.trackerObjective or "")

    -- If statements
    alert = self:ParseIfStatement(alert)

    return alert
end


function addon:ParseIfStatement(alert)
    -- Loop checks for multiple if statements
    while alert:find("if%%") do
        -- Replacing the end of the first loop with something different so we can narrow it down to the shortest match
        alert = gsub(alert, "if%%", "!!", 1)

        -- Storing condition,text,elseText in matches table
        local matches = {alert:match("%%if%((.+),(.+),(.*)%)!!")}

        -- Evalutes the if statement and makes the replacement
        alert = gsub(alert, "%%if%((.+),(.+),(.*)%)!!", assert(loadstring("return " .. matches[1]))() and matches[2] or matches[3])
    end

    return alert
end


--*------------------------------------------------------------------------
-- Send alerts


function addon:SendAlert(alertType, alert, alertInfo, soundID)
    if self:GetDBValue("global", "settings.alerts")[alertType].chat and alert then
        self:Print(self:ParseAlert(alert, alertInfo))
    end

    if self:GetDBValue("global", "settings.alerts")[alertType].screen and alert then
        -- if not self.CoroutineUpdater:IsVisible() then
            UIErrorsFrame:AddMessage(self:ParseAlert(alert, alertInfo), 1, 1, 1)
        -- else
        --     self.CoroutineUpdater.alert:SetText(self:ParseAlert(alert, alertInfo))
        -- end
    end

    if self:GetDBValue("global", "settings.alerts")[alertType].sound.enabled and soundID then
        PlaySoundFile(LSM:Fetch("sound", self:GetDBValue("global", "settings.alerts.button.sound")[soundID]))
    end
end