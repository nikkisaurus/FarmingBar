local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

local AceGUI = LibStub("AceGUI-3.0", true)

local tinsert, pairs, wipe = table.insert, pairs, table.wipe
local strfind, strupper = string.find, string.upper
local CreateFrame, UIParent = CreateFrame, UIParent

--*------------------------------------------------------------------------

local function Initialize_DragFrame()
    local DragFrame = CreateFrame("Frame", "FarmingBarDragFrame", UIParent)
    DragFrame:SetSize(25, 25)
    DragFrame:SetPoint("CENTER")
    DragFrame:Hide()
    addon.DragFrame = DragFrame

    DragFrame:SetScript("OnUpdate", function(self, ...)
        if DragFrame:IsVisible() then
            local scale, x, y = self:GetEffectiveScale(), GetCursorPosition()
            self:SetPoint("CENTER", nil, "BOTTOMLEFT", (x / scale) + 50, (y / scale) - 20)
        end
    end)

    ------------------------------------------------------------

    DragFrame.icon = DragFrame:CreateTexture(nil, "OVERLAY")
    DragFrame.icon:SetAllPoints(DragFrame)
    DragFrame.icon:SetTexture("")

    DragFrame.text = DragFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    DragFrame.text:SetPoint("LEFT", DragFrame.icon, "RIGHT", 3, 0)

    ------------------------------------------------------------

    function DragFrame:Clear()
        DragFrame.selected = nil
        DragFrame.icon:SetTexture("")
        DragFrame.text:SetText("")
        DragFrame:Hide()
    end

    function DragFrame:Load(objectiveTitle)
        DragFrame.selected = objectiveTitle
        DragFrame.icon:SetTexture(addon:GetIcon(objectiveTitle))
        DragFrame.text:SetText(objectiveTitle)
        DragFrame:Show()
    end
end

local function LoadObjectiveTab(self, objectiveTitle)
    self:ReleaseChildren()
    if not objectiveTitle then return end
    local objectiveInfo = FarmingBar.db.global.objectives[objectiveTitle]

    ------------------------------------------------------------

    local enabled = AceGUI:Create("CheckBox")
    enabled:SetFullWidth(true)
    enabled:SetValue(objectiveInfo.enabled)
    enabled:SetLabel(L["Enabled"])
    self:AddChild(enabled)

    enabled:SetCallback("OnValueChanged", function(editbox, event, ...)
        FarmingBar.db.global.objectives[objectiveTitle].enabled = editbox:GetValue()
    end)

    ------------------------------------------------------------

    local autoIcon = AceGUI:Create("CheckBox")
    autoIcon:SetFullWidth(true)
    autoIcon:SetValue(objectiveInfo.autoIcon)
    autoIcon:SetLabel(L["Automatic Icon"])
    self:AddChild(autoIcon)

    autoIcon:SetCallback("OnValueChanged", function(editbox, event, ...)
        FarmingBar.db.global.objectives[objectiveTitle].autoIcon = editbox:GetValue()

        addon.ObjectiveBuilder.buttons[objectiveTitle]:SetIcon(addon:GetIcon(objectiveTitle))
        LoadObjectiveTab(self, objectiveTitle)
    end)

    ------------------------------------------------------------

    if not objectiveInfo.autoIcon then
        local displayIcon = AceGUI:Create("EditBox")
        displayIcon:SetRelativeWidth(1/2)
        displayIcon:SetText(objectiveInfo.icon)
        self:AddChild(displayIcon)

        displayIcon:SetCallback("OnEnterPressed", function(self, event, ...)
            FarmingBar.db.global.objectives[objectiveTitle].icon = self:GetText()
            self:ClearFocus()

            addon.ObjectiveBuilder.buttons[objectiveTitle]:SetIcon(addon:GetIcon(objectiveTitle))
        end)

        ------------------------------------------------------------

        local chooseButton = AceGUI:Create("Button")
        chooseButton:SetRelativeWidth(1/2)
        chooseButton:SetText(L["Choose"])
        self:AddChild(chooseButton)

        chooseButton:SetCallback("OnClick", function(self, event, ...)
            -- TODO: Icon selector frame
            print("Open icon selector!")
        end)
    end

    ------------------------------------------------------------

    local displayRefHeader = AceGUI:Create("Heading")
    displayRefHeader:SetFullWidth(true)
    displayRefHeader:SetText(L["Display Reference"])
    self:AddChild(displayRefHeader)

    ------------------------------------------------------------

    local displayRefDropDown = AceGUI:Create("Dropdown")
    displayRefDropDown:SetFullWidth(true)
    displayRefDropDown:SetList({ITEM = L["Item"], CURRENCY = L["Currency"], NONE = L["None"]}, {"CURRENCY", "ITEM", "NONE"})
    displayRefDropDown:SetValue(objectiveInfo.displayRef.trackerType)
    displayRefDropDown:SetLabel(L["Type"])
    self:AddChild(displayRefDropDown)

    displayRefDropDown:SetCallback("OnValueChanged", function(_, event, selected)
        if selected == "NONE" then
            FarmingBar.db.global.objectives[objectiveTitle].displayRef.trackerType = false
            FarmingBar.db.global.objectives[objectiveTitle].displayRef.trackerID = false
        else
            FarmingBar.db.global.objectives[objectiveTitle].displayRef.trackerType = selected
        end
        addon.ObjectiveBuilder.buttons[objectiveTitle]:SetIcon(addon:GetIcon(objectiveTitle))
        LoadObjectiveTab(self, objectiveTitle)
    end)

    ------------------------------------------------------------

    if objectiveInfo.displayRef.trackerType then
        local refEditBox = AceGUI:Create("EditBox")
        --@retail@
        refEditBox:SetLabel((objectiveInfo.displayRef.trackerType == "ITEM" and L["Item ID/Name/Link"] or L["Currency ID"]))
        --@end-retail@
        --[===[@non-retail@
        refEditBox:SetLabel(L["Item ID/Name/Link"])
        --@end-non-retail@]===]
        refEditBox:SetFullWidth(true)
        refEditBox:SetText(objectiveInfo.displayRef.trackerID or "")
        self:AddChild(refEditBox)

        refEditBox:SetCallback("OnEnterPressed", function(self, event, ...)
            local valid = addon:ValidateTracker(objectiveInfo.displayRef.trackerType, self:GetText())
            if valid or self:GetText() == "" then
                FarmingBar.db.global.objectives[objectiveTitle].displayRef.trackerID = objectiveInfo.displayRef.trackerType == "ITEM" and valid or tonumber(self:GetText())

                addon.ObjectiveBuilder.buttons[objectiveTitle]:SetIcon(addon:GetIcon(objectiveTitle))
                self:SetText(objectiveInfo.displayRef.trackerID)
                self:ClearFocus()
            else
                self:SetText("")
                self:SetFocus()
            end
        end)
    end

    ------------------------------------------------------------

    local displayRefHelp = AceGUI:Create("FB30_InteractiveLabel")
    displayRefHelp:SetText(" ")
    displayRefHelp:SetImage(616343)
    displayRefHelp:SetImageSize(25, 25)
    displayRefHelp:SetFullWidth(true)
    self:AddChild(displayRefHelp)

    displayRefHelp:SetCallback("OnClick", function(self, event, ...)
        if self:GetText() and self:GetText() ~= " " then
            self:SetText("")
        else
            self:SetText("Display References allow you to set an item or currency as the Automatic Icon and button On Use target without having the item as a tracker. For example, if you want to track the mats for a recipe but you want the to be able to right-click an objective button to use the recipe, you would set it up here.")
        end
    end)

end

local function LoadTrackerTab(self, objectiveTitle)
    self:ReleaseChildren()
    if not objectiveTitle then return end
    local objectiveInfo = FarmingBar.db.global.objectives[objectiveTitle]
end

--*------------------------------------------------------------------------

local ObjectiveBuilderMethods = {
    Load = function(self)
        self:Show()
        self:LoadObjectives()
    end,

    Release = function(self)
        AceGUI:Release(self)
    end,

    LoadObjectives = function(self)
        local topContent, sideContent, mainContent = self.topContent, self.sideContent, self.mainContent
        sideContent:ReleaseChildren()
        wipe(self.buttons)

        for title, objective in addon.pairs(FarmingBar.db.global.objectives) do
            if not self.objectiveSearchBox:GetText() or strfind(strupper(title), strupper(self.objectiveSearchBox:GetText())) then
                local button = AceGUI:Create("FB30_ObjectiveButton")
                button:SetFullWidth(true)
                button:SetText(title)
                button:SetIcon(addon:GetIcon(title))
                button:SetStatusTable(self.objectives)
                sideContent:AddChild(button)
                self.buttons[title] = button

                ------------------------------------------------------------

                button:SetCallback("OnClick", function(self, event, ...)
                    mainContent:ReleaseChildren()
                    mainContent:LoadObjectiveTab(title)
                end)

                button:SetCallback("OnDragStart", function(self, event, ...)
                    addon.DragFrame:Load(title)
                end)

                button:SetCallback("OnDragStop", function(self, event, ...)
                    addon.DragFrame:Clear()
                end)
            end
        end
    end,
}


--*------------------------------------------------------------------------

function addon:Initialize_ObjectiveBuilder()
    local ObjectiveBuilder = AceGUI:Create("FB30_Window")
    ObjectiveBuilder:SetTitle("Farming Bar "..L["Objective Builder"])
    ObjectiveBuilder:SetSize(700, 500)
    ObjectiveBuilder:SetLayout("FB30_2RowSplitBottom")
    ObjectiveBuilder:Hide()
    self.ObjectiveBuilder = ObjectiveBuilder
    ObjectiveBuilder.buttons = {}
    ObjectiveBuilder.objectives = {}

    for method, func in pairs(ObjectiveBuilderMethods) do
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

    newObjectiveButton:SetCallback("OnClick", function(self, event, ...)
        -- TODO: implement add objective
    end)

    ------------------------------------------------------------

    local importObjectiveButton = AceGUI:Create("FB30_InteractiveLabel")
    importObjectiveButton:SetText(L["Import Objective"])
    importObjectiveButton:SetWidth(importObjectiveButton.label:GetStringWidth() + importObjectiveButton.image:GetWidth())
    importObjectiveButton:SetImageSize(importObjectiveButton.label:GetHeight(), importObjectiveButton.label:GetHeight())
    importObjectiveButton:SetImage(131906, 1, 0, 0, 1)
    importObjectiveButton:SetDisabled(true)
    topContent:AddChild(importObjectiveButton)

    importObjectiveButton:SetCallback("OnClick", function(self, event, ...)
        -- TODO: implement import/export
    end)

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

    objectiveSearchBox:SetCallback("OnTextChanged", function(self, event, ...)
        ObjectiveBuilder:LoadObjectives(self:GetText())
    end)

    objectiveSearchBox:SetCallback("OnEnterPressed", function(self, event, ...)
        self:ClearFocus()
    end)

    ------------------------------------------------------------

    local sideContainer = AceGUI:Create("SimpleGroup")
    sideContainer:SetLayout("Fill")
    sidePanel:AddChild(sideContainer)

    local sideContent = AceGUI:Create("ScrollFrame")
    sideContent:SetLayout("List")
    sideContainer:AddChild(sideContent)
    ObjectiveBuilder.sideContent = sideContent

    ------------------------------------------------------------

    local mainPanel = AceGUI:Create("SimpleGroup")
    mainPanel:SetRelativeWidth(3/4)
    mainPanel:SetFullHeight(true)
    mainPanel:SetLayout("Fill")
    ObjectiveBuilder:AddChild(mainPanel)

    local mainContent = AceGUI:Create("ScrollFrame")
    mainContent:SetLayout("Fill")
    mainPanel:AddChild(mainContent)

    local mainTabGroup = AceGUI:Create("TabGroup")
    mainTabGroup:SetLayout("Flow")
    mainTabGroup:SetTabs({{text = L["Objective"], value = "objectiveTab"}, {text = L["Tracker"], value = "trackerTab"}})
    mainTabGroup:SelectTab("objectiveTab")
    mainContent:AddChild(mainTabGroup)

    mainTabGroup:SetCallback("OnGroupSelected", function(self, event, selected)
        self:ReleaseChildren()

        if group == "objectiveTab" then
            self:LoadObjectiveTab()
        elseif group == "trackerTab" then
            self:LoadTrackerTab()
        end
    end)

    ObjectiveBuilder.mainContent = mainTabGroup

    mainTabGroup["LoadObjectiveTab"] = LoadObjectiveTab
    mainTabGroup["LoadTrackerTab"] = LoadTrackerTab

    ------------------------------------------------------------

    Initialize_DragFrame()

    ------------------------------------------------------------
    --Debug-----------------------------------------------------
    ------------------------------------------------------------
    if FarmingBar.db.global.debug.ObjectiveBuilder then
        C_Timer.After(1, function() ObjectiveBuilder:Load() end)
    end
    ------------------------------------------------------------
    ------------------------------------------------------------
end