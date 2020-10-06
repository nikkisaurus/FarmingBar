local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

local Type, Version = "FB30_Frame", 1
local AceGUI = LibStub("AceGUI-3.0", true)
if (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

local CreateFrame, UIParent, CreateFrame, UIParent

-------------
-- Scripts --
-------------

--------------------
-- Widget Methods --
--------------------
local methods = {
    OnAcquire = function(self)
        -- TODO: Set defaults
    end,
}

-----------------
-- Constructor --
-----------------

local function Constructor()
    local widget = {
        frame = frame,
        type = Type,
    }

    for method, func in pairs(methods) do
        widget[method] = func
    end

    return AceGUI:RegisterAsContainer(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)