local addonName = ...
local U = LibStub("LibAddonUtils-1.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)
local addon = LibStub("AceAddon-3.0"):NewAddon(L.addonName, "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")
local ACD = LibStub("AceConfigDialog-3.0")
local LSM = LibStub("LibSharedMedia-3.0")

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function addon:OnEnable()
    -- Load modules and bars
    self:CreateObjectiveBuilder()
    self:CreateCoFrame()
    self:LoadBars()
    self:CreateDataObject()

    --  Check for Masque
    local MSQ, MSQVersion = LibStub("Masque", true)

    if MSQ then
        self.MSQ = true

        if MSQVersion < 80200 then
            MSQ = nil
            self:Print(L.MasqueUpgrade)
        else
            self.masque = {}
            self.masque.anchor = MSQ:Group(L.addonName, "Anchor")
            self.masque.button = MSQ:Group(L.addonName, "Button")

            -- Update skin when Masque is disabled
            self.masque.button:SetCallback(function(...)
                local disabled = select(7, ...)

                if disabled then
                    self:UpdateSkin()
                end
            end)

            self:UpdateMasque()
        end
    end
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function addon:OnInitialize()
    local oldDB, oldCharDB

    if FarmingBarDB and FarmingBarDB.cache then
        -- For some reason I didn't code a version into the original db, so I need to check for this to find out if it's version 1
        oldDB = FarmingBarDB
        FarmingBarDB = nil
    end

    if FarmingBarCharacterDB then
        -- This should only ever show up for version 1 since I've switched to AceDB for version 2
        oldCharDB = FarmingBarCharacterDB
        FarmingBarCharacterDB = nil
    end

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- Setup defaults


    self.bars = {}
    self.maxButtons = 100
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

    self.barProgress = "%B progress: %progressColor%%c/%t%color%%if(%p>0, (%p%%),)if%"
    self.hasObjective = "%if(%p>=100 and %C<%o,Objective complete!,Farming update:)if% %n %progressColor%%c/%o%color% (%if(%O>1,x%O ,)if%%diffColor%%d%color%)"
    self.noObjective = "Farming update: %n x%c (%diffColor%%d%color%)"

    -- Set up database
    local defaults = {
        char = {
            numBars = 1,
            bars = {
                ["**"] = {
                    enabled = false,
                    desc = "",

                    movable = true,
                    hidden = false,
                    mouseover = false,
                    anchorMouseover = false,
                    showEmpties = true,

                    muteAlerts = false,
                    trackProgress = false,
                    trackCompletedObjectives = true,

                    visibleButtons = 6,
                    direction = 2, -- 1: Up, 2: Right, 3: Down, 4: Left
                    buttonsPerRow = 12,
                    rowDirection = 1, -- 1: Normal (Right/Down), 2: Reverse (Left/Up)

                    alpha = 1,
                    scale = 1,

                    position = {"TOP"},

                    buttonSize = 35,
                    buttonPadding = 2,

                    font = {
                        face = false,
                        outline = false,
                        size = false,
                    },

                    count = {
                        anchor = "BOTTOM",
                        xOffset = 1,
                        yOffset = 6,
                    },

                    objective = {
                        anchor = "TOPLEFT",
                        xOffset = 6,
                        yOffset = -4,
                    },

                    objectives = {
                        ["**"] = {
                            objective = false,
                        },
                    },
                },
            },
        },
        global = {
            autoLootItems = false,
            alerts = {
                barChat = true,
                barScreen = true,
                barSound = true,
                chat = true,
                screen = true,
                sound = true,
                chatFrame = (DEFAULT_CHAT_FRAME:GetName()),
            },
            alertFormats = {
                objectivePreview = 200,
                newCountPreview = 25,
                oldCountPreview = 20,
                barCountPreview = 1,
                barTotalPreview = 5,
                barTitlePreview = true,

                barProgress = self.barProgress,
                hasObjective = self.hasObjective,
                noObjective = self.noObjective,
            },
            commands = {
                farmbar = true,
                farm = true,
                fbar = true,
                fb = false,
            },
            sounds = {
                barProgress = "Auction Open",
                barComplete = "Auction Close",
                farmingProgress = "Loot Coin",
                objectiveComplete = "Quest Complete",
                objectiveSet = "Quest Activate",
                objectiveCleared = "Quest Failed",
            },
            template = {
                includeData = false,
                includeDataPrompt = false,
                saveOrder = false,
                saveOrderPrompt = false,
            },
            tooltips = {
                bar = true,
                barTips = true,
                button = true,
                buttonTips = true,
                enableMod = true,
                mod = "Alt",
            },
            skins = {},
            templates = {},
            version = 2,
        },
        profile = {
            style = {
                font = {
                    face = "Friz Quadrata TT",
                    outline = "OUTLINE",
                    size = 11,
                },
                skin = {
                    type = "builtin",
                    name = "default",
                },
                layers = {
                    AutoCastable = true, -- bank overlay
                    Border = false, -- oGlow
                    Cooldown = false,
                    CooldownEdge = false,
                },
                count = {
                    type = "custom", -- "includeBank", "oGlow", "custom"
                    color = {1, 1, 1, 1},
                },
            },
        },
    }

    ------------------------------------------------------------

    -- If coming back from version 3, save data to backup and wipe FarmingBarDB to prevent lua errors from changed k/v
    -- Don't wipe the whole DB as it'll wipe profiles and profileKeys
    local backup, version2 = {}
    if FarmingBarDB then
        version2 = FarmingBarDB.global and FarmingBarDB.global.version2
        if version2 then
            for k, v in pairs(version2) do
                backup[k] = v
            end
            FarmingBarDB.char = nil
            FarmingBarDB.global = nil
            FarmingBarDB.profile = nil
        end
    end

    ------------------------------------------------------------

    self.db = LibStub("AceDB-3.0"):New(addonName .. "DB", defaults, true)

    ------------------------------------------------------------

    -- Save the backup to the database, so we can still access multiple characters' saved data
    -- We'll delete as we go below
    if version2 then
        self.db.global.version2_2 = backup
    end

    local version2_2 = self.db.global.version2_2
    if version2_2 then
        -- Copy profiles and delete; no use for this after the first time
        if version2_2.profiles then
            for k, v in pairs(version2_2.profiles) do
                self.db.profiles[k] = v
            end
            self.db.global.version2_2.profiles = nil
        end

        -- Copy global and delete; no use for this after the first time
        if version2_2.global then
            for k, v in pairs(version2_2.global) do
                self.db.global[k] = v
            end
            self.db.global.version2_2.global = nil
        end
        if version2_2.profile then
            for k, v in pairs(version2_2.profile) do
                self.db.profile[k] = v
            end
            self.db.global.version2_2.profile = nil
        end

        ------------------------------------------------------------

        -- If there's a saved char db for the current toon, copy and delete
        local realmKey = GetRealmName()
        local charKey = UnitName("player").." - "..realmKey
        if version2_2.char then
            local char = version2_2.char[charKey]
            if char then
                -- Set the data
                self.db.char.numBars = char.numBars
                for k, v in pairs(char.bars) do
                    tinsert(self.db.char.bars, v)
                end

                -- Remove from the backup
                self.db.global.version2_2.char[charKey] = nil
                if U.tcount(version2_2.char) == 0 then
                    self.db.global.version2_2.char = nil
                end

                -- Calling this ensures the new bars have the correct metatables set
                self:OnInitialize()
                return
            end
        end

        -- If we have backup profileKeys for this character, change the profile to the correct profile and remove
        if version2_2.profileKeys and version2_2.profileKeys[charKey] then
            self.db:SetProfile(version2_2.profileKeys[charKey])

            version2_2.profileKeys[charKey] = nil
            if U.tcount(version2_2.profileKeys) == 0 then
                self.db.global.version2_2.profileKeys = nil
            end
        end

        ------------------------------------------------------------

        -- If there are no more items in the backup, remove the backup
        if U.tcount(version2_2) == 0 then
            self.db.global.version2_2 = nil
        end
    end

    ------------------------------------------------------------

    for i = 1, self.db.char.numBars do
        self.db.char.bars[i].enabled = true
    end
    for k, v in pairs(self.db.char.bars) do
        if not v.enabled then
            tremove(self.db.char.bars, k)
        end
    end

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- Save backups into new db and convert the database

    if oldDB or oldCharDB then
        self:ConvertDB(2, oldDB and oldDB.version, oldDB, oldCharDB)
    end

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- Setup options table

    LibStub("AceConfig-3.0"):RegisterOptionsTable(L.addonName, self:GetOptions())
    LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName, self:GetChatOptions())
    ACD:SetDefaultSize(L.addonName, 875, 500)

    self.db.RegisterCallback(self, "OnProfileChanged", "UpdateSkin")
    self.db.RegisterCallback(self, "OnProfileCopied", "UpdateSkin")
    self.db.RegisterCallback(self, "OnProfileReset", "UpdateSkin")

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- Register events

    self:RegisterEvent("PLAYER_REGEN_DISABLED")
    self:RegisterEvent("PLAYER_REGEN_ENABLED")

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- Register chat commands

    addon:RegisterChatCommand("farmingbar", "SlashCommandFunc")

    if self.db.global.commands.farmbar then
        addon:RegisterChatCommand("farmbar", "SlashCommandFunc")
    end

    if self.db.global.commands.farm then
        addon:RegisterChatCommand("farm", "SlashCommandFunc")
    end

    if self.db.global.commands.fbar then
        addon:RegisterChatCommand("fbar", "SlashCommandFunc")
    end

    if self.db.global.commands.fb then
        addon:RegisterChatCommand("fb", "SlashCommandFunc")
    end

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- Register LSM sounds

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

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- Setup container ID tables

    addon.bankIDs = {-3, -1, 5, 6, 7, 8, 9, 10, 11}
    addon.bagIDs = {0, 1, 2, 3, 4}

    --@retail@
    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- Setup currencies table

    local currencies = {61, 81, 241, 361, 384, 385, 391, 393, 394, 397, 398, 399, 400, 401, 402, 416, 515, 614, 615, 676, 677, 697, 738, 752, 754, 776, 777, 789, 821, 823, 824, 828, 829, 910, 944, 980, 994, 999, 1008, 1017, 1020, 1101, 1129, 1149, 1155, 1166, 1172, 1173, 1174, 1191, 1220, 1226, 1268, 1273, 1275, 1314, 1342, 1356, 1357, 1379, 1416, 1501, 1508, 1533, 1534, 1535, 1560, 1565, 1580, 1587, 1704, 1710, 1716, 1717, 1718, 1755, 1719, 1803}

    if select(4, GetBuildInfo()) >= 90001 then
        tinsert(currencies, 1767)
        tinsert(currencies, 1810)
        tinsert(currencies, 1811)
        tinsert(currencies, 1812)
        tinsert(currencies, 1813)
        tinsert(currencies, 1822)
        tinsert(currencies, 1828)
    end


    self.currencies = {}
    for k, v in pairs(currencies) do
        self.currencies[v] = C_CurrencyInfo.GetCurrencyInfo(v) and C_CurrencyInfo.GetCurrencyInfo(v).name
    end

    self.sortedCurrencies = {}
    for k, v in U.pairs(self.currencies, function(a, b) return self.currencies[a] < self.currencies[b] end) do
        self.sortedCurrencies[U.tcount(self.sortedCurrencies) + 1] = k
    end
    --@end-retail@
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function addon:IsFrameOpen()
    return ACD.OpenFrames[L.addonName]
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function addon:Open(...)
    if UnitAffectingCombat("player") then
        self:Print(L.OptionsCombatWarning)
        self.showFrame = {...}
        return
    end
    ACD:SelectGroup(L.addonName, ...)
    ACD:Open(L.addonName)
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function addon:PLAYER_REGEN_DISABLED()
    if self:IsFrameOpen() then
        self.showFrame = {}
    end
    ACD:Close(L.addonName)
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function addon:PLAYER_REGEN_ENABLED()
    if self.showFrame then
        self:Open(U.unpack(self.showFrame))
        self.showFrame = false
    end
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function addon:Refresh()
    if self:IsFrameOpen() then
        self:Open()
    end
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function addon:SlashCommandFunc(input)
    if not input or input:trim() == "" then
        self:Open()
    else
        LibStub("AceConfigCmd-3.0").HandleCommand(addon, "farmingbar", addonName, input)
    end
end