local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

--*------------------------------------------------------------------------

-- TODO: Localize text

StaticPopupDialogs["FARMINGBAR_CONFIRM_DELETE_MULTIPLE_OBJECTIVES"] = {
    text = "You are about to delete %d objectives. |cffff0000This will remove these objectives from all bars globally.|r These objectives are active on %d button(s). Do you want to continue?",
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
    text = [[You are about to delete the objective "%s". |cffff0000This will remove this objective from all bars globally.|r This objective is active on %d button(s). Do you want to continue?]],
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

StaticPopupDialogs["FARMINGBAR_CONFIRM_NEW_QUICK_OBJECTIVE_PROMPT"] = {
    text = [[The objective "%s" already exists. What do you want to do?]],
    button1 = L["OVERWRITE"],
    button2 = L["USE EXISTING"],
    button3 = L["CREATE NEW"],
    OnAccept = function(_, objectiveInfo) -- button1
        addon:CreateObjective(objectiveInfo.objectiveTitle, objectiveInfo.defaultInfo, true)
    end,
    OnAlt = function(_, objectiveInfo) -- button3
        local objectiveTitle = addon:CreateObjective(objectiveInfo.objectiveTitle, objectiveInfo.defaultInfo)
        if objectiveInfo.widget then
            objectiveInfo.widget:SetObjectiveID(objectiveTitle)
        end
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

--*------------------------------------------------------------------------

StaticPopupDialogs["FARMINGBAR_CONFIRM_OVERWRITE_TEMPLATE"] = {
    text = [[Template "%s" already exists. Do you want to overwrite this template?]],
    button1 = YES,
    button2 = NO,
    OnAccept = function(_, barID, templateName)
        addon:SaveTemplate(barID, templateName, true)
    end,
    timeout = 0,
    whileDead = true,
    enterClicksFirstButton = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

------------------------------------------------------------

StaticPopupDialogs["FARMINGBAR_INCLUDE_TEMPLATE_DATA"] = {
    text = [[Do you want to include objective data while loading templates "%s"]],
    button1 = YES,
    button2 = NO,
    button3 = CANCEL,
    OnAccept = function(_, data)
        if FarmingBar.db.global.settings.preserveTemplateOrder == "PROMPT" then
            local dialog = StaticPopup_Show("FARMINGBAR_SAVE_TEMPLATE_ORDER", data[2])
            if dialog then
                dialog.data = {data[1], data[2], true}
            end
        else
            addon:LoadTemplate("user", data[1], data[2], true, FarmingBar.db.global.settings.preserveTemplateOrder == "ENABLED")
        end
    end,
    OnCancel = function(_, data)
        if FarmingBar.db.global.settings.preserveTemplateOrder == "PROMPT" then
            local dialog = StaticPopup_Show("FARMINGBAR_SAVE_TEMPLATE_ORDER", data[2])
            if dialog then
                dialog.data = {data[1], data[2], false}
            end
        else
            addon:LoadTemplate("user", data[1], data[2], false, FarmingBar.db.global.settings.preserveTemplateOrder == "ENABLED")
        end
    end,
    timeout = 0,
    whileDead = true,
    enterClicksFirstButton = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

------------------------------------------------------------

StaticPopupDialogs["FARMINGBAR_SAVE_TEMPLATE_ORDER"] = {
    text = [[Do you want to save the objective order while loading template "%s"?]],
    button1 = YES,
    button2 = NO,
    button3 = CANCEL,
    OnAccept = function(_, data)
        addon:LoadTemplate("user", data[1], data[2], data[3], true)
    end,
    OnCancel = function(_, data)
        addon:LoadTemplate("user", data[1], data[2], data[3])
    end,
    timeout = 0,
    whileDead = true,
    enterClicksFirstButton = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

--*------------------------------------------------------------------------

StaticPopupDialogs["FARMINGBAR_V30_ALPHA2_BARRESET"] = {
    text = "Farming Bar (v3.0-alpha2): General bar settings have been changed from character to profile specific. Alerts, bar titles, and objectives remain character specific. Your bars have been reset. Objectives have not been altered and can be added back to your bars from the Objective Builder.",
    button1 = OKAY,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3
}
