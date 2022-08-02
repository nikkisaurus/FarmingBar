local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)

function private:InitializeTooltip()
    FarmingBar_Tooltip = FarmingBar_Tooltip
        or CreateFrame("GameTooltip", "FarmingBar_Tooltip", UIParent, "GameTooltipTemplate")
end

function private:GetTooltip()
    return private.db.global.settings.useGameTooltip and GameTooltip or
        FarmingBar_Tooltip
end

function private:ClearTooltip()
    local tooltip = private:GetTooltip()
    tooltip:ClearLines()
    tooltip:Hide()
end

function private:LoadTooltip(owner, anchor, x, y, lines)
    if not lines or type(lines) ~= "table" then
        return
    end

    local tooltip = private:GetTooltip()
    tooltip:ClearLines()
    tooltip:SetOwner(owner, anchor, x, y)

    for _, line in pairs(lines) do
        if line.link then
            tooltip:SetHyperlink(line.line)
        elseif line.texture then
            tooltip:AddTexture(line.line, line.size)
        elseif line.double then
            tooltip:AddDoubleLine(line.k, line.v, addon.unpack(line.color, { 1, 1, 1, 1, 1, 1 }))
        else
            tooltip:AddLine(line.line, addon.unpack(line.color, { 1, 1, 1, 1, 1, 1 }))
        end
    end

    tooltip:Show()
end
