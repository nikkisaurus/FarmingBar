local addonName = ...
local addon = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

-- Optional libraries
local ACD = LibStub("AceConfigDialog-3.0")

-- *------------------------------------------------------------------------
-- Tables and sorts

local actions = {
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

local newTrackerType = "ITEM"
--@retail@
local trackers = {
    ITEM = L["Item"],
    CURRENCY = L["Currency"],
}
local trackerSort = {"ITEM", "CURRENCY"}
--@end-retail@

local trackerConditions = {
    ANY = L["Any"],
    ALL = L["All"],
    CUSTOM = L["Custom"],
}
local trackerConditionSort = {"ANY", "ALL", "CUSTOM"}

-- *------------------------------------------------------------------------
-- Methods

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

local function GetTrackerIDLabel()
    if newTrackerType == "ITEM" then
        return L["Item ID/Name/Link"]
        --@retail@
    elseif newTrackerType == "CURRENCY" then
        return L["Currency ID/Link"]
        --@end-retail@
    end
end

-- *------------------------------------------------------------------------
-- Initialize objective builder options

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
        import = {
            order = 2,
            type = "execute",
            name = L["Import"],
            disabled = true,
            func = function()

            end,
        },
        quickAdd = {
            order = 3,
            type = "group",
            name = L["Quick Add"],
            inline = true,
            args = {
                description = {
                    order = 0,
                    type = "description",
                    name = L.Options_ObjectiveBuilder("objective.quickAddDesc"),
                },
                spacer = {
                    order = 1,
                    type = "header",
                    name = "",
                },
            },
        },
    }

    for objectiveTitle, objectiveInfo in self.pairs(self:GetDBValue("global", "objectives")) do
        -- Objective configuration
        options[objectiveTitle] = {
            type = "group",
            name = objectiveTitle,                
            icon = function()
                return self:GetObjectiveTemplateIcon(objectiveTitle), 35, 35
            end,
            childGroups = "tab",
            args = {
                objective = {
                    order = 1,
                    type = "group",
                    name = L["Objective"],
                    args = self:GetObjectiveBuilderOptions_Objective(objectiveTitle),
                },
                trackers = {
                    order = 2,
                    type = "group",
                    name = L["Trackers"],
                    args = {
                        condition = {
                            order = 1,
                            type = "select",
                            name = L["Condition"],
                            values = trackerConditions,
                            sorting = trackerConditionSort,
                            get = function(info)
                                return self:GetObjectiveDBValue(info[#info], objectiveTitle)
                            end,
                            set = function(info, value)
                                self:SetObjectiveDBValue(info[#info], value, objectiveTitle)
                                addon:UpdateButtons()
                            end,
                        },
                        conditionInfo = {
                            order = 2,
                            type = "input",
                            width = "full",
                            multiline = true,
                            name = L["Custom"],
                            hidden = function()
                                return self:GetObjectiveDBValue("condition", objectiveTitle) ~= "CUSTOM"
                            end,
                            get = function(info)
                                return self:GetObjectiveDBValue(info[#info], objectiveTitle)
                            end,
                            validate = function(_, value)
                                if value == "" then
                                    return true
                                end
                                local validCondition, err = self:ValidateCustomCondition(value)

                                if err then
                                    addon:ReportError(L.InvalidCustomCondition)
                                    print(err)
                                else
                                    return true
                                end
                            end,
                            set = function(info, value)
                                self:SetObjectiveDBValue(info[#info], value, objectiveTitle)
                                addon:UpdateButtons()
                            end,
                        },
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
                        newTrackerID = {
                            order = 5,
                            type = "input",
                            width = "full",
                            name = function()
                                return GetTrackerIDLabel()
                            end,
                            validate = function(_, value)
                                local validTrackerID = self:ValidateTrackerData(newTrackerType, value)
                                local trackerIDExists = validTrackerID and self:TrackerExists(self:GetDBValue("global", "objectives")[objectiveTitle], strupper(newTrackerType) .. ":" .. validTrackerID)

                                if trackerIDExists then
                                    return format(L.TrackerIDExists, value)
                                else
                                    return validTrackerID or format(L.InvalidTrackerID, newTrackerType, value)
                                end
                            end,
                            set = function(info, value)
                                local validTrackerID = self:ValidateTrackerData(newTrackerType, value)

                                local trackerKey = addon:CreateTracker(self:GetDBValue("global", "objectives")[objectiveTitle], newTrackerType, validTrackerID)
                                if trackerKey then
                                    ACD:SelectGroup(addonName, "objectiveBuilder", objectiveTitle, "trackers", trackerKey)
                                    addon:UpdateButtons()
                                end
                            end,
                        },
                    },
                },
            },
        }

        for tracker, trackerInfo in pairs(self:GetDBValue("global", "objectives")[objectiveTitle].trackers) do
            if trackerInfo.order ~= 0 then
                options[objectiveTitle].args.trackers.args[tracker] = self:GetObjectiveBuilderOptions_Trackers(objectiveTitle, tracker)
            end
        end
        
        -- Quick add button
        options.quickAdd.args[objectiveTitle] = {
            type = "execute",
            name = objectiveTitle,
            width = 1 / 3,
            image = function()
                return self:GetObjectiveTemplateIcon(objectiveTitle), 35, 35
            end,
            func = function()
                if IsControlKeyDown() then
                    ACD:SelectGroup(addonName, "objectiveBuilder", objectiveTitle)
                else                  
                    self.DragFrame:LoadObjectiveTemplate(objectiveTitle)
                end
            end,
        }
    end

    return options
end

-- *------------------------------------------------------------------------
-- Load objective builder

function addon:GetObjectiveBuilderOptions_Objective(objectiveTitle)
    local options = {
        dropper = {
            order = 0,
            type = "execute",
            name = " ",
            desc = L.Options_ObjectiveBuilder("objective.dropper"),
            width = 1 / 3,
            image = function()
                return self:GetObjectiveTemplateIcon(objectiveTitle), 35, 35
            end,
            func = function()
                self.DragFrame:LoadObjectiveTemplate(objectiveTitle)
            end,
        },
        title = {
            order = 1,
            type = "input",
            width = 2.5,
            name = L["Title"],
            validate = function(_, value)
                if value == "" then
                    return
                end
                return objectiveTitle == value or not self:ObjectiveTemplateExists(value) or L.ObjectiveExists
            end,
            get = function(info)
                return objectiveTitle
            end,
            set = function(info, value)
                if objectiveTitle == value then
                    return
                end
                self:RenameObjectiveTemplate(objectiveTitle, value)
                ACD:SelectGroup(addonName, "objectiveBuilder", value)
            end,
        },
        autoIcon = {
            order = 2,
            type = "toggle",
            name = L["Automatic Icon"],
            get = function(info)
                return self:GetObjectiveDBValue(info[#info], objectiveTitle)
            end,
            set = function(info, value)
                self:SetObjectiveDBValue(info[#info], value, objectiveTitle)
                addon:UpdateButtons()
            end,
        },
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
                addon:UpdateButtons()
            end,
        },
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
                        addon:UpdateButtons()
                    end,
                },
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
                        if value == "" then
                            return true
                        end
                        local action = self:GetObjectiveDBValue("action", objectiveTitle)

                        if action == "ITEM" or action == "CURRENCY" then
                            return self:ValidateTrackerData(action, value) or format(L.InvalidTrackerID, action, value)
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
                            addon:UpdateButtons()
                            return
                        end

                        local action = self:GetObjectiveDBValue("action", objectiveTitle)

                        if action == "ITEM" or action == "CURRENCY" then
                            local validTrackerID = self:ValidateTrackerData(action, value)
                            if validTrackerID then
                                self:SetObjectiveDBValue(info[#info], validTrackerID, objectiveTitle)
                            end
                        else
                            self:SetObjectiveDBValue(info[#info], value, objectiveTitle)
                        end

                        addon:UpdateButtons()
                    end,
                },
            },
        },
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
                    func = function()
                        self:DuplicateObjective(objectiveTitle)
                    end,
                },
                exportObjective = {
                    order = 2,
                    type = "execute",
                    name = L["Export Objective"],
                    disabled = true,
                    func = function()

                    end,
                },
                DeleteObjectiveTemplate = {
                    order = 3,
                    type = "execute",
                    name = L["Delete Objective"],
                    func = function()
                        self:DeleteObjectiveTemplate(objectiveTitle)
                        ACD:SelectGroup(addonName, "objectiveBuilder")
                    end,
                    confirm = function()
                        return format(L.Options_ObjectiveBuilder("objective.manage.DeleteObjectiveTemplate_confirm"), objectiveTitle)
                    end,
                },
            },
        },
    }

    return options
end

function addon:GetObjectiveBuilderOptions_Trackers(objectiveTitle, trackerKey)
    local objectiveInfo = self:GetDBValue("global", "objectives")[objectiveTitle]
    local trackers = objectiveInfo.trackers
    local trackerInfo = trackers[trackerKey]
    local trackerType, trackerID = self:ParseTrackerKey(trackerKey)

    local options = {
        order = trackerInfo.order,
        type = "group",
        name = trackerKey,
        -- name = "", --! add back after fixing below
        args = {
            title = {
                order = 1,
                type = "description",
                name = tostring(trackerID),
                -- name = "", --! add back after fixing below
                width = "full",
                imageWidth = 20,
                imageHeight = 20,
                fontSize = "medium",
            },
            order = {
                order = 2,
                type = "input",
                width = "full",
                name = L["Order"],
                get = function(info)
                    return tostring(self:GetTrackerDBInfo(trackers, trackerKey, info[#info]))
                end,
                validate = function(_, value)
                    value = tonumber(value) or 0
                    return value > 0
                end,
                set = function(info, value)
                    self:SetTrackerDBValue(trackers, trackerKey, info[#info], tonumber(value))
                    addon:UpdateButtons()
                end,
            },

            objective = {
                order = 3,
                type = "input",
                width = "full",
                name = L["Objective"],
                get = function(info)
                    return tostring(self:GetTrackerDBInfo(trackers, trackerKey, info[#info]))
                end,
                validate = function(_, value)
                    value = tonumber(value) or 0
                    return value > 0
                end,
                set = function(info, value)
                    self:SetTrackerDBValue(trackers, trackerKey, info[#info], tonumber(value))
                    addon:UpdateButtons()
                end,
            },
            countsFor = {
                order = 4,
                type = "input",
                width = "full",
                name = L["Counts For"],
                get = function(info)
                    return tostring(self:GetTrackerDBInfo(trackers, trackerKey, info[#info]))
                end,
                validate = function(_, value)
                    value = tonumber(value) or 0
                    return value > 0
                end,
                set = function(info, value)
                    self:SetTrackerDBValue(trackers, trackerKey, info[#info], tonumber(value))
                    addon:UpdateButtons()
                end,
            },
            deleteTracker = {
                order = 5,
                type = "execute",
                width = "full",
                name = L["Delete Tracker"],
                func = function()
                    self:DeleteTracker(trackers, trackerKey, objectiveInfo.instances)
                end,
                confirm = function(...)
                    return L.Options_ObjectiveBuilder("tracker.deleteTracker")
                end,
            },
        },
    }

    if trackerType == "ITEM" then
        self.CacheItem(trackerID, function(itemID)
            options.name = GetItemInfo(itemID)
            options.args.title.name = self.ColorFontString(GetItemInfo(itemID), "gold")
        end, trackerID)
        options.icon = C_Item.GetItemIconByID(trackerID)
        options.args.title.image = C_Item.GetItemIconByID(trackerID)
    else
        local currency = C_CurrencyInfo.GetCurrencyInfo(trackerID)
        options.name = currency.name
        options.args.title.name = self.ColorFontString(currency.name, "gold")
        options.icon = currency.iconFileID
        options.args.title.image = currency.iconFileID
    end

    return options
end
