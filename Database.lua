local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

function addon:Initialize_DB()
    local defaults = {
        char = {
            bars = {
                ["**"] = { -- barID
                    title = "",

                    alerts = {
                        barProgress = false, --bar.trackProgress
                        completedObjectives = true, --bar.trackCompletedObjectives
                        muteAll = false, --bar.muteAlerts
                    },

                    objectives = {}, -- buttonID = {}
                },
            },
        },

        ------------------------------------------------------------

        global = {
            enabled = true,
            resetAlphaDB = 1,

            ------------------------------------------------------------

            settings = {
                alerts = {
                    bar = {
                        chat = true, --global.alerts.barChat
                        screen = true, --global.alerts.barScreen
                        sound = {
                            enabled = true, --global.alerts.barSound

                            complete = "Auction Close", --global.sounds.barComplete
                            progress = "Auction Open", --global.sounds.barProgress
                        },

                        format = {
                            progress = self.barProgress, --global.alertFormats.barProgress
                        },

                        preview = {
                            count = 1, --global.alertFormats.barCountPreview
                            total = 5, --global.alertFormats.barTotalPreview
                            withTitle = true, --global.alertFormats.barTitlePreview
                        },
                    },

                    ------------------------------------------------------------

                    button = {
                        chat = true, --global.alerts.chat
                        screen = true, --global.alerts.screen
                        sound = {
                            enabled = true, --global.alerts.sound

                            objectiveCleared = "Quest Failed", --global.sounds.objectiveCleared
                            objectiveComplete = "Quest Complete", --global.sounds.objectiveComplete
                            objectiveSet = "Quest Activate", --global.sounds.objectiveSet
                            progress = "Loot Coin", --global.sounds.farmingProgress
                        },

                        format = {
                            withObjective = self.withObjective, --global.alertFormats.hasObjective
                            withoutObjective = self.withoutObjective, --global.alertFormats.noObjective
                        },

                        preview = {
                            oldCount = 20, --global.alertFormats.oldCountPreview
                            newCount = 25, --global.alertFormats.newCountPreview
                            objective = 200, --global.alertFormats.objectivePreview
                        },
                    },
                },

                ------------------------------------------------------------

                autoLootOnUse = false, -- global.autoLootItems
                filterQuickObjectives = false, -- hides auto added items from ObjectiveBuilder list
                newQuickObjectives = "PROMPT", -- PROMPT, NEW, OVERWRITE, USEEXISTING
                preserveTemplateData = "DISABLED", -- PROMPT, ENABLED, DISABLED
                preserveTemplateOrder = "DISABLED", -- PROMPT, ENABLED, DISABLED
            },

            ------------------------------------------------------------

            keybinds = {
                bar = {
                    moveBar = {
                        type = "drag",
                        button = "LeftButton",
                        modifier = "",
                    },

                    configBar = {
                        button = "RightButton",
                        modifier = "shift",
                    },

                    toggleMovable = {
                        button = "LeftButton",
                        modifier = "shift",
                    },

                    openSettings = {
                        button = "LeftButton",
                        modifier = "ctrl",
                    },

                    openHelp = {
                        button = "RightButton",
                        modifier = "",
                    },
                },

                button = {
                    clearObjective = {
                        button = "RightButton",
                        modifier = "shift",
                    },

                    includeBank = {
                        button = "LeftButton",
                        modifier = "alt",
                    },

                    moveObjective = {
                        button = "LeftButton",
                        modifier = "",
                    },

                    dragObjective = {
                        type = "drag",
                        button = "LeftButton",
                        modifier = "shift",
                    },

                    showObjectiveBuilder = {
                        showOnEmpty = true,
                        button = "RightButton",
                        modifier = "ctrl",
                    },

                    showObjectiveEditBox = {
                        button = "LeftButton",
                        modifier = "ctrl",
                    },

                    useItem = {
                        button = "RightButton",
                        modifier = "",
                    },
                },
            },

            ------------------------------------------------------------

            commands = {
                farmingbar = true,
                farmbar = true,
                farm = true,
                fbar = true,
                fb = false,
            },

            ------------------------------------------------------------

            tooltips = {
                bar = true,
                button = true,
                hideObjectiveInfo = false,
            },

            ------------------------------------------------------------

            hints = {
                enableModifier = false, --global.tooltips.enableMod
                modifier = "Alt", --global.tooltips.mod

                bars = true, --global.tooltips.barTips
                buttons = true, --global.tooltips.buttonTips
                ObjectiveBuilder = true,
            },

            ------------------------------------------------------------

            debugMode = false, -- ! Set false before releases; enables debug toggles in GUI
            debug = {
                barDB = false, -- resets bar database on reload
                commands = false, -- enables debug only commands
                Config = false, -- opens Config frame on reload
                ConfigButtons = false, -- opens Config frame to buttons tab if Config enabled
                ObjectiveBuilder = false, -- opens Objective Builder on reload
                ObjectiveBuilderTrackers = false, -- opens Objective Builder to trackers tab if Objective Builder enabled
                StyleEditor = false, -- opens Style Editor on reload
            },

            ------------------------------------------------------------

            objectives = {},
            templates = {},

            ------------------------------------------------------------

            skins = {
                -- ["**"] = {},
            },
        },

        ------------------------------------------------------------

        profile = {
            enabled = true, --enables bar creation for new users/characters; disable when user deletes all bars
            bars = {},
            style = {
                skin = "FarmingBar_Default",
                font = {
                    face = "Friz Quadrata TT",
                    outline = "OUTLINE",
                    size = 11,
                    fontStrings = {
                        count = {
                            style = "CUSTOM", -- "CUSTOM", "INCLUDEBANK", "ITEMQUALITY" --profile.style.count.type
                            color = {1, 1, 1, 1}, --profile.style.count.color
                        },
                    },
                },
                buttonLayers = {
                    AutoCastable = true, --bank overlay
                    Border = true, --item quality
                    Cooldown = true,
                    CooldownEdge = false,
                },
            },
        },
    }

    ------------------------------------------------------------
    --Debug-----------------------------------------------------
    ------------------------------------------------------------
    if defaults.global.debug.commands then
        defaults.global.commands.fb = true
    end
    ------------------------------------------------------------
    ------------------------------------------------------------

    -- Convert/save old DB before initializing DB
    local backup = {}
    local version2
    if FarmingBarDB then
        version2 = FarmingBarDB.global and not FarmingBarDB.global.version or FarmingBarDB.global.version < 3 -- version 2 coming new to version 3
        if version2 then
            for k, v in pairs(FarmingBarDB) do
                backup[k] = v
            end
            wipe(FarmingBarDB)
        end
    end


    ------------------------------------------------------------

    FarmingBar.db = LibStub("AceDB-3.0"):New("FarmingBarDB", defaults)

    ------------------------------------------------------------

    -- Have to keep track of version manually since it will otherwise get wiped out from AceDB
    -- Check for previous versions first and convert before changing the version.
    -- This should only be done once database is finalized.
    FarmingBar.db.global.version = 3

    ------------------------------------------------------------

    if version2 then
        FarmingBarDB.global.version2 = backup
    end

    ------------------------------------------------------------

    -- alpha1 -> alpha2 only
    -- Moving bars from character to profile specific
    local charKey = UnitName("player").." - "..GetRealmName()
    if FarmingBar.db.char.enabled then
        FarmingBar.db.profile.enabled = FarmingBar.db.char.enabled
        FarmingBar.db.char.enabled = nil
    end

    if FarmingBar.db.global.resetAlphaDB then
        for k, v in pairs(FarmingBar.db.char.bars) do
            tremove(FarmingBar.db.char.bars, k)
        end
        FarmingBar.db.global.resetAlphaDB = false
        StaticPopup_Show("FARMINGBAR_V30_ALPHA2_BARRESET")
    end
end

--*------------------------------------------------------------------------

function addon:GetDefaultBar()
    local bar = {
        movable = true,

        hidden = false,
        anchorMouseover = false,
        mouseover = false,
        showEmpty = true,

        alpha = 1,
        scale = 1,

        numVisibleButtons = 6,
        buttonWrap = 12,
        grow = {"RIGHT", "NORMAL"}, -- [1] = "RIGHT", "LEFT", "UP", "DOWN"; [2] = "NORMAL", "REVERSE"
        point = {"TOP"},

        button = {
            size = 35, --bar.buttonSize
            padding = 2, --bar.buttonPadding
            fontStrings = {
                count = {
                    anchor = "BOTTOM",
                    xOffset = -1,
                    yOffset = 6,
                },
                objective = {
                    anchor = "TOPLEFT",
                    xOffset = 6,
                    yOffset = -4,
                },
            },
        },
    }

    return bar
end

------------------------------------------------------------

function addon:GetDefaultObjective()
    local objective = {
        autoIcon = true,
        customCondition = "",
        displayRef = {
            trackerID = false,
            trackerType = "NONE",
        },
        icon = 134400,
        trackerCondition = "ALL",
        trackers = {},
    }

    return objective
end

------------------------------------------------------------

function addon:GetDefaultTracker()
    local tracker = {
        includeAllChars = false,
        includeBank = false,
        exclude = {},
        objective = 1,
        countsFor = 1,
        trackerType = "ITEM",
        trackerID = "",
    }

    return tracker
end

--*------------------------------------------------------------------------

function addon:GetDBValue(scope, key)
    local keys = {strsplit(".", key)}
    local path = FarmingBar.db[scope]

    for k, key in pairs(keys) do
        if k < #keys then
            path = path[key]
        end
    end

    return path[keys[#keys]]
end

------------------------------------------------------------

function addon:SetDBValue(scope, key, value)
    local keys = {strsplit(".", key)}
    local path = FarmingBar.db[scope]

    for k, key in pairs(keys) do
        if k < #keys then
            path = path[key]
        end
    end

    path[keys[#keys]] = value
end