local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)

function private:InitializeDatabase()
    private.defaults = {
        tooltip_desc = { 1, 1, 1, 1, 1, 1, 1 },
        tooltip_keyvalue = { 1, 0.82, 0, 1, 1, 1, 1 },
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
                enabled = true,
                bgFile = {
                    bgFile = [[INTERFACE\TOOLTIPS\UI-TOOLTIP-BACKGROUND]],
                    edgeFile = [[INTERFACE\TOOLTIPS\UI-TOOLTIP-BORDER]],
                    edgeSize = 12,
                    tile = true,
                    tileEdge = true,
                    tileSize = 2,
                    insets = { left = 2, right = 2, top = 2, bottom = 2 }
                },
                bgColor = { 0, 0, 0, 0.33 },
                borderColor = { 1, 1, 1, 1 },
                texCoords = { 0, 1, 0, 1 },
            },

            buttons = {
            },

            buttonTextures = {
                backdrop = {
                    -- texture = [[INTERFACE\BUTTONS\WHITE8X8]],
                    -- texCoords = { 0, 1, 0, 1 },
                    texture = [[INTERFACE\BUTTONS\UI-EMPTYSLOT-WHITE]],
                    texCoords = { 9 / 64, 53 / 64, 10 / 64, 53 / 64 },
                    color = { 1, 1, 1, 0.33 },
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
                    -- texture = [[INTERFACE\BUTTONS\WHITE8X8]],
                    -- texCoords = { 0, 1, 0, 1 },
                    texture = [[INTERFACE\BUTTONS\UI-EMPTYSLOT-WHITE]],
                    texCoords = { 9 / 64, 53 / 64, 10 / 64, 53 / 64 },
                    color = { 1, 1, 1, 0.33 },
                    blendMode = "BLEND",
                },
                shadow = {
                    texture = nil,
                    texCoords = { 0, 1, 0, 1 },
                    color = { 1, 1, 1, 1 },
                    blendMode = "BLEND",
                },
                highlight = {
                    -- texture = [[INTERFACE\BUTTONS\WHITE8X8]],
                    -- texCoords = { 0, 1, 0, 1 },
                    texture = [[INTERFACE\BUTTONS\UI-EMPTYSLOT-WHITE]],
                    texCoords = { 9 / 64, 53 / 64, 10 / 64, 53 / 64 },
                    color = { 1, 1, 1, 0.33 },
                    blendMode = "ADD",
                },
                pushed = {
                    -- texture = [[INTERFACE\BUTTONS\WHITE8X8]],
                    -- texCoords = { 0, 1, 0, 1 },
                    texture = [[INTERFACE\BUTTONS\UI-EMPTYSLOT-WHITE]],
                    texCoords = { 9 / 64, 53 / 64, 10 / 64, 53 / 64 },
                    color = { 1, 1, 1, 0.33 },
                    blendMode = "BLEND",
                },
                iconBorder = {
                    texture = [[Interface\Buttons\UI-ActionButton-Border]],
                    texCoords = { 11 / 64, 51 / 64, 12 / 64, 52 / 64 },
                    color = { 1, 1, 1, 1 },
                    blendMode = "ADD",
                },
            },

            movable = true,
            point = { "CENTER" },

            buttonGrowth = "ROW", -- "ROW", "COL"
            barAnchor = "TOPLEFT", -- "TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT"
            numButtons = 12,
            buttonsPerAxis = 12,
            buttonSize = 100,
            buttonPadding = 6,

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
            },
            settings = {
                useGameTooltip = false,
            },
        },
        profile = {
            enabled = true,
            bars = {
                private.defaults.bar,
            },
        },
    })

    addon:SetEnabledState(private.db.profile.enabled)
end
