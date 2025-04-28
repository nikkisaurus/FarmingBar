local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)
local LSM = LibStub("LibSharedMedia-3.0")

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

    GAME_VERSION = select(4, GetBuildInfo()),
    VERSION = "4.2.1",
}

private.iconTiers = {
    [0] = { 18 / 64, 35 / 64, 18 / 64, 32 / 64 },
    [1] = { 36 / 64, 52 / 64, 18 / 64, 32 / 64 },
    [2] = { 18 / 64, 35 / 64, 34 / 64, 48 / 64 },
    [3] = { 18 / 64, 35 / 64, 48 / 64, 62 / 64 },
    [4] = { 36 / 64, 52 / 64, 34 / 64, 48 / 64 },
    [5] = { 36 / 64, 52 / 64, 48 / 64, 62 / 64 },
}

private.lists = {
    conditionType = {
        ALL = ALL,
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
        red = LibStub("LibAddonUtils-2.0").ChatColors["RED"],
        green = LibStub("LibAddonUtils-2.0").ChatColors["GREEN"],
        gold = LibStub("LibAddonUtils-2.0").ChatColors["GOLD"],
    },

    buttonTextures = {
        backdrop = L["Backdrop"],
        gloss = L["Gloss"],
        highlight = L["Highlight"],
        icon = L["Icon"],
        iconBorder = L["Icon Border"],
        iconTier = L["Icon Tier"],
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

local function MSQ_Callback(...)
    for _, bar in pairs(private.bars) do
        bar:UpdateButtonTextures()
    end
end

function addon:BANKFRAME_CLOSED()
    private.status.bankOpen = false
end

function addon:BANKFRAME_OPENED()
    private.status.bankOpen = true
end

function private:GetGameVersion()
    return private.CONST.GAME_VERSION
end

function private:GetMixedBarDBValues(info, path, path2)
    local key = info[#info]
    if info.option.type == "toggle" then
        local count, total = 0, 0
        for barID, bar in pairs(private.bars) do
            local barDB = bar:GetDB()
            if (path2 and barDB[path][path2][key]) or (path and barDB[path][key]) or (not path and barDB[key]) then
                count = count + 1
            end
            total = total + 1
        end

        if count == 0 then
            return false
        elseif count == total then
            return true
        else
            return nil
        end
    elseif info.option.type == "select" or info.option.type == "range" then
        local value
        for _, bar in pairs(private.bars) do
            local barDB = bar:GetDB()
            if not value then
                value = (path2 and barDB[path][path2][key]) or (path and barDB[path][key]) or (not path and barDB[key])
            elseif value ~= ((path2 and barDB[path][path2][key]) or (path and barDB[path][key]) or barDB[key]) then
                return
            end
        end
        return value
    elseif info.option.type == "color" then
        local r, g, b, a
        for _, bar in pairs(private.bars) do
            local barDB = bar:GetDB()
            local R, G, B, A = unpack((path2 and barDB[path][path2][key]) or (path and barDB[path][key]) or barDB[key])
            if not r then
                r, g, b, a = R, G, B, A
            elseif r ~= R or g ~= G or b ~= B or a ~= A then
                return 1, 1, 1, 1
            end
        end
        return r, g, b, a
    end
end

function private:GetMouseFocusName()
    if private:GetGameVersion() >= 110000 then
        local frame = GetMouseFoci()
        return frame and frame[1]:GetName()
    else
        return GetMouseFocus():GetName()
    end
end

function private:InitializeMasque()
    local MSQ, MSQVersion = LibStub("Masque", true)

    if MSQ and MSQVersion >= 90002 then
        private.MSQ = {
            button = MSQ:Group(L.addonName),
        }

        private.MSQ.button:SetCallback(MSQ_Callback)
    end
end

function private:IsCurrencySupported()
    return WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC and WOW_PROJECT_ID ~= WOW_PROJECT_BURNING_CRUSADE_CLASSIC
end

if not private:IsCurrencySupported() then
    private.lists.newTrackerType.CURRENCY = nil
end

function private:RegisterMedia()
    LSM:Register(LSM.MediaType.BACKGROUND, L["UI EmptySlot White"], [[INTERFACE\BUTTONS\UI-EMPTYSLOT-WHITE]])
    LSM:Register(LSM.MediaType.BACKGROUND, L["UI ActionButton Border"], [[Interface\Buttons\UI-ActionButton-Border]])
    LSM:Register(LSM.MediaType.BACKGROUND, L["Profession Quality Icon"], [[interface/professions/professionsqualityicons]])
    LSM:Register(LSM.MediaType.BACKGROUND, L["Icon Border Thick"], [[Interface\AddOns\FarmingBar\Media\IconBorderThick]])
    LSM:Register(LSM.MediaType.BACKGROUND, L["Icon Border"], [[Interface\AddOns\FarmingBar\Media\IconBorder]])
    LSM:Register(LSM.MediaType.BORDER, L["Solid Border"], [[Interface\AddOns\FarmingBar\Media\SolidBorder]])
    LSM:Register(LSM.MediaType.SOUND, L["Auction Open"], 567482) -- id:5274
    LSM:Register(LSM.MediaType.SOUND, L["Auction Close"], 567499) -- id:5275
    LSM:Register(LSM.MediaType.SOUND, L["Loot Coin"], 567428) -- id:120
    LSM:Register(LSM.MediaType.SOUND, L["Quest Activate"], 567400) -- id:618
    LSM:Register(LSM.MediaType.SOUND, L["Quest Complete"], 567439) -- id:878
    LSM:Register(LSM.MediaType.SOUND, L["Quest Failed"], 567459) -- id:846
    LSM:Register(LSM.MediaType.SOUND, L["Select Difficulty"], 2177913)
    LSM:Register(LSM.MediaType.SOUND, L["Quest Objective Complete"], 642843)
end

function private:SetMixedBarDBValues(info, value, path, callback, path2)
    local option = (info and type(info) == "table" and info[#info]) or info
    for barID, bar in pairs(private.bars) do
        if path2 then
            private.db.profile.bars[barID][path][path2][option] = value
        elseif path then
            private.db.profile.bars[barID][path][option] = value
        else
            private.db.profile.bars[barID][option] = value
        end

        if callback and type(callback) == "function" then
            callback(barID)
        end
    end
end

function private:ShowConfirmationDialog(msg, onAccept, onCancel, args1, args2)
    StaticPopupDialogs["FARMINGBAR_CONFIRMATION_DIALOG"] = {
        text = msg,
        button1 = L["Confirm"],
        button2 = CANCEL,
        OnAccept = function()
            if onAccept then
                return onAccept(addon:unpack(args1, {}))
            end
        end,
        OnCancel = function()
            if onCancel then
                return onCancel(addon:unpack(args2, {}))
            end
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }

    StaticPopup_Show("FARMINGBAR_CONFIRMATION_DIALOG")
end

function private:StartDebug()
    private:LoadOptions("objectiveTemplates")
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
    if not itemID then
        return
    end

    local _, itemLink = GetItemInfo(itemID)
    if itemLink then
        local itemString = select(3, strfind(itemLink, "|H(.+)|h"))
        local _, itemId = strsplit(":", itemString)
        return tonumber(itemId)
    end
end
