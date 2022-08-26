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
                    },
                },
                limitMats = {
                    order = 3,
                    type = "toggle",
                    width = "full",
                    name = L["Limit Mats"],
                    desc = L["Objectives on this bar cannot use materials already accounted for by another objective on the same bar."],
                    descStyle = "inline",
                },
            },
        },
        apperance = {
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
                    set = function() end, -- TODO
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
                    args = {
                        hiddenEvents = {
                            order = 1,
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
                            order = 2,
                            type = "input",
                            width = "full",
                            dialogControl = "FarmingBar_LuaEditBox",
                            multiline = true,
                            name = L["Hidden"],
                            set = function(info, value)
                                private.db.profile.bars[barID][info[#info]] = value
                                private.bars[barID]:SetHidden()
                            end,
                            validate = function(_, value)
                                return private:ValidateHiddenFunc(value)
                            end,
                            arg = function(value)
                                return private:ValidateHiddenFunc(value)
                            end,
                        },
                        resetHidden = {
                            order = 3,
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
            args = {},
        },
        manage = {
            order = 4,
            type = "group",
            name = L["Manage"],
            args = {
                templates = {
                    order = 1,
                    type = "group",
                    inline = true,
                    name = L["Templates"],
                    args = {}, -- TODO
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
                    end,
                },
                duplicateBar = {
                    order = 3,
                    type = "execute",
                    name = L["Duplicate"],
                    func = function() end, -- TODO
                },
                removeBar = {
                    order = 3,
                    type = "execute",
                    name = REMOVE,
                    confirm = function()
                        return format(L["Are you sure you want to remove Bar \"%d\"?"], barID)
                    end,
                    func = function()
                        private:RemoveBar(barID)
                        private:RefreshOptions("config")
                    end,
                },
            },
        },
    }

    return options
end
