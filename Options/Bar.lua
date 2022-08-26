local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)

function private:GetBarOptions()
    local options = {
        general = {
            order = 1,
            type = "group",
            childGroups = "tab",
            name = L["General"],
            args = {},
        },
        apperance = {
            order = 2,
            type = "group",
            childGroups = "tab",
            name = L["Appearance"],
            args = {},
        },
        layout = {
            order = 3,
            type = "group",
            childGroups = "tab",
            name = L["Layout"],
            args = {},
        },
    }

    return options
end
