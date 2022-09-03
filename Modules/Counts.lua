local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)

function private:GetObjectiveWidgetCount(widget)
    if widget:IsEmpty() then
        return
    end

    local _, buttonDB = widget:GetDB()
    local trackers = buttonDB.trackers
    local condition = buttonDB.condition

    local count = 0

    if condition.type == "ALL" then
        for trackerKey, trackerInfo in pairs(buttonDB.trackers) do
            local trackerCount = private:GetTrackerCount(trackerInfo)
            count = count > 0 and min(count, trackerCount) or trackerCount
        end
    elseif condition.type == "ANY" then
        for trackerKey, trackerInfo in pairs(buttonDB.trackers) do
            count = count + private:GetTrackerCount(trackerInfo)
        end
    elseif condition.type == "CUSTOM" then
        local func = loadstring("return " .. buttonDB.condition.func)
        if type(func) == "function" then
            local success, userFunc = pcall(func)
            if success and type(userFunc) == "function" then
                count = count + (userFunc(buttonDB.trackers, private.GetTrackerCount) or 0)
            end
        end
    end

    return count
end

function private:GetTrackerCount(trackerInfo)
    local DS = #private:GetMissingDataStoreModules() == 0

    local count = 0
    if trackerInfo.type == "ITEM" then
        if DS then
            count = floor(private:GetDataStoreItemCount(trackerInfo.id, trackerInfo) / trackerInfo.objective)
        else
            count = floor(GetItemCount(trackerInfo.id, trackerInfo.includeBank) / trackerInfo.objective)
        end
    elseif trackerInfo.type == "CURRENCY" then
        local quantity
        if DS and trackerInfo.includeAlts then
            quantity = private:GetDataStoreCurrencyCount(trackerInfo.id)
        else
            local currency = C_CurrencyInfo.GetCurrencyInfo(trackerInfo.id)
            quantity = currency and floor(currency.quantity / trackerInfo.objective) or 0
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

    return count, trackerInfo.objective
end

function private:GetObjectiveWidgetObjective(widget)
    if widget:IsEmpty() then
        return
    end

    local _, buttonDB = widget:GetDB()
    return buttonDB.objective
end

function private:GetTrackerObjectiveCount(widget, trackerKey)
    local _, buttonDB = widget:GetDB()
    local tracker = buttonDB.trackers[trackerKey]

    return buttonDB.objective * tracker.objective
end
