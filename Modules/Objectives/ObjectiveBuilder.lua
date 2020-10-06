local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

local AceGUI = LibStub("AceGUI-3.0", true)

local tinsert, pairs = table.insert, pairs

--*------------------------------------------------------------------------

local methods = {
    Load = function(self)
        self:Show()
    end,

    Release = function(self)
        AceGUI:Release(self)
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

    local sidePanel = AceGUI:Create("SimpleGroup")
    sidePanel:SetRelativeWidth(1/4)
    sidePanel:SetFullHeight(true)
    sidePanel:SetLayout("FB30_2RowFill")
    ObjectiveBuilder:AddChild(sidePanel)

    local objectiveSearchBox = AceGUI:Create("EditBox")
    objectiveSearchBox:SetFullWidth(true)
    sidePanel:AddChild(objectiveSearchBox)

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

    ------------------------------------------------------------
    --Debug-----------------------------------------------------
    ------------------------------------------------------------
    if FarmingBar.db.global.debug.ObjectiveBuilder then
        C_Timer.After(1, function() ObjectiveBuilder:Load() end)

        local test = AceGUI:Create("Label")
        test:SetFullWidth(true)
        test:SetText("Top panel")
        topContent:AddChild(test)

        for i = 1, 50 do
            test = AceGUI:Create("Label")
            test:SetFullWidth(true)
            test:SetText("Test side panel ", i)
            sideContent:AddChild(test)

            test = AceGUI:Create("Label")
            test:SetFullWidth(true)
            test:SetText("Test main panel ", i)
            mainContent:AddChild(test)
        end
    end
    ------------------------------------------------------------
    ------------------------------------------------------------
end