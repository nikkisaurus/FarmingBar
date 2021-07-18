local addonName = ...
local addon = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

------------------------------------------------------------

local currentVersion = 4

--*------------------------------------------------------------------------

function addon:InitializeDB()
    local backup = self:ValidateDB()

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

                    objectives = {
                        ["**"] = { -- buttonID
                            template = false, -- global objective template

                            -- Template
                            title = "",
                            autoIcon = true,
                            icon = 134400,
                            action = "NONE", -- displayRef.trackerType: CURRENCY, ITEM, MACROTEXT, RECIPE, NONE
                            actionInfo = "", -- displayRef.trackerID
                            condition = "ALL", -- trackerCondition
                            conditionInfo = "", -- customCondition
                            --

                            objective = 0,

                            trackers = {
                                ["**"] = { -- trackerID: "ITEM:1412", "CURRENCY:1803"
                                    --Template
                                    order = 0,
                                    objective = 1,
                                    countsFor = 1,
                                    --

                                    --Char
                                    includeAllChars = false,
                                    includeBank = false,
                                    exclude = {}, -- buttonIDs
                                },
                            },
                        },
                    },
                },
            },
        },

        ------------------------------------------------------------

        global = {
            skins = {},
            templates = {},

            ------------------------------------------------------------

            objectives = {
                ["**"] = { -- objectiveTitle
                    title = "",
                    autoIcon = true,
                    icon = 134400,
                    action = "NONE",
                    actionInfo = "",
                    condition = "ALL",
                    conditionInfo = "",

                    trackers = {
                        ["**"] = { -- trackerID: "ITEM:1412", "CURRENCY:1803"
                            order = 0,
                            objective = 1,
                            countsFor = 1,
                        },
                    },

                    links = {
                        ["**"] = {},
                        -- profileKey = {
                        --     buttonID, ...
                        -- }
                    },
                },
            },

            ------------------------------------------------------------

            settings = {
                commands = {
                    farmingbar = true,
                    farmbar = true,
                    farm = true,
                    fbar = true,
                    fb = false,
                },

                ------------------------------------------------------------

                debug = {
                    enabled = false, -- ! Set false before releases; enables debug toggles in GUI
                    barDB = false, -- resets bar database on reload
                    commands = false, -- enables debug only commands
                    Config = false, -- opens Config frame on reload
                    ConfigButtons = false, -- opens Config frame to buttons tab if Config enabled
                    ObjectiveBuilder = false, -- opens Objective Builder on reload
                    ObjectiveBuilderTrackers = false, -- opens Objective Builder to trackers tab if Objective Builder enabled
                    StyleEditor = false, -- opens Style Editor on reload
                },

                ------------------------------------------------------------

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

                        includeAllChars = {
                            button = "RightButton",
                            modifier = "alt",
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

                misc = {
                    autoLootOnUse = false, -- global.autoLootItems
                    preserveTemplateData = "DISABLED", -- PROMPT, ENABLED, DISABLED
                    preserveTemplateOrder = "DISABLED", -- PROMPT, ENABLED, DISABLED
                },
            },
        },

        ------------------------------------------------------------

        profile = {
            enabled = true, --enables bar creation for new users/characters; disable when user deletes all bars
            bars = {
                ["**"] = { -- barID
                    enabled = false,
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
                },
            },

            style = {
                skin = "FarmingBar_Default",

                font = {
                    face = "Friz Quadrata TT",
                    outline = "OUTLINE",
                    size = 11,

                    fontStrings = {
                        count = {
                            style = "CUSTOM", -- "CUSTOM", "INCLUDEAUTOLAYERS", "INCLUDEALLCHARS", "INCLUDEBANK", "ITEMQUALITY" --profile.style.count.type
                            color = {1, 1, 1, 1}, --profile.style.count.color
                        },
                    },
                },

                buttonLayers = {
                    AutoCastable = true, --bank overlay
                    AccountOverlay = true, -- account overlay
                    Border = true, --item quality
                    Cooldown = true,
                    CooldownEdge = false,
                },
            },
        },
    }

    ------------------------------------------------------------

    self.db = LibStub("AceDB-3.0"):New("FarmingBarDB", defaults)
    self.db.global.version = currentVersion
    if backup then self.db.global.db_backup = backup end
end

------------------------------------------------------------

function addon:ValidateDB()
    local backup

    if FarmingBarDB then
        local version = FarmingBarDB.global.version
        if version == currentVersion then
            return
        else
            backup = self:CloneTable(FarmingBarDB)
            FarmingBarDB = nil
        end
    end

    return backup
end

--*------------------------------------------------------------------------

function addon:GetDBValue(scope, key)
    local path = self.db[scope]
    if not key then return path end
    local keys = {strsplit(".", key)}

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
    local path = self.db[scope]

    for k, key in pairs(keys) do
        if k < #keys then
            path = path[key]
        end
    end

    if value == "_TOGGLE_" then
        if path[keys[#keys]] then
            value = false
        else
            value = true
        end
    end

    path[keys[#keys]] = value
end