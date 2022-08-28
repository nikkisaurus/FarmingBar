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
    LSM:Register(LSM.MediaType.BACKGROUND, "UI EmptySlot White", [[INTERFACE\BUTTONS\UI-EMPTYSLOT-WHITE]])
    LSM:Register(LSM.MediaType.BACKGROUND, "UI ActionButton Border", [[Interface\Buttons\UI-ActionButton-Border]])
    LSM:Register(LSM.MediaType.BACKGROUND, "Icon Border Thick", [[Interface\AddOns\FarmingBar\Media\IconBorderThick]])
    LSM:Register(LSM.MediaType.BACKGROUND, "Icon Border", [[Interface\AddOns\FarmingBar\Media\IconBorder]])
end

--[[ Widgets ]]
function private:AddSpecialFrame(frame, frameName)
    _G[frameName] = frame
    tinsert(UISpecialFrames, frameName)
    self[frameName] = frame
end
