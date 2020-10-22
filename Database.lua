local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

function addon:Initialize_DB()
    local defaults = {
        char = {
            bars = {},
        },
        global = {
            enabled = true,

            ------------------------------------------------------------

            alertSettings = {
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

            templateSettings = {
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

            miscSettings = {
                autoLootOnUse = false, -- global.autoLootItems
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
                enableModifier = true, --global.tooltips.enableMod
                modifier = "Alt", --global.tooltips.mod

                bars = true, --global.tooltips.barTips
                buttons = true, --global.tooltips.buttonTips
                ObjectiveBuilder = true,
            },

            ------------------------------------------------------------

            debug = {
                commands = true,
                ObjectiveBuilder = false,
                ObjectiveBuilderTrackers = false,
                ObjectiveBuilderCondition = false,
            },

            ------------------------------------------------------------

            objectives = {},
            skins = {},
            templates = {},
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

    FarmingBar.db = LibStub("AceDB-3.0"):New("FarmingBarDB", defaults, true)

    -- Have to keep track of version manually since it will otherwise get wiped out from AceDB
    -- Check for previous versions first and convert before changing the version.
    -- This should only be done once database is finalized.
    FarmingBar.db.global.version = 3
end