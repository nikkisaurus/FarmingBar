local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)

local anchors = {
    BOTTOMLEFT = true,
    BOTTOMRIGHT = true,
    TOPLEFT = true,
    TOPRIGHT = true,
}

local growth = {
    COL = true,
    ROW = true,
}

local function GetCommandDesc(cmd, desc, ...)
    local args = { ... }

    for key, arg in pairs(args) do
        args[key] = addon.ColorFontString(format("[%s]", arg), "LIGHTRED")
    end

    return strjoin(" ", addon.ColorFontString(cmd, "LIGHTBLUE"), table.concat(args, " ")) .. ": " .. desc
end

function private:GetSlashCommandOptions()
    local options = {
        type = "group",
        name = L.addonName,
        guiHidden = true,
        args = {
            bar = {
                type = "group",
                name = "bar",
                desc = GetCommandDesc(
                    "/farmingbar bar",
                    L["Configure bar settings."],
                    "alpha",
                    "axis",
                    "buttons",
                    "grow",
                    "movable",
                    "padding",
                    "scale",
                    "size"
                ),
                args = {
                    alpha = {
                        type = "execute",
                        name = "",
                        desc = GetCommandDesc("/farmingbar bar alpha", L["Set bar alpha."], "barID | 0", "alpha"),
                        validate = function(info)
                            local _, command, barID, alpha = strsplit(" ", info.input:trim())
                            barID = tonumber(barID)
                            alpha = tonumber(alpha)

                            if not barID or (barID ~= 0 and not private.bars[barID]) then
                                return L["Invalid barID. To apply to all bars, use barID 0."]
                            elseif not alpha or alpha < 0 or alpha > 1 then
                                return L["Invalid alpha value. Please provide an integer between 0 and 1."]
                            end
                            return true
                        end,
                        func = function(info)
                            local _, command, barID, alpha = strsplit(" ", info.input:trim())
                            barID = tonumber(barID)
                            alpha = tonumber(alpha)

                            if barID == 0 then
                                private:SetMixedBarDBValues("alpha", alpha, nil, function(barID)
                                    private.bars[barID]:SetMouseover()
                                end)
                            else
                                private.db.profile.bars[barID].alpha = alpha
                                private.bars[barID]:SetMouseover()
                            end
                        end,
                    },
                    axis = {
                        type = "execute",
                        name = "",
                        desc = GetCommandDesc(
                            "/farmingbar bar axis",
                            L["Set the number of buttons per axis."],
                            "barID | 0",
                            "numButtons"
                        ),
                        validate = function(info)
                            local _, command, barID, numButtons = strsplit(" ", info.input:trim())
                            barID = tonumber(barID)
                            numButtons = tonumber(numButtons)

                            if not barID or (barID ~= 0 and not private.bars[barID]) then
                                return L["Invalid barID. To apply to all bars, use barID 0."]
                            elseif not numButtons or numButtons < 1 or numButtons > private.CONST.MAX_BUTTONS then
                                return format(
                                    L["Please specify the number of buttons from %d to %d."],
                                    1,
                                    private.CONST.MAX_BUTTONS
                                )
                            end
                        end,
                        func = function(info)
                            local _, command, barID, buttonsPerAxis = strsplit(" ", info.input:trim())
                            barID = tonumber(barID)
                            buttonsPerAxis = tonumber(buttonsPerAxis)

                            if barID == 0 then
                                private:SetMixedBarDBValues("buttonsPerAxis", buttonsPerAxis, nil, function(barID)
                                    private.bars[barID]:SetPoints()
                                end)
                            else
                                private.db.profile.bars[barID].buttonsPerAxis = buttonsPerAxis
                                private.bars[barID]:SetPoints()
                            end
                        end,
                    },
                    buttons = {
                        type = "execute",
                        name = "",
                        desc = GetCommandDesc(
                            "/farmingbar bar buttons",
                            L["Set the number of buttons on bar."],
                            "barID | 0",
                            "numButtons"
                        ),
                        validate = function(info)
                            local _, command, barID, numButtons = strsplit(" ", info.input:trim())
                            barID = tonumber(barID)
                            numButtons = tonumber(numButtons)

                            if not barID or (barID ~= 0 and not private.bars[barID]) then
                                return L["Invalid barID. To apply to all bars, use barID 0."]
                            elseif not numButtons or numButtons < 1 or numButtons > private.CONST.MAX_BUTTONS then
                                return format(
                                    L["Please specify a number between %d and %d."],
                                    1,
                                    private.CONST.MAX_BUTTONS
                                )
                            end
                        end,
                        func = function(info)
                            local _, command, barID, numButtons = strsplit(" ", info.input:trim())
                            barID = tonumber(barID)
                            numButtons = tonumber(numButtons)

                            if barID == 0 then
                                private:SetMixedBarDBValues("numButtons", numButtons, nil, function(barID)
                                    private.bars[barID]:DrawButtons()
                                    private.bars[barID]:LayoutButtons()
                                    private.bars[barID]:SetScale()
                                end)
                            else
                                private.db.profile.bars[barID].numButtons = numButtons
                                private.bars[barID]:DrawButtons()
                                private.bars[barID]:LayoutButtons()
                                private.bars[barID]:SetScale()
                            end
                        end,
                    },
                    grow = {
                        type = "execute",
                        name = "",
                        desc = GetCommandDesc(
                            "/farmingbar bar grow",
                            L["Set the direction of bar's growth."],
                            "barID | 0",
                            "bottomleft | bottomright | topleft | topright",
                            "col | row"
                        ),
                        validate = function(info)
                            local _, command, barID, anchor, grow = strsplit(" ", info.input:trim())
                            barID = tonumber(barID)

                            if not barID or (barID ~= 0 and not private.bars[barID]) then
                                return L["Invalid barID. To apply to all bars, use barID 0."]
                            elseif not anchors[strupper(anchor)] then
                                return L["Invalid anchor: bottomleft | bottomright | topleft | topright"]
                            elseif not growth[strupper(grow)] then
                                return L["Invalid growth: col | row"]
                            end
                        end,
                        func = function(info)
                            local _, command, barID, barAnchor, buttonGrowth = strsplit(" ", info.input:trim())
                            barID = tonumber(barID)
                            barAnchor = strupper(barAnchor)
                            buttonGrowth = strupper(buttonGrowth)

                            if barID == 0 then
                                private:SetMixedBarDBValues("barAnchor", barAnchor)
                                private:SetMixedBarDBValues("buttonGrowth", buttonGrowth, nil, function(barID)
                                    private.bars[barID]:SetPoints()
                                end)
                            else
                                private.db.profile.bars[barID].barAnchor = barAnchor
                                private.db.profile.bars[barID].buttonGrowth = buttonGrowth
                                private.bars[barID]:SetPoints()
                            end
                        end,
                    },
                    movable = {
                        type = "execute",
                        name = "",
                        desc = GetCommandDesc(
                            "/farmingbar bar movable",
                            L["Lock or unlock bar."],
                            "barID | 0",
                            "true | false | toggle"
                        ),
                        validate = function(info)
                            local _, command, barID, movable = strsplit(" ", info.input:trim())
                            barID = tonumber(barID)

                            if not barID or (barID ~= 0 and not private.bars[barID]) then
                                return L["Invalid barID. To apply to all bars, use barID 0."]
                            elseif not movable then
                                return L["Please specify movable type: true, false, toggle."]
                            end
                        end,
                        func = function(info)
                            local _, command, barID, movable = strsplit(" ", info.input:trim())
                            barID = tonumber(barID)

                            local function SetMovable(barID)
                                if movable == "true" then
                                    private.db.profile.bars[barID].movable = true
                                elseif movable == "false" then
                                    private.db.profile.bars[barID].movable = false
                                elseif movable == "toggle" then
                                    if private.db.profile.bars[barID].movable then
                                        private.db.profile.bars[barID].movable = false
                                    else
                                        private.db.profile.bars[barID].movable = true
                                    end
                                end
                                private.bars[barID]:SetMovable()
                            end

                            if barID == 0 then
                                for BarID, _ in pairs(private.bars) do
                                    SetMovable(BarID)
                                end
                            else
                                SetMovable(barID)
                            end
                        end,
                    },
                    padding = {
                        type = "execute",
                        name = "",
                        desc = GetCommandDesc(
                            "/farmingbar bar padding",
                            L["Set the padding of bar's buttons."],
                            "barID | 0",
                            "padding"
                        ),
                        validate = function(info)
                            local _, command, barID, padding = strsplit(" ", info.input:trim())
                            barID = tonumber(barID)
                            padding = tonumber(padding)

                            if not barID or (barID ~= 0 and not private.bars[barID]) then
                                return L["Invalid barID. To apply to all bars, use barID 0."]
                            elseif
                                not padding
                                or padding < private.CONST.MIN_PADDING
                                or padding > private.CONST.MAX_PADDING
                            then
                                return format(
                                    L["Please specify a number between %d and %d."],
                                    private.CONST.MIN_PADDING,
                                    private.CONST.MAX_PADDING
                                )
                            end
                        end,
                        func = function(info)
                            local _, command, barID, buttonPadding = strsplit(" ", info.input:trim())
                            barID = tonumber(barID)
                            buttonPadding = tonumber(buttonPadding)

                            if barID == 0 then
                                private:SetMixedBarDBValues("buttonPadding", buttonPadding, nil, function(barID)
                                    private.bars[barID]:SetPoints()
                                end)
                            else
                                private.db.profile.bars[barID].buttonPadding = buttonPadding
                                private.bars[barID]:SetPoints()
                            end
                        end,
                    },
                    scale = {
                        type = "execute",
                        name = "",
                        desc = GetCommandDesc("/farmingbar bar scale", L["Set bar scale."], "barID | 0", "scale"),
                        validate = function(info)
                            local _, command, barID, scale = strsplit(" ", info.input:trim())
                            barID = tonumber(barID)
                            scale = tonumber(scale)

                            if not barID or (barID ~= 0 and not private.bars[barID]) then
                                return L["Invalid barID. To apply to all bars, use barID 0."]
                            elseif not scale or scale < private.CONST.MIN_SCALE or scale > private.CONST.MAX_SCALE then
                                return format(
                                    L["Please specify a number between %s and %s."],
                                    tostring(private.CONST.MIN_SCALE),
                                    tostring(private.CONST.MAX_SCALE)
                                )
                            end
                            return true
                        end,
                        func = function(info)
                            local _, command, barID, scale = strsplit(" ", info.input:trim())
                            barID = tonumber(barID)
                            scale = tonumber(scale)

                            if barID == 0 then
                                private:SetMixedBarDBValues("scale", scale, nil, function(barID)
                                    private.bars[barID]:SetScale()
                                end)
                            else
                                private.db.profile.bars[barID].scale = scale
                                private.bars[barID]:SetScale()
                            end
                        end,
                    },
                    size = {
                        type = "execute",
                        name = "",
                        desc = GetCommandDesc(
                            "/farmingbar bar size",
                            L["Set the size of bar's buttons."],
                            "barID | 0",
                            "buttonSize"
                        ),
                        validate = function(info)
                            local _, command, barID, size = strsplit(" ", info.input:trim())
                            barID = tonumber(barID)
                            size = tonumber(size)

                            if not barID or (barID ~= 0 and not private.bars[barID]) then
                                return L["Invalid barID. To apply to all bars, use barID 0."]
                            elseif
                                not size
                                or size < private.CONST.MIN_BUTTON_SIZE
                                or size > private.CONST.MAX_BUTTON_SIZE
                            then
                                return format(
                                    L["Please specify a number between %d and %d."],
                                    private.CONST.MIN_BUTTON_SIZE,
                                    private.CONST.MAX_BUTTON_SIZE
                                )
                            end
                        end,
                        func = function(info)
                            local _, command, barID, buttonSize = strsplit(" ", info.input:trim())
                            barID = tonumber(barID)
                            buttonSize = tonumber(buttonSize)

                            if barID == 0 then
                                private:SetMixedBarDBValues("buttonSize", buttonSize, nil, function(barID)
                                    private.bars[barID]:SetPoints()
                                end)
                            else
                                private.db.profile.bars[barID].buttonSize = buttonSize
                                private.bars[barID]:SetPoints()
                            end
                        end,
                    },
                },
            },
            disable = {
                type = "execute",
                name = "",
                desc = GetCommandDesc("/farmingbar disable", L["Disable active profile."]),
                func = function()
                    private.db.profile.enabled = false
                    addon:Disable()
                end,
            },
            enable = {
                type = "execute",
                name = "",
                desc = GetCommandDesc("/farmingbar enable", L["Enable active profile."]),
                func = function()
                    private.db.profile.enabled = true
                    addon:Enable()
                end,
            },
            profile = {
                type = "execute",
                name = "",
                desc = GetCommandDesc("/farmingbar profile", L["Swap profiles."], "profileName"),
                func = function(info)
                    local _, profileName = strsplit(" ", info.input:trim())
                    if not profileName then
                        return
                    end
                    for _, profile in pairs(private.db:GetProfiles()) do
                        if strlower(profileName) == strlower(profile) then
                            private.db:SetProfile(profile)
                        end
                    end
                end,
            },
            show = {
                type = "execute",
                name = "",
                desc = GetCommandDesc("/farmingbar show", L["Show options frame."]),
                func = function()
                    private:LoadOptions()
                end,
            },
            tooltips = {
                type = "group",
                name = "",
                desc = GetCommandDesc(
                    "/farmingbar tooltips",
                    L["Toggle tooltips."],
                    "bar | button | disable | enable | toggle"
                ),
                args = {
                    bar = {
                        type = "execute",
                        name = "",
                        desc = GetCommandDesc("/farmingbar tooltips bar", L["Toggle bar tooltips."], "barID | 0"),
                        func = function()
                            if private.db.global.settings.tooltips.bar then
                                private.db.global.settings.tooltips.bar = false
                            else
                                private.db.global.settings.tooltips.bar = true
                            end
                        end,
                    },
                    button = {
                        type = "execute",
                        name = "",
                        desc = GetCommandDesc("/farmingbar tooltips button", L["Toggle button tooltips."], "barID | 0"),
                        func = function()
                            if private.db.global.settings.tooltips.button then
                                private.db.global.settings.tooltips.button = false
                            else
                                private.db.global.settings.tooltips.button = true
                            end
                        end,
                    },
                    disable = {
                        type = "execute",
                        name = "",
                        desc = GetCommandDesc("/farmingbar tooltips disable", L["Disable all tooltips."]),
                        func = function()
                            private.db.global.settings.tooltips.button = false
                            private.db.global.settings.tooltips.bar = false
                        end,
                    },
                    enable = {
                        type = "execute",
                        name = "",
                        desc = GetCommandDesc("/farmingbar tooltips enable", L["Enable all tooltips."]),
                        func = function()
                            private.db.global.settings.tooltips.button = true
                            private.db.global.settings.tooltips.bar = true
                        end,
                    },
                    toggle = {
                        type = "execute",
                        name = "",
                        desc = GetCommandDesc("/farmingbar tooltips toggle", L["Toggle all tooltips."]),
                        func = function()
                            if private.db.global.settings.tooltips.bar then
                                private.db.global.settings.tooltips.bar = false
                            else
                                private.db.global.settings.tooltips.bar = true
                            end

                            if private.db.global.settings.tooltips.button then
                                private.db.global.settings.tooltips.button = false
                            else
                                private.db.global.settings.tooltips.button = true
                            end
                        end,
                    },
                },
            },
        },
    }

    return options
end
