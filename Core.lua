local addonName = ...
local addon = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

------------------------------------------------------------

LibStub("LibAddonUtils-1.0"):Embed(addon)
local ACD = LibStub("AceConfigDialog-3.0")

--*------------------------------------------------------------------------

function addon:OnInitialize()
    self.bars = {}

    self.maxButtons = 108
    self.maxButtonPadding = 20
    self.maxButtonSize = 60
    self.maxFontSize = 32
    self.maxScale = 5
    self.minButtonPadding = -3
    self.minButtonSize = 15
    self.minFontSize = 4
    self.minScale = .25
    self.moveDelay = .4
    self.OffsetX = 10
    self.OffsetY = 10

    self.tooltip_description = {1, 1, 1, 1, 1, 1, 1}
    self.tooltip_keyvalue = {1, .82, 0, 1, 1, 1, 1}

    self.barProgress = "%B progress: %progressColor%%c/%t%color%%if(%p>0, (%p%%),)if%"
    self.withObjective = "%if(%p>=100 and %C<%o,Objective complete!,Farming update:)if% %t %progressColor%%c/%o%color% (%if(%O>1,x%O ,)if%%diffColor%%d%color%)"
    self.withoutObjective = "Farming update: %t x%c (%diffColor%%d%color%)"

    ------------------------------------------------------------

    self:InitializeDB()
    self:RegisterSlashCommands()
end

------------------------------------------------------------

function addon:OnEnable()
    self:InitializeBars()
    addon:InitializeDragFrame()
    addon:InitializeOptions()
end

------------------------------------------------------------

function addon:OnDisable()
end

--*------------------------------------------------------------------------

function addon:RegisterSlashCommands()
    for command, enabled in pairs(self:GetDBValue("global", "settings.commands")) do
        if enabled then
            self:RegisterChatCommand(command, "SlashCommandFunc")
        else
            self:UnregisterChatCommand(command)
        end
    end
end

------------------------------------------------------------

function addon:SlashCommandFunc(input)
    ACD:Open(addonName)
end

--*------------------------------------------------------------------------

-- https://forum.cockos.com/showthread.php?t=221712
function addon:CloneTable(orig)
    local copy
    if type(orig) == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[self:CloneTable(orig_key)] = self:CloneTable(orig_value)
        end
        setmetatable(copy, self:CloneTable(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

------------------------------------------------------------

function addon:GetModifierString()
    local mod = ""
    if IsShiftKeyDown() then
        mod = "shift"
    end
    if IsControlKeyDown() then
        mod = "ctrl"..(mod ~= "" and "-" or "")..mod
    end
    if IsAltKeyDown() then
        mod = "alt"..(mod ~= "" and "-" or "")..mod
    end
    return mod
end