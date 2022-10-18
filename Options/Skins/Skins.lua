local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)

function private:GetSkinsOptions()
    local options = {
        newSkin = {
            order = 1,
            type = "input",
            name = L["New Skin"],
            set = function(_, value)
                local newSkinName = private:CreateSkin(value)
                private:RefreshOptions("skins", newSkinName)
            end,
        },
        removeSkin = {
            order = 2,
            type = "select",
            style = "dropdown",
            name = L["Remove Skin"],
            disabled = function()
                return addon:tcount(private.db.global.skins) == 2
            end,
            values = function()
                local values = {}

                for skinName, _ in pairs(private.db.global.skins) do
                    if not private.defaults.skins[skinName] then
                        values[skinName] = skinName
                    end
                end

                return values
            end,
            sorting = function()
                local sorting = {}

                for skinName, _ in addon:pairs(private.db.global.skins) do
                    if not private.defaults.skins[skinName] then
                        tinsert(sorting, skinName)
                    end
                end

                return sorting
            end,
            set = function(_, value)
                private:RemoveSkin(value)
                private:RefreshOptions()
            end,
            confirm = function(_, value)
                return format(L["Are you sure you want to remove skin \"%s\"?"], value)
            end,
        },
        note = {
            order = 3,
            type = "description",
            name = addon:ColorFontString(L["Button textures may be controlled by Masque and must be disabled through its settings for skins to be applied."], "RED"),
            hidden = function()
                return not private.MSQ
            end,
        },
    }

    local i = 1
    for skinName, skin in pairs(private.db.global.skins) do
        if not private.defaults.skins[skinName] then
            options[skinName] = {
                order = i,
                type = "group",
                name = skinName,
                childGroups = "tab",
                args = private:GetSkinOptions(skinName),
            }
            i = i + 1
        end
    end

    return options
end
