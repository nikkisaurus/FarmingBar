local addonName = ...
local L = LibStub("AceLocale-3.0"):NewLocale("FarmingBar", "enUS", true)
local utils = LibStub("LibAddonUtils-1.0")

local format, gsub, strlower, strupper = string.format, string.gsub, string.lower, string.upper
local sexteal = utils.ChatColors["SEXTEAL"]

--*------------------------------------------------------------------------
--*Errors------------------------------------------------------------------

-- Shared
L["Error"] = true

------------------------------------------------------------

-- Modules\ObjectiveBuilder.lua
L.InvalidCustomCondition = "Invalid custom condition:"
L.InvalidCustomConditionReturn = [[Custom conditions must return a table with nested "trackerGroup" tables.]]
L.InvalidCustomConditionTable = "Nested trackerGroups must be tables."
L.InvalidCustomConditionID = [[Nested trackerGroup keys must be in the format "t%d", where %d is the tracker ID.]]
L.InvalidCustomConditionObjective = "Nested trackerGroup values must be an integer >= 0 representing the tracker objective."
L.InvalidObjectiveTitle = "Invalid objective title."
L.InvalidTrackerExclusion = "Cannot exclude parent objective."
L.ObjectiveIsExcluded = "Objective is already being excluded."

L.invalidSyntax = function(err) return "Syntax error: "..err end
L.InvalidTrackerID = function(trackerType, trackerID) return format("Invalid tracker ID: %s:%s", strupper(trackerType), trackerID) end
L.TrackerIDExists = function(trackerID) return format("Already tracking %s", trackerID) end


--*------------------------------------------------------------------------
--*Hints-------------------------------------------------------------------

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
    local mods = strupper(strsub(commandInfo.modifier, 1, 1))..strlower(strsub(commandInfo.modifier, 2))
    local button = gsub(commandInfo.button, "Button", "")
    button = mods == "" and button or format("+%s", strlower(button))

    return utils.ColorFontString(format("%s%s-click", mods, button), "SEXTEAL")
end

L.ButtonHints = function(command, commandInfo)
    local commands = {
        useItem = format("%s to use the display item or run the display macrotext.", GetCommandString(commandInfo)),
        moveObjective = format("%s to move this objective.", GetCommandString(commandInfo)),
        clearObjective = format("%s to clear this objective.", GetCommandString(commandInfo)),
        includeBank = format("%s to toggle bank inclusion.", GetCommandString(commandInfo)),
        showObjectiveBuilder = format("%s to show the Objective Builder.", GetCommandString(commandInfo)),
        showObjectiveEditBox = format("%s to show the objective editbox.", GetCommandString(commandInfo)),
    }

    return commands[command] or ""
end

--*------------------------------------------------------------------------
--*Strings-----------------------------------------------------------------

-- Shared

------------------------------------------------------------

-- Core.lua
L["Auction Open"] = true
L["Auction Close"] = true
L["Loot Coin"] = true
L["Quest Activate"] = true
L["Quest Complete"] = true
L["Quest Failed"] = true

------------------------------------------------------------

-- Modules\ObjectiveBuilder.lua
L["Add"] = true
L["All"] = true
L["Any"] = true
L["Automatic Icon"] = true
L["Choose"] = true
L["Close"] = true
L["Condition"] = true
L["Currency"] = true
L["Custom"] = true
L["Custom Condition"] = true
L["Delete"] = true
L["Delete All"] = true
L["Display Ref"] = true
L["Display Reference"] = true
L["Duplicate"] = true
L["Duplicate All"] = true
L["Enabled"] = true
L["Exclude Objective"] = true
L["Excluded"] = true
L["Export"] = true
L["FALSE"] = true
L["Filter Auto Items"] = true
L["Help"] = true
L["Import Objective"] = true
L["Include All Characters"] = true
L["Include Bank"] = true
L["Invalid Tracker"] = true
L["Item"] = true
L["Macrotext"] = true
L["Missing"] = true
L["more"] = true
L["New Objective"] = true
L["New Tracker"] = true
L["None"] = true
L["Objective"] = true
L["Objective Builder"] = true
L["Rename"] = true
L["Tracker Condition"] = true
L["Trackers"] = true
L["TRUE"] = true
L["Type"] = true

L.DisplayReferenceDescription = [[Display References allow you to set which item/currency you want to use for automatic objective information. This includes the icon chosen when using "Automatic Icon" and the item associated with a button's "use" attribute. However, when set to a macrotext, the icon will be unaffected.]]
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
L["Currency ID/Link"] = true
L["Item ID/Name/Link"] = true

------------------------------------------------------------

-- Frame\Widgets\FarmingBar_TrackerButton.lua
L["Move Down"] = true
L["Move Up"] = true
