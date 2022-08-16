local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)

private.defaults = {
    maxButtons = 72,
    minPadding = -3,
    maxPadding = 20,
    minButtonSize = 25,
    maxButtonSize = 64,

    tooltip_desc = { 1, 1, 1 },
    tooltip_keyvalue = { 1, 0.82, 0, 1, 1, 1, 1 },

    objective = {
        icon = {
            type = "AUTO", -- "AUTO", "FALLBACK"
            id = 134400,
        },
        onUse = {
            type = "NONE", -- "ITEM", "NONE", "MACROTEXT"
            itemID = false,
            macrotext = "",
        },
        condition = {
            type = "ALL", -- "ALL", "ANY", "CUSTOM"
            func = [[function()
end]],
        },
        trackers = {},
    },

    tracker = {
        type = "ITEM",
        id = false,
        objective = 1,
        altIDs = {},
    },

    bar = {
        --[[ General ]]
        label = "",
        alerts = {
            barProgress = false,
            completedObjectives = true,
            muteAll = false,
        },
        limitMats = false,

        --[[ Appearance ]]
        backdrop = {
            enabled = false,
            bgFile = {
                bgFile = "Blizzard Tooltip",
                edgeFile = "Blizzard Tooltip",
                edgeSize = 12,
                tile = true,
                tileEdge = true,
                tileSize = 2,
                insets = { left = 2, right = 2, top = 2, bottom = 2 },
            },
            bgColor = { 1, 1, 1, 1 },
            borderColor = { 1, 1, 1, 1 },
        },

        hidden = [[function()
    -- To hide this bar, return true
    -- To show this bar, return nil
    return
end]],
        mouseover = false,
        alpha = 1,
        scale = 1,
        showEmpty = true,
        showCooldown = true,

        --[[ Layout ]]
        movable = true,
        point = { "CENTER" },
        buttonGrowth = "ROW", -- "ROW", "COL"
        barAnchor = "TOPLEFT", -- "TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT"

        --[[ Buttons ]]
        buttons = {},

        buttonTextures = {
            backdrop = {
                texture = "UI EmptySlot White",
                texCoords = { 9 / 64, 53 / 64, 10 / 64, 53 / 64 },
                color = { 1, 1, 1, 0.66 },
                blendMode = "BLEND",
                insets = { left = 0, right = 0, top = 0, bottom = 0 },
                drawLayer = "BACKGROUND",
                layer = -1,
                hidden = false,
            },
            gloss = {
                texture = "None",
                texCoords = { 0, 1, 0, 1 },
                color = { 1, 1, 1, 1 },
                blendMode = "BLEND",
                insets = { left = 0, right = 0, top = 0, bottom = 0 },
                drawLayer = "OVERLAY",
                layer = 0,
                hidden = false,
            },
            icon = {
                texture = "None",
                texCoords = { 0, 1, 0, 1 },
                color = { 1, 1, 1, 1 },
                blendMode = "BLEND",
                insets = { left = 0, right = 0, top = 0, bottom = 0 },
                drawLayer = "ARTWORK",
                layer = 1,
                hidden = false,
            },
            normal = {
                texture = "UI EmptySlot White",
                texCoords = { 9 / 64, 52 / 64, 10 / 64, 53 / 64 },
                color = { 1, 1, 1, 0.66 },
                blendMode = "BLEND",
                insets = { left = 0, right = 0, top = 0, bottom = 0 },
                drawLayer = "ARTWORK",
                layer = 0,
                hidden = false,
            },
            shadow = {
                texture = "None",
                texCoords = { 0, 1, 0, 1 },
                color = { 1, 1, 1, 1 },
                blendMode = "BLEND",
                insets = { left = 0, right = 0, top = 0, bottom = 0 },
                drawLayer = "ARTWORK",
                layer = -1,
                hidden = false,
            },
            highlight = {
                texture = "UI EmptySlot White",
                texCoords = { 9 / 64, 53 / 64, 10 / 64, 53 / 64 },
                color = { 1, 1, 1, 1 },
                blendMode = "ADD",
                insets = { left = 0, right = 0, top = 0, bottom = 0 },
                drawLayer = "HIGHLIGHT",
                layer = 0,
                hidden = false,
            },
            pushed = {
                texture = "UI EmptySlot White",
                texCoords = { 9 / 64, 53 / 64, 10 / 64, 53 / 64 },
                color = { 1, 1, 1, 0.66 },
                blendMode = "BLEND",
                insets = { left = 0, right = 0, top = 0, bottom = 0 },
                drawLayer = "ARTWORK",
                layer = 0,
                hidden = false,
            },
            iconBorder = {
                texture = "UI ActionButton Border",
                texCoords = { 12 / 64, 51 / 64, 13 / 64, 53 / 64 },
                color = { 1, 1, 1, 0.33 },
                blendMode = "ADD",
                insets = { left = 0, right = 0, top = 0, bottom = 0 },
                drawLayer = "OVERLAY",
                layer = 1,
                hidden = false,
            },
        },
        numButtons = 12,
        buttonsPerAxis = 6,
        buttonSize = 40,
        buttonPadding = 2,
    },
}

function private:InitializeDatabase()
    private.db = LibStub("AceDB-3.0"):New("FarmingBarDevDB", {
        global = {
            debug = {
                enabled = false,
                -- enabled = true,
            },
            settings = {
                useGameTooltip = false,
                commands = {
                    farmingbar = true,
                    farmbar = true,
                    farm = true,
                    fbar = true,
                    fb = false,
                },
                keybinds = {
                    clearObjective = {
                        button = "RightButton",
                        modifier = "shift",
                    },
                    moveObjective = {
                        button = "LeftButton",
                        modifier = "",
                    },
                    moveObjectiveToBank = {
                        button = "RightButton",
                        modifier = "alt-ctrl",
                    },
                    moveAllToBank = {
                        button = "LeftButton",
                        modifier = "alt-ctrl",
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
                    showObjectiveEditor = {
                        button = "RightButton",
                        modifier = "ctrl",
                    },
                    showQuickAddEditBox = {
                        button = "LeftButton",
                        modifier = "alt",
                    },
                    showQuickAddCurrencyEditBox = {
                        button = "RightButton",
                        modifier = "alt",
                    },
                    onUse = {
                        button = "RightButton",
                        modifier = "",
                    },
                },
            },
            objectives = {},
        },
        profile = {
            enabled = true,
            bars = {
                private.defaults.bar,
            },
            style = {
                font = {
                    face = "Friz Quadrata TT",
                    outline = "OUTLINE",
                    size = 12,
                },
            },
        },
    }, true)

    addon:SetEnabledState(private.db.profile.enabled)
end
