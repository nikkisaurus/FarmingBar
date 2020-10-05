local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):NewAddon("FarmingBar", "AceConsole-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)
local db = FarmingBar.db

function FarmingBar:OnInitialize()
    addon:Initialize_DB()
    self:RegisterChatCommand("farmingbar", "SlashCommandFunc")
    LibStub("LibAddonUtils-1.0"):Embed(addon)
end

function FarmingBar:OnEnable()
    addon:Initialize_ObjectiveBuilder()
    -- addon:Initialize_Bars()
    -- addon:Initialize_Options()
end

function FarmingBar:OnDisable()
    addon.ObjectiveBuilder:Release()
    -- addon:ReleaseBars()
end

function FarmingBar:SlashCommandFunc(input)
    if strupper(input) == "BUILD" then
        addon.ObjectiveBuilder:Load()
    end
end