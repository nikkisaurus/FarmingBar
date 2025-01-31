local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)
local AceGUI = LibStub("AceGUI-3.0")
local LibDeflate = LibStub("LibDeflate")

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
            -- Create frame
            local exportFrame = AceGUI:Create("Frame")
            exportFrame:SetTitle(L.addonName .. " - " .. L["Export Frame"])
            exportFrame:SetLayout("Fill")
            exportFrame:SetCallback("OnClose", function(self)
                self:Release()
                private:LoadOptions()
            end)

            local editbox = AceGUI:Create("MultiLineEditBox")
            editbox:SetLabel(objectiveTitle)
            editbox:DisableButton(true)
            exportFrame:AddChild(editbox)

            -- Hide options
            private:CloseOptions()
            exportFrame:Show()

            -- Populate editbox
            local serialized = LibStub("LibSerialize"):Serialize(objectiveTemplate)
            local compressed = LibDeflate:CompressDeflate(serialized)
            local encoded = LibDeflate:EncodeForPrint(compressed)

            editbox:SetText(encoded)
            editbox:SetFocus()
            editbox:HighlightText()
        end,

        icon = function(_, mouseButton)
            if mouseButton == "LeftButton" then
                private:PickupObjectiveTemplate(objectiveTemplateName)
            end
        end,

        newTrackerID = function(_, value)
            local pendingTrackerType = private.status.options.objectiveTemplates.newTrackerType
            local validID = private:ValidateTracker(objectiveTemplateName, pendingTrackerType, value)
            local trackerKey = private:AddObjectiveTracker(objectiveTemplateName, pendingTrackerType, validID)

            private:RefreshOptions("objectiveTemplates", objectiveTemplateName, "trackers", "tracker" .. trackerKey)
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
                    name = objectiveTemplate.title,
                    desc = L["Left-click to pickup this objective."],
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
                    name = L["Icon"],
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
                    desc = L["Set the ID or path of the icon texture."],
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

                iconSelector = {
                    order = 4,
                    type = "execute",
                    name = L["Choose"],
                    hidden = function()
                        return objectiveTemplate.icon.type == "AUTO"
                    end,
                    func = function()
                        private:CloseOptions()
                        local selectorFrame = AceGUI:Create("FarmingBar_IconSelector")
                        selectorFrame:LoadObjective(objectiveTemplateName)
                        selectorFrame:SetCallback("OnClose", function(self, _, iconID)
                            if iconID then
                                private.db.global.objectives[objectiveTemplateName].icon.id = iconID
                                private:RefreshOptions()
                            end
                            self:Release()
                            private:LoadOptions()
                        end)
                    end,
                },

                mute = {
                    order = 5,
                    type = "toggle",
                    name = L["Mute"],
                    desc = L["Mute alerts for this objective."],
                    get = function(info)
                        return objectiveTemplate.mute
                    end,
                    set = function(info, value)
                        private.db.global.objectives[objectiveTemplateName].mute = value
                    end,
                },

                onUse = {
                    order = 6,
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
                            name = objectiveTemplate.onUse.itemID and addon:CacheItem(objectiveTemplate.onUse.itemID, function(success, id)
                                if success then
                                    return (GetItemInfo(id))
                                end
                            end) or "",
                            image = function()
                                local itemID = objectiveTemplate.onUse.itemID
                                if not itemID then
                                    return ""
                                end

                                return GetItemIcon(itemID), 24, 24
                            end,
                            hidden = function()
                                return objectiveTemplate.onUse.type ~= "ITEM"
                            end,
                        },

                        type = {
                            order = 2,
                            type = "select",
                            name = L["Type"],
                            desc = L["Set the type of action performed when using this objective."],
                            values = private.lists.onUseType,
                            set = function(info, value)
                                private.db.global.objectives[objectiveTemplateName].onUse[info[#info]] = value
                                private:RefreshOptions()
                            end,
                        },

                        itemID = {
                            order = 3,
                            type = "input",
                            name = L["Item ID"],
                            desc = L["Set the ID of the item to use when using this objective."],
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
                            desc = L["Set the macrotext to be run when using this objective."],
                            hidden = function()
                                return objectiveTemplate.onUse.type ~= "MACROTEXT"
                            end,
                        },
                    },
                },

                duplicateObjectiveTemplate = {
                    order = 7,
                    type = "execute",
                    name = L["Duplicate"],
                    func = funcs.duplicateObjectiveTemplate,
                },

                exportObjectiveTemplate = {
                    order = 8,
                    type = "execute",
                    name = L["Export"],
                    func = funcs.exportObjectiveTemplate,
                },

                deleteObjectiveTemplate = {
                    order = 9,
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

                newTracker = {
                    order = 3,
                    type = "group",
                    inline = true,
                    name = L["Add Tracker"],
                    args = {
                        Type = {
                            order = 1,
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

                        id = {
                            order = 2,
                            type = "input",
                            name = L["Tracker ID"],
                            get = function()
                                return private.status.options.objectiveTemplates.newTrackerID
                            end,
                            set = funcs.newTrackerID,
                            validate = function(_, value)
                                return private:ValidateTracker(objectiveTemplateName, private.status.options.objectiveTemplates.newTrackerType, value)
                            end,
                        },
                    },
                },
            },
        },
    }

    local i = 4
    for trackerKey, tracker in addon:pairs(objectiveTemplate.trackers) do
        local trackerName, trackerIcon
        if tracker.type == "ITEM" then
            trackerName = GetItemInfo(tracker.id)
            trackerIcon = GetItemIcon(tracker.id)
        elseif tracker.type == "CURRENCY" then
            local currency = C_CurrencyInfo.GetCurrencyInfo(tracker.id)
            trackerName = currency and currency.name
            trackerIcon = currency and currency.iconFileID
        end

        options.trackers.args["tracker" .. trackerKey] = {
            order = i,
            type = "group",
            name = tracker.name ~= "" and tracker.name or L["Tracker"] .. " " .. trackerKey,
            desc = function()
                return format("%s:%d", tracker.type, tracker.id)
            end,
            icon = trackerIcon or 134400,
            args = {
                trackerKey = {
                    order = 1,
                    type = "input",
                    name = L["Tracker Key"],
                    desc = L["Set the order of this tracker."],
                    get = function(info)
                        return tostring(trackerKey)
                    end,
                    set = function(info, value)
                        local newTrackerKey = private:UpdateTrackerKeys(objectiveTemplateName, trackerKey, tonumber(value))
                        private:RefreshOptions("objectiveTemplates", objectiveTemplateName, "trackers", "tracker" .. newTrackerKey)
                    end,
                },
                objective = {
                    order = 2,
                    type = "input",
                    name = L["Goal"],
                    desc = L["Set the amount of this tracker required to count toward one of this objective."],
                    get = function(info)
                        return tostring(tracker[info[#info]])
                    end,
                    set = function(info, value)
                        local objective = tonumber(value) or 1
                        objective = objective < 1 and 1 or objective

                        private.db.global.objectives[objectiveTemplateName].trackers[trackerKey][info[#info]] = objective
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
                        private.db.global.objectives[objectiveTemplateName].trackers[trackerKey]["include" .. info[#info]] = value
                    end,
                    args = {
                        Bank = {
                            order = 1,
                            type = "toggle",
                            name = L["Bank"],
                            desc = L["Include counts from the bank for this tracker."],
                        },
                        Warbank = {
                            order = 2,
                            type = "toggle",
                            name = L["Warbank"],
                            desc = L["Include counts from the warbank for this tracker."],
                            hidden = function()
                                return select(4, GetBuildInfo()) < 110000
                            end,
                        },
                        Alts = {
                            order = 3,
                            type = "toggle",
                            name = L["Alts"],
                            desc = L["Include counts from alts for this tracker."],
                            hidden = function()
                                return private:MissingDataStore()
                            end,
                        },
                        AllFactions = {
                            order = 4,
                            type = "toggle",
                            name = L["All Factions"],
                            desc = L["Include counts from all factions for this tracker."],
                            hidden = function()
                                return private:MissingDataStore()
                            end,
                        },
                        GuildBank = {
                            order = 5,
                            type = "multiselect",
                            name = L["Guild Bank"],
                            desc = L["Include counts from the selected guild bank(s) for this tracker."],
                            values = private:GetGuildsList(),
                            get = function(info, guildKey)
                                return tracker["include" .. info[#info]][guildKey]
                            end,
                            set = function(info, guildKey, value)
                                private.db.global.objectives[objectiveTemplateName].trackers[trackerKey].includeGuildBank[guildKey] = value
                            end,
                            disabled = function()
                                return addon:tcount(private:GetGuildsList()) == 0
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
                            desc = L["The ID of a tracker which is equivalent to this tracker."],
                            set = function(_, value)
                                local pendingAltIDType = private.status.options.objectiveTemplates.newAltIDType
                                addon:Cache(strlower(pendingAltIDType), value, function(success, id, private, objectiveTemplateName, pendingAltIDType, trackerKey)
                                    if success then
                                        local validID = private:ValidateTracker(objectiveTemplateName, pendingAltIDType, value)

                                        if private:ObjectiveTemplateTrackerAltIDExists(objectiveTemplateName, trackerKey, pendingAltIDType, validID) then
                                            addon:Print(L["Alt ID already exists for this tracker."])
                                            return
                                        elseif not validID then
                                            addon:Print(L["Invalid Alt ID"])
                                            return
                                        end

                                        private:AddObjectiveTrackerAltID(objectiveTemplateName, trackerKey, pendingAltIDType, validID)
                                        private:RefreshOptions()
                                    else
                                        addon:Print(L["Invalid Alt ID"])
                                    end
                                end, { private, objectiveTemplateName, pendingAltIDType, trackerKey })
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
                                    values[AltKey] = AltInfo.name ~= "" and AltInfo.name or L["Alt ID"] .. " " .. AltKey
                                end

                                return values
                            end,
                            set = function(_, value)
                                private.db.global.objectives[objectiveTemplateName].trackers[trackerKey].altIDs[value] = nil
                                private:RefreshOptions()
                            end,
                            confirm = function(_, value)
                                local AltInfo = tracker.altIDs[value]

                                return format(L["Are you sure you want to remove %s from the tracker \"%s\"?"], AltInfo.name or L["Alt ID"] .. " " .. value, trackerName or L["Tracker"] .. " " .. trackerKey)
                            end,
                            disabled = function()
                                return addon:tcount(tracker.altIDs) == 0
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
                        return format(L["Are you sure you want to remove %s from %s?"], private:GetTrackerInfo(tracker.type, tracker.id), objectiveTemplateName)
                    end,
                },
            },
        }

        local I = 1
        for altKey, altInfo in addon:pairs(tracker.altIDs) do
            local _, altIDIcon = private:GetTrackerInfo(altInfo.type, altInfo.id)

            options.trackers.args["tracker" .. trackerKey].args.altIDs.args.altIDsList.args["altID" .. altKey] = {
                order = I,
                type = "description",
                width = 3 / 2,
                name = altInfo.name ~= "" and altInfo.name or L["Alt ID"] .. " " .. altKey,
                image = altIDIcon or 134400,
                imageWidth = 20,
                imageHeight = 20,
            }

            options.trackers.args["tracker" .. trackerKey].args.altIDs.args.altIDsList.args["altID" .. altKey .. "Multiplier"] = {
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
                            multiplier = num / den
                        else
                            multiplier = 1
                        end
                    else
                        multiplier = tonumber(value) or 1
                    end

                    multiplier = multiplier > 0 and multiplier or 1

                    private.db.global.objectives[objectiveTemplateName].trackers[trackerKey].altIDs[altKey].multiplier = multiplier
                end,
            }
            I = I + 2
        end
        i = i + 1
    end

    return options
end
