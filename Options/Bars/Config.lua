local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)

function private:GetConfigOptions()
    local options = {
        newBar = {
            order = 1,
            type = "execute",
            name = NEW,
            func = function()
                local barID = private:AddBar()
                private:RefreshOptions("config", "bar" .. barID, "general")
            end,
        },
        removeBar = {
            order = 2,
            type = "select",
            style = "dropdown",
            name = REMOVE,
            values = function()
                local values = {}

                for barID, _ in addon:pairs(private.db.profile.bars) do
                    values[barID] = private:GetBarName(barID)
                end

                return values
            end,
            disabled = function()
                return addon:tcount(private.db.profile.bars) == 0
            end,
            confirm = function(_, value)
                return format(L["Are you sure you want to remove Bar %d?"], value)
            end,
            set = function(_, value)
                private:RemoveBar(value)
                private:RefreshOptions("config")
            end,
        },
        allBars = {
            order = 3,
            type = "group",
            childGroups = "tab",
            name = L["All Bars"],
            get = function(info)
                return private:GetMixedBarDBValues(info)
            end,
            set = function(info, value)
                private:SetMixedBarDBValues(info, value)
            end,
            disabled = function()
                return addon:tcount(private.db.profile.bars) == 0 or not addon:IsEnabled()
            end,
            args = {
                general = {
                    order = 1,
                    type = "group",
                    name = L["General"],
                    args = {
                        alerts = {
                            order = 1,
                            type = "group",
                            inline = true,
                            name = L["Alerts"],
                            get = function(info)
                                return private:GetMixedBarDBValues(info, "alerts")
                            end,
                            set = function(info, value)
                                private:SetMixedBarDBValues(info, value, "alerts")
                            end,
                            args = {
                                barProgress = {
                                    order = 1,
                                    type = "toggle",
                                    tristate = true,
                                    width = "full",
                                    name = L["Bar Progress"],
                                    desc = L["Track the number of completed goals on this bar."],
                                    descStyle = "inline",
                                },
                                completedObjectives = {
                                    order = 2,
                                    type = "toggle",
                                    tristate = true,
                                    width = "full",
                                    name = L["Completed Goals"],
                                    desc = L["Continue tracking farming progress after goal completion."],
                                    descStyle = "inline",
                                },
                                muteAll = {
                                    order = 3,
                                    type = "toggle",
                                    tristate = true,
                                    width = "full",
                                    name = L["Mute All"],
                                    desc = L["Mute all alerts on this bar."],
                                    descStyle = "inline",
                                },
                                chatFrame = {
                                    order = 4,
                                    type = "select",
                                    name = L["Chat Frame"],
                                    desc = L["Chat frame for chat alerts from this bar."],
                                    values = function()
                                        local values = {}
                                        for i = 1, NUM_CHAT_WINDOWS do
                                            local name = GetChatWindowInfo(i)
                                            if name ~= "" then
                                                values["ChatFrame" .. i] = name
                                            end
                                        end
                                        return values
                                    end,
                                    sorting = function()
                                        local values = {}
                                        local sorting = {}

                                        for i = 1, NUM_CHAT_WINDOWS do
                                            local name = GetChatWindowInfo(i)
                                            if name ~= "" then
                                                values[name] = "ChatFrame" .. i
                                            end
                                        end

                                        for name, frame in addon:pairs(values) do
                                            tinsert(sorting, frame)
                                        end

                                        return sorting
                                    end,
                                },
                            },
                        },
                        limitMats = {
                            order = 2,
                            type = "toggle",
                            tristate = true,
                            width = "full",
                            name = L["Limit Mats"],
                            desc = L["Objectives on this bar cannot use materials already accounted for by another objective on the same bar."],
                            descStyle = "inline",
                            set = function(info, value)
                                private:SetMixedBarDBValues(info, value, _, function(barID)
                                    private.bars[barID]:UpdateButtons()
                                end)
                            end,
                        },
                    },
                },
                appearance = {
                    order = 2,
                    type = "group",
                    name = L["Appearance"],
                    args = {
                        skin = {
                            order = 1,
                            type = "select",
                            style = "dropdown",
                            name = L["Skin"],
                            values = function()
                                local values = {}

                                for skinName, _ in addon:pairs(private.db.global.skins) do
                                    values[skinName] = skinName
                                end

                                return values
                            end,
                            set = function(info, value)
                                private:SetMixedBarDBValues(info, value, _, function(barID)
                                    private.bars[barID]:SetBackdrop()
                                    private.bars[barID]:UpdateButtonTextures()
                                end)
                            end,
                        },
                        alpha = {
                            order = 2,
                            type = "range",
                            min = 0,
                            max = 1,
                            step = 0.01,
                            isPercent = true,
                            name = L["Alpha"],
                            set = function(info, value)
                                private:SetMixedBarDBValues(info, value, _, function(barID)
                                    private.bars[barID]:SetMouseover()
                                end)
                            end,
                        },
                        scale = {
                            order = 2,
                            type = "range",
                            min = private.CONST.MIN_SCALE,
                            max = private.CONST.MAX_SCALE,
                            step = 0.01,
                            isPercent = true,
                            name = L["Scale"],
                            set = function(info, value)
                                private:SetMixedBarDBValues(info, value, _, function(barID)
                                    private.bars[barID]:SetScale()
                                end)
                            end,
                        },
                        mouseover = {
                            order = 3,
                            type = "toggle",
                            name = L["Mouseover"],
                            desc = L["Show this bar only on mouseover."],
                            set = function(info, value)
                                private:SetMixedBarDBValues(info, value, _, function(barID)
                                    private.bars[barID]:SetMouseover()
                                end)
                            end,
                        },
                        showEmpty = {
                            order = 3,
                            type = "toggle",
                            name = L["Show Empty"],
                            desc = L["Shows a backdrop on empty buttons."],
                            set = function(info, value)
                                private:SetMixedBarDBValues(info, value, _, function(barID)
                                    private.bars[barID]:SetMouseover()
                                end)
                            end,
                        },
                        showCooldown = {
                            order = 4,
                            type = "toggle",
                            name = L["Show Cooldown"],
                            desc = L["Shows the cooldown swipe animation on buttons."],
                            set = function(info, value)
                                private:SetMixedBarDBValues(info, value, _, function(barID)
                                    addon:SPELL_UPDATE_COOLDOWN()
                                end)
                            end,
                        },
                        overrideHidden = {
                            order = 5,
                            type = "toggle",
                            tristate = true,
                            name = L["Hidden (Override Func)"],
                            desc = L["Hides the bar, regardless of the output from the custom hidden function."],
                            set = function(info, value)
                                private:SetMixedBarDBValues(info, value, _, function(barID)
                                    private.bars[barID]:SetHidden()
                                end)
                            end,
                        },
                    },
                },
                layout = {
                    order = 3,
                    type = "group",
                    name = L["Layout"],
                    get = function(info)
                        return private:GetMixedBarDBValues(info)
                    end,
                    set = function(info, value)
                        private:SetMixedBarDBValues(info, value, _, function(barID)
                            private.bars[barID]:SetPoints()
                        end)
                    end,
                    args = {
                        barAnchor = {
                            order = 1,
                            type = "select",
                            style = "dropdown",
                            name = L["Bar Anchor"],
                            desc = L["Set the anchor of the button to the bar."],
                            values = private.lists.barAnchor,
                        },
                        buttonGrowth = {
                            order = 2,
                            type = "select",
                            style = "dropdown",
                            name = L["Button Growth"],
                            desc = L["Set the direction buttons grow: row (horizontally) or col (vertically)."],
                            values = private.lists.buttonGrowth,
                        },
                        movable = {
                            order = 3,
                            type = "toggle",
                            name = L["Movable"],
                            set = function(info, value)
                                private:SetMixedBarDBValues(info, value, _, function(barID)
                                    private.bars[barID]:SetMovable()
                                end)
                            end,
                        },
                        buttons = {
                            order = 4,
                            type = "group",
                            inline = true,
                            name = L["Buttons"],
                            args = {
                                numButtons = {
                                    order = 1,
                                    type = "range",
                                    min = 1,
                                    max = private.CONST.MAX_BUTTONS,
                                    step = 1,
                                    name = L["Buttons"],
                                    desc = L["Set the number of buttons per bar."],
                                    set = function(info, value)
                                        private:SetMixedBarDBValues(info, value, _, function(barID)
                                            private.bars[barID]:DrawButtons()
                                            private.bars[barID]:LayoutButtons()
                                            private.bars[barID]:SetScale()
                                        end)
                                    end,
                                },
                                buttonsPerAxis = {
                                    order = 2,
                                    type = "range",
                                    min = 1,
                                    max = private.CONST.MAX_BUTTONS,
                                    step = 1,
                                    name = L["Buttons Per Axis"],
                                    desc = L["Set the number of buttons before a bar wraps to a new column or row."],
                                },
                                buttonPadding = {
                                    order = 3,
                                    type = "range",
                                    min = private.CONST.MIN_PADDING,
                                    max = private.CONST.MAX_PADDING,
                                    step = 1,
                                    name = L["Button Padding"],
                                    desc = L["Set the spacing between buttons."],
                                },
                                buttonSize = {
                                    order = 4,
                                    type = "range",
                                    min = private.CONST.MIN_BUTTON_SIZE,
                                    max = private.CONST.MAX_BUTTON_SIZE,
                                    step = 1,
                                    name = L["Button Size"],
                                },
                            },
                        },
                    },
                },
            },
        },
    }

    local i = 101
    for fontName, fontDB in addon:pairs(private.defaults.bar.fontstrings) do
        options.allBars.args.appearance.args[fontName] = {
            order = i,
            type = "group",
            inline = true,
            name = format(L["%s Text"], fontName),
            get = function(info)
                return private:GetMixedBarDBValues(info, "fontstrings", fontName)
            end,
            set = function(info, value)
                private:SetMixedBarDBValues(info, value, "fontstrings", function(barID)
                    private.bars[barID]:UpdateFontstrings()
                end, fontName)
            end,
            args = {
                enabled = {
                    order = 1,
                    type = "toggle",
                    name = L["Enable"],
                },
                color = {
                    order = 2,
                    type = "color",
                    hasAlpha = true,
                    name = L["Color"],
                    set = function(info, ...)
                        for barID, bar in pairs(private.bars) do
                            private.db.profile.bars[barID].fontstrings[fontName][info[#info]] = { ... }
                            private.bars[barID]:UpdateFontstrings()
                        end
                    end,
                },
                spacer = {
                    order = 3,
                    type = "description",
                    width = "full",
                    name = " ",
                },
                face = {
                    order = 4,
                    type = "select",
                    style = "dropdown",
                    dialogControl = "LSM30_Font",
                    name = L["Font Face"],
                    values = AceGUIWidgetLSMlists.font,
                },
                outline = {
                    order = 5,
                    type = "select",
                    style = "dropdown",
                    name = L["Font Outline"],
                    values = private.lists.outlines,
                },
                size = {
                    order = 6,
                    type = "range",
                    min = private.CONST.MIN_FONT_SIZE,
                    max = private.CONST.MAX_FONT_SIZE,
                    step = 1,
                    name = L["Font Size"],
                },
            },
        }

        options.allBars.args.layout.args[fontName] = {
            order = i,
            type = "group",
            inline = true,
            name = format(L["%s Text"], fontName),
            get = function(info)
                return private:GetMixedBarDBValues(info, "fontstrings", fontName)
            end,
            set = function(info, value)
                private:SetMixedBarDBValues(info, value, "fontstrings", function(barID)
                    private.bars[barID]:UpdateFontstrings()
                end, fontName)
            end,
            args = {
                anchor = {
                    order = 1,
                    type = "select",
                    style = "dropdown",
                    name = L["Anchor"],
                    values = private.lists.anchors,
                },
                x = {
                    order = 2,
                    type = "range",
                    min = -private.CONST.MIN_MAX_XOFFSET,
                    max = private.CONST.MIN_MAX_XOFFSET,
                    step = 1,
                    name = L["X-Offset"],
                },
                y = {
                    order = 3,
                    type = "range",
                    min = -private.CONST.MIN_MAX_YOFFSET,
                    max = private.CONST.MIN_MAX_YOFFSET,
                    step = 1,
                    name = L["Y-Offset"],
                },
            },
        }
        i = i + 1
    end

    local i = 100
    for barID, bar in pairs(private.db.profile.bars) do
        options["bar" .. barID] = {
            order = barID + i,
            type = "group",
            childGroups = "tab",
            name = private:GetBarName(barID),
            args = private:GetBarOptions(barID),
        }
        i = i + 1
    end

    return options
end
