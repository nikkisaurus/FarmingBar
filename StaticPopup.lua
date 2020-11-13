local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

--*------------------------------------------------------------------------

-- TODO: Localize text

StaticPopupDialogs["FARMINGBAR_CONFIRM_DELETE_MULTIPLE_OBJECTIVES"] = {
    text = "You are about to delete %d objectives. |cffff0000This will remove these objectives from all bars globally.|r Do you want to continue?",
    button1 = YES,
    button2 = NO,
    OnAccept = function()
        addon:DeleteObjective()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3
}

------------------------------------------------------------

StaticPopupDialogs["FARMINGBAR_CONFIRM_DELETE_OBJECTIVE"] = {
    text = [[You are about to delete the objective "%s". |cffff0000This will remove this objective from all bars globally.|r Do you want to continue?]],
    button1 = YES,
    button2 = NO,
    OnAccept = function(_, objectiveTitle)
        addon:DeleteObjective(objectiveTitle)
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3
}

------------------------------------------------------------

StaticPopupDialogs["FARMINGBAR_CONFIRM_OVERWRITE_OBJECTIVE"] = {
    text = [[The objective "%s" already exists. Do you want to overwrite it?]],
    button1 = YES,
    button2 = NO,
    OnAccept = function(_, objectiveTitle, objectiveInfo)
        addon:CreateObjective(objectiveTitle, objectiveInfo, true)
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3
}

--*------------------------------------------------------------------------

StaticPopupDialogs["FARMINGBAR_CONFIRM_REMOVE_ALL_BARS"] = {
    text = "You are about to delete all bars. Do you want to continue?",
    button1 = YES,
    button2 = NO,
    OnAccept = function()
        addon:RemoveAllBars()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3
}

------------------------------------------------------------

StaticPopupDialogs["FARMINGBAR_CONFIRM_REMOVE_BAR"] = {
    text = [[You are about to delete "%s". Do you want to continue?]],
    button1 = YES,
    button2 = NO,
    OnAccept = function(_, barID)
        addon:RemoveBar(barID)
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3
}

------------------------------------------------------------

StaticPopupDialogs["FARMINGBAR_CONFIRM_REMOVE_MULTIPLE_BARS"] = {
    text = "You are about to delete %d bars. Do you want to continue?",
    button1 = YES,
    button2 = NO,
    OnAccept = function()
        addon:RemoveSelectedBars(true)
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3
}