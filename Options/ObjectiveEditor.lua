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
    local args = {}

    if buttonDB then
        args.icon = {
            order = 1,
            type = "execute",
            dialogControl = "FarmingBar_Icon",
            image = private:GetObjectiveIcon(buttonDB),
            width = 0.25,
            name = buttonDB.title,
        }

        args.title = {
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
        }

        args.iconType = {
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
        }

        args.iconID = {
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
        }

        args.iconSelector = {
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
        }

        args.mute = {
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
        }

        args.onUse = {
            order = 6,
            type = "group",
            inline = true,
            name = L["OnUse"],
            get = function(info)
                return buttonDB.onUse[info[#info]]
            end,
            set = function(info, value)
                widget:SetDBValue("onUse", info[#info], value)
                widget:UpdateAttributes()
            end,
            args = {
                itemPreview = {
                    order = 1,
                    type = "description",
                    name = buttonDB.onUse.itemID and addon:CacheItem(buttonDB.onUse.itemID, function(success, id)
                        if success then
                            local name
                            if private:GetGameVersion() < 110000 then
                                name = GetItemInfo(id)
                            else
                                name = (format("%s |A:Professions-Icon-Quality-Tier%d-Inv:20:20|a", GetItemInfo(id), C_TradeSkillUI.GetItemReagentQualityByItemInfo(id)))
                            end
                            return name
                        end
                    end) or "",
                    image = function()
                        local itemID = buttonDB.onUse.itemID
                        if not itemID then
                            return ""
                        end

                        return C_Item.GetItemIconByID(itemID), 24, 24
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
                        widget:UpdateAttributes()
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
                        widget:SetDBValue("onUse", info[#info], tonumber(value) or tonumber(string.match(value, "item:(%d+)")))
                        private:RefreshObjectiveEditor(widget)
                        widget:UpdateAttributes()
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
        }

        args.clear = {
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
        }

        args.saveTemplate = {
            order = 8,
            type = "execute",
            name = L["Save as Template"],
            func = function()
                local newObjectiveTitle = private:AddObjectiveTemplate(buttonDB)
                private:CloseObjectiveEditor()
                private:LoadOptions("objectiveTemplates", newObjectiveTitle)
            end,
        }
    end

    args.applyTemplate = {
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
            widget:SetObjectiveInfo(addon:CloneTable(private.db.global.objectives[value]))
            private:RefreshObjectiveEditor(widget)
        end,
        confirm = function(_, value)
            return format(L["Are you sure you want to overwrite Bar %d Button %d with objective template \"%s\"?"], barID, buttonID, value)
        end,
        disabled = function()
            return addon:tcount(private.db.global.objectives) == 0
        end,
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

    if not buttonDB then
        return {}
    end

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

        newTracker = {
            order = 3,
            type = "group",
            inline = true,
            name = L["Add Tracker"],
            args = {
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
                        local trackerKey = private:AddObjectiveTracker(widget, pendingTrackerType, validID)

                        widget:SetCount()
                        private:RefreshObjectiveEditor(widget, "trackers", "tracker" .. trackerKey)
                    end,
                    validate = function(_, value)
                        return private:ValidateTracker(widget, private.status.objectiveEditor.newTrackerType, value)
                    end,
                },
            },
        },
    }

    local i = 4
    for trackerKey, tracker in addon:pairs(buttonDB.trackers) do
        local trackerName, trackerIcon = private:GetTrackerInfo(tracker.type, tracker.id)

        local name
        if private:GetGameVersion() < 110000 then
            name = tracker.name ~= "" and tracker.name or L["Tracker"] .. " " .. trackerKey
        else
            name = format("%s |A:Professions-Icon-Quality-Tier%d-Inv:20:20|a", tracker.name ~= "" and tracker.name or L["Tracker"] .. " " .. trackerKey, C_TradeSkillUI.GetItemReagentQualityByItemInfo(tracker.id))
        end

        args["tracker" .. trackerKey] = {
            order = i,
            type = "group",
            name = name,
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
                        private:RefreshObjectiveEditor(widget, "trackers", "tracker" .. newTrackerKey)
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
                        Warbank = {
                            order = 2,
                            type = "toggle",
                            name = L["Warbank"],
                            desc = L["Include counts from the warbank for this tracker."],
                            hidden = function()
                                return private:GetGameVersion() < 110000
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
                                widget:SetTrackerDBValue(trackerKey, "includeGuildBank", guildKey, value)
                                widget:SetCount()
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

                                addon:Cache(strlower(pendingAltIDType), value, function(success, id, private, widget, pendingAltIDType, trackerKey)
                                    if success then
                                        local validID = private:ValidateTracker(widget, pendingAltIDType, id)
                                        validID = validID == L["Tracker already exists for this objective."] and id or validID

                                        if widget:TrackerAltIDExists(trackerKey, pendingAltIDType, validID) then
                                            addon:Print(private.defaultChatFrame, L["Alt ID already exists for this tracker."])
                                            return
                                        elseif not validID then
                                            addon:Print(private.defaultChatFrame, L["Invalid Alt ID"])
                                            return
                                        end

                                        widget:AddTrackerAltID(trackerKey, pendingAltIDType, validID)
                                        widget:SetCount()
                                        private:RefreshObjectiveEditor(widget)
                                    else
                                        addon:Print(private.defaultChatFrame, L["Invalid Alt ID"])
                                    end
                                end, { private, widget, pendingAltIDType, trackerKey })
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
                                private.db.profile.bars[barID].buttons[buttonID].trackers[trackerKey].altIDs[value] = nil
                                widget:SetCount()
                                private:RefreshObjectiveEditor(widget)
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
                        private.db.profile.bars[barID].buttons[buttonID].trackers[trackerKey] = nil
                        widget:SetCount()
                        private:RefreshObjectiveEditor(widget)
                    end,
                    confirm = function(_)
                        return format(L["Are you sure you want to remove %s from %s?"], private:GetTrackerInfo(tracker.type, tracker.id), buttonDB.title)
                    end,
                },
            },
        }

        local I = 1
        for altKey, altInfo in addon:pairs(tracker.altIDs) do
            local _, altIDIcon = private:GetTrackerInfo(altInfo.type, altInfo.id)

            local name
            if private:GetGameVersion() < 110000 then
                name = altInfo.name ~= "" and altInfo.name or L["Alt ID"] .. " " .. altKey
            else
                name = format("%s |A:Professions-Icon-Quality-Tier%d-Inv:20:20|a", altInfo.name ~= "" and altInfo.name or L["Alt ID"] .. " " .. altKey, C_TradeSkillUI.GetItemReagentQualityByItemInfo(altInfo.id))
            end

            args["tracker" .. trackerKey].args.altIDs.args.altIDsList.args["altID" .. altKey] = {
                order = I,
                type = "description",
                width = 3 / 2,
                name = name,
                image = altIDIcon or 134400,
                imageWidth = 20,
                imageHeight = 20,
            }

            args["tracker" .. trackerKey].args.altIDs.args.altIDsList.args["altID" .. altKey .. "Multiplier"] = {
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

                    private.db.profile.bars[barID].buttons[buttonID].trackers[trackerKey].altIDs[altKey].multiplier = multiplier
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
        private.editor.widget = widget
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
