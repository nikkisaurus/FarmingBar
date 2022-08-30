local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)

function private:GetButtonTooltip(widget)
    local barDB, buttonDB = widget:GetDB()
    local barID, buttonID = widget:GetID()
    local showDetails = private.db.global.settings.tooltips.showDetails
        or _G["Is" .. private.db.global.settings.tooltips.modifier .. "KeyDown"]()
    local lines = {}

    if widget:IsEmpty() then
        local pendingLines = {
            {
                double = true,
                k = L["Button"],
                v = strjoin(":", barID, buttonID),
            },
        }

        private:InsertPendingTooltipLines(lines, pendingLines)
    else
        local link = widget:GetHyperlink()
        local trackers = buttonDB.trackers
        local objective = private:GetObjectiveWidgetObjective(widget)

        -- Link and counts
        local pendingLines = {
            {
                line = link,
                link = true,
                hidden = not private.db.global.settings.tooltips.showLink or not link,
            },
            private:GetTooltipBlankLine(not private.db.global.settings.tooltips.showLink or not link),
            private:GetTooltipTextureLine(not private.db.global.settings.tooltips.showLink or not link),
            {
                double = true,
                k = L["Count"],
                v = private:GetObjectiveWidgetCount(widget),
            },
            {
                double = true,
                k = L["Objective"],
                v = objective > 0 and objective or "-",
            },
            {
                double = true,
                k = L["Trackers"],
                v = addon.tcount(trackers),
            },
        }

        private:InsertPendingTooltipLines(lines, pendingLines)

        -- Trackers
        for trackerKey, tracker in pairs(trackers) do
            if trackerKey <= 5 or showDetails then
                local count = private:GetTrackerCount(tracker)
                local trackerObjective = private:GetTrackerObjectiveCount(widget, trackerKey)
                local trackerName, trackerIcon
                if tracker.type == "ITEM" then
                    private:CacheItem()
                    trackerName = GetItemInfo(tracker.id)
                    trackerIcon = GetItemIcon(tracker.id)
                elseif tracker.type == "CURRENCY" then
                    local currency = C_CurrencyInfo.GetCurrencyInfo(tracker.id)
                    trackerName = currency and currency.name
                    trackerIcon = currency and currency.iconFileID
                end

                tinsert(pendingLines, {
                    double = true,
                    color = private.CONST.TOOLTIP_KEYVALUE2,
                    k = private:GetSubstring(trackerName, 30) or L["Tracker"] .. " " .. trackerKey,
                    v = trackerObjective > 0 and format("%d/%d", count, objective) or count,
                })

                tinsert(pendingLines, {
                    texture = true,
                    line = trackerIcon or 134400,
                })
            else
                tinsert(pendingLines, {
                    line = format(L["%d more..."], addon.tcount(trackers) - 5),
                })
                break
            end
        end

        private:InsertPendingTooltipLines(lines, pendingLines)

        -- OnUse
        local onUseType = buttonDB.onUse.type
        local onUsePreview, onUseIcon
        if onUseType == "ITEM" then
            onUsePreview, onUseIcon = private:GetTrackerInfo(onUseType, buttonDB.onUse.itemID)
        elseif onUseType == "MACROTEXT" then
            onUsePreview = buttonDB.onUse.macrotext
        end

        -- Details
        -- includebank, includealts, includeguildbank
        pendingLines = {
            private:GetTooltipBlankLine(not showDetails),
            {
                double = true,
                k = L["Name"],
                v = private:GetSubstring(buttonDB.title, 15),
                hidden = not showDetails,
            },
            {
                double = true,
                k = L["Include Bank"],
                v = buttonDB.includeBank and L["true"] or L["false"],
                hidden = not showDetails,
            },
            {
                double = true,
                k = L["Include Alts"],
                v = buttonDB.includeAlts and L["true"] or L["false"],
                hidden = not showDetails or private:MissingDataStore(),
            },
            {
                double = true,
                k = L["Include Guild Bank"],
                v = buttonDB.includeGuildBank and L["true"] or L["false"],
                hidden = not showDetails or private:MissingDataStore(),
            },
            private:GetTooltipBlankLine(not showDetails),
            {
                double = true,
                k = L["OnUse"],
                v = L[private:StringToTitle(buttonDB.onUse.type)],
                hidden = not showDetails,
            },
            {
                line = private:GetSubstring(onUsePreview or "", 30),
                hidden = not showDetails or onUseType == "NONE",
            },
            {
                texture = true,
                line = onUseIcon or 134400,
                hidden = not showDetails or onUseType ~= "ITEM",
            },
            private:GetTooltipBlankLine(not showDetails),
            {
                double = true,
                k = L["Condition"],
                v = L[private:StringToTitle(buttonDB.condition.type)],
                hidden = not showDetails,
            },
            {
                line = private:GetSubstring(buttonDB.condition.func or "", 30),
                hidden = not showDetails or buttonDB.condition.type ~= "CUSTOM",
            },
        }

        private:InsertPendingTooltipLines(lines, pendingLines)

        -- Button ID
        pendingLines = {
            private:GetTooltipBlankLine(),
            private:GetTooltipTextureLine(),
            {
                double = true,
                k = L["Button"],
                v = strjoin(":", barID, buttonID),
            },
        }

        private:InsertPendingTooltipLines(lines, pendingLines)
    end

    return lines
end
