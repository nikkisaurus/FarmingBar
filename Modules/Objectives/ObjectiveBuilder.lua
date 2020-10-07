local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

local AceGUI = LibStub("AceGUI-3.0", true)

local tinsert, pairs = table.insert, pairs
local strfind, strupper = string.find, string.upper

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

                button:SetCallback("OnClick", function(self, event, ...)
                    mainContent:ReleaseChildren()
                    mainContent:Load(title)
                end)
            end
        end
    end,
}

--*------------------------------------------------------------------------

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

    -- TODO: Implement an x button next to searchbox to clear the filter

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
    --Debug-----------------------------------------------------
    ------------------------------------------------------------
    if FarmingBar.db.global.debug.ObjectiveBuilder then
        C_Timer.After(1, function() ObjectiveBuilder:Load() end)

        local test = AceGUI:Create("Label")
        test:SetFullWidth(true)
        test:SetText("Top panel")
        topContent:AddChild(test)
    end
    ------------------------------------------------------------
    ------------------------------------------------------------
end