local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)
local ACD = LibStub("AceConfigDialog-3.0")
local AceGUI = LibStub("AceGUI-3.0")

function private:CloseObjectiveEditor()
    ACD:Close(addonName .. "ObjectiveEditor")
end

function private:GetObjectiveEditor()
    private.editor = {
        type = "group",
        name = private:GetObjectiveEditorName(),
        childGroups = "tab",
        args = {
            general = {
                order = 1,
                type = "group",
                name = L["General"],
                args = private:GetObjectiveEditorGeneralContent(widget),
            },
            trackers = {
                order = 2,
                type = "group",
                name = L["Trackers"],
                args = private:GetObjectiveEditorTrackersContent(widget),
            },
        },
    }

    return private.editor
end

function private:GetObjectiveEditorGeneralContent(widget)
    if not widget then
        return {}
    end

    local _, buttonDB = widget:GetDB()
    local barID, buttonID = widget:GetID()

    local args = {
        icon = {
            order = 1,
            type = "execute",
            dialogControl = "FarmingBar_Icon",
            image = private:GetObjectiveIcon(buttonDB),
            width = 0.25,
            name = buttonDB.title,
        },

        title = {
            order = 2,
            type = "input",
            width = 2,
            name = L["Name"],
            get = function(info)
                return buttonDB[info[#info]]
            end,
            set = function(info, value)
                widget:SetDBValue(info[#info], value)
            end,
        },

        iconType = {
            order = 3,
            type = "select",
            name = L["Icon"],
            values = private.lists.iconType,
            get = function(info)
                return buttonDB.icon.type
            end,
            set = function(info, value)
                widget:SetDBValue("icon", "type", value)
                private:RefreshObjectiveEditor(widget)
                widget:SetIconTextures()
            end,
        },

        iconID = {
            order = 3,
            type = "input",
            name = L["Icon ID"],
            desc = L["Set the ID or path of the icon texture."],
            hidden = function()
                return buttonDB.icon.type == "AUTO"
            end,
            get = function(info)
                return tostring(buttonDB.icon.id)
            end,
            set = function(info, value)
                widget:SetDBValue("icon", "id", tonumber(value) or 134400)
                private:RefreshObjectiveEditor(widget)
                widget:SetIconTextures()
            end,
        },

        iconSelector = {
            order = 4,
            type = "execute",
            name = L["Choose"],
            hidden = function()
                return buttonDB.icon.type == "AUTO"
            end,
            func = function()
                private:CloseObjectiveEditor()
                local selectorFrame = AceGUI:Create("FarmingBar_IconSelector")
                selectorFrame:LoadObjective(widget)
                selectorFrame:SetCallback("OnClose", function(self, _, iconID)
                    if iconID then
                        widget:SetDBValue("icon", "id", iconID)
                        private:RefreshObjectiveEditor(widget)
                        widget:SetIconTextures()
                    end
                    self:Release()
                    private:LoadObjectiveEditor(widget)
                end)
                selectorFrame:SetCallback("OnHide", function()
                    private:LoadObjectiveEditor(widget)
                end)
            end,
        },

        mute = {
            order = 5,
            type = "toggle",
            name = L["Mute"],
            desc = L["Mute alerts for this button."],
            get = function(info)
                return buttonDB.mute
            end,
            set = function(info, value)
                widget:SetDBValue("mute", value)
            end,
        },

        onUse = {
            order = 6,
            type = "group",
            inline = true,
            name = L["OnUse"],
            get = function(info)
                return buttonDB.onUse[info[#info]]
            end,
            set = function(info, value)
                widget:SetDBValue("onUse", info[#info], value)
                widget:SetAttributes()
            end,
            args = {
                itemPreview = {
                    order = 1,
                    type = "description",
                    name = function()
                        local itemID = buttonDB.onUse.itemID
                        if not itemID then
                            return ""
                        end

                        private:CacheItem(itemID)

                        return (GetItemInfo(itemID))
                    end,
                    image = function()
                        local itemID = buttonDB.onUse.itemID
                        if not itemID then
                            return ""
                        end

                        private:CacheItem(itemID)

                        return select(10, GetItemInfo(itemID)), 24, 24
                    end,
                    hidden = function()
                        return buttonDB.onUse.type ~= "ITEM"
                    end,
                },

                type = {
                    order = 2,
                    type = "select",
                    name = L["Type"],
                    desc = L["Set the type of action performed when using this objective."],
                    values = private.lists.onUseType,
                    set = function(info, value)
                        widget:SetDBValue("onUse", info[#info], value)
                        private:RefreshObjectiveEditor(widget)
                        widget:SetAttributes()
                    end,
                },

                itemID = {
                    order = 3,
                    type = "input",
                    name = L["Item ID"],
                    desc = L["Set the ID of the item to use when using this objective."],
                    hidden = function()
                        return buttonDB.onUse.type ~= "ITEM"
                    end,
                    get = function(info)
                        local itemID = buttonDB.onUse[info[#info]]
                        return itemID and tostring(itemID) or ""
                    end,
                    set = function(info, value)
                        widget:SetDBValue("onUse", info[#info], tonumber(value))
                        private:RefreshObjectiveEditor(widget)
                        widget:SetAttributes()
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
                        return buttonDB.onUse.type ~= "MACROTEXT"
                    end,
                },
            },
        },

        clear = {
            order = 7,
            type = "execute",
            name = L["Clear"],
            func = function()
                widget:Clear()
                private:CloseObjectiveEditor()
            end,
            confirm = function()
                return L["Are you sure you want to clear this button?"]
            end,
        },

        saveTemplate = {
            order = 8,
            type = "execute",
            name = L["Save as Template"],
            func = function()
                local newObjectiveTitle = private:AddObjectiveTemplate(buttonDB)
                private:CloseObjectiveEditor()
                private:LoadOptions("objectiveTemplates", newObjectiveTitle)
            end,
        },

        applyTemplate = {
            order = 9,
            type = "select",
            style = "dropdown",
            name = L["Apply Objective Template"],
            values = function()
                local values = {}

                for templateName, _ in pairs(private.db.global.objectives) do
                    values[templateName] = templateName
                end

                return values
            end,
            set = function(_, value)
                widget:SetObjectiveInfo(addon.CloneTable(private.db.global.objectives[value]))
                private:RefreshObjectiveEditor(widget)
            end,
            confirm = function(_, value)
                return format(
                    L["Are you sure you want to overwrite Bar %d Button %d with objective template \"%s\"?"],
                    barID,
                    buttonID,
                    value
                )
            end,
            disabled = function()
                return addon.tcount(private.db.global.objectives) == 0
            end,
        },
    }

    return args
end

function private:GetObjectiveEditorName(widget)
    local name = L.addonName .. " " .. L["Objective Editor"]

    if not widget then
        return name
    end

    local barID, buttonID = widget:GetID()

    return format("%s (%d:%d)", name, barID, buttonID)
end

function private:GetObjectiveEditorTrackersContent(widget)
    if not widget then
        return {}
    end

    local _, buttonDB = widget:GetDB()
    local barID, buttonID = widget:GetID()

    local args = {
        conditionType = {
            order = 1,
            type = "select",
            name = L["Condition"],
            values = private.lists.conditionType,
            get = function(info)
                return buttonDB.condition.type
            end,
            set = function(info, value)
                widget:SetDBValue("condition", "type", value)
                widget:SetCount()
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
                return buttonDB.condition.type ~= "CUSTOM"
            end,
            get = function(info)
                return buttonDB.condition.func
            end,
            set = function(info, value)
                widget:SetDBValue("condition", "func", value)
                widget:SetCount()
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
                        return private.status.objectiveEditor.newTrackerType
                    end,
                    set = function(_, value)
                        private.status.objectiveEditor.newTrackerType = value
                    end,
                },

                newTrackerID = {
                    order = 3,
                    type = "input",
                    name = L["Tracker ID"],
                    get = function()
                        return private.status.objectiveEditor.newTrackerID
                    end,
                    set = function(_, value)
                        local pendingTrackerType = private.status.objectiveEditor.newTrackerType
                        local validID = private:ValidateTracker(widget, pendingTrackerType, value)
                        local trackerKey = widget:AddTracker(pendingTrackerType, validID)

                        widget:SetCount()
                        private:RefreshObjectiveEditor(widget, "trackers", "trackersList", "tracker" .. trackerKey)
                    end,
                    validate = function(_, value)
                        return private:ValidateTracker(widget, private.status.objectiveEditor.newTrackerType, value)
                    end,
                },
            },
        },
    }

    local i = 4
    for trackerKey, tracker in addon.pairs(buttonDB.trackers) do
        local trackerName, trackerIcon = private:GetTrackerInfo(tracker.type, tracker.id)

        args.trackersList.args["tracker" .. trackerKey] = {
            order = i,
            type = "group",
            name = trackerName or L["Tracker"] .. " " .. trackerKey,
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
                        local newTrackerKey = widget:UpdateTrackerKeys(trackerKey, tonumber(value))
                        private:RefreshObjectiveEditor(widget, "trackers", "trackersList", "tracker" .. newTrackerKey)
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

                        widget:SetTrackerDBValue(trackerKey, info[#info], objective)
                        widget:SetCount()
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
                        widget:SetTrackerDBValue(trackerKey, "include" .. info[#info], value)
                        widget:SetCount()
                    end,
                    args = {
                        Bank = {
                            order = 1,
                            type = "toggle",
                            name = L["Bank"],
                            desc = L["Include counts from the bank for this tracker."],
                        },
                        Alts = {
                            order = 2,
                            type = "toggle",
                            name = L["Alts"],
                            desc = L["Include counts from alts for this tracker."],
                            hidden = function()
                                return private:MissingDataStore()
                            end,
                        },
                        GuildBank = {
                            order = 2,
                            type = "multiselect",
                            name = L["Guild Bank"],
                            desc = L["Include counts from the selected guild bank(s) for this tracker."],
                            values = private:GetGuildsList(),
                            get = function(info, guildKey)
                                return tracker["include" .. info[#info]][guildKey]
                            end,
                            set = function(info, guildKey, value)
                                widget:SetTrackerDBValue(trackerKey, "includeGuildBank", guildKey, value)
                                widget:SetCount()
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
                                return private.status.objectiveEditor.newAltIDType
                            end,
                            set = function(_, value)
                                private.status.objectiveEditor.newAltIDType = value
                            end,
                        },
                        newAltID = {
                            order = 2,
                            type = "input",
                            name = L["Alt ID"],
                            desc = L["The ID of a tracker which is equivalent to this tracker."],
                            set = function(_, value)
                                local pendingAltIDType = private.status.objectiveEditor.newAltIDType
                                local validID = private:ValidateTracker(widget, pendingAltIDType, value)

                                widget:AddTrackerAltID(trackerKey, pendingAltIDType, validID)
                                widget:SetCount()
                                private:RefreshObjectiveEditor(widget)
                            end,
                            validate = function(_, value)
                                local pendingAltIDType = private.status.objectiveEditor.newAltIDType
                                local validID = private:ValidateTracker(widget, pendingAltIDType, value)

                                if widget:TrackerAltIDExists(trackerKey, pendingAltIDType, validID) then
                                    return L["Alt ID already exists for this tracker."]
                                end

                                return private:ValidateTracker(
                                    widget,
                                    private.status.objectiveEditor.newAltIDType,
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
                                private.db.profile.bars[barID].buttons[buttonID].trackers[trackerKey].altIDs[value] =
                                    nil
                                widget:SetCount()
                                private:RefreshObjectiveEditor(widget)
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
                        private.db.profile.bars[barID].buttons[buttonID].trackers[trackerKey] = nil
                        widget:SetCount()
                        private:RefreshObjectiveEditor(widget)
                    end,
                    confirm = function(_)
                        return format(
                            L["Are you sure you want to remove %s from %s?"],
                            private:GetTrackerInfo(tracker.type, tracker.id),
                            buttonDB.title
                        )
                    end,
                },
            },
        }

        local I = 1
        for altKey, altInfo in addon.pairs(tracker.altIDs) do
            local altIDName, altIDIcon = private:GetTrackerInfo(altInfo.type, altInfo.id)

            args.trackersList.args["tracker" .. trackerKey].args.altIDs.args.altIDsList.args["altID" .. altKey] = {
                order = I,
                type = "description",
                width = 3 / 2,
                name = altIDName or L["Alt ID"] .. " " .. altKey,
                image = altIDIcon or 134400,
                imageWidth = 20,
                imageHeight = 20,
            }

            args.trackersList.args["tracker" .. trackerKey].args.altIDs.args.altIDsList.args["altID" .. altKey .. "Multiplier"] =
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

                        private.db.profile.bars[barID].buttons[buttonID].trackers[trackerKey].altIDs[altKey].multiplier =
                            multiplier
                        widget:SetCount()
                    end,
                }

            I = I + 2
        end
        i = i + 1
    end

    return args
end

function private:LoadObjectiveEditor(widget, ...)
    private:SelectObjectiveEditorPath(...)
    ACD:Open(addonName .. "ObjectiveEditor")
    private:RefreshObjectiveEditor(widget)
end

function private:RefreshObjectiveEditor(widget, ...)
    if private.editor then
        private.editor.name = private:GetObjectiveEditorName(widget)
        private.editor.args.general.args = private:GetObjectiveEditorGeneralContent(widget)
        private.editor.args.trackers.args = private:GetObjectiveEditorTrackersContent(widget)
    end

    if ... then
        private:SelectObjectiveEditorPath(...)
    end

    private:NotifyChange()
end

function private:SelectObjectiveEditorPath(...)
    ACD:SelectGroup(addonName .. "ObjectiveEditor", ...)
end
