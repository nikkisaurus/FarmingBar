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
            chatFrame = "ChatFrame1",
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
                color = { 1, 0.82, 0, 1 },
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
        hiddenEvents = {},
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
                    edgeSize = 10,
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
                    texCoords = { 9 / 64, 54 / 64, 10 / 64, 53 / 64 },
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
                    texCoords = { 9 / 64, 54 / 64, 10 / 64, 53 / 64 },
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
                    texCoords = { 9 / 64, 54 / 64, 10 / 64, 53 / 64 },
                    color = { 1, 1, 1, 1 },
                    blendMode = "ADD",
                    insets = { left = 0, right = 0, top = 0, bottom = 0 },
                    drawLayer = "HIGHLIGHT",
                    layer = 0,
                    hidden = false,
                },
                pushed = {
                    texture = "UI EmptySlot White",
                    texCoords = { 9 / 64, 54 / 64, 10 / 64, 53 / 64 },
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
        FarmingBar_Minimal = {
            backdrop = {
                enabled = false,
                bgFile = {
                    bgFile = "Solid",
                    edgeFile = "Solid Border",
                    edgeSize = 2,
                    tile = true,
                    tileEdge = true,
                    tileSize = 2,
                    insets = { left = 0, right = 0, top = 0, bottom = 0 },
                },
                bgColor = { 0, 0, 0, 0.66 },
                borderColor = { 0, 0, 0, 1 },
            },

            buttonTextures = {
                backdrop = {
                    texture = "Solid",
                    texCoords = { 0, 1, 0, 1 },
                    color = { 0, 0, 0, 0.33 },
                    blendMode = "BLEND",
                    insets = { left = 0, right = 0, top = 0, bottom = 0 },
                    drawLayer = "BACKGROUND",
                    layer = 0,
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
                    texCoords = { 0.08, 0.92, 0.08, 0.92 },
                    color = { 1, 1, 1, 1 },
                    blendMode = "BLEND",
                    insets = { left = 0, right = 0, top = 0, bottom = 0 },
                    drawLayer = "ARTWORK",
                    layer = 1,
                    hidden = false,
                },
                normal = {
                    texture = "Icon Border",
                    texCoords = { 0, 1, 0, 1 },
                    color = { 0, 0, 0, 1 },
                    blendMode = "BLEND",
                    insets = { left = 0, right = 0, top = 0, bottom = 0 },
                    drawLayer = "ARTWORK",
                    layer = 2,
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
                    texture = "Solid",
                    texCoords = { 0, 1, 0, 1 },
                    color = { 1, 0.82, 0, 0.25 },
                    blendMode = "ADD",
                    insets = { left = 1, right = -1, top = -1, bottom = 1 },
                    drawLayer = "HIGHLIGHT",
                    layer = 0,
                    hidden = false,
                },
                pushed = {
                    texture = "Solid",
                    texCoords = { 0, 1, 0, 1 },
                    color = { 0, 0, 0, 0.33 },
                    blendMode = "BLEND",
                    insets = { left = 0, right = 0, top = 0, bottom = 0 },
                    drawLayer = "ARTWORK",
                    layer = 0,
                    hidden = false,
                },
                iconBorder = {
                    texture = "Icon Border",
                    texCoords = { 0, 1, 0, 1 },
                    color = { 1, 1, 1, 1 },
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
        objective = 0,
        mute = false,
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
            func = [[function(trackers, GetTrackerCount)
    -- This is the structure of the tracker table:
    --trackers = {
    --    [1] = {
    --        type = "ITEM", -- "CURRENCY"
    --        id = 0000,
    --        objective = 1,
    --        includeAlts = false,
    --        includeBank = false,
    --        includeGuildBank = {
    --             ["GuildKey"] = true
    --        },
    --        altIDs = {
    --            {
    --                type = "ITEM", -- "CURRENCY"
    --                id = 0000,
    --                multiplier = 1,
    --            }
    --        },
    --    },
    --}
    
    -- NOTE: make sure the first argument of GetTrackerCount is nil
    -- This function is not necessary, but available if your custom function is simple and doesn't change the way each tracker is calculated.
    --local count =  GetTrackerCount(_, trackers[1])
    
    return GetTrackerCount(_, trackers[1])
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

    buttonAlert = [[function(info, colors)
    -- info.title
    -- info.oldCount
    -- info.newCount
    -- info.difference
    -- info.lost
    -- info.gained
    -- info.objective
    -- info.objectiveMet
    -- info.newObjectiveMet
    -- info.reps
    -- colors.red = "|cffff0000"
    -- colors.green = "|cff00ff00"
    -- colors.gold = "|cffffcc00"
    
    
    -- Button progress helpers
    local diffColor = info.gained and colors.green or colors.red -- Color the sign green if gained or red if lost
    local sign = info.gained and "+" or "" -- no need to use "-" because it's included in info.difference
    
    
    if info.objective > 0  then -- Button progress, with objective
        
        if  info.newObjectiveMet and info.objectiveMet then -- Button progress, objective met
            
            return format("%sObjective complete!|r %s %s%d/%d|r x%d", colors.green,  info.title, colors.green, info.newCount, info.objective, info.reps)
            
        else -- Button progress, objective not met or already met
            
            local countColor = info.objectiveMet and colors.green or colors.gold
            
            return format("%sFarming update:|r %s %s%d/%d|r (%s%s%d|r)", colors.gold,  info.title, countColor,  info.newCount, info.objective, diffColor, sign, info.difference) 
            
        end
        
    else -- Button progress, without objective
        
        return format("%sFarming update:|r %s %sx%d|r (%s%s%d|r)", colors.gold, info.title, colors.gold,  info.newCount, diffColor, sign, info.difference)
        
    end
    
    
end]],

    barAlert = [[function(info, colors)
    -- info.barID
    -- info.label
    -- info.lost
    -- info.gained
    -- info.difference
    -- info.oldProgress
    -- info.oldTotal
    -- info.newProgress
    -- info.newTotal
    -- info.newComplete
    -- colors.red = "|cffff0000"
    -- colors.green = "|cff00ff00"
    -- colors.gold = "|cffffcc00"
    
    
    if info.newComplete then -- Bar complete
        
        return format("%sBar complete!|r Bar %d %s%d/%d|r", colors.green, info.barID, colors.green, info.newProgress, info.newTotal)
        
    else     -- Bar progress   
        
        local diffColor = info.gained and colors.green or colors.red -- Color the sign green if gained or red if lost
        local sign = info.gained and "+" or "" -- no need to use "-" because it's included in info.difference
        
        return format("%sBar progress:|r Bar %d %s%d/%d|r (%s%s%d|r)", colors.gold, info.barID, colors.gold, info.newProgress, info.newTotal, diffColor, sign, info.difference)
        
    end
    
    
end]],
}

function private:InitializeDatabase()
    if FarmingBarDB and FarmingBarDB.global.version and FarmingBarDB.global.version < 5 then
        private.backup = FarmingBarDB
    end

    private.db = LibStub("AceDB-3.0"):New("FarmingBarDevDB", {
        global = {
            version = 5,
            debug = {
                enabled = false,
                enabled = true,
            },
            settings = {
                alerts = {
                    button = {
                        sound = true,
                        chat = true,
                        screen = true,
                        format = private.defaults.buttonAlert,
                        alertInfo = {
                            title = "Test Alert",
                            oldCount = 0,
                            newCount = 3,
                            difference = 0,
                            lost = false,
                            gained = true,
                            objective = 20,
                            objectiveMet = false,
                            newObjectiveMet = true,
                            reps = 0,
                        },
                    },
                    bar = {
                        sound = true,
                        chat = true,
                        screen = true,
                        format = private.defaults.barAlert,
                        alertInfo = {
                            barID = 1,
                            label = "Test Bar",
                            lost = false,
                            gained = true,
                            difference = 1,
                            oldProgress = 0,
                            oldTotal = 1,
                            newProgress = 1,
                            newTotal = 1,
                            newComplete = true,
                        },
                    },
                    sounds = {
                        objectiveSet = L["Quest Activate"],
                        objectiveCleared = L["Quest Failed"],
                        barProgress = L["Auction Open"],
                        barComplete = L["Auction Close"],
                        progress = L["Loot Coin"],
                        objectiveMet = L["Quest Complete"],
                    },
                },
                tooltips = {
                    useGameTooltip = false,
                    modifier = "Alt",
                    showDetails = false,
                    showHints = true,
                    showLink = true,
                },
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
            templates = {},
            skins = private.defaults.skins,
        },
        profile = {
            enabled = true,
            chatFrame = "ChatFrame1",
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

    private.db.RegisterCallback(addon, "OnProfileChanged", "OnProfile_")
    private.db.RegisterCallback(addon, "OnProfileCopied", "OnProfile_")
    private.db.RegisterCallback(addon, "OnProfileReset", "OnProfile_")

    if private.backup then
        if private.backup.global.version == 4 then
            private:ConvertDB_V4()
        elseif private.backup.global.version == 3 then
            private:ConvertDB_V3()
        end
    end
end
