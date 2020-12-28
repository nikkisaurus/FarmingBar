local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

local format = string.format

--*------------------------------------------------------------------------

local displayRefs =  {
    ITEM = L["Item"],
    --@retail@
    CURRENCY = L["Currency"],
    --@end-retail@
    RECIPE = L["Recipe"],
    MACROTEXT = L["Macrotext"],
    NONE = L["None"],
}

--@retail@
local displayRefSort = {"ITEM", "CURRENCY", "RECIPE", "MACROTEXT", "NONE"}
--@end-retail@
--[===[@non-retail@
local displayRefSort = {"ITEM", "CRAFT", "MACROTEXT", "NONE"}
--@end-non-retail@]===]

--*------------------------------------------------------------------------

local function GetDisplayRefTrackerIDLabel()
    local trackerType = addon:GetObjectiveDBValue("displayRef.trackerType", objectiveTitle)

    if trackerType == "ITEM" then
        return L["Item ID/Name/Link"]
    --@retail@
    elseif trackerType == "CURRENCY" then
        return L["Currency ID/Link"]
    --@end-retail@
    elseif trackerType == "RECIPE" then
        return L["Tradeskill Recipe Name"]
    elseif trackerType == "MACROTEXT" then
        return L["Macrotext"]
    end
end

--*------------------------------------------------------------------------

function addon:GetObjectiveBuilderOptions()
    local options = {
        newObjective = {
            order = 1,
            type = "execute",
            name = L["New Objective"],
            func = function()

            end,
        },

        ------------------------------------------------------------

        import = {
            order = 2,
            type = "execute",
            name = L["Import"],
            disabled = true,
            func = function()

            end,
        },

        ------------------------------------------------------------

        cleanup = {
            order = 3,
            type = "execute",
            name = L["Cleanup"],
            desc = L.Options_ObjectiveBuilder("cleanup"),
            func = function()
                self:CleanupQuickObjectives()
            end,
            confirm = function()
                return L.Options_ObjectiveBuilder("cleanup_confirm")
            end,
        },

        ------------------------------------------------------------

        filter = {
            order = 4,
            type = "toggle",
            width = "full",
            name = L["Filter quick objectives"],
            get = function()
                return self:GetDBValue("global", "settings.filterQuickObjectives")
            end,
            set = function(_, value)
                self:SetDBValue("global", "settings.filterQuickObjectives", value)
                self:RefreshObjectiveBuilderOptions()
            end,
        },
    }

    for objectiveTitle, objectiveInfo in self.pairs(FarmingBar.db.global.objectives) do
        local autoFilterEnabled = self:GetDBValue("global", "settings.filterQuickObjectives")
        local autoFiltered = autoFilterEnabled and self:IsObjectiveAutoItem(objectiveTitle)

        if not autoFiltered then

            options[objectiveTitle] = {
                type = "group",
                name = objectiveTitle,
                childGroups = "tab",
                args = {
                    objective = {
                        order = 1,
                        type = "group",
                        name = L["Objective"],
                        args = self:GetObjectiveObjectiveBuilderOptions(objectiveTitle),
                    },

                    ------------------------------------------------------------

                    trackers = {
                        order = 2,
                        type = "group",
                        name = L["Trackers"],
                        args = self:GetTrackersObjectiveBuilderOptions(objectiveTitle),
                    },
                },
            }
        end
    end

    return options
end

------------------------------------------------------------

function addon:GetObjectiveObjectiveBuilderOptions(objectiveTitle)
    local options = {
        icon = {
            order = 1,
            type = "input",
            name = L["Icon"],
            hidden = function()
                return self:GetObjectiveDBValue("autoIcon", objectiveTitle)
            end,
            get = function(info)
                return self:GetObjectiveDBValue(info[#info], objectiveTitle)
            end,
            set = function(info, value)
                self:SetObjectiveDBInfo(info[#info], value, objectiveTitle)
            end,
        },

        ------------------------------------------------------------

        iconSelector = {
            order = 2,
            type = "execute",
            name = L["Choose"],
            hidden = function()
                return self:GetObjectiveDBValue("autoIcon", objectiveTitle)
            end,
            func = function()

            end,
        },

        ------------------------------------------------------------

        autoIcon = {
            order = 3,
            type = "toggle",
            name = L["Automatic Icon"],
            get = function(info)
                return self:GetObjectiveDBValue(info[#info], objectiveTitle)
            end,
            set = function(info, value)
                self:SetObjectiveDBInfo(info[#info], value, objectiveTitle)
            end,
        },

        ------------------------------------------------------------

        displayRef = {
            order = 4,
            type = "group",
            inline = true,
            name = L["Display Reference"],
            args = {
                trackerType = {
                    order = 1,
                    type = "select",
                    name = L["Type"],
                    values = displayRefs,
                    sorting = displayRefSort,
                    get = function(info)
                        return self:GetObjectiveDBValue("displayRef."..info[#info], objectiveTitle)
                    end,
                    set = function(info, value)
                        self:SetObjectiveDBInfo("displayRef."..info[#info], value, objectiveTitle)
                    end,
                },

                ------------------------------------------------------------

                trackerID = {
                    order = 2,
                    type = "input",
                    name = function()
                        return GetDisplayRefTrackerIDLabel()
                    end,
                    hidden = function()
                        local trackerType = self:GetObjectiveDBValue("displayRef.trackerType", objectiveTitle)
                        return trackerType == "NONE" or trackerType == "MACROTEXT"
                    end,
                    get = function(info)
                        local trackerID = self:GetObjectiveDBValue("displayRef.trackerID", objectiveTitle)
                        return trackerID and tostring(trackerID)
                    end,
                    set = function(info, value)
                        local trackerType = self:GetObjectiveDBValue("displayRef.trackerType", objectiveTitle)

                        if trackerType == "RECIPE" then
                            -- TODO: validate recipe
                            self:SetObjectiveDBInfo("displayRef.trackerID", value, objectiveTitle)
                        else
                            local validTrackerID, trackerType = self:ValidateObjectiveData(trackerType, value)
                            self:SetObjectiveDBInfo("displayRef.trackerID", validTrackerID, objectiveTitle)
                        end
                    end,
                    validate = function(_, value)
                        if value == "" then return true end
                        local trackerType = self:GetObjectiveDBValue("displayRef.trackerType", objectiveTitle)

                        if trackerType == "RECIPE" then
                            -- TODO: validate recipe
                            return true
                        else
                            return self:ValidateObjectiveData(trackerType, value) or format(L.InvalidTrackerID, trackerType, value)
                        end
                    end,
                },

                ------------------------------------------------------------

                trackerID_Multi = {
                    order = 2,
                    type = "input",
                    width = "full",
                    name = function()
                        return GetDisplayRefTrackerIDLabel()
                    end,
                    hidden = function()
                        return self:GetObjectiveDBValue("displayRef.trackerType", objectiveTitle) ~= "MACROTEXT"
                    end,
                    multiline = true,
                    get = function(info)
                        return self:GetObjectiveDBValue("displayRef.trackerID", objectiveTitle)
                    end,
                    set = function(info, value)
                        self:SetObjectiveDBInfo("displayRef.trackerID", value, objectiveTitle)
                    end,
                },
            },
        },
    }

    return options
end

------------------------------------------------------------

function addon:GetTrackersObjectiveBuilderOptions(objectiveTitle)
    local options = {}

    return options
end

------------------------------------------------------------

------------------------------------------------------------

function addon:RefreshObjectiveBuilderOptions()
    self.options.args.objectiveBuilder.args = self:GetObjectiveBuilderOptions()
    addon:RefreshOptions()
end