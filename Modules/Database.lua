local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)

private.defaults = {
    bar = {
        buttons = {},

        --[[ General ]]
        alerts = {
            barProgress = false,
            completedObjectives = true,
            muteAll = false,
        },
        label = "",
        limitMats = false,

        --[[ Appearance ]]
        alpha = 1,
        barAnchor = "TOPLEFT", -- "TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT"
        buttonGrowth = "ROW", -- "ROW", "COL"
        buttonSize = 40,
        buttonPadding = 2,
        buttonsPerAxis = 6,
        fontstrings = {
            Cooldown = {
                enabled = true,
                color = { 1, 1, 1, 1 },
                face = "Friz Quadrata TT",
                outline = "OUTLINE",
                size = 12,
                anchor = "CENTER",
                x = 0,
                y = 0,
            },
            Count = {
                enabled = true,
                color = { 1, 1, 1, 1 },
                face = "Friz Quadrata TT",
                outline = "OUTLINE",
                size = 12,
                anchor = "BOTTOMRIGHT",
                x = -1,
                y = 2,
                showEdge = false,
            },
            Objective = {
                enabled = true,
                color = { 1, 1, 1, 1 },
                face = "Friz Quadrata TT",
                outline = "OUTLINE",
                size = 12,
                anchor = "TOPLEFT",
                x = 1,
                y = -2,
            },
        },
        hidden = [[function()
            -- To hide this bar, return true
            -- To show this bar, return nil
            return
        end]],
        mouseover = false,
        movable = true,
        numButtons = 12,
        point = { "CENTER" },
        scale = 1,
        showCooldown = true,
        showEmpty = true,

        --[[ Skins ]]
        skin = "FarmingBar_Default",
    },

    skins = {
        FarmingBar_Default = {
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
        },
    },

    objective = {
        title = "",
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
        includeAlts = false,
        includeBank = false,
        includeGuildBank = {},
        altIDs = {},
    },
}

function private:InitializeDatabase()
    private.db = LibStub("AceDB-3.0"):New("FarmingBarDevDB", {
        global = {
            debug = {
                enabled = false,
                enabled = true,
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
                    moveObjectiveToBank = { -- TODO
                        button = "RightButton",
                        modifier = "alt-ctrl",
                    },
                    moveAllToBank = { -- TODO
                        button = "LeftButton",
                        modifier = "alt-ctrl",
                    },
                    dragObjective = {
                        type = "drag",
                        button = "LeftButton",
                        modifier = "shift",
                    },
                    showObjectiveEditBox = { -- TODO
                        button = "LeftButton",
                        modifier = "ctrl",
                    },
                    showObjectiveEditor = { -- TODO
                        button = "RightButton",
                        modifier = "ctrl",
                    },
                    showQuickAddEditBox = { -- TODO
                        button = "LeftButton",
                        modifier = "alt",
                    },
                    showQuickAddCurrencyEditBox = { -- TODO
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
            skins = {
                FarmingBar_Default = private.defaults.skins.FarmingBar_Default,
            },
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
                buttons = {
                    size = 45,
                    padding = 2,
                },
            },
        },
    }, true)

    addon:SetEnabledState(private.db.profile.enabled)
end
