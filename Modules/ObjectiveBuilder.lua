local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)
local AceGUI = LibStub("AceGUI-3.0", true)

local tinsert, tremove, wipe, pairs, unpack = table.insert, table.remove, table.wipe, pairs, unpack
local strfind, strformat, gsub, strupper, tonumber = string.find, string.format, string.gsub, string.upper, tonumber

--*------------------------------------------------------------------------

local function FocusNextWidget(widget, widgetType, reverse)
    local widgetKey
    for key, w in addon.pairs(widget.parent.children, reverse and function(a, b) return a > b end or function(a, b) return a < b end) do
        if w == widget then
            widgetKey = key
        elseif widgetKey and (not widgetType or w[widgetType]) then
            w:SetFocus()
            if widgetType == "editbox" then
                w:HighlightText()
            end
            return
        end
    end
end

--*------------------------------------------------------------------------

local function autoIcon_OnValueChanged(self)
    addon:SetObjectiveDBInfo((addon:GetSelectedObjectiveInfo()), "autoIcon", self:GetValue())
    addon.ObjectiveBuilder:Refresh("objectiveTab")
end

------------------------------------------------------------

local function customCondition_OnEnterPressed(self)
    addon:SetObjectiveDBInfo((addon:GetSelectedObjectiveInfo()), "trackFunc", self:GetText())
    -- !print(addon:ParseObjectiveCondition((addon:GetSelectedObjectiveInfo())))
end

------------------------------------------------------------

local function displayIcon_OnEnterPressed(self)
    addon:SetObjectiveDBInfo((addon:GetSelectedObjectiveInfo()), "icon", self:GetText())

    self:ClearFocus()

    addon.ObjectiveBuilder:Refresh("objectiveTab")
    FocusNextWidget(self, "editbox", IsShiftKeyDown())
end

------------------------------------------------------------

local function displayRefHelp_OnClick(mainContent, label)
    if label:GetText() and label:GetText() ~= " " then
        label:SetText("")
        label:SetWidth(30)
    else
        --@retail@
            label:SetText(L.DisplayReferenceDescription)
        --@end-retail@
        --[===[@non-retail@
            -- Removing the currency reference from Classic here to make the localization page cleanier/easier to translate.
            label:SetText(gsub(L.DisplayReferenceDescription, L.DisplayReferenceDescription_Gsub, ""))
        --@end-non-retail@]===]
        label:SetWidth(label.frame:GetParent():GetWidth() - 10)
    end

    mainContent:DoLayout()
end

------------------------------------------------------------

local function displayRefTrackerID_OnEnterPressed(self)
    local objectiveTitle, objectiveInfo = addon:GetSelectedObjectiveInfo()
    local validTrackerID = addon:ValidateObjectiveData(objectiveInfo.displayRef.trackerType, self:GetText())

    if validTrackerID or self:GetText() == "" then
        addon:SetObjectiveDBInfo(objectiveTitle, "displayRef.trackerID", objectiveInfo.displayRef.trackerType == "ITEM" and validTrackerID or tonumber(self:GetText()))

        self:SetText(objectiveInfo.displayRef.trackerID)
        self:ClearFocus()

        addon.ObjectiveBuilder:Refresh("objectiveTab")
        FocusNextWidget(self, "editbox", IsShiftKeyDown())
    else
        addon:ReportError(L.InvalidTrackerID(objectiveInfo.displayRef.trackerType, self:GetText()))

        self:SetText("")
        self:SetFocus()
    end
end

------------------------------------------------------------

local function displayRefTrackerType_OnValueChanged(self, selected)
    local objectiveTitle = addon:GetSelectedObjectiveInfo()

    if selected == "NONE" then
        addon:SetObjectiveDBInfo(objectiveTitle, "displayRef.trackerType", false)
        addon:SetObjectiveDBInfo(objectiveTitle, "displayRef.trackerID", false)

    else
        addon:SetObjectiveDBInfo(objectiveTitle, "displayRef.trackerType", selected)
    end

    addon.ObjectiveBuilder:Refresh("objectiveTab")
    if selected ~= "NONE" then
        FocusNextWidget(self, "editbox", IsShiftKeyDown())
    end
end

------------------------------------------------------------

local function excludeObjectives_OnEnterPressed(self)
    if IsShiftKeyDown() then
        FocusNextWidget(self, "editbox", IsShiftKeyDown())
        return
    end

    ------------------------------------------------------------

    local objective = self:GetText()
    local validObjective = addon:ObjectiveExists(objective)

    if validObjective then
        local objectiveTitle, _, _, trackerInfo = addon:GetSelectedObjectiveInfo()
        local excluded = trackerInfo.exclude

        self:SetText()

        if strupper(objectiveTitle) == strupper(objective) then
            addon:ReportError(L.InvalidTrackerExclusion)
            return
        elseif addon:ObjectiveIsExcluded(excluded, objective) then
            addon:ReportError(L.ObjectiveIsExcluded)
            return
        end

        tinsert(excluded, validObjective)

        addon.ObjectiveBuilder:LoadExcludeList()
    else
        addon:ReportError(L.InvalidObjectiveTitle)
        self:HighlightText()
    end
end

------------------------------------------------------------

local function mainTabGroup_OnGroupSelected(self, selected)
    local objectiveTitle = addon:GetSelectedObjectiveInfo()

    self:ReleaseChildren()
    if selected == "objectiveTab" then
        self:SetLayout("Fill")
        addon:ObjectiveBuilder_LoadObjectiveTab(objectiveTitle)
    elseif selected == "conditionTab" then
        self:SetLayout("Fill")
        addon:ObjectiveBuilder_LoadConditionTab(objectiveTitle)
    elseif selected == "trackersTab" then
        self:SetLayout("FB30_2RowSplitBottom")
        addon:LoadTrackersTab(objectiveTitle)
    end
end

------------------------------------------------------------

local function numericEditBox_OnTextChanged(self)
    self:SetText(string.gsub(self:GetText(), "[%s%c%p%a]", ""))
    self.editbox:SetCursorPosition(strlen(self:GetText()))
end

------------------------------------------------------------

local function objective_OnEnterPressed(self)
    local text = self:GetText() ~= "" and self:GetText() or 0
    local objective = tonumber(text) > 0 and tonumber(text)

    addon:SetObjectiveDBInfo((addon:GetSelectedObjectiveInfo()), "objective", objective)

    self:SetText(objective)
    self:ClearFocus()

    FocusNextWidget(self, "editbox", IsShiftKeyDown())
end

------------------------------------------------------------

local function trackCondition_OnValueChanged(selected)
    addon:SetObjectiveDBInfo((addon:GetSelectedObjectiveInfo()), "trackCondition", selected)
    addon.ObjectiveBuilder:Refresh("conditionTab")
end

------------------------------------------------------------

local function trackerID_OnEnterPressed(self)
    local ObjectiveBuilder = addon.ObjectiveBuilder
    local objectiveTitle, _, tracker, trackerInfo = addon:GetSelectedObjectiveInfo()

    ------------------------------------------------------------

    if not self:GetText() or self:GetText() == "" then
        -- Clear trackerID
        addon:SetTrackerDBInfo(objectiveTitle, tracker, "trackerID", "")

        self:ClearFocus()

        ObjectiveBuilder:UpdateTrackerButton(tracker)
        ObjectiveBuilder:Refresh("trackerTab")
        FocusNextWidget(self, "editbox", IsShiftKeyDown())

        return
    end

    ------------------------------------------------------------

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
                FocusNextWidget(self, "editbox", IsShiftKeyDown())
            end
        else
            addon:SetTrackerDBInfo(objectiveTitle, tracker, "trackerID", newTrackerID)

            self:SetText(trackerInfo.trackerID)
            self:ClearFocus()

            ObjectiveBuilder:UpdateTrackerButton(tracker)
            ObjectiveBuilder:Refresh("trackerTab")
            FocusNextWidget(self, "editbox", IsShiftKeyDown())
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
    local objectiveTitle, _, tracker = addon:GetSelectedObjectiveInfo()
    local text = self:GetText() ~= "" and self:GetText() or 1
    local objective = tonumber(text) > 0 and tonumber(text) or 1

    addon:SetTrackerDBInfo(objectiveTitle, tracker, "objective", objective)

    self:SetText(objective)
    self:ClearFocus()

    FocusNextWidget(self, "editbox", IsShiftKeyDown())
end

------------------------------------------------------------

local function trackerType_OnValueChanged(self, selected)
    local ObjectiveBuilder = addon.ObjectiveBuilder
    local objectiveTitle, _, tracker = addon:GetSelectedObjectiveInfo()

    addon:SetTrackerDBInfo(objectiveTitle, tracker, "trackerType", selected)

    ObjectiveBuilder:UpdateTrackerButton(tracker)
    ObjectiveBuilder:Refresh("trackerTab", tracker)
    FocusNextWidget(self, "editbox")
end

------------------------------------------------------------

local function trackFunc_OnEnterPressed(self)
    addon:SetObjectiveDBInfo((addon:GetSelectedObjectiveInfo()), "trackFunc", self:GetText())
end

--*------------------------------------------------------------------------

local function ObjectiveButton_OnClick(objectiveTitle)
    addon:ObjectiveBuilder_DrawTabs()
    addon.ObjectiveBuilder:SelectObjective(objectiveTitle)
end

------------------------------------------------------------

local function TrackerButton_OnClick(tracker)
    addon.ObjectiveBuilder.status.tracker = tracker
    addon:ObjectiveBuilder_LoadTrackerInfo(tracker)
end

--*------------------------------------------------------------------------

local function ObjectiveButton_Tooltip(self, tooltip)
    local objectiveTitle = self:GetObjectiveTitle()
    local objectiveInfo = addon:GetObjectiveInfo(objectiveTitle)
    if not objectiveInfo then return end
    local numTrackers = #objectiveInfo.trackers

    ------------------------------------------------------------

    tooltip:AddLine(objectiveTitle)

    GameTooltip_AddBlankLinesToTooltip(GameTooltip, 1)
    tooltip:AddDoubleLine(L["Enabled"], objectiveInfo.enabled and L["TRUE"] or L["FALSE"], unpack(addon.tooltip_keyvalue))
    tooltip:AddDoubleLine(L["Objective"], objectiveInfo.objective or L["FALSE"], unpack(addon.tooltip_keyvalue))

    GameTooltip_AddBlankLinesToTooltip(GameTooltip, 1)
    if objectiveInfo.displayRef.trackerType then
        -- !Try to remove this if I can set up a coroutine to handle item caching.
        addon:GetTrackerDataTable(objectiveInfo.displayRef.trackerType, objectiveInfo.displayRef.trackerID, function(data)
            tooltip:AddDoubleLine(L["Display Ref"], data.name, unpack(addon.tooltip_keyvalue))
        end)
        -- !
    else
        tooltip:AddDoubleLine(L["Display Ref"], L["NONE"], unpack(addon.tooltip_keyvalue))
    end

    GameTooltip_AddBlankLinesToTooltip(GameTooltip, 1)
    tooltip:AddDoubleLine(L["Trackers"], numTrackers, unpack(addon.tooltip_keyvalue))
    for key, trackerInfo in pairs(objectiveInfo.trackers) do
        if key > 10 then
            tooltip:AddLine(strformat("%d %s...", numTrackers - 10, L["more"]), unpack(addon.tooltip_description))
            tooltip:AddTexture(134400)
            break
        else
            -- !Try to remove this if I can set up a coroutine to handle item caching.
            addon:GetTrackerDataTable(trackerInfo.trackerType, trackerInfo.trackerID, function(data)
                tooltip:AddLine(data.name, unpack(addon.tooltip_description))
                tooltip:AddTexture(data.icon or 134400)
            end)
            -- !
        end
    end

    ------------------------------------------------------------

    GameTooltip_AddBlankLinesToTooltip(GameTooltip, 1)
    if FarmingBar.db.global.hints.ObjectiveBuilder then
        tooltip:AddLine(string.format("%s:", L["Hint"]))
        tooltip:AddLine(L.ObjectiveContextMenuHint, unpack(addon.tooltip_description))
    end
end

------------------------------------------------------------

local function TrackerButton_Tooltip(self, tooltip)
    local _, _, tracker, trackerInfo = addon:GetSelectedObjectiveInfo()
    if not trackerInfo then return end
    local numExcluded = #trackerInfo.exclude

    ------------------------------------------------------------

    tooltip:SetHyperlink(string.format("%s:%s", string.lower(trackerInfo.trackerType), trackerInfo.trackerID))

    GameTooltip_AddBlankLinesToTooltip(GameTooltip, 1)
    tooltip:AddDoubleLine(L["Objective"], trackerInfo.objective or L["FALSE"], unpack(addon.tooltip_keyvalue))
    tooltip:AddDoubleLine(L["Include Bank"], trackerInfo.includeBank and L["TRUE"] or L["FALSE"], unpack(addon.tooltip_keyvalue))
    tooltip:AddDoubleLine(L["Include All Characters"], trackerInfo.includeAllCharacters and L["TRUE"] or L["FALSE"], unpack(addon.tooltip_keyvalue))

    GameTooltip_AddBlankLinesToTooltip(GameTooltip, 1)
    tooltip:AddDoubleLine(L["Excluded"], numExcluded, unpack(addon.tooltip_keyvalue))
    for key, excludedTitle in pairs(trackerInfo.exclude) do
        if key > 10 then
            tooltip:AddLine(string.format("%d %s...", numExcluded - 10, L["more"]), unpack(addon.tooltip_description))
            tooltip:AddTexture(134400)
            break
        else
            tooltip:AddLine(excludedTitle)
            tooltip:AddTexture(addon:GetObjectiveIcon(excludedTitle))
        end
    end

    ------------------------------------------------------------

    GameTooltip_AddBlankLinesToTooltip(GameTooltip, 1)
    if FarmingBar.db.global.hints.ObjectiveBuilder then
        tooltip:AddLine(string.format("%s:", L["Hint"]))
        tooltip:AddLine(L.TrackerContextMenuHint, unpack(addon.tooltip_description))
    end
end

--*------------------------------------------------------------------------

local function GetObjectiveContextMenu()
    local selected = addon.ObjectiveBuilder.status.selected
    local multiSelected = #selected > 1

    local menu = {
        {
            text = multiSelected and L["Duplicate All"] or L["Duplicate"],
            notCheckable = true,
            func = function() addon:DuplicateSelectedObjectives() end,
        },

        {text = "", notCheckable = true, notClickable = true},

        {
            text = multiSelected and L["Delete All"] or L["Delete"],
            notCheckable = true,
            func = function() addon:DeleteSelectedObjectives() end,
        },

        {text = "", notCheckable = true, notClickable = true},

        {
            text = L["Close"],
            notCheckable = true,
        }
    }

    if not multiSelected then
        tinsert(menu, 1, {
            text = L["Rename"],
            notCheckable = true,
            func = function(self) selected[1]:RenameObjective() end,
        })

        tinsert(menu, 3, {
            text = L["Export"],
            disabled = true,
            notCheckable = true,
            func = function() end,
        })
    end

    return menu
end

------------------------------------------------------------

local function GetTrackerContextMenu()
    local multiSelected = #addon.ObjectiveBuilder.trackerList.status.selected > 1

    local menu = {
        {
            text = multiSelected and L["Delete All"] or L["Delete"],
            notCheckable = true,
            func = function() addon:DeleteTracker() end,
        },

        {text = "", notCheckable = true, notClickable = true},

        {
            text = L["Close"],
            notCheckable = true,
        },
    }

    return menu
end

--*------------------------------------------------------------------------

local methods = {
    ["GetSelectedObjective"] = function(self)
        return self.status.objectiveTitle
    end,

    ["GetSelectedTracker"] = function(self)
        return self.status.tracker
    end,

    ["GetObjectiveButtonByTitle"] = function(self, objectiveTitle)
        for key, objective in pairs(self.status.children) do
            if objective.objectiveTitle == objectiveTitle then
                return objective.button
            end
        end
    end,

    ["Load"] = function(self)
        self:Show()
        self:LoadObjectives()
    end,

    ["LoadExcludeList"] = function(self)
        local _, _, _, trackerInfo = addon:GetSelectedObjectiveInfo()
        local excludeList = addon.ObjectiveBuilder.excludeList

        excludeList:ReleaseChildren()

        ------------------------------------------------------------

        for key, objectiveTitle in pairs(trackerInfo.exclude) do
            local label = AceGUI:Create("FB30_InteractiveLabel")
            label:SetFullWidth(true)
            label:SetText(objectiveTitle)
            label:SetImageSize(15, 15)
            label:SetImage(addon:GetObjectiveIcon(objectiveTitle))
            excludeList:AddChild(label)

            label:SetCallback("OnClick", function(_, _, buttonClicked)
                -- !Move this to a local
                if IsShiftKeyDown() and buttonClicked == "RightButton" then
                    tremove(trackerInfo.exclude, key)
                    self:LoadExcludeList()
                end
                -- !
            end)

            label:SetTooltip(function(self, tooltip)
                -- !Move this to a local
                if FarmingBar.db.global.hints.ObjectiveBuilder then
                    tooltip:AddLine(string.format("%s:", L["Hint"]))
                    tooltip:AddLine(L.RemoveExcludeHint, unpack(addon.tooltip_description))
                end
                -- !
            end)
        end
    end,

    ["LoadObjectives"] = function(self, objectiveTitle)
        local sideContent, mainPanel = self.sideContent, self.mainPanel
        local filter = self.objectiveSearchBox:GetText()

        sideContent:ReleaseChildren()
        wipe(self.status.selected)
        wipe(self.status.children)

        ------------------------------------------------------------

        for objectiveTitle, objective in addon.pairs(FarmingBar.db.global.objectives) do
            if not filter or strfind(strupper(objectiveTitle), strupper(filter)) then
                local button = AceGUI:Create("FB30_ObjectiveButton")
                button:SetFullWidth(true)
                button:SetText(objectiveTitle)
                button:SetIcon(addon:GetObjectiveIcon(objectiveTitle))
                button:SetStatus(self.status)
                button:SetMenuFunc(GetObjectiveContextMenu)
                button:SetTooltip(ObjectiveButton_Tooltip)
                sideContent:AddChild(button)
                tinsert(self.status.children, {objectiveTitle = objectiveTitle, button = button})

                ------------------------------------------------------------

                button:SetCallback("OnClick", function(self, event, ...) ObjectiveButton_OnClick(objectiveTitle) end)
                button:SetCallback("OnDragStart", function(self, event, ...) addon.DragFrame:Load(objectiveTitle) end)
                button:SetCallback("OnDragStop", function(self, event, ...) addon.DragFrame:Clear() end)

            end
        end

        if objectiveTitle then
            local button = addon.ObjectiveBuilder:GetObjectiveButtonByTitle(objectiveTitle)
            if button then
                button.frame:Click()
            end
        else
            mainPanel:ReleaseChildren()
        end
    end,

    ["LoadTrackers"] = function(self)
        local _, objectiveInfo = addon:GetSelectedObjectiveInfo()
        local trackerList = addon.ObjectiveBuilder.trackerList

        trackerList:ReleaseChildren()
        wipe(trackerList.status.selected)
        wipe(trackerList.status.children)

        ------------------------------------------------------------

        for tracker, trackerInfo in pairs(objectiveInfo.trackers) do
            local button = AceGUI:Create("FB30_ObjectiveButton")
            button:SetFullWidth(true)
            -- !Try to remove this if I can set up a coroutine to handle item caching.
            addon:GetTrackerDataTable(trackerInfo.trackerType, trackerInfo.trackerID, function(data)
                button:SetText(data.name)
                button:SetIcon(data.icon)
                tinsert(trackerList.status.children, {trackerTitle = data.name, button = button})
            end)
            -- !
            button:SetStatus(trackerList.status)
            button:SetMenuFunc(GetTrackerContextMenu)
            button:SetTooltip(TrackerButton_Tooltip)
            trackerList:AddChild(button)

            ------------------------------------------------------------

            button:SetCallback("OnClick", function(self, event, ...) TrackerButton_OnClick(tracker) end)
        end
    end,

    ["Release"] = function(self)
        AceGUI:Release(self)
    end,

    ["Refresh"] = function(self, reloadTab, reloadTracker)
        self:UpdateObjectiveIcon((addon:GetSelectedObjectiveInfo()))

        if reloadTab then
            self.mainContent:SelectTab(reloadTab)
        end

        if reloadTracker then
            addon:ObjectiveBuilder_LoadTrackerInfo(reloadTracker)
        end
    end,

    ["SelectObjective"] = function(self, objectiveTitle)
        self.status.objectiveTitle = objectiveTitle
        local mainPanel = self.mainPanel.frame

        if objectiveTitle then
            mainPanel:Show()
        else
            mainPanel:Hide()
        end

        self.mainContent:SelectTab("objectiveTab")
    end,

    ["UpdateObjectiveIcon"] = function(self, objectiveTitle)
        self:GetObjectiveButtonByTitle(objectiveTitle):SetIcon(addon:GetObjectiveIcon(objectiveTitle))
    end,

    ["UpdateTrackerButton"] = function(self)
        local _, _, tracker, trackerInfo = addon:GetSelectedObjectiveInfo()

        -- !Try to remove this if I can set up a coroutine to handle item caching.
        addon:GetTrackerDataTable(trackerInfo.trackerType, trackerInfo.trackerID, function(data)
            local button = addon.ObjectiveBuilder.trackerList.status.children[tracker].button
            button:SetText(data.name == "" and L["Invalid Tracker"] or data.name)
            button:SetIcon(data.icon)
        end)
        -- !
    end,
}

------------------------------------------------------------

function addon:Initialize_ObjectiveBuilder()
    local ObjectiveBuilder = AceGUI:Create("FB30_Window")
    ObjectiveBuilder:SetTitle("Farming Bar "..L["Objective Builder"])
    ObjectiveBuilder:SetSize(700, 500)
    ObjectiveBuilder:SetLayout("FB30_2RowSplitBottom")
    ObjectiveBuilder:Hide()
    self.ObjectiveBuilder = ObjectiveBuilder
    ObjectiveBuilder.status = {children = {}, selected = {}}

    for method, func in pairs(methods) do
        ObjectiveBuilder[method] = func
    end

    ------------------------------------------------------------

    local topContent = AceGUI:Create("SimpleGroup")
    topContent:SetFullWidth(true)
    topContent:SetHeight(20)
    topContent:SetLayout("Flow")
    topContent:SetAutoAdjustHeight(false)
    ObjectiveBuilder:AddChild(topContent)
    ObjectiveBuilder.topContent = topContent

    ------------------------------------------------------------

    local newObjectiveButton = AceGUI:Create("FB30_InteractiveLabel")
    newObjectiveButton:SetText(L["New Objective"])
    newObjectiveButton:SetWidth(newObjectiveButton.label:GetStringWidth() + newObjectiveButton.image:GetWidth())
    newObjectiveButton:SetImageSize(newObjectiveButton.label:GetHeight(), newObjectiveButton.label:GetHeight())
    newObjectiveButton:SetImage(514607)
    topContent:AddChild(newObjectiveButton)

    newObjectiveButton:SetCallback("OnClick", function() addon:CreateObjective(_, _, _, _, true) end)
    newObjectiveButton:SetCallback("OnReceiveDrag", function() addon:CreateObjective(_, _, _, _, true) end)

    if FarmingBar.db.global.hints.ObjectiveBuilder then
        newObjectiveButton:SetTooltip(function(self, tooltip)
            -- !Move this to a local
            tooltip:AddLine(strformat("%s:", L["Hint"]))
            tooltip:AddLine(L.NewObjectiveHint, unpack(addon.tooltip_description))
            -- !
        end)
    end

    ------------------------------------------------------------

    local importObjectiveButton = AceGUI:Create("FB30_InteractiveLabel")
    importObjectiveButton:SetText(L["Import Objective"])
    importObjectiveButton:SetWidth(importObjectiveButton.label:GetStringWidth() + importObjectiveButton.image:GetWidth())
    importObjectiveButton:SetImageSize(importObjectiveButton.label:GetHeight(), importObjectiveButton.label:GetHeight())
    importObjectiveButton:SetImage(131906, 1, 0, 0, 1)
    importObjectiveButton:SetDisabled(true)
    topContent:AddChild(importObjectiveButton)

    -- importObjectiveButton:SetCallback("OnClick", function() ????? end) -- TODO: implement import/export

    ------------------------------------------------------------

    local sidePanel = AceGUI:Create("SimpleGroup")
    sidePanel:SetRelativeWidth(1/4)
    sidePanel:SetFullHeight(true)
    sidePanel:SetLayout("FB30_2RowFill")
    ObjectiveBuilder:AddChild(sidePanel)

    ------------------------------------------------------------

    local objectiveSearchBox = AceGUI:Create("FB30_SearchEditBox")
    objectiveSearchBox:SetFullWidth(true)
    sidePanel:AddChild(objectiveSearchBox)
    ObjectiveBuilder.objectiveSearchBox = objectiveSearchBox

    objectiveSearchBox:SetCallback("OnTextChanged", function(self) ObjectiveBuilder:LoadObjectives(self:GetText()) end)
    objectiveSearchBox:SetCallback("OnEnterPressed", function(self) self:ClearFocus() end)

    ------------------------------------------------------------

    local sideContent = AceGUI:Create("ScrollFrame")
    sideContent:SetLayout("List")
    sidePanel:AddChild(sideContent)
    ObjectiveBuilder.sideContent = sideContent

    ------------------------------------------------------------

    local mainPanel = AceGUI:Create("SimpleGroup")
    mainPanel:SetRelativeWidth(3/4)
    mainPanel:SetFullHeight(true)
    mainPanel:SetLayout("Fill")
    ObjectiveBuilder:AddChild(mainPanel)
    ObjectiveBuilder.mainPanel = mainPanel

    ------------------------------------------------------------

    self:Initialize_DragFrame()

    ------------------------------------------------------------
    --Debug-----------------------------------------------------
    ------------------------------------------------------------
    if FarmingBar.db.global.debug.ObjectiveBuilder then
        C_Timer.After(1, function()
            ObjectiveBuilder:Load()

            for key, objective in pairs(addon.ObjectiveBuilder.status.children) do
                objective.button.frame:Click()
                if FarmingBar.db.global.debug.ObjectiveBuilderTrackers then
                    addon.ObjectiveBuilder.mainContent:SelectTab("trackersTab")

                    if key == #addon.ObjectiveBuilder.status.children then
                        for _, tracker in pairs(ObjectiveBuilder.trackerList.status.children) do
                            tracker.button.frame:Click()
                            break
                        end
                    end
                elseif FarmingBar.db.global.debug.ObjectiveBuilderCondition then
                    addon.ObjectiveBuilder.mainContent:SelectTab("conditionTab")
                end
                break
            end
        end)
    end
    ------------------------------------------------------------
    ------------------------------------------------------------
end

--*------------------------------------------------------------------------

function addon:ObjectiveBuilder_DrawTabs()
    local ObjectiveBuilder = self.ObjectiveBuilder
    local mainPanel = ObjectiveBuilder.mainPanel

    mainPanel:ReleaseChildren()

    ------------------------------------------------------------

    local mainTabGroup = AceGUI:Create("TabGroup")
    mainTabGroup:SetLayout("Fill")
    mainPanel:AddChild(mainTabGroup)
    ObjectiveBuilder.mainContent = mainTabGroup

    mainTabGroup:SetTabs({
        {text = L["Objective"], value = "objectiveTab"},
        {text = L["Condition"], value = "conditionTab"},
        {text = L["Trackers"], value = "trackersTab"}
    })
    mainTabGroup:SelectTab("objectiveTab")

    ------------------------------------------------------------

    mainTabGroup:SetCallback("OnGroupSelected", function(self, _, selected) mainTabGroup_OnGroupSelected(self, selected) end)
end

--*------------------------------------------------------------------------

function addon:ObjectiveBuilder_LoadConditionTab(objectiveTitle)
    local mainContent = self.ObjectiveBuilder.mainContent

    if not objectiveTitle then return end
    local objectiveInfo = self:GetObjectiveInfo(objectiveTitle)

    ------------------------------------------------------------

    local tabContent = AceGUI:Create("ScrollFrame")
    tabContent:SetLayout("Flow")
    mainContent:AddChild(tabContent)
    mainContent:SetLayout("Fill")

    ------------------------------------------------------------

    -- TODO: ObjectiveBuilder_LoadConditionTab()
    local trackCondition = AceGUI:Create("Dropdown")
    trackCondition:SetFullWidth(true)
    trackCondition:SetLabel(L["Tracker Condition"])
    trackCondition:SetList(
        {
            ALL = L["All"],
            ANY = L["Any"],
            CUSTOM = L["Custom"],
        },
        {"ALL", "ANY", "CUSTOM"}
    )
    trackCondition:SetValue(objectiveInfo.trackCondition)
    tabContent:AddChild(trackCondition)

    trackCondition:SetCallback("OnValueChanged", function(_, _, selected) trackCondition_OnValueChanged(selected) end)

    ------------------------------------------------------------

    if objectiveInfo.trackCondition == "CUSTOM" then
        local customCondition = AceGUI:Create("MultiLineEditBox")
        customCondition:SetFullWidth(true)
        customCondition:SetLabel(L["Custom Function"])
        customCondition:SetText(objectiveInfo.trackFunc)
        tabContent:AddChild(customCondition)

        customCondition:SetCallback("OnEnterPressed", customCondition_OnEnterPressed)
    end
end

------------------------------------------------------------

function addon:ObjectiveBuilder_LoadObjectiveTab(objectiveTitle)
    local mainContent = self.ObjectiveBuilder.mainContent

    if not objectiveTitle then return end
    local objectiveInfo = self:GetObjectiveInfo(objectiveTitle)

    ------------------------------------------------------------

    local tabContent = AceGUI:Create("ScrollFrame")
    tabContent:SetLayout("Flow")
    mainContent:AddChild(tabContent)
    mainContent:SetLayout("Fill")

    ------------------------------------------------------------

    local title = AceGUI:Create("Label")
    title:SetFullWidth(true)
    title:SetText(objectiveTitle)
    title:SetFontObject(GameFontNormalLarge)
    title:SetImageSize(20, 20)
    title:SetImage(self:GetObjectiveIcon(objectiveTitle))
    tabContent:AddChild(title)

    ------------------------------------------------------------

    local spacer_enabled = AceGUI:Create("Label")
    spacer_enabled:SetFullWidth(true)
    spacer_enabled:SetText(" ")
    tabContent:AddChild(spacer_enabled)

    ------------------------------------------------------------

    local enabled = AceGUI:Create("CheckBox")
    enabled:SetFullWidth(true)
    enabled:SetValue(objectiveInfo.enabled)
    enabled:SetLabel(L["Enabled"])
    tabContent:AddChild(enabled)

    enabled:SetCallback("OnValueChanged", function(self) addon:SetObjectiveDBInfo(objectiveTitle, "enabled", self:GetValue()) end)

    ------------------------------------------------------------

    local autoIcon = AceGUI:Create("CheckBox")
    autoIcon:SetFullWidth(true)
    autoIcon:SetValue(objectiveInfo.autoIcon)
    autoIcon:SetLabel(L["Automatic Icon"])
    tabContent:AddChild(autoIcon)

    autoIcon:SetCallback("OnValueChanged", autoIcon_OnValueChanged)

    ------------------------------------------------------------

    if not objectiveInfo.autoIcon then
        local displayIcon = AceGUI:Create("EditBox")
        displayIcon:SetRelativeWidth(1/2)
        displayIcon:SetText(objectiveInfo.icon)
        tabContent:AddChild(displayIcon, tabContent.objective)

        displayIcon:SetCallback("OnEnterPressed", displayIcon_OnEnterPressed)

        ------------------------------------------------------------

        local chooseButton = AceGUI:Create("Button")
        chooseButton:SetRelativeWidth(1/2)
        chooseButton:SetText(L["Choose"])
        tabContent:AddChild(chooseButton, tabContent.objective)

        -- chooseButton:SetCallback("OnClick", function() self.IconSelector:Show() end) -- TODO: Icon selector frame
    end

    ------------------------------------------------------------

    local objective = AceGUI:Create("EditBox")
    objective:SetFullWidth(true)
    objective:SetText(objectiveInfo.objective)
    objective:SetLabel(L["Objective"])
    tabContent:AddChild(objective)

    objective:SetCallback("OnEnterPressed", objective_OnEnterPressed)
    objective:SetCallback("OnTextChanged", function(self) numericEditBox_OnTextChanged(self) end)

    ------------------------------------------------------------

    local displayRef = AceGUI:Create("Heading")
    displayRef:SetFullWidth(true)
    displayRef:SetText(L["Display Reference"])
    tabContent:AddChild(displayRef)

    ------------------------------------------------------------

    local displayRefTrackerType = AceGUI:Create("Dropdown")
    displayRefTrackerType:SetRelativeWidth(0.92)
    displayRefTrackerType:SetLabel(L["Type"])
    displayRefTrackerType:SetList(
        {
            ITEM = L["Item"],
            CURRENCY = L["Currency"],
            NONE = L["None"],
        },
        {"ITEM", "CURRENCY", "NONE"}
    )
    displayRefTrackerType:SetValue(objectiveInfo.displayRef.trackerType or "NONE")
    tabContent:AddChild(displayRefTrackerType)

    displayRefTrackerType:SetCallback("OnValueChanged", function(self, _, selected) displayRefTrackerType_OnValueChanged(self, selected) end)

    ------------------------------------------------------------

    local displayRefHelp = AceGUI:Create("FB30_InteractiveLabel")
    displayRefHelp:SetText(" ")
    displayRefHelp:SetImage(616343)
    displayRefHelp:SetImageSize(25, 25)
    displayRefHelp:SetWidth(30)
    tabContent:AddChild(displayRefHelp)

    displayRefHelp:SetCallback("OnClick", function(label) displayRefHelp_OnClick(tabContent, label) end)

    ------------------------------------------------------------

    if objectiveInfo.displayRef.trackerType then
        local displayRefTrackerID = AceGUI:Create("EditBox")
        displayRefTrackerID:SetFullWidth(true)
        displayRefTrackerID:SetLabel(self:GetTrackerTypeLabel(objectiveInfo.displayRef.trackerType))
        displayRefTrackerID:SetText(objectiveInfo.displayRef.trackerID or "")
        tabContent:AddChild(displayRefTrackerID)

        displayRefTrackerID:SetCallback("OnEnterPressed", displayRefTrackerID_OnEnterPressed)
    end
end

------------------------------------------------------------

function addon:LoadTrackersTab(objectiveTitle)
    local ObjectiveBuilder = addon.ObjectiveBuilder
    local tabContent = ObjectiveBuilder.mainContent

    if not objectiveTitle then return end
    local objectiveInfo = self:GetObjectiveInfo(objectiveTitle)

    ------------------------------------------------------------

    local topContent = AceGUI:Create("SimpleGroup")
    topContent:SetFullWidth(true)
    topContent:SetHeight(20)
    topContent:SetLayout("Flow")
    topContent:SetAutoAdjustHeight(false)
    tabContent:AddChild(topContent)

    ------------------------------------------------------------

    local newTrackerButton = AceGUI:Create("FB30_InteractiveLabel")
    newTrackerButton:SetText(L["New Tracker"])
    newTrackerButton:SetWidth(newTrackerButton.label:GetStringWidth() + newTrackerButton.image:GetWidth())
    newTrackerButton:SetImageSize(newTrackerButton.label:GetHeight(), newTrackerButton.label:GetHeight())
    newTrackerButton:SetImage(514607)
    topContent:AddChild(newTrackerButton)

    newTrackerButton:SetCallback("OnClick", function() addon:CreateTracker() end)
    newTrackerButton:SetCallback("OnReceiveDrag", function() addon:CreateTracker(true) end)
    if FarmingBar.db.global.hints.ObjectiveBuilder then
        newTrackerButton:SetTooltip(function(self, tooltip)
            -- !Move this to a local
            tooltip:AddLine(string.format("%s:", L["Hint"]))
            tooltip:AddLine(L.NewTrackerHint, unpack(addon.tooltip_description))
            -- !
        end)
    end

    ------------------------------------------------------------

    local trackerListContainer = AceGUI:Create("SimpleGroup")
    trackerListContainer:SetLayout("Fill")
    tabContent:AddChild(trackerListContainer)

    ------------------------------------------------------------

    local trackerList = AceGUI:Create("ScrollFrame")
    trackerList:SetLayout("List")
    trackerListContainer:AddChild(trackerList)
    ObjectiveBuilder.trackerList = trackerList
    trackerList.status = {children = {}, selected = {}}

    ------------------------------------------------------------

    local trackerInfo = AceGUI:Create("ScrollFrame")
    trackerInfo:SetLayout("List")
    tabContent:AddChild(trackerInfo)
    trackerList.status.content = trackerInfo

    ------------------------------------------------------------

    ObjectiveBuilder:LoadTrackers()
end

--*------------------------------------------------------------------------

function addon:ObjectiveBuilder_LoadTrackerInfo(tracker)
    local ObjectiveBuilder = self.ObjectiveBuilder
    local objectiveTitle, _, _, trackerInfo = self:GetSelectedObjectiveInfo()
    local tabContent = ObjectiveBuilder.trackerList.status.content

    tabContent:ReleaseChildren()

    if not objectiveTitle or not trackerInfo then return end

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
    trackerID:SetLabel(self:GetTrackerTypeLabel(trackerInfo.trackerType))
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
    trackerObjective:SetCallback("OnTextChanged", function(self) numericEditBox_OnTextChanged(self) end)

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

    ObjectiveBuilder:LoadExcludeList()
end