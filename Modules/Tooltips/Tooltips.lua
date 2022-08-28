local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)

function private:InitializeTooltip()
    FarmingBar_Tooltip = FarmingBar_Tooltip
        or CreateFrame("GameTooltip", "FarmingBar_Tooltip", UIParent, "GameTooltipTemplate")
end

function private:GetTooltip()
    return private.db.global.settings.useGameTooltip and GameTooltip or FarmingBar_Tooltip
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
    tooltip:SetOwner(owner, anchor, x, y)
    tooltip:ClearLines()

    for _, line in pairs(lines) do
        if line.link then
            tooltip:SetHyperlink(line.line)
        elseif line.texture then
            tooltip:AddTexture(line.line, line.size)
        elseif line.double then
            tooltip:AddDoubleLine(line.k, line.v, addon.unpack(line.color, private.CONST.TOOLTIP_KEYVALUE))
        else
            local r, g, b = addon.unpack(line.color, private.CONST.TOOLTIP_DESC)
            tooltip:AddLine(line.line, r, g, b, line.wrap)
        end
    end

    tooltip:Show()
end

function private:InsertTooltipDivider(lines)
    lines = private:InsertBlankLine(lines)
    tinsert(lines, {
        texture = true,
        line = 389194,
        size = {
            width = 200,
            height = 10,
        },
    })
    return lines
end

function private:InsertBlankLine(lines)
    tinsert(lines, { line = " " })
    return lines
end
