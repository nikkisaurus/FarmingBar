local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)
local AceGUI = LibStub("AceGUI-3.0")
local LSM = LibStub("LibSharedMedia-3.0")

function addon:SPELL_UPDATE_COOLDOWN()
    for _, bar in pairs(private.bars) do
        for _, button in pairs(bar:GetButtons()) do
            local barDB, buttonDB = button:GetDB()
            if not button:IsEmpty() and barDB.showCooldown and buttonDB.onUse.type == "ITEM" then
                local startTime, duration, enable = GetItemCooldown(buttonDB.onUse.itemID)
                button.cooldown:SetDrawEdge(barDB.fontstrings.Cooldown.showEdge)
                button.cooldown:SetCooldown(startTime, duration)
                button.cooldown:Show()
            else
                button.cooldown:SetCooldown(0, 0)
                button.cooldown:Hide()
            end
        end
    end
end

function addon:CURSOR_CHANGED()
    for _, bar in pairs(private.bars) do
        bar:SetMouseover()
    end
end

function private:InitializeBars()
    private.bars = {}

    for barID, barDB in pairs(private.db.profile.bars) do
        local bar = AceGUI:Create("FarmingBar_Bar")
        bar:SetID(barID)
        private.bars[barID] = bar
    end

    addon:SPELL_UPDATE_COOLDOWN()
end

function private:AddBar()
    local barDB = addon.CloneTable(private.defaults.bar)
    local styleDB = private.db.profile.style

    barDB.buttonSize = styleDB.buttons.size
    barDB.buttonPadding = styleDB.buttons.padding

    for _, fontstring in pairs(barDB.fontstrings) do
        fontstring.face = styleDB.font.face
        fontstring.outline = styleDB.font.outline
        fontstring.size = styleDB.font.size
    end

    local pos = tinsert(private.db.profile.bars, barDB)
    local barID = #private.db.profile.bars

    local bar = AceGUI:Create("FarmingBar_Bar")
    bar:SetID(barID)
    private.bars[barID] = bar

    addon:SPELL_UPDATE_COOLDOWN()

    return barID
end

local exclude = {
    label = true,
    buttons = true,
    point = true,
}
function private:CopyBarDB(sourceID, destID)
    for key, value in pairs(private.db.profile.bars[sourceID]) do
        if not exclude[key] then
            private.db.profile.bars[destID][key] = addon.CloneTable(value)
        end
    end

    private.bars[destID]:Update()
end

function private:GetBarName(barID)
    local barDB = private.db.profile.bars[barID]
    return L["Bar"] .. " " .. barID, barDB.title
end

function private:RemoveBar(barID)
    private:ReleaseAllBars()
    tremove(private.db.profile.bars, barID)
    private:InitializeBars()
end

function private:ReleaseAllBars()
    for _, bar in pairs(private.bars) do
        bar:Release()
    end
end

function private:DuplicateBar(barID)
    local newBarID = private:AddBar()
    private:CopyBarDB(barID, newBarID)
    return newBarID
end

function private:ValidateHiddenFunc(value)
    local func = loadstring("return " .. value)
    if type(func) == "function" then
        local success, userFunc = pcall(func)
        if success and type(userFunc) == "function" then
            return true
        else
            return L["Hidden must be a function returning a boolean value."]
        end
    else
        return L["Hidden must be a function returning a boolean value."]
    end
end
