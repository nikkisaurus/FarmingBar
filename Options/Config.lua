local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

local Config = addon.Config

--*------------------------------------------------------------------------

local methods = {
    Load = function(self, barID)
        print(barID)
        Config.frame:Show()
    end,
}

--*------------------------------------------------------------------------

function addon:InitializeConfig()
    Config = AceGUI:Create("FarmingBar_Frame")
    Config:SetTitle("Farming Bar "..L["Config"])
    Config:SetLayout("FB30_TopSidebarGroup")
    Config:SetUserData("selectedTabs", {})
    Config:SetUserData("sidebarDenom", 4)
    addon.Config = Config

    for method, func in pairs(methods) do
        Config[method] = func
    end

    ------------------------------------------------------------

    local topPanel = AceGUI:Create("FarmingBar_InlineGroup")
    topPanel:SetLayout("Flow")
    Config:AddChild(topPanel)

    ------------------------------------------------------------

    local newBar = AceGUI:Create("FarmingBar_InteractiveLabel")
    newBar:SetText(L["Add Bar"])
    newBar:SetTextHighlight(1, .82, 0, 1)
    newBar:SetWordWrap(false)
    newBar:SetIcon(514607, nil, 13, 13)
    -- newBar:SetUserData("tooltip", "GetNewObjectiveButtonTooltip")
    topPanel:AddChild(newBar)

    newBar:SetCallback("OnClick", function() self:CreateBar() end)
    -- newBar:SetCallback("OnReceiveDrag", function() self:CreateObjectiveFromCursor() end)
    -- newBar:SetCallback("OnEnter", newObjective_OnEnter)
    -- newBar:SetCallback("OnLeave", Tooltip_OnLeave)

    -- ------------------------------------------------------------

    local sidebar = AceGUI:Create("FarmingBar_InlineGroup")
    sidebar:SetLayout("FB30_List")
    sidebar:SetUserData("childPadding", 10)
    Config:AddChild(sidebar)

    ------------------------------------------------------------

    local mainPanel = AceGUI:Create("FarmingBar_InlineGroup")
    mainPanel:SetLayout("Flow")
    Config:AddChild(mainPanel)
    -- Config:SetUserData("mainPanel", mainPanel)
end