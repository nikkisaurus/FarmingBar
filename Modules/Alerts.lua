local addonName = ...
local addon = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)


-- Optional libraries
local LSM = LibStub("LibSharedMedia-3.0")


--*------------------------------------------------------------------------
-- Send alerts


function addon:SendAlert(alertType, alert, alertInfo, soundID)
    local parsedAlert = assert(loadstring("return " .. alert))()(alertInfo)

    if self:GetDBValue("global", "settings.alerts")[alertType].chat and alert then
        self:Print(parsedAlert)
    end

    if self:GetDBValue("global", "settings.alerts")[alertType].screen and alert then
        -- if not self.CoroutineUpdater:IsVisible() then
            UIErrorsFrame:AddMessage(parsedAlert, 1, 1, 1)
        -- else
        --     self.CoroutineUpdater.alert:SetText(parsedAlert)
        -- end
    end

    if self:GetDBValue("global", "settings.alerts")[alertType].sound.enabled and soundID then
        PlaySoundFile(LSM:Fetch("sound", self:GetDBValue("global", "settings.alerts.button.sound")[soundID]))
    end
end