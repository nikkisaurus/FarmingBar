local addonName = ...
local L = LibStub("AceLocale-3.0"):NewLocale("FarmingBar", "enUS", true)

--*------------------------------------------------------------------------

local strupper = string.upper

--*------------------------------------------------------------------------
--*Strings-----------------------------------------------------------------

-- Shared
L["Trackers"] = true

-- Modules\Objectives\ObjectiveBuilder-Objective.lua
L["All"] = true
L["All of"] = true
L["Any"] = true
L["Any of"] = true
L["Automatic Icon"] = true
L["Choose"] = true
L["Condition"] = true
L["Custom"] = true
L["Display Reference"] = true
L["Enabled"] = true
L["Export"] = true
L["If"] = true
L["New Tracker"] = true
L["None"] = true
L["Tracker Condition"] = true

L.DisplayReferenceDescription_Gsub = "/currency"
L.DisplayReferenceDescription = [[Display References allow you to set which item/currency you want to use for automatic objective information. This includes the icon chosen when using "Automatic Icon" and the item associated with a button's "use" attribute.]]

------------------------------------------------------------

-- Modules\Objectives\ObjectiveBuilder.lua
L["Close"] = true
L["Delete"] = true
L["Delete All"] = true
L["Display Ref"] = true
L["Duplicate"] = true
L["Duplicate All"] = true
L["FALSE"] = true
L["Import Objective"] = true
L["Invalid Tracker"] = true
L["more"] = true
L["New Objective"] = true
L["NONE"] = true
L["Objective"] = true
L["Objective Builder"] = true
L["Rename"] = true
L["Total"] = true
L["Tracker"] = true
L["TRUE"] = true

------------------------------------------------------------

-- Modules\Objectives\Objectives.lua
L["New"] = true

------------------------------------------------------------

-- Modules\Objectives\Trackers.lua
L["Currency"] = true
L["Currency ID"] = true
L["Exclude Objective"] = true
L["Include All Characters"] = true
L["Include Bank"] = true
L["Item"] = true
L["Item ID/Name/Link"] = true
L["Objective"] = true
L["Required"] = true
L["Type"] = true

--*------------------------------------------------------------------------
--*Errors------------------------------------------------------------------

-- Shared
L["Error"] = true


------------------------------------------------------------

-- Modules\Objectives\Trackers.lua
L.InvalidObjectiveTitle = "Invalid objective title."
L.InvalidTrackerExclusion = "Cannot exclude parent objective."
L.ObjectiveIsExcluded = "Objective is already being excluded."

L.InvalidTrackerID = function(trackerType, trackerID) return string.format("Invalid tracker ID: %s:%s", strupper(trackerType), trackerID) end
L.TrackerIDExists = function(trackerID) return string.format("Already tracking %s", trackerID) end
