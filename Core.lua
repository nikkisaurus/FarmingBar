local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):NewAddon("FarmingBar", "AceConsole-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

local pairs, wipe = pairs, table.wipe
local strupper = string.upper

--*------------------------------------------------------------------------

function FarmingBar:OnInitialize()
    LibStub("LibAddonUtils-1.0"):Embed(addon)

    ------------------------------------------------------------

    addon:Initialize_DB()
    for command, enabled in pairs(FarmingBar.db.global.commands) do
        if enabled then
            self:RegisterChatCommand(command, "SlashCommandFunc")
        end
    end

    ------------------------------------------------------------

    addon.tooltip_description = {1, 1, 1, 1, 1, 1, 1}
    addon.tooltip_keyvalue = {1, .82, 0, 1, 1, 1, 1}
end

function FarmingBar:OnEnable()
    addon:Initialize_ObjectiveBuilder()
    addon:Initialize_Bars()
    -- TODO: addon:Initialize_Options()
end

function FarmingBar:OnDisable()
    addon.ObjectiveBuilder:Release()
    -- TODO: addon:ReleaseBars()
    -- TODO: addon.Options:Release()
end

--*------------------------------------------------------------------------

function FarmingBar:SlashCommandFunc(input)
    if strupper(input) == "BUILD" then
        addon.ObjectiveBuilder:Load()
    end
end

--*------------------------------------------------------------------------

function addon:ReportError(error)
    PlaySound(846) -- "sound/interface/igquestfailed.ogg" classic?
    FarmingBar:Print(string.format("%s %s", self.ColorFontString(L["Error"], "red"), error))
end

------------------------------------------------------------

local missing = {}
function addon:IsDataStoreLoaded()
    wipe(missing)

    if not IsAddOnLoaded("DataStore") then
        tinsert(missing, "DataStore")
    end

    if not IsAddOnLoaded("DataStore_Auctions") then
        tinsert(missing, "DataStore_Auctions")
    end

    if not IsAddOnLoaded("DataStore_Containers") then
        tinsert(missing, "DataStore_Containers")
    end

    if not IsAddOnLoaded("DataStore_Inventory") then
        tinsert(missing, "DataStore_Inventory")
    end

    if not IsAddOnLoaded("DataStore_Mails") then
        tinsert(missing, "DataStore_Mails")
    end

    return missing
end