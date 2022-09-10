local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0")
local L = LibStub("AceLocale-3.0"):NewLocale(addonName, "enUS", true)
LibStub("LibAddonUtils-1.0"):Embed(addon)

L.addonName = "Farming Bar"

private.status = {
    options = {
        objectiveTemplates = {
            newTrackerType = "ITEM",
            newAltIDType = "ITEM",
        },
        bar = {},
    },
    objectiveEditor = {
        newTrackerType = "ITEM",
        newAltIDType = "ITEM",
    },
}

L[" for help."] = true
L[" to configure bars."] = true
L[" to configure settings."] = true
L[" to configure this bar."] = true
L[" to enable/disable the active profile."] = true
L[" to lock and hide anchor."] = true
L["%d more..."] = true
L["%s Text"] = true
L["* The following settings are profile specific."] = true
L["Add Tracker"] = true
L["Add"] = true
L["Alert formats must be a function returning a string value."] = true
L["Alerts"] = true
L["All Bars"] = true
L["Alpha"] = true
L["AlphaKey"] = true
L["Alt ID already exists for this tracker."] = true
L["Alt ID"] = true
L["Alt IDs"] = true
L["Alt"] = true
L["Alts"] = true
L["Anchor"] = true
L["Any"] = true
L["Appearance"] = true
L["Apply Objective Template"] = true
L["Are you sure you want to clear Bar %d?"] = true
L["Are you sure you want to clear this button?"] = true
L["Are you sure you want to delete the objective template \"%s\"?"] = true
L["Are you sure you want to overwrite \"%s\" with \"%s\"?"] = true
L["Are you sure you want to overwrite Bar %d Button %d with objective template \"%s\"?"] = true
L["Are you sure you want to remove %s from %s?"] = true
L["Are you sure you want to remove %s from the tracker \"%s\"?"] = true
L["Are you sure you want to remove Bar %d?"] = true
L["Are you sure you want to remove skin \"%s\"?"] = true
L["Are you sure you want to reset bar alerts format?"] = true
L["Are you sure you want to reset button alerts format?"] = true
L["Are you sure you want to reset this bar's hidden function?"] = true
L["Are you sure you want to reset tracker alerts format?"] = true
L["Auction Close"] = true
L["Auction Open"] = true
L["Auto"] = true
L["Backdrop"] = true
L["Background Color"] = true
L["Background"] = true
L["Bank"] = true
L["Bar Anchor"] = true
L["Bar Backdrop"] = true
L["Bar Complete"] = true
L["Bar is already assigned an ID: %d"] = true
L["Bar Progress"] = true
L["Bar Tooltips"] = true
L["Bar"] = true
L["barDB.hidden must return a \"function\""] = true
L["Blend Mode"] = true
L["BLEND"] = true
L["Blend"] = true
L["Border"] = true
L["Button Growth"] = true
L["Button is already assigned an ID: %d:%d"] = true
L["Button Padding"] = true
L["Button Size"] = true
L["Button textures may be controlled by Masque and must be disabled through its settings for skins to be applied."] =
    true
L["Button Textures"] = true
L["Button Tooltips"] = true
L["Button"] = true
L["Buttons Per Axis"] = true
L["Buttons"] = true
L["Chat frame for chat alerts from this bar."] = true
L["Chat Frame"] = true
L["Chat"] = true
L["Choose"] = true
L["Clear Bar"] = true
L["Clear"] = true
L["clearObjective"] = "Clear Objective"
L["Code Viewer"] = true
L["Color"] = true
L["Completed Objectives"] = true
L["Condition"] = true
L["Config"] = true
L["Configure bar settings."] = true
L["Confirm"] = true
L["Continue tracking objectives after completion."] = true
L["Control"] = true
L["Copy From"] = true
L["Count"] = true
L["Currency"] = true
L["Custom Condition"] = true
L["Custom Condition: Invalid function"] = true
L["Custom Condition: Syntax error"] = true
L["Custom Tracker Condition"] = true
L["Custom"] = true
L["Default chat frame for chat alerts. * Profile"] = true
L["Disable active profile."] = true
L["Disable all tooltips."] = true
L["Disable"] = true
L["dragObjective"] = "Drag Objective"
L["Draw Layer"] = true
L["Duplicate"] = true
L["Enable active profile."] = true
L["Enable all tooltips."] = true
L["Enable"] = true
L["Event \"%s\" doesn't exist."] = true
L["Events"] = true
L["Expand Tooltip"] = true
L["Expand"] = true
L["Export Frame"] = true
L["Export"] = true
L["Fallback Icon"] = true
L["Fallback"] = true
L["Farming Progress"] = true
L["First"] = true
L["Font Face"] = true
L["Font Outline"] = true
L["Font Size"] = true
L["Fonts"] = true
L["Format"] = true
L["General"] = true
L["Gloss"] = true
L["Guild Bank"] = true
L["Help"] = true
L["Hidden must be a function returning a boolean value."] = true
L["Hidden"] = true
L["Highlight"] = true
L["Hints"] = true
L["Hold this key down while hovering over a button to view additional tooltip details."] = true
L["Icon Border Thick"] = true
L["Icon Border"] = true
L["Icon ID"] = true
L["Icon Selector"] = true
L["Icon"] = true
L["Import Frame"] = true
L["Import"] = true
L["Include Alts"] = true
L["Include Bank"] = true
L["Include Guild Bank"] = true
L["Include"] = true
L["Insets"] = true
L["Invalid alpha value. Please provide an integer between 0 and 1."] = true
L["Invalid anchor: bottomleft | bottomright | topleft | topright"] = true
L["Invalid barID. To apply to all bars, use barID 0."] = true
L["Invalid currency ID."] = true
L["Invalid growth: col | row"] = true
L["Invalid item ID."] = true
L["Invalid scale value. Please provide an integer between %s and %s."] = true
L["Invalid template name."] = true
L["Invalid Tracker/Alt ID"] = true
L["Invalid tradeskill name."] = true
L["Item"] = true
L["ItemID"] = true
L["Keybinds"] = true
L["Label"] = true
L["Last"] = true
L["Layer"] = true
L["Layout"] = true
L["Left Button"] = true
L["Limit Mats"] = true
L["Lock or unlock bar."] = true
L["Loot Coin"] = true
L["Lua Editor"] = true
L["Macrotext"] = true
L["Manage"] = true
L["Mod"] = true
L["Modifier"] = true
L["Monochrome"] = true
L["Mouse Button"] = true
L["Mouseover"] = true
L["Movable"] = true
L["moveAllToBank"] = "Move All to Bank"
L["moveObjective"] = "Move Objective"
L["moveObjectiveToBank"] = "Move Objective to Bank"
L["Multiplier"] = true
L["Mute alerts for this button."] = true
L["Mute alerts for this objective."] = true
L["Mute all alerts on this bar."] = true
L["Mute All"] = true
L["Mute"] = true
L["Name"] = true
L["New Skin"] = true
L["New"] = true
L["None"] = true
L["Normal"] = true
L["Objective Cleared"] = true
L["Objective Complete"] = true
L["Objective Editor"] = true
L["Objective Set"] = true
L["Objective Templates"] = true
L["Objective"] = true
L["Objectives on this bar cannot use materials already accounted for by another objective on the same bar."] = true
L["On Use Macrotext"] = true
L["onUse"] = "On Use"
L["OnUse"] = "On Use"
L["Outline"] = true
L["Overlay"] = true
L["Page"] = true
L["Please specify a number between %d and %d."] = true
L["Please specify a number between %s and %s."] = true
L["Please specify a tradeskill recipe name."] = true
L["Please specify movable type: true, false, toggle."] = true
L["Preview"] = true
L["Pushed"] = true
L["Quest Activate"] = true
L["Quest Complete"] = true
L["Quest Failed"] = true
L["Refresh hidden status on these events."] = true
L["Remove Alt ID"] = true
L["Remove Objective Template"] = true
L["Remove Skin"] = true
L["Reset Bar Alert"] = true
L["Reset Button Alert"] = true
L["Reset Hidden"] = true
L["Reset Tracker Alert"] = true
L["Right Button"] = true
L["Save as Template"] = true
L["Save Template"] = true
L["Scale"] = true
L["Screen"] = true
L["Set the direction of bar's growth."] = true
L["Set the number of buttons on bar."] = true
L["Set the number of buttons per axis."] = true
L["Set the padding of bar's buttons."] = true
L["Set the size of bar's buttons."] = true
L["Sets bar alpha."] = true
L["Sets bar scale."] = true
L["Settings"] = true
L["Shadow"] = true
L["Shift"] = true
L["Shift+left-click to choose this icon."] = true
L["Show all details on tooltips without holding the modifier key."] = true
L["Show Cooldown"] = true
L["Show Details"] = true
L["Show Edge"] = true
L["Show Empty"] = true
L["Show hints on tooltips without holding the modifier key."] = true
L["Show Hints"] = true
L["Show Hyperlink"] = true
L["Show item hyperlink on button tooltips."] = true
L["Show options frame."] = true
L["Show this bar only on mouseover."] = true
L["showObjectiveEditBox"] = "Show Objective EditBox"
L["showObjectiveEditor"] = "Show Objective Editor"
L["showQuickAddCurrencyEditBox"] = "Show Quick-Add Currency EditBox"
L["showQuickAddEditBox"] = "Show Quick-Add EditBox"
L["Shows a backdrop on empty buttons."] = true
L["Shows the cooldown swipe animation on buttons."] = true
L["Skin"] = true
L["Skins"] = true
L["Slash Commands"] = true
L["Solid Border"] = true
L["Sound"] = true
L["Sounds"] = true
L["Style"] = true
L["Swap profiles."] = true
L["Template exists."] = true
L["Templates"] = true
L["TexCoords"] = true
L["Texture"] = true
L["Thick Outline"] = true
L["Toggle all tooltips."] = true
L["Toggle bar tooltips."] = true
L["Toggle button tooltips."] = true
L["Toggle tooltips."] = true
L["Tooltips"] = true
L["Track the number of completed objectives on this bar."] = true
L["Tracker already exists for this objective."] = true
L["Tracker ID"] = true
L["Tracker Key"] = true
L["Tracker Type"] = true
L["Tracker"] = true
L["Trackers"] = true
L["Type"] = true
L["UI ActionButton Border"] = true
L["UI EmptySlot White"] = true
L["Use GameTooltip"] = true
L["User Templates"] = true
L["View Code"] = true
L["X-Offset"] = true
L["Y-Offset"] = true

local function GetCommandString(actionInfo)
    -- Ctrl+right-click
    local mods = private:StringToTitle(gsub(actionInfo.modifier, "-", "+")) -- Put in title case and replace - with +
    local button = gsub(actionInfo.button, "Button", "")
    button = mods == "" and button or format("+%s", strlower(button))
    local clickType = actionInfo.type and "drag" or "click"

    return addon.ColorFontString(format("%s%s-%s", mods, button, clickType), "TORQUISEBLUE")
end

L.ButtonHints = function(action, actionInfo)
    local actions = {
        useItem = format("%s to use the display item or run the display macrotext.", GetCommandString(actionInfo)),
        moveObjective = format("%s to move this objective.", GetCommandString(actionInfo)),
        dragObjective = format("%s to move this objective.", GetCommandString(actionInfo)),
        clearObjective = format("%s to clear this objective.", GetCommandString(actionInfo)),
        showObjectiveEditBox = format("%s to show the objective editbox.", GetCommandString(actionInfo)),
        showQuickAddEditBox = format("%s to show the quick add editbox.", GetCommandString(actionInfo)),
        showQuickAddCurrencyEditBox = format(
            "%s to show the currency quick add editbox.",
            GetCommandString(actionInfo)
        ),
        showObjectiveEditor = format("%s to show the objective editor.", GetCommandString(actionInfo)),
        moveObjectiveToBank = format(
            "%s to move all items until the objective to your bank.",
            GetCommandString(actionInfo)
        ),
        moveAllToBank = format("%s to move all items to your bank.", GetCommandString(actionInfo)),
    }

    return actions[action] or ""
end

L.GetTexCoordID = function(id)
    local ids = {
        [1] = "Left",
        [2] = "Right",
        [3] = "Top",
        [4] = "Bottom",
    }
    return ids[id]
end

L.UnknownRecipe = function(recipeName)
    return format(
        "You do not know the recipe: %s. If you believe this is an error, please manually open your tradeskill and try again.",
        recipeName
    )
end
