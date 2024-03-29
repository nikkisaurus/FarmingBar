local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)

function private:CopySkin(sourceSkinName, destSkinName)
    private.db.global.skins[destSkinName] = addon:CloneTable(private.db.global.skins[sourceSkinName])
end

function private:CreateSkin(skinName, skin)
    local newSkinName = addon:IncrementString(skinName, function(str, private)
        return private:SkinExists(str)
    end, { private })
    private.db.global.skins[newSkinName] = addon:CloneTable(skin or private.defaults.skins.FarmingBar_Default)
    private:RefreshOptions()
    return newSkinName
end

function private:RemoveSkin(skinName)
    for barID, barDB in pairs(private.db.profile.bars) do
        if barDB.skin == skinName then
            private.db.profile.bars[barID].skin = "FarmingBar_Default"
            local bar = private.bars[barID]
            bar:SetBackdrop()
            bar:UpdateButtonTextures()
        end
    end
    private.db.global.skins[skinName] = nil
end

function private:SkinExists(skinName)
    return private.db.global.skins[skinName]
end

function private:UpdateBarSkins(skinName)
    for barID, barDB in pairs(private.db.profile.bars) do
        if barDB.skin == skinName then
            local bar = private.bars[barID]
            bar:SetBackdrop()
            bar:UpdateButtonTextures()
        end
    end
end
