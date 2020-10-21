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
L.InvalidObjectiveTitle = "Invalid objective title."
L.InvalidTrackerExclusion = "Cannot exclude parent objective."
L.ObjectiveIsExcluded = "Objective is already being excluded."

L.InvalidTrackerID = function(trackerType, trackerID) return string.format("Invalid tracker ID: %s:%s", strupper(trackerType), trackerID) end
L.TrackerIDExists = function(trackerID) return string.format("Already tracking %s", trackerID) end


--*------------------------------------------------------------------------
--*Hints-------------------------------------------------------------------

-- Modules\ObjectiveBuilder.lua
L.NewObjectiveHint = "You can drop an item on this button to quickly add it as an objective."
L.NewTrackerHint = "You can drop an item on this button to quickly add it as a tracker."
L.ObjectiveContextMenuHint = "Right-click this button to open a context menu to rename, duplicate, or delete this objective.\nDrag this button onto a bar to track it."
L.RemoveExcludeHint = "Shift+right-click this objective to remove it from the list."
L.TrackerContextMenuHint = "Right-click this button to delete or move this tracker."

--*------------------------------------------------------------------------
--*Strings-----------------------------------------------------------------

-- Shared

------------------------------------------------------------

-- Modules\ObjectiveBuilder.lua
L["All"] = true
L["Any"] = true
L["Automatic Icon"] = true
L["Choose"] = true
L["Close"] = true
L["Condition"] = true
L["Currency"] = true
L["Custom"] = true
L["Custom Function"] = true
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
L["Hint"] = true
L["Import Objective"] = true
L["Include All Characters"] = true
L["Include Bank"] = true
L["Invalid Tracker"] = true
L["Item"] = true
L["Missing"] = true
L["more"] = true
L["New Objective"] = true
L["New Tracker"] = true
L["None"] = true
L["NONE"] = true
L["Objective"] = true
L["Objective Builder"] = true
L["Rename"] = true
L["Tracker Condition"] = true
L["Trackers"] = true
L["TRUE"] = true
L["Type"] = true

L.DisplayReferenceDescription = [[Display References allow you to set which item/currency you want to use for automatic objective information. This includes the icon chosen when using "Automatic Icon" and the item associated with a button's "use" attribute.]]
L.DisplayReferenceDescription_Gsub = "/currency"

------------------------------------------------------------

-- Modules\Objectives.lua
L["New"] = true

------------------------------------------------------------

-- Modules\Trackers.lua
L["Currency ID"] = true
L["Item ID/Name/Link"] = true
