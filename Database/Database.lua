local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)

private.defaults = {
    bar = {
        alerts = {
            barProgress = false,
            chatFrame = "ChatFrame1",
            completedObjectives = true,
            muteAll = false,
        },
        alpha = 1,
        barAnchor = "TOPLEFT", -- "TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT"
        buttonGrowth = "ROW", -- "ROW", "COL"
        buttonPadding = 2,
        buttons = {},
        buttonsPerAxis = 6,
        buttonSize = 40,
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
                showEdge = false,
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
        overrideHidden = false,
        hidden = [[function()
            -- To hide this bar, return true
            -- To show this bar, return nil
            return
        end]],
        hiddenEvents = {},
        hideInCombat = false,
        label = "",
        limitMats = false,
        mouseover = false,
        movable = true,
        numButtons = 12,
        point = { "CENTER" },
        scale = 1,
        showCooldown = true,
        showEmpty = true,
        skin = "FarmingBar_Default",
    },

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

    barAlertStr = [[%gold%Bar progress:%color% %b %progressColor%%c/%t%color% (%diffColor%%d%color%)]],

    buttonAlert = [[function(info, colors)
-- info.title
-- info.oldCount
-- info.newCount
-- info.difference
-- info.lost
-- info.gained
-- info.goal
-- info.goalMet
-- info.newGoalMet
-- info.reps
-- colors.red = "|cffff0000"
-- colors.green = "|cff00ff00"
-- colors.gold = "|cffffcc00"


-- Button progress helpers
local diffColor = info.gained and colors.green or colors.red -- Color the sign green if gained or red if lost
local sign = info.gained and "+" or "" -- no need to use "-" because it's included in info.difference


if info.goal > 0  then -- Button progress, with goal
    
    if  info.newGoalMet and info.goalMet then -- Button progress, goal met
        
        return format("%sObjective complete!|r %s %s%d/%d|r x%d", colors.green,  info.title, colors.green, info.newCount, info.goal, info.reps)
        
    else -- Button progress, goal not met or already met
        
        local countColor = info.goalMet and colors.green or colors.gold
        
        return format("%sFarming update:|r %s %s%d/%d|r (%s%s%d|r)", colors.gold,  info.title, countColor,  info.newCount, info.goal, diffColor, sign, info.difference) 
        
    end
    
else -- Button progress, without goal
    
    return format("%sFarming update:|r %s %sx%d|r (%s%s%d|r)", colors.gold, info.title, colors.gold,  info.newCount, diffColor, sign, info.difference)
    
end


end]],

    buttonAlertStr = [[%if(%g>0 and %c>=%g and %C<%g,%green%Objective complete!,%gold%Farming update:)if%%color% %t %progressColor%%if(%g==0,x,)if%%c%if(%g>0,/%g,)if%%color% %if(%O>0,x%O,(%diffColor%%d%color%))if%]],

    objective = {
        condition = {
            type = "ALL", -- "ALL", "ANY", "CUSTOM"
            func = [[function(trackers, GetTrackerCount)
    -- This is the structure of the tracker table:
    --trackers = {
    --    [1] = {
    --        type = "ITEM", -- "CURRENCY"
    --        id = 0000,
    --        objective = 1,
    --        includeAllFactions = false,
    --        includeAlts = false,
    --        includeBank = false,
    --        includeWarbank = false,
    --        includeGuildBank = {
    --             ["GuildKey"] = true
    --        },
    --        altIDs = {
    --            {
    --                type = "ITEM", -- "CURRENCY"
    --                name = "",
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
        icon = {
            type = "AUTO", -- "AUTO", "FALLBACK"
            id = 134400,
        },
        mute = false,
        objective = 0,
        onUse = {
            type = "NONE", -- "ITEM", "NONE", "MACROTEXT"
            itemID = false,
            macrotext = "",
        },
        title = "",
        trackers = {},
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
                iconTier = {
                    texture = "Professions Quality Icons",
                    texCoords = { 0, 1, 0, 1 },
                    color = { 1, 1, 1, 1 },
                    blendMode = "BLEND",
                    points = { { "LEFT" } },
                    scale = 0.75,
                    drawLayer = "OVERLAY",
                    layer = 2,
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
                iconTier = {
                    texture = "Professions Quality Icons",
                    texCoords = { 0, 1, 0, 1 },
                    color = { 1, 1, 1, 1 },
                    blendMode = "BLEND",
                    points = { { "LEFT" } },
                    scale = 0.75,
                    drawLayer = "OVERLAY",
                    layer = 2,
                    hidden = false,
                },
            },
        },
    },

    tracker = {
        type = "ITEM",
        id = false,
        name = "",
        objective = 1,
        includeAllFactions = false,
        includeAlts = false,
        includeBank = false,
        includeWarbank = false,
        includeGuildBank = {},
        altIDs = {},
    },

    trackerAlert = [[function(info, colors)
        -- info.title
        -- info.trackerName
        -- info.oldCount
        -- info.newCount
        -- info.difference
        -- info.lost
        -- info.gained
        -- info.goal
        -- info.trackerGoal
        -- info.trackerGoalTotal
        -- info.goalMet
        -- info.newComplete
        -- colors.red = "|cffff0000"
        -- colors.green = "|cff00ff00"
        -- colors.gold = "|cffffcc00"
        
        
        -- Tracker progress helpers
        local diffColor = info.gained and colors.green or colors.red -- Color the sign green if gained or red if lost
        local sign = info.gained and "+" or "" -- no need to use "-" because it's included in info.difference
        
        if info.goal > 0 then -- Tracker progress, with goal
            
            if info.newComplete then -- Tracker complete, with goal
                
                return format("%sTracker complete!|r (%s) %s %s%d/%d|r (%s%s%d|r)", colors.green,  info.title, info.trackerName, colors.green, info.newCount, info.trackerGoalTotal, diffColor, sign, info.difference)
                
            else -- Tracker progress, with goal
                
                return format("%sTracker update:|r (%s) %s %s%d/%d|r (%s%s%d|r)", colors.gold,  info.title, info.trackerName, colors.gold, info.newCount, info.trackerGoalTotal, diffColor, sign, info.difference)
                
            end
            
        end
        
        -- Tracker progress, no goal
        return format("%sTracker update:|r (%s) %s %sx%d|r (%s%s%d|r)", colors.gold,  info.title, info.trackerName, colors.gold, info.newCount, diffColor, sign, info.difference)
        
    end]],

    trackerAlertStr = [[%if(%g>0 and %c>=%G and %C<%G,%green%Tracker complete!,%gold%Tracker update:)if%%color% (%t) %T %progressColor%%if(%g==0,x,)if%%c%if(%g~=0,/%G,)if%%color% (%diffColor%%d%color%)]],
}

function private:InitializeDatabase()
    if FarmingBarDB then
        if FarmingBarDB.global and FarmingBarDB.global.version then
            if FarmingBarDB.global.version == 4 then
                private.version = 4
                private.backup = FarmingBarDB
                FarmingBarDB = nil
            end
        else
            private.version = 2
            private.backup = FarmingBarDB
            FarmingBarDB = nil
        end
    end

    private.db = LibStub("AceDB-3.0"):New("FarmingBarDB", {
        global = {
            debug = {
                -- enabled = true,
            },
            settings = {
                autoLoot = false,
                includeAuctions = true,
                alerts = {
                    button = {
                        sound = true,
                        chat = true,
                        screen = true,
                        format = private.defaults.buttonAlert,
                        formatStr = private.defaults.buttonAlertStr,
                        formatType = "STRING", -- STRING, FUNC
                        alertInfo = {
                            title = "Test Alert",
                            oldCount = 0,
                            newCount = 3,
                            difference = 0,
                            lost = false,
                            gained = true,
                            goal = 20,
                            goalMet = false,
                            newGoalMet = true,
                            reps = 0,
                        },
                    },
                    bar = {
                        sound = true,
                        chat = true,
                        screen = true,
                        format = private.defaults.barAlert,
                        formatStr = private.defaults.barAlertStr,
                        formatType = "STRING", -- STRING, FUNC
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
                    tracker = {
                        sound = true,
                        chat = true,
                        screen = true,
                        format = private.defaults.trackerAlert,
                        formatStr = private.defaults.trackerAlertStr,
                        formatType = "STRING", -- STRING, FUNC
                        alertInfo = {
                            title = "Test Alert",
                            trackerName = "Test Tracker",
                            oldCount = 18,
                            newCount = 21,
                            difference = 3,
                            lost = false,
                            gained = true,
                            goal = 10,
                            trackerGoal = 2,
                            trackerGoalTotal = 20,
                            objectiveMet = true,
                            newComplete = true,
                        },
                    },
                    sounds = {
                        objectiveSet = L["Quest Activate"],
                        objectiveCleared = L["Quest Failed"],
                        barProgress = L["Auction Open"],
                        barComplete = L["Auction Close"],
                        trackerProgress = L["Select Difficulty"],
                        trackerComplete = L["Quest Objective Complete"],
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
                    bar = true,
                    button = true,
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
            templates = {},
            skins = private.defaults.skins,
        },
        profile = {
            enabled = true,
            chatFrame = (DEFAULT_CHAT_FRAME:GetName()),
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
                    abbreviateCount = false,
                },
            },
        },
    }, true)

    addon:SetEnabledState(private.db.profile.enabled)

    if private.db.global.version == 5 then
        private:ConvertDB_V5()
    end
    private.db.global.version = 7

    private.db.RegisterCallback(addon, "OnProfileChanged", "OnProfile_")
    private.db.RegisterCallback(addon, "OnProfileCopied", "OnProfile_")
    private.db.RegisterCallback(addon, "OnProfileReset", "OnProfile_")

    if private.version == 4 then
        private:ConvertDB_V4()
    elseif private.version == 2 then
        private:ConvertDB_V2()
    end
end
