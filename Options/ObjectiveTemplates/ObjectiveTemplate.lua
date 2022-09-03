local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)

private.lists = {
    conditionType = {
        ALL = L["All"],
        ANY = L["Any"],
        CUSTOM = L["Custom"],
    },

    iconType = {
        AUTO = L["Auto"],
        FALLBACK = L["Fallback"],
    },

    onUseType = {
        ITEM = L["Item"],
        NONE = L["None"],
        MACROTEXT = L["Macrotext"],
    },

    newTrackerType = {
        ITEM = L["Item"],
        CURRENCY = L["Currency"],
    },

    modifiers = {
        alt = L["Alt"],
        ctrl = L["Control"],
        shift = L["Shift"],
    },

    Modifiers = {
        Alt = L["Alt"],
        Control = L["Control"],
        Shift = L["Shift"],
    },

    mouseButtons = {
        LeftButton = L["Left Button"],
        RightButton = L["Right Button"],
    },
}

function private:GetObjectiveTemplateOptions(objectiveTemplateName)
    local objectiveTemplate = private.db.global.objectives[objectiveTemplateName]

    local funcs = {
        deleteObjectiveTemplate = function()
            private:DeleteObjectiveTemplate(objectiveTemplateName)
            private:RefreshOptions("objectiveTemplates")
        end,

        deleteObjectiveTemplate_Confirm = function()
            return format(L["Are you sure you want to delete the objective template \"%s\"?"], objectiveTemplateName)
        end,

        duplicateObjectiveTemplate = function()
            local newObjectiveTemplateName = private:DuplicateObjectiveTemplate(objectiveTemplateName)
            private:SelectOptionsPath("objectiveTemplates", newObjectiveTemplateName)
        end,

        exportObjectiveTemplate = function()
            print("Export")
        end,

        icon = function(_, mouseButton)
            if mouseButton == "LeftButton" then
                private:PickupObjectiveTemplate(objectiveTemplateName)
            end
        end,

        newTrackerID = function(_, value)
            local pendingTrackerType = private.status.options.objectiveTemplates.newTrackerType
            local validID = private:ValidateTracker(objectiveTemplateName, pendingTrackerType, value)
            local trackerKey = private:AddObjectiveTemplateTracker(objectiveTemplateName, pendingTrackerType, validID)

            private:RefreshOptions(
                "objectiveTemplates",
                objectiveTemplateName,
                "trackers",
                "trackersList",
                "tracker" .. trackerKey
            )
        end,

        title = function(_, value)
            local newObjectiveTemplateName = private:RenameObjectiveTemplate(objectiveTemplateName, value)
            private:RefreshOptions("objectiveTemplates", newObjectiveTemplateName)
        end,
    }

    local options = {
        general = {
            order = 1,
            type = "group",
            name = L["General"],
            args = {
                icon = {
                    order = 1,
                    type = "execute",
                    dialogControl = "FarmingBar_Icon",
                    image = private:GetObjectiveIcon(objectiveTemplate),
                    width = 0.25,
                    name = " ",
                    func = funcs.icon,
                },

                title = {
                    order = 2,
                    type = "input",
                    width = 2,
                    name = L["Name"],
                    get = function(info)
                        return objectiveTemplate[info[#info]]
                    end,
                    set = funcs.title,
                },

                iconType = {
                    order = 3,
                    type = "select",
                    name = L["Fallback Icon"],
                    values = private.lists.iconType,
                    get = function(info)
                        return objectiveTemplate.icon.type
                    end,
                    set = function(info, value)
                        private.db.global.objectives[objectiveTemplateName].icon.type = value
                        private:RefreshOptions()
                    end,
                },

                iconID = {
                    order = 3,
                    type = "input",
                    name = L["Icon ID"],
                    hidden = function()
                        return objectiveTemplate.icon.type == "AUTO"
                    end,
                    get = function(info)
                        return tostring(objectiveTemplate.icon.id)
                    end,
                    set = function(info, value)
                        private.db.global.objectives[objectiveTemplateName].icon.id = tonumber(value) or 134400
                        private:RefreshOptions()
                    end,
                },

                onUse = {
                    order = 4,
                    type = "group",
                    inline = true,
                    name = L["OnUse"],
                    get = function(info)
                        return objectiveTemplate.onUse[info[#info]]
                    end,
                    set = function(info, value)
                        private.db.global.objectives[objectiveTemplateName].onUse[info[#info]] = value
                    end,
                    args = {

                        itemPreview = {
                            order = 1,
                            type = "description",
                            name = function()
                                local itemID = objectiveTemplate.onUse.itemID
                                if not itemID then
                                    return ""
                                end

                                private:CacheItem(itemID)

                                return (GetItemInfo(itemID))
                            end,
                            image = function()
                                local itemID = objectiveTemplate.onUse.itemID
                                if not itemID then
                                    return ""
                                end

                                private:CacheItem(itemID)

                                return select(10, GetItemInfo(itemID)), 24, 24
                            end,
                            hidden = function()
                                return objectiveTemplate.onUse.type ~= "ITEM"
                            end,
                        },

                        type = {
                            order = 2,
                            type = "select",
                            name = L["Type"],
                            values = private.lists.onUseType,
                            set = function(info, value)
                                private.db.global.objectives[objectiveTemplateName].onUse[info[#info]] = value
                                private:RefreshOptions()
                            end,
                        },

                        itemID = {
                            order = 3,
                            type = "input",
                            name = L["ItemID"],
                            hidden = function()
                                return objectiveTemplate.onUse.type ~= "ITEM"
                            end,
                            get = function(info)
                                local itemID = objectiveTemplate.onUse[info[#info]]
                                return itemID and tostring(itemID) or ""
                            end,
                            set = function(info, value)
                                private.db.global.objectives[objectiveTemplateName].onUse[info[#info]] = tonumber(value)
                                private:RefreshOptions()
                            end,
                            validate = function(_, value)
                                return private:ValidateItem(value)
                            end,
                        },

                        macrotext = {
                            order = 3,
                            type = "input",
                            multiline = true,
                            width = "full",
                            name = L["Macrotext"],
                            hidden = function()
                                return objectiveTemplate.onUse.type ~= "MACROTEXT"
                            end,
                        },
                    },
                },

                duplicateObjectiveTemplate = {
                    order = 5,
                    type = "execute",
                    name = L["Duplicate"],
                    func = funcs.duplicateObjectiveTemplate,
                },

                exportObjectiveTemplate = {
                    order = 6,
                    type = "execute",
                    name = L["Export"],
                    func = funcs.exportObjectiveTemplate,
                },

                deleteObjectiveTemplate = {
                    order = 7,
                    type = "execute",
                    name = DELETE,
                    func = funcs.deleteObjectiveTemplate,
                    confirm = funcs.deleteObjectiveTemplate_Confirm,
                },
            },
        },

        trackers = {
            order = 2,
            type = "group",
            name = L["Trackers"],
            args = {
                conditionType = {
                    order = 1,
                    type = "select",
                    name = L["Condition"],
                    values = private.lists.conditionType,
                    get = function(info)
                        return objectiveTemplate.condition.type
                    end,
                    set = function(info, value)
                        private.db.global.objectives[objectiveTemplateName].condition.type = value
                    end,
                },

                conditionFunc = {
                    order = 2,
                    type = "input",
                    multiline = true,
                    dialogControl = "FarmingBar_LuaEditBox",
                    width = "full",
                    name = L["Custom Condition"],
                    hidden = function()
                        return objectiveTemplate.condition.type ~= "CUSTOM"
                    end,
                    get = function(info)
                        return objectiveTemplate.condition.func
                    end,
                    set = function(info, value)
                        private.db.global.objectives[objectiveTemplateName].condition.func = value
                    end,
                    validate = function(_, value)
                        return private:ValidateConditionFunc(value)
                    end,
                    arg = function(value)
                        return private:ValidateConditionFunc(value)
                    end,
                },

                trackersList = {
                    order = 3,
                    type = "group",
                    name = L["Trackers"],
                    args = {
                        newTrackerHeader = {
                            order = 1,
                            type = "header",
                            name = L["Add Tracker"],
                        },

                        newTrackerType = {
                            order = 2,
                            type = "select",
                            name = L["Tracker Type"],
                            values = private.lists.newTrackerType,
                            get = function()
                                return private.status.options.objectiveTemplates.newTrackerType
                            end,
                            set = function(_, value)
                                private.status.options.objectiveTemplates.newTrackerType = value
                            end,
                        },

                        newTrackerID = {
                            order = 3,
                            type = "input",
                            name = L["Tracker ID"],
                            get = function()
                                return private.status.options.objectiveTemplates.newTrackerID
                            end,
                            set = funcs.newTrackerID,
                            validate = function(_, value)
                                return private:ValidateTracker(
                                    objectiveTemplateName,
                                    private.status.options.objectiveTemplates.newTrackerType,
                                    value
                                )
                            end,
                        },
                    },
                },
            },
        },
    }

    local i = 4
    for trackerKey, tracker in addon.pairs(objectiveTemplate.trackers) do
        local trackerName, trackerIcon
        if tracker.type == "ITEM" then
            private:CacheItem()
            trackerName = GetItemInfo(tracker.id)
            trackerIcon = GetItemIcon(tracker.id)
        elseif tracker.type == "CURRENCY" then
            local currency = C_CurrencyInfo.GetCurrencyInfo(tracker.id)
            trackerName = currency and currency.name
            trackerIcon = currency and currency.iconFileID
        end

        options.trackers.args.trackersList.args["tracker" .. trackerKey] = {
            order = i,
            type = "group",
            name = trackerName or L["Tracker"] .. " " .. trackerKey,
            icon = trackerIcon or 134400,
            args = {
                trackerKey = {
                    order = 1,
                    type = "input",
                    name = L["Tracker Key"],
                    get = function(info)
                        return tostring(trackerKey)
                    end,
                    set = function(info, value)
                        local newTrackerKey =
                            private:UpdateTrackerKeys(objectiveTemplateName, trackerKey, tonumber(value))
                        private:RefreshOptions(
                            "objectiveTemplates",
                            objectiveTemplateName,
                            "trackers",
                            "trackersList",
                            "tracker" .. newTrackerKey
                        )
                    end,
                },
                objective = {
                    order = 2,
                    type = "input",
                    name = L["Objective"],
                    get = function(info)
                        return tostring(tracker[info[#info]])
                    end,
                    set = function(info, value)
                        local objective = tonumber(value) or 1
                        objective = objective < 1 and 1 or objective

                        private.db.global.objectives[objectiveTemplateName].trackers[trackerKey][info[#info]] =
                            objective
                    end,
                },
                include = {
                    order = 3,
                    type = "group",
                    inline = true,
                    name = L["Include"],
                    get = function(info)
                        return tracker["include" .. info[#info]]
                    end,
                    set = function(info, value)
                        private.db.global.objectives[objectiveTemplateName].trackers[trackerKey]["include" .. info[#info]] =
                            value
                    end,
                    args = {
                        Bank = {
                            order = 1,
                            type = "toggle",
                            name = L["Bank"],
                        },
                        Alts = {
                            order = 2,
                            type = "toggle",
                            name = L["Alts"],
                        },
                        GuildBank = {
                            order = 2,
                            type = "multiselect",
                            name = L["Guild Bank"],
                            values = private:GetGuildsList(),
                            get = function(info, guildKey)
                                return tracker["include" .. info[#info]][guildKey]
                            end,
                            set = function(info, guildKey, value)
                                private.db.global.objectives[objectiveTemplateName].trackers[trackerKey].includeGuildBank[guildKey] =
                                    value
                            end,
                            disabled = function()
                                return addon.tcount(private:GetGuildsList()) == 0
                            end,
                            hidden = function()
                                return private:MissingDataStore()
                            end,
                        },
                    },
                },
                altIDs = {
                    order = 4,
                    type = "group",
                    inline = true,
                    name = L["Alt IDs"],
                    args = {
                        newAltIDType = {
                            order = 1,
                            type = "select",
                            name = L["Type"],
                            values = private.lists.newTrackerType,
                            get = function()
                                return private.status.options.objectiveTemplates.newAltIDType
                            end,
                            set = function(_, value)
                                private.status.options.objectiveTemplates.newAltIDType = value
                            end,
                        },
                        newAltID = {
                            order = 2,
                            type = "input",
                            name = L["Alt ID"],
                            set = function(_, value)
                                local pendingAltIDType = private.status.options.objectiveTemplates.newAltIDType
                                local validID = private:ValidateTracker(objectiveTemplateName, pendingAltIDType, value)

                                private:AddObjectiveTemplateTrackerAltID(
                                    objectiveTemplateName,
                                    trackerKey,
                                    pendingAltIDType,
                                    validID
                                )

                                private:RefreshOptions()
                            end,
                            validate = function(_, value)
                                local pendingAltIDType = private.status.options.objectiveTemplates.newAltIDType
                                local validID = private:ValidateTracker(objectiveTemplateName, pendingAltIDType, value)

                                if
                                    private:ObjectiveTemplateTrackerAltIDExists(
                                        objectiveTemplateName,
                                        trackerKey,
                                        pendingAltIDType,
                                        validID
                                    )
                                then
                                    return L["Alt ID already exists for this tracker."]
                                end

                                return private:ValidateTracker(
                                    objectiveTemplateName,
                                    private.status.options.objectiveTemplates.newAltIDType,
                                    value
                                ) or L["Invalid Alt ID"]
                            end,
                        },
                        removeAltID = {
                            order = 3,
                            type = "select",
                            name = L["Remove Alt ID"],
                            width = "full",
                            values = function()
                                local values = {}

                                for AltKey, AltInfo in pairs(tracker.altIDs) do
                                    local altIDName = private:GetTrackerInfo(AltInfo.type, AltInfo.id)
                                    values[AltKey] = altIDName
                                end

                                return values
                            end,
                            set = function(_, value)
                                private.db.global.objectives[objectiveTemplateName].trackers[trackerKey].altIDs[value] =
                                    nil
                                private:RefreshOptions()
                            end,
                            confirm = function(_, value)
                                local AltInfo = tracker.altIDs[value]
                                local altIDName = private:GetTrackerInfo(AltInfo.type, AltInfo.id)

                                return format(
                                    L["Are you sure you want to remove %s from the tracker \"%s\"?"],
                                    altIDName,
                                    trackerName or L["Tracker"] .. " " .. trackerKey
                                )
                            end,
                            disabled = function()
                                return addon.tcount(tracker.altIDs) == 0
                            end,
                        },
                        altIDsList = {
                            order = 4,
                            type = "group",
                            inline = true,
                            name = "",
                            args = {},
                        },
                    },
                },

                removeTracker = {
                    order = 5,
                    type = "execute",
                    name = REMOVE,
                    func = function()
                        private:RemoveObjectiveTemplateTracker(objectiveTemplateName, trackerKey)
                        private:RefreshOptions()
                    end,
                    confirm = function(_)
                        return format(
                            L["Are you sure you want to remove %s from %s?"],
                            private:GetTrackerInfo(tracker.type, tracker.id),
                            objectiveTemplateName
                        )
                    end,
                },
            },
        }

        local I = 1
        for altKey, altInfo in addon.pairs(tracker.altIDs) do
            local altIDName, altIDIcon = private:GetTrackerInfo(altInfo.type, altInfo.id)

            options.trackers.args.trackersList.args["tracker" .. trackerKey].args.altIDs.args.altIDsList.args["altID" .. altKey] =
                {
                    order = I,
                    type = "description",
                    width = 3 / 2,
                    name = altIDName or L["Alt ID"] .. " " .. altKey,
                    image = altIDIcon or 134400,
                    imageWidth = 20,
                    imageHeight = 20,
                }

            options.trackers.args.trackersList.args["tracker" .. trackerKey].args.altIDs.args.altIDsList.args["altID" .. altKey .. "Multiplier"] =
                {
                    order = I + 1,
                    type = "input",
                    width = 1 / 2,
                    name = L["Multiplier"],
                    get = function()
                        return tostring(altInfo.multiplier)
                    end,
                    set = function(_, value)
                        local num, den = strsplit("/", value)
                        local multiplier

                        if den then
                            num = tonumber(num)
                            den = tonumber(den)
                            if num and den and den ~= 0 then
                                multiplier = addon.round(num / den, 3)
                            else
                                multiplier = 1
                            end
                        else
                            multiplier = tonumber(value) or 1
                        end

                        multiplier = multiplier > 0 and multiplier or 1

                        private.db.global.objectives[objectiveTemplateName].trackers[trackerKey].altIDs[altKey].multiplier =
                            multiplier
                    end,
                }

            I = I + 2
        end
        i = i + 1
    end

    return options
end

function private:GetTrackerInfo(Type, id)
    local name, icon
    if Type == "ITEM" then
        private:CacheItem()
        name = GetItemInfo(id)
        icon = GetItemIcon(id)
    elseif Type == "CURRENCY" then
        local currency = C_CurrencyInfo.GetCurrencyInfo(id)
        name = currency and currency.name
        icon = currency and currency.iconFileID
    end

    return name, icon
end
