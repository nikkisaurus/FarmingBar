local addonName = ...
local addon = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

-- Optional libraries
local ACD = LibStub("AceConfigDialog-3.0")
local AceGUI = LibStub("AceGUI-3.0", true)
local LSM = LibStub("LibSharedMedia-3.0")

local Type = "FarmingBar_IconSelector"
local Version = 1

-- *------------------------------------------------------------------------
-- Widget methods

local methods = {
    OnAcquire = function(self)
    end,
    OnRelease = function(self)
    end
}

-- *------------------------------------------------------------------------
-- Constructor

local function Constructor()
    local frame = AceGUI:Create("Frame")

    if IsAddOnLoaded("ElvUI") then
        local E = unpack(_G["ElvUI"])
        local S = E:GetModule("Skins")
        S:HandleButton(expandButton)
    end

    local widget = frame

    for method, func in pairs(methods) do
        widget[method] = func
    end

    return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
