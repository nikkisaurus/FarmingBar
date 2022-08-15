local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0")
local L = LibStub("AceLocale-3.0"):NewLocale(addonName, "enUS", true)
LibStub("LibAddonUtils-1.0"):Embed(addon)

L.addonName = "Farming Bar"

--[[ Errors ]]
L["Bar is already assigned an ID: %d"] = true
L["Button is already assigned an ID: %d:%d"] = true
L["barDB.hidden must return a \"function\""] = true

--[[ Tooltips ]]
L["Control+click to lock and hide anchor."] = true

--[[ Options ]]
L["Alt IDs"] = true
L["Quantity"] = true
L["Objective template must contain at least one tracker."] = true
L["Are you sure you want to delete %s from objective template \"%s\"?"] = true
L["Alt ID already exists for this tracker."] = true
L["Objective"] = true
L["Multiplier"] = true
L["Alerts"] = true
L["Bar"] = true
L["Bars"] = true
L["Item/Currency Name"] = true
L["Label"] = true
L["Bar Progress"] = true
L["Track the number of completed objectives on this bar."] = true
L["Completed Objectives"] = true
L["Continue tracking objectives after completed."] = true
L["Mute All"] = true
L["Mute all alerts on this bar."] = true
L["Limit Mats"] = true
L["Objectives on this bar cannot use materials already accounted for by another objective on the same bar."] = true
L["Alpha"] = true
L["Scale"] = true
L["Mouseover"] = true
L["Show this bar only on mouseover."] = true
L["Backdrop"] = true
L["Background"] = true
L["Enable"] = true
L["Border"] = true
L["Background Color"] = true
L["Border Color"] = true
L["Show Empty"] = true
L["Shows a backdrop on empty buttons."] = true
L["Hidden"] = true
L["Reset Hidden"] = true
L["Bar Anchor"] = true
L["Movable"] = true
L["Skins"] = true
L["Button Growth"] = true
L["Buttons"] = true
L["Buttons Per Axis"] = true
L["Button Padding"] = true
L["Button Size"] = true
L["Button Textures"] = true
L["Blend Mode"] = true
L["TexCoords"] = true
L["Texture"] = true
L["Color"] = true
L["Insets"] = true
L["Reset to Default"] = true
L["Draw Layer"] = true
L["Layer"] = true
L["Layout"] = true
L["Display"] = true
L["Are you sure you want to reset this texture?"] = true
L["Confirm"] = true
L["Are you sure you want to reset this bar's hidden function?"] = true
L["Button textures may be controlled by Masque and must be disabled through its settings for these to be applied."] =
    true
L["Hidden must be a function returning a boolean value."] = true
L["Objectives"] = true
L["Trackers"] = true
L["Objective Templates"] = true
L["Objective Title"] = true
L["Fallback Icon"] = true
L["Auto"] = true
L["Fallback"] = true
L["Icon Type"] = true
L["Item"] = true
L["Macrotext"] = true
L["None"] = true
L["Type"] = true
L["OnUse"] = true
L["ItemID"] = true
L["Invalid item/currency ID."] = true
L["Invalid itemID."] = true
L["Expand"] = true
L["Lua Editor"] = true
L["Objective template exists."] = true
L["General"] = true
L["Appearance"] = true
L["Manage"] = true
L["Trackers"] = true
L["Are you sure you want to delete the objective template \"%s\"?"] = true
L["Delete"] = true
L["Duplicate"] = true
L["Export"] = true
L["Export Frame"] = true
L["New"] = true
L["Import"] = true
L["Delete Objective Template"] = true
L["Import Frame"] = true
L["View Code"] = true
L["Imported Objective"] = true
L["Code Viewer"] = true
L["Custom Tracker Condition"] = true
L["Custom Condition"] = true
L["Condition"] = true
L["Button"] = true
L["All"] = true
L["Any"] = true
L["Custom"] = true
L["Currency"] = true
L["Currency/Item ID"] = true
L["Please select type: item or currency."] = true
L["Invalid input: duplicate entry."] = true
L["New Tracker"] = true
L["New Alt ID"] = true

L.CustomCodeWarning =
    "This objective may contain custom Lua code. Make sure you only import objectives from trusted sources."
L.GetTexCoordID = function(id)
    local ids = {
        [1] = "Left",
        [2] = "Right",
        [3] = "Top",
        [4] = "Bottom",
    }
    return ids[id]
end
