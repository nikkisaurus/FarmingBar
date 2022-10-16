local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)

function private:GetBarTooltip(widget)
    if not private.db.global.settings.tooltips.bar then
        return
    end

    local barDB = widget:GetDB()
    local progress, progressTotal = widget:GetProgress()
    local showHints = private.db.global.settings.tooltips.showHints or _G["Is" .. private.db.global.settings.tooltips.modifier .. "KeyDown"]()
    local showDetails = private.db.global.settings.tooltips.showDetails or _G["Is" .. private.db.global.settings.tooltips.modifier .. "KeyDown"]()

    local lines = {
        {
            line = L["Bar"] .. " " .. widget:GetID(),
            color = private.CONST.TOOLTIP_TITLE,
        },
        {
            double = true,
            k = L["Bar Progress"],
            v = barDB.alerts.barProgress and (format("%d/%d", progress, progressTotal)) or L["Disabled"],
            hidden = not showDetails,
        },
        {
            double = true,
            k = L["Expand Tooltip"],
            v = L[private.db.global.settings.tooltips.modifier],
            hidden = showDetails,
        },
        {
            color = private.CONST.TOOLTIP_TITLE,
            line = L["Hints"],
            hidden = not showDetails and not showHints,
        },
        {
            line = addon:ColorFontString("Control+click", "TORQUISEBLUE") .. L[" to lock and hide anchor."],
            color = private.CONST.TOOLTIP_DESC,
            hidden = not showDetails and not showHints,
        },
        {
            line = addon:ColorFontString("Right-click", "TORQUISEBLUE") .. L[" to configure this bar."],
            color = private.CONST.TOOLTIP_DESC,
            hidden = not showDetails and not showHints,
        },
    }

    return lines
end
