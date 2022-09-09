local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)

function private:GetSkinOptions(skinName)
    local skin = private.db.global.skins[skinName]

    local options = {
        copyFrom = {
            order = 1,
            type = "select",
            style = "dropdown",
            name = L["Copy From"],
            values = function()
                local values = {}

                for SkinName, _ in pairs(private.db.global.skins) do
                    if SkinName ~= skinName then
                        values[SkinName] = SkinName
                    end
                end

                return values
            end,
            sorting = function()
                local sorting = {}

                for SkinName, _ in addon.pairs(private.db.global.skins) do
                    if SkinName ~= skinName then
                        tinsert(sorting, SkinName)
                    end
                end

                return sorting
            end,
            set = function(_, value)
                private:CopySkin(value, skinName)
                private:UpdateBarSkins(skinName)
            end,
            confirm = function(_, value)
                return format(L["Are you sure you want to overwrite \"%s\" with \"%s\"?"], skinName, value)
            end,
        },
        duplicateSkin = {
            order = 2,
            type = "execute",
            name = L["Duplicate"],
            func = function()
                local newSkinName = private:IncrementString(skinName, private, "SkinExists")
                private:CopySkin(skinName, newSkinName)
                private:RefreshOptions("skins", newSkinName)
            end,
        },
        removeSkin = {
            order = 3,
            type = "execute",
            name = REMOVE,
            func = function()
                private:RemoveSkin(skinName)
                private:RefreshOptions("skins")
            end,
            confirm = function()
                return format(L["Are you sure you want to remove skin \"%s\"?"], skinName)
            end,
        },
        backdrop = {
            order = 4,
            type = "group",
            name = L["Bar Backdrop"],
            args = {
                enabled = {
                    order = 1,
                    type = "toggle",
                    name = L["Enable"],
                    get = function(info)
                        return skin.backdrop[info[#info]]
                    end,
                    set = function(info, value)
                        private.db.global.skins[skinName].backdrop[info[#info]] = value and true or false
                        private:UpdateBarSkins(skinName)
                    end,
                },
                spacer = {
                    order = 2,
                    type = "description",
                    name = " ",
                },
                bgFile = {
                    order = 3,
                    type = "select",
                    style = "dropdown",
                    dialogControl = "LSM30_Background",
                    values = AceGUIWidgetLSMlists.background,
                    name = L["Background"],
                    get = function(info)
                        return skin.backdrop.bgFile[info[#info]]
                    end,
                    set = function(info, value)
                        private.db.global.skins[skinName].backdrop.bgFile[info[#info]] = value
                        private:UpdateBarSkins(skinName)
                    end,
                },
                bgColor = {
                    order = 4,
                    type = "color",
                    hasAlpha = true,
                    name = L["Background Color"],
                    get = function(info)
                        return unpack(skin.backdrop[info[#info]])
                    end,
                    set = function(info, ...)
                        private.db.global.skins[skinName].backdrop[info[#info]] = { ... }
                        private:UpdateBarSkins(skinName)
                    end,
                },
                edgeFile = {
                    order = 5,
                    type = "select",
                    style = "dropdown",
                    dialogControl = "LSM30_Border",
                    values = AceGUIWidgetLSMlists.border,
                    name = L["Border"],
                    get = function(info)
                        return skin.backdrop.bgFile[info[#info]]
                    end,
                    set = function(info, value)
                        private.db.global.skins[skinName].backdrop.bgFile[info[#info]] = value
                        private:UpdateBarSkins(skinName)
                    end,
                },
                borderColor = {
                    order = 6,
                    type = "color",
                    hasAlpha = true,
                    name = L["Background Color"],
                    get = function(info)
                        return unpack(skin.backdrop[info[#info]])
                    end,
                    set = function(info, ...)
                        private.db.global.skins[skinName].backdrop[info[#info]] = { ... }
                        private:UpdateBarSkins(skinName)
                    end,
                },
            },
        },
        buttonTextures = {
            order = 5,
            type = "group",
            name = L["Button Textures"],
            args = {},
        },
    }

    local i = 1
    for layerName, layer in addon.pairs(skin.buttonTextures) do
        options.buttonTextures.args[layerName] = {
            order = i,
            type = "group",
            name = private.lists.buttonTextures[layerName],
            get = function(info)
                return layer[info[#info]]
            end,
            set = function(info, value)
                private.db.global.skins[skinName].buttonTextures[layerName][info[#info]] = value
                private:UpdateBarSkins(skinName)
            end,
            args = {
                texture = {
                    order = 1,
                    type = "select",
                    style = "dropdown",
                    dialogControl = "LSM30_Background",
                    values = AceGUIWidgetLSMlists.background,
                    name = L["Texture"],
                    hidden = function()
                        return layerName == "icon"
                    end,
                },
                blendMode = {
                    order = 2,
                    type = "select",
                    style = "dropdown",
                    values = private.lists.blendModes,
                    name = L["Blend Mode"],
                },
                drawLayer = {
                    order = 3,
                    type = "select",
                    style = "dropdown",
                    values = private.lists.drawLayers,
                    name = L["Draw Layer"],
                },
                layer = {
                    order = 4,
                    type = "range",
                    min = -8,
                    max = 7,
                    step = 1,
                    name = L["Layer"],
                },
                color = {
                    order = 5,
                    type = "color",
                    hasAlpha = true,
                    name = L["Background Color"],
                    get = function(info)
                        return unpack(layer[info[#info]])
                    end,
                    set = function(info, ...)
                        private.db.global.skins[skinName].buttonTextures[layerName][info[#info]] = { ... }
                        private:UpdateBarSkins(skinName)
                    end,
                },
                hidden = {
                    order = 6,
                    type = "toggle",
                    name = L["Hidden"],
                    hidden = function()
                        return layerName == "icon"
                    end,
                },
                texCoords = {
                    order = 7,
                    type = "group",
                    inline = true,
                    name = L["TexCoords"],
                    args = {},
                },
                insets = {
                    order = 8,
                    type = "group",
                    inline = true,
                    name = L["Insets"],
                    args = {},
                },
            },
        }
        i = i + 1

        for x = 1, 4 do
            local id = L.GetTexCoordID(x)

            options.buttonTextures.args[layerName].args.texCoords.args["tex" .. x] = {
                order = x,
                type = "range",
                min = 0,
                max = 1,
                step = 0.001,
                name = function(info)
                    return id
                end,
                get = function(info)
                    return layer.texCoords[x]
                end,
                set = function(info, value)
                    private.db.global.skins[skinName].buttonTextures[layerName].texCoords[x] = value
                    private:UpdateBarSkins(skinName)
                end,
            }

            options.buttonTextures.args[layerName].args.insets.args["inset" .. x] = {
                order = x,
                type = "range",
                min = -10,
                max = 10,
                step = 1,
                name = function(info)
                    return id
                end,
                get = function(info)
                    return layer.insets[strlower(id)]
                end,
                set = function(info, value)
                    private.db.global.skins[skinName].buttonTextures[layerName].insets[strlower(id)] = value
                    private:UpdateBarSkins(skinName)
                end,
            }
        end
    end

    return options
end
