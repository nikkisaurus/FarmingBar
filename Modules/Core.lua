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
end

function addon:HandleSlashCommand(input)
    private:LoadOptions()
end

--[[ Item Caching ]]
private.CacheItemCo = function(itemID)
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
