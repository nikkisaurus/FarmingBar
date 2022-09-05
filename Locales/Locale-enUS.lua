local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0")
local L = LibStub("AceLocale-3.0"):NewLocale(addonName, "enUS", true)
LibStub("LibAddonUtils-1.0"):Embed(addon)
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

L.addonName = "Farming Bar"

--[[ Errors ]]
L["Bar is already assigned an ID: %d"] = true
L["Button is already assigned an ID: %d:%d"] = true
L["barDB.hidden must return a \"function\""] = true

--[[ Tooltips ]]
L[" to lock and hide anchor."] = true

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

--[[ Options ]]
L["Left Button"] = true
L["Expand Tooltip"] = true
L["* The following settings are profile specific."] = true
L["Show Hints"] = true
L["Show hints on tooltips without holding the modifier key."] = true
L["Right Button"] = true
L["Alt"] = true
L["Control"] = true
L["Shift"] = true
L.clearObjective = "Clear Objective"
L.moveObjective = "Move Objective"
L.moveObjectiveToBank = "Move Objective to Bank"
L.moveAllToBank = "Move All to Bank"
L.dragObjective = "Drag Objective"
L.showObjectiveEditBox = "Show Objective EditBox"
L.showObjectiveEditor = "Show Objective Editor"
L.showQuickAddEditBox = "Show Quick-Add EditBox"
L.showQuickAddCurrencyEditBox = "Show Quick-Add Currency EditBox"
L.onUse = "On Use"
L["On Use Macrotext"] = true
L["Hints"] = true
L["Layout"] = true
L["Tooltips"] = true
L["Show Hyperlink"] = true
L["Show item hyperlink on button tooltips."] = true
L["Show Details"] = true
L["Show all details on tooltips without holding the modifier key."] = true
L["Hold this key down while hovering over a button to view additional tooltip details."] = true
L["Use GameTooltip"] = true
L["Slash Commands"] = true
L["Are you sure you want to remove %s from this objective?"] = true
L["Are you sure you want to clear this button?"] = true
L["BLEND"] = true
L["Style"] = true
L["Custom Condition: Syntax error"] = true
L["Custom Condition: Invalid function"] = true
L["Lua Editor"] = true
L["Invalid Tracker Type"] = true
L["Invalid Tracker/Alt ID"] = true
L["Apply Objective Template"] = true
L["Invalid template name."] = true
L["Template exists."] = true
L["Missing dependencies"] = true
L["Clear"] = true
L["Profile"] = true
L["Keybinds"] = true
L["Are you sure you want to overwrite Bar %d Button %d with objective template \"%s\"?"] = true
L["Include Alts"] = true
L["Include Bank"] = true
L["Config"] = true
L["Settings"] = true
L["Help"] = true
L["Config Bars"] = true
L["Include Guild Bank"] = true
L["Objective Editor"] = true
L["Save Template"] = true
L["Are you sure you want to delete %s from Bar %d Button %d?"] = true
L["X-Offset"] = true
L["Y-Offset"] = true
L["Fontstrings"] = true
L["ADD"] = true
L["DISABLE"] = true
L["Text"] = true
L["ALPHAKEY"] = true
L["MOD"] = true
L["Modifier"] = true
L["Mouse Button"] = true
L["Alerts"] = true
L["Monochrome"] = true
L["Outline"] = true
L["Thick Outline"] = true
L["Alt ID"] = true
L["Are you sure you want to remove %s from the tracker \"%s\"?"] = true
L["Remove Alt ID"] = true
L["Alt IDs"] = true
L["%s Text"] = true
L["Are you sure you want to remove Bar %d?"] = true
L["Quantity"] = true
L["Fonts"] = true
L["Events"] = true
L["Refresh hidden status on these events."] = true
L["Font Face"] = true
L["OnUse"] = true
L["Font Outline"] = true
L["Font Size"] = true
L["Show Cooldown"] = true
L["Shows the cooldown swipe animation on buttons."] = true
L["Are you sure you want to delete %s from objective template \"%s\"?"] = true
L["Alt ID already exists for this tracker."] = true
L["Tracker already exists for this objective."] = true
L["Objective"] = true
L["Multiplier"] = true
L["Event \"%s\" doesn't exist."] = true
L["Alerts"] = true
L["Name"] = true
L["Templates"] = true
L["Copy From"] = true
L["Bar"] = true
L["Bars"] = true
L["Item/Currency Name"] = true
L["Label"] = true
L["Bar Progress"] = true
L["Track the number of completed objectives on this bar."] = true
L["Completed Objectives"] = true
L["Continue tracking objectives after completion."] = true
L["Mute All"] = true
L["Mute all alerts on this bar."] = true
L["Limit Mats"] = true
L["Objectives on this bar cannot use materials already accounted for by another objective on the same bar."] = true
L["Alpha"] = true
L["Count"] = true
L["Counts"] = true
L["%d more..."] = true
L["Scale"] = true
L["Skin"] = true
L["Are you sure you want to clear Bar %d"] = true
L["Mouseover"] = true
L["Clear Bar"] = true
L["Show this bar only on mouseover."] = true
L["Backdrop"] = true
L[" to configure this bar."] = true
L["Background"] = true
L["Enable"] = true
L["Save as Template"] = true
L["User Templates"] = true
L["Border"] = true
L["Background Color"] = true
L["Border Color"] = true
L["Show Empty"] = true
L["Shows a backdrop on empty buttons."] = true
L["Hidden"] = true
L["Reset Hidden"] = true
L["Bar Anchor"] = true
L["Anchor"] = true
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
L["Icon ID"] = true
L["Item"] = true
L["Macrotext"] = true
L["None"] = true
L["Type"] = true
L["OnUse"] = true
L["ItemID"] = true
L["Invalid item/currency ID."] = true
L["Invalid itemID."] = true
L["Objective Editor"] = true
L["Invalid item ID."] = true
L["Invalid currency ID."] = true
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
L["place"] = true
L["Export Frame"] = true
L["New"] = true
L["true"] = true
L["false"] = true
L["Import"] = true
L["Remove Objective Template"] = true
L["Import Frame"] = true
L["Are you sure you want to remove %s from %s?"] = true
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
L["Add Tracker"] = true
L["Tracker"] = true
L["Tracker Type"] = true
L["Tracker ID"] = true
L["New Alt ID"] = true
L["Bank"] = true
L["Alts"] = true
L["Guild Bank"] = true
L["Include"] = true
L["Tracker Key"] = true
L["Button Alert"] = true
L["Reset Button Alert"] = true
L["Bar Alert"] = true
L["Reset Bar Alert"] = true
L["Are you sure you want to reset bar alerts format?"] = true
L["Are you sure you want to reset button alerts format?"] = true
L["Alert formats must be a function returning a string value."] = true
L["Format"] = true
L["Preview"] = true
L["Auction Open"] = true
L["Auction Close"] = true
L["Loot Coin"] = true
L["Quest Activate"] = true
L["Quest Complete"] = true
L["Quest Failed"] = true
L["UI EmptySlot White"] = true
L["UI ActionButton Border"] = true
L["Icon Border Thick"] = true
L["Icon Border"] = true
L["Solid Border"] = true
L["Chat"] = true
L["Screen"] = true
L["Sound"] = true
L["Sounds"] = true
L["Farming Progress"] = true
L["Bar Progress"] = true
L["Bar Complete"] = true
L["Objective Set"] = true
L["Objective Cleared"] = true
L["Objective Complete"] = true

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
