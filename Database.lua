local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)
local db = FarmingBar.db

function addon:Initialize_DB()
    local defaults = {}
    FarmingBar.db = LibStub("AceDB-3.0"):New("FarmingBarDB", defaults, true)
end