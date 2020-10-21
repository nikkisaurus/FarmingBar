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
                fb = true, -- DEBUG
            },
            hints = {
                bars = true,
                buttons = true,
                ObjectiveBuilder = true,
            },
            debug = {
                ObjectiveBuilder = true,
                ObjectiveBuilderTrackers = false,
                ObjectiveBuilderCondition = false,
            },

            objectives = {},
        },
    }

    FarmingBar.db = LibStub("AceDB-3.0"):New("FarmingBarDB", defaults, true)
end