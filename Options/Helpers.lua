local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)
local LSM = LibStub("LibSharedMedia-3.0")

--[[ Masque ]]
local function MSQ_Callback(...)
    for _, bar in pairs(private.bars) do
        bar:UpdateButtonTextures()
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

--[[ Media ]]
function private:RegisterMedia()
    LSM:Register(LSM.MediaType.BACKGROUND, L["UI EmptySlot White"], [[INTERFACE\BUTTONS\UI-EMPTYSLOT-WHITE]])
    LSM:Register(LSM.MediaType.BACKGROUND, L["UI ActionButton Border"], [[Interface\Buttons\UI-ActionButton-Border]])
    LSM:Register(
        LSM.MediaType.BACKGROUND,
        L["Icon Border Thick"],
        [[Interface\AddOns\FarmingBar\Media\IconBorderThick]]
    )
    LSM:Register(LSM.MediaType.BACKGROUND, L["Icon Border"], [[Interface\AddOns\FarmingBar\Media\IconBorder]])
    LSM:Register(LSM.MediaType.BORDER, L["Solid Border"], [[Interface\AddOns\FarmingBar\Media\SolidBorder]])
    LSM:Register(LSM.MediaType.SOUND, L["Auction Open"], 567482) -- id:5274
    LSM:Register(LSM.MediaType.SOUND, L["Auction Close"], 567499) -- id:5275
    LSM:Register(LSM.MediaType.SOUND, L["Loot Coin"], 567428) -- id:120
    LSM:Register(LSM.MediaType.SOUND, L["Quest Activate"], 567400) -- id:618
    LSM:Register(LSM.MediaType.SOUND, L["Quest Complete"], 567439) -- id:878
    LSM:Register(LSM.MediaType.SOUND, L["Quest Failed"], 567459) -- id:846
end

--[[ Widgets ]]
function private:AddSpecialFrame(frame, frameName)
    _G[frameName] = frame
    tinsert(UISpecialFrames, frameName)
    self[frameName] = frame
end
