local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)
local AceGUI = LibStub("AceGUI-3.0", true)

local pairs = pairs
local gsub = string.gsub

--*------------------------------------------------------------------------

local function autoIcon_OnValueChanged(self)
    FarmingBar.db.global.objectives[addon.ObjectiveBuilder:GetSelectedObjective()].autoIcon = self:GetValue()

    addon.ObjectiveBuilder.mainContent:Refresh("Objective")
end

local function displayIcon_OnEnterPressed(self)
    FarmingBar.db.global.objectives[addon.ObjectiveBuilder:GetSelectedObjective()].icon = self:GetText()
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
    local objectiveTitle = addon.ObjectiveBuilder:GetSelectedObjective()
    local objectiveInfo = FarmingBar.db.global.objectives[objectiveTitle]
    local valid = addon:ValidateTracker(objectiveInfo.displayRef.trackerType, self:GetText())

    if valid or self:GetText() == "" then
        FarmingBar.db.global.objectives[objectiveTitle].displayRef.trackerID = objectiveInfo.displayRef.trackerType == "ITEM" and valid or tonumber(self:GetText())

        self:SetText(objectiveInfo.displayRef.trackerID)
        self:ClearFocus()

        addon.ObjectiveBuilder.mainContent:Refresh("Objective")
    else
        self:SetText("")
        self:SetFocus()
    end
end

local function displayRefTrackerType_OnValueChanged(selected)
    local objectiveTitle = addon.ObjectiveBuilder:GetSelectedObjective()
    if selected == "NONE" then
        FarmingBar.db.global.objectives[objectiveTitle].displayRef.trackerType = false
        FarmingBar.db.global.objectives[objectiveTitle].displayRef.trackerID = false

    else
        FarmingBar.db.global.objectives[objectiveTitle].displayRef.trackerType = selected
    end

    addon.ObjectiveBuilder.mainContent:Refresh("Objective")
end

local function mainTabGroup_OnGroupSelected(self, selected)
    self:ReleaseChildren()

    if selected == "objectiveTab" then
        addon:LoadObjectiveTab(addon.ObjectiveBuilder:GetSelectedObjective())
    elseif selected == "trackerTab" then
        addon:LoadTrackerTab(addon.ObjectiveBuilder:GetSelectedObjective())
    end
end

local function trackCondition_OnValueChanged(selected)
    FarmingBar.db.global.objectives[addon.ObjectiveBuilder:GetSelectedObjective()].trackCondition = selected

    addon.ObjectiveBuilder.mainContent:Refresh("Tracker")
end

local function trackFunc_OnEnterPressed(self)
    FarmingBar.db.global.objectives[addon.ObjectiveBuilder:GetSelectedObjective()].trackFunc = self:GetText()
end

--*------------------------------------------------------------------------

local methods = {
    ["Refresh"] = function(self, reloadTab)
        addon.ObjectiveBuilder:UpdateObjectiveIcon(addon.ObjectiveBuilder:GetSelectedObjective())
        if reloadTab then
            addon["Load"..reloadTab.."Tab"](addon, addon.ObjectiveBuilder:GetSelectedObjective())
        end
    end,

    ["SelectObjective"] = function(self, objectiveTitle)
        self.objectiveTitle = objectiveTitle
        local mainContainer = addon.ObjectiveBuilder.mainContainer.frame
        if objectiveTitle then
            mainContainer:Show()
        else
            mainContainer:Hide()
        end
        addon:LoadObjectiveTab(objectiveTitle)
    end,
}

--*------------------------------------------------------------------------

local function GetTrackerTypeLabel(trackerType)
    --@retail@
    return trackerType == "ITEM" and L["Item ID/Name/Link"] or L["Currency ID"]
    --@end-retail@
    --[===[@non-retail@
    return L["Item ID/Name/Link"]
    --@end-non-retail@]===]
end

--*------------------------------------------------------------------------

function addon:DrawTabs()
    local mainContainer = self.ObjectiveBuilder.mainContainer
    mainContainer:ReleaseChildren()

    local mainTabGroup = AceGUI:Create("TabGroup")
    mainTabGroup:SetLayout("Flow")
    mainTabGroup:SetTabs({{text = L["Objective"], value = "objectiveTab"}, {text = L["Tracker"], value = "trackerTab"}})
    mainTabGroup:SelectTab("objectiveTab")
    mainContainer:AddChild(mainTabGroup)
    self.ObjectiveBuilder.mainContent = mainTabGroup

    mainTabGroup:SetCallback("OnGroupSelected", function(self, _, selected) mainTabGroup_OnGroupSelected(self, selected) end)

    for method, func in pairs(methods) do
        mainTabGroup[method] = func
    end
end

--*------------------------------------------------------------------------

function addon:LoadObjectiveTab(objectiveTitle)
    local mainContent = self.ObjectiveBuilder.mainContent
    mainContent:ReleaseChildren()
    if not objectiveTitle then return end
    local objectiveInfo = FarmingBar.db.global.objectives[objectiveTitle]

    ------------------------------------------------------------

    local title = AceGUI:Create("Label")
    title:SetFullWidth(true)
    title:SetText(objectiveTitle)
    title:SetFontObject(GameFontNormalLarge)
    title:SetImageSize(20, 20)
    title:SetImage(self:GetIcon(objectiveTitle))
    mainContent:AddChild(title)

    ------------------------------------------------------------

    local spacer_enabled = AceGUI:Create("Label")
    spacer_enabled:SetFullWidth(true)
    spacer_enabled:SetText(" ")
    mainContent:AddChild(spacer_enabled)

    ------------------------------------------------------------

    local enabled = AceGUI:Create("CheckBox")
    enabled:SetFullWidth(true)
    enabled:SetValue(objectiveInfo.enabled)
    enabled:SetLabel(L["Enabled"])
    mainContent:AddChild(enabled)

    enabled:SetCallback("OnValueChanged", function(self) FarmingBar.db.global.objectives[objectiveTitle].enabled = self:GetValue() end)

    ------------------------------------------------------------

    local autoIcon = AceGUI:Create("CheckBox")
    autoIcon:SetFullWidth(true)
    autoIcon:SetValue(objectiveInfo.autoIcon)
    autoIcon:SetLabel(L["Automatic Icon"])
    mainContent:AddChild(autoIcon)

    autoIcon:SetCallback("OnValueChanged", function(self) autoIcon_OnValueChanged(self) end)

    ------------------------------------------------------------

    if not objectiveInfo.autoIcon then
        local displayIcon = AceGUI:Create("EditBox")
        displayIcon:SetRelativeWidth(1/2)
        displayIcon:SetText(FarmingBar.db.global.objectives[objectiveTitle].icon)
        mainContent:AddChild(displayIcon, mainContent.displayRef)

        displayIcon:SetCallback("OnEnterPressed", function(self) displayIcon_OnEnterPressed(self) end)

        ------------------------------------------------------------

        local chooseButton = AceGUI:Create("Button")
        chooseButton:SetRelativeWidth(1/2)
        chooseButton:SetText(L["Choose"])
        mainContent:AddChild(chooseButton, mainContent.displayRef)

        -- chooseButton:SetCallback("OnClick", function() self.IconSelector:Show() end) -- TODO: Icon selector frame
    end

    ------------------------------------------------------------

    local displayRef = AceGUI:Create("Heading")
    displayRef:SetFullWidth(true)
    displayRef:SetText(L["Display Reference"])
    mainContent:AddChild(displayRef)
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
    mainContent:AddChild(displayRefTrackerType)

    displayRefTrackerType:SetCallback("OnValueChanged", function(_, _, selected) displayRefTrackerType_OnValueChanged(selected) end)

    ------------------------------------------------------------

    local displayRefHelp = AceGUI:Create("FB30_InteractiveLabel")
    displayRefHelp:SetText(" ")
    displayRefHelp:SetImage(616343)
    displayRefHelp:SetImageSize(25, 25)
    displayRefHelp:SetWidth(30)
    mainContent:AddChild(displayRefHelp)

    displayRefHelp:SetCallback("OnClick", function(label) displayRefHelp_OnClick(mainContent, label) end)

    ------------------------------------------------------------

    if objectiveInfo.displayRef.trackerType then
        local displayRefTrackerID = AceGUI:Create("EditBox")
        displayRefTrackerID:SetFullWidth(true)
        displayRefTrackerID:SetLabel(GetTrackerTypeLabel(objectiveInfo.displayRef.trackerType))
        displayRefTrackerID:SetText(objectiveInfo.displayRef.trackerID or "")
        mainContent:AddChild(displayRefTrackerID)

        displayRefTrackerID:SetCallback("OnEnterPressed", function(self) displayRefTrackerID_OnEnterPressed(self) end)
    end
end

--*------------------------------------------------------------------------

function addon:LoadTrackerTab(objectiveTitle)
    local mainContent = self.ObjectiveBuilder.mainContent
    mainContent:ReleaseChildren()
    if not objectiveTitle then return end
    local objectiveInfo = FarmingBar.db.global.objectives[objectiveTitle]

    -- TODO: LoadTrackerTab()
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
    mainContent:AddChild(trackCondition)

    trackCondition:SetCallback("OnValueChanged", function(_, _, selected) trackCondition_OnValueChanged(selected) end)

    if objectiveInfo.trackCondition == "CUSTOM" then
        local trackFunc = AceGUI:Create("MultiLineEditBox")
        trackFunc:SetFullWidth(true)
        trackFunc:SetText(objectiveInfo.trackFunc)
        mainContent:AddChild(trackFunc)

        trackFunc:SetCallback("OnEnterPressed", function(self, event, ...) trackFunc_OnEnterPressed(self) end)
    end
end



