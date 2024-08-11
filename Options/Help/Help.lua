local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)

function private:GetWidget(i, key, value)
    local Type = value[1]

    if Type == 1 then
        -- String
        return {
            order = i,
            type = "description",
            name = value[2],
        }
    elseif Type == 2 then
        local group = {
            order = i,
            type = "group",
            name = value[2],
            args = {},
        }

        local x = 1
        for Key, Value in pairs(value[3]) do
            group.args["Key" .. Key] = private:GetWidget(x, Key, Value)
            x = x + 1
        end

        return group
    elseif Type == 3 then
        -- Header
        return {
            order = i,
            type = "description",
            name = addon.ColorFontString(value[2], "GOLD"),
            fontSize = "medium",
        }
    end
end

function private:GetHelpOptions()
    local options = {}

    local i = 1
    for key, value in pairs(L.OptionsHelp()) do
        options["key" .. key] = private:GetWidget(i, key, value)

        i = i + 1
    end

    return options
end
