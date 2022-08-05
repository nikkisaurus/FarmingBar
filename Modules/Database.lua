local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)

function private:InitializeDatabase()
    private.defaults = {
        maxButtons = 72,
        minPadding = -3,
        maxPadding = 20,
        minButtonSize = 25,
        maxButtonSize = 64,

        tooltip_desc = { 1, 1, 1, 1, 1, 1, 1 },
        tooltip_keyvalue = { 1, 0.82, 0, 1, 1, 1, 1 },

        button = {
            iconID = 134400,
            itemQuality = 0,
            action = "NONE", -- "CURRENCY", "ITEM", "MACROTEXT", "NONE"
            actionInfo = "",
            condition = "ALL", -- "ALL", "ANY", "CUSTOM"
            customCondition = "",
            trackers = {},
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
                    insets = { left = 2, right = 2, top = 2, bottom = 2 }
                },
                bgColor = { 1, 1, 1, 1 },
                borderColor = { 1, 1, 1, 1 },
            },

            hidden = [[function()
    -- To hide this bar, return true
    -- To show this bar, return nil
    return
end]]        ,
            mouseover = false,
            alpha = 1,
            scale = 1,
            showEmpty = true,

            --[[ Layout ]]
            movable = true,
            point = { "CENTER" },
            buttonGrowth = "ROW", -- "ROW", "COL"
            barAnchor = "TOPLEFT", -- "TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT"

            --[[ Buttons ]]
            buttons = {
                {
                    iconID = 134400,
                    itemQuality = 1,
                    action = "NONE", -- "CURRENCY", "ITEM", "MACROTEXT", "NONE"
                    actionInfo = "",
                    condition = "ALL", -- "ALL", "ANY", "CUSTOM"
                    customCondition = "",
                    trackers = {},
                },
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
                },
                gloss = {
                    texture = "None",
                    texCoords = { 0, 1, 0, 1 },
                    color = { 1, 1, 1, 1 },
                    blendMode = "BLEND",
                    insets = { left = 0, right = 0, top = 0, bottom = 0 },
                    drawLayer = "OVERLAY",
                    layer = 0,
                },
                icon = {
                    texture = "None",
                    texCoords = { 0, 1, 0, 1 },
                    color = { 1, 1, 1, 1 },
                    blendMode = "BLEND",
                    insets = { left = 0, right = 0, top = 0, bottom = 0 },
                    drawLayer = "ARTWORK",
                    layer = 1,
                },
                normal = {
                    texture = "UI EmptySlot White",
                    texCoords = { 9 / 64, 53 / 64, 10 / 64, 53 / 64 },
                    color = { 1, 1, 1, 0.66 },
                    blendMode = "BLEND",
                    insets = { left = 0, right = 0, top = 0, bottom = 0 },
                    drawLayer = "ARTWORK",
                    layer = 0,
                },
                shadow = {
                    texture = "None",
                    texCoords = { 0, 1, 0, 1 },
                    color = { 1, 1, 1, 1 },
                    blendMode = "BLEND",
                    insets = { left = 0, right = 0, top = 0, bottom = 0 },
                    drawLayer = "ARTWORK",
                    layer = -1,
                },
                highlight = {
                    texture = "UI EmptySlot White",
                    texCoords = { 9 / 64, 53 / 64, 10 / 64, 53 / 64 },
                    color = { 1, 1, 1, 1 },
                    blendMode = "ADD",
                    insets = { left = 0, right = 0, top = 0, bottom = 0 },
                    drawLayer = "HIGHLIGHT",
                    layer = 0,
                },
                pushed = {
                    texture = "UI EmptySlot White",
                    texCoords = { 9 / 64, 53 / 64, 10 / 64, 53 / 64 },
                    color = { 1, 1, 1, 0.66 },
                    blendMode = "BLEND",
                    insets = { left = 0, right = 0, top = 0, bottom = 0 },
                    drawLayer = "ARTWORK",
                    layer = 0,
                },
                iconBorder = {
                    texture = "UI ActionButton Border",
                    texCoords = { 11 / 64, 51 / 64, 12 / 64, 52 / 64 },
                    color = { 1, 1, 1, 0.33 },
                    blendMode = "ADD",
                    insets = { left = 0, right = 0, top = 0, bottom = 0 },
                    drawLayer = "OVERLAY",
                    layer = 1,
                },
            },
            numButtons = 12,
            buttonsPerAxis = 6,
            buttonSize = 40,
            buttonPadding = 2,
        },
    }

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
            },
        },
        profile = {
            enabled = true,
            bars = {
                private.defaults.bar,
            },
        },
    }, true)

    addon:SetEnabledState(private.db.profile.enabled)
end
