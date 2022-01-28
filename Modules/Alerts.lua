local addonName = ...
local addon = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

-- Optional libraries
local LSM = LibStub("LibSharedMedia-3.0")

-- *------------------------------------------------------------------------

function addon:InitializeAlerts()
    self.alerts = {
        bar = {
            progress = loadstring("return " .. self:GetDBValue("global", "settings.alerts.bar.format.progress"))
        },
        button = {
            withObjective = loadstring(
                "return " .. self:GetDBValue("global", "settings.alerts.button.format.withObjective")
            ),
            withoutObjective = loadstring(
                "return " .. self:GetDBValue("global", "settings.alerts.button.format.withoutObjective")
            )
        },
        tracker = {
            progress = loadstring("return " .. self:GetDBValue("global", "settings.alerts.tracker.format.progress"))
        }
    }
end

function addon:UpdateAlert(alertType, alert, input)
    if addon.alerts[alertType] and addon.alerts[alertType][alert] and input then
        addon.alerts[alertType][alert] = loadstring("return " .. input)
    end
end

function addon:PreviewAlert(alertType, input, info)
    local alertInfo

    -- Setup alertInfo
    if alertType == "bar" then
        local barIDName = format("%s %s", L["Bar"], 1)
        local progressCount = self:GetDBValue("global", "settings.alerts.bar.preview.count")
        local progressTotal = self:GetDBValue("global", "settings.alerts.bar.preview.total")
        local alertType = self:GetDBValue("global", "settings.alerts.bar.preview.alertType")

        alertInfo = {
            progressCount = progressCount,
            progressTotal = progressTotal,
            barIDName = barIDName,
            barNameLong = format("%s (%s)", barIDName, L["My Bar Name"]),
            progressColor = (progressCount == progressTotal and alertType ~= "lost") and "|cff00ff00" or
                alertType == "complete" and "|cffffcc00" or
                alertType == "lost" and "|cffff0000",
            difference = {
                sign = alertType == "lost" and "-" or "+",
                color = alertType == "lost" and "|cffff0000" or "|cff00ff00"
            }
        }
    elseif alertType == "button" then
        local objective = self:GetDBValue("global", "settings.alerts.button.preview.objective")
        local oldCount = self:GetDBValue("global", "settings.alerts.button.preview.oldCount")
        local newCount = self:GetDBValue("global", "settings.alerts.button.preview.newCount")
        local difference = newCount - oldCount

        alertInfo = {
            objectiveTitle = L["Hearthstone"],
            objective = {
                color = (objective and objective > 0) and (newCount >= objective and "|cff00ff00" or "|cffffcc00") or "",
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
    elseif alertType == "tracker" then
        local oldTrackerCount = self:GetDBValue("global", "settings.alerts.tracker.preview.oldCount")
        local newTrackerCount = self:GetDBValue("global", "settings.alerts.tracker.preview.newCount")
        local trackerObjective = self:GetDBValue("global", "settings.alerts.tracker.preview.objective")
        local oldCount = self:GetDBValue("global", "settings.alerts.tracker.preview.objectiveInfo.oldCount")
        local newCount = self:GetDBValue("global", "settings.alerts.tracker.preview.objectiveInfo.newCount")
        local objective = self:GetDBValue("global", "settings.alerts.tracker.preview.objectiveInfo.objective")
        local difference, trackerDifference = newCount - oldCount, newTrackerCount - oldTrackerCount

        alertInfo = {
            objectiveTitle = L["Hearthstones"],
            trackerTitle = L["Hearthstone"],
            objective = {
                color = (objective and objective > 0) and (newCount >= objective and "|cff00ff00" or "|cffffcc00") or "",
                count = objective
            },
            trackerObjective = {
                color = newTrackerCount >=
                    ((objective and objective > 0) and objective * trackerObjective or trackerObjective) and
                    "|cff00ff00" or
                    "|cffffcc00",
                count = (objective and objective > 0) and objective * trackerObjective or trackerObjective
            },
            oldTrackerCount = oldTrackerCount,
            newTrackerCount = newTrackerCount,
            trackerDifference = {
                sign = trackerDifference > 0 and "+" or trackerDifference < 0 and "",
                color = trackerDifference > 0 and "|cff00ff00" or trackerDifference < 0 and "|cffff0000",
                count = trackerDifference
            }
        }
    else
        return
    end

    input = input or self:GetDBValue(info[1], info[2]) or ""

    -- Validate alert
    -- Transform the string into a function
    -- "return function(info) return "" end" -> local userFunc = function(info) return "" end
    local userFunc, err = loadstring("return " .. input)
    if not userFunc then
        return L.InvalidSyntax(err), true
    end

    -- Verify that userFunc is actually a valid function
    -- local userParseFunc = userFunc(alertInfo)
    local success, userParseFunc = pcall(userFunc, alertInfo)
    if not success then
        return L.InvalidSyntax(userParseFunc), true
    elseif type(userParseFunc) ~= "function" then
        return L.InvalidFunction, true
    end

    -- Get the parsed string from userFunc
    local success, ret = pcall(userParseFunc, alertInfo)

    if not success then
        return L.InvalidSyntax(ret), true
    elseif type(ret) ~= "string" then
        return L.InvalidReturn, true
    else
        return "|cffffffff" .. ret .. "|r"
    end
end

function addon:SendAlert(bar, alertType, alert, alertInfo, soundID, isTracker)
    -- Validate format func
    local success, formatFunc = pcall(addon.alerts[alertType][alert])
    if not success then
        return
    end

    local alertSettings = addon:GetDBValue("global", "settings.alerts")[alertType]

    -- Get parsed alert
    local parsedAlert = formatFunc(alertInfo)
    if parsedAlert then
        -- Send alert
        if alertSettings.chat then
            self:Print(parsedAlert)
        elseif alertSettings.screen then
            UIErrorsFrame:AddMessage(parsedAlert, 1, 1, 1)
        end
    end

    -- Send sound alert
    local barDB = bar:GetBarCharDB()
    local newCompletion =
        (alertInfo.objective.count or 0) and (alertInfo.newCount or 0) > (alertInfo.objective.count or 0) and
        (alertInfo.oldCount or 0) < (alertInfo.objective.count or 0)
    local showBarAlert = barDB.alerts.barProgress and barDB.alerts.completedObjectives

    if alertSettings.sound.enabled and soundID and not (newCompletion and showBarAlert) then
        PlaySoundFile(LSM:Fetch("sound", alertSettings.sound[soundID]))
    else
        -- Get bar progress info
        local objective = not isTracker and alertInfo.objective.count
        local oldCount = not isTracker and alertInfo.oldCount
        local newCount = not isTracker and alertInfo.newCount
        local newCompletion = oldCount < objective and newCount > objective
        local lostCompletion = oldCount > objective and newCount < objective

        bar:AlertProgress("progress", (newCompletion and "complete") or (lostCompletion and "lost"))
    end
end
