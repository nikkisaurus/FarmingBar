local addonName = ...
local addon = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)


--*------------------------------------------------------------------------


local anchors = {
    TOPLEFT = L["Topleft"],
    TOP = L["Top"],
    TOPRIGHT = L["Topright"],
    LEFT = L["Left"],
    CENTER = L["Center"],
    RIGHT = L["Right"],
    BOTTOMLEFT = L["Bottomleft"],
    BOTTOM = L["Bottom"],
    BOTTOMRIGHT = L["Bottomright"],
}

local anchorSort = {"TOPLEFT", "TOP", "TOPRIGHT", "LEFT", "CENTER", "RIGHT", "BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT"}


--*------------------------------------------------------------------------
-- Get options

function addon:GetConfigOptions()
    local options = {
        bar0 = {
            order = 0,
            type = "group",
            name = L["All"],
            childGroups = "tab",
            args = {
                bar = {
                    order = 1,
                    type = "group",
                    name = L["Bar"],
                    args = self:GetBarConfigOptions(0)
                },
                button = {
                    order = 2,
                    type = "group",
                    name = L["Button"],
                    args = self:GetButtonConfigOptions(0)
                },
            },
        },
    }

    local bars = self:GetDBValue("profile", "bars")

    for barID, _ in pairs(bars) do
        options["bar"..barID] = {
            order = barID,
            type = "group",
            name = L["Bar"].." "..barID,
            childGroups = "tab",
            args = {
                bar = {
                    order = 1,
                    type = "group",
                    name = L["Bar"],
                    args = self:GetBarConfigOptions(barID),
                },
                button = {
                    order = 2,
                    type = "group",
                    name = L["Button"],
                    args = self:GetButtonConfigOptions(barID),
                },
            },
        }
    end

    return options
end


function addon:GetBarConfigOptions(barID)
    local options
    local bar = barID > 0 and self.bars[barID]

    if barID == 0 then -- Config all bars
        options = {
            manage = {
                order = 1,
                type = "group",
                inline = true,
                name = L["Manage"],
                args = {
                    ToggleBarDisabled = {
                        order = 1,
                        type = "select",
                        width = "full",
                        name = L["Toggle Bar Enabled"],
                        disabled = function()
                            return self.tcount(self.bars) == 0
                        end,
                        values = function()
                            local values = {}
                            local bars = self:GetDBValue("profile", "bars")

                            for barID, _ in pairs(bars) do
                                values[barID] = L["Bar"].." "..barID
                            end

                            return values
                        end,
                        sorting = function()
                            local sorting = {}
                            local bars = self:GetDBValue("profile", "bars")

                            for barID, _ in pairs(bars) do
                                tinsert(sorting, barID)
                            end

                            return sorting
                        end,
                        set = function(_, barID)
                            self:SetBarDisabled(barID, "_TOGGLE_")
                        end,
                    },
                    RemoveBar = {
                        order = 2,
                        type = "select",
                        width = "full",
                        name = L["Remove Bar"],
                        disabled = function()
                            return self.tcount(self.bars) == 0
                        end,
                        values = function()
                            local values = {}
                            local bars = self:GetDBValue("profile", "bars")

                            for barID, _ in pairs(bars) do
                                values[barID] = L["Bar"].." "..barID
                            end

                            return values
                        end,
                        sorting = function()
                            local sorting = {}
                            local bars = self:GetDBValue("profile", "bars")

                            for barID, _ in pairs(bars) do
                                tinsert(sorting, barID)
                            end

                            return sorting
                        end,
                        confirm = function(_, barID)
                            return format(L.ConfirmRemoveBar, barID)
                        end,
                        set = function(_, barID)
                            self:RemoveBar(barID)
                        end,
                    },
                    addBar = {
                        order = 3,
                        type = "execute",
                        width = "full",
                        name = L["Add Bar"],
                        func = function()
                            self:CreateBar()
                        end,
                    },
                },
            },
        }
    else -- Config barID
        options = {
            enabled = {
                order = 0,
                type = "toggle",
                width = "full",
                name = "Enabled",
                get = function()
                    return addon:GetBarDBValue("enabled", barID)
                end,
                set = function(_, value)
                    addon:SetBarDBValue("enabled", value, barID)
                    addon:SetBarDisabled(barID, value)
                end,
            },
            title = {
                order = 1,
                type = "input",
                width = "full",
                name = "*"..L["Title"],
                get = function()
                    return addon:GetBarDBValue("title", barID, true)
                end,
                set = function(_, value)
                    addon:SetBarDBValue("title", value, barID, true)
                end,
            },
            alerts = {
                order = 2,
                type = "group",
                inline = true,
                width = "full",
                name = "*"..L["Alerts"],
                get = function(info)
                    return addon:GetBarDBValue("alerts."..info[#info], barID, true)
                end,
                set = function(info, value)
                    addon:SetBarDBValue("alerts."..info[#info], value, barID, true)
                end,
                args = {
                    muteAll = {
                        order = 1,
                        type = "toggle",
                        name = L["Mute All"],
                    },
                    barProgress = {
                        order = 2,
                        type = "toggle",
                        name = L["Bar Progress"],
                        disabled = true,
                    },
                    completedObjectives = {
                        order = 3,
                        type = "toggle",
                        name = L["Completed Objectives"],
                        disabled = true,
                    },
                },
            },
            visibility = {
                order = 3,
                type = "group",
                inline = true,
                width = "full",
                name = L["Visibility"],
                get = function(info)
                    return addon:GetBarDBValue(info[#info], barID)
                end,
                set = function(info, value)
                    addon:SetBarDBValue(info[#info], value, barID)
                end,
                args = {
                    hidden = {
                        order = 1,
                        type = "toggle",
                        name = L["Hidden"],
                        set = function(info, value)
                            addon:SetBarDBValue(info[#info], value, barID)
                            bar:SetHidden()
                        end,
                    },
                    showEmpty = {
                        order = 2,
                        type = "toggle",
                        name = L["Show Empty Buttons"],
                    },
                    mouseover = {
                        order = 3,
                        type = "toggle",
                        name = L["Show on Mouseover"],
                    },
                    anchorMouseover = {
                        order = 4,
                        type = "toggle",
                        name = L["Show on Anchor Mouseover"],
                    },
                },
            },
            point = {
                order = 4,
                type = "group",
                inline = true,
                width = "full",
                name = L["Point"],
                args = {
                    growthDirection = {
                        order = 1,
                        type = "select",
                        name = L["Growth Direction"],
                        values = {
                            RIGHT = L["Right"],
                            LEFT = L["Left"],
                            UP = L["Up"],
                            DOWN = L["Down"],
                        },
                        sorting = {"RIGHT", "LEFT", "UP", "DOWN"},
                        get = function()
                            return addon:GetBarDBValue("grow", barID)[1]
                        end,
                        set = function(info, value)
                            addon:GetDBValue("profile", "bars")[barID].grow[1] = value
                            bar:AnchorButtons()
                        end,

                    },
                    growthType = {
                        order = 2,
                        type = "select",
                        name = L["Growth Direction"],
                        values = {
                            NORMAL = L["Normal"],
                            REVERSE = L["Reverse"],
                        },
                        sorting = {"NORMAL", "REVERSE"},
                        get = function()
                            return addon:GetBarDBValue("grow", barID)[2]
                        end,
                        set = function(info, value)
                            addon:GetDBValue("profile", "bars")[barID].grow[2] = value
                            bar:AnchorButtons()
                        end,

                    },
                    movable = {
                        order = 3,
                        type = "toggle",
                        name = L["Movable"],
                        get = function(info)
                            return addon:GetBarDBValue(info[#info], barID)
                        end,
                        set = function(info, value)
                            addon:SetBarDBValue(info[#info], value, barID)
                            bar:SetMovable()
                        end,
                    },
                },
            },
            style = {
                order = 5,
                type = "group",
                inline = true,
                width = "full",
                name = L["Style"],
                get = function(info)
                    return addon:GetBarDBValue(info[#info], barID)
                end,
                args = {
                    scale = {
                        order = 1,
                        type = "range",
                        name = L["Scale"],
                        min = self.minScale,
                        max = self.maxScale,
                        step = .01,
                        set = function(info, value)
                            addon:SetBarDBValue(info[#info], value, barID)
                            bar:SetScale()
                        end,
                    },
                    alpha = {
                        order = 2,
                        type = "range",
                        name = L["Alpha"],
                        min = 0,
                        max = 1,
                        step = .01,
                        set = function(info, value)
                            addon:SetBarDBValue(info[#info], value, barID)
                            bar:SetAlpha()
                        end,
                    },
                },
            },
            template = {
                order = 6,
                type = "group",
                inline = true,
                width = "full",
                name = "*"..L["Template"],
                args = {
                    title = {
                        order = 1,
                        type = "input",
                        name = L["Save as Template"],
                        set = function(_, value)
                            self:SaveTemplate(barID, value)
                        end,
                    },
                    builtinTemplate = {
                        order = 2,
                        type = "select",
                        name = L["Load Template"],
                        values = function()
                            local values = {}

                            for templateName, _ in self.pairs(self.templates) do
                                values[templateName] = templateName
                            end

                            return values
                        end,
                        sorting = function()
                            local sorting = {}

                            for templateName, _ in self.pairs(self.templates) do
                                tinsert(sorting, templateName)
                            end

                            return sorting
                        end,
                        set = function(_, templateName)
                            self:LoadTemplate(nil, barID, templateName)
                        end,
                    },
                    userTemplate = {
                        order = 2,
                        type = "select",
                        name = L["Load User Template"],
                        disabled = function()
                            return self.tcount(addon:GetDBValue("global", "templates")) == 0
                        end,
                        values = function()
                            local values = {}

                            for templateName, _ in self.pairs(addon:GetDBValue("global", "templates")) do
                                values[templateName] = templateName
                            end

                            return values
                        end,
                        sorting = function()
                            local sorting = {}

                            for templateName, _ in self.pairs(addon:GetDBValue("global", "templates")) do
                                tinsert(sorting, templateName)
                            end

                            return sorting
                        end,
                        set = function(_, templateName)
                            if addon:GetDBValue("global", "settings.misc.preserveTemplateData") == "PROMPT" then
                                local dialog = StaticPopup_Show("FARMINGBAR_INCLUDE_TEMPLATE_DATA", templateName)
                                if dialog then
                                    dialog.data = {barID, templateName}
                                end
                            else
                                if addon:GetDBValue("global", "settings.misc.preserveTemplateOrder") == "PROMPT" then
                                    local dialog = StaticPopup_Show("FARMINGBAR_SAVE_TEMPLATE_ORDER", templateName)
                                    if dialog then
                                        dialog.data = {barID, templateName, addon:GetDBValue("global", "settings.misc.preserveTemplateData") == "ENABLED"}
                                    end
                                else
                                    addon:LoadTemplate("user", barID, templateName, addon:GetDBValue("global", "settings.misc.preserveTemplateData") == "ENABLED", addon:GetDBValue("global", "settings.misc.preserveTemplateOrder") == "ENABLED")
                                end
                            end
                        end,
                    },
                },
            },
            manage = {
                order = 7,
                type = "group",
                inline = true,
                name = L["Manage"],
                args = {
                    RemoveBar = {
                        order = 1,
                        type = "execute",
                        name = L["Remove Bar"],
                        confirm = function()
                            return format(L.ConfirmRemoveBar, barID)
                        end,
                        func = function()
                            self:RemoveBar(barID)
                        end,
                    },
                },
            },
            charSpecific = {
                order = 8,
                type = "description",
                width = "full",
                name = L.Options_Config("charSpecific"),
            },
        }
    end

    return options
end


function addon:GetButtonConfigOptions(barID)
    local options
    local bar = barID > 0 and self.bars[barID]

    if barID == 0 then -- Config all bars
        options = {

        }
    else -- Config barID
        options = {
            buttons = {
                order = 1,
                type = "group",
                inline = true,
                width = "full",
                name = L["Buttons"],
                get = function(info)
                    return self:GetBarDBValue(info[#info], barID)
                end,
                args = {
                    numVisibleButtons = {
                        order = 1,
                        type = "range",
                        name = L["Number of Buttons"],
                        min = 0,
                        max = self.maxButtons,
                        step = 1,
                        set = function(info, value)
                            self:SetBarDBValue(info[#info], value, barID)
                            bar:UpdateVisibleButtons()
                        end,
                    },
                    buttonWrap = {
                        order = 2,
                        type = "range",
                        name = L["Buttons Per Wrap"],
                        min = 1,
                        max = self.maxButtons,
                        step = 1,
                        set = function(info, value)
                            self:SetBarDBValue(info[#info], value, barID)
                            bar:AnchorButtons()
                        end,
                    },
                },
            },
            style = {
                order = 2,
                type = "group",
                inline = true,
                width = "full",
                name = L["Style"],
                args = {
                    size = {
                        order = 1,
                        type = "range",
                        name = L["Size"],
                        min = self.minButtonSize,
                        max = self.maxButtonSize,
                        step = 1,
                        get = function(info)
                            return self:GetBarDBValue("button."..info[#info], barID)
                        end,
                        set = function(info, value)
                            self:SetBarDBValue("button."..info[#info], value, barID)
                            bar:SetSize()
                        end,
                    },
                    padding = {
                        order = 2,
                        type = "range",
                        name = L["Padding"],
                        min = self.minButtonPadding,
                        max = self.maxButtonPadding,
                        step = 1,
                        get = function(info)
                            return self:GetBarDBValue("button."..info[#info], barID)
                        end,
                        set = function(info, value)
                            self:SetBarDBValue("button."..info[#info], value, barID)
                            bar:SetSize()
                            bar:AnchorButtons()
                        end,
                    },
                    countHeader = {
                        order = 3,
                        type = "header",
                        name = L["Count Fontstring"]
                    },
                    countAnchor = {
                        order = 4,
                        type = "select",
                        name = L["Anchor"],
                        values = anchors,
                        sorting = anchorSort,
                        get = function(info)
                            return self:GetBarDBValue("button.fontStrings.count.anchor", barID)
                        end,
                        set = function(info, value)
                            self:SetBarDBValue("button.fontStrings.count.anchor", value, barID)
                            self:UpdateButtons()
                        end,
                    },
                    countXOffset = {
                        order = 5,
                        type = "range",
                        name = L["X Offset"],
                        min = -self.OffsetX,
                        max = self.OffsetX,
                        step = 1,
                        get = function(info)
                            return self:GetBarDBValue("button.fontStrings.count.xOffset", barID)
                        end,
                        set = function(info, value)
                            self:SetBarDBValue("button.fontStrings.count.xOffset", value, barID)
                            self:UpdateButtons()
                        end,
                    },
                    countYOffset = {
                        order = 6,
                        type = "range",
                        name = L["Y Offset"],
                        min = -self.OffsetY,
                        max = self.OffsetY,
                        step = 1,
                        get = function(info)
                            return self:GetBarDBValue("button.fontStrings.count.yOffset", barID)
                        end,
                        set = function(info, value)
                            self:SetBarDBValue("button.fontStrings.count.yOffset", value, barID)
                            self:UpdateButtons()
                        end,
                    },
                    objectiveHeader = {
                        order = 7,
                        type = "header",
                        name = L["Objective Fontstring"]
                    },
                    objectiveAnchor = {
                        order = 8,
                        type = "select",
                        name = L["Anchor"],
                        values = anchors,
                        sorting = anchorSort,
                        get = function(info)
                            return self:GetBarDBValue("button.fontStrings.objective.anchor", barID)
                        end,
                        set = function(info, value)
                            self:SetBarDBValue("button.fontStrings.objective.anchor", value, barID)
                            self:UpdateButtons()
                        end,
                    },
                    objectiveXOffset = {
                        order = 9,
                        type = "range",
                        name = L["X Offset"],
                        min = -self.OffsetX,
                        max = self.OffsetX,
                        step = 1,
                        get = function(info)
                            return self:GetBarDBValue("button.fontStrings.objective.xOffset", barID)
                        end,
                        set = function(info, value)
                            self:SetBarDBValue("button.fontStrings.objective.xOffset", value, barID)
                            self:UpdateButtons()
                        end,
                    },
                    objectiveYOffset = {
                        order = 10,
                        type = "range",
                        name = L["Y Offset"],
                        min = -self.OffsetY,
                        max = self.OffsetY,
                        step = 1,
                        get = function(info)
                            return self:GetBarDBValue("button.fontStrings.objective.yOffset", barID)
                        end,
                        set = function(info, value)
                            self:SetBarDBValue("button.fontStrings.objective.yOffset", value, barID)
                            self:UpdateButtons()
                        end,
                    },
                },
            },
            operations = {
                order = 3,
                type = "group",
                inline = true,
                width = "full",
                name = L["Operations"],
                args = {
                    clearButtons = {
                        order = 1,
                        type = "execute",
                        name = "*"..L["Clear Buttons"],
                        func = function()
                            self:ClearBar(barID)
                        end,
                    },
                    reindexButtons = {
                        order = 2,
                        type = "execute",
                        name = "*"..L["Reindex Buttons"],
                        func = function()
                            self:ReindexButtons(barID)
                        end,
                    },
                    sizeBarToButtons = {
                        order = 3,
                        type = "execute",
                        name = "**"..L["Size Bar to Buttons"],
                        func = function()
                            self:SizeBarToButtons(barID)
                        end,
                    },
                },
            },
            charSpecific = {
                order = 4,
                type = "description",
                width = "full",
                name = L.Options_Config("charSpecific"),
            },
            mixedSpecific = {
                order = 4,
                type = "description",
                width = "full",
                name = L.Options_Config("mixedSpecific"),
            },
        }
    end

    return options
end