local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)

local function GetGoalColor(completed)
    return completed and addon.ChatColors["GREEN"] or addon.ChatColors["GOLD"]
end

local function GetProgressColor(completed)
    return completed > 0 and addon.ChatColors["GREEN"] or addon.ChatColors["GOLD"]
end

local function GetIncludeCount(trackers, include)
    local count = 0

    for _, tracker in pairs(trackers) do
        if type(tracker[include]) ~= "table" then
            count = count + (tracker[include] and 1 or 0)
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
    if not private.db.global.settings.tooltips.button then
        return
    end

    local barDB, buttonDB = widget:GetDB()
    local barID, buttonID = widget:GetID()
    local showDetails = private.db.global.settings.tooltips.showDetails or _G["Is" .. private.db.global.settings.tooltips.modifier .. "KeyDown"]()
    local showHints = private.db.global.settings.tooltips.showHints or _G["Is" .. private.db.global.settings.tooltips.modifier .. "KeyDown"]()
    local isEmpty = widget:IsEmpty()
    local lines = {}

    if isEmpty then
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
                v = addon:iformat(private:GetObjectiveWidgetCount(widget), 1, true),
            },
            {
                double = true,
                k = L["Goal"],
                v = objective > 0 and addon:iformat(objective, 1) or "-",
            },
            {
                double = true,
                k = L["Trackers"],
                v = addon:tcount(trackers),
            },
        }

        private:InsertPendingTooltipLines(lines, pendingLines)

        -- Trackers
        for trackerKey, tracker in pairs(trackers) do
            if trackerKey <= 5 or showDetails then
                local trackerIcon
                if tracker.type == "ITEM" then
                    trackerIcon = GetItemIcon(tracker.id)
                elseif tracker.type == "CURRENCY" then
                    local currency = C_CurrencyInfo.GetCurrencyInfo(tracker.id)
                    trackerIcon = currency and currency.iconFileID
                end

                local count = private:GetTrackerCount(tracker, nil, nil, 1)
                local totalTrackerGoal = private:GetTrackerObjectiveCount(widget, trackerKey)
                local completed = floor(count / tracker.objective)

                local progressColor = GetProgressColor(completed)
                local countStr = format("%s (%s%s/%s|r)", addon:ColorFontString(addon:iformat(completed, 1), progressColor), progressColor, addon:iformat(count, 1), addon:iformat(tracker.objective, 1))
                if totalTrackerGoal > 0 then
                    countStr = format("%s (%s%s/%s|r) [%s]", addon:ColorFontString(completed, progressColor), progressColor, addon:iformat(count, 1), addon:iformat(tracker.objective, 1), addon:ColorFontString(addon:iformat(totalTrackerGoal, 1), GetGoalColor(count >= totalTrackerGoal)))
                end

                tinsert(pendingLines, {
                    double = true,
                    color = private.CONST.TOOLTIP_KEYVALUE2,
                    k = addon:GetSubstring(tracker.name, 30) or L["Tracker"] .. " " .. trackerKey,
                    v = countStr,
                })

                tinsert(pendingLines, {
                    texture = true,
                    line = trackerIcon or 134400,
                    tier = C_TradeSkillUI.GetItemReagentQualityByItemInfo(tracker.id),
                })
            else
                tinsert(pendingLines, {
                    line = format(L["%d more..."], addon:tcount(trackers) - 5),
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
                v = addon:GetSubstring(buttonDB.title, 15),
                hidden = not showDetails,
            },
            {
                double = true,
                k = L["Include Bank"],
                v = format("%d/%d", GetIncludeCount(trackers, "includeBank"), addon:tcount(trackers)),
                hidden = not showDetails,
            },
            {
                double = true,
                k = L["Include Warbank"],
                v = format("%d/%d", GetIncludeCount(trackers, "includeWarbank"), addon:tcount(trackers)),
                hidden = not showDetails or select(4, GetBuildInfo()) < 110000,
            },
            {
                double = true,
                k = L["Include Alts"],
                v = format("%d/%d", GetIncludeCount(trackers, "includeAlts"), addon:tcount(trackers)),
                hidden = not showDetails or private:MissingDataStore(),
            },
            {
                double = true,
                k = L["Include All Factions"],
                v = format("%d/%d", GetIncludeCount(trackers, "includeAllFactions"), addon:tcount(trackers)),
                hidden = not showDetails or private:MissingDataStore(),
            },
            {
                double = true,
                k = L["Include Guild Bank"],
                v = format("%d/%d", GetIncludeCount(trackers, "includeGuildBank"), addon:tcount(trackers)),
                hidden = not showDetails or private:MissingDataStore(),
            },
            private:GetTooltipBlankLine(not showDetails),
            {
                double = true,
                k = L["OnUse"],
                v = L[addon:StringToTitle(buttonDB.onUse.type)],
                hidden = not showDetails,
            },
            {
                line = addon:GetSubstring(onUsePreview, 30),
                hidden = not showDetails or onUseType == "NONE",
            },
            {
                texture = true,
                line = onUseIcon or 134400,
                tier = C_TradeSkillUI.GetItemReagentQualityByItemInfo(buttonDB.onUse.itemID),
                hidden = not showDetails or onUseType ~= "ITEM",
            },
            private:GetTooltipBlankLine(not showDetails),
            {
                double = true,
                k = L["Condition"],
                v = L[addon:StringToTitle(buttonDB.condition.type)],
                hidden = not showDetails,
            },
            {
                line = addon:GetSubstring(buttonDB.condition.func, 30),
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
            {
                double = true,
                k = L["Expand Tooltip"],
                v = L[private.db.global.settings.tooltips.modifier],
                hidden = showDetails,
            },
        }

        private:InsertPendingTooltipLines(lines, pendingLines)
    end

    pendingLines = {
        {
            color = private.CONST.TOOLTIP_TITLE,
            line = L["Hints"],
            hidden = not showDetails and not showHints,
        },
    }

    for action, actionInfo in pairs(private.db.global.settings.keybinds) do
        local showCurrency = action == "showQuickAddCurrencyEditBox" and private:IsCurrencySupported()
        local validEmptyAction = isEmpty and (action == "showQuickAddEditBox" or action == "showObjectiveEditor" or showCurrency)
        local validNotEmptyAction = (not isEmpty) and (action ~= "showQuickAddCurrencyEditBox" or showCurrency)

        if validEmptyAction or validNotEmptyAction then
            tinsert(pendingLines, {
                line = L.ButtonHints(action, actionInfo),
                hidden = not showDetails and not showHints,
            })
        end
    end

    private:InsertPendingTooltipLines(lines, pendingLines)

    return lines
end
