local addonName = ...
local L = LibStub("AceLocale-3.0"):NewLocale("FarmingBar", "enUS", true)

-- Shared

-- Modules\Objectives\ObjectiveBuilder.lua
L["Close"] = true
L["Delete"] = true
L["Duplicate"] = true
L["Import Objective"] = true
L["New Objective"] = true
L["Objective"] = true
L["Objective Builder"] = true
L["Rename"] = true
L["Tracker"] = true

-- Modules\Objectives\ObjectiveBuilder-Objective.lua
L["Automatic Icon"] = true
L["Choose"] = true
L["Currency"] = true
L["Currency ID"] = true
L["Display Reference"] = true
L["Enabled"] = true
L["Item"] = true
L["Item ID/Name/Link"] = true
L["None"] = true
L["Type"] = true

L.DisplayReferenceDescription_Gsub = "/currency"
L.DisplayReferenceDescription = [[Display References allow you to set which item/currency you want to use for automatic objective information. This includes the icon chosen when using "Automatic Icon" and the item associated with a button's "use" attribute.]]
