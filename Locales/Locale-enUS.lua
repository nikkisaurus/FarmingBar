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
L["Alerts"] = true
L["Bar"] = true
L["Bars"] = true
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

L.GetTexCoordID = function(id)
    local ids = {
        [1] = "Left",
        [2] = "Right",
        [3] = "Top",
        [4] = "Bottom",
    }
    return ids[id]
end
