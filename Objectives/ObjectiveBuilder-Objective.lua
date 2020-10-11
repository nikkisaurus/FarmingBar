local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)
local AceGUI = LibStub("AceGUI-3.0", true)

local pairs = pairs
local gsub = string.gsub

--*------------------------------------------------------------------------

local function autoIcon_OnValueChanged(self)
    addon:SetObjectiveDBInfo(addon.ObjectiveBuilder:GetSelectedObjective(), "autoIcon", self:GetValue())

    addon.ObjectiveBuilder.mainContent:Refresh("Objective")
end

local function displayIcon_OnEnterPressed(self)
    addon:SetObjectiveDBInfo(addon.ObjectiveBuilder:GetSelectedObjective(), "icon", self:GetText())
    self:ClearFocus()

    addon.ObjectiveBuilder.mainContent:Refresh("Objective")
end

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

local function displayRefTrackerID_OnEnterPressed(self)
    local ObjectiveBuilder = addon.ObjectiveBuilder
    local objectiveTitle = ObjectiveBuilder:GetSelectedObjective()
    local objectiveInfo = addon:GetObjectiveInfo(objectiveTitle)
    local validTrackerID = addon:ValidateObjectiveData(objectiveInfo.displayRef.trackerType, self:GetText())

    if validTrackerID or self:GetText() == "" then

        addon:SetObjectiveDBInfo(objectiveTitle, "displayRef.trackerID", objectiveInfo.displayRef.trackerType == "ITEM" and validTrackerID or tonumber(self:GetText()))

        self:SetText(objectiveInfo.displayRef.trackerID)
        self:ClearFocus()

        ObjectiveBuilder.mainContent:Refresh("Objective")
    else
        self:SetText("")
        self:SetFocus()
    end
end

local function displayRefTrackerType_OnValueChanged(selected)
    local ObjectiveBuilder = addon.ObjectiveBuilder
    local objectiveTitle = ObjectiveBuilder:GetSelectedObjective()

    if selected == "NONE" then
        addon:SetObjectiveDBInfo(objectiveTitle, "displayRef.trackerType", false)
        addon:SetObjectiveDBInfo(objectiveTitle, "displayRef.trackerID", false)

    else
        addon:SetObjectiveDBInfo(objectiveTitle, "displayRef.trackerType", selected)
    end

    ObjectiveBuilder.mainContent:Refresh("Objective")
end

local function mainTabGroup_OnGroupSelected(self, selected)
    local ObjectiveBuilder = addon.ObjectiveBuilder
    local objectiveTitle = ObjectiveBuilder:GetSelectedObjective()

    self:ReleaseChildren()
    if selected == "objectiveTab" then
        self:SetLayout("Fill")
        addon:ObjectiveBuilder_LoadObjectiveTab(objectiveTitle)
    elseif selected == "conditionTab" then
        self:SetLayout("Fill")
        addon:ObjectiveBuilder_LoadConditionTab(objectiveTitle)
    elseif selected == "trackersTab" then
        self:SetLayout("FB30_2Column")
        addon:LoadTrackersTab(objectiveTitle)
    end
end

local function trackCondition_OnValueChanged(selected)
    local ObjectiveBuilder = addon.ObjectiveBuilder

    addon:SetObjectiveDBInfo(ObjectiveBuilder:GetSelectedObjective(), "trackCondition", selected)

    ObjectiveBuilder.mainContent:Refresh("Condition")
end

local function trackFunc_OnEnterPressed(self)
    addon:SetObjectiveDBInfo(addon.ObjectiveBuilder:GetSelectedObjective(), "trackFunc", self:GetText())
end

--*------------------------------------------------------------------------

local function GetTrackerContextMenu()
    local menu = {
        {
            text = L["Close"],
            notCheckable = true,
        },
    }

    return menu
end

--*------------------------------------------------------------------------

local methods = {
    ["Refresh"] = function(self, reloadTab)
        local ObjectiveBuilder = addon.ObjectiveBuilder

        ObjectiveBuilder:UpdateObjectiveIcon(ObjectiveBuilder:GetSelectedObjective())
        if reloadTab then
            addon["ObjectiveBuilder_Load"..reloadTab.."Tab"](addon, ObjectiveBuilder:GetSelectedObjective())
        end
    end,

    ["SelectObjective"] = function(self, objectiveTitle)
        local ObjectiveBuilder = addon.ObjectiveBuilder
        ObjectiveBuilder.status.objectiveTitle = objectiveTitle
        local mainPanel = ObjectiveBuilder.mainPanel.frame

        if objectiveTitle then
            mainPanel:Show()
        else
            mainPanel:Hide()
        end

        ObjectiveBuilder.mainContent:SelectTab("objectiveTab")
    end,
}

------------------------------------------------------------

function addon:ObjectiveBuilder_DrawTabs()
    local ObjectiveBuilder = self.ObjectiveBuilder
    local mainPanel = ObjectiveBuilder.mainPanel
    mainPanel:ReleaseChildren()

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

    mainTabGroup:SetCallback("OnGroupSelected", function(self, _, selected) mainTabGroup_OnGroupSelected(self, selected) end)

    for method, func in pairs(methods) do
        mainTabGroup[method] = func
    end
end

--*------------------------------------------------------------------------

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

    autoIcon:SetCallback("OnValueChanged", function(self) autoIcon_OnValueChanged(self) end)

    ------------------------------------------------------------

    if not objectiveInfo.autoIcon then
        local displayIcon = AceGUI:Create("EditBox")
        displayIcon:SetRelativeWidth(1/2)
        displayIcon:SetText(self:GetObjectiveInfo(objectiveTitle).icon)
        tabContent:AddChild(displayIcon, tabContent.displayRef)

        displayIcon:SetCallback("OnEnterPressed", function(self) displayIcon_OnEnterPressed(self) end)

        ------------------------------------------------------------

        local chooseButton = AceGUI:Create("Button")
        chooseButton:SetRelativeWidth(1/2)
        chooseButton:SetText(L["Choose"])
        tabContent:AddChild(chooseButton, tabContent.displayRef)

        -- chooseButton:SetCallback("OnClick", function() self.IconSelector:Show() end) -- TODO: Icon selector frame
    end

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

    displayRefTrackerType:SetCallback("OnValueChanged", function(_, _, selected) displayRefTrackerType_OnValueChanged(selected) end)

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
        displayRefTrackerID:SetLabel(self:GetObjectiveDataLabel(objectiveInfo.displayRef.trackerType))
        displayRefTrackerID:SetText(objectiveInfo.displayRef.trackerID or "")
        tabContent:AddChild(displayRefTrackerID)

        displayRefTrackerID:SetCallback("OnEnterPressed", function(self) displayRefTrackerID_OnEnterPressed(self) end)
    end
end

------------------------------------------------------------

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

    if objectiveInfo.trackCondition == "CUSTOM" then
        -- TODO: Conditions...
        -- local list = {
        --     ALL = L["All of"],
        --     ANY = L["Any of"],
        -- }
        -- local sortlist = {"ALL", "ANY"}

        -- local condition1 = AceGUI:Create("Dropdown")
        -- condition1:SetRelativeWidth(1/2)
        -- condition1:SetLabel(L["If"])
        -- condition1:SetList({
        --     ALL = L["All of"],
        --     ANY = L["Any of"],
        -- }, {"ALL", "ANY"})
        -- tabContent:AddChild(condition1)
        -- condition1:SetCallback("OnValueChanged", function(_, _, selected)
        --     print(objectiveInfo.trackFunc)
        -- end)

        -- for k, v in addon.pairs(objectiveInfo.trackers) do
        --     condition1:AddItem(k.."spacer", "")
        --     condition1:SetItemDisabled(k.."spacer", true)
        --     if v.trackerType == "ITEM" then
        --         self:CacheItem(v.trackerID, function(k, itemID)
        --             condition1:AddItem(k, (GetItemInfo(itemID)))
        --             condition1:SetItemDisabled(k, true)
        --         end, k, v.trackerID)
        --     elseif v.trackerType == "CURRENCY" then
        --         condition1:AddItem(k, (GetCurrencyInfo(v.trackerID)))
        --         condition1:SetItemDisabled(k, true)
        --     end
        --     condition1:AddItem(k.."complete", "Complete")
        --     condition1:AddItem(k.."count", "Count")
        -- end
    end
end

------------------------------------------------------------

------------------------------------------------------------

function addon:LoadTrackersTab(objectiveTitle)
    local ObjectiveBuilder = addon.ObjectiveBuilder
    local mainContent = ObjectiveBuilder.mainContent

    if not objectiveTitle then return end
    local objectiveInfo = self:GetObjectiveInfo(objectiveTitle)

    ------------------------------------------------------------

    local trackerListContainer = AceGUI:Create("SimpleGroup")
    trackerListContainer:SetRelativeWidth(1/3)
    trackerListContainer:SetFullHeight(true)
    trackerListContainer:SetLayout("Fill")
    mainContent:AddChild(trackerListContainer)

    ------------------------------------------------------------

    local trackerList = AceGUI:Create("ScrollFrame")
    trackerList:SetLayout("List")
    trackerListContainer:AddChild(trackerList)
    ObjectiveBuilder.trackerList = trackerList
    trackerList.status = {children = {}, selected = {}}

    for tracker, trackerInfo in pairs(objectiveInfo.trackers) do
        local button = AceGUI:Create("FB30_ObjectiveButton")
        button:SetFullWidth(true)
        -- !Try to remove this if I can set up a coroutine to handle item caching.
        self:GetObjectiveDataTable(trackerInfo.trackerType, trackerInfo.trackerID, function(data)
            button:SetText(data.name)
            button:SetIcon(data.icon)
        end)
        -- !
        button:SetStatus(trackerList.status)
        button:SetMenuFunc(GetTrackerContextMenu)
        trackerList:AddChild(button)
        tinsert(trackerList.status.children, {objectiveTitle = objectiveTitle, button = button})

        ------------------------------------------------------------

        -- TODO: trackerList button scripts
        -- button:SetCallback("OnClick", function(self, event, ...) ObjectiveButton_OnClick(objectiveTitle) end)
        -- button:SetCallback("OnDragStart", function(self, event, ...) self.DragFrame:Load(objectiveTitle) end)
        -- button:SetCallback("OnDragStop", function(self, event, ...) self.DragFrame:Clear() end)
    end

    ------------------------------------------------------------

    local trackerInfoContainer = AceGUI:Create("SimpleGroup")
    trackerInfoContainer:SetRelativeWidth(2/3)
    trackerInfoContainer:SetFullHeight(true)
    trackerInfoContainer:SetLayout("Fill")
    mainContent:AddChild(trackerInfoContainer)

    ------------------------------------------------------------

    local trackerInfo = AceGUI:Create("ScrollFrame")
    trackerInfo:SetLayout("Flow")
    trackerInfoContainer:AddChild(trackerInfo)
    trackerList.trackerInfo = trackerInfo

    ------------------------------------------------------------
    --Debug-----------------------------------------------------
    ------------------------------------------------------------
    for i = 1, 60 do
        local label = AceGUI:Create("Label")
        label:SetFullWidth(true)
        label:SetText("Test blah blah blah lorem blah blah lkjasdf oij asdfljoi jslfj salf  "..i)
        trackerInfo:AddChild(label)
    end
    ------------------------------------------------------------
    ------------------------------------------------------------
end