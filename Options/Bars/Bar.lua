local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)

function private:GetBarOptions(barID)
    local barDB = private.db.profile.bars[barID]

    local options = {
        general = {
            order = 1,
            type = "group",
            name = L["General"],
            get = function(info)
                return barDB[info[#info]]
            end,
            set = function(info, value)
                private.db.profile.bars[barID][info[#info]] = value
            end,
            args = {
                label = {
                    order = 1,
                    type = "input",
                    width = "full",
                    name = L["Label"],
                },
                alerts = {
                    order = 2,
                    type = "group",
                    inline = true,
                    name = L["Alerts"],
                    get = function(info)
                        return barDB.alerts[info[#info]]
                    end,
                    set = function(info, value)
                        private.db.profile.bars[barID].alerts[info[#info]] = value
                    end,
                    args = {
                        barProgress = {
                            order = 1,
                            type = "toggle",
                            width = "full",
                            name = L["Bar Progress"],
                            desc = L["Track the number of completed objectives on this bar."],
                            descStyle = "inline",
                        },
                        completedObjectives = {
                            order = 2,
                            type = "toggle",
                            width = "full",
                            name = L["Completed Objectives"],
                            desc = L["Continue tracking objectives after completion."],
                            descStyle = "inline",
                        },
                        muteAll = {
                            order = 3,
                            type = "toggle",
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

                                for name, frame in addon.pairs(values) do
                                    tinsert(sorting, frame)
                                end

                                return sorting
                            end,
                        },
                    },
                },
                limitMats = {
                    order = 3,
                    type = "toggle",
                    width = "full",
                    name = L["Limit Mats"],
                    desc = L["Objectives on this bar cannot use materials already accounted for by another objective on the same bar."],
                    descStyle = "inline",
                    set = function(info, value)
                        private.db.profile.bars[barID][info[#info]] = value
                        private.bars[barID]:UpdateButtons()
                    end,
                },
                manage = {
                    order = 3,
                    type = "group",
                    inline = true,
                    name = L["Manage"],
                    args = {
                        templates = {
                            order = 1,
                            type = "group",
                            inline = true,
                            name = L["Templates"],
                            args = {
                                saveAsTemplate = {
                                    order = 1,
                                    type = "input",
                                    name = L["Save as Template"],
                                    set = function(_, value)
                                        if value and value ~= "" and not private:TemplateExists(value) then
                                            private:SaveTemplate(barID, value)
                                            private:RefreshOptions()
                                        end
                                    end,
                                    validate = function(_, value)
                                        if not value or value == "" then
                                            return L["Invalid template name."]
                                        elseif private:TemplateExists(value) then
                                            return L["Template exists."]
                                        else
                                            return true
                                        end
                                    end,
                                },
                                builtInTemplates = {
                                    order = 2,
                                    disabled = true,
                                    type = "select",
                                    style = "dropdown",
                                    name = L["Templates"],
                                    disabled = function()
                                        return addon.tcount(private.templates) == 0
                                    end,
                                    values = function()
                                        local values = {}

                                        for templateName, _ in pairs(private.templates) do
                                            values[templateName] = templateName
                                        end

                                        return values
                                    end,
                                    set = function(_, value)
                                        private:LoadTemplate(barID, value)
                                    end,
                                },
                                userTemplates = {
                                    order = 2,
                                    type = "select",
                                    style = "dropdown",
                                    name = L["User Templates"],
                                    disabled = function()
                                        return addon.tcount(private.db.global.templates) == 0
                                    end,
                                    values = function()
                                        local values = {}

                                        for templateName, _ in pairs(private.db.global.templates) do
                                            values[templateName] = templateName
                                        end

                                        return values
                                    end,
                                    set = function(_, value)
                                        private.db.profile.bars[barID].buttons =
                                            addon.CloneTable(private.db.global.templates[value])
                                        private.bars[barID]:UpdateButtons()
                                    end,
                                },
                                clear = {
                                    order = 3,
                                    type = "execute",
                                    name = L["Clear Bar"],
                                    func = function()
                                        for _, button in pairs(private.bars[barID]:GetButtons()) do
                                            if not button:IsEmpty() then
                                                button:Clear()
                                            end
                                        end
                                    end,
                                    confirm = function()
                                        return format(L["Are you sure you want to clear Bar %d?"], barID)
                                    end,
                                },
                            },
                        },
                        copyFrom = {
                            order = 2,
                            type = "select",
                            style = "dropdown",
                            name = L["Copy From"],
                            values = function()
                                local values = {}

                                for BarID, _ in addon.pairs(private.db.profile.bars) do
                                    if BarID ~= barID then
                                        values[BarID] = private:GetBarName(BarID)
                                    end
                                end

                                return values
                            end,
                            disabled = function()
                                return addon.tcount(private.db.profile.bars) == 1
                            end,
                            set = function(_, value)
                                private:CopyBarDB(value, barID)
                                private:RefreshOptions()
                                private.bars[barID]:UpdateButtonTextures()
                            end,
                        },
                        duplicateBar = {
                            order = 3,
                            type = "execute",
                            name = L["Duplicate"],
                            func = function()
                                local newBarID = private:DuplicateBar(barID)
                                private:RefreshOptions("config", "bar" .. newBarID, "general")
                            end,
                        },
                        removeBar = {
                            order = 3,
                            type = "execute",
                            name = REMOVE,
                            confirm = function()
                                return format(L["Are you sure you want to remove Bar %d?"], barID)
                            end,
                            func = function()
                                private:RemoveBar(barID)
                                private:RefreshOptions("config")
                            end,
                        },
                    },
                },
            },
        },
        appearance = {
            order = 2,
            type = "group",
            name = L["Appearance"],
            get = function(info)
                return barDB[info[#info]]
            end,
            set = function(info, value)
                private.db.profile.bars[barID][info[#info]] = value
            end,
            args = {
                skin = {
                    order = 1,
                    type = "select",
                    style = "dropdown",
                    name = L["Skin"],
                    values = function()
                        local values = {}

                        for skinName, _ in addon.pairs(private.db.global.skins) do
                            values[skinName] = skinName
                        end

                        return values
                    end,
                    set = function(info, value)
                        private.db.profile.bars[barID][info[#info]] = value
                        private.bars[barID]:SetBackdrop()
                        private.bars[barID]:UpdateButtonTextures()
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
                        private.db.profile.bars[barID][info[#info]] = value
                        private.bars[barID]:SetMouseover()
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
                        private.db.profile.bars[barID][info[#info]] = value
                        private.bars[barID]:SetScale()
                    end,
                },
                mouseover = {
                    order = 3,
                    type = "toggle",
                    name = L["Mouseover"],
                    desc = L["Show this bar only on mouseover."],
                    set = function(info, value)
                        private.db.profile.bars[barID][info[#info]] = value
                        private.bars[barID]:SetMouseover()
                    end,
                },
                showEmpty = {
                    order = 3,
                    type = "toggle",
                    name = L["Show Empty"],
                    desc = L["Shows a backdrop on empty buttons."],
                    set = function(info, value)
                        private.db.profile.bars[barID][info[#info]] = value
                        private.bars[barID]:SetMouseover()
                    end,
                },
                showCooldown = {
                    order = 4,
                    type = "toggle",
                    name = L["Show Cooldown"],
                    desc = L["Shows the cooldown swipe animation on buttons."],
                    set = function(info, value)
                        private.db.profile.bars[barID][info[#info]] = value
                        addon:SPELL_UPDATE_COOLDOWN()
                    end,
                },
                hidden = {
                    order = 5,
                    type = "group",
                    inline = true,
                    name = L["Hidden"],
                    get = function(info)
                        return barDB[info[#info]]
                    end,
                    set = function(info, value)
                        private.db.profile.bars[barID][info[#info]] = value
                        private.bars[barID]:SetHidden()
                    end,
                    args = {
                        overrideHidden = {
                            order = 1,
                            type = "toggle",
                            name = L["Hidden (Override Func)"],
                        },
                        hiddenEvents = {
                            order = 2,
                            type = "input",
                            width = "full",
                            name = L["Events"],
                            desc = L["Refresh hidden status on these events."],
                            get = function(info)
                                return table.concat(barDB[info[#info]], ",")
                            end,
                            set = function(info, value)
                                value = gsub(value, " ", "")
                                local events = { strsplit(",", value) }

                                private.db.profile.bars[barID][info[#info]] = value == "" and {} or events
                                private.bars[barID]:SetEvents()
                            end,
                            validate = function(info, value)
                                if value == "" then
                                    return true
                                end

                                value = gsub(value, " ", "")
                                local events = { strsplit(",", value) }

                                for _, event in pairs(events) do
                                    local frame = private.bars[barID].frame
                                    local success = pcall(frame.RegisterEvent, frame, event)
                                    if not success then
                                        return format(L["Event \"%s\" doesn't exist."], event)
                                    end
                                end

                                return true
                            end,
                        },
                        hidden = {
                            order = 3,
                            type = "input",
                            width = "full",
                            dialogControl = "FarmingBar_LuaEditBox",
                            multiline = true,
                            name = L["Hidden"],
                            validate = function(_, value)
                                return private:ValidateHiddenFunc(value)
                            end,
                            arg = function(value)
                                return private:ValidateHiddenFunc(value)
                            end,
                        },
                        resetHidden = {
                            order = 4,
                            type = "execute",
                            name = RESET,
                            func = function(info)
                                private.db.profile.bars[barID].hidden = private.defaults.bar.hidden
                                private.bars[barID]:SetHidden()
                            end,
                            confirm = function()
                                return L["Are you sure you want to reset this bar's hidden function?"]
                            end,
                        },
                    },
                },
            },
        },
        layout = {
            order = 3,
            type = "group",
            name = L["Layout"],
            get = function(info)
                return barDB[info[#info]]
            end,
            set = function(info, value)
                private.db.profile.bars[barID][info[#info]] = value
                private.bars[barID]:SetPoints()
            end,
            args = {
                barAnchor = {
                    order = 1,
                    type = "select",
                    style = "dropdown",
                    name = L["Bar Anchor"],
                    values = private.lists.barAnchor,
                },
                buttonGrowth = {
                    order = 2,
                    type = "select",
                    style = "dropdown",
                    name = L["Button Growth"],
                    values = private.lists.buttonGrowth,
                },
                movable = {
                    order = 3,
                    type = "toggle",
                    name = L["Movable"],
                    set = function(info, value)
                        private.db.profile.bars[barID][info[#info]] = value
                        private.bars[barID]:SetMovable()
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
                            set = function(info, value)
                                private.db.profile.bars[barID][info[#info]] = value
                                private.bars[barID]:DrawButtons()
                                private.bars[barID]:LayoutButtons()
                                private.bars[barID]:SetScale()
                            end,
                        },
                        buttonsPerAxis = {
                            order = 2,
                            type = "range",
                            min = 1,
                            max = private.CONST.MAX_BUTTONS,
                            step = 1,
                            name = L["Buttons Per Axis"],
                        },
                        buttonPadding = {
                            order = 3,
                            type = "range",
                            min = private.CONST.MIN_PADDING,
                            max = private.CONST.MAX_PADDING,
                            step = 1,
                            name = L["Button Padding"],
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
    }

    local i = 101
    for fontName, fontDB in addon.pairs(barDB.fontstrings) do
        options.appearance.args[fontName] = {
            order = i,
            type = "group",
            inline = true,
            name = format(L["%s Text"], fontName),
            get = function(info)
                return fontDB[info[#info]]
            end,
            set = function(info, value)
                private.db.profile.bars[barID].fontstrings[fontName][info[#info]] = value
                private.bars[barID]:UpdateFontstrings()
            end,
            args = {
                enabled = {
                    order = 1,
                    type = "toggle",
                    name = L["Enable"],
                },
                showEdge = {
                    order = 2,
                    type = "toggle",
                    name = L["Show Edge"],
                    hidden = function()
                        return fontName ~= "Cooldown"
                    end,
                },
                color = {
                    order = 3,
                    type = "color",
                    hasAlpha = true,
                    name = L["Color"],
                    get = function(info)
                        return unpack(fontDB[info[#info]])
                    end,
                    set = function(info, ...)
                        private.db.profile.bars[barID].fontstrings[fontName][info[#info]] = { ... }
                        private.bars[barID]:UpdateFontstrings()
                    end,
                },
                spacer = {
                    order = 4,
                    type = "description",
                    width = "full",
                    name = " ",
                },
                face = {
                    order = 5,
                    type = "select",
                    style = "dropdown",
                    dialogControl = "LSM30_Font",
                    name = L["Font Face"],
                    values = AceGUIWidgetLSMlists.font,
                },
                outline = {
                    order = 6,
                    type = "select",
                    style = "dropdown",
                    name = L["Font Outline"],
                    values = private.lists.outlines,
                },
                size = {
                    order = 7,
                    type = "range",
                    min = private.CONST.MIN_FONT_SIZE,
                    max = private.CONST.MAX_FONT_SIZE,
                    step = 1,
                    name = L["Font Size"],
                },
            },
        }

        options.layout.args[fontName] = {
            order = i,
            type = "group",
            inline = true,
            name = format(L["%s Text"], fontName),
            get = function(info)
                return fontDB[info[#info]]
            end,
            set = function(info, value)
                private.db.profile.bars[barID].fontstrings[fontName][info[#info]] = value
                private.bars[barID]:UpdateFontstrings()
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

    return options
end
