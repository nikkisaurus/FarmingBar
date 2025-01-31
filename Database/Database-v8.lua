local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)

function private:ConvertDB_V8()
    for barID, barDB in pairs(private.db.profile.bars) do
        if not barDB.iconTier then
            private.db.profile.bars[barID].iconTier = {
                enabled = true,
                scale = 0.5,
                anchor = "CENTER",
                x = 5,
                y = -2,
            }
        end
    end
end
