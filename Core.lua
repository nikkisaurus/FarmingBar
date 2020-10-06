local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):NewAddon("FarmingBar", "AceConsole-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

local pairs = pairs
local strupper = strupper

--*------------------------------------------------------------------------

function FarmingBar:OnInitialize()
    LibStub("LibAddonUtils-1.0"):Embed(addon)

    addon:Initialize_DB()
    for command, enabled in pairs(FarmingBar.db.global.commands) do
        if enabled then
            self:RegisterChatCommand(command, "SlashCommandFunc")
        end
    end
end

function FarmingBar:OnEnable()
    addon:Initialize_ObjectiveBuilder()
    -- addon:Initialize_Bars()
    -- addon:Initialize_Options()
end

function FarmingBar:OnDisable()
    addon.ObjectiveBuilder:Release()
    -- addon:ReleaseBars()
    -- addon.Options:Release()
end

--*------------------------------------------------------------------------

function FarmingBar:SlashCommandFunc(input)
    --Debug--------------------------------------
    if FarmingBar.db.global.debug.ObjectiveBuilder and strupper(input) == "BUILD" then
        addon.ObjectiveBuilder:Load()
    end
    ---------------------------------------------
end