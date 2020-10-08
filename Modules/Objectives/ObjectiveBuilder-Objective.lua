local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)
local AceGUI = LibStub("AceGUI-3.0", true)

local pairs = pairs
local gsub = string.gsub

--*------------------------------------------------------------------------

local function autoIcon_OnValueChanged(self, objectiveTitle)
    FarmingBar.db.global.objectives[objectiveTitle].autoIcon = self:GetValue()

    addon.ObjectiveBuilder.mainContent:Refresh("Objective")
end

local function displayIcon_OnEnterPressed(self, objectiveTitle)
    FarmingBar.db.global.objectives[objectiveTitle].icon = self:GetText()
    self:ClearFocus()

    addon.ObjectiveBuilder.mainContent:Refresh("Objective")
end

local function displayRefHelp_OnClick(self, label)
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

    self:DoLayout()
end

local function displayRefTrackerID_OnEnterPressed(self, objectiveTitle)
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

local function displayRefTrackerType_OnValueChanged(objectiveTitle, selected)
    if selected == "NONE" then
        FarmingBar.db.global.objectives[objectiveTitle].displayRef.trackerType = false
        FarmingBar.db.global.objectives[objectiveTitle].displayRef.trackerID = false
    else
        FarmingBar.db.global.objectives[objectiveTitle].displayRef.trackerType = selected
    end

    addon.ObjectiveBuilder.mainContent:Refresh("Objective")
end

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
    title:SetImage(addon:GetIcon(objectiveTitle))
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

    autoIcon:SetCallback("OnValueChanged", function(self) autoIcon_OnValueChanged(self, objectiveTitle) end)

    ------------------------------------------------------------

    if not objectiveInfo.autoIcon then
        local displayIcon = AceGUI:Create("EditBox")
        displayIcon:SetRelativeWidth(1/2)
        displayIcon:SetText(FarmingBar.db.global.objectives[objectiveTitle].icon)
        mainContent:AddChild(displayIcon, mainContent.displayRef)

        displayIcon:SetCallback("OnEnterPressed", function(self) displayIcon_OnEnterPressed(self, objectiveTitle) end)

        ------------------------------------------------------------

        local chooseButton = AceGUI:Create("Button")
        chooseButton:SetRelativeWidth(1/2)
        chooseButton:SetText(L["Choose"])
        mainContent:AddChild(chooseButton, mainContent.displayRef)

        -- chooseButton:SetCallback("OnClick", function() addon.IconSelector:Show() end) -- TODO: Icon selector frame
    end

    ------------------------------------------------------------

    local displayRef = AceGUI:Create("Heading")
    displayRef:SetFullWidth(true)
    displayRef:SetText(L["Display Reference"])
    mainContent:AddChild(displayRef)

    ------------------------------------------------------------

    local displayRefHelp = AceGUI:Create("FB30_InteractiveLabel")
    displayRefHelp:SetText(" ")
    displayRefHelp:SetImage(616343)
    displayRefHelp:SetImageSize(25, 25)
    displayRefHelp:SetWidth(30)
    mainContent:AddChild(displayRefHelp)

    displayRefHelp:SetCallback("OnClick", function(label) displayRefHelp_OnClick(mainContent, label) end)

    ------------------------------------------------------------

    local displayRefTrackerType = AceGUI:Create("Dropdown")
    displayRefTrackerType:SetFullWidth(true)
    displayRefTrackerType:SetLabel(L["Type"])
    displayRefTrackerType:SetList(
        {
            ITEM = L["Item"],
            CURRENCY = L["Currency"],
            NONE = L["None"],
        },
        {"CURRENCY", "ITEM", "NONE"}
    )
    displayRefTrackerType:SetValue(objectiveInfo.displayRef.trackerType or "NONE")
    mainContent:AddChild(displayRefTrackerType)

    displayRefTrackerType:SetCallback("OnValueChanged", function(_, _, selected) displayRefTrackerType_OnValueChanged(objectiveTitle, selected) end)

    ------------------------------------------------------------

    if objectiveInfo.displayRef.trackerType then
        local displayRefTrackerID = AceGUI:Create("EditBox")
        displayRefTrackerID:SetFullWidth(true)
        displayRefTrackerID:SetLabel(GetTrackerTypeLabel(objectiveInfo.displayRef.trackerType))
        displayRefTrackerID:SetText(objectiveInfo.displayRef.trackerID or "")
        mainContent:AddChild(displayRefTrackerID)

        displayRefTrackerID:SetCallback("OnEnterPressed", function(self) displayRefTrackerID_OnEnterPressed(self, objectiveTitle) end)
    end
end

--*------------------------------------------------------------------------

function addon:LoadTrackerTab(objectiveTitle)
    local mainContent = self.ObjectiveBuilder.mainContent
    mainContent:ReleaseChildren()
    if not objectiveTitle then return end
    local objectiveInfo = FarmingBar.db.global.objectives[objectiveTitle]

    -- TODO: LoadTrackerTab()
end



