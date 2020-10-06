local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

function addon:Initialize_DB()
    local defaults = {
        global = {
            enabled = true,
            commands = {
                farmingbar = true,
                farmbar = true,
                farm = true,
                fbar = true,
                fb = false,
            },
            debug = {
                ObjectiveBuilder = true,
            },

            objectives = {},
        },
    }
    FarmingBar.db = LibStub("AceDB-3.0"):New("FarmingBarDB", defaults, true)
end