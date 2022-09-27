local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)

function private:GetObjectiveWidgetCount(widget)
    if widget:IsEmpty() then
        return
    end

    local barDB, buttonDB = widget:GetDB()
    local _, buttonID = widget:GetID()
    local trackers = {}
    local condition = buttonDB.condition

    local count

    if condition.type == "ALL" then
        for trackerKey, trackerInfo in addon.pairs(buttonDB.trackers) do
            local trackerCount =
                private:GetTrackerCount(trackerInfo, barDB.limitMats and widget:GetBar(), barDB.limitMats and buttonID)
            count = count and min(count, trackerCount) or trackerCount
            trackers[trackerKey] = private:GetTrackerCount(
                trackerInfo,
                barDB.limitMats and widget:GetBar(),
                barDB.limitMats and buttonID,
                1
            )
        end
    elseif condition.type == "ANY" then
        for trackerKey, trackerInfo in pairs(buttonDB.trackers) do
            local trackerCount =
                private:GetTrackerCount(trackerInfo, barDB.limitMats and widget:GetBar(), barDB.limitMats and buttonID)
            count = (count or 0) + trackerCount
            trackers[trackerKey] = private:GetTrackerCount(
                trackerInfo,
                barDB.limitMats and widget:GetBar(),
                barDB.limitMats and buttonID,
                1
            )
        end
    elseif condition.type == "CUSTOM" then
        local func = loadstring("return " .. buttonDB.condition.func)
        if type(func) == "function" then
            local success, userFunc = pcall(func)
            if success and type(userFunc) == "function" then
                count = (count or 0) + (userFunc(buttonDB.trackers, private.GetTrackerCount) or 0)
            end
        end
    end

    return count, trackers
end

function private:GetObjectiveWidgetObjective(widget)
    if widget:IsEmpty() then
        return
    end

    local _, buttonDB = widget:GetDB()
    return buttonDB.objective
end

function private:GetTrackerCount(trackerInfo, bar, buttonID, overrideObjective)
    local DS = #private:GetMissingDataStoreModules() == 0

    if not trackerInfo then
        return 0
    end

    local objective = overrideObjective or trackerInfo.objective
    local count = 0
    if trackerInfo.type == "ITEM" then
        if DS then
            count = floor(private:GetDataStoreItemCount(trackerInfo.id, trackerInfo) / objective)
        else
            count = floor(GetItemCount(trackerInfo.id, trackerInfo.includeBank) / objective)
        end
    elseif trackerInfo.type == "CURRENCY" then
        local quantity
        if DS and trackerInfo.includeAlts then
            quantity = private:GetDataStoreCurrencyCount(trackerInfo.id)
        else
            local currency = C_CurrencyInfo.GetCurrencyInfo(trackerInfo.id)
            quantity = currency and floor(currency.quantity / objective) or 0
        end
        count = count + quantity
    end

    for _, altInfo in pairs(trackerInfo.altIDs) do
        local altCount

        if altInfo.type == "ITEM" then
            altCount = floor(GetItemCount(altInfo.id, trackerInfo.includeBank) * altInfo.multiplier)
        elseif altInfo.type == "CURRENCY" then
            if DS and trackerInfo.includeAlts then
                altCount = private:GetDataStoreCurrencyCount(altInfo.id)
            else
                local currency = C_CurrencyInfo.GetCurrencyInfo(altInfo.id)
                altCount = currency and floor(currency.quantity * altInfo.multiplier) or 0
            end
        end

        count = count + altCount
    end

    if bar then
        for ButtonID, button in pairs(bar:GetButtons()) do
            if ButtonID ~= buttonID and not button:IsEmpty() then
                local _, buttonDB = button:GetDB()
                for trackerKey, tracker in pairs(buttonDB.trackers) do
                    if tracker.type == trackerInfo.type and tracker.id == trackerInfo.id then
                        if buttonDB.objective > 0 then
                            count = count - private:GetTrackerObjectiveCount(button, trackerKey)
                        else
                            count = count - private:GetTrackerCount(tracker)
                        end
                    end
                end
            elseif ButtonID == buttonID then
                break
            end
        end
    end

    count = count >= 0 and count or 0

    return count, trackerInfo.objective
end

function private:GetTrackerObjectiveCount(widget, trackerKey)
    local _, buttonDB = widget:GetDB()
    local tracker = buttonDB.trackers[trackerKey]

    return buttonDB.objective * tracker.objective
end
