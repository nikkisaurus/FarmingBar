local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)

function private:GetButtonTooltip(widget)
    local barDB, buttonDB = widget:GetDB()
    local barID, buttonID = widget:GetID()
    local settings = private.db.global.settings.tooltips

    local lines = {}

    if widget:IsEmpty() then
    else
        local link = widget:GetHyperlink()

        if settings.hyperlink and link then
            tinsert(lines, {
                line = link,
                link = true,
            })

            lines = private:InsertTooltipDivider(lines)
        end

        if settings.title then
            tinsert(lines, {
                color = private.CONST.TOOLTIP_TITLE,
                line = buttonDB.title,
            })
        end

        tinsert(lines, {
            double = true,
            k = L["Count"],
            v = private:GetObjectiveWidgetCount(widget),
        })

        if settings.onUse then
            lines = private:InsertBlankLine(lines)

            local onUseType = buttonDB.onUse.type

            tinsert(lines, {
                color = private.CONST.TOOLTIP_TITLE,
                line = L["OnUse"],
            })

            if onUseType ~= "NONE" then
                local line, preview
                if onUseType == "ITEM" then
                    private:CacheItem(buttonDB.onUse.itemID)
                    line = link
                    preview = (GetItemInfo(buttonDB.onUse.itemID))
                elseif onUseType == "MACROTEXT" then
                    line = L["Macrotext"]
                    preview = buttonDB.onUse.macrotext
                end

                tinsert(lines, {
                    double = true,
                    color = { 1, 1, 1, 1, 1, 1 },
                    k = line .. ":",
                    v = private:GetSubstring(preview, 15),
                })
            else
                tinsert(lines, {
                    line = NONE,
                })
            end
        end
    end

    if settings.buttonID then
        tinsert(lines, {
            double = true,
            k = L["Button"],
            v = strjoin(":", barID, buttonID),
        })
    end

    return lines
end
