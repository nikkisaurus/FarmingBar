local addonName = ...
local addon = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

local ACD = LibStub("AceConfigDialog-3.0")

------------------------------------------------------------

local format, tonumber, tostring = string.format, tonumber, tostring
local GetItemIconByID = C_Item.GetItemIconByID
--@retail@
local GetCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo
--@end-retail@

--*------------------------------------------------------------------------

local actions =  {
    ITEM = L["Item"],
    --@retail@
    CURRENCY = L["Currency"],
    --@end-retail@
    MACROTEXT = L["Macrotext"],
    RECIPE = L["Recipe"],
    NONE = L["None"],
}

--@retail@
local actionSort = {"ITEM", "CURRENCY", "MACROTEXT", "RECIPE", "NONE"}
--@end-retail@
--[===[@non-retail@
local actionSort = {"ITEM", "MACROTEXT", "RECIPE", "NONE"}
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

local function GetActionInfoLabel(objectiveTitle)
    local trackerType = addon:GetDBValue("global", "objectives")[objectiveTitle].action

    if trackerType == "ITEM" then
        return L["Item ID/Name/Link"]
    --@retail@
    elseif trackerType == "CURRENCY" then
        return L["Currency ID/Link"]
    --@end-retail@
    elseif trackerType == "RECIPE" then
        return L["Recipe String"]
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
        new = {
            order = 1,
            type = "execute",
            name = L["New"],
            func = function()
                self:CreateObjectiveTemplate()
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
    }

    for objectiveTitle, objectiveInfo in self.pairs(addon.db.global.objectives) do
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
                        args = {
                            trackerCondition = {
                                order = 1,
                                type = "select",
                                name = L["Action"],
                                values = trackerConditions,
                                sorting = trackerConditionSort,
                                get = function(info)
                                    return self:GetObjectiveDBValue(info[#info], objectiveTitle)
                                end,
                                set = function(info, value)
                                    self:SetObjectiveDBValue(info[#info], value, objectiveTitle)
                                end,
                            },

                            ------------------------------------------------------------

                            customCondition = {
                                order = 2,
                                type = "input",
                                width = "full",
                                multiline = true,
                                name = L["Custom"],
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
                                    return self:SetObjectiveDBValue(info[#info], value, objectiveTitle)
                                end,
                            },

                            ------------------------------------------------------------

                            --@retail@
                            type = {
                                order = 4,
                                type = "select",
                                name = L["Type"],
                                values = trackers,
                                sorting = trackerSort,
                                get = function(info)
                                    return newTrackerType
                                end,
                                set = function(info, value)
                                    newTrackerType = value
                                end,
                            },
                            --@end-retail@

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
                },
            }

            for tracker, trackerInfo in pairs(addon.db.global.objectives[objectiveTitle].trackers) do
                options[objectiveTitle].args.trackers.args[tostring(trackerInfo.trackerID)] = self:GetTrackersObjectiveBuilderOptions(objectiveTitle, tracker)
            end
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
                return self:GetObjectiveTemplateIcon(objectiveTitle), 35, 35
            end,
            func = function()
                self.DragFrame:LoadObjectiveTemplate(objectiveTitle)
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
                self:SetObjectiveDBValue(info[#info], value, objectiveTitle)
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
                self:SetObjectiveDBValue(info[#info], value, objectiveTitle)
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

        action = {
            order = 5,
            type = "group",
            inline = true,
            name = L["Action"],
            get = function(info)
                return tostring(self:GetObjectiveDBValue(info[#info], objectiveTitle))
            end,
            args = {
                action = {
                    order = 1,
                    type = "select",
                    name = L["Action"],
                    values = actions,
                    sorting = actionSort,
                    set = function(info, value)
                        self:SetObjectiveDBValue("action", value, objectiveTitle)
                    end,
                },

                ------------------------------------------------------------

                actionInfo = {
                    order = 2,
                    type = "input",
                    width = "full",
                    multiline = true,
                    name = function()
                        return GetActionInfoLabel(objectiveTitle)
                    end,
                    hidden = function()
                        return self:GetObjectiveDBValue("action", objectiveTitle) == "NONE"
                    end,
                    validate = function(_, value)
                        if value == "" then return true end
                        local action = self:GetObjectiveDBValue("action", objectiveTitle)

                        if action == "ITEM" or action == "CURRENCY" then
                            return self:ValidateObjectiveData(action, value) or format(L.InvalidTrackerID, action, value)
                        elseif action == "RECIPE" then
                            -- TODO: validate recipe
                            return true
                        else -- MACROTEXT
                            return true
                        end
                    end,
                    set = function(info, value)
                        if value == "" then
                            self:SetObjectiveDBValue(info[#info], value, objectiveTitle)
                            return
                        end

                        local action = self:GetObjectiveDBValue("action", objectiveTitle)

                        if action == "ITEM" or action == "CURRENCY" then
                            local validTrackerID = self:ValidateObjectiveData(action, value)
                            if validTrackerID then
                                self:SetObjectiveDBValue(info[#info], validTrackerID, objectiveTitle)
                            end
                        else
                            self:SetObjectiveDBValue(info[#info], value, objectiveTitle)
                        end
                    end,
                },
            },
        },

        ------------------------------------------------------------

        manage = {
            order = 6,
            type = "group",
            inline = true,
            name = L["Manage"],
            args = {
                duplicateObjective = {
                    order = 1,
                    type = "execute",
                    name = L["Duplicate Objective"],
                    disabled = true,
                    func = function()
                        self:CreateObjectiveTemplate(objectiveTitle, self:GetObjectiveInfo(objectiveTitle))
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
                    disabled = true,
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

function addon:GetTrackersObjectiveBuilderOptions(objectiveTitle, tracker)
    local trackerInfo = addon.db.global.objectives[objectiveTitle].trackers[tracker]

    local options = {
        type = "group",
        name = "",
        args = {
            title = {
                order = 1,
                type = "description",
                name = trackerInfo.trackerID,
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

                    for eObjectiveTitle, _ in self.pairs(addon.db.global.objectives, function(a, b) return strupper(a) < strupper(b) end) do
                        if eObjectiveTitle ~= objectiveTitle and not self:ObjectiveIsExcluded(trackerInfo.exclude, eObjectiveTitle) then
                            values[eObjectiveTitle] = eObjectiveTitle
                        end
                    end

                    return values
                end,
                sorting = function()
                    local sorting = {}

                    for eObjectiveTitle, _ in self.pairs(addon.db.global.objectives, function(a, b) return strupper(a) < strupper(b) end) do
                        if eObjectiveTitle ~= objectiveTitle and not self:ObjectiveIsExcluded(trackerInfo.exclude, eObjectiveTitle) then
                            tinsert(sorting, eObjectiveTitle)
                        end
                    end

                    return sorting
                end,
                disabled = function(info)
                    local count = 0

                    for eObjectiveTitle, _ in self.pairs(addon.db.global.objectives, function(a, b) return strupper(a) < strupper(b) end) do
                        if eObjectiveTitle ~= objectiveTitle and not self:ObjectiveIsExcluded(trackerInfo.exclude, eObjectiveTitle) then
                            count = count + 1
                        end
                    end

                    return count == 0
                end,
                set = function(_, value)
                    tinsert(addon.db.global.objectives[objectiveTitle].trackers[tracker].exclude, value)
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
            options.name = GetItemInfo(itemID)
            options.args.title.name = self.ColorFontString(GetItemInfo(itemID), "gold")
        end, trackerInfo.trackerID)
        options.icon = GetItemIconByID(trackerInfo.trackerID)
        options.args.title.image = GetItemIconByID(trackerInfo.trackerID)
    else
        local currency = GetCurrencyInfo(trackerInfo.trackerID)
        options.name = currency.name
        options.args.title.name = self.ColorFontString(currency.name, "gold")
        options.icon = currency.iconFileID
        options.args.title.image = currency.iconFileID
    end

    return options
end

------------------------------------------------------------

function addon:RefreshObjectiveBuilderOptions()
    if not self.options then return end
    self.options.args.objectiveBuilder.args = self:GetObjectiveBuilderOptions()
    self:RefreshOptions()
end