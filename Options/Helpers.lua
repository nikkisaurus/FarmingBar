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

function private:GetMixedBarDBValues(info, path, path2)
    local key = info[#info]
    if info.option.type == "toggle" then
        local count, total = 0, 0
        for _, bar in pairs(private.bars) do
            local barDB = bar:GetDB()

            if (path2 and barDB[path][path2][key]) or (path and barDB[path][key]) or barDB[key] then
                count = count + 1
            end
            total = total + 1
        end

        if count == 0 then
            return false
        elseif count == total then
            return true
        else
            return nil
        end
    elseif info.option.type == "select" or info.option.type == "range" then
        local value
        for _, bar in pairs(private.bars) do
            local barDB = bar:GetDB()
            if not value then
                value = (path2 and barDB[path][path2][key]) or (path and barDB[path][key]) or barDB[key]
            elseif value ~= ((path2 and barDB[path][path2][key]) or (path and barDB[path][key]) or barDB[key]) then
                return
            end
        end
        return value
    elseif info.option.type == "color" then
        local r, g, b, a
        for _, bar in pairs(private.bars) do
            local barDB = bar:GetDB()
            local R, G, B, A = unpack((path2 and barDB[path][path2][key]) or (path and barDB[path][key]) or barDB[key])
            if not r then
                r, g, b, a = R, G, B, A
            elseif r ~= R or g ~= G or b ~= B or a ~= A then
                return 1, 1, 1, 1
            end
        end
        return r, g, b, a
    end
end

function private:SetMixedBarDBValues(info, value, path, callback, path2)
    for barID, bar in pairs(private.bars) do
        if path2 then
            private.db.profile.bars[barID][path][path2][info[#info]] = value
        elseif path then
            private.db.profile.bars[barID][path][info[#info]] = value
        else
            private.db.profile.bars[barID][info[#info]] = value
        end

        if callback and type(callback) == "function" then
            callback(barID)
        end
    end
end
