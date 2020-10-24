local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):NewAddon("FarmingBar", "AceConsole-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

local pairs, wipe = pairs, table.wipe
local strupper = string.upper

--*------------------------------------------------------------------------

function FarmingBar:OnInitialize()
    LibStub("LibAddonUtils-1.0"):Embed(addon)

    ------------------------------------------------------------

    addon.bars = {}

    addon.maxButtons = 100
    addon.maxButtonPadding = 20
    addon.maxButtonSize = 60
    addon.maxFontSize = 32
    addon.maxScale = 5
    addon.minButtonPadding = -3
    addon.minButtonSize = 15
    addon.minFontSize = 4
    addon.minScale = .25
    addon.moveDelay = .4
    addon.OffsetX = 10
    addon.OffsetY = 10

    addon.tooltip_description = {1, 1, 1, 1, 1, 1, 1}
    addon.tooltip_keyvalue = {1, .82, 0, 1, 1, 1, 1}

    addon.barProgress = "%B progress: %progressColor%%c/%t%color%%if(%p>0, (%p%%),)if%"
    addon.withObjective = "%if(%p>=100 and %C<%o,Objective complete!,Farming update:)if% %n %progressColor%%c/%o%color% (%if(%O>1,x%O ,)if%%diffColor%%d%color%)"
    addon.withoutObjective = "Farming update: %n x%c (%diffColor%%d%color%)"

    ------------------------------------------------------------

    addon:Initialize_DB()
    for command, enabled in pairs(FarmingBar.db.global.commands) do
        if enabled then
            self:RegisterChatCommand(command, "SlashCommandFunc")
        end
    end
end

function FarmingBar:OnEnable()
    addon:Initialize_ObjectiveBuilder()
    addon:Initialize_Masque()
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