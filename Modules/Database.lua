local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)

function private:InitializeDatabase()
    private.defaults = {
        button = {
            iconID = 1053367,
            itemQuality = 6,
            action = "NONE", -- "CURRENCY", "ITEM", "MACROTEXT", "NONE"
            actionInfo = "",
            condition = "ALL", -- "ALL", "ANY", "CUSTOM"
            customCondition = "",
            trackers = {},
        },
        bar = {
            backdrop = {
                enabled = false,
                bgFile = {
                    bgFile = [[INTERFACE\BUTTONS\WHITE8X8]],
                    edgeFile = [[INTERFACE\BUTTONS\WHITE8X8]],
                    edgeSize = 2,
                    tile = true,
                    tileEdge = true,
                    tileSize = 2,
                    insets = { left = 2, right = 2, top = 2, bottom = 2 }
                },
                bgColor = { 0, 0, 0, 0.33 },
                borderColor = { 0, 0, 0, 1 },
                texCoords = { 0, 1, 0, 1 },
            },

            buttons = {
            },

            buttonTextures = {
                backdrop = {
                    texture = [[Interface\Buttons\UI-Quickslot]],
                    texCoords = { 11 / 64, 51 / 64, 11 / 64, 51 / 64 },
                    color = { 1, 1, 1, 1 },
                    blendMode = "BLEND",
                },
                gloss = {
                    texture = nil,
                    texCoords = { 0, 1, 0, 1 },
                    color = { 1, 1, 1, 1 },
                    blendMode = "BLEND",
                },
                icon = {
                    texture = nil,
                    texCoords = { 0, 1, 0, 1 },
                    color = { 1, 1, 1, 1 },
                    blendMode = "BLEND",
                },
                normal = {
                    texture = [[Interface\Buttons\UI-Quickslot2]],
                    texCoords = { 11 / 64, 51 / 64, 11 / 64, 51 / 64 },
                    color = { 1, 1, 1, 1 },
                    blendMode = "BLEND",
                },
                shadow = {
                    texture = nil,
                    texCoords = { 0, 1, 0, 1 },
                    color = { 1, 1, 1, 1 },
                    blendMode = "BLEND",
                },
                highlight = {
                    texture = [[Interface\Buttons\UI-Quickslot2]],
                    texCoords = { 11 / 64, 51 / 64, 11 / 64, 51 / 64 },
                    color = { 1, 1, 1, 1 },
                    blendMode = "ADD",
                },
                pushed = {
                    texture = [[Interface\Buttons\UI-Quickslot2]],
                    texCoords = { 11 / 64, 51 / 64, 11 / 64, 51 / 64 },
                    color = { 1, 1, 1, 1 },
                    blendMode = "BLEND",
                },
                iconBorder = {
                    texture = [[Interface\Buttons\UI-ActionButton-Border]],
                    texCoords = { 11 / 64, 51 / 64, 12 / 64, 52 / 64 },
                    color = { 1, 1, 1, 1 },
                    blendMode = "ADD",
                },
            },

            point = { "CENTER" },

            buttonGrowth = "ROW", -- "ROW", "COL"
            barAnchor = "TOPLEFT", -- "TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT"
            numButtons = 12,
            buttonsPerAxis = 12,
            buttonSize = 40,
            buttonPadding = 2,

            hidden = [[function()
    return
end]]        ,
            mouseover = false,
            alpha = 1,
        },
    }

    private.db = LibStub("AceDB-3.0"):New("FarmingBarDevDB", {
        global = {
            debug = {
                enabled = true,
            }
        },
        profile = {
            enabled = true,
            bars = {
                private.defaults.bar,
            },
        },
    })
end
