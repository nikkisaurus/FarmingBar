local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

local AceGUI = LibStub("AceGUI-3.0", true)

local tinsert, pairs = table.insert, pairs

--*------------------------------------------------------------------------

local ObjectiveBuilderMethods = {
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
    ObjectiveBuilder:SetLayout("Flow")
    ObjectiveBuilder:Hide()

    for method, func in pairs(ObjectiveBuilderMethods) do
        ObjectiveBuilder[method] = func
    end

    self.ObjectiveBuilder = ObjectiveBuilder

    --Debug---------------------------------------------
    if FarmingBar.db.global.debug.ObjectiveBuilder then
        C_Timer.After(1, function() ObjectiveBuilder:Load() end)
    end
    ----------------------------------------------------
end