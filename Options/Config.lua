local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)

function private:GetConfigOptions()
    local options = {}

    for barID, bar in pairs(private.db.profile.bars) do
        options["bar" .. barID] = {
            order = barID,
            type = "group",
            childGroups = "tab",
            name = private:GetBarName(barID),
            args = private:GetBarOptions(barID),
        }
    end

    return options
end
