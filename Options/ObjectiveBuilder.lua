local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)
local ACD = LibStub("AceConfigDialog-3.0")

local format, tonumber, tostring = string.format, tonumber, tostring
local GetItemIconByID = C_Item.GetItemIconByID
--@retail@
local GetCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo
--@end-retail@

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

------------------------------------------------------------

local newTrackerType, newTrackerID = "ITEM"

--@retail@
local trackers = {
    ITEM = L["Item"],
    CURRENCY = L["Currency"],
}

local trackerSort = {"ITEM", "CURRENCY"}
--@end-retail@

------------------------------------------------------------

local trackerConditions = {
    ANY = L["Any"],
    ALL = L["All"],
    CUSTOM = L["Custom"],
}

local trackerConditionSort = {"ANY", "ALL", "CUSTOM"}

--*------------------------------------------------------------------------

local function GetDisplayRefTrackerIDLabel(objectiveTitle)
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

------------------------------------------------------------

local function GetTrackerIDLabel()
    if newTrackerType == "ITEM" then
        return L["Item ID/Name/Link"]
    --@retail@
    elseif newTrackerType == "CURRENCY" then
        return L["Currency ID/Link"]
    --@end-retail@
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
                self:CreateObjective()
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
        dropper = {
            order = 0,
            type = "execute",
            name = " ",
            desc = L.Options_ObjectiveBuilder("objective.dropper"),
            width = 1/3,
            image = function()
                return self:GetObjectiveIcon(objectiveTitle), 35, 35
            end,
            func = function()
                self.DragFrame:Load(objectiveTitle)
            end,
        },

        ------------------------------------------------------------

        title = {
            order = 1,
            type = "input",
            width = 2.5,
            name = L["Title"],
            validate = function(_, value)
                if value == "" then return end
                return objectiveTitle == value or not self:GetObjectiveInfo(value) or L.ObjectiveExists
            end,
            get = function(info)
                return objectiveTitle
            end,
            set = function(info, value)
                if objectiveTitle == value then return end
                self:RenameObjective(objectiveTitle, value)
                ACD:SelectGroup(addonName, "objectiveBuilder", value)
            end,
        },

        ------------------------------------------------------------

        autoIcon = {
            order = 2,
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

        icon = {
            order = 3,
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
            order = 4,
            type = "execute",
            name = L["Choose"],
            hidden = function()
                return self:GetObjectiveDBValue("autoIcon", objectiveTitle)
            end,
            func = function()

            end,
        },

        ------------------------------------------------------------

        displayRef = {
            order = 5,
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
                    width = "full",
                    multiline = true,
                    name = function()
                        return GetDisplayRefTrackerIDLabel(objectiveTitle)
                    end,
                    hidden = function()
                        return self:GetObjectiveDBValue("displayRef.trackerType", objectiveTitle) == "NONE"
                    end,
                    get = function(info)
                        local trackerID = self:GetObjectiveDBValue("displayRef."..info[#info], objectiveTitle)
                        return trackerID and tostring(trackerID)
                    end,
                    validate = function(_, value)
                        if value == "" then return true end
                        local trackerType = self:GetObjectiveDBValue("displayRef.trackerType", objectiveTitle)

                        if trackerType == "ITEM" or trackerType == "CURRENCY" then
                            return self:ValidateObjectiveData(trackerType, value) or format(L.InvalidTrackerID, trackerType, value)
                        elseif trackerType == "RECIPE" then
                            -- TODO: validate recipe
                            return true
                        else -- MACROTEXT
                            return true
                        end
                    end,
                    set = function(info, value)
                        local trackerType = self:GetObjectiveDBValue("displayRef.trackerType", objectiveTitle)

                        if trackerType == "ITEM" or trackerType == "CURRENCY" then
                            local validTrackerID = self:ValidateObjectiveData(trackerType, value)
                            self:SetObjectiveDBInfo("displayRef."..info[#info], validTrackerID, objectiveTitle)
                        else
                            self:SetObjectiveDBInfo("displayRef."..info[#info], value, objectiveTitle)
                        end
                    end,
                },
            },
        },

        ------------------------------------------------------------

        trackers = {
            order = 6,
            type = "group",
            inline = true,
            name = L["Trackers"],
            args = {
                trackerCondition = {
                    order = 1,
                    type = "select",
                    name = L["Tracker Condition"],
                    values = trackerConditions,
                    sorting = trackerConditionSort,
                    get = function(info)
                        return self:GetObjectiveDBValue(info[#info], objectiveTitle)
                    end,
                    set = function(info, value)
                        self:SetObjectiveDBInfo(info[#info], value, objectiveTitle)
                    end,
                },

                ------------------------------------------------------------

                customCondition = {
                    order = 2,
                    type = "input",
                    width = "full",
                    multiline = true,
                    name = L["Custom Condition"],
                    hidden = function()
                        return self:GetObjectiveDBValue("trackerCondition", objectiveTitle) ~= "CUSTOM"
                    end,
                    get = function(info)
                        return self:GetObjectiveDBValue(info[#info], objectiveTitle)
                    end,
                    validate = function(_, value)
                        if value == "" then return true end
                        local validCondition, err = self:ValidateCustomCondition(value)

                        if err then
                            addon:ReportError(L.InvalidCustomCondition)
                            print(err)
                        else
                            return true
                        end
                    end,
                    set = function(info, value)
                        return self:SetObjectiveDBInfo(info[#info], value, objectiveTitle)
                    end,
                },

                ------------------------------------------------------------

                newTracker = {
                    order = 3,
                    type = "header",
                    name = L["New Tracker"],
                },

                ------------------------------------------------------------

                type = {
                    order = 4,
                    type = "select",
                    name = L["Type"],
                    values = trackers,
                    sorting = trackerSort,
                    --[===[@non-retail@
                    hidden = function()
                        return true
                    end,
                    --@end-non-retail@]===]
                    get = function(info)
                        return newTrackerType
                    end,
                    set = function(info, value)
                        newTrackerType = value
                    end,
                },

                ------------------------------------------------------------

                newTrackerID = {
                    order = 5,
                    type = "input",
                    width = "full",
                    name = function()
                        return GetTrackerIDLabel(objectiveTitle)
                    end,
                    validate = function(_, value)
                        local validTrackerID = self:ValidateObjectiveData(newTrackerType, value)
                        local trackerIDExists = validTrackerID and self:TrackerExists(objectiveTitle, validTrackerID)

                        if trackerIDExists then
                            return format(L.TrackerIDExists, value)
                        else
                            return validTrackerID or format(L.InvalidTrackerID, newTrackerType, value)
                        end
                    end,
                    set = function(info, value)
                        local validTrackerID = self:ValidateObjectiveData(newTrackerType, value)
                        self:CreateTracker(objectiveTitle, {trackerType = newTrackerType, trackerID = validTrackerID})
                        ACD:SelectGroup(addonName, "objectiveBuilder", objectiveTitle, "trackers", value)
                    end,
                },

            },
        },

        ------------------------------------------------------------

        manage = {
            order = 7,
            type = "group",
            inline = true,
            name = L["Manage"],
            args = {
                duplicateObjective = {
                    order = 1,
                    type = "execute",
                    name = L["Duplicate Objective"],
                    func = function()
                        self:CreateObjective(objectiveTitle, self:GetObjectiveInfo(objectiveTitle))
                    end,
                },

                ------------------------------------------------------------

                exportObjective = {
                    order = 2,
                    type = "execute",
                    name = L["Export Objective"],
                    disabled = true,
                    func = function()

                    end,
                },

                ------------------------------------------------------------

                deleteObjective = {
                    order = 3,
                    type = "execute",
                    name = L["Delete Objective"],
                    func = function()
                        self:DeleteObjective(objectiveTitle)
                    end,
                    confirm = function()
                        return format(L.Options_ObjectiveBuilder("objective.manage.deleteObjective_confirm"), objectiveTitle, self:GetNumButtonsContainingObjective(objectiveTitle))
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

    for tracker, trackerInfo in pairs(FarmingBar.db.global.objectives[objectiveTitle].trackers) do
        options[tostring(trackerInfo.trackerID)] = {
            type = "group",
            args = {
                title = {
                    order = 1,
                    type = "description",
                    width = "full",
                    imageWidth = 20,
                    imageHeight = 20,
                    fontSize = "medium",
                },

                ------------------------------------------------------------

                objective = {
                    order = 2,
                    type = "input",
                    width = "full",
                    name = L["Objective"],
                    get = function(info)
                        return tostring(self:GetTrackerDBInfo(objectiveTitle, tracker, info[#info]))
                    end,
                    validate = function(_, value)
                        value = tonumber(value) or 0
                        return value > 0
                    end,
                    set = function(info, value)
                        self:SetTrackerDBInfo(objectiveTitle, tracker, info[#info], tonumber(value))
                    end,
                },

                ------------------------------------------------------------

                countsFor = {
                    order = 3,
                    type = "input",
                    width = "full",
                    name = L["Counts For"],
                    get = function(info)
                        return tostring(self:GetTrackerDBInfo(objectiveTitle, tracker, info[#info]))
                    end,
                    validate = function(_, value)
                        value = tonumber(value) or 0
                        return value > 0
                    end,
                    set = function(info, value)
                        self:SetTrackerDBInfo(objectiveTitle, tracker, info[#info], tonumber(value))
                    end,
                },

                ------------------------------------------------------------

                includeBank = {
                    order = 4,
                    type = "toggle",
                    width = "full",
                    name = L["Include Bank"],
                    get = function(info)
                        return self:GetTrackerDBInfo(objectiveTitle, tracker, info[#info])
                    end,
                    set = function(info, value)
                        self:SetTrackerDBInfo(objectiveTitle, tracker, info[#info], value)
                        self:UpdateButtons(objectiveTitle)
                    end,
                },

                ------------------------------------------------------------

                includeAllChars = {
                    order = 4,
                    type = "toggle",
                    width = "full",
                    name = L["Include All Characters"],
                    get = function(info)
                        return self:GetTrackerDBInfo(objectiveTitle, tracker, info[#info])
                    end,
                    set = function(info, value)
                        self:SetTrackerDBInfo(objectiveTitle, tracker, info[#info], value)
                    end,
                },

                ------------------------------------------------------------

                exclude = {
                    order = 5,
                    type = "select",
                    width = "full",
                    name = L["Exclude Objective"],
                    values = function()
                        local values = {}

                        for eObjectiveTitle, _ in self.pairs(FarmingBar.db.global.objectives, function(a, b) return strupper(a) < strupper(b) end) do
                            if eObjectiveTitle ~= objectiveTitle and not self:ObjectiveIsExcluded(trackerInfo.exclude, eObjectiveTitle) then
                                values[eObjectiveTitle] = eObjectiveTitle
                            end
                        end

                        return values
                    end,
                    sorting = function()
                        local sorting = {}

                        for eObjectiveTitle, _ in self.pairs(FarmingBar.db.global.objectives, function(a, b) return strupper(a) < strupper(b) end) do
                            if eObjectiveTitle ~= objectiveTitle and not self:ObjectiveIsExcluded(trackerInfo.exclude, eObjectiveTitle) then
                                tinsert(sorting, eObjectiveTitle)
                            end
                        end

                        return sorting
                    end,
                    disabled = function(info)
                        local count = 0

                        for eObjectiveTitle, _ in self.pairs(FarmingBar.db.global.objectives, function(a, b) return strupper(a) < strupper(b) end) do
                            if eObjectiveTitle ~= objectiveTitle and not self:ObjectiveIsExcluded(trackerInfo.exclude, eObjectiveTitle) then
                                count = count + 1
                            end
                        end

                        return count == 0
                    end,
                    set = function(_, value)
                        tinsert(FarmingBar.db.global.objectives[objectiveTitle].trackers[tracker].exclude, value)
                        self:UpdateButtons()
                    end,
                },

                ------------------------------------------------------------

                excluded = {
                    order = 6,
                    type = "select",
                    width = "full",
                    name = L["Remove Excluded Objective"],
                    values = function()
                        local values = {}

                        for _, eObjectiveTitle in self.pairs(trackerInfo.exclude, function(a, b) return strupper(a) < strupper(b) end) do
                            values[eObjectiveTitle] = eObjectiveTitle
                        end

                        return values
                    end,
                    sorting = function()
                        local sorting = {}

                        for _, eObjectiveTitle in self.pairs(trackerInfo.exclude, function(a, b) return strupper(a) < strupper(b) end) do
                            tinsert(sorting, eObjectiveTitle)
                        end

                        return sorting
                    end,
                    disabled = function(info)
                        return self.tcount(trackerInfo.exclude) == 0
                    end,
                    set = function(_, value)
                        for key, eObjectiveTitle in pairs(trackerInfo.exclude) do
                            if eObjectiveTitle == value then
                                tremove(trackerInfo.exclude, key)
                            end
                        end
                        self:UpdateButtons()
                    end,
                },

                ------------------------------------------------------------

                deleteTracker = {
                    order = 7,
                    type = "execute",
                    width = "full",
                    name = L["Delete Tracker"],
                    func = function()
                        self:DeleteTracker(objectiveTitle, tracker)
                    end,
                    confirm = function(...)
                        return L.Options_ObjectiveBuilder("tracker.deleteTracker")
                    end,
                },
            },
        }

        if trackerInfo.trackerType == "ITEM" then
            self.CacheItem(trackerInfo.trackerID, function(itemID)
                options[tostring(trackerInfo.trackerID)].name = GetItemInfo(itemID)
                options[tostring(trackerInfo.trackerID)].args.title.name = self.ColorFontString(GetItemInfo(itemID), "gold")
            end, trackerInfo.trackerID)
            options[tostring(trackerInfo.trackerID)].icon = GetItemIconByID(trackerInfo.trackerID)
            options[tostring(trackerInfo.trackerID)].args.title.image = GetItemIconByID(trackerInfo.trackerID)
        else
            local currency = GetCurrencyInfo(trackerInfo.trackerID)
            options[tostring(trackerInfo.trackerID)].name = currency.name
            options[tostring(trackerInfo.trackerID)].args.title.name = self.ColorFontString(currency.name, "gold")
            options[tostring(trackerInfo.trackerID)].icon = currency.iconFileID
            options[tostring(trackerInfo.trackerID)].args.title.image = currency.iconFileID
        end
    end

    return options
end

------------------------------------------------------------

function addon:RefreshObjectiveBuilderOptions()
    if not self.options then return end
    self.options.args.objectiveBuilder.args = self:GetObjectiveBuilderOptions()
    self:RefreshOptions()
end

------------------------------------------------------------

function addon:RefreshObjectiveBuilderTrackerOptions(objectiveTitle)
    if not self.options then return end
    self.options.args.objectiveBuilder.args[objectiveTitle].args.trackers.args = self:GetTrackersObjectiveBuilderOptions(objectiveTitle)
    self:RefreshOptions()
end