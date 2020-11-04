local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)
local AceGUI = LibStub("AceGUI-3.0", true)

local tinsert, tremove, wipe, pairs = table.insert, table.remove, table.wipe, pairs
local strfind, strformat, gsub, strupper, tonumber = string.find, string.format, string.gsub, string.upper, tonumber
local CreateFrame, UIParent = CreateFrame, UIParent

local ObjectiveBuilder = addon.ObjectiveBuilder

--*------------------------------------------------------------------------

local displayRefTrackerTypeList =  {
    ITEM = L["Item"],
    CURRENCY = L["Currency"],
    MACROTEXT = L["Macrotext"],
    NONE = L["None"],
}

------------------------------------------------------------

local displayRefTrackerTypeListSort = {"ITEM", "CURRENCY", "MACROTEXT", "NONE"}

------------------------------------------------------------

local mainTabGroupTabs = {
    {text = L["Objective"], value = "objectiveTab"},
    {text = L["Trackers"], value = "trackersTab"}
}

------------------------------------------------------------

local ObjectiveBuilder_ScrollFrames = {
    objectiveList = {},
    mainContent = {},
    trackerList = {},
    excludeList = {},
}

------------------------------------------------------------

local ObjectiveBuilder_TableInfo = {
    {
        cols = {
            {width = "fill"},
        },
    },
    {
        cols = {
            {width = "relative", relWidth = 1/3},
            {width = "relative", relWidth = 2/3},
        },
        hpadding = 5,
        vOffset = 5,
        rowHeight = "fill",
    },
}

------------------------------------------------------------

local ObjectiveBuilderMainPanel_TableInfo = {
    {
        cols = {
            {width = "fill"},
        },
    },
    {
        cols = {
            {width = "fill"},
        },
        rowHeight = "fill",
    },
}

------------------------------------------------------------

local ObjectiveBuilderTrackerContent_TableInfo = {
    {
        cols = {
            {width = "relative", relWidth = 1/3},
            {width = "relative", relWidth = 2/3},
        },
        hpadding = 5,
        rowHeight = "fill",
    },
}

------------------------------------------------------------

local trackerConditionList = {
    ANY = L["Any"],
    ALL = L["All"],
    CUSTOM = L["Custom"],
}

------------------------------------------------------------

local trackerConditionListSort = {"ANY", "ALL", "CUSTOM"}

--*------------------------------------------------------------------------

local function autoIcon_OnValueChanged(self)
    addon:SetObjectiveDBInfo("autoIcon", self:GetValue())
end

------------------------------------------------------------

local function customCondition_OnEnterPressed(self)
    local condition = self:GetText()

    if addon:ValidateCustomCondition(condition) then
        addon:SetObjectiveDBInfo("customCondition", condition)
    else
        addon:ReportError(L.InvalidCustomCondition)
        self:SetFocus()
        self:HighlightText()
    end
end

------------------------------------------------------------

local function displayIcon_OnEnterPressed(self)
    addon:SetObjectiveDBInfo("icon", self:GetText())
end

------------------------------------------------------------

--!
local function displayRefHelp_OnClick(self)
    ObjectiveBuilder:SetUserData("showDisplayRefHelp", not ObjectiveBuilder:GetUserData("showDisplayRefHelp"))
    ObjectiveBuilder:LoadObjectives()
end

------------------------------------------------------------

local function displayRefMacrotext_OnEnterPressed(self)
    addon:SetObjectiveDBInfo("displayRef.trackerID", self:GetText())
end

------------------------------------------------------------

local function displayRefTrackerID_OnEnterPressed(self)
    local objectiveTitle, objectiveInfo = addon:GetSelectedObjectiveInfo()
    local trackerID = self:GetText()

    if addon:ValidateObjectiveData(objectiveInfo.displayRef.trackerType, trackerID) then
        addon:SetObjectiveDBInfo("displayRef.trackerID", objectiveInfo.displayRef.trackerType == "ITEM" and validTrackerID or tonumber(trackerID))

        self:SetText(objectiveInfo.displayRef.trackerID)
        self:ClearFocus()
    else
        addon:ReportError(L.InvalidTrackerID(objectiveInfo.displayRef.trackerType, trackerID))

        self:SetText("")
        self:SetFocus()
    end
end

------------------------------------------------------------

local function displayRefTrackerType_OnValueChanged(self, _, selected)
    addon:SetObjectiveDBInfo("displayRef.trackerType", selected ~= "NONE" and selected or false)
    -- addon:SetObjectiveDBInfo("displayRef.trackerID", false)
    --! have to add checks if we do this ^
end

------------------------------------------------------------

--!
local function excludeListLabel_OnClick(self, buttonClicked, key)
    if IsShiftKeyDown() and buttonClicked == "RightButton" then
        tremove(select(4, addon:GetSelectedObjectiveInfo()).exclude, key)
        self:LoadExcludeList()
    end
end

------------------------------------------------------------

local function excludeObjectives_OnEnterPressed(self)
    local objective = self:GetText()
    local validObjective = addon:ObjectiveExists(objective)

    if validObjective then
        local objectiveTitle, _, _, trackerInfo = addon:GetSelectedObjectiveInfo()
        local excluded = trackerInfo.exclude

        --! Should I not move this below the error reporting and rehighlight on err?
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

-- ! Move this
local function filterAutoItems_OnEnter(self)
    if FarmingBar.db.global.hints.ObjectiveBuilder then
        GameTooltip:SetOwner(self.frame, "ANCHOR_BOTTOMRIGHT", 0, 0)
        GameTooltip:AddLine(strformat("%s:", L["Hint"]))
        GameTooltip:AddLine(L.FilterAutoItemsHint, unpack(addon.tooltip_description))
        GameTooltip:Show()
    end
end

------------------------------------------------------------

local function filterAutoItems_OnLeave(self)
    if FarmingBar.db.global.hints.ObjectiveBuilder then
        GameTooltip:ClearLines()
        GameTooltip:Hide()
    end
end
-- !

------------------------------------------------------------

local function filterAutoItems_OnValueChanged(self, _, value)
    addon:SetDBValue("global", "settings.misc.filterOBAutoItems", value)
    ObjectiveBuilder:LoadObjectives()
end

------------------------------------------------------------

local function mainTabGroup_OnGroupSelected(self, _, selected)
    local objectiveTitle = addon:GetSelectedObjectiveInfo()
    if objectiveTitle then
        ObjectiveBuilder:GetUserData("selectedTabs")[objectiveTitle] = selected
    end

    ------------------------------------------------------------

    self:ReleaseChildren()

    local mainContent = AceGUI:Create("ScrollFrame")
    mainContent:SetLayout("Flow")
    mainContent:SetStatusTable(ObjectiveBuilder:GetUserData("scrollFrames").mainContent)
    ObjectiveBuilder:SetUserData("mainContent", mainContent)
    self:AddChild(mainContent)

    mainContent:SetScroll(mainContent.status.scrollvalue)

    ------------------------------------------------------------

    if selected == "objectiveTab" then
        addon:ObjectiveBuilder_LoadObjectiveTab(mainContent)
    elseif selected == "trackersTab" then
        addon:ObjectiveBuilder_LoadTrackersTab(mainContent)
    end
end

------------------------------------------------------------

local function NumericEditBox_OnTextChanged(self)
    self:SetText(string.gsub(self:GetText(), "[%s%c%p%a]", ""))
    self.editbox:SetCursorPosition(strlen(self:GetText()))
end

------------------------------------------------------------

local function trackerCondition_OnValueChanged(_, _, selected)
    addon:SetObjectiveDBInfo("trackerCondition", selected)
end

------------------------------------------------------------

local function trackerContentSizer_OnMouseUp(self, trackerContent, tabContent)
    ObjectiveBuilder:SetUserData("trackerContentHeight", trackerContent.frame:GetHeight())
    tabContent:ReleaseChildren()
    addon:ObjectiveBuilder_LoadTrackersTab(tabContent)
end

------------------------------------------------------------

--!
local function trackerID_OnEnterPressed(self)
    local objectiveTitle, _, tracker, trackerInfo = addon:GetSelectedObjectiveInfo()

    ------------------------------------------------------------

    if not self:GetText() or self:GetText() == "" then
        -- Clear trackerID
        addon:SetTrackerDBInfo(objectiveTitle, tracker, "trackerID", "")

        self:ClearFocus()

        -- ObjectiveBuilder:UpdateTrackerButton(tracker) --!
        RefreshObjectiveBuilder()
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
            end
        else
            addon:SetTrackerDBInfo(objectiveTitle, tracker, "trackerID", newTrackerID)

            self:SetText(trackerInfo.trackerID)
            self:ClearFocus()

            -- ObjectiveBuilder:UpdateTrackerButton(tracker) --!
            RefreshObjectiveBuilder()
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
end

------------------------------------------------------------

local function trackerType_OnValueChanged(self, selected)
    local objectiveTitle, _, tracker = addon:GetSelectedObjectiveInfo()

    addon:SetTrackerDBInfo(objectiveTitle, tracker, "trackerType", selected)

    RefreshObjectiveBuilder()
end

--*------------------------------------------------------------------------

local function TrackerButton_OnClick(tracker)
    ObjectiveBuilder:SetUserData("selectedTracker", tracker)
    addon:ObjectiveBuilder_LoadTrackerInfo(tracker)
end

--*------------------------------------------------------------------------

local methods = {
    GetSelectedObjective = function(self)
        return self:GetUserData("selectedObjective")

    end,

    ------------------------------------------------------------

    GetSelectedObjectiveInfo = function(self)
        local objectiveTitle = self:GetSelectedObjective()
        local objectiveInfo = addon:GetObjectiveInfo(objectiveTitle)
        local tracker = self:GetSelectedTracker()
        local trackerInfo = tracker and addon:GetTrackerInfo(objectiveTitle, tracker)

        return objectiveTitle, objectiveInfo, tracker, trackerInfo
    end,

    ------------------------------------------------------------

    GetSelectedTab = function(self, objectiveTitle)
        return self:GetUserData("selectedTabs")[objectiveTitle]
    end,

    ------------------------------------------------------------

    GetSelectedTracker = function(self)
        return self:GetUserData("selectedTracker")
    end,

    ------------------------------------------------------------

    GetObjectiveButton = function(self, objectiveTitle)
        for _, button in pairs(self:GetUserData("objectiveList").children) do
            if button:GetUserData("objectiveTitle") == objectiveTitle then
                return button
            end
        end
    end,

    ------------------------------------------------------------

    GetTrackerButton = function(self, trackerInfo)
        for _, button in pairs(self:GetUserData("trackerList").children) do
            if button:GetUserData("trackerType") == trackerInfo.trackerType and button:GetUserData("trackerID") == trackerInfo.trackerID then
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
            local label = AceGUI:Create("FarmingBar_InteractiveLabel")
            label:SetFullWidth(true)
            label:SetText(objectiveTitle)
            label:SetIcon(addon:GetObjectiveIcon(objectiveTitle), nil, 13, 13)
            excludeList:AddChild(label)

            label:SetCallback("OnClick", function(_, _, buttonClicked) excludeListLabel_OnClick(self, buttonClicked, key) end)

            label:SetTooltip(addon.GetExcludeListLabelTooltip)
        end
    end,

    ------------------------------------------------------------

    LoadObjectives = function(self, objectiveTitle)
        local objectiveList = self:GetUserData("objectiveList")
        local filter = self:GetUserData("objectiveSearchBox"):GetText()
        objectiveList:ReleaseChildren()

        ------------------------------------------------------------

        for objectiveTitle, objectiveInfo in addon.pairs(FarmingBar.db.global.objectives, function(a, b) return strupper(a) < strupper(b) end) do
            local notFiltered = not filter or strfind(strupper(objectiveTitle), strupper(filter))
            local autoFilterEnabled = addon:GetDBValue("global", "settings.misc.filterOBAutoItems")
            local notAutoFiltered = autoFilterEnabled and not addon:IsObjectiveAutoItem(objectiveTitle) or not autoFilterEnabled

            if notFiltered and notAutoFiltered then
                local button = AceGUI:Create("FarmingBar_ObjectiveButton")
                button:SetFullWidth(true)
                button:SetObjective(objectiveTitle)
                objectiveList:AddChild(button)
            end
        end

        ------------------------------------------------------------

        local selectedObjectiveTitle = objectiveTitle or self:GetSelectedObjective()

        if selectedObjectiveTitle then
            self:GetObjectiveButton(selectedObjectiveTitle):Select() --! "attempt to index a nil value" deleting while renaming
        end
    end,

    ------------------------------------------------------------

    LoadTrackers = function(self, trackerInfo)
        local _, objectiveInfo, _, selectedTrackerInfo = self:GetSelectedObjectiveInfo()
        local trackerList = ObjectiveBuilder:GetUserData("trackerList")

        trackerList:ReleaseChildren()

        ------------------------------------------------------------

        for tracker, trackerInfo in pairs(objectiveInfo.trackers) do
            local button = AceGUI:Create("FarmingBar_TrackerButton")
            button:SetFullWidth(true)
            button:SetTracker(trackerInfo)
            trackerList:AddChild(button)
        end

        ------------------------------------------------------------

        local selectedTracker = trackerInfo or selectedTrackerInfo

        if selectedTracker then
            self:GetTrackerButton(selectedTracker):Select()
        end
    end,

    ------------------------------------------------------------

    SelectObjective = function(self, objectiveTitle)
        local mainPanel = self:GetUserData("mainPanel")
        self:SetUserData("selectedObjective", objectiveTitle)

        mainPanel:ReleaseChildren()

        if objectiveTitle then
            local title = AceGUI:Create("FarmingBar_InteractiveLabel")
            title:SetFontObject(GameFontNormalLarge)
            title:SetText(objectiveTitle)
            title:SetIcon(addon:GetObjectiveIcon(objectiveTitle), nil, 20, 20)
            mainPanel:AddChild(title)

            ------------------------------------------------------------

            local mainTabGroup = AceGUI:Create("TabGroup")
            mainTabGroup:SetLayout("Fill")
            mainTabGroup:SetTabs(mainTabGroupTabs)
            mainPanel:AddChild(mainTabGroup)
            self:SetUserData("mainTabGroup", mainTabGroup)

            mainTabGroup:SetCallback("OnGroupSelected", mainTabGroup_OnGroupSelected)
            mainTabGroup:SelectTab(self:GetSelectedTab(objectiveTitle) or "objectiveTab")
        end
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

function addon:Initialize_ObjectiveBuilder()
    ObjectiveBuilder = AceGUI:Create("FarmingBar_Frame")
    ObjectiveBuilder:SetTitle("Farming Bar "..L["Objective Builder"])
    ObjectiveBuilder:SetLayout("FB30_Table")
    ObjectiveBuilder:SetUserData("table", ObjectiveBuilder_TableInfo)
    ObjectiveBuilder:SetUserData("selectedTabs", {})
    ObjectiveBuilder:SetUserData("scrollFrames", ObjectiveBuilder_ScrollFrames)
    ObjectiveBuilder:SetUserData("scrollvalues", {})
    addon.ObjectiveBuilder = ObjectiveBuilder

    ObjectiveBuilder:SetCallback("OnMouseDown", function(self)
        for scrollFrame, status in pairs(self:GetUserData("scrollFrames")) do
            local widget = self:GetUserData(scrollFrame)
            if widget then
                self:GetUserData("scrollvalues")[scrollFrame] = status.scrollvalue
            end
        end
    end)

    ObjectiveBuilder:SetCallback("OnMouseUp", function(self)
        for scrollFrame, scrollvalue in pairs(self:GetUserData("scrollvalues")) do
            local widget = self:GetUserData(scrollFrame)
            if widget then
                widget:SetScroll(scrollvalue)
                widget.scrollbar:SetValue(scrollvalue)
            end
        end
    end)

    for method, func in pairs(methods) do
        ObjectiveBuilder[method] = func
    end

    ------------------------------------------------------------

    local topPanel = AceGUI:Create("FarmingBar_InlineGroup")
    topPanel:SetFullWidth(true)
    topPanel:SetLayout("Flow")
    ObjectiveBuilder:AddChild(topPanel)

    ------------------------------------------------------------

    local newObjective = AceGUI:Create("FarmingBar_InteractiveLabel")
    newObjective:SetText(L["New Objective"])
    newObjective:SetTextHighlight(1, .82, 0, 1)
    newObjective:SetWordWrap(false)
    newObjective:SetIcon(514607, nil, 13, 13)
    topPanel:AddChild(newObjective)

    newObjective:SetCallback("OnClick", function() addon:CreateObjective() end)
    newObjective:SetCallback("OnReceiveDrag", function() addon:CreateObjectiveFromCursor() end)

    if FarmingBar.db.global.hints.ObjectiveBuilder then
        newObjective:SetTooltip(addon.GetNewObjectiveButtonTooltip)
    end

    ------------------------------------------------------------

    local importObjective = AceGUI:Create("FarmingBar_InteractiveLabel")
    importObjective:SetText(L["Import Objective"])
    importObjective:SetIcon([[INTERFACE\ADDONS\FARMINGBAR\MEDIA\IMPORT]], nil, 13, 13)
    importObjective:SetTextHighlight(1, .82, 0, 1)
    importObjective:SetIconColor(1, .82, 0, 1)
    importObjective:SetDisabled(true)
    topPanel:AddChild(importObjective)

    -- importObjectiveButton:SetCallback("OnClick", importObjective_OnClick) -- TODO: implement import/export

    ------------------------------------------------------------

    -- TODO: Custom checkbox
    local filterAutoItems = AceGUI:Create("CheckBox")
    filterAutoItems:SetLabel(L["Filter Auto Items"])
    filterAutoItems:SetValue(FarmingBar.db.global.settings.misc.filterOBAutoItems)
    filterAutoItems:SetWidth(filterAutoItems.text:GetStringWidth() + filterAutoItems.checkbg:GetWidth())
    topPanel:AddChild(filterAutoItems)
    ObjectiveBuilder.filterAutoItems = filterAutoItems

    filterAutoItems:SetCallback("OnEnter", filterAutoItems_OnEnter)
    filterAutoItems:SetCallback("OnLeave", filterAutoItems_OnLeave)
    filterAutoItems:SetCallback("OnValueChanged", filterAutoItems_OnValueChanged)

    -- ------------------------------------------------------------

    local sidebar = AceGUI:Create("FarmingBar_InlineGroup")
    sidebar:SetFullHeight(true)
    sidebar:SetLayout("FB30_PaddedList")
    sidebar:SetUserData("childPadding", 10)
    ObjectiveBuilder:AddChild(sidebar)

    ------------------------------------------------------------

    local objectiveSearchBox = AceGUI:Create("FarmingBar_SearchBox")
    objectiveSearchBox:SetFullWidth(true)
    sidebar:AddChild(objectiveSearchBox)
    ObjectiveBuilder:SetUserData("objectiveSearchBox", objectiveSearchBox)

    objectiveSearchBox:SetCallback("OnTextChanged", function() ObjectiveBuilder:LoadObjectives() end)

    ------------------------------------------------------------

    local objectiveListContainer = AceGUI:Create("FarmingBar_InlineGroup")
    objectiveListContainer:SetFullWidth(true)
    objectiveListContainer:SetFullHeight(true)
    objectiveListContainer:SetLayout("Fill")
    sidebar:AddChild(objectiveListContainer)

    ------------------------------------------------------------

    local objectiveList = AceGUI:Create("ScrollFrame")
    objectiveList:SetLayout("FB30_PaddedList")
    objectiveList:SetUserData("childPadding", 5)
    objectiveList:SetUserData("renaming", {})
    objectiveList:SetStatusTable(ObjectiveBuilder:GetUserData("scrollFrames").objectiveList)
    objectiveListContainer:AddChild(objectiveList)
    ObjectiveBuilder:SetUserData("objectiveList", objectiveList)

    objectiveList:SetScroll(objectiveList.status.scrollvalue)

    -- ------------------------------------------------------------

    local mainPanel = AceGUI:Create("FarmingBar_InlineGroup")
    mainPanel:SetLayout("FB30_Table")
    mainPanel:SetUserData("table", ObjectiveBuilderMainPanel_TableInfo)
    ObjectiveBuilder:AddChild(mainPanel)
    ObjectiveBuilder:SetUserData("mainPanel", mainPanel)

    ------------------------------------------------------------

    self.MenuFrame = self.MenuFrame or CreateFrame("Frame", "FarmingBarMenuFrame", UIParent, "UIDropDownMenuTemplate")
    self:Initialize_DragFrame()

    ------------------------------------------------------------
    --Debug-----------------------------------------------------
    ------------------------------------------------------------
    if FarmingBar.db.global.debug.ObjectiveBuilder then
        C_Timer.After(1, function()
            ObjectiveBuilder:Load()

            -- for key, objective in pairs(addon.ObjectiveBuilder.children) do
            --     objective.button.frame:Click()
            --     if FarmingBar.db.global.debug.ObjectiveBuilderTrackers then
            --         addon.ObjectiveBuilder.mainContent:SelectTab("trackersTab")

            --         if key == #addon.ObjectiveBuilder.children then
            --             for _, tracker in pairs(ObjectiveBuilder.trackerList.status.children) do
            --                 tracker.button.frame:Click()
            --                 break
            --             end
            --         end
            --     elseif FarmingBar.db.global.debug.ObjectiveBuilderCondition then
            --         addon.ObjectiveBuilder.mainContent:SelectTab("conditionTab")
            --     end
            --     break
            -- end
        end)
    end
    ------------------------------------------------------------
    ------------------------------------------------------------
end

--*------------------------------------------------------------------------

function addon:ObjectiveBuilder_LoadObjectiveTab(tabContent)
    local objectiveTitle, objectiveInfo = ObjectiveBuilder:GetSelectedObjectiveInfo()
    if not objectiveTitle then return end

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

    local displayRef = AceGUI:Create("Heading")
    displayRef:SetFullWidth(true)
    displayRef:SetText(L["Display Reference"])
    tabContent:AddChild(displayRef)

    ------------------------------------------------------------

    local displayRefHelp = AceGUI:Create("FarmingBar_InteractiveLabel")
    displayRefHelp:SetWidth(30)
    displayRefHelp:SetIcon(616343, nil, 25, 25)
    tabContent:AddChild(displayRefHelp)

    displayRefHelp:SetCallback("OnClick", displayRefHelp_OnClick)

    ------------------------------------------------------------

    if ObjectiveBuilder:GetUserData("showDisplayRefHelp") then
        local displayRefHelpLabel = AceGUI:Create("InteractiveLabel")
        displayRefHelpLabel:SetFullWidth(true)
        --@retail@
        displayRefHelpLabel:SetText(L.DisplayReferenceDescription)
        --@end-retail@
        --[===[@non-retail@
        -- Removing the currency reference from Classic here to make the localization page cleanier/easier to translate.
        displayRefHelpLabel:SetText(gsub(L.DisplayReferenceDescription, L.DisplayReferenceDescription_Gsub, ""))
        --@end-non-retail@]===]
        tabContent:AddChild(displayRefHelpLabel)

        displayRefHelpLabel:SetCallback("OnClick", displayRefHelp_OnClick)
    end

    ------------------------------------------------------------

    local displayRefTrackerType = AceGUI:Create("Dropdown")
    displayRefTrackerType:SetFullWidth(0.9)
    displayRefTrackerType:SetLabel(L["Type"])
    displayRefTrackerType:SetList(displayRefTrackerTypeList, displayRefTrackerTypeListSort)
    displayRefTrackerType:SetValue(objectiveInfo.displayRef.trackerType or "NONE")
    tabContent:AddChild(displayRefTrackerType)

    displayRefTrackerType:SetCallback("OnValueChanged", displayRefTrackerType_OnValueChanged)

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

function addon:ObjectiveBuilder_LoadTrackersTab(tabContent)
    local objectiveTitle, objectiveInfo = ObjectiveBuilder:GetSelectedObjectiveInfo()
    if not objectiveTitle then return end

    ------------------------------------------------------------

    local trackerCondition = AceGUI:Create("Dropdown")
    trackerCondition:SetFullWidth(true)
    trackerCondition:SetLabel(L["Tracker Condition"])
    trackerCondition:SetList(trackerConditionList, trackerConditionListSort)
    trackerCondition:SetValue(objectiveInfo.trackerCondition)
    tabContent:AddChild(trackerCondition)

    trackerCondition:SetCallback("OnValueChanged", trackerCondition_OnValueChanged)

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

    local newTrackerButton = AceGUI:Create("FarmingBar_InteractiveLabel")
    newTrackerButton:SetText(L["New Tracker"])
    newTrackerButton:SetTextHighlight(1, .82, 0, 1)
    newTrackerButton:SetWordWrap(false)
    newTrackerButton:SetIcon(514607, nil, 13, 13)
    tabContent:AddChild(newTrackerButton)

    newTrackerButton:SetCallback("OnClick", function() addon:CreateTracker() end)
    newTrackerButton:SetCallback("OnReceiveDrag", function() addon:CreateTracker(true) end)
    if FarmingBar.db.global.hints.ObjectiveBuilder then
        newTrackerButton:SetTooltip(addon.GetNewTrackerButtonTooltip)
    end

    ------------------------------------------------------------

    local spacer = AceGUI:Create("Label")
    spacer:SetFullWidth(true)
    spacer:SetText("")
    tabContent:AddChild(spacer)

    ------------------------------------------------------------

    local trackerContent = AceGUI:Create("FarmingBar_SimpleGroup")
    trackerContent:SetFullWidth(true)
    trackerContent:SetAutoAdjustHeight(false)
    trackerContent:SetHeight(ObjectiveBuilder:GetUserData("trackerContentHeight") or 200)
    trackerContent:SetLayout("FB30_Table")
    trackerContent:SetUserData("table", ObjectiveBuilderTrackerContent_TableInfo)
    tabContent:AddChild(trackerContent)

    ------------------------------------------------------------

    local trackerListContainer = AceGUI:Create("FarmingBar_InlineGroup")
    trackerListContainer:SetFullWidth(true)
    trackerListContainer:SetFullHeight(true)
    trackerListContainer:SetLayout("Fill")
    trackerContent:AddChild(trackerListContainer)

    ------------------------------------------------------------

    local trackerList = AceGUI:Create("ScrollFrame")
    trackerList:SetLayout("FB30_PaddedList")
    trackerList:SetUserData("childPadding", 5)
    trackerList:SetStatusTable(ObjectiveBuilder:GetUserData("scrollFrames").trackerList)
    trackerListContainer:AddChild(trackerList)
    ObjectiveBuilder:SetUserData("trackerList", trackerList)

    trackerList:SetScroll(trackerList.status.scrollvalue)

    ------------------------------------------------------------

    local trackerPanel = AceGUI:Create("FarmingBar_InlineGroup")
    trackerPanel:SetLayout("Flow")
    trackerContent:AddChild(trackerPanel)

    ------------------------------------------------------------

    local trackerContentSizer = AceGUI:Create("FarmingBar_Sizer")
    trackerContentSizer:SetFullWidth(true)
    trackerContentSizer:SetHeight(5)
    trackerContentSizer:SetWidget(trackerContent, "BOTTOM")
    tabContent:AddChild(trackerContentSizer)

    trackerContentSizer:SetCallback("OnMouseUp", function(self) trackerContentSizer_OnMouseUp(self, trackerContent, tabContent) end)

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
    trackerObjective:SetCallback("OnTextChanged", function(self) NumericEditBox_OnTextChanged(self) end)

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
    excludeList:SetStatusTable(ObjectiveBuilder:GetUserData("scrollFrames").excludeList)
    excludeListContainer:AddChild(excludeList)
    ObjectiveBuilder.excludeList = excludeList

    excludeList:SetScroll(excludeList.status.scrollvalue)

    ------------------------------------------------------------

    ObjectiveBuilder:LoadExcludeList()
end


