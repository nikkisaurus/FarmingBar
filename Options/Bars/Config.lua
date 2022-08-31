local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)

function private:GetConfigOptions()
    local options = {
        newBar = {
            order = 1,
            type = "execute",
            name = NEW,
            func = function()
                local barID = private:AddBar()
                private:RefreshOptions("config", "bar" .. barID, "general")
            end,
        },
        removeBar = {
            order = 2,
            type = "select",
            style = "dropdown",
            name = REMOVE,
            values = function()
                local values = {}

                for barID, _ in addon.pairs(private.db.profile.bars) do
                    values[barID] = private:GetBarName(barID)
                end

                return values
            end,
            disabled = function()
                return addon.tcount(private.db.profile.bars) == 0
            end,
            confirm = function(_, value)
                return format(L["Are you sure you want to remove Bar \"%d\"?"], value)
            end,
            set = function(_, value)
                private:RemoveBar(value)
                private:RefreshOptions("config")
            end,
        },
    }

    local i = 100
    for barID, bar in pairs(private.db.profile.bars) do
        options["bar" .. barID] = {
            order = barID + i,
            type = "group",
            childGroups = "tab",
            name = private:GetBarName(barID),
            args = private:GetBarOptions(barID),
        }
        i = i + 1
    end

    return options
end
