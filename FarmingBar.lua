local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)

--[[ OnInitialize ]]
function addon:OnInitialize()
    private:InitializeDatabase()
    private:InitializeSlashCommands()
    private:InitializeOptions()
    private:RegisterMedia()
    private:RegisterDataObject()
    private:InitializeTooltip()
    private:InitializeObjectiveFrame()
    private:InitializeMasque()
    private.bars = {}
end

--[[ OnEnable ]]
function addon:OnEnable()
    private:InitializeBars()
    addon:RegisterEvent("CURSOR_CHANGED")
    addon:RegisterEvent("SPELL_UPDATE_COOLDOWN")

    if private.db.global.debug.enabled then
        C_Timer.After(1, private.StartDebug)
    end
end

function addon:OnDisable()
    private:ReleaseAllBars()
    private:RefreshOptions("settings")
    addon:UnregisterEvent("CURSOR_CHANGED")
    addon:UnregisterEvent("SPELL_UPDATE_COOLDOWN")
end

--[[ StartDebug ]]
function private:StartDebug()
    private:LoadOptions("settings")
end

function addon:OnProfile_(...)
    addon:SetEnabledState(private.db.profile.enabled)
    private:InitializeBars()
    private:RefreshOptions("profiles")
end

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
    },
}

private.CONST = {
    MIN_FONT_SIZE = 8,
    MAX_FONT_SIZE = 64,

    MIN_SCALE = 0.25,
    MAX_SCALE = 4,

    MAX_BUTTONS = 72,
    MIN_PADDING = -3,
    MAX_PADDING = 20,
    MIN_BUTTON_SIZE = 25,
    MAX_BUTTON_SIZE = 64,

    MIN_MAX_XOFFSET = 24,
    MIN_MAX_YOFFSET = 24,

    MAX_ICONS = 500,

    TOOLTIP_DESC = { 1, 1, 1 },
    TOOLTIP_KEYVALUE = { 1, 0.82, 0, 1, 1, 1 },
    TOOLTIP_KEYVALUE2 = { 1, 1, 1, 1, 1, 1 },
    TOOLTIP_TITLE = { 1, 0.82, 0 },
}

private.lists = {
    conditionType = {
        ALL = L["All"],
        ANY = L["Any"],
        CUSTOM = L["Custom"],
    },

    iconType = {
        AUTO = L["Auto"],
        FALLBACK = L["Fallback"],
    },

    onUseType = {
        ITEM = L["Item"],
        NONE = L["None"],
        MACROTEXT = L["Macrotext"],
    },

    newTrackerType = {
        ITEM = L["Item"],
        CURRENCY = L["Currency"],
    },

    modifiers = {
        alt = L["Alt"],
        ctrl = L["Control"],
        shift = L["Shift"],
    },

    Modifiers = {
        Alt = L["Alt"],
        Control = L["Control"],
        Shift = L["Shift"],
    },

    mouseButtons = {
        LeftButton = L["Left Button"],
        RightButton = L["Right Button"],
    },

    anchors = {
        CENTER = "CENTER",
        TOPLEFT = "TOPLEFT",
        TOPRIGHT = "TOPRIGHT",
        TOP = "TOP",
        BOTTOMLEFT = "BOTTOMLEFT",
        BOTTOMRIGHT = "BOTTOMRIGHT",
        BOTTOM = "BOTTOM",
        LEFT = "LEFT",
        RIGHT = "RIGHT",
    },

    barAnchor = {
        TOPLEFT = "TOPLEFT",
        TOPRIGHT = "TOPRIGHT",
        BOTTOMLEFT = "BOTTOMLEFT",
        BOTTOMRIGHT = "BOTTOMRIGHT",
    },

    buttonGrowth = {
        ROW = "ROW",
        COL = "COL",
    },

    outlines = {
        MONOCHROME = L["Monochrome"],
        OUTLINE = L["Outline"],
        THICKOUTLINE = L["Thick Outline"],
        NONE = NONE,
    },

    alertColors = {
        red = LibStub("LibAddonUtils-1.0").ChatColors["RED"],
        green = LibStub("LibAddonUtils-1.0").ChatColors["GREEN"],
        gold = LibStub("LibAddonUtils-1.0").ChatColors["GOLD"],
    },

    buttonTextures = {
        backdrop = L["Backdrop"],
        gloss = L["Gloss"],
        highlight = L["Highlight"],
        icon = L["Icon"],
        iconBorder = L["Icon Border"],
        normal = L["Normal"],
        pushed = L["Pushed"],
        shadow = L["Shadow"],
    },

    blendModes = {
        DISABLE = L["Disable"],
        BLEND = L["Blend"],
        ALPHAKEY = L["AlphaKey"],
        ADD = L["Add"],
        MOD = L["Mod"],
    },

    drawLayers = {
        BACKGROUND = "Background",
        BORDER = "Border",
        ARTWORK = "Artwork",
        OVERLAY = "Overlay",
        HIGHLIGHT = "Highlight",
    },
}

--[[ Slash Commands ]]
function private:InitializeSlashCommands()
    for command, enabled in pairs(private.db.global.settings.commands) do
        if enabled then
            addon:RegisterChatCommand(command, "HandleSlashCommand")
        else
            addon:UnregisterChatCommand(command)
        end
    end

    addon:RegisterChatCommand("craft", "CraftTradeSkill")
end

function addon:HandleSlashCommand(input)
    private:LoadOptions()
end

local tradeskillIDs = {
    FIRSTAID = 129,
    BLACKSMITHING = 164,
    LEATHERWORKING = 165,
    ALCHEMY = 171,
    HERBALISM = 182,
    COOKING = 185,
    MINING = 186,
    TAILORING = 197,
    ENGINEERING = 202,
    ENCHANTING = 333,
    FISHING = 356,
    SKINNING = 393,
    JEWELCRAFTING = 755,
    INSCRIPTION = 773,
    ARCHEOLOGY = 794,
}

function private:CraftRecipe(recipeName)
    for _, id in pairs(C_TradeSkillUI.GetAllRecipeIDs()) do
        local recipeInfo = C_TradeSkillUI.GetRecipeInfo(id)
        if strupper(recipeInfo.name) == recipeName then
            C_TradeSkillUI.CraftRecipe(recipeInfo.recipeID)
            return
        end
    end

    addon:Print(L.UnknownRecipe(recipeName))
end

function addon:CraftTradeSkill(input)
    input = strupper(input)
    local inputTable = { strsplit(" ", input) }
    local skillID = inputTable[1]
    tremove(inputTable, 1)
    local recipeName = strjoin(" ", unpack(inputTable))

    if strfind(input, "^FIRST AID ") then
        skillID = "FIRSTAID"
        recipeName = recipeName == "AID" and nil or gsub(recipeName, "^AID ", "")
    end
    skillID = tradeskillIDs[strupper(skillID)]

    if not skillID then
        addon:Print(L.InvalidCraftSkillID)
        return
    elseif not recipeName or recipeName == "" then
        addon:Print(L.MissingCraftRecipeName)
        return
    end

    if not C_TradeSkillUI.IsTradeSkillReady() then
        C_TradeSkillUI.OpenTradeSkill(skillID)
        private:CraftRecipe(recipeName)
        C_TradeSkillUI.CloseTradeSkill()
    else
        private:CraftRecipe(recipeName)
    end
end

--[[ Item/Currency ]]
private.CacheItemCo = function(itemID)
    if not itemID then
        return
    end

    C_Timer.NewTicker(0.1, function(self)
        if GetItemInfo(itemID) then
            self:Cancel()
            return
        end
    end)
    coroutine.yield(itemID)
end

function private:CacheItem(itemID)
    local co = coroutine.create(private.CacheItemCo)
    local _, cachedItemID = coroutine.resume(co, itemID)
    while not cachedItemID do
        _, cachedItemID = coroutine.resume(co, itemID)
    end
end

function private:ValidateCurrency(currencyID)
    if tonumber(currencyID) then
        if C_CurrencyInfo.GetCurrencyInfo(currencyID) then
            return tonumber(currencyID)
        end
    else
        local currency = C_CurrencyInfo.GetCurrencyInfoFromLink(currencyID)
        if currency then
            return C_CurrencyInfo.GetCurrencyIDFromLink(currencyID)
        end
    end
end

function private:ValidateItem(itemID)
    local _, itemLink = GetItemInfo(itemID)
    if itemLink then
        local itemString = select(3, strfind(itemLink, "|H(.+)|h"))
        local _, itemId = strsplit(":", itemString)
        return tonumber(itemId)
    end
end

--[[ String Manipulation ]]
function private:IncrementString(str, obj, validateFunc)
    local func = validateFunc and obj[validateFunc] or _G[validateFunc]
    if func(obj, str) then
        local i = 2
        while true do
            local newStr = format("%s %d", str, i)

            if not func(obj, newStr) then
                return newStr
            else
                i = i + 1
            end
        end
    else
        return str
    end
end

function private:GetSubstring(str, len)
    str = str or ""
    return strsub(str, 1, len) .. (strlen(str) > len and "..." or "")
end

function private:StringToTitle(str)
    local strs = { strsplit(" ", str) }

    for key, Str in pairs(strs) do
        strs[key] = strupper(strsub(Str, 1, 1)) .. strlower(strsub(Str, 2, strlen(Str)))
    end

    return table.concat(strs, " ")
end

--[[ Static Popups ]]
function private:ShowConfirmationDialog(msg, onAccept, onCancel, args1, args2)
    StaticPopupDialogs["FARMINGBAR_CONFIRMATION_DIALOG"] = {
        text = msg,
        button1 = L["Confirm"],
        button2 = CANCEL,
        OnAccept = function()
            if onAccept then
                onAccept(addon.unpack(args1, {}))
            end
        end,
        OnCancel = function()
            if onCancel then
                onCancel(addon.unpack(args2, {}))
            end
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }

    StaticPopup_Show("FARMINGBAR_CONFIRMATION_DIALOG")
end

--[[ Misc ]]
function private:GetModifierString()
    local modifier = ""
    if IsShiftKeyDown() then
        modifier = "shift"
    end
    if IsControlKeyDown() then
        modifier = "ctrl" .. (modifier ~= "" and "-" or "") .. modifier
    end
    if IsAltKeyDown() then
        modifier = "alt" .. (modifier ~= "" and "-" or "") .. modifier
    end
    return modifier
end

function private:ValidateConditionFunc(value)
    local func = loadstring("return " .. value)
    if type(func) == "function" then
        local success, userFunc = pcall(func)
        if success and type(userFunc) == "function" then
            return true
        else
            return L["Custom Condition: Invalid function"]
        end
    else
        return L["Custom Condition: Syntax error"]
    end
end
