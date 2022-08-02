local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)

private.anchorPoints = {
    ROW = {
        button1 = {
            TOPLEFT = {
                anchor = "TOPLEFT",
                relAnchor = "TOPLEFT",
                xCo = 1,
                yCo = -1,
            },
            TOPRIGHT = {
                anchor = "TOPRIGHT",
                relAnchor = "TOPRIGHT",
                xCo = -1,
                yCo = -1,
            },
            BOTTOMLEFT = {
                anchor = "BOTTOMLEFT",
                relAnchor = "BOTTOMLEFT",
                xCo = 1,
                yCo = 1,
            },
            BOTTOMRIGHT = {
                anchor = "BOTTOMRIGHT",
                relAnchor = "BOTTOMRIGHT",
                xCo = -1,
                yCo = 1,
            },
        },
        newRowButton = {
            TOPLEFT = {
                anchor = "TOPLEFT",
                relAnchor = "BOTTOMLEFT",
                xCo = 0,
                yCo = -1,
            },
            TOPRIGHT = {
                anchor = "TOPRIGHT",
                relAnchor = "BOTTOMRIGHT",
                xCo = 0,
                yCo = -1,
            },
            BOTTOMLEFT = {
                anchor = "BOTTOMLEFT",
                relAnchor = "TOPLEFT",
                xCo = 0,
                yCo = 1,
            },
            BOTTOMRIGHT = {
                anchor = "BOTTOMRIGHT",
                relAnchor = "TOPRIGHT",
                xCo = 0,
                yCo = 1,
            },
        },
        button = {
            TOPLEFT = {
                anchor = "TOPLEFT",
                relAnchor = "TOPRIGHT",
                xCo = 1,
                yCo = 0,
            },
            TOPRIGHT = {
                anchor = "TOPRIGHT",
                relAnchor = "TOPLEFT",
                xCo = -1,
                yCo = 0,
            },
            BOTTOMLEFT = {
                anchor = "BOTTOMLEFT",
                relAnchor = "BOTTOMRIGHT",
                xCo = 1,
                yCo = 0,
            },
            BOTTOMRIGHT = {
                anchor = "BOTTOMRIGHT",
                relAnchor = "BOTTOMLEFT",
                xCo = -1,
                yCo = 0,
            },
        },
    },
    COL = {
        button1 = {
            TOPLEFT = {
                anchor = "TOPLEFT",
                relAnchor = "TOPLEFT",
                xCo = 1,
                yCo = -1,
            },
            TOPRIGHT = {
                anchor = "TOPRIGHT",
                relAnchor = "TOPRIGHT",
                xCo = -1,
                yCo = -1,
            },
            BOTTOMLEFT = {
                anchor = "BOTTOMLEFT",
                relAnchor = "BOTTOMLEFT",
                xCo = 1,
                yCo = 1,
            },
            BOTTOMRIGHT = {
                anchor = "BOTTOMRIGHT",
                relAnchor = "BOTTOMRIGHT",
                xCo = -1,
                yCo = 1,
            },
        },
        newRowButton = {
            TOPLEFT = {
                anchor = "TOPLEFT",
                relAnchor = "TOPRIGHT",
                xCo = 1,
                yCo = 0,
            },
            TOPRIGHT = {
                anchor = "TOPRIGHT",
                relAnchor = "TOPLEFT",
                xCo = -1,
                yCo = 0,
            },
            BOTTOMLEFT = {
                anchor = "BOTTOMLEFT",
                relAnchor = "BOTTOMRIGHT",
                xCo = 1,
                yCo = 0,
            },
            BOTTOMRIGHT = {
                anchor = "BOTTOMRIGHT",
                relAnchor = "BOTTOMLEFT",
                xCo = -1,
                yCo = 0,
            },
        },
        button = {
            TOPLEFT = {
                anchor = "TOPLEFT",
                relAnchor = "BOTTOMLEFT",
                xCo = 0,
                yCo = -1,
            },
            TOPRIGHT = {
                anchor = "TOPRIGHT",
                relAnchor = "BOTTOMRIGHT",
                xCo = 0,
                yCo = -1,
            },
            BOTTOMLEFT = {
                anchor = "BOTTOMLEFT",
                relAnchor = "TOPLEFT",
                xCo = 0,
                yCo = 1,
            },
            BOTTOMRIGHT = {
                anchor = "BOTTOMRIGHT",
                relAnchor = "TOPRIGHT",
                xCo = 0,
                yCo = 1,
            },
        },
    },
    anchor = {
        TOPLEFT = {
            anchor = "TOPRIGHT",
            relAnchor = "TOPLEFT",
            xCo = -1,
            yCo = 0,
        },
        TOPRIGHT = {
            anchor = "TOPLEFT",
            relAnchor = "TOPRIGHT",
            xCo = 1,
            yCo = 0,
        },
        BOTTOMLEFT = {
            anchor = "BOTTOMRIGHT",
            relAnchor = "BOTTOMLEFT",
            xCo = -1,
            yCo = 0,
        },
        BOTTOMRIGHT = {
            anchor = "BOTTOMLEFT",
            relAnchor = "BOTTOMRIGHT",
            xCo = 1,
            yCo = 0,
        },
    }
}
