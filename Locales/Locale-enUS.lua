local addonName = ...
local addon = LibStub("AceAddon-3.0"):NewAddon("FarmingBar", "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0")
local L = LibStub("AceLocale-3.0"):NewLocale("FarmingBar", "enUS", true)

------------------------------------------------------------

local utils = LibStub("LibAddonUtils-1.0")

local format, gsub, strlower, strupper = string.format, string.gsub, string.lower, string.upper
local sexteal = utils.ChatColors["SEXTEAL"]

-- *------------------------------------------------------------------------

L.addon = "Farming Bar"

-- *------------------------------------------------------------------------
-- *Errors------------------------------------------------------------------

-- Shared
L["Error"] = true
L.InvalidFunction = "Input must be a function."
L.InvalidReturn = "Function must return a string"
L.InvalidBarPreviewTotal = "Progress total cannot be larger than progress count."

------------------------------------------------------------

-- Modules\ObjectiveBuilder.lua
L["Tracked"] = true

L.InvalidCustomCondition = "Invalid custom condition:"
L.InvalidCustomConditionReturn = [[Custom conditions must return a table with nested "trackerGroup" tables.]]
L.InvalidCustomConditionTable = "Nested trackerGroups must be tables."
L.InvalidCustomConditionID =
    [[Nested trackerGroup keys must be in the format "t%d", where %d is the tracker ID or "%dt%d:%dt%d" expressing a ration between two tracker IDs, such that 10t1:1t2 represents the equivalency between 10 of tracker 1 and 1 of tracker 2.]]
L.InvalidCustomConditionObjective = "Nested trackerGroup values must be an integer >= 0 representing the tracker objective."
L.InvalidObjectiveTitle = "Invalid objective title."
L.InvalidTrackerExclusion = "Cannot exclude parent objective."
L.ObjectiveIsExcluded = "Objective is already being excluded."

L.InvalidCraftSkillID = "Invalid tradeskill name."
L.MissingCraftRecipeName = "Please specify a Recipe String"
L.UnknownRecipe = "You do not know the recipe: %s"

L.InvalidSyntax = function(err)
    return "Syntax error: " .. (type(err) == "string" and err or "??")
end
L.InvalidTrackerID = "Invalid tracker: %s:%s"
-- L.InvalidTrackerID = function(trackerType, trackerID) return format("Invalid tracker ID: %s:%s", strupper(trackerType), trackerID) end
L.TrackerIDExists = "Already tracking %s"
-- L.TrackerIDExists = function(trackerID) return format("Already tracking %s", trackerID) end

-- *------------------------------------------------------------------------
-- *Hints-------------------------------------------------------------------

L["Hint"] = true
L["Hints"] = true

-- Modules\ObjectiveBuilder.lua
L.FilterAutoItemsHint = [[Check this option to hide automatically created item objectives (prepended by "item:").]]
L.NewObjectiveHint = "You can drop an item on this button to quickly add it as an objective."
L.ObjectiveContextMenuHint = format("%sRight-click|r this button to open a context menu to rename, duplicate, or delete this objective.\n%sDrag|r this button onto a bar to track it.", sexteal, sexteal)
L.RemoveExcludeHint = format("%sShift+right-click|r this objective to remove it from the list.", sexteal)
L.TrackerContextMenuHint = format("%sRight-click|r this button to delete or move this tracker.", sexteal)

------------------------------------------------------------

-- Modules\Tooltips.lua
local function GetCommandString(commandInfo)
    -- Ctrl+right-click
    local mods = gsub(strupper(strsub(commandInfo.modifier, 1, 1)) .. strlower(strsub(commandInfo.modifier, 2)), "-", "+") -- Put in title case and replace - with +
    local button = (button == "LeftButton" or button == "RightButton") and gsub(commandInfo.button, "Button", "") or commandInfo.button
    button = mods == "" and button or format("+%s", strlower(button))
    local clickType = commandInfo.type and "drag" or "click"

    return utils.ColorFontString(format("%s%s-%s", mods, button, clickType), "SEXTEAL")
end

L.BarHints = function(command, commandInfo)
    commandInfo = commandInfo or {
        button = "",
        modifier = "",
    }
    local commands = {
        moveBar = format("%s to move this bar.", GetCommandString(commandInfo)),
        configBar = format("%s to configure this bar.", GetCommandString(commandInfo)),
        toggleMovable = format("%s to lock or unlock this bar.", GetCommandString(commandInfo)),
        openHelp = format("%s to open the help documentation.", GetCommandString(commandInfo)),
        openSettings = format("%s to configure addon settings.", GetCommandString(commandInfo)),
        showObjectiveBuilder = format("%s to open the Objective Builder.", GetCommandString(commandInfo)),
    }

    return commands[command] or ""
end

L.ButtonHints = function(command, commandInfo)
    local commands = {
        useItem = format("%s to use the display item or run the display macrotext.", GetCommandString(commandInfo)),
        moveObjective = format("%s to move this objective.", GetCommandString(commandInfo)),
        dragObjective = format("%s to move this objective.", GetCommandString(commandInfo)),
        clearObjective = format("%s to clear this objective.", GetCommandString(commandInfo)),
        showObjectiveEditBox = format("%s to show the objective editbox.", GetCommandString(commandInfo)),
        showQuickAddEditBox = format("%s to show the quick add editbox.", GetCommandString(commandInfo)),
        showQuickAddCurrencyEditBox = format("%s to show the currency quick add editbox.", GetCommandString(commandInfo)),
        showObjectiveEditor = format("%s to show the objective editbox.", GetCommandString(commandInfo)),
        moveObjectiveToBank = format("%s to move all items until the objective to your bank.", GetCommandString(commandInfo)),
        moveAllToBank = format("%s to move all items to your bank.", GetCommandString(commandInfo)),
    }

    return commands[command] or ""
end

L["Progress"] = true
L["Show Hints"] = true

L.ToggleMovable = function(barTitle, movable)
    return format("%s %s.", barTitle, movable and "unlocked" or "locked")
end

-- *------------------------------------------------------------------------
-- *Strings-----------------------------------------------------------------

-- Shared

------------------------------------------------------------

-- Core.lua
L["Auction Open"] = true
L["Auction Close"] = true
L["Loot Coin"] = true
L["Quest Activate"] = true
L["Quest Complete"] = true
L["Quest Failed"] = true

L["Manage"] = true
L.ConfirmRemoveBar = "Are you sure you want to permanently remove bar %d?"

------------------------------------------------------------

-- Modules\ObjectiveBuilder.lua
L["Add"] = true
L["All"] = true
L["Any"] = true
L["Automatic Icon"] = true
L["Bar Complete"] = true
L["Bar Progress"] = true
L["Choose"] = true
L["Cleanup"] = true
L["Close"] = true
L["Condition"] = true
L["Create Objective Template"] = true
L["Currency"] = true
L["Custom"] = true
L["Custom"] = true
L["Delete Tracker"] = true
L["Delete Objective"] = true
L["Action"] = true
L["Action"] = true
L["Duplicate"] = true
L["Duplicate Objective"] = true
L["Enabled"] = true
L["Exclude Objective"] = true
L["Remove Excluded Objective"] = true
L["Excluded"] = true
L["Export"] = true
L["FALSE"] = true
L["Filter Auto Items"] = true
L["Help"] = true
L["Import"] = true
L["Include All Characters"] = true
L["Include Bank"] = true
L["Include Guild Bank"] = true
L["Invalid Tracker"] = true
L["Item"] = true
L["Macrotext"] = true
L["Missing"] = true
L["more"] = true
L["Mute Alerts"] = true
L["New"] = true
L["New Count"] = true
L["New Tracker"] = true
L["None"] = true
L["Objective"] = true
L["Objective Builder"] = true
L["Objective Cleared"] = true
L["Objective Editor"] = true
L["Objective Set"] = true
L["Old Count"] = true
L["Order"] = true
L["Preview Settings"] = true
L["Preview Settings - Objective"] = true
L["Preview Settings - Tracker"] = true
L["Rename"] = true
L["Condition"] = true
L["Trackers"] = true
L["Toggle Bar Enabled"] = true
L["TRUE"] = true
L["Type"] = true

L.DisplayReferenceDescription =
    [[Actions allow you to set which item/currency you want to use for automatic objective information. This includes the icon chosen when using "Automatic Icon" and the item associated with a button's "use" attribute. However, when set to a macrotext, the icon will be unaffected.

Farming Bar provides a /craft command that you can use in your macrotexts. Simply use "/craft Recipe String". For example:

/craft Enchanting Eternal Bounds
/use Enchanting Vellum]]
L.DisplayReferenceDescription_Gsub = "/currency"

------------------------------------------------------------

-- Modules\Objectives.lua
L["New"] = true

------------------------------------------------------------

-- Modules\Tooltips.lua
L["Button ID"] = true
L["Count"] = true
L["Objective Complete"] = true

-- L.ButtonID = function(id) return format("Button ID: %s", id) end

------------------------------------------------------------

-- Modules\Trackers.lua
L["Counts For"] = true
L["Currency ID/Link"] = true
L["Item ID/Name/Link"] = true
L["Recipe String"] = true

------------------------------------------------------------

-- Frame\Widgets\FarmingBar_TrackerButton.lua
L["Move Down"] = true
L["Move Up"] = true

------------------------------------------------------------

-- Options\Config.lua
L["Add Bar"] = true
L["Bar"] = true
L["Config"] = true
L["Remove Bar"] = true

------------------------------------------------------------

-- Options\Options.lua
L["ACCOUNT COUNTS"] = true
L["Account Counts Overlay"] = true
L["Alt"] = true
L["Auto loot items on use"] = true
L["BANK INCLUSION"] = true
L["Bank Overlay"] = true
L["Bar Tooltips"] = true
L["Bars"] = true
L["Button Layers"] = true
L["Button Tooltips"] = true
L["Commands"] = true
L["Control"] = "Ctrl"
L["Cooldown"] = true
L["Cooldown Edge"] = true
L["CREATE NEW"] = true
L["CUSTOM"] = true
L["Debug"] = true
L["Delete Template"] = true
L["DISABLED"] = true
L["Enable Modifier"] = true
L["Enabled"] = true
L["ENABLED"] = true
L["Face"] = true
L["Fonts"] = true
L["General"] = true
L["Global"] = true
L["Hide Objective Info"] = true
L["INCLUDE ACCOUNT AND BANK"] = true
L["Item Quality"] = true
L["ITEM QUALITY"] = true
L["Keybinds"] = true
L["Miscellaneous"] = true
L["Modifier"] = true
L["Modules"] = true
L["MONOCHROME"] = true
L["NONE"] = true
L["Objectives"] = true
L["Open"] = true
L["OUTLINE"] = true
L["OVERWRITE"] = true
L["Preserve Template Data"] = true
L["Preserve Template Order"] = true
L["Profile"] = true
L["PROMPT"] = true
L["Settings"] = true
L["Shift"] = true
L["Skin"] = true
L["Slash Commands"] = true
L["Style Editor"] = true
L["Templates"] = true
L["Tooltips"] = true
L["THICKOUTLINE"] = true
L["USE EXISTING"] = true

L.Options_settings_global_general_tooltips_bar = "Enables bar tooltips."
L.Options_settings_global_general_tooltips_button = "Enables button tooltips."
L.Options_settings_global_general_tooltips_hideObjectiveInfo = "Hides objective information on button tooltips."
L.Options_settings_global_general_hints_bars = "Displays keybind hints at the bottom of bar tooltips."
L.Options_settings_global_general_hints_buttons = "Displays keybind hints at the bottom of button tooltips."
L.Options_settings_global_general_hints_ObjectiveBuilder = "Displays tooltip hints on Objective Builder widgets."
L.Options_settings_global_general_hints_enableModifier = "Allows tooltip hints to be shown only when a modifier is held down."
L.Options_settings_global_general_hints_modifier = "Sets the modifier key used to show tooltip hints."
L.Options_settings_global_misc_autoLootOnUse = "Temporarily enables auto loot when using an item"
L.Options_settings_global_misc_filterQuickObjectives = "Hides automatically created item objectives from the Objective Builder list"
L.Options_settings_global_templates_deleteTemplate = "Permanently deletes a user-defined template."
L.Options_settings_global_templates_deleteTemplateConfirm = [[Are you sure you want to permanently delete the template "%s"?]]
L.Options_settings_global_templates_preserveTemplateData = "Includes objective data when loading user-defined templates."
L.Options_settings_global_templates_preserveTemplateOrder = "Saves the order of objectives loaded onto a bar from user-defined templates."

L.Options_settings_profile_skin = "Sets the skin for bars and buttons."
L.Options_settings_profile_buttonLayers_AccountOverlay = "Enables the four-point orange diamond border indicating account counts on buttons."
L.Options_settings_profile_buttonLayers_AutoCastable = "Enables the four-point gold border indicating bank inclusion on buttons."
L.Options_settings_profile_buttonLayers_Border = "Enables the item quality border on buttons."
L.Options_settings_profile_buttonLayers_Cooldown = "Enables the item cooldown swipe on buttons."
L.Options_settings_profile_buttonLayers_CooldownEdge = "Enables the bling on the edge of item cooldown swipes on buttons."
L.Options_settings_profile_fonts_face = "Sets the font face for bar and button fontstrings."
L.Options_settings_profile_fonts_size = "Sets the font size for bar and button fontstrings."
L.Options_settings_profile_fonts_outline = "Sets the font outline for bar and button fontstrings."
L.Options_settings_profile_count_style = "Sets the color style for button count fontstrings."
L.Options_settings_profile_count_color = "Sets the custom color for button count fontstrings."

------------------------------------------------------------

-- Frame\Widgets\FarmingBar_BarButton.lua
L["Alerts"] = true
L["Alert Type"] = true
L["All Bars"] = true
L["Alpha"] = true
L["Anchor"] = true
L["Bar"] = true
L["Bar Progress"] = true
L["Bottom"] = true
L["Bottomleft"] = true
L["Bottomright"] = true
L["Button"] = true
L["Buttons"] = true
L["Buttons Per Wrap"] = true
L["Chat"] = true
L["Clear Buttons"] = true
L["Center"] = true
L["Color"] = true
L["Completed Objectives"] = true
L["Count Fontstring"] = true
L["Disabled"] = true
L["Down"] = true
L["Duplicate Bar"] = true
L["Lua Editor"] = true
L["Enabled"] = true
L["Expand"] = true
L["Hearthstone"] = true
L["Hearthstones"] = true
L["Font Face"] = true
L["Font Outline"] = true
L["Font Size"] = true
L["Format With Objective"] = true
L["Format Without Objective"] = true
L["Formats"] = true
L["Gain"] = true
L["Growth Direction"] = true
L["Growth Type"] = true
L["Hidden"] = true
L["Left"] = true
L["Load Template"] = true
L["Load User Template"] = true
L["Loss"] = true
L["Monochrome"] = true
L["Movable"] = true
L["Mute All"] = true
L["Muted"] = true
L["My Bar Name"] = true
L["None"] = true
L["Normal"] = true
L["Number of Buttons"] = true
L["Objective Fontstring"] = true
L["Operations"] = true
L["Outline"] = true
L["Padding"] = true
L["Point"] = true
L["Preview"] = true
L["Progress Format"] = true
L["Reindex Buttons"] = true
L["Remove"] = true
L["Remove All"] = true
L["Remove Selected"] = true
L["Reverse"] = true
L["Right"] = true
L["Save as Template"] = true
L["Screen"] = true
L["Show Empty Buttons"] = true
L["Show on Anchor Mouseover"] = true
L["Show on Mouseover"] = true
L["Size"] = true
L["Resize Bar"] = true
L["Sound"] = true
L["Sounds"] = true
L["Style"] = true
L["Styles"] = true
L["Template"] = true
L["Thickoutline"] = true
L["Export Objective"] = true
L["Title"] = true
L["Top"] = true
L["Topleft"] = true
L["Total Objectives"] = true
L["Tracker"] = true
L["Icon"] = true
L["Recipe"] = true
L["Topright"] = true
L["Up"] = true
L["Use Long Name"] = true
L["Visibility"] = true
L["X Offset"] = true
L["Y Offset"] = true

------------------------------------------------------------

L.ObjectiveExists = "Objectives exists"
-- Modules\Templates.lua
L.TemplateSaved = "All items on bar %d saved as farming template: %s"
L.TemplateDeleted = [[Template "%s" deleted.]]
L.InvalidItemID = "Invalid itemID: %d"
L.InvalidCurrencyID = "Invalid currencyID: %d"
L.MissingIncludeAllCharsDependecies = "The following addons are missing and required for this feature: %s"

L.TemplateObjectiveMissing = [[Missing template objective "%s" not loaded.]]

-- *------------------------------------------------------------------------

L.Options_Config = function(widget)
    local strings = {
        ["charSpecific"] = [[*(Asterisk) denotes character specific database settings.]],
        ["mixedSpecific"] = [[**(Double asterisk) denotes mixed character and profile specific database settings.]],
    }

    return strings[widget]
end

-- *------------------------------------------------------------------------

L.Options_ObjectiveBuilder = function(widget)
    local strings = {
        ["objective.dropper"] = "Click to place this objective onto a bar.",
        ["objective.manage.DeleteObjectiveTemplate_confirm"] = [[Are you sure you want to delete the objective template "%s"?]],
        ["tracker.deleteTracker"] = [[Are you sure you want to permanently delete this tracker?]],
    }

    return strings[widget]
end

-- *------------------------------------------------------------------------

L.Options_Help = [[|cffffcc00Farming Bar (v3.0-alpha18)|r

Thank you for testing the alpha! If you have any suggestions or bug reports, please create an issue at |cff00ccff[ https://github.com/niketa-wow/farmingbar/issues ]|r and specify the current alpha version. Features in the stable release that are not yet implemented in this alpha are not bugs and should not be reported.

For other questions, you can message me on Discord |cff00ccff@Niketa#1247|r or comment at |cff00ccff[ https://www.curseforge.com/wow/addons/farming-bar ]|r.

As a reminder, if you switch back to the stable version from this alpha, your alpha settings will not be saved. Your stable database, however, will remain intact and be restored. There is no guarantee that alpha database versions will be protected during alpha restructures (though I will try my best not to restructure anything major).]]

------------------------------------------------------------

L.Options_Help_Alerts = [[|cffffcc00Alerts|r

This is a description.
]]

------------------------------------------------------------

L.Options_Help_Commands = [[|cffffcc00Commands|r

This is a description.
]]

------------------------------------------------------------

L.Options_Help_Objectives = [[|cffffcc00Objectives|r

This is a description.
]]

------------------------------------------------------------

L.Options_Help_Templates = [[|cffffcc00Templates|r

This is a description.
]]

L.FARMINGBAR_CONFIRM_OVERWRITE_TEMPLATE = [[Template "%s" already exists. Do you want to overwrite this template?]]
L.FARMINGBAR_INCLUDE_TEMPLATE_DATA = [[Do you want to include objective data while loading templates "%s"]]
L.FARMINGBAR_SAVE_TEMPLATE_ORDER = [[Do you want to save the objective order while loading template "%s"?]]
