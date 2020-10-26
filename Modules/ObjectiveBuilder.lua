local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)
local AceGUI = LibStub("AceGUI-3.0", true)

local tinsert, tremove, wipe, pairs = table.insert, table.remove, table.wipe, pairs
local strfind, gsub, strupper, tonumber = string.find, string.gsub, string.upper, tonumber

local tabCache = {}

--*------------------------------------------------------------------------

local function FocusNextWidget(widget, widgetType, reverse)
    local widgetKey
    for key, w in addon.pairs(widget.parent.children, reverse and function(a, b) return a > b end or function(a, b) return a < b end) do
        if w == widget then
            widgetKey = key
        elseif widgetKey and (not widgetType or w.type == widgetType) then
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

    local ObjectiveBuilder = addon.ObjectiveBuilder
    local objectiveTitle = ObjectiveBuilder:GetSelectedObjective()
    ObjectiveBuilder:LoadObjectives(objectiveTitle)
    addon:UpdateButtons(objectiveTitle)
end

------------------------------------------------------------

local function customCondition_OnEnterPressed(self)
    local condition = self:GetText()

    if addon:ValidateCustomCondition(condition) or condition == "" then
        addon:SetObjectiveDBInfo((addon:GetSelectedObjectiveInfo()), "customCondition", condition)
    else
        addon:ReportError(L.InvalidCustomCondition)
        self:SetFocus()
        self:HighlightText()
    end
end

------------------------------------------------------------

local function displayIcon_OnEnterPressed(self)
    addon:SetObjectiveDBInfo((addon:GetSelectedObjectiveInfo()), "icon", self:GetText())

    local ObjectiveBuilder = addon.ObjectiveBuilder
    local objectiveTitle = ObjectiveBuilder:GetSelectedObjective()
    ObjectiveBuilder:LoadObjectives(objectiveTitle)
    addon:UpdateButtons(objectiveTitle)
    FocusNextWidget(self, "EditBox", IsShiftKeyDown())
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

local function displayRefMacrotext_OnEnterPressed(self)
    addon:SetObjectiveDBInfo((addon:GetSelectedObjectiveInfo()), "displayRef.trackerID", self:GetText())
    addon:UpdateButtons(addon.ObjectiveBuilder:GetSelectedObjective())
end

------------------------------------------------------------

local function displayRefTrackerID_OnEnterPressed(self)
    local objectiveTitle, objectiveInfo = addon:GetSelectedObjectiveInfo()
    local validTrackerID = addon:ValidateObjectiveData(objectiveInfo.displayRef.trackerType, self:GetText())

    if validTrackerID or self:GetText() == "" then
        addon:SetObjectiveDBInfo(objectiveTitle, "displayRef.trackerID", objectiveInfo.displayRef.trackerType == "ITEM" and validTrackerID or tonumber(self:GetText()))

        self:SetText(objectiveInfo.displayRef.trackerID)
        self:ClearFocus()

        local ObjectiveBuilder = addon.ObjectiveBuilder
        local objectiveTitle = ObjectiveBuilder:GetSelectedObjective()
        ObjectiveBuilder:LoadObjectives(objectiveTitle)
        addon:UpdateButtons(objectiveTitle)

        FocusNextWidget(self, "EditBox", IsShiftKeyDown())
    else
        addon:ReportError(L.InvalidTrackerID(objectiveInfo.displayRef.trackerType, self:GetText()))

        self:SetText("")
        self:SetFocus()
    end
end

------------------------------------------------------------

local function displayRefTrackerType_OnValueChanged(self, selected)
    local objectiveTitle = addon:GetSelectedObjectiveInfo()

    addon:SetObjectiveDBInfo(objectiveTitle, "displayRef.trackerType", selected ~= "NONE" and selected or false)
    addon:SetObjectiveDBInfo(objectiveTitle, "displayRef.trackerID", false)

    local ObjectiveBuilder = addon.ObjectiveBuilder
    local objectiveTitle = ObjectiveBuilder:GetSelectedObjective()
    ObjectiveBuilder:LoadObjectives(objectiveTitle)
    addon:UpdateButtons(objectiveTitle)

    if selected ~= "NONE" then
        FocusNextWidget(self, selected == "MACROTEXT" and "MultiLineEditBox" or "EditBox")
    end
end

------------------------------------------------------------

local function excludeListLabel_OnClick(self, buttonClicked, key)
    if IsShiftKeyDown() and buttonClicked == "RightButton" then
        tremove(select(4, addon:GetSelectedObjectiveInfo()).exclude, key)
        self:LoadExcludeList()
    end
end

------------------------------------------------------------

local function excludeObjectives_OnEnterPressed(self)
    if IsShiftKeyDown() then
        FocusNextWidget(self, "EditBox", IsShiftKeyDown())
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
    tabCache[objectiveTitle] = selected

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

    FocusNextWidget(self, "EditBox", IsShiftKeyDown())
end

------------------------------------------------------------

local function trackerCondition_OnValueChanged(selected)
    addon:SetObjectiveDBInfo((addon:GetSelectedObjectiveInfo()), "trackerCondition", selected)
    addon.ObjectiveBuilder:RefreshTab("conditionTab")
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
        ObjectiveBuilder:RefreshTab("trackerTab")
        FocusNextWidget(self, "EditBox", IsShiftKeyDown())

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
                FocusNextWidget(self, "EditBox", IsShiftKeyDown())
            end
        else
            addon:SetTrackerDBInfo(objectiveTitle, tracker, "trackerID", newTrackerID)

            self:SetText(trackerInfo.trackerID)
            self:ClearFocus()

            ObjectiveBuilder:UpdateTrackerButton(tracker)
            ObjectiveBuilder:RefreshTab("trackerTab")
            FocusNextWidget(self, "EditBox", IsShiftKeyDown())
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

    FocusNextWidget(self, "EditBox", IsShiftKeyDown())
end

------------------------------------------------------------

local function trackerType_OnValueChanged(self, selected)
    local ObjectiveBuilder = addon.ObjectiveBuilder
    local objectiveTitle, _, tracker = addon:GetSelectedObjectiveInfo()

    addon:SetTrackerDBInfo(objectiveTitle, tracker, "trackerType", selected)

    ObjectiveBuilder:UpdateTrackerButton(tracker)
    ObjectiveBuilder:RefreshTab("trackerTab", tracker)
    FocusNextWidget(self, "editbox")
end

------------------------------------------------------------

local function customCondition_OnEnterPressed(self)
    addon:SetObjectiveDBInfo((addon:GetSelectedObjectiveInfo()), "customCondition", self:GetText())
end

--*------------------------------------------------------------------------

local function TrackerButton_OnClick(tracker)
    addon.ObjectiveBuilder.status.tracker = tracker
    addon:ObjectiveBuilder_LoadTrackerInfo(tracker)
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
    GetSelectedObjective = function(self)
        return self:GetUserData("selectedObjective")

    end,

    ------------------------------------------------------------

    GetSelectedTracker = function(self)
        return self.status.tracker
    end,

    ------------------------------------------------------------

    GetObjectiveButton = function(self, objectiveTitle)
        for _, button in pairs(self.objectiveList.children) do
            if button:GetUserData("objectiveTitle") == objectiveTitle then
                return button
            end
        end
    end,

    ------------------------------------------------------------

    Load = function(self, objectiveTitle)
        self:Show()
        self:LoadObjectives(objectiveTitle)
    end,

    ------------------------------------------------------------

    LoadExcludeList = function(self)
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

            label:SetCallback("OnClick", function(_, _, buttonClicked) excludeListLabel_OnClick(self, buttonClicked, key) end)

            label:SetTooltip(addon.GetExcludeListLabelTooltip)
        end
    end,

    ------------------------------------------------------------

    LoadObjectives = function(self, objectiveTitle)
        local objectiveList, mainPanel = self.objectiveList, self.mainPanel
        local filter = self.objectiveSearchBox:GetText()

        objectiveList:ReleaseChildren()

        ------------------------------------------------------------

        for objectiveTitle, objective in addon.pairs(FarmingBar.db.global.objectives, function(a, b) return strupper(a) < strupper(b) end) do
            if not filter or strfind(strupper(objectiveTitle), strupper(filter)) then
                local button = AceGUI:Create("FarmingBar_ObjectiveButton")
                button:SetFullWidth(true)
                button:SetObjective(objectiveTitle)
                objectiveList:AddChild(button)
            end
        end

        if objectiveTitle then
            self:SetSelected(objectiveTitle)
        elseif self:GetSelectedObjective() then
            self:SetSelected(self:GetSelectedObjective())
        else
            mainPanel:ReleaseChildren()
        end
    end,

    ------------------------------------------------------------

    LoadTrackers = function(self)
        local _, objectiveInfo = addon:GetSelectedObjectiveInfo()
        local trackerList = addon.ObjectiveBuilder.trackerList

        trackerList:ReleaseChildren()
        wipe(trackerList.status.selected)
        wipe(trackerList.status.children)

        ------------------------------------------------------------

        for tracker, trackerInfo in pairs(objectiveInfo.trackers) do
            local button = AceGUI:Create("FarmingBar_TrackerButton")
            button:SetFullWidth(true)
            addon:GetTrackerDataTable(trackerInfo.trackerType, trackerInfo.trackerID, function(data)
                button:SetText(data.name)
                button:SetIcon(data.icon)
                tinsert(trackerList.status.children, {trackerTitle = data.name, button = button})
            end)
            button:SetStatus(trackerList.status)
            button:SetMenuFunc(GetTrackerContextMenu)
            button:SetTooltip(addon.GetTrackerButtonTooltip)
            trackerList:AddChild(button)

            ------------------------------------------------------------

            button:SetCallback("OnClick", function(self, event, ...) TrackerButton_OnClick(tracker) end)
        end
    end,

    ------------------------------------------------------------

    Release = function(self)
        AceGUI:Release(self)
    end,

    ------------------------------------------------------------

    RefreshTab = function(self, reloadTab, reloadTracker)
        if reloadTab then
            self.mainContent:SelectTab(reloadTab)
        end

        if reloadTracker then
            addon:ObjectiveBuilder_LoadTrackerInfo(reloadTracker)
        end
    end,

    ------------------------------------------------------------

    SetSelected = function(self, objectiveTitle)
        for _, button in pairs(self.objectiveList.children) do
            if button:GetUserData("objectiveTitle") == objectiveTitle then
                button.frame:Click()
                return
            end
        end
    end,

    ------------------------------------------------------------

    SelectObjective = function(self, objectiveTitle)
        self:SetUserData("selectedObjective", objectiveTitle)

        local mainPanel = self.mainPanel.frame
        if objectiveTitle then
            mainPanel:Show()
        else
            mainPanel:Hide()
        end

        self.mainContent:SelectTab(tabCache[objectiveTitle] or "objectiveTab")
    end,

    ------------------------------------------------------------

    UpdateTrackerButton = function(self)
        local _, _, tracker, trackerInfo = addon:GetSelectedObjectiveInfo()

        addon:GetTrackerDataTable(trackerInfo.trackerType, trackerInfo.trackerID, function(data)
            local button = addon.ObjectiveBuilder.trackerList.status.children[tracker].button
            button:SetText(data.name)
            button:SetIcon(data.icon)
        end)
    end,
}

------------------------------------------------------------

function addon:ObjectiveBuilder_OnUpdate()
    -- if #FarmingBar.db.global.objectives ~= #self.ObjectiveBuilder.objectiveList.children then
    --     print(#FarmingBar.db.global.objectives, #self.ObjectiveBuilder.objectiveList.children)
    --     -- self:LoadObjectives()
    -- end
end

------------------------------------------------------------

function addon:Initialize_ObjectiveBuilder()
    local ObjectiveBuilder = AceGUI:Create("FB30_Window")
    ObjectiveBuilder:SetTitle("Farming Bar "..L["Objective Builder"])
    ObjectiveBuilder:SetSize(700, 500)
    ObjectiveBuilder:SetLayout("FB30_2RowSplitBottom")
    ObjectiveBuilder:Hide()
    self.ObjectiveBuilder = ObjectiveBuilder
    ObjectiveBuilder.status = {children = {}, selected = {}}

    ObjectiveBuilder:SetCallback("OnUpdate", function() addon:ObjectiveBuilder_OnUpdate() end)

    for method, func in pairs(methods) do
        ObjectiveBuilder[method] = func
    end

    ------------------------------------------------------------

    self.MenuFrame = self.MenuFrame or CreateFrame("Frame", "FarmingBarMenuFrame", UIParent, "UIDropDownMenuTemplate")

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

    newObjectiveButton:SetCallback("OnClick", function() addon:CreateObjective() end)
    newObjectiveButton:SetCallback("OnReceiveDrag", function() addon:CreateObjectiveFromCursor() end)

    if FarmingBar.db.global.hints.ObjectiveBuilder then
        newObjectiveButton:SetTooltip(addon.GetNewObjectiveButtonTooltip)
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

    objectiveSearchBox:SetCallback("OnTextChanged", function(self) ObjectiveBuilder:LoadObjectives() end)

    ------------------------------------------------------------

    local objectiveList = AceGUI:Create("ScrollFrame")
    objectiveList:SetLayout("List")
    sidePanel:AddChild(objectiveList)
    objectiveList:SetUserData("renaming", {})
    ObjectiveBuilder.objectiveList = objectiveList

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
    -- mainTabGroup:SelectTab("objectiveTab")

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

    local trackerCondition = AceGUI:Create("Dropdown")
    trackerCondition:SetFullWidth(true)
    trackerCondition:SetLabel(L["Tracker Condition"])
    trackerCondition:SetList(
        {
            ANY = L["Any"],
            ALL = L["All"],
            CUSTOM = L["Custom"],
        },
        {"ANY", "ALL", "CUSTOM"}
    )
    trackerCondition:SetValue(objectiveInfo.trackerCondition)
    tabContent:AddChild(trackerCondition)

    trackerCondition:SetCallback("OnValueChanged", function(_, _, selected) trackerCondition_OnValueChanged(selected) end)

    ------------------------------------------------------------

    if objectiveInfo.trackerCondition == "CUSTOM" then
        local customCondition = AceGUI:Create("MultiLineEditBox")
        customCondition:SetFullWidth(true)
        customCondition:SetLabel(L["Custom Function"])
        customCondition:SetText(objectiveInfo.customCondition)
        tabContent:AddChild(customCondition)

        customCondition:SetCallback("OnEnterPressed", customCondition_OnEnterPressed)
    end

    ------------------------------------------------------------
    --Debug-----------------------------------------------------
    ------------------------------------------------------------
    if FarmingBar.db.global.debug.ObjectiveBuilder then
        local debug_checkCount = AceGUI:Create("Button")
        debug_checkCount:SetFullWidth(true)
        debug_checkCount:SetText("Check Count")
        tabContent:AddChild(debug_checkCount)

        debug_checkCount:SetCallback("OnClick", function(self, event, ...)
            print(addon:GetObjectiveCount((addon:GetSelectedObjectiveInfo())))
        end)
    end
    ------------------------------------------------------------
    ------------------------------------------------------------
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
            MACROTEXT = L["Macrotext"],
            NONE = L["None"],
        },
        {"ITEM", "CURRENCY", "MACROTEXT", "NONE"}
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

    if objectiveInfo.displayRef.trackerType == "MACROTEXT" then
        local displayRefMacrotext = AceGUI:Create("MultiLineEditBox")
        displayRefMacrotext:SetFullWidth(true)
        displayRefMacrotext:SetLabel(L["Macrotext"])
        displayRefMacrotext:SetText(objectiveInfo.displayRef.trackerID or "")
        tabContent:AddChild(displayRefMacrotext)

        displayRefMacrotext:SetCallback("OnEnterPressed", displayRefMacrotext_OnEnterPressed)
    elseif objectiveInfo.displayRef.trackerType and objectiveInfo.displayRef.trackerType ~= "NONE" then
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
        newTrackerButton:SetTooltip(addon.GetNewTrackerButtonTooltip)
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

    includeBank:SetCallback("OnValueChanged", function(self)
        local ObjectiveBuilder = addon.ObjectiveBuilder
        local objectiveTitle = ObjectiveBuilder:GetSelectedObjective()
        addon:SetTrackerDBInfo(objectiveTitle, ObjectiveBuilder:GetSelectedTracker(), "includeBank", self:GetValue())
        addon:UpdateButtons(objectiveTitle)
    end) --! move to local

    ------------------------------------------------------------

    local includeAllChars = AceGUI:Create("CheckBox")
    includeAllChars:SetFullWidth(true)
    includeAllChars:SetLabel(L["Include All Characters"])
    includeAllChars:SetValue(trackerInfo.includeAllChars)
    local missing = self:IsDataStoreLoaded()
    if #missing > 0 then
        includeAllChars:SetDisabled(true)
        local line = L["Missing"] ..": "..missing[1]
        if #missing > 1 then
            for i = 2, #missing do
                line = line ..", "..missing[i]
            end
        end
        includeAllChars:SetDescription(line)
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