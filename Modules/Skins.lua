local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

--*------------------------------------------------------------------------

addon.skins = {
    FarmingBar_Default = {
        bar = {
            texture = [[INTERFACE\BUTTONS\UI-QUICKSLOT]],
            texCoords = {12/64, 52/64, 12/64, 52/64},
            color = {1, 1, 1, 1},
        },

        button = {

        },
    },

    FarmingBar_Minimal = {
        bar = {
            texture = [[INTERFACE\BUTTONS\WHITE8X8]],
            texCoords = {0, 1, 0, 1},
            color = {0, 0, 0, .5},
        },

        button = {

        },
    },
}

--*------------------------------------------------------------------------

function addon:StripBarTextures(bar)
    bar.anchor:SetTexture()
    bar.anchor:SetTexCoord(0, 1, 0, 1)
    bar.anchor:SetVertexColor(1, 1, 1, 1)
end

------------------------------------------------------------

function addon:SkinBar(bar, skin)
    self:StripBarTextures(bar)

    skin = (strmatch(skin, "^FarmingBar_") and addon.skins[skin] or FarmingBar.db.global.skins[skin]).bar

    bar.anchor:SetTexture(skin.texture)
    bar.anchor:SetTexCoord(unpack(skin.texCoords))
    bar.anchor:SetVertexColor(unpack(skin.color))
end