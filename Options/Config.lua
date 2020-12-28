local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

local pairs, tinsert = pairs, table.insert
local format = string.format

--*------------------------------------------------------------------------

function addon:GetConfigOptions()
    local options = {}

    for barID = 0, #self.bars do
        options["bar"..barID] = {
            order = barID,
            type = "group",
            name = barID > 0 and (L["Bar"].." "..barID) or L["All"],
            childGroups = "tab",
            args = {
                bar = {
                    order = 1,
                    type = "group",
                    name = L["Bar"],
                    args = self:GetBarConfigOptions(barID),
                },

                ------------------------------------------------------------

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

------------------------------------------------------------

function addon:RefreshConfigOptions()
    self.options.args.config.args = self:GetConfigOptions()
    LibStub("AceConfigRegistry-3.0"):NotifyChange(addonName)
end

--*------------------------------------------------------------------------

function addon:GetBarConfigOptions(barID)
    local options

    if barID == 0 then
        options = {
            manage = {
                order = 1,
                type = "group",
                inline = true,
                name = L["Manage"],
                args = {
                    removeBar = {
                        order = 1,
                        type = "select",
                        name = L["Remove Bar"],
                        width = "full",
                        values = function()
                            local values = {}

                            for i = 1, #self.bars do
                                values[i] = L["Bar"].." "..i
                            end

                            return values
                        end,
                        sorting = function()
                            local sorting = {}

                            for i = 1, #self.bars do
                                tinsert(sorting, i)
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

                    ------------------------------------------------------------

                    addBar = {
                        order = 2,
                        type = "execute",
                        name = L["Add Bar"],
                        width = "full",
                        func = function()
                            self:CreateBar()
                        end,
                    },
                },
            },
        }
    else
        options = {

        }
    end

    return options
end

------------------------------------------------------------

function addon:GetButtonConfigOptions(barID)
    local options

    if barID == 0 then
        options = {

        }
    else
        options = {

        }
    end

    return options
end