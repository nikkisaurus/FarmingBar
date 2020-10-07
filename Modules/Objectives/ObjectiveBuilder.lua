local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

local AceGUI = LibStub("AceGUI-3.0", true)

local tinsert, pairs = table.insert, pairs
local strfind, strupper = string.find, string.upper
local CreateFrame, UIParent = CreateFrame, UIParent

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

        for title, objective in addon.pairs(FarmingBar.db.global.objectives) do
            if not self.objectiveSearchBox:GetText() or strfind(strupper(title), strupper(self.objectiveSearchBox:GetText())) then
                local button = AceGUI:Create("FB30_ObjectiveButton")
                button:SetFullWidth(true)
                button:SetText(title)
                button:SetIcon(objective.icon)
                button:SetStatusTable(self.objectives)
                sideContent:AddChild(button)

                ------------------------------------------------------------

                button:SetCallback("OnClick", function(self, event, ...)
                    mainContent:ReleaseChildren()
                    mainContent
                    :Load(title)
                end)

                button:SetCallback("OnDragStart", function(self, event, ...)
                    addon.DragFrame:Load(title, objective.icon)
                end)

                button:SetCallback("OnDragStop", function(self, event, ...)
                    addon.DragFrame:Clear()
                end)
            end
        end
    end,
}

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

    function DragFrame:Load(objectiveTitle, icon)
        DragFrame.selected = objectiveTitle
        DragFrame.icon:SetTexture(icon)
        DragFrame.text:SetText(objectiveTitle)
        DragFrame:Show()
    end
end

local function LoadMainContent(self, objectiveTitle)
    ------------------------------------------------------------
    --Debug-----------------------------------------------------
    ------------------------------------------------------------
    if FarmingBar.db.global.debug.ObjectiveBuilder then
        local test = AceGUI:Create("Label")
        test:SetFullWidth(true)
        test:SetText("Test main panel "..objectiveTitle)
        self:AddChild(test)
    end
    ------------------------------------------------------------
    ------------------------------------------------------------
end


--*------------------------------------------------------------------------

function addon:Initialize_ObjectiveBuilder()
    local ObjectiveBuilder = AceGUI:Create("FB30_Window")
    ObjectiveBuilder:SetTitle("Farming Bar "..L["Objective Builder"])
    ObjectiveBuilder:SetSize(700, 500)
    ObjectiveBuilder:SetLayout("FB30_2RowSplitBottom")
    ObjectiveBuilder:Hide()
    self.ObjectiveBuilder = ObjectiveBuilder
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
    mainContent:SetLayout("Flow")
    mainPanel:AddChild(mainContent)
    ObjectiveBuilder.mainContent = mainContent

    mainContent["Load"] = LoadMainContent

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