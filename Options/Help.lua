local addonName = ...
local addon = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

------------------------------------------------------------

local strsub, strupper = string.sub, string.upper

--*------------------------------------------------------------------------

local categories = {
    alerts = L["Alerts"],
    commands = L["Commands"],
    objectives = L["Objectives"],
    templates = L["Templates"],
}

--*------------------------------------------------------------------------

function addon:GetHelpOptions()
    local options = {}

    options.general = {
        type = "description",
        name = L.Options_Help,
    }

    local i = 1
    for key, name in pairs(categories) do
        options[key] = {
            order = i,
            type = "group",
            name = name,
            args = {
                [key] = {
                    type = "description",
                    name = L["Options_Help_"..strupper(strsub(key, 1, 1))..strsub(key, 2)],
                }
            },
        }
        i = i + 1
    end

    return options
end