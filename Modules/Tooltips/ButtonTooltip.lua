local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)

local function GetIncludeCount(trackers, include)
    local count = 0

    for _, tracker in pairs(trackers) do
        if type(tracker[include]) ~= "table" then
            count = count + 1
        else
            for _, included in pairs(tracker[include]) do
                if included then
                    count = count + 1
                    break
                end
            end
        end
    end

    return count
end

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
                v = addon.iformat(private:GetObjectiveWidgetCount(widget), 1, true),
            },
            {
                double = true,
                k = L["Objective"],
                v = objective > 0 and addon.iformat(objective, 1) or "-",
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
                local count = addon.iformat(private:GetTrackerCount(tracker), 1, true)
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
                    v = trackerObjective > 0 and format("%s/%s", count, addon.iformat(objective, 1)) or count,
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
                v = format("%d/%d", GetIncludeCount(trackers, "includeBank"), addon.tcount(trackers)),
                hidden = not showDetails,
            },
            {
                double = true,
                k = L["Include Alts"],
                v = format("%d/%d", GetIncludeCount(trackers, "includeAlts"), addon.tcount(trackers)),
                hidden = not showDetails or private:MissingDataStore(),
            },
            {
                double = true,
                k = L["Include Guild Bank"],
                v = format("%d/%d", GetIncludeCount(trackers, "includeGuildBank"), addon.tcount(trackers)),
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
                line = private:GetSubstring(onUsePreview, 30),
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
                line = private:GetSubstring(buttonDB.condition.func, 30),
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
