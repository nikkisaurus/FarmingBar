local addonName = ...
local addon = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

------------------------------------------------------------

local floor = math.floor
local gsub = string.gsub

--*------------------------------------------------------------------------

function addon:ParseAlert(alert, alertInfo)
    local objectiveReps = alertInfo.objective and floor(alertInfo.newCount / alertInfo.objective) or ""
    local percent = alertInfo.objective and (floor((alertInfo.newCount / alertInfo.objective) * 100)) or ""
    local remainder =  alertInfo.objective and (alertInfo.objective - alertInfo.newCount) or ""

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

    alert = self:ParseIfStatement(alert)

    return alert
end

------------------------------------------------------------

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