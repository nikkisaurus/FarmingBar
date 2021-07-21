local addonName = ...
local addon = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)


-- Optional libraries
local ACD = LibStub("AceConfigDialog-3.0")
local LSM = LibStub("LibSharedMedia-3.0")
LibStub("LibAddonUtils-1.0"):Embed(addon)


--*------------------------------------------------------------------------
-- Addon functions


function addon:OnInitialize()
    -- Create bar container
    self.bars = {}

    -- Set addon defaults
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


    -- Register sounds
    --@retail@
    LSM:Register("sound", L["Auction Open"], 567482) -- id:5274
    LSM:Register("sound", L["Auction Close"], 567499) -- id:5275
    LSM:Register("sound", L["Loot Coin"], 567428) -- id:120
    LSM:Register("sound", L["Quest Activate"], 567400) -- id:618
    LSM:Register("sound", L["Quest Complete"], 567439) -- id:878
    LSM:Register("sound", L["Quest Failed"], 567459) -- id:846
    --@end-retail@
    --[===[@non-retail@
    LSM:Register("sound", L["Auction Open"], "sound/interface/auctionwindowopen.ogg") -- id:5274
    LSM:Register("sound", L["Auction Close"], "sound/interface/auctionwindowclose.ogg") -- id:5275
    LSM:Register("sound", L["Loot Coin"], "sound/interface/lootcoinsmall.ogg") -- id:120
    LSM:Register("sound", L["Quest Activate"], "sound/interface/iquestactivate.ogg") -- id:618
    LSM:Register("sound", L["Quest Complete"], "sound/interface/iquestcomplete.ogg") -- id:878
    LSM:Register("sound", L["Quest Failed"], "sound/interface/igquestfailed.ogg") -- id:846
    --@end-non-retail@]===]


    -- Initialize database and slash commands
    self:InitializeDB()
    self:RegisterSlashCommands()
end


function addon:OnEnable()
    -- addon:Initialize_Masque()
    addon:InitializeBars()
    addon:InitializeDragFrame()
    addon:InitializeOptions()
    -- addon:ClearDeletedObjectives()
end


function addon:OnDisable()

end


function addon:OnProfile_(...)
     self:ReleaseAllBars()
     self:InitializeBars()
end


function addon:RegisterSlashCommands()
    for command, enabled in pairs(self:GetDBValue("global", "settings.commands")) do
        if enabled then
            self:RegisterChatCommand(command, "SlashCommandFunc")
        else
            self:UnregisterChatCommand(command)
        end
    end
end


function addon:SlashCommandFunc(input)
    local cmd, arg, arg2 = strsplit(" ", strupper(input))
    if cmd == "BUILD" then
        addon.ObjectiveBuilder:Load()
    elseif cmd == "BAR" then
        if arg == "ADD" then
            addon:CreateBar()
        elseif arg == "REMOVE" then
            local arg2 = tonumber(arg2)
            if addon.bars[arg2] then
                addon:SetBarDisabled(arg2)
            end
        end
    elseif cmd == "CONFIG" then
        local arg = tonumber(arg)
        ACD:SelectGroup(addonName, "config", addon.bars[arg] and "bar"..arg)
        ACD:Open(addonName)
    else
        LibStub("AceConfigDialog-3.0"):Open(addonName)
        self:Print([[Currently available commands: "build", "bar add", "bar remove barID", "config"]])
    end
end


function addon:ReportError(error)
    PlaySound(846) -- "sound/interface/igquestfailed.ogg" classic?
    addon:Print(string.format("%s %s", self.ColorFontString(L["Error"], "red"), error))
end


--*------------------------------------------------------------------------
-- Core functions


function addon:CloneTable(orig)
    -- https://forum.cockos.com/showthread.php?t=221712
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