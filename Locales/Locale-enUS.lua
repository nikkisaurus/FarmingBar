local addonName = ...
local L = LibStub("AceLocale-3.0"):NewLocale("FarmingBar", "enUS", true)

--*------------------------------------------------------------------------

local strupper = string.upper

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
L.InvalidTrackerID = function(trackerType, trackerID) return string.format("Invalid tracker ID: %s:%s", strupper(trackerType), trackerID) end
L.TrackerIDExists = function(trackerID) return string.format("Already tracking %s", trackerID) end


--*------------------------------------------------------------------------
--*Hints-------------------------------------------------------------------

-- Modules\ObjectiveBuilder.lua
L.FilterAutoItemsHint = [[Check this option to hide automatically created item objectives (prepended by "item:").]]
L.NewObjectiveHint = "You can drop an item on this button to quickly add it as an objective."
L.ObjectiveContextMenuHint = "Right-click this button to open a context menu to rename, duplicate, or delete this objective.\nDrag this button onto a bar to track it."
L.RemoveExcludeHint = "Shift+right-click this objective to remove it from the list."
L.TrackerContextMenuHint = "Right-click this button to delete or move this tracker."

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
L["Hint"] = true
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

-- Modules\Trackers.lua
L["Currency ID/Link"] = true
L["Item ID/Name/Link"] = true

------------------------------------------------------------

-- Frame\Widgets\FarmingBar_TrackerButton.lua
L["Move Down"] = true
L["Move Up"] = true
