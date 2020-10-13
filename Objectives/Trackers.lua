local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)
local AceGUI = LibStub("AceGUI-3.0", true)

--*------------------------------------------------------------------------

local function trackerID_OnEnterPressed(self)
    local ObjectiveBuilder = addon.ObjectiveBuilder
    local objectiveTitle = ObjectiveBuilder:GetSelectedObjective()
    local tracker = ObjectiveBuilder:GetSelectedTracker()
    local trackerInfo = addon:GetTrackerInfo(objectiveTitle, tracker)
    local validTrackerID = addon:ValidateObjectiveData(trackerInfo.trackerType, self:GetText())

    if validTrackerID or self:GetText() == "" then
        addon:SetTrackerDBInfo(objectiveTitle, tracker, "trackerID", trackerInfo.trackerType == "ITEM" and validTrackerID or tonumber(self:GetText()))

        self:SetText(trackerInfo.trackerID)
        self:ClearFocus()

        ObjectiveBuilder:UpdateTrackerButton(tracker)
        ObjectiveBuilder.mainContent:Refresh("trackerTab")
    else
        self:SetText(trackerInfo.trackerID)
        self:HighlightText()
        self:SetFocus()
    end
end

------------------------------------------------------------

local function trackerObjective_OnEnterPressed(self)
    local ObjectiveBuilder = addon.ObjectiveBuilder
    local objective = tonumber(self:GetText()) > 0 and tonumber(self:GetText()) or 1

    addon:SetTrackerDBInfo(ObjectiveBuilder:GetSelectedObjective(), ObjectiveBuilder:GetSelectedTracker(), "objective", objective)

    self:SetText(objective)
    self:ClearFocus()
end

------------------------------------------------------------

local function trackerType_OnValueChanged(selected)
    local ObjectiveBuilder = addon.ObjectiveBuilder
    local objectiveTitle = ObjectiveBuilder:GetSelectedObjective()
    local tracker = ObjectiveBuilder:GetSelectedTracker()

    addon:SetTrackerDBInfo(objectiveTitle, tracker, "trackerType", selected)

    ObjectiveBuilder:UpdateTrackerButton(tracker)
    ObjectiveBuilder.mainContent:Refresh("trackerTab", tracker)
end

--*------------------------------------------------------------------------

function addon:ObjectiveBuilder_LoadTrackerInfo(tracker)
    local ObjectiveBuilder = self.ObjectiveBuilder
    local tabContent = ObjectiveBuilder.trackerList.status.content
    local objectiveTitle = ObjectiveBuilder:GetSelectedObjective()

    tabContent:ReleaseChildren()

    if not objectiveTitle or not tracker then return end
    local trackerInfo = self:GetTrackerInfo(objectiveTitle, tracker)

    ------------------------------------------------------------

    --@retail@
    local trackerType = AceGUI:Create("Dropdown")
    trackerType:SetFullWidth(1)
    trackerType:SetLabel(L["Type"])
    trackerType:SetList(
        {
            ITEM = L["Item"],
            CURRENCY = L["Currency"],
        },
        {"ITEM", "CURRENCY"}
    )
    trackerType:SetValue(trackerInfo.trackerType)
    tabContent:AddChild(trackerType)

    trackerType:SetCallback("OnValueChanged", function(_, _, selected) trackerType_OnValueChanged(selected) end)
    --@end-retail@

    ------------------------------------------------------------

    local trackerID = AceGUI:Create("EditBox")
    trackerID:SetFullWidth(true)
    trackerID:SetLabel(self:GetObjectiveDataLabel(trackerInfo.trackerType))
    trackerID:SetText(trackerInfo.trackerID or "")
    tabContent:AddChild(trackerID)

    trackerID:SetCallback("OnEnterPressed", function(self) trackerID_OnEnterPressed(self) end)

    ------------------------------------------------------------

    local trackerObjective = AceGUI:Create("EditBox")
    trackerObjective:SetFullWidth(true)
    trackerObjective:SetLabel(L["Objective"])
    trackerObjective:SetText(trackerInfo.objective or "")
    tabContent:AddChild(trackerObjective)

    trackerObjective:SetCallback("OnEnterPressed", function(self) trackerObjective_OnEnterPressed(self) end)

    ------------------------------------------------------------
    local includeBank = AceGUI:Create("CheckBox")
    includeBank:SetFullWidth(true)
    includeBank:SetLabel(L["Include Bank"])
    includeBank:SetValue(trackerInfo.includeBank)
    tabContent:AddChild(includeBank)

    includeBank:SetCallback("OnValueChanged", function(self, event, ...)
        print("Cow")
    end)
end

------------------------------------------------------------

function addon:GetObjectiveDataLabel(trackerType)
    --@retail@
    return trackerType == "ITEM" and L["Item ID/Name/Link"] or L["Currency ID"]
    --@end-retail@
    --[===[@non-retail@
    return L["Item ID/Name/Link"]
    --@end-non-retail@]===]
end

------------------------------------------------------------

function addon:GetObjectiveDataTable(...)
    local dataType = select(1, ...)
    local dataID = select(2, ...)
    local callback = select(3, ...)

    if dataType == "ITEM" then
        self:CacheItem(dataID, function(dataType, dataID, callback)
            local name, _, _, _, _, _, _, _, _, icon = GetItemInfo(dataID)
            local data = {name = name, icon = icon, label = addon:GetObjectiveDataLabel(dataType), trackerType = dataType, trackerID = dataID}

            if callback then
                callback(data)
            else
                return data
            end
        end, ...)
    elseif dataType == "CURRENCY" then
        -- !Revise once Shadowlands/prepatch is live.
        local data
        if C_CurrencyInfo.GetCurrencyInfo then
            local currency = C_CurrencyInfo.GetCurrencyInfo(tonumber(dataID))
            data = {name = currency.name, icon = currency.iconFileID, label = addon:GetObjectiveDataLabel(dataType), trackerType = dataType, trackerID = dataID}
        else
            local name, _, icon = GetCurrencyInfo(dataID)
            data = {name = name, icon = icon, label = addon:GetObjectiveDataLabel(dataType), trackerType = dataType, trackerID = dataID}
        end
        if callback then
            callback(data)
        else
            return data
        end
        -- !
    end
end

------------------------------------------------------------

function addon:GetTrackerInfo(objectiveTitle, tracker)
    return FarmingBar.db.global.objectives[objectiveTitle].trackers[tracker]
end

------------------------------------------------------------

function addon:SetTrackerDBInfo(objectiveTitle, tracker, key, value)
    local keys = {strsplit(".", key)}
    local path = FarmingBar.db.global.objectives[objectiveTitle].trackers[tracker]
    for k, key in pairs(keys) do
        if k < #keys then
            path = path[key]
        end
    end
    path[keys[#keys]] = value
end

------------------------------------------------------------

function addon:ValidateObjectiveData(trackerType, trackerID)
    if trackerType == "ITEM" then
        return (GetItemInfoInstant(trackerID))
    elseif trackerType == "CURRENCY" then
        return GetCurrencyInfo(trackerID) ~= "" and GetCurrencyInfo(trackerID)
    end
end