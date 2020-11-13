local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

function addon:Initialize_DB()
    local defaults = {
        char = {
            enabled = true, --enables bar creation for new users/characters; disable when user deletes all bars
            bars = {},
        },

        global = {
            enabled = true,

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

                objectives = {
                    overwriteQuickObjectives = {
                        enabled = false, -- when enabled, overwrites every time; if disabled, creates a new objective every time
                        prompt = true, -- always prompt to overwrite or use existing
                        useExisting = false, -- when enabled, never overwrite; when disabled, overwrite
                    },
                },

                ------------------------------------------------------------

                templates = {
                    preserveData = {
                        enabled = false, -- global.template.includeData
                        prompt = false, -- global.template.includeDataPrompt
                    },
                    preserveOrder = {
                        enabled = false, -- global.template.saveOrder
                        prompt = false, -- global.template.saveOrderPrompt
                    },
                },

                ------------------------------------------------------------

                misc = {
                    autoLootOnUse = false, -- global.autoLootItems
                    filterOBAutoItems = false, -- hides auto added items from ObjectiveBuilder list
                },
            },

            ------------------------------------------------------------

            keybinds = {
                bar = {
                    -- openHelp = {
                    --     button = "",
                    --     modifier = "",
                    -- },

                    openSettings = {
                        button = "RightButton",
                        modifier = "shift",
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

                    showObjectiveBuilder = {
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

                dragButton = {
                    button = "LeftButton",
                    modifier = "shift",
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

            debug = {
                commands = false,
                barDB = false,
                ObjectiveBuilder = false,
                ObjectiveBuilderTrackers = false,
            },

            ------------------------------------------------------------

            objectives = {},
            templates = {},

            ------------------------------------------------------------

            skins = {
                -- ["**"] = {},
            },
        },

        profile = {
            style = {
                skin = "FarmingBar_Minimal",
                font = {
                    face = "Friz Quadrata TT",
                    outline = "OUTLINE",
                    size = 11,
                    fontStrings = {
                        ["**"] = {
                            colorType = "CUSTOM", -- "CUSTOM", "INCLUDEBANK", "ITEMQUALITY" --profile.style.count.type
                            color = {1, 1, 1, 1}, --profile.style.count.color
                        },
                        count = {},
                        objective = {},
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

    FarmingBar.db = LibStub("AceDB-3.0"):New("FarmingBarDB", defaults, true)

    ------------------------------------------------------------

    -- Have to keep track of version manually since it will otherwise get wiped out from AceDB
    -- Check for previous versions first and convert before changing the version.
    -- This should only be done once database is finalized.
    FarmingBar.db.global.version = 3
    if version2 then
        FarmingBarDB.global.version2 = backup
    end
end

--*------------------------------------------------------------------------

function addon:GetDefaultBar()
    local bar = {
        title = "",

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

        alerts = {
            barProgress = false, --bar.trackProgress
            completedObjectives = true, --bar.trackCompletedObjectives
            muteAll = false, --bar.muteAlerts
        },

        button = {
            size = 35, --bar.buttonSize
            padding = 2, --bar.buttonPadding
        },

        objectives = {},
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
            trackerType = false,
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