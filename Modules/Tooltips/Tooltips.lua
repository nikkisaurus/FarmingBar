local addonName = ...
local addon = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)


--*------------------------------------------------------------------------
-- Initialize tooltip

local FarmingBar_Tooltip = CreateFrame("GameTooltip", "FarmingBar_Tooltip", UIParent, "GameTooltipTemplate")
local tooltipScanner = CreateFrame("Frame")
local showTooltip

tooltipScanner:SetScript("OnUpdate", function(self)
    local frame = GetMouseFocus()
    local widget = frame and frame.obj
    local tooltip = widget and widget.GetUserData and widget:GetUserData("tooltip")

    addon.cursorItem = GetCursorInfo() == "item" or addon.movingButton or (addon.DragFrame and addon.DragFrame:GetObjective())
    addon:UpdateButtons(_, "SetHidden")

    if tooltip and addon[tooltip] and not addon.DragFrame:GetObjective() then
        showTooltip = true
        FarmingBar_Tooltip:ClearLines()
        FarmingBar_Tooltip:SetOwner(frame, "ANCHOR_BOTTOMRIGHT", 0, 0)
        addon[tooltip](addon, widget, FarmingBar_Tooltip)
        FarmingBar_Tooltip:Show()
    elseif showTooltip then
        showTooltip = false
        FarmingBar_Tooltip:ClearLines()
        FarmingBar_Tooltip:Hide()
    end
end)


--*------------------------------------------------------------------------
-- Methods

function addon:IsTooltipMod()
    if not self:GetDBValue("global", "settings.hints.enableModifier") then
        return true
    else
        return _G["Is" .. self:GetDBValue("global", "settings.hints.modifier") .. "KeyDown"]()
    end
end