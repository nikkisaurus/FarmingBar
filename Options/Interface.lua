local addonName = ...
local U = LibStub("LibAddonUtils-1.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)
local addon = LibStub("AceAddon-3.0"):GetAddon(L.addonName)
local ACD = LibStub("AceConfigDialog-3.0")
local LSM = LibStub("LibSharedMedia-3.0")

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function addon:CreateDataObject()
    local dataObject = LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject(addonName, {
        type = "launcher",
        icon = "INTERFACE\\ADDONS\\FARMINGBAR\\MEDIA\\FARMINGBAR-ICON",
        label = addonName,
        OnTooltipShow = function(self)
            self:AddLine(addonName)
            self:AddLine(L._Tooltips("broker", 1), 1, 1, 1, 1)
            self:AddLine(L._Tooltips("broker", 2), 1, 1, 1, 1)
            self:AddLine(L._Tooltips("broker", 3), 1, 1, 1, 1)
            self:AddLine(L._Tooltips("broker", 4), 1, 1, 1, 1)
            self:AddLine(L._Tooltips("broker", 5), 1, 1, 1, 1)
            self:AddLine(L._Tooltips("broker", 6), 1, 1, 1, 1)
        end,
        OnClick = function(_, button)
            if button == "LeftButton" then
                if addon:IsFrameOpen() then
                    ACD:Close(L.addonName)
                else
                    addon:Open("settings")
                end
            else
                if IsAltKeyDown() then
                    addon:SetMixedDBValues("char.bars", IsControlKeyDown() and "anchorMouseover" or "mouseover", "_toggle", function(bar)
                        bar:SetMouseover()
                    end)
                elseif IsControlKeyDown() and not IsAltKeyDown() then
                    if UnitAffectingCombat("player") then
                        addon:Print(L.CommandCombatError)
                        return
                    end

                    addon:SetMixedDBValues("char.bars", "hidden", "_toggle", function(bar)
                        bar:SetHidden()
                    end)
                elseif IsShiftKeyDown() then
                    addon:SetMixedDBValues("char.bars", "movable", "_toggle")
                    addon:Print(L.BarMovableChanged(nil, "_toggle"))
                else
                    addon:Open("bars")
                end
            end
        end,
    })
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function addon:GetAboutOptions()
    local options = {
        aboutDesc = {
            order = 1,
            type = "description",
            name = L._About("aboutDesc"),
        },
        differenceHeader = {
            order = 2,
            type = "header",
            name = L._About("differenceHeader"),
        },
        differenceDesc1 = {
            order = 3,
            type = "description",
            name = L._About("differenceDesc1"),
        },
        spacer1 = {
            order = 4,
            type = "description",
            name = "",
        },
        differenceDesc2 = {
            order = 5,
            type = "description",
            name = L._About("differenceDesc2"),
        },
        whatsNewHeader = {
            order = 6,
            type = "header",
            name = L._About("whatsNewHeader"),
        },
        whatsNewDesc = {
            order = 7,
            type = "description",
            name = L._About("whatsNewDesc"),
        },
    }

    return options
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function addon:GetBarOptions(barID)
    local options = {
        bar = {
            order = 1,
            type = "group",
            name = L["Bar"],
            args = {
                desc = {
                    order = 1,
                    type = "input",
                    width = "full",
                    name = L["Name/Description"],
                    desc = L._Bars("descDesc"),
                    set = function(info, value)
                        self:SetDBValue("char.bars", info, value, barID)
                        self:UpdateBars()
                    end,
                },
                movable = {
                    order = 2,
                    type = "toggle",
                    width = .85,
                    name = L["Movable"],
                    desc = L._Bars("movableToggleDesc"),
                },
                hidden = {
                    order = 3,
                    type = "toggle",
                    width = .85,
                    name = L["Hidden"],
                    desc = L._Bars("hiddenToggleDesc"),
                    set = function(info, value)
                        self:SetDBValue("char.bars", info, value, barID)
                        self.bars[barID]:SetHidden(true)
                    end,
                },
                mouseover = {
                    order = 4,
                    type = "toggle",
                    width = .85,
                    name = L["Mouseover"],
                    desc = L._Bars("mouseoverToggleDesc"),
                    set = function(info, value)
                        self:SetDBValue("char.bars", info, value, barID)
                        self.bars[barID]:SetMouseover(true)
                    end,
                },
                anchorMouseover = {
                    order = 5,
                    type = "toggle",
                    name = L["Anchor Mouseover"],
                    desc = L._Bars("anchorMouseoverToggleDesc"),
                    set = function(info, value)
                        self:SetDBValue("char.bars", info, value, barID)
                        self.bars[barID]:SetMouseover(true)
                    end,
                },
                showEmpties = {
                    order = 6,
                    type = "toggle",
                    name = L["Show Empty Buttons"],
                    desc = L._Bars("showEmptiesDesc"),
                    set = function(info, value)
                        self:SetDBValue("char.bars", info, value, barID)
                    end,
                },
                trackProgress = {
                    order = 7,
                    type = "toggle",
                    name = L["Track Progress"],
                    desc = L._Bars("trackProgressDesc"),
                    set = function(info, value)
                        self:SetDBValue("char.bars", info, value, barID)
                    end,
                },
                trackCompletedObjectives = {
                    order = 8,
                    type = "toggle",
                    name = L["Track Completed Objectives"],
                    desc = L._Bars("trackCompletedObjectivesToggleDesc"),
                    set = function(info, value)
                        self:SetDBValue("char.bars", info, value, barID)
                    end,
                },
                muteAlerts = {
                    order = 9,
                    type = "toggle",
                    name = L["Mute Alerts"],
                    desc = L._Bars("muteDesc"),
                    set = function(info, value)
                        self:SetDBValue("char.bars", info, value, barID)
                    end,
                },
                direction = {
                    order = 10,
                    name = L["Bar Direction"],
                    desc = L._Bars("directionDesc"),
                    type = "select",
                    style = "dropdown",
                    values = function()
                        local values = {}
                        for i = 1, 4 do
                            values[i] = addon.directionInfo[i].displayText
                        end
                        return values
                    end,
                    set = function(info, value)
                        self:SetDBValue("char.bars", info, value, barID)
                        self.bars[barID]:UpdateButtons("Anchor")
                        self.bars[barID]:SetBackdrop()
                    end,
                },
                rowDirection = {
                    order = 11,
                    name = L["Row/Column Direction"],
                    desc = L._Bars("rowDirectionDesc"),
                    type = "select",
                    style = "dropdown",
                    values = function()
                        local values = {
                            [1] = L["Bottom/Right"],
                            [2] = L["Top/Left"],
                        }

                        return values
                    end,
                    set = function(info, value)
                        self:SetDBValue("char.bars", info, value, barID)
                        self.bars[barID]:UpdateButtons("Anchor")
                        self.bars[barID]:SetBackdrop()
                    end,
                },
                visibleButtons = {
                    order = 12,
                    type = "range",
                    name = L["Visible Buttons"],
                    desc = L._Bars("visibleButtonsDesc"),
                    min = 0,
                    max = self.maxButtons,
                    step = 1,
                    set = function(info, value)
                        self:SetDBValue("char.bars", info, value, barID)
                        self.bars[barID]:UpdateButtons("SetVisible")
                        self.bars[barID]:SetBackdrop()
                    end,
                },
                buttonsPerRow = {
                    order = 13,
                    type = "range",
                    name = L["Buttons Per Row/Column"],
                    desc = L._Bars("buttonsPerRowDesc"),
                    min = 1,
                    max = self.maxButtons,
                    step = 1,
                    set = function(info, value)
                        self:SetDBValue("char.bars", info, value, barID)
                        self.bars[barID]:UpdateButtons("Anchor")
                        self.bars[barID]:SetBackdrop()
                    end,
                },
                buttonSize = {
                    order = 14,
                    type = "range",
                    name = L["Button Size"],
                    desc = L._Bars("buttonSizeDesc"),
                    min = self.minButtonSize,
                    max = self.maxButtonSize,
                    step = 1,
                    set = function(info, value)
                        self:SetDBValue("char.bars", info, value, barID)
                        self.bars[barID]:Size()
                        self.bars[barID]:UpdateButtons("Size")
                    end,
                },
                buttonPadding = {
                    order = 15,
                    type = "range",
                    name = L["Button Padding"],
                    desc = L._Bars("buttonPaddingDesc"),
                    min = self.minButtonPadding,
                    max = self.maxButtonPadding,
                    step = 1,
                    set = function(info, value)
                        self:SetDBValue("char.bars", info, value, barID)
                        self.bars[barID]:UpdateButtons("Anchor")
                    end,
                },
                scale = {
                    order = 16,
                    type = "range",
                    name = L["Scale"],
                    desc = L._Bars("scaleDesc"),
                    min = self.minScale,
                    max = self.maxScale,
                    set = function(info, value)
                        self:SetDBValue("char.bars", info, value, barID)
                        self.bars[barID]:SetScale(value)
                    end,
                },
                alpha = {
                    order = 17,
                    type = "range",
                    name = L["Alpha"],
                    desc = L._Bars("alphaDesc"),
                    min = 0,
                    max = 1,
                    set = function(info, value)
                        self:SetDBValue("char.bars", info, value, barID)
                        self.bars[barID]:SetAlpha(value)
                    end,
                },
                font = {
                    order = 18,
                    type = "group",
                    inline = true,
                    name = L["Font"],
                    get = function(info) return self:GetDBValue("char.bars.font", info, barID) or self:GetDBValue("profile.style.font", info) end,
                    set = function(info, value)
                        self:SetDBValue("char.bars.font", info, value, barID)
                        self:UpdateFonts()
                    end,
                    args = {
                        size = {
                            order = 1,
                            type = "range",
                            name = L["Font Size"],
                            desc =  L._Bars("sizeDesc"),
                            min = self.minFontSize,
                            max = self.maxFontSize,
                            step = 1,
                        },
                        face = {
                            order = 2,
                            type = "select",
                            name = L["Font Face"],
                            desc =  L._Bars("faceDesc"),
                            dialogControl = "LSM30_Font",
                            values = AceGUIWidgetLSMlists.font,
                        },
                        outline = {
                            order = 3,
                            type = "select",
                            name = L["Font Outline"],
                            desc =  L._Bars("outlineDesc"),
                            values = {
                                ["MONOCHROME"] = L["MONOCHROME"],
                                ["OUTLINE"] = L["OUTLINE"],
                                ["THICKOUTLINE"] = L["THICKOUTLINE"],
                                ["NONE"] = L["NONE"],
                            },
                            sorting = {"MONOCHROME", "OUTLINE", "THICKOUTLINE", "NONE"},
                        },
                    },
                },
                spacer2 = {
                    order = 99,
                    type = "description",
                    width = "full",
                    name = "",
                },
                removeBarExecute = {
                    order = 100,
                    type = "execute",
                    name = L["Remove Bar"],
                    desc = L._Bars("removeBarExecuteDesc"),
                    func = function()
                        addon:RemoveBar(barID)
                    end,
                },
            },
        },
        buttons = {
            order = 2,
            type = "group",
            name = L["Buttons"],
            args = {
                countTextGroup = {
                    order = 1,
                    type = "group",
                    inline = true,
                    name = L["Count Text"],
                    get = function(info) return self:GetDBValue("char.bars.count", info, barID) end,
                    set = function(info, value)
                        self:SetDBValue("char.bars.count", info, value, barID)
                        self.bars[barID]:UpdateButtons("Size")
                    end,
                    args = {
                        anchor = {
                            order = 1,
                            type = "select",
                            style = "dropdown",
                            name = L["Anchor"],
                            desc = L._Bars("anchorCountDesc"),
                            values = {
                                TOPLEFT = L["TOPLEFT"],
                                TOP = L["TOP"],
                                TOPRIGHT = L["TOPRIGHT"],
                                LEFT = L["LEFT"],
                                CENTER = L["CENTER"],
                                RIGHT = L["RIGHT"],
                                BOTTOMLEFT = L["BOTTOMLEFT"],
                                BOTTOM = L["BOTTOM"],
                                BOTTOMRIGHT = L["BOTTOMRIGHT"],
                            },
                            sorting = {"TOPLEFT", "TOP", "TOPRIGHT", "LEFT", "CENTER", "RIGHT", "BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT"},
                        },
                        xOffset = {
                            order = 2,
                            type = "range",
                            name = L["X Offset"],
                            desc = L._Bars("xOffsetCountDesc"),
                            min = -self.OffsetX,
                            max = self.OffsetX,
                        },
                        yOffset = {
                            order = 3,
                            type = "range",
                            name = L["Y Offset"],
                            desc = L._Bars("yOffsetCountDesc"),
                            min = -self.OffsetY,
                            max = self.OffsetY,
                        },
                    },
                },
                objectiveTextGroup = {
                    order = 2,
                    type = "group",
                    inline = true,
                    name = L["Objective Text"],
                    get = function(info) return self:GetDBValue("char.bars.objective", info, barID) end,
                    set = function(info, value)
                        self:SetDBValue("char.bars.objective", info, value, barID)
                        self.bars[barID]:UpdateButtons("Size")
                    end,
                    args = {
                        anchor = {
                            order = 1,
                            type = "select",
                            style = "dropdown",
                            name = L["Anchor"],
                            desc = L._Bars("anchorObjectiveDesc"),
                            values = {
                                TOPLEFT = L["TOPLEFT"],
                                TOP = L["TOP"],
                                TOPRIGHT = L["TOPRIGHT"],
                                LEFT = L["LEFT"],
                                CENTER = L["CENTER"],
                                RIGHT = L["RIGHT"],
                                BOTTOMLEFT = L["BOTTOMLEFT"],
                                BOTTOM = L["BOTTOM"],
                                BOTTOMRIGHT = L["BOTTOMRIGHT"],
                            },
                            sorting = {"TOPLEFT", "TOP", "TOPRIGHT", "LEFT", "CENTER", "RIGHT", "BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT"},
                        },
                        xOffset = {
                            order = 2,
                            type = "range",
                            name = L["X Offset"],
                            desc = L._Bars("xOffsetObjectiveDesc"),
                            min = -self.OffsetX,
                            max = self.OffsetX,
                        },
                        yOffset = {
                            order = 3,
                            type = "range",
                            name = L["Y Offset"],
                            desc = L._Bars("yOffsetObjectiveDesc"),
                            min = -self.OffsetY,
                            max = self.OffsetY,
                        },
                    },
                },
                templateGroup = {
                    order = 3,
                    type = "group",
                    inline = true,
                    name = L["Templates"],
                    args = {
                        newTemplateInput = {
                            order = 3,
                            type = "input",
                            name = L["New"],
                            desc = L._Bars("newTemplateInputDesc"),
                            set = function(_, value) self:SaveTemplate(barID, value) end
                        },
                        loadTemplateSelect1 = {
                            order = 4,
                            type = "select",
                            style = "dropdown",
                            name = L["Load Built-In Template"],
                            desc = L._Bars("loadTemplateSelect1Desc"),
                            values = function()
                                local values = {}
                                for k, v in pairs(self.templates) do
                                    values[k] = k
                                end
                                return values
                            end,
                            set = function(_, value) self:LoadTemplate("builtin", barID, value) end,
                        },
                        loadTemplateSelect2 = {
                            order = 5,
                            type = "select",
                            style = "dropdown",
                            name = L["Load User Template"],
                            desc = L._Bars("loadTemplateSelect2Desc"),
                            values = function()
                                local values = {}
                                for k, v in pairs(self.db.global.templates) do
                                    values[k] = k
                                end
                                return values
                            end,
                            set = function(info, value)
                                if self.db.global.template.includeDataPrompt then
                                    local dialog = StaticPopup_Show("FARMINGBAR_INCLUDE_TEMPLATE_DATA", value)
                                    if dialog then
                                        dialog.data = {barID, value}
                                    end
                                else
                                    if self.db.global.template.saveOrderPrompt then
                                        local dialog = StaticPopup_Show("FARMINGBAR_SAVE_TEMPLATE_ORDER", value)
                                        if dialog then
                                            dialog.data = {barID, value, self.db.global.template.includeData}
                                        end
                                    else
                                        self:LoadTemplate("user", barID, value,  self.db.global.template.includeData, self.db.global.template.saveOrder)
                                    end
                                end
                            end,
                            disabled = function() return U.tcount(self.db.global.templates) == 0 end,
                        },
                        deleteTemplateSelect = {
                            order = 6,
                            type = "select",
                            style = "dropdown",
                            name = L["Delete User Template"],
                            desc = L._Bars("deleteTemplateSelectDesc"),
                            values = function()
                                local values = {}
                                for k, v in pairs(self.db.global.templates) do
                                    values[k] = k
                                end
                                return values
                            end,
                            set = function(_, value) self:DeleteTemplate(value) end,
                            confirm = function(_, value) return L._Bars("deleteTemplateSelectConfirm", value) end,
                            disabled = function() return U.tcount(self.db.global.templates) == 0 end,
                        },
                    },
                },
                reindexButtonsExecute = {
                    order = 4,
                    type = "execute",
                    name = L["Reindex Buttons"],
                    desc = L._Bars("reindexButtonsExecuteDesc"),
                    func = function() self.bars[barID]:ReindexButtons() end,
                    disabled = function() return U.tcount(self.bars[barID].db.objectives, nil, "type") == 0 end,
                },
                sizeBarExecute = {
                    order = 5,
                    type = "execute",
                    name = L["Size Bar to Buttons"],
                    desc = L._Bars("sizeBarExecuteDesc"),
                    func = function() self.bars[barID]:ReindexButtons(true) end,
                    disabled = function() return U.tcount(self.bars[barID].db.objectives, nil, "type") == 0 end,
                },
                clearButtonsExecute = {
                    order = 6,
                    type = "execute",
                    name = L["Clear Buttons"],
                    desc = L._Bars("clearButtonsExecuteDesc"),
                    func = function() self.bars[barID]:ClearItems() end,
                    disabled = function() return U.tcount(self.bars[barID].db.objectives, nil, "type") == 0 end,
                },
            },

        },
    }

    return options
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function addon:GetCommandsOptions()
    local options = {
        bar = {
            order = 1,
            type = "group",
            name = "bar",
            args = {
                add = {
                    order = 1,
                    type = "group",
                    inline = true,
                    name = "add",
                    args = {
                        addDesc = {
                            order = 1,
                            type = "description",
                            name = L._Commands(L, "bar", "i_addDesc"),
                            fontSize = "medium",
                        },
                        addArgsDesc = {
                            order = 2,
                            type = "description",
                            name = L._Commands(L, "bar", "i_addArgsDesc"),
                        },
                        addExDesc = {
                            order = 3,
                            type = "description",
                            name = L._Commands(L, "bar", "i_addExDesc"),
                        },
                    },
                },

                alpha = {
                    order = 2,
                    type = "group",
                    inline = true,
                    name = "alpha",
                    args = {
                        alphaDesc = {
                            order = 1,
                            type = "description",
                            name = L._Commands(L, "bar", "i_alphaDesc"),
                            fontSize = "medium",
                        },
                        alphaArgsDesc = {
                            order = 2,
                            type = "description",
                            name = L._Commands(L, "bar", "i_alphaArgsDesc"),
                        },
                        alphaRangeDesc = {
                            order = 3,
                            type = "description",
                            name = L._Commands(L, "bar", "i_alphaRangeDesc", 0, 1),
                        },
                        alphaExDesc = {
                            order = 4,
                            type = "description",
                            name = L._Commands(L, "bar", "i_alphaExDesc"),
                        },
                    },
                },

                buttons = {
                    order = 3,
                    type = "group",
                    inline = true,
                    name = "buttons",
                    args = {
                        buttonsDesc = {
                            order = 1,
                            type = "description",
                            name = L._Commands(L, "bar", "i_buttonsDesc"),
                            fontSize = "medium",
                        },
                        buttonsArgsDesc = {
                            order = 2,
                            type = "description",
                            name = L._Commands(L, "bar", "i_buttonsArgsDesc"),
                        },
                        buttonsRangeDesc = {
                            order = 3,
                            type = "description",
                            name = L._Commands(L, "bar", "i_buttonsRangeDesc", 1, self.maxButtons),
                        },
                        buttonsExDesc = {
                            order = 4,
                            type = "description",
                            name = L._Commands(L, "bar", "i_buttonsExDesc"),
                        },
                    },
                },

                empties = {
                    order = 4,
                    type = "group",
                    inline = true,
                    name = "empties",
                    args = {
                        emptiesDesc = {
                            order = 1,
                            type = "description",
                            name = L._Commands(L, "bar", "i_emptiesDesc"),
                            fontSize = "medium",
                        },
                        emptiesArgsDesc = {
                            order = 2,
                            type = "description",
                            name = L._Commands(L, "bar", "i_emptiesArgsDesc"),
                        },
                        emptiesExDesc = {
                            order = 3,
                            type = "description",
                            name = L._Commands(L, "bar", "i_emptiesExDesc"),
                        },
                    },
                },

                font = {
                    order = 5,
                    type = "group",
                    inline = true,
                    name = "font",
                    args = {
                        fontDesc = {
                            order = 1,
                            type = "description",
                            name = L._Commands(L, "bar", "i_fontDesc"),
                            fontSize = "medium",
                        },
                        fontArgsDesc = {
                            order = 2,
                            type = "description",
                            name = L._Commands(L, "bar", "i_fontArgsDesc"),
                        },
                        fontRangeDesc = {
                            order = 3,
                            type = "description",
                            name = L._Commands(L, "bar", "i_fontRangeDesc", self.minFontSize, self.maxFontSize),
                        },
                        fontExDesc = {
                            order = 4,
                            type = "description",
                            name = L._Commands(L, "bar", "i_fontExDesc"),
                        },
                    },
                },

                groups = {
                    order = 6,
                    type = "group",
                    inline = true,
                    name = "groups",
                    args = {
                        groupsDesc = {
                            order = 1,
                            type = "description",
                            name = L._Commands(L, "bar", "i_groupsDesc"),
                            fontSize = "medium",
                        },
                        groupsArgsDesc = {
                            order = 2,
                            type = "description",
                            name = L._Commands(L, "bar", "i_groupsArgsDesc"),
                        },
                        groupsRangeDesc = {
                            order = 3,
                            type = "description",
                            name = L._Commands(L, "bar", "i_groupsRangeDesc", 1, self.maxButtons),
                        },
                        groupsExDesc = {
                            order = 4,
                            type = "description",
                            name = L._Commands(L, "bar", "i_groupsExDesc"),
                        },
                    },
                },

                grow = {
                    order = 7,
                    type = "group",
                    inline = true,
                    name = "grow",
                    args = {
                        growDesc = {
                            order = 1,
                            type = "description",
                            name = L._Commands(L, "bar", "i_growDesc"),
                            fontSize = "medium",
                        },
                        growArgsDesc = {
                            order = 2,
                            type = "description",
                            name = L._Commands(L, "bar", "i_growArgsDesc"),
                        },
                        growExDesc = {
                            order = 3,
                            type = "description",
                            name = L._Commands(L, "bar", "i_growExDesc"),
                        },
                    },
                },

                mouseover = {
                    order = 8,
                    type = "group",
                    inline = true,
                    name = "mouseover",
                    args = {
                        mouseoverDesc = {
                            order = 1,
                            type = "description",
                            name = L._Commands(L, "bar", "i_mouseoverDesc"),
                            fontSize = "medium",
                        },
                        mouseoverArgsDesc = {
                            order = 2,
                            type = "description",
                            name = L._Commands(L, "bar", "i_mouseoverArgsDesc"),
                        },
                        mouseoverExDesc = {
                            order = 3,
                            type = "description",
                            name = L._Commands(L, "bar", "i_mouseoverExDesc"),
                        },
                    },
                },

                movable = {
                    order = 9,
                    type = "group",
                    inline = true,
                    name = "movable",
                    args = {
                        movableDesc = {
                            order = 1,
                            type = "description",
                            name = L._Commands(L, "bar", "i_movableDesc"),
                            fontSize = "medium",
                        },
                        movableArgsDesc = {
                            order = 2,
                            type = "description",
                            name = L._Commands(L, "bar", "i_movableArgsDesc"),
                        },
                        movableExDesc = {
                            order = 3,
                            type = "description",
                            name = L._Commands(L, "bar", "i_movableExDesc"),
                        },
                    },
                },

                mute = {
                    order = 10,
                    type = "group",
                    inline = true,
                    name = "mute",
                    args = {
                        muteDesc = {
                            order = 1,
                            type = "description",
                            name = L._Commands(L, "bar", "i_muteDesc"),
                            fontSize = "medium",
                        },
                        muteArgsDesc = {
                            order = 2,
                            type = "description",
                            name = L._Commands(L, "bar", "i_muteArgsDesc"),
                        },
                        muteExDesc = {
                            order = 3,
                            type = "description",
                            name = L._Commands(L, "bar", "i_muteExDesc"),
                        },
                    },
                },

                name = {
                    order = 11,
                    type = "group",
                    inline = true,
                    name = "name",
                    args = {
                        nameDesc = {
                            order = 1,
                            type = "description",
                            name = L._Commands(L, "bar", "i_nameDesc"),
                            fontSize = "medium",
                        },
                        nameArgsDesc = {
                            order = 2,
                            type = "description",
                            name = L._Commands(L, "bar", "i_nameArgsDesc"),
                        },
                        nameExDesc = {
                            order = 3,
                            type = "description",
                            name = L._Commands(L, "bar", "i_nameExDesc"),
                        },
                    },
                },

                padding = {
                    order = 12,
                    type = "group",
                    inline = true,
                    name = "padding",
                    args = {
                        paddingDesc = {
                            order = 1,
                            type = "description",
                            name = L._Commands(L, "bar", "i_paddingDesc"),
                            fontSize = "medium",
                        },
                        paddingArgsDesc = {
                            order = 2,
                            type = "description",
                            name = L._Commands(L, "bar", "i_paddingArgsDesc"),
                        },
                        paddingRangeDesc = {
                            order = 3,
                            type = "description",
                            name = L._Commands(L, "bar", "i_paddingRangeDesc", self.minButtonPadding, self.maxButtonPadding),
                        },
                        paddingExDesc = {
                            order = 4,
                            type = "description",
                            name = L._Commands(L, "bar", "i_paddingExDesc"),
                        },
                    },
                },

                remove = {
                    order = 13,
                    type = "group",
                    inline = true,
                    name = "remove",
                    args = {
                        removeDesc = {
                            order = 1,
                            type = "description",
                            name = L._Commands(L, "bar", "i_removeDesc"),
                            fontSize = "medium",
                        },
                        removeArgsDesc = {
                            order = 2,
                            type = "description",
                            name = L._Commands(L, "bar", "i_removeArgsDesc"),
                        },
                        removeExDesc = {
                            order = 3,
                            type = "description",
                            name = L._Commands(L, "bar", "i_removeExDesc"),
                        },
                    },
                },

                scale = {
                    order = 14,
                    type = "group",
                    inline = true,
                    name = "scale",
                    args = {
                        scaleDesc = {
                            order = 1,
                            type = "description",
                            name = L._Commands(L, "bar", "i_scaleDesc"),
                            fontSize = "medium",
                        },
                        scaleArgsDesc = {
                            order = 2,
                            type = "description",
                            name = L._Commands(L, "bar", "i_scaleArgsDesc"),
                        },
                        scaleRangeDesc = {
                            order = 3,
                            type = "description",
                            name = L._Commands(L, "bar", "i_scaleRangeDesc", self.minScale, self.maxScale),
                        },
                        scaleExDesc = {
                            order = 4,
                            type = "description",
                            name = L._Commands(L, "bar", "i_scaleExDesc"),
                        },
                    },
                },

                size = {
                    order = 15,
                    type = "group",
                    inline = true,
                    name = "size",
                    args = {
                        sizeDesc = {
                            order = 1,
                            type = "description",
                            name = L._Commands(L, "bar", "i_sizeDesc"),
                            fontSize = "medium",
                        },
                        sizeArgsDesc = {
                            order = 2,
                            type = "description",
                            name = L._Commands(L, "bar", "i_sizeArgsDesc"),
                        },
                        sizeRangeDesc = {
                            order = 3,
                            type = "description",
                            name = L._Commands(L, "bar", "i_sizeRangeDesc", self.minButtonSize, self.maxButtonSize),
                        },
                        sizeExDesc = {
                            order = 4,
                            type = "description",
                            name = L._Commands(L, "bar", "i_sizeExDesc"),
                        },
                    },
                },

                track = {
                    order = 16,
                    type = "group",
                    inline = true,
                    name = "track",
                    args = {
                        trackDesc = {
                            order = 1,
                            type = "description",
                            name = L._Commands(L, "bar", "i_trackDesc"),
                            fontSize = "medium",
                        },
                        trackArgsDesc = {
                            order = 2,
                            type = "description",
                            name = L._Commands(L, "bar", "i_trackArgsDesc"),
                        },
                        trackExDesc = {
                            order = 3,
                            type = "description",
                            name = L._Commands(L, "bar", "i_trackExDesc"),
                        },
                    },
                },


                visibility = {
                    order = 17,
                    type = "group",
                    inline = true,
                    name = "visibility",
                    args = {
                        visibilityDesc = {
                            order = 1,
                            type = "description",
                            name = L._Commands(L, "bar", "i_visibilityDesc"),
                            fontSize = "medium",
                        },
                        visibilityArgsDesc = {
                            order = 2,
                            type = "description",
                            name = L._Commands(L, "bar", "i_visibilityArgsDesc"),
                        },
                        visibilityExDesc = {
                            order = 3,
                            type = "description",
                            name = L._Commands(L, "bar", "i_visibilityExDesc"),
                        },
                    },
                },

            },
        },

        buttons = {
            order = 2,
            type = "group",
            name = "buttons/btns",
            args = {
                clear = {
                    order = 1,
                    type = "group",
                    inline = true,
                    name = "clear",
                    args = {
                        clearDesc = {
                            order = 1,
                            type = "description",
                            name = L._Commands(L, "buttons", "i_clearDesc"),
                            fontSize = "medium",
                        },
                        clearArgsDesc = {
                            order = 2,
                            type = "description",
                            name = L._Commands(L, "buttons", "i_clearArgsDesc"),
                        },
                        clearExDesc = {
                            order = 3,
                            type = "description",
                            name = L._Commands(L, "buttons", "i_clearExDesc"),
                        },
                    },
                },

                reindex = {
                    order = 1,
                    type = "group",
                    inline = true,
                    name = "reindex",
                    args = {
                        reindexDesc = {
                            order = 1,
                            type = "description",
                            name = L._Commands(L, "buttons", "i_reindexDesc"),
                            fontSize = "medium",
                        },
                        reindexArgsDesc = {
                            order = 2,
                            type = "description",
                            name = L._Commands(L, "buttons", "i_reindexArgsDesc"),
                        },
                        reindexExDesc = {
                            order = 3,
                            type = "description",
                            name = L._Commands(L, "buttons", "i_reindexExDesc"),
                        },
                    },
                },

                size = {
                    order = 2,
                    type = "group",
                    inline = true,
                    name = "size",
                    args = {
                        sizeDesc = {
                            order = 1,
                            type = "description",
                            name = L._Commands(L, "buttons", "i_sizeDesc"),
                            fontSize = "medium",
                        },
                        sizeArgsDesc = {
                            order = 2,
                            type = "description",
                            name = L._Commands(L, "buttons", "i_sizeArgsDesc"),
                        },
                        sizeExDesc = {
                            order = 3,
                            type = "description",
                            name = L._Commands(L, "buttons", "i_sizeExDesc"),
                        },
                    },
                },
            },
        },

        profile = {
            order = 3,
            type = "group",
            name = "profile",
            args = {
                reset = {
                    order = 1,
                    type = "group",
                    inline = true,
                    name = "reset",
                    args = {
                        resetDesc = {
                            order = 1,
                            type = "description",
                            name = L._Commands(L, "profile", "i_resetDesc"),
                            fontSize = "medium",
                        },
                        resetArgsDesc = {
                            order = 2,
                            type = "description",
                            name = L._Commands(L, "profile", "i_resetArgsDesc"),
                        },
                        resetExDesc = {
                            order = 3,
                            type = "description",
                            name = L._Commands(L, "profile", "i_resetExDesc"),
                        },
                    },
                },
            },
        },

        template = {
            order = 4,
            type = "group",
            name = "template/tpl",
            args = {
                delete = {
                    order = 1,
                    type = "group",
                    inline = true,
                    name = "delete",
                    args = {
                        deleteDesc = {
                            order = 1,
                            type = "description",
                            name = L._Commands(L, "template", "i_deleteDesc"),
                            fontSize = "medium",
                        },
                        deleteArgsDesc = {
                            order = 2,
                            type = "description",
                            name = L._Commands(L, "template", "i_deleteArgsDesc"),
                        },
                        deleteExDesc = {
                            order = 3,
                            type = "description",
                            name = L._Commands(L, "template", "i_deleteExDesc"),
                        },
                    },
                },

                load = {
                    order = 2,
                    type = "group",
                    inline = true,
                    name = "load",
                    args = {
                        loadDesc = {
                            order = 1,
                            type = "description",
                            name = L._Commands(L, "template", "i_loadDesc"),
                            fontSize = "medium",
                        },
                        loadArgsDesc = {
                            order = 2,
                            type = "description",
                            name = L._Commands(L, "template", "i_loadArgsDesc"),
                        },
                        loadExDesc = {
                            order = 3,
                            type = "description",
                            name = L._Commands(L, "template", "i_loadExDesc"),
                        },
                    },
                },

                save = {
                    order = 3,
                    type = "group",
                    inline = true,
                    name = "save",
                    args = {
                        saveDesc = {
                            order = 1,
                            type = "description",
                            name = L._Commands(L, "template", "i_saveDesc"),
                            fontSize = "medium",
                        },
                        saveArgsDesc = {
                            order = 2,
                            type = "description",
                            name = L._Commands(L, "template", "i_saveArgsDesc"),
                        },
                        saveExDesc = {
                            order = 3,
                            type = "description",
                            name = L._Commands(L, "template", "i_saveExDesc"),
                        },
                    },
                },
            },
        },

        howToUseDesc = {
            order = 6,
            type = "description",
            name = L._Commands(L, nil, "howToUseDesc"),
        },

        limitationsHeader = {
            order = 7,
            type = "header",
            name = L._Commands(L, nil, "limitationsHeader"),
        },
        limitationsDesc = {
            order = 8,
            type = "description",
            name = L._Commands(L, nil, "limitationsDesc"),
        },
        spacer1 = {
            order = 9,
            type = "description",
            name = " ",
        },
        limitationsDesc2 = {
            order = 10,
            type = "description",
            name = L._Commands(L, nil, "limitationsDesc2"),
        },
        spacer2 = {
            order = 11,
            type = "description",
            name = " ",
        },
        limitationsDesc3 = {
            order = 12,
            type = "description",
            name = L._Commands(L, nil, "limitationsDesc3"),
        },

        argsHeader = {
            order = 13,
            type = "header",
            name = L._Commands(L, nil, "argsHeader"),
        },
        argsDesc = {
            order = 14,
            type = "description",
            name = L._Commands(L, nil, "argsDesc"),
        },

        aliasHeader = {
            order = 15,
            type = "header",
            name = L._Commands(L, nil, "aliasHeader"),
        },
        aliasDesc = {
            order = 16,
            type = "description",
            name = L._Commands(L, nil, "aliasDesc"),
        },
    }

    return options
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function addon:GetBarsOptions()
    local options = {
        removeBarDropDown = {
            order = 1,
            type = "select",
            style = "dropdown",
            name = L["Remove Bar"],
            desc = L._Bars("removeBarDropDownDesc"),
            values = function()
                local values = {}
                for k, v in pairs(self.db.char.bars) do
                    if v.enabled then
                        values[k] = L.GetBarIDString(k)
                    end
                end

                return values
            end,
            set = function(_, value)
                self:RemoveBar(value)
                self:UpdateBars()
            end,
            confirm = function(_, value) return L._Bars("removeBarConfirm", value) end,
            disabled = function() return U.tcount(self.db.char.bars, nil, "enabled") == 0 end,
        },
        addBarExecute = {
            order = 2,
            type = "execute",
            name = L["Add Bar"],
            desc = L._Bars("addBarExecuteDesc"),
            func = function()
                self:AddBar()
            end,
        },
        resetCharExecute = {
            order = 3,
            type = "execute",
            name = L["Reset Character Database"],
            desc = L._Bars("resetCharExecuteDesc"),
            func = function()
                self:ResetProfile()
            end,
            confirm = function() return L._Bars("resetCharExecuteConfirm") end,
        },
        spacer1 = {
            order = 4,
            type = "description",
            width = "full",
            name = "",
        },
        configAllDesc = {
            order = 5,
            type = "description",
            name = L._Bars("configAllDesc"),
        },
        spacer2 = {
            order = 6,
            type = "description",
            width = "full",
            name = "",
        },
        configBarsGroup = {
            order = 7,
            type = "group",
            inline = true,
            name = L["Config: Bars"],
            get = function(info) return self:GetMixedDBValues("char.bars", info) end,
            set = function(info, value) self:SetMixedDBValues("char.bars", info, value or false) end,
            args = {
                movable = {
                    order = 1,
                    type = "toggle",
                    width = .85,
                    name = L["Movable"],
                    desc = L._Bars("movableToggleDesc"),
                    tristate = true,
                },
                hidden = {
                    order = 2,
                    type = "toggle",
                    width = .85,
                    name = L["Hidden"],
                    desc = L._Bars("hiddenToggleDesc"),
                    tristate = true,
                    set = function(info, value)
                        self:SetMixedDBValues("char.bars", info, value or false, function(bar)
                            bar:SetHidden()
                        end)
                    end,
                },
                mouseover = {
                    order = 3,
                    type = "toggle",
                    width = .85,
                    name = L["Mouseover"],
                    desc = L._Bars("mouseoverToggleDesc"),
                    tristate = true,
                    set = function(info, value)
                        self:SetMixedDBValues("char.bars", info, value or false, function(bar)
                            bar:SetMouseover()
                        end)
                    end,
                },
                anchorMouseover = {
                    order = 4,
                    type = "toggle",
                    name = L["Anchor Mouseover"],
                    desc = L._Bars("anchorMouseoverToggleDesc"),
                    tristate = true,
                    set = function(info, value)
                        self:SetMixedDBValues("char.bars", info, value or false, function(bar)
                            bar:SetMouseover()
                        end)
                    end,
                },
                showEmpties = {
                    order = 5,
                    type = "toggle",
                    name = L["Show Empty Buttons"],
                    desc = L._Bars("showEmptiesDesc"),
                    tristate = true,
                },
                trackProgress = {
                    order = 6,
                    type = "toggle",
                    name = L["Track Progress"],
                    desc = L._Bars("trackProgressDesc"),
                    tristate = true,
                },
                trackCompletedObjectives = {
                    order = 7,
                    type = "toggle",
                    name = L["Track Completed Objectives"],
                    desc = L._Bars("trackCompletedObjectivesToggleDesc"),
                    tristate = true,
                },
                muteAlerts = {
                    order = 8,
                    type = "toggle",
                    name = L["Mute Alerts"],
                    desc = L._Bars("muteDesc"),
                    tristate = true,
                },
                direction = {
                    order = 9,
                    name = L["Bar Direction"],
                    desc = L._Bars("directionDesc"),
                    type = "select",
                    style = "dropdown",
                    values = function()
                        local values = {}
                        for i = 1, 4 do
                            values[i] = addon.directionInfo[i].displayText
                        end
                        return values
                    end,
                    set = function(info, value)
                        self:SetMixedDBValues("char.bars", info, value, function(bar)
                            bar:UpdateButtons("Anchor")
                            bar:SetBackdrop()
                        end)
                    end,
                },
                rowDirection = {
                    order = 10,
                    name = L["Row/Column Direction"],
                    desc = L._Bars("rowDirectionDesc"),
                    type = "select",
                    style = "dropdown",
                    values = function()
                        local values = {
                            [1] = L["Bottom/Right"],
                            [2] = L["Top/Left"],
                        }

                        return values
                    end,
                    set = function(info, value)
                        self:SetMixedDBValues("char.bars", info, value, function(bar)
                            bar:UpdateButtons("Anchor")
                            bar:SetBackdrop()
                        end)
                    end,
                },
                visibleButtons = {
                    order = 11,
                    type = "range",
                    name = L["Visible Buttons"],
                    desc = L._Bars("visibleButtonsDesc"),
                    min = 0,
                    max = self.maxButtons,
                    step = 1,
                    set = function(info, value)
                        self:SetMixedDBValues("char.bars", info, value, function(bar)
                            bar:UpdateButtons("SetVisible")
                            bar:SetBackdrop()
                        end)
                    end,
                },
                buttonsPerRow = {
                    order = 12,
                    type = "range",
                    name = L["Buttons Per Row/Column"],
                    desc = L._Bars("buttonsPerRowDesc"),
                    min = 1,
                    max = self.maxButtons,
                    step = 1,
                    set = function(info, value)
                        self:SetMixedDBValues("char.bars", info, value, function(bar)
                            bar:UpdateButtons("Anchor")
                            bar:SetBackdrop()
                        end)
                    end,
                },
                buttonSize = {
                    order = 13,
                    type = "range",
                    name = L["Button Size"],
                    desc = L._Bars("buttonSizeDesc"),
                    min = self.minButtonSize,
                    max = self.maxButtonSize,
                    step = 1,
                    set = function(info, value)
                        self:SetMixedDBValues("char.bars", info, value, function(bar)
                            bar:Size()
                            bar:UpdateButtons("Size")
                        end)
                    end,
                },
                buttonPadding = {
                    order = 14,
                    type = "range",
                    name = L["Button Padding"],
                    desc = L._Bars("buttonPaddingDesc"),
                    min = self.minButtonPadding,
                    max = self.maxButtonPadding,
                    step = 1,
                    set = function(info, value)
                        self:SetMixedDBValues("char.bars", info, value, function(bar)
                            bar:UpdateButtons("Anchor")
                        end)
                    end,
                },
                scale = {
                    order = 15,
                    type = "range",
                    name = L["Scale"],
                    desc = L._Bars("scaleDesc"),
                    min = self.minScale,
                    max = self.maxScale,
                    set = function(info, value)
                        self:SetMixedDBValues("char.bars", info, value, function(bar)
                            bar:SetScale(value)
                        end)
                    end,
                },
                alpha = {
                    order = 16,
                    type = "range",
                    name = L["Alpha"],
                    desc = L._Bars("alphaDesc"),
                    min = 0,
                    max = 1,
                    set = function(info, value)
                        self:SetMixedDBValues("char.bars", info, value, function(bar)
                            bar:SetAlpha(value)
                        end)
                    end,
                },
                font = {
                    order = 17,
                    type = "group",
                    inline = true,
                    name = L["Font"],
                    get = function(info) return self:GetMixedDBValues("char.bars.font", info, "profile.style.font") end,
                    set = function(info, value)
                        self:SetMixedDBValues("char.bars.font", info, value)
                        self:UpdateFonts()
                    end,
                    args = {
                        size = {
                            order = 1,
                            type = "range",
                            name = L["Font Size"],
                            desc =  L._Bars("sizeDesc"),
                            min = self.minFontSize,
                            max = self.maxFontSize,
                            step = 1,
                        },
                        face = {
                            order = 2,
                            type = "select",
                            name = L["Font Face"],
                            desc =  L._Bars("faceDesc"),
                            dialogControl = "LSM30_Font",
                            values = AceGUIWidgetLSMlists.font,
                        },
                        outline = {
                            order = 3,
                            type = "select",
                            name = L["Font Outline"],
                            desc =  L._Bars("outlineDesc"),
                            values = {
                                ["MONOCHROME"] = L["MONOCHROME"],
                                ["OUTLINE"] = L["OUTLINE"],
                                ["THICKOUTLINE"] = L["THICKOUTLINE"],
                                ["NONE"] = L["NONE"],
                            },
                            sorting = {"MONOCHROME", "OUTLINE", "THICKOUTLINE", "NONE"},
                        },
                    },
                },
            },
        },
        configButtonsGroup = {
            order = 8,
            type = "group",
            inline = true,
            name = L["Config: Buttons"],
            args = {
                countTextGroup = {
                    order = 1,
                    type = "group",
                    inline = true,
                    name = L["Count Text"],
                    get = function(info) return self:GetMixedDBValues("char.bars.count", info) end,
                    set = function(info, value)
                        self:SetMixedDBValues("char.bars.count", info, value, function(bar)
                            bar:UpdateButtons("Size")
                        end)
                    end,
                    args = {
                        anchor = {
                            order = 1,
                            type = "select",
                            style = "dropdown",
                            name = L["Anchor"],
                            desc = L._Bars("anchorCountDesc"),
                            values = {
                                TOPLEFT = L["TOPLEFT"],
                                TOP = L["TOP"],
                                TOPRIGHT = L["TOPRIGHT"],
                                LEFT = L["LEFT"],
                                CENTER = L["CENTER"],
                                RIGHT = L["RIGHT"],
                                BOTTOMLEFT = L["BOTTOMLEFT"],
                                BOTTOM = L["BOTTOM"],
                                BOTTOMRIGHT = L["BOTTOMRIGHT"],
                            },
                            sorting = {"TOPLEFT", "TOP", "TOPRIGHT", "LEFT", "CENTER", "RIGHT", "BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT"},
                        },
                        xOffset = {
                            order = 2,
                            type = "range",
                            name = L["X Offset"],
                            desc = L._Bars("xOffsetCountDesc"),
                            min = -self.OffsetX,
                            max = self.OffsetX,
                        },
                        yOffset = {
                            order = 3,
                            type = "range",
                            name = L["Y Offset"],
                            desc = L._Bars("yOffsetCountDesc"),
                            min = -self.OffsetY,
                            max = self.OffsetY,
                        },
                    },
                },
                objectiveTextGroup = {
                    order = 2,
                    type = "group",
                    inline = true,
                    name = L["Objective Text"],
                    get = function(info) return self:GetMixedDBValues("char.bars.objective", info) end,
                    set = function(info, value)
                        self:SetMixedDBValues("char.bars.objective", info, value, function(bar)
                            bar:UpdateButtons("Size")
                        end)
                    end,
                    args = {
                        anchor = {
                            order = 1,
                            type = "select",
                            style = "dropdown",
                            name = L["Anchor"],
                            desc = L._Bars("anchorObjectiveDesc"),
                            values = {
                                TOPLEFT = L["TOPLEFT"],
                                TOP = L["TOP"],
                                TOPRIGHT = L["TOPRIGHT"],
                                LEFT = L["LEFT"],
                                CENTER = L["CENTER"],
                                RIGHT = L["RIGHT"],
                                BOTTOMLEFT = L["BOTTOMLEFT"],
                                BOTTOM = L["BOTTOM"],
                                BOTTOMRIGHT = L["BOTTOMRIGHT"],
                            },
                            sorting = {"TOPLEFT", "TOP", "TOPRIGHT", "LEFT", "CENTER", "RIGHT", "BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT"},
                        },
                        xOffset = {
                            order = 2,
                            type = "range",
                            name = L["X Offset"],
                            desc = L._Bars("xOffsetObjectiveDesc"),
                            min = -self.OffsetX,
                            max = self.OffsetX,
                        },
                        yOffset = {
                            order = 3,
                            type = "range",
                            name = L["Y Offset"],
                            desc = L._Bars("yOffsetObjectiveDesc"),
                            min = -self.OffsetY,
                            max = self.OffsetY,
                        },
                    },
                },
            },
        }
    }

    self.configOptions = options
    self:UpdateBars()

    return options
end
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function addon:GetHelpOptions()
    local options = {
        alertFormats = {
            order = 2,
            type = "group",
            name = L["Alert Formats"],
            args = {},
        },
        barAlertFormats = {
            order = 2,
            type = "group",
            name = L["Bar Alert Formats"],
            args = {},
        },
        bars = {
            order = 3,
            type = "group",
            name = L["Bars"],
            args = {},
        },
        buttons = {
            order = 4,
            type = "group",
            name = L["Buttons"],
            args = {},
        },
        mixedItems = {
            order = 5,
            type = "group",
            name = L["Mixed Items"],
            args = {},
        },
        objectiveBuilder = {
            order = 6,
            type = "group",
            name = L["Objective Builder"],
            args = {},
        },
        shoppingLists = {
            order = 7,
            type = "group",
            name = L["Shopping Lists"],
            args = {},
        },
        templates = {
            order = 8,
            type = "group",
            name = L["Templates"],
            args = {},
        },
    }

    for strKey, strValue in pairs(L._Help(L, "base")) do
        local line = {
            order = strValue[2],
            type = strValue[3] and "header" or "description",
            name = strValue[1],
        }

        options[strKey] = line
    end

    for optionsKey, optionsTable in pairs(options) do
        for strKey, strValue in pairs(L._Help(L, optionsKey, (optionsKey == "bars" or optionsKey == "buttons") and self.maxButtons)) do
            local line = {
                order = strValue[2],
                type = strValue[3] and "header" or "description",
                name = strValue[1],
            }

            optionsTable.args[strKey] = line
        end
    end

    return options
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function addon:GetSettingsOptions()
    local options = {
        alertFormatsGroup = {
            order = 0,
            type = "group",
            name = L["Alert Formats"],
            args = {
                options = {
                    order = 1,
                    type = "group",
                    name = L["Button Options"],
                    inline = true,
                    get = function(...) return self:GetDBValue("global.alertFormats", ...) end,
                    set = function(...) return self:SetDBValue("global.alertFormats", ...) end,
                    args = {
                        objectivePreview = {
                            order = 1,
                            type = "range",
                            name = L["Objective Preview"],
                            desc = L._Settings("objectivePreviewRangeDesc"),
                            min = 1,
                            max = 5000,
                            step = 1
                        },
                        newCountPreview = {
                            order = 2,
                            type = "range",
                            name = L["New Count Preview"],
                            desc = L._Settings("newCountPreviewRangeDesc"),
                            min = 0,
                            max = 5000,
                            step = 1
                        },
                        oldCountPreview = {
                            order = 3,
                            type = "range",
                            name = L["Old Count Preview"],
                            desc = L._Settings("oldCountPreviewRangeDesc"),
                            min = 0,
                            max = 5000,
                            step = 1
                        },
                    },
                },

                buttonAlerts = {
                    order = 2,
                    type = "group",
                    name = L["Button Alerts"],
                    inline = true,
                    get = function(...) return self:GetDBValue("global.alertFormats", ...) end,
                    set = function(...) return self:SetDBValue("global.alertFormats", ...) end,
                    args = {
                        hasObjective = {
                            order = 1,
                            type = "input",
                            width = "full",
                            name = L["Has Objective"],
                            validate = function(info, value)
                                local success, err = pcall(addon["ParseAlert"], addon, value, {objectiveTitle = "My Special Flower Objective", objective = self:GetDBValue("global.alertFormats", "objectivePreview"), objectiveName = "Zin'anthid", oldCount = self:GetDBValue("global.alertFormats", "oldCountPreview"), newCount = self:GetDBValue("global.alertFormats", "newCountPreview"), difference = (self:GetDBValue("global.alertFormats", "newCountPreview") - self:GetDBValue("global.alertFormats", "oldCountPreview"))})
                                return success or err
                            end,
                            desc = L._Settings("hasObjectiveInputDesc"),
                        },
                        hasObjectivePreview = {
                            order = 2,
                            type = "input",
                            width = "full",
                            name = L["Preview"],
                            disabled = true,
                            get = function(info, ...)
                                if tonumber(self:GetDBValue("global.alertFormats", "newCountPreview")) == tonumber(self:GetDBValue("global.alertFormats", "oldCountPreview")) then return L.GetErrorMessage("invalidCountDifference") end

                                local success, err = pcall(addon["ParseAlert"], addon, self:GetDBValue("global.alertFormats", "hasObjective"), {objectiveTitle = "My Special Flower Objective", objective = self:GetDBValue("global.alertFormats", "objectivePreview"), objectiveName = "Zin'anthid", oldCount = self:GetDBValue("global.alertFormats", "oldCountPreview"), newCount = self:GetDBValue("global.alertFormats", "newCountPreview"), difference = (self:GetDBValue("global.alertFormats", "newCountPreview") - self:GetDBValue("global.alertFormats", "oldCountPreview"))})
                                return err
                            end,
                        },
                        resetHasObjective = {
                            order = 3,
                            type = "execute",
                            name = L["Reset"],
                            desc = L._Settings("resetHasObjectiveDesc"),
                            confirm = function() return L._Settings("resetHasObjectiveConfirm") end,
                            func = function()
                                self:SetDBValue("global.alertFormats", "hasObjective", self.hasObjective)
                            end,
                        },
                        noObjective = {
                            order = 4,
                            type = "input",
                            width = "full",
                            name = L["No Objective"],
                            validate = function(info, value)
                                local success, err = pcall(addon["ParseAlert"], addon, value, {objectiveTitle = "My Special Flower Objective", objective = false, objectiveName = "Zin'anthid", oldCount = self:GetDBValue("global.alertFormats", "oldCountPreview"), newCount = self:GetDBValue("global.alertFormats", "newCountPreview"), difference = (self:GetDBValue("global.alertFormats", "newCountPreview") - self:GetDBValue("global.alertFormats", "oldCountPreview"))})
                                return success or err
                            end,
                            desc = L._Settings("noObjectiveInputDesc"),
                        },
                        noObjectivePreview = {
                            order = 5,
                            type = "input",
                            width = "full",
                            name = L["Preview"],
                            disabled = true,
                            get = function(info, ...)
                                if tonumber(self:GetDBValue("global.alertFormats", "newCountPreview")) == tonumber(self:GetDBValue("global.alertFormats", "oldCountPreview")) then return L.GetErrorMessage("invalidCountDifference") end

                                local success, err = pcall(addon["ParseAlert"], addon, self:GetDBValue("global.alertFormats", "noObjective"), {objectiveTitle = "My Special Flower Objective", objective = false, objectiveName = "Zin'anthid", oldCount = self:GetDBValue("global.alertFormats", "oldCountPreview"), newCount = self:GetDBValue("global.alertFormats", "newCountPreview"), difference = (self:GetDBValue("global.alertFormats", "newCountPreview") - self:GetDBValue("global.alertFormats", "oldCountPreview"))})
                                return err
                            end,
                        },
                        resetNoObjective = {
                            order = 6,
                            type = "execute",
                            name = L["Reset"],
                            desc = L._Settings("resetNoObjectiveDesc"),
                            confirm = function() return L._Settings("resetNoObjectiveConfirm") end,
                            func = function()
                                self:SetDBValue("global.alertFormats", "noObjective", self.noObjective)
                            end,
                        },
                    },
                },

                help = {
                    order = 3,
                    type = "execute",
                    name = L["Help"] .. "!",
                    desc = L._Settings("helpExecuteDesc"),
                    func = function()
                        ACD:SelectGroup(L.addonName, "help", "alertFormats")
                    end,
                },

                barOptions = {
                    order = 4,
                    type = "group",
                    name = L["Bar Options"],
                    inline = true,
                    get = function(...) return self:GetDBValue("global.alertFormats", ...) end,
                    set = function(...) return self:SetDBValue("global.alertFormats", ...) end,
                    args = {
                        barCountPreview = {
                            order = 1,
                            type = "range",
                            name = L["Progress Count"],
                            desc = L._Settings("barCountPreviewRangeDesc"),
                            min = 0,
                            max = self.maxButtons,
                            step = 1
                        },
                        barTotalPreview = {
                            order = 2,
                            type = "range",
                            name = L["Progress Total"],
                            desc = L._Settings("barTotalPreviewRangeDesc"),
                            min = 1,
                            max = self.maxButtons,
                            step = 1
                        },
                        barTitlePreview = {
                            order = 3,
                            type = "toggle",
                            name = L["Bar Has Name"],
                            desc = L._Settings("barTitlePreviewToggleDesc"),
                        },
                    },
                },

                barAlerts = {
                    order = 5,
                    type = "group",
                    name = L["Bar Alerts"],
                    inline = true,
                    get = function(...) return self:GetDBValue("global.alertFormats", ...) end,
                    set = function(...) return self:SetDBValue("global.alertFormats", ...) end,
                    args = {
                        barProgress = {
                            order = 1,
                            type = "input",
                            width = "full",
                            name = L["Bar Progress"],
                            validate = function(info, value)
                                if tonumber(self:GetDBValue("global.alertFormats", "barCountPreview")) > tonumber(self:GetDBValue("global.alertFormats", "barTotalPreview")) then return L.GetErrorMessage("invalidProgressDifference") end

                                local alertInfo = {id = 1, desc = L._Settings("sampleBarTitle"), count = self:GetDBValue("global.alertFormats", "barCountPreview"), total = self:GetDBValue("global.alertFormats", "barTotalPreview")}
                                local success, err = pcall(addon["ParseBarAlert"], addon, self:GetDBValue("global.alertFormats", "barProgress"), alertInfo)
                                return success or err
                            end,
                            desc = L._Settings("barProgressInputDesc"),
                        },
                        barProgressPreview = {
                            order = 2,
                            type = "input",
                            width = "full",
                            name = L["Preview"],
                            disabled = true,
                            get = function(info, ...)
                                if tonumber(self:GetDBValue("global.alertFormats", "barCountPreview")) > tonumber(self:GetDBValue("global.alertFormats", "barTotalPreview")) then return L.GetErrorMessage("invalidProgressDifference") end

                                local alertInfo = {id = 1, desc = self:GetDBValue("global.alertFormats", "barTitlePreview") and L._Settings("sampleBarTitle") or "", count = self:GetDBValue("global.alertFormats", "barCountPreview"), total = self:GetDBValue("global.alertFormats", "barTotalPreview")}
                                local success, err = pcall(addon["ParseBarAlert"], addon, self:GetDBValue("global.alertFormats", "barProgress"), alertInfo)
                                return err
                            end,
                        },
                        resetBarProgress = {
                            order = 3,
                            type = "execute",
                            name = L["Reset"],
                            desc = L._Settings("resetBarProgressDesc"),
                            confirm = function() return L._Settings("resetBarProgressConfirm") end,
                            func = function()
                                self:SetDBValue("global.alertFormats", "barProgress", self.barProgress)
                            end,
                        },
                    },
                },

                barHelp = {
                    order = 6,
                    type = "execute",
                    name = L["Help"] .. "!",
                    desc = L._Settings("helpBarExecuteDesc"),
                    func = function()
                        ACD:SelectGroup(L.addonName, "help", "barAlertFormats")
                    end,
                },
            },
        },

        profileGroup = {
            order = 1,
            type = "group",
            name = L["Profile Settings"],
            args = {

                name = {
                    order = 1,
                    type = "select",
                    style = "dropdown",
                    name = L["Skin"],
                    desc = L._Settings("skinDropDownDesc"),
                    values = function()
                        local values = {
                            default = strupper(L["default"]),
                            minimal = strupper(L["minimal"]),
                        }

                        for k, v in pairs(self.db.global.skins) do
                            values[k] = k
                        end

                        return values
                    end,
                    sorting = function(info)
                        local temp = {
                            [1] = "default",
                            [2] = "minimal",
                        }

                        for k, v in U.pairs(self.db.global.skins) do
                            temp[#temp + 1] = k
                        end

                        return temp
                    end,
                    get = function(...) return self:GetDBValue("profile.style.skin", ...) end,
                    set = function(info, value)
                        if value == "default" or value == "minimal" then
                            self:SetDBValue("profile.style.skin", "type", "builtin")
                        else
                            self:SetDBValue("profile.style.skin", "type", "user")
                        end

                        self:SetDBValue("profile.style.skin", info, value)
                        self:UpdateSkin()
                    end,
                },

                count = {
                    order = 2,
                    type = "group",
                    inline = true,
                    name = L["Count Text"],
                    args = {
                        type = {
                            order = 1,
                            type = "select",
                            style = "dropdown",
                            name = L["Type"],
                            desc = L._Settings("countColorDropDownDesc"),
                            values = {
                                includeBank = L["Bank Inclusion"],
                                oGlow = L["Item Quality"],
                                custom = L["Custom"],
                            },
                            sorting = {"includeBank", "oGlow", "custom"},
                            get = function(...)
                                return self:GetDBValue("profile.style.count", ...)
                            end,
                            set = function(...)
                                self:SetDBValue("profile.style.count", ...)
                                self:UpdateFonts()
                            end,
                        },
                        color = {
                            order = 2,
                            type = "color",
                            hasAlpha = true,
                            name = L["Color"],
                            get = function(...)
                                return U.unpack(self:GetDBValue("profile.style.count", ...))
                            end,
                            set = function(info, ...)
                                self:SetDBValue("profile.style.count", info, {...})
                                self:UpdateFonts()
                            end,
                            disabled = function() return self.db.profile.style.count.type ~= "custom" end,
                        },
                    },
                },

                layers = {
                    order = 3,
                    type = "group",
                    inline = true,
                    name = L["Button Layers"],
                    args = {
                        AutoCastable = {
                            order = 1,
                            type = "toggle",
                            width = .85,
                            name = L["Bank Overlay"],
                            desc = L._Settings("AutoCastableDesc"),
                            get = function(...) return self:GetDBValue("profile.style.layers", ...) end,
                            set = function(info, value)
                                self:SetDBValue("profile.style.layers", info, value)
                                self:UpdateButtonLayer(info[#info])
                            end,
                        },
                        Border = {
                            order = 2,
                            type = "toggle",
                            width = .85,
                            name = L["Item Quality"],
                            desc = L._Settings("BorderDesc"),
                            get = function(...) return self:GetDBValue("profile.style.layers", ...) end,
                            set = function(info, value)
                                self:SetDBValue("profile.style.layers", info, value)
                                self:UpdateButtonLayer(info[#info])
                            end,
                        },
                        Cooldown = {
                            order = 3,
                            type = "toggle",
                            width = .85,
                            name = L["Cooldown Swipe"],
                            desc = L._Settings("CooldownDesc"),
                            get = function(...) return self:GetDBValue("profile.style.layers", ...) end,
                            set = function(info, value)
                                self:SetDBValue("profile.style.layers", info, value)
                                self:UpdateButtonLayer(info[#info])
                            end,
                        },
                        CooldownEdge = {
                            order = 4,
                            type = "toggle",
                            width = .85,
                            name = L["Cooldown Edge"],
                            desc = L._Settings("CooldownEdgeDesc"),
                            get = function(...) return self:GetDBValue("profile.style.layers", ...) end,
                            set = function(info, value)
                                self:SetDBValue("profile.style.layers", info, value)
                                self:UpdateButtonLayer(info[#info])
                            end,
                        },

                    },
                },

                font = {
                    order = 4,
                    type = "group",
                    inline = true,
                    name = L["Font"],
                    get = function(info) return self:GetDBValue("profile.style.font", info, barID) end,
                    set = function(info, value)
                        self:SetDBValue("profile.style.font", info, value, barID)
                        self:UpdateFonts()
                    end,
                    args = {
                        profileFont = {
                            order = 0,
                            type = "description",
                            name = L._Bars("profileFontDesc"),
                        },
                        size = {
                            order = 1,
                            type = "range",
                            name = L["Font Size"],
                            desc =  L._Bars("sizeDesc"),
                            min = self.minFontSize,
                            max = self.maxFontSize,
                            step = 1,
                        },
                        face = {
                            order = 2,
                            type = "select",
                            name = L["Font Face"],
                            desc =  L._Bars("faceDesc"),
                            dialogControl = "LSM30_Font",
                            values = AceGUIWidgetLSMlists.font,
                        },
                        outline = {
                            order = 3,
                            type = "select",
                            name = L["Font Outline"],
                            desc =  L._Bars("outlineDesc"),
                            values = {
                                ["MONOCHROME"] = L["MONOCHROME"],
                                ["OUTLINE"] = L["OUTLINE"],
                                ["THICKOUTLINE"] = L["THICKOUTLINE"],
                                ["NONE"] = L["NONE"],
                            },
                            sorting = {"MONOCHROME", "OUTLINE", "THICKOUTLINE", "NONE"},
                        },
                    },
                },

            },
        },

        alertsGroup = {
            order = 1,
            type = "group",
            inline = true,
            name = L["Alerts"],
            get = function(...) return self:GetDBValue("global.alerts", ...) end,
            set = function(...) return self:SetDBValue("global.alerts", ...) end,
            args = {
                chat = {
                    order = 1,
                    type = "toggle",
                    width = .85,
                    name = L["Chat"],
                    desc = L._Settings("chatToggleDesc"),
                },
                screen = {
                    order = 2,
                    type = "toggle",
                    width = .85,
                    name = L["Screen"],
                    desc = L._Settings("screenToggleDesc"),
                },
                sound = {
                    order = 3,
                    type = "toggle",
                    width = .85,
                    name = L["Sound"],
                    desc = L._Settings("soundToggleDesc"),
                },
                chatFrame = {
                    order = 4,
                    type = "select",
                    name = L["Chat Frame"],
                    desc = L._Settings("chatFrameSelectDesc"),
                    values = function()
                        local values = {}
                        for i = 1, FCF_GetNumActiveChatFrames() do
                            values["ChatFrame"..i] = _G["ChatFrame"..i.."Tab"]:GetText()
                        end
                        return values
                    end,
                },
            },
        },

        barAlertsGroup = {
            order = 2,
            type = "group",
            inline = true,
            name = L["Bar Alerts"],
            get = function(...) return self:GetDBValue("global.alerts", ...) end,
            set = function(...) return self:SetDBValue("global.alerts", ...) end,
            args = {
                barChat = {
                    order = 1,
                    type = "toggle",
                    width = .85,
                    name = L["Chat"],
                    desc = L._Settings("barChatToggleDesc"),
                },
                barScreen = {
                    order = 2,
                    type = "toggle",
                    width = .85,
                    name = L["Screen"],
                    desc = L._Settings("barScreenToggleDesc"),
                },
                barSound = {
                    order = 3,
                    type = "toggle",
                    width = .85,
                    name = L["Sound"],
                    desc = L._Settings("barSoundToggleDesc"),
                },
            },
        },

        commandsGroup = {
            order = 3,
            type = "group",
            inline = true,
            name = L["Command Aliases"],
            get = function(...) return self:GetDBValue("global.commands", ...) end,
            set = function(info, value)
                self:SetDBValue("global.commands", info, value)
                if value then
                    addon:RegisterChatCommand(info[#info], "SlashCommandFunc")
                else
                    self:UnregisterChatCommand(info[#info])
                end
            end,
            args = {
                desc = {
                    order = 1,
                    type = "description",
                    name = L._Settings("commandsDescDesc"),
                },
                farmbar = {
                    order = 2,
                    type = "toggle",
                    width = .85,
                    name = "farmbar",
                    desc = L._Settings("commandsToggleDesc", "farmbar"),
                },
                farm = {
                    order = 3,
                    type = "toggle",
                    width = .85,
                    name = "farm",
                    desc = L._Settings("commandsToggleDesc", "farm"),
                },
                fbar = {
                    order = 4,
                    type = "toggle",
                    width = .85,
                    name = "fbar",
                    desc = L._Settings("commandsToggleDesc", "fbar"),
                },
                fb = {
                    order = 5,
                    type = "toggle",
                    width = .85,
                    name = "fb",
                    desc = L._Settings("commandsToggleDesc", "fb"),
                },
            },
        },

        soundsGroup = {
            order = 4,
            type = "group",
            inline = true,
            name = L["Sounds"],
            get = function(...) return self:GetDBValue("global.sounds", ...) end,
            set = function(...) return self:SetDBValue("global.sounds", ...) end,
            args = {
                barProgress = {
                    order = 1,
                    type = "select",
                    name = L["Bar Progress"],
                    desc =  L._Bars("barProgressDesc"),
                    dialogControl = "LSM30_Sound",
                    values = AceGUIWidgetLSMlists.sound,
                },
                barComplete = {
                    order = 2,
                    type = "select",
                    name = L["Bar Complete"],
                    desc =  L._Bars("barCompleteDesc"),
                    dialogControl = "LSM30_Sound",
                    values = AceGUIWidgetLSMlists.sound,
                },
                farmingProgress = {
                    order = 3,
                    type = "select",
                    name = L["Farming Progress"],
                    desc =  L._Bars("farmingProgressDesc"),
                    dialogControl = "LSM30_Sound",
                    values = AceGUIWidgetLSMlists.sound,
                },
                objectiveCleared = {
                    order = 4,
                    type = "select",
                    name = L["Objective Cleared"],
                    desc =  L._Bars("objectiveClearedDesc"),
                    dialogControl = "LSM30_Sound",
                    values = AceGUIWidgetLSMlists.sound,
                },
                objectiveComplete = {
                    order = 5,
                    type = "select",
                    name = L["Objective Complete"],
                    desc =  L._Bars("objectiveCompleteDesc"),
                    dialogControl = "LSM30_Sound",
                    values = AceGUIWidgetLSMlists.sound,
                },
                objectiveSet = {
                    order = 6,
                    type = "select",
                    name = L["Objective Set"],
                    desc =  L._Bars("objectiveSetDesc"),
                    dialogControl = "LSM30_Sound",
                    values = AceGUIWidgetLSMlists.sound,
                },
            },
        },

        templatesGroup = {
            order = 5,
            type = "group",
            inline = true,
            name = L["Templates"],
            get = function(...) return self:GetDBValue("global.template", ...) end,
            set = function(...) return self:SetDBValue("global.template", ...) end,
            args = {
                includeData = {
                    order = 1,
                    type = "toggle",
                    width = .85,
                    name = L["Include Data"],
                    desc = L._Settings("includeDataTemplatesDesc"),
                },
                includeDataPrompt = {
                    order = 2,
                    type = "toggle",
                    width = .85,
                    name = L["Include Data Prompt"],
                    desc = L._Settings("includeDataPromptTemplatesDesc"),
                },
                saveOrder = {
                    order = 3,
                    type = "toggle",
                    width = .85,
                    name = L["Save Order"],
                    desc = L._Settings("saveOrderTemplatesDesc"),
                },
                saveOrderPrompt = {
                    order = 4,
                    type = "toggle",
                    width = .85,
                    name = L["Save Order Prompt"],
                    desc = L._Settings("saveOrderPromptTemplatesDesc"),
                },
            },
        },

        tooltipsGroup = {
            order = 6,
            type = "group",
            inline = true,
            name = L["Tooltips"],
            get = function(...) return self:GetDBValue("global.tooltips", ...) end,
            set = function(...) return self:SetDBValue("global.tooltips", ...) end,
            args = {
                bar = {
                    order = 1,
                    type = "toggle",
                    width = .85,
                    name = L["Bar"],
                    desc = L._Settings("barTooltipDesc"),
                },
                barTips = {
                    order = 2,
                    type = "toggle",
                    width = .85,
                    name = L["Bar Tips"],
                    desc = L._Settings("barTipTooltipDesc"),
                },
                button = {
                    order = 3,
                    type = "toggle",
                    width = .85,
                    name = L["Button"],
                    desc = L._Settings("buttonTooltipDesc"),
                },
                buttonTips = {
                    order = 4,
                    type = "toggle",
                    width = .85,
                    name = L["Button Tips"],
                    desc = L._Settings("buttonTipTooltipDesc"),
                },
                enableMod = {
                    order = 5,
                    type = "toggle",
                    width = .85,
                    name = L["Enable Modifier"],
                    desc = L._Settings("enableModTooltipDesc"),
                },
                mod = {
                    order = 6,
                    type = "select",
                    style = "dropdown",
                    name = L["Modifier"],
                    desc = L._Settings("modTooltipDesc"),
                    values = function()
                        local values = {
                            Alt = L["Alt"],
                            Control = L["Control"],
                            Shift = L["Shift"],
                        }
                        return values
                    end,
                },
            },
        },

        otherGroup = {
            order = 7,
            type = "group",
            inline = true,
            name = L["Other"],
            get = function(...) return self:GetDBValue("global", ...) end,
            set = function(...) return self:SetDBValue("global", ...) end,
            args = {
                autoLootItems = {
                    order = 1,
                    type = "toggle",
                    width = .85,
                    name = L["Auto Loot Items"],
                    desc = L._Settings("autoLootItemsOtherDesc"),
                },
            },
        },
    }

    return options
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function addon:GetStylesOptions()
    local options = {

    }

    return options
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function addon:UpdateBars()
    for k, v in pairs(self.configOptions) do
        if k:find("^bar%d+$") then
            self.configOptions[k] = nil
        end
    end

    for k, v in pairs(self.db.char.bars) do
        if v.enabled then
            self.configOptions[string.format("bar%d", k)] = {
                order = k + 1,
                type = "group",
                childGroups = "tab",
                name = v.desc ~= "" and string.format("%s: %s", L.GetBarIDString(k), v.desc) or L.GetBarIDString(k),
                get = function(info) return self:GetDBValue("char.bars", info, k) end,
                set = function(info, value) return self:SetDBValue("char.bars", info, value, k) end,
                args = self:GetBarOptions(k),
            }
        end
    end
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function addon:GetOptions()
    local options = {
        type = "group",
        name = L.addonName,
        args = {
            about = {
                order = 1,
                type = "group",
                name = L["About"],
                args = self:GetAboutOptions(),
            },

            commands = {
                order = 2,
                type = "group",
                name = L["Commands"],
                args = self:GetCommandsOptions(),
            },

            bars = {
                order = 3,
                type = "group",
                name = L["Bars"],
                args = self:GetBarsOptions(),
            },

            settings = {
                order = 4,
                type = "group",
                name = L["Settings"],
                args = self:GetSettingsOptions(),
            },

            -- styles = {
            --     order = 5,
            --     type = "group",
            --     childGroups = "tab",
            --     name = L["Style Editor"],
            --     args = self:GetStylesOptions(),
            -- },

            profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db),

            help = {
                order = 7,
                type = "group",
                name = L["Help"],
                args = self:GetHelpOptions(),
            },
        },
    }

    options.args.profiles.order = 6

    return options
end