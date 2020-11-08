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
    ObjectiveBuilder:LoadDisplayIcon()
end

------------------------------------------------------------

local function customCondition_OnEnterPressed(self)
    local condition = self:GetText()
    local validCondition, err = addon:ValidateCustomCondition(condition)

    if validCondition then
        addon:SetObjectiveDBInfo("customCondition", condition)
    else
        addon:ReportError(L.InvalidCustomCondition)
        print(err)
        self:SetFocus()
        self:HighlightText()
    end
end

-- local x = 10
-- local tbl =  {{t1 = x, t2 = 2, t3 = 3}, {t1 = 5}}
-- return tbl

------------------------------------------------------------

local function displayIcon_OnEnterPressed(self)
    addon:SetObjectiveDBInfo("icon", self:GetText())
end

------------------------------------------------------------

local function displayRefHelp_OnClick(self)
    if not self.text:GetText() then
        --@retail@
        self:SetText(L.DisplayReferenceDescription)
        --@end-retail@
        --[===[@non-retail@
        -- Removing the currency reference from Classic here to make the localization page cleanier/easier to translate.
        displayRefHelpLabel:SetText(gsub(L.DisplayReferenceDescription, L.DisplayReferenceDescription_Gsub, ""))
        --@end-non-retail@]===]
    else
        self:SetText()
    end

    self.parent:DoLayout()
end

------------------------------------------------------------

local function displayRefMacrotext_OnEnterPressed(self)
    addon:SetObjectiveDBInfo("displayRef.trackerID", self:GetText())
end

------------------------------------------------------------

local function displayRefMacrotext_OnEscapePressed(self)
    local objectiveTitle, objectiveInfo = addon:GetSelectedObjectiveInfo()
    self:SetText(objectiveInfo.displayRef.trackerID)
end

------------------------------------------------------------

local function displayRefTrackerID_OnEnterPressed(self)
    local objectiveTitle, objectiveInfo = addon:GetSelectedObjectiveInfo()
    local trackerID = self:GetText()
    local validTrackerID, trackerType = addon:ValidateObjectiveData(objectiveInfo.displayRef.trackerType, trackerID)

    if validTrackerID then
        addon:SetObjectiveDBInfo("displayRef.trackerID", validTrackerID)

        self:SetText(validTrackerID)
        self:ClearFocus()
    else
        addon:ReportError(L.InvalidTrackerID(trackerType, trackerID))

        self:SetText()
        self:SetFocus()
    end
end

------------------------------------------------------------

local function displayRefTrackerID_OnEscapePressed(self)
    local objectiveTitle, objectiveInfo = addon:GetSelectedObjectiveInfo()
    self:SetText(objectiveInfo.displayRef.trackerID)
end

------------------------------------------------------------

local function displayRefTrackerType_OnValueChanged(self, _, selected)
    addon:SetObjectiveDBInfo("displayRef.trackerType", selected ~= "NONE" and selected or false)
    -- addon:SetObjectiveDBInfo("displayRef.trackerID", false) --! have to add checks if we do this
    ObjectiveBuilder:LoadDisplayRefEditbox()
end

------------------------------------------------------------

local function excludeListLabel_OnClick(self, buttonClicked)
    if IsShiftKeyDown() and buttonClicked == "RightButton" then
        local _, _, _, trackerInfo = ObjectiveBuilder:GetSelectedObjectiveInfo()

        for key, objectiveTitle in pairs(trackerInfo.exclude) do
            if objectiveTitle == self:GetText() then
                tremove(trackerInfo.exclude, key)
            end
        end

        ObjectiveBuilder:ReleaseChild(self)
        ObjectiveBuilder:GetUserData("excludeList"):DoLayout()
        ObjectiveBuilder:UpdateExcludeObjectivesDropdown()
    end
end

------------------------------------------------------------

local function excludeObjectives_OnValueChanged(self)
    local objective = self:GetValue()
    local objectiveTitle, _, _, trackerInfo = addon:GetSelectedObjectiveInfo()

    tinsert(trackerInfo.exclude, objective)
    addon:AddExcludeLabel(objective)
    ObjectiveBuilder:GetUserData("excludeList"):DoLayout()

    ObjectiveBuilder:UpdateExcludeObjectivesDropdown()
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
    ObjectiveBuilder:RefreshObjectives()
end

------------------------------------------------------------

local function help_OnClick(self)
    print("COWSHIT")
end

------------------------------------------------------------

local function includeAllChars_OnValueChanged(self)
    local objectiveTitle, _, tracker = ObjectiveBuilder:GetSelectedObjectiveInfo()
    addon:SetTrackerDBInfo(objectiveTitle, tracker, "includeAllChars", self:GetValue())end

------------------------------------------------------------

local function includeBank_OnValueChanged(self)
    local objectiveTitle, _, tracker = ObjectiveBuilder:GetSelectedObjectiveInfo()
    addon:SetTrackerDBInfo(objectiveTitle, tracker, "includeBank", self:GetValue())
    addon:UpdateButtons(objectiveTitle)
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
    mainContent:SetLayout("FB30_List")
    ObjectiveBuilder:SetUserData("mainContent", mainContent)
    self:AddChild(mainContent)

    ------------------------------------------------------------

    if selected == "objectiveTab" then
        addon:ObjectiveBuilder_LoadObjectiveTab(mainContent)
    elseif selected == "trackersTab" then
        addon:ObjectiveBuilder_LoadTrackersTab(mainContent)
    end
end

------------------------------------------------------------

local function newTrackerButton_OnClick(self)
    local objectiveTitle = ObjectiveBuilder:GetSelectedObjective()
    local trackerType = ObjectiveBuilder:GetUserData("trackerType"):GetValue()
    local editbox = ObjectiveBuilder:GetUserData("trackerID")
    local trackerID = editbox:GetText()
    if not trackerID or trackerID == "" then return end

    ------------------------------------------------------------

    local validTrackerID = addon:ValidateObjectiveData(trackerType, trackerID)

    if validTrackerID or trackerID == "" then
        local trackerIDExists = addon:TrackerExists(validTrackerID)

        if trackerIDExists then
            editbox:SetText()

            if validTrackerID ~= trackerID then
                addon:ReportError(L.TrackerIDExists(trackerID))

                editbox:SetFocus()
            end
        else
            editbox:SetText()
            addon:CreateTracker({trackerType = trackerType, trackerID = validTrackerID})
        end
    else
        addon:ReportError(L.InvalidTrackerID(trackerType, trackerID))

        editbox:HighlightText()
        editbox:SetFocus()
    end
end

------------------------------------------------------------

local function NumericEditBox_OnTextChanged(self)
    self:SetText(string.gsub(self:GetText(), "[%s%c%p%a]", ""))
    self.editbox:SetCursorPosition(strlen(self:GetText()))
end

------------------------------------------------------------

local function objectiveSearchBox_OnTextChanged(self)
    ObjectiveBuilder:RefreshObjectives()
end

------------------------------------------------------------

local function trackerCondition_OnValueChanged(_, _, selected)
    addon:SetObjectiveDBInfo("trackerCondition", selected)
    ObjectiveBuilder:LoadCustomCondition()
end

------------------------------------------------------------

local function trackerContentSizer_OnMouseUp(self, trackerContent, tabContent)
    ObjectiveBuilder:SetUserData("trackerContentHeight", trackerContent.frame:GetHeight())
    ObjectiveBuilder:GetUserData("mainTabGroup"):DoLayout()
end

------------------------------------------------------------

--!
local function trackerID_OnEnterPressed(self)
    self:ClearFocus()
    ObjectiveBuilder:GetUserData("newTrackerButton"):Fire("OnClick")
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

local function trackerType_OnValueChanged(self, _, selected)
    ObjectiveBuilder:GetUserData("trackerID"):SetLabel(addon:GetTrackerTypeLabel(selected))
end

--*------------------------------------------------------------------------

local methods = {
    ClearSelectedObjective = function(self)
        local objectiveTitle = self:GetSelectedObjective()
        if not objectiveTitle then return end
        self:GetObjectiveButton(objectiveTitle):SetSelected(false)

        self:GetUserData("selectedTabs")[objectiveTitle] = nil
        self:SetUserData("selectedObjective")
        self:SetUserData("selectedTracker")

        self:GetUserData("mainPanel"):ReleaseChildren()
    end,

    ------------------------------------------------------------

    ClearSelectedTracker = function(self)
        local objectiveTitle, objectiveInfo, tracker, trackerInfo = self:GetSelectedObjectiveInfo()
        if not trackerInfo then return end
        self:GetTrackerButton(trackerInfo):SetSelected(false)

        self:SetUserData("selectedTracker")

        self:GetUserData("trackerPanel"):ReleaseChildren()
        self:GetUserData("trackerPanel"):DoLayout()
    end,

    ------------------------------------------------------------

    GetObjectiveList = function(self)
        local selectedObjectiveTitle, _, _, trackerInfo = self:GetSelectedObjectiveInfo()

        local list = {}
        local sort = {}

        for objectiveTitle, _ in addon.pairs(FarmingBar.db.global.objectives, function(a, b) return strupper(a) < strupper(b) end) do
            if objectiveTitle ~= selectedObjectiveTitle and not addon:ObjectiveIsExcluded(trackerInfo.exclude, objectiveTitle) then
                list[objectiveTitle] = objectiveTitle
                tinsert(sort, objectiveTitle)
            end
        end

        return list, sort
    end,

    ------------------------------------------------------------

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
            if button:GetObjective() == objectiveTitle then
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

        ------------------------------------------------------------

        for _, button in pairs(self:GetUserData("objectiveList").children) do
            button:SetSelected(false)
        end

        ------------------------------------------------------------

        if objectiveTitle then
            self:SelectObjective(objectiveTitle)
            self:GetObjectiveButton(objectiveTitle):SetSelected(true)
        else
            self:ClearSelectedObjective()
        end
    end,

    ------------------------------------------------------------

    LoadCustomCondition = function(self)
        local objectiveTitle, objectiveInfo = self:GetSelectedObjectiveInfo()
        local tabContent = self:GetUserData("mainContent")

        self:ReleaseChild("customCondition")

        if objectiveInfo.trackerCondition == "CUSTOM" then
            local customCondition = AceGUI:Create("MultiLineEditBox")
            customCondition:SetFullWidth(true)
            customCondition:SetLabel(L["Custom Condition"])
            customCondition:SetText(objectiveInfo.customCondition)
            tabContent:AddChild(customCondition, tabContent.children[2])
            self:SetUserData("customCondition", customCondition)

            customCondition:SetCallback("OnEnterPressed", customCondition_OnEnterPressed)
        end

        tabContent:DoLayout()
    end,

    ------------------------------------------------------------

    LoadDisplayIcon = function(self)
        local objectiveTitle, objectiveInfo = self:GetSelectedObjectiveInfo()
        local tabContent = self:GetUserData("mainContent")

        self:ReleaseChild("displayIcon")
        self:ReleaseChild("chooseButton")

        if not objectiveInfo.autoIcon then
            local displayIcon = AceGUI:Create("EditBox")
            displayIcon:SetRelativeWidth(1/2)
            displayIcon:SetText(objectiveInfo.icon)
            tabContent:AddChild(displayIcon, tabContent.children[2])
            self:SetUserData("displayIcon", displayIcon)

            displayIcon:SetCallback("OnEnterPressed", displayIcon_OnEnterPressed)

            ------------------------------------------------------------

            local chooseButton = AceGUI:Create("Button")
            chooseButton:SetRelativeWidth(1/2)
            chooseButton:SetText(L["Choose"])
            tabContent:AddChild(chooseButton, tabContent.children[3])
            self:SetUserData("chooseButton", chooseButton)

            -- chooseButton:SetCallback("OnClick", function() self.IconSelector:Show() end) -- TODO: Icon selector frame
        end

        tabContent:DoLayout()
    end,

    ------------------------------------------------------------

    LoadDisplayRefEditbox = function(self)
        local objectiveTitle, objectiveInfo = addon:GetSelectedObjectiveInfo()
        local tabContent = self:GetUserData("mainContent")

        self:ReleaseChild("displayRefMacrotext")
        self:ReleaseChild("displayRefTrackerID")

        ------------------------------------------------------------

        local editbox

        if objectiveInfo.displayRef.trackerType == "MACROTEXT" then
            editbox = AceGUI:Create("MultiLineEditBox")
            editbox:SetLabel(L["Macrotext"])
            self:SetUserData("displayRefMacrotext", editbox)

            editbox:SetCallback("OnEnterPressed", displayRefMacrotext_OnEnterPressed)
            editbox:SetCallback("OnEscapePressed", displayRefMacrotext_OnEscapePressed)
        elseif objectiveInfo.displayRef.trackerType and objectiveInfo.displayRef.trackerType ~= "NONE" then
            editbox = AceGUI:Create("FarmingBar_EditBox")
            editbox:SetLabel(addon:GetTrackerTypeLabel(objectiveInfo.displayRef.trackerType))
            editbox:SetLink(true)
            self:SetUserData("displayRefTrackerID", editbox)

            editbox:SetCallback("OnEnterPressed", displayRefTrackerID_OnEnterPressed)
            editbox:SetCallback("OnEscapePressed", displayRefTrackerID_OnEscapePressed)
        end

        ------------------------------------------------------------

        if editbox then
            editbox:SetFullWidth(true)
            editbox:SetText(objectiveInfo.displayRef.trackerID or "")
            tabContent:AddChild(editbox)
        end

        tabContent:DoLayout()
    end,

    ------------------------------------------------------------

    LoadExcludeList = function(self)
        local _, _, _, trackerInfo = addon:GetSelectedObjectiveInfo()
        local excludeList = ObjectiveBuilder:GetUserData("excludeList")

        excludeList:ReleaseChildren()

        ------------------------------------------------------------

        for key, objectiveTitle in addon.pairs(trackerInfo.exclude) do
            addon:AddExcludeLabel(objectiveTitle)
        end
    end,

    ------------------------------------------------------------

    LoadObjectives = function(self)
        for objectiveTitle, _ in addon.pairs(FarmingBar.db.global.objectives) do
            addon:AddObjectiveButton(objectiveTitle)
        end

        self:RefreshObjectives()
    end,

    ------------------------------------------------------------

    LoadTrackers = function(self)
        local _, objectiveInfo, selectedTracker = self:GetSelectedObjectiveInfo()

        for tracker, trackerInfo in addon.pairs(objectiveInfo.trackers) do
            local button = addon:AddTrackerButton(tracker, trackerInfo)
            if tracker == selectedTracker then
                button:Select()
            end
        end
    end,

    ------------------------------------------------------------

    RefreshObjectives = function(self, objectiveTitle)
        local objectiveList = self:GetUserData("objectiveList")

        for key, button in pairs(objectiveList.children) do
            local objectiveTitle = button:GetObjective()

            local filter = self:GetUserData("objectiveSearchBox"):GetText()
            local filtered = filter and not strfind(strupper(objectiveTitle), strupper(filter))

            local autoFilterEnabled = addon:GetDBValue("global", "settings.misc.filterOBAutoItems")
            local autoFiltered = autoFilterEnabled and addon:IsObjectiveAutoItem(objectiveTitle)

            local objectiveExists = FarmingBar.db.global.objectives[objectiveTitle]

            ------------------------------------------------------------

            if objectiveExists and not filtered and not autoFiltered then
                -- Show the button and refresh the icon (this method is called on icon changes)
                button:SetUserData("filtered", false)
                button:RefreshIcon()
            else
                -- Hide the button and clear selected
                button:SetUserData("filtered", true)
                button:SetSelected(false)

                if autoFiltered and self:GetSelectedObjective() == objectiveTitle then
                    -- If an auto item is selected and then filtered, clear the selection
                    self:ClearSelectedObjective()
                end
            end
        end

        objectiveList:DoLayout()
    end,

    ------------------------------------------------------------

    ReleaseChild = function(self, widget)
        -- Releasing widgets doesn't remove them from the parent container's children table, so we need to do it manually
        -- Remove the userdata reference to prevent error about already having been released

        widget = ObjectiveBuilder:GetUserData(widget) or widget
        if not widget.parent then return end
        local children = widget.parent.children

        for key, child in pairs(children) do
            if widget == child then
                child:Release()
                ObjectiveBuilder:SetUserData(widget)
                tremove(children, key)
            end
        end
    end,

    ------------------------------------------------------------

    SelectObjective = function(self, objectiveTitle)
        local mainPanel = self:GetUserData("mainPanel")
        self:SetUserData("selectedObjective", objectiveTitle)
        self:SetUserData("selectedTracker")

        mainPanel:ReleaseChildren()

        if objectiveTitle then
            local title = AceGUI:Create("FarmingBar_InteractiveLabel")
            title:SetFontObject(GameFontNormalLarge)
            title:SetText(objectiveTitle)
            title:SetIcon(addon:GetObjectiveIcon(objectiveTitle), nil, 20, 20)
            mainPanel:AddChild(title)

            ------------------------------------------------------------

            local mainTabGroup = AceGUI:Create("TabGroup")
            mainTabGroup:SetFullWidth(true)
            mainTabGroup:SetFullHeight(true)
            mainTabGroup:SetLayout("Fill")
            mainTabGroup:SetTabs(mainTabGroupTabs)
            mainPanel:AddChild(mainTabGroup)
            self:SetUserData("mainTabGroup", mainTabGroup)

            mainTabGroup:SetCallback("OnGroupSelected", mainTabGroup_OnGroupSelected)
            mainTabGroup:SelectTab(self:GetSelectedTab(objectiveTitle) or "objectiveTab")
        end
    end,

    ------------------------------------------------------------

    SelectTracker = function(self, tracker)
        self:SetUserData("selectedTracker", tracker)
        addon:ObjectiveBuilder_LoadTrackerInfo()
    end,

    ------------------------------------------------------------

    UpdateExcludeObjectivesDropdown = function(self)
        local excludeObjectives = self:GetUserData("excludeObjectives")
        excludeObjectives:SetList(self:GetObjectiveList())
        excludeObjectives:SetDisabled(addon.tcount(excludeObjectives.list) == 0)
        excludeObjectives:SetValue()
    end,
}

------------------------------------------------------------

function addon:Initialize_ObjectiveBuilder()
    ObjectiveBuilder = AceGUI:Create("FarmingBar_Frame")
    ObjectiveBuilder:SetTitle("Farming Bar "..L["Objective Builder"])
    ObjectiveBuilder:SetLayout("FB30_TopSidebarGroup")
    ObjectiveBuilder:SetUserData("selectedTabs", {})
    ObjectiveBuilder:SetUserData("sidebarDenom", 4)
    addon.ObjectiveBuilder = ObjectiveBuilder

    for method, func in pairs(methods) do
        ObjectiveBuilder[method] = func
    end

    ------------------------------------------------------------

    local topPanel = AceGUI:Create("FarmingBar_InlineGroup")
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

    ------------------------------------------------------------

    local help = AceGUI:Create("FarmingBar_InteractiveLabel")
    help:SetIcon(616343, nil, 25, 25)
    help:SetOffsetH(-7)
    help:SetText(L["Help"])
    topPanel:AddChild(help)

    help:SetCallback("OnClick", help_OnClick)

    -- ------------------------------------------------------------

    local sidebar = AceGUI:Create("FarmingBar_InlineGroup")
    sidebar:SetLayout("FB30_List")
    sidebar:SetUserData("childPadding", 10)
    ObjectiveBuilder:AddChild(sidebar)

    ------------------------------------------------------------

    local objectiveSearchBox = AceGUI:Create("FarmingBar_SearchBox")
    objectiveSearchBox:SetFullWidth(true)
    sidebar:AddChild(objectiveSearchBox)
    ObjectiveBuilder:SetUserData("objectiveSearchBox", objectiveSearchBox)

    objectiveSearchBox:SetCallback("OnTextChanged", objectiveSearchBox_OnTextChanged)

    ------------------------------------------------------------

    local objectiveListContainer = AceGUI:Create("FarmingBar_InlineGroup")
    objectiveListContainer:SetFullWidth(true)
    objectiveListContainer:SetFullHeight(true)
    objectiveListContainer:SetLayout("Fill")
    sidebar:AddChild(objectiveListContainer)

    ------------------------------------------------------------

    local objectiveList = AceGUI:Create("ScrollFrame")
    objectiveList:SetLayout("FB30_List")
    objectiveList:SetUserData("childPadding", 5)
    objectiveList:SetUserData("renaming", {})
    objectiveList:SetUserData("sortFunc", function(a, b)
        return strupper(a:GetObjective()) < strupper(b:GetObjective())
    end)
    objectiveListContainer:AddChild(objectiveList)
    ObjectiveBuilder:SetUserData("objectiveList", objectiveList)

    ------------------------------------------------------------

    local mainPanel = AceGUI:Create("FarmingBar_InlineGroup")
    mainPanel:SetLayout("Flow")
    ObjectiveBuilder:AddChild(mainPanel)
    ObjectiveBuilder:SetUserData("mainPanel", mainPanel)

    ------------------------------------------------------------

    self.MenuFrame = self.MenuFrame or CreateFrame("Frame", "FarmingBarMenuFrame", UIParent, "UIDropDownMenuTemplate")
    self:Initialize_DragFrame()
    ObjectiveBuilder:LoadObjectives()

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

function addon:AddObjectiveButton(objectiveTitle)
    local objectiveList = ObjectiveBuilder:GetUserData("objectiveList")

    local button = AceGUI:Create("FarmingBar_ObjectiveButton")
    button:SetFullWidth(true)
    button:SetObjective(objectiveTitle)
    objectiveList:AddChild(button)
    objectiveList:DoLayout()

    return button
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

    ObjectiveBuilder:LoadDisplayIcon()

    ------------------------------------------------------------

    local displayRef = AceGUI:Create("Heading")
    displayRef:SetFullWidth(true)
    displayRef:SetText(L["Display Reference"])
    tabContent:AddChild(displayRef)

    ------------------------------------------------------------

    local displayRefHelp = AceGUI:Create("FarmingBar_InteractiveLabel")
    displayRefHelp:SetIcon(616343, nil, 25, 25)
    displayRefHelp:SetAutoWidth(false)
    tabContent:AddChild(displayRefHelp)

    displayRefHelp:SetCallback("OnClick", displayRefHelp_OnClick)

    ------------------------------------------------------------

    local displayRefTrackerType = AceGUI:Create("Dropdown")
    displayRefTrackerType:SetFullWidth(0.9)
    displayRefTrackerType:SetLabel(L["Type"])
    displayRefTrackerType:SetList(displayRefTrackerTypeList, displayRefTrackerTypeListSort)
    displayRefTrackerType:SetValue(objectiveInfo.displayRef.trackerType or "NONE")
    tabContent:AddChild(displayRefTrackerType)

    displayRefTrackerType:SetCallback("OnValueChanged", displayRefTrackerType_OnValueChanged)

    ObjectiveBuilder:LoadDisplayRefEditbox()
end

--*------------------------------------------------------------------------

function addon:AddExcludeLabel(objectiveTitle)
    local label = AceGUI:Create("FarmingBar_InteractiveLabel")
    label:SetFullWidth(true)
    label:SetText(objectiveTitle)
    label:SetIcon(self:GetObjectiveIcon(objectiveTitle), nil, 13, 13)
    label:SetTooltip(self.GetExcludeListLabelTooltip)
    ObjectiveBuilder:GetUserData("excludeList"):AddChild(label)

    label:SetCallback("OnClick", function(self, _, buttonClicked) excludeListLabel_OnClick(self, buttonClicked) end)

    return label
end
------------------------------------------------------------

function addon:AddTrackerButton(tracker, trackerInfo)
    local trackerList = ObjectiveBuilder:GetUserData("trackerList")
    local _, objectiveInfo = ObjectiveBuilder:GetSelectedObjectiveInfo()

    local button = AceGUI:Create("FarmingBar_TrackerButton")
    button:SetFullWidth(true)
    button:SetTracker(tracker, trackerInfo)
    trackerList:AddChild(button)
    trackerList:DoLayout()

    return button
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

    ObjectiveBuilder:LoadCustomCondition()

    ------------------------------------------------------------

    local newTracker = AceGUI:Create("Heading")
    newTracker:SetFullWidth(true)
    newTracker:SetText(L["New Tracker"])
    tabContent:AddChild(newTracker)

    ------------------------------------------------------------

    --@retail@
    local trackerType = AceGUI:Create("Dropdown")
    trackerType:SetFullWidth(true)
    trackerType:SetLabel(L["Type"])
    trackerType:SetList(
        {
            ITEM = L["Item"],
            CURRENCY = L["Currency"],
        },
        {"ITEM", "CURRENCY"}
    )
    trackerType:SetValue("ITEM")
    tabContent:AddChild(trackerType)
    ObjectiveBuilder:SetUserData("trackerType", trackerType)

    trackerType:SetCallback("OnValueChanged", trackerType_OnValueChanged)
    --@end-retail@

    ------------------------------------------------------------

    local trackerID = AceGUI:Create("FarmingBar_EditBox")
    trackerID:SetFullWidth(true)
    trackerID:SetLabel(self:GetTrackerTypeLabel(trackerType:GetValue()))
    tabContent:AddChild(trackerID)
    ObjectiveBuilder:SetUserData("trackerID", trackerID)

    trackerID:SetCallback("OnEnterPressed", trackerID_OnEnterPressed)

    ------------------------------------------------------------

    local newTrackerButton = AceGUI:Create("Button")
    newTrackerButton:SetText(L["Add"])
    tabContent:AddChild(newTrackerButton)
    ObjectiveBuilder:SetUserData("newTrackerButton", newTrackerButton)

    newTrackerButton:SetCallback("OnClick", newTrackerButton_OnClick)

    ------------------------------------------------------------

    local trackers = AceGUI:Create("Heading")
    trackers:SetFullWidth(true)
    trackers:SetText(L["Trackers"])
    tabContent:AddChild(trackers)

    ------------------------------------------------------------

    local trackerContent = AceGUI:Create("SimpleGroup")
    trackerContent:SetFullWidth(true)
    trackerContent:SetHeight(ObjectiveBuilder:GetUserData("trackerContentHeight") or 200)
    trackerContent:SetAutoAdjustHeight(false)
    trackerContent:SetLayout("FB30_SidebarGroup")
    tabContent:AddChild(trackerContent)

    ------------------------------------------------------------

    local trackerListContainer = AceGUI:Create("FarmingBar_InlineGroup")
    trackerListContainer:SetLayout("Fill")
    trackerContent:AddChild(trackerListContainer)

    ------------------------------------------------------------

    local trackerList = AceGUI:Create("ScrollFrame")
    trackerList:SetLayout("FB30_List")
    trackerList:SetUserData("childPadding", 5)
    trackerListContainer:AddChild(trackerList)
    ObjectiveBuilder:SetUserData("trackerList", trackerList)

    ------------------------------------------------------------

    local trackerPanelContainer = AceGUI:Create("FarmingBar_InlineGroup")
    trackerPanelContainer:SetLayout("Fill")
    trackerContent:AddChild(trackerPanelContainer)

    ------------------------------------------------------------

    local trackerPanel = AceGUI:Create("ScrollFrame")
    trackerPanel:SetLayout("FB30_List")
    trackerPanel:SetUserData("childPadding", 5)
    trackerPanelContainer:AddChild(trackerPanel)
    ObjectiveBuilder:SetUserData("trackerPanel", trackerPanel)

    ------------------------------------------------------------

    local trackerContentSizer = AceGUI:Create("FarmingBar_Sizer")
    trackerContentSizer:SetFullWidth(true)
    trackerContentSizer:SetHeight(5)
    trackerContentSizer:SetWidget(trackerContent, "BOTTOM", {200, 200})
    tabContent:AddChild(trackerContentSizer)

    trackerContentSizer:SetCallback("OnMouseUp", function(self) trackerContentSizer_OnMouseUp(self, trackerContent, tabContent) end)

    ------------------------------------------------------------

    ObjectiveBuilder:LoadTrackers()
end

--*------------------------------------------------------------------------

function addon:ObjectiveBuilder_LoadTrackerInfo()
    local objectiveTitle, _, _, trackerInfo = ObjectiveBuilder:GetSelectedObjectiveInfo()
    local trackerButton = ObjectiveBuilder:GetTrackerButton(trackerInfo)
    local tabContent = ObjectiveBuilder:GetUserData("trackerPanel")

    tabContent:ReleaseChildren()

    if not objectiveTitle or not trackerInfo then return end

    ------------------------------------------------------------

    local title = AceGUI:Create("FarmingBar_InteractiveLabel")
    title:SetFontObject(GameFontNormalLarge)
    title:SetText(trackerButton:GetUserData("trackerName"))
    title:SetIcon(trackerButton:GetUserData("trackerIcon"), nil, 20, 20)
    tabContent:AddChild(title)

    ------------------------------------------------------------

    local trackerObjective = AceGUI:Create("EditBox")
    trackerObjective:SetFullWidth(true)
    trackerObjective:SetLabel(L["Objective"])
    trackerObjective:SetText(trackerInfo.objective or "")
    tabContent:AddChild(trackerObjective)

    trackerObjective:SetCallback("OnEnterPressed", trackerObjective_OnEnterPressed)
    trackerObjective:SetCallback("OnTextChanged", NumericEditBox_OnTextChanged)

    ------------------------------------------------------------

    local includeBank = AceGUI:Create("CheckBox")
    includeBank:SetFullWidth(true)
    includeBank:SetLabel(L["Include Bank"])
    includeBank:SetValue(trackerInfo.includeBank)
    tabContent:AddChild(includeBank)

    includeBank:SetCallback("OnValueChanged", includeBank_OnValueChanged)

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

    includeAllChars:SetCallback("OnValueChanged", includeAllChars_OnValueChanged)

    ------------------------------------------------------------

    local excludeObjectives = AceGUI:Create("Dropdown")
    excludeObjectives:SetFullWidth(true)
    excludeObjectives:SetLabel(L["Exclude Objective"])
    tabContent:AddChild(excludeObjectives)
    ObjectiveBuilder:SetUserData("excludeObjectives", excludeObjectives)

    excludeObjectives:SetCallback("OnValueChanged", excludeObjectives_OnValueChanged)

    ObjectiveBuilder:UpdateExcludeObjectivesDropdown()

    ------------------------------------------------------------

    local excludeListContainer = AceGUI:Create("SimpleGroup")
    excludeListContainer:SetFullWidth(true)
    excludeListContainer:SetHeight(150)
    excludeListContainer:SetLayout("Fill")
    tabContent:AddChild(excludeListContainer)

    ------------------------------------------------------------

    local excludeList = AceGUI:Create("ScrollFrame")
    excludeList:SetLayout("FB30_List")
    excludeList:SetUserData("sortFunc", function(a, b)
        return strupper(a:GetText()) < strupper(b:GetText())
    end)
    excludeListContainer:AddChild(excludeList)
    ObjectiveBuilder:SetUserData("excludeList", excludeList)

    ------------------------------------------------------------

    ObjectiveBuilder:LoadExcludeList()
end


