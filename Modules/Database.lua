local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)

function private:InitializeDatabase()
    private.defaults = {
        bar = {
            backdrop = {
                bgFile = {
                    bgFile = [[INTERFACE\BUTTONS\WHITE8X8]],
                    edgeFile = [[INTERFACE\BUTTONS\WHITE8X8]],
                    edgeSize = 2,
                    tile = true,
                    tileEdge = true,
                    tileSize = 2,
                    insets = { left = 2, right = 2, top = 2, bottom = 2 }
                },
                bgColor = { 1, 1, 1, 1 },
                borderColor = { 0, 0, 0, 1 },
            },

            buttons = {},

            buttonBackdrop = {
                bgFile = {
                    bgFile = [[INTERFACE\BUTTONS\WHITE8X8]],
                    edgeFile = [[INTERFACE\BUTTONS\WHITE8X8]],
                    edgeSize = 2,
                    tile = true,
                    tileEdge = true,
                    tileSize = 2,
                    insets = { left = 2, right = 2, top = 2, bottom = 2 }
                },
                bgColor = { 0, 1, 0, 1 },
                borderColor = { 1, 0, 0, 1 },
            },

            buttonGrowth = "ROW", -- "ROW", "COL"
            barAnchor = "TOPLEFT", -- "TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT"
            numButtons = 12,
            buttonsPerAxis = 3,
            buttonSize = 120,
            buttonPadding = 8,

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
