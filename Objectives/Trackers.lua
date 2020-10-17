local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)
local AceGUI = LibStub("AceGUI-3.0", true)

--*------------------------------------------------------------------------

local strupper, tonumber = string.upper, tonumber

--*------------------------------------------------------------------------

local function excludeObjectives_OnEnterPressed(self)
    if IsShiftKeyDown() then
        addon:FocusNextWidget(self, "editbox", IsShiftKeyDown())
        return
    end

    local objective = self:GetText()
    local validObjective = addon:ObjectiveExists(objective)

    if validObjective then
        local ObjectiveBuilder = addon.ObjectiveBuilder
        local objectiveTitle = ObjectiveBuilder:GetSelectedObjective()
        local excluded = FarmingBar.db.global.objectives[objectiveTitle].trackers[ObjectiveBuilder:GetSelectedTracker()].exclude

        self:SetText()

        if strupper(objectiveTitle) == strupper(objective) then
            addon:ReportError(L.InvalidTrackerExclusion)
            return
        elseif addon:ObjectiveIsExcluded(excluded, objective) then
            addon:ReportError(L.ObjectiveIsExcluded)
            return
        end

        tinsert(excluded, validObjective)

        ObjectiveBuilder.mainContent:LoadExcludeList()
    else
        addon:ReportError(L.InvalidObjectiveTitle)
        self:HighlightText()
    end
end

------------------------------------------------------------

local function trackerID_OnEnterPressed(self)
    local ObjectiveBuilder = addon.ObjectiveBuilder
    local objectiveTitle = ObjectiveBuilder:GetSelectedObjective()
    local tracker = ObjectiveBuilder:GetSelectedTracker()
    local trackerInfo = addon:GetTrackerInfo(objectiveTitle, tracker)

    if not self:GetText() or self:GetText() == "" then
        -- Clear trackerID
        addon:SetTrackerDBInfo(objectiveTitle, tracker, "trackerID", "")
        self:ClearFocus()

        ObjectiveBuilder:UpdateTrackerButton(tracker)
        ObjectiveBuilder.mainContent:Refresh("trackerTab")

        addon:FocusNextWidget(self, "editbox", IsShiftKeyDown())
        return
    end

    local validTrackerID = addon:ValidateObjectiveData(trackerInfo.trackerType, self:GetText())
    if validTrackerID or self:GetText() == "" then
        local newTrackerID = trackerInfo.trackerType == "ITEM" and validTrackerID or tonumber(self:GetText())

        local trackerIDExists = addon:TrackerExists(newTrackerID)

        if trackerIDExists then
            self:SetText(trackerInfo.trackerID)

            if newTrackerID ~= trackerInfo.trackerID then
                addon:ReportError(L.TrackerIDExists(self:GetText()))

                self:HighlightText()
                self:SetFocus()
            else
                addon:FocusNextWidget(self, "editbox", IsShiftKeyDown())
            end
        else
            addon:SetTrackerDBInfo(objectiveTitle, tracker, "trackerID", newTrackerID)

            self:SetText(trackerInfo.trackerID)
            self:ClearFocus()

            ObjectiveBuilder:UpdateTrackerButton(tracker)
            ObjectiveBuilder.mainContent:Refresh("trackerTab")

            addon:FocusNextWidget(self, "editbox", IsShiftKeyDown())
        end
    else
        addon:ReportError(L.InvalidTrackerID(trackerInfo.trackerType, self:GetText()))

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

    addon:FocusNextWidget(self, "editbox", IsShiftKeyDown())
end

------------------------------------------------------------

local function trackerType_OnValueChanged(self, selected)
    local ObjectiveBuilder = addon.ObjectiveBuilder
    local objectiveTitle = ObjectiveBuilder:GetSelectedObjective()
    local tracker = ObjectiveBuilder:GetSelectedTracker()

    addon:SetTrackerDBInfo(objectiveTitle, tracker, "trackerType", selected)

    ObjectiveBuilder:UpdateTrackerButton(tracker)
    ObjectiveBuilder.mainContent:Refresh("trackerTab", tracker)

    addon:FocusNextWidget(self, "editbox")
end

--*------------------------------------------------------------------------

function addon:CreateTracker(fromCursor)
    local ObjectiveBuilder = self.ObjectiveBuilder
    local objectiveTitle = ObjectiveBuilder:GetSelectedObjective()
    local trackersTable = FarmingBar.db.global.objectives[objectiveTitle].trackers
    local trackerStatus = ObjectiveBuilder.trackerList.status

    if fromCursor then
        -- Create tracker from cursor
        local cursorType, cursorID = GetCursorInfo()
        ClearCursor()
        if cursorType == "item" and not self:TrackerExists(cursorID) then
            tinsert(trackersTable, {
                ["trackerType"] = "ITEM",
                ["trackerID"] = cursorID,
                ["objective"] = 1,
                ["includeBank"] = false,
                ["includeAllChars"] = false,
                ["exclude"] = {
                },
            })
        else
            addon:ReportError(L.TrackerIDExists(cursorID))
            return
        end
    else
        tinsert(trackersTable, {
            ["trackerType"] = "ITEM",
            ["trackerID"] = "",
            ["objective"] = 1,
            ["includeBank"] = false,
            ["includeAllChars"] = false,
            ["exclude"] = {
            },
        })
    end

    ObjectiveBuilder.mainContent:LoadTrackers()
    trackerStatus.children[#trackersTable].button.frame:Click()
    if not fromCursor then
        C_Timer.After(.01, function()
            trackerStatus.trackerID:SetFocus()
        end)
    end
end

------------------------------------------------------------

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

    trackerType:SetCallback("OnValueChanged", function(self, _, selected) trackerType_OnValueChanged(self, selected) end)
    --@end-retail@

    ------------------------------------------------------------

    local trackerID = AceGUI:Create("EditBox")
    trackerID:SetFullWidth(true)
    trackerID:SetLabel(self:GetObjectiveDataLabel(trackerInfo.trackerType))
    trackerID:SetText(trackerInfo.trackerID or "")
    tabContent:AddChild(trackerID)
    ObjectiveBuilder.trackerList.status.trackerID = trackerID

    trackerID:SetCallback("OnEnterPressed", trackerID_OnEnterPressed)

    ------------------------------------------------------------

    local trackerObjective = AceGUI:Create("EditBox")
    trackerObjective:SetFullWidth(true)
    trackerObjective:SetLabel(L["Objective"])
    trackerObjective:SetText(trackerInfo.objective or "")
    tabContent:AddChild(trackerObjective)

    trackerObjective:SetCallback("OnEnterPressed", trackerObjective_OnEnterPressed)

    ------------------------------------------------------------

    local includeBank = AceGUI:Create("CheckBox")
    includeBank:SetFullWidth(true)
    includeBank:SetLabel(L["Include Bank"])
    includeBank:SetValue(trackerInfo.includeBank)
    tabContent:AddChild(includeBank)

    includeBank:SetCallback("OnValueChanged", function(self) addon:SetTrackerDBInfo(addon.ObjectiveBuilder:GetSelectedObjective(), addon.ObjectiveBuilder:GetSelectedTracker(), "includeBank", self:GetValue()) end)

    ------------------------------------------------------------

    local includeAllChars = AceGUI:Create("CheckBox")
    includeAllChars:SetFullWidth(true)
    includeAllChars:SetLabel(L["Include All Characters"])
    includeAllChars:SetValue(trackerInfo.includeAllChars)
    if not self:IsDataStoreLoaded() then
        includeAllChars:SetDescription(L["Required"] ..": DataStore, DataStore_Auctions, DataStore_Containers, DataStore_Inventory, DataStore_Mails")
        includeAllChars:SetDisabled(true)
    end
    tabContent:AddChild(includeAllChars)

    includeAllChars:SetCallback("OnValueChanged", function(self) addon:SetTrackerDBInfo(addon.ObjectiveBuilder:GetSelectedObjective(), addon.ObjectiveBuilder:GetSelectedTracker(), "includeAllChars", self:GetValue()) end)

    ------------------------------------------------------------

    local excludeObjectives = AceGUI:Create("EditBox")
    excludeObjectives:SetFullWidth(true)
    excludeObjectives:SetLabel(L["Exclude Objective"])
    tabContent:AddChild(excludeObjectives)

    excludeObjectives:SetCallback("OnEnterPressed", excludeObjectives_OnEnterPressed)

    ------------------------------------------------------------

    local excludeListContainer = AceGUI:Create("SimpleGroup")
    excludeListContainer:SetFullWidth(true)
    excludeListContainer:SetHeight(150)
    excludeListContainer:SetLayout("Fill")
    tabContent:AddChild(excludeListContainer)

    ------------------------------------------------------------

    local excludeList = AceGUI:Create("ScrollFrame")
    excludeList:SetLayout("FB30_PaddedList")
    excludeListContainer:AddChild(excludeList)
    ObjectiveBuilder.excludeList = excludeList

    ObjectiveBuilder.mainContent:LoadExcludeList()
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
            if not currency then return end
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

function addon:DeleteTracker(selected)
    local ObjectiveBuilder = self.ObjectiveBuilder

    local trackers = {}
    for k, v in pairs(ObjectiveBuilder.trackerList.status.children) do
        if v.button.selected then
            FarmingBar.db.global.objectives[ObjectiveBuilder:GetSelectedObjective()].trackers[k] = nil
        end
    end

    -- Reindex trackers table so trackerList buttons aren't messed up
    for k, v in pairs(FarmingBar.db.global.objectives[ObjectiveBuilder:GetSelectedObjective()].trackers) do
        tinsert(trackers, v)
    end
    FarmingBar.db.global.objectives[ObjectiveBuilder:GetSelectedObjective()].trackers = trackers

    ObjectiveBuilder.mainContent:LoadTrackers()
    self:ObjectiveBuilder_LoadTrackerInfo()
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

function addon:TrackerExists(trackerID)
    for _, tracker in pairs(FarmingBar.db.global.objectives[self.ObjectiveBuilder:GetSelectedObjective()].trackers) do
        if tracker.trackerID == trackerID then
            return true
        end
    end
end

------------------------------------------------------------

function addon:ValidateObjectiveData(trackerType, trackerID)
    if trackerType == "ITEM" then
        return (GetItemInfoInstant(trackerID))
    elseif trackerType == "CURRENCY" then
        local currency = C_CurrencyInfo.GetCurrencyInfo(tonumber(trackerID) or 0)
        return currency and currency.name
    end
end