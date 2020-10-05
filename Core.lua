local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):NewAddon("FarmingBar", "AceConsole-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)
local db = FarmingBar.db

function FarmingBar:OnInitialize()
    addon:InitializeDB()
    self:RegisterChatCommand("farmingbar", "SlashCommandFunc")

    LibStub("LibAddonUtils-1.0"):Embed(addon)
end

function FarmingBar:OnEnable()
end

function FarmingBar:OnDisable()
end

function FarmingBar:SlashCommandFunc(input)
end