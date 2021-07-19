local addonName = ...
local addon = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

------------------------------------------------------------

local widget

--*------------------------------------------------------------------------

function addon:InitializeObjectiveEditorOptions(...)
    widget = ...
    LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName.."ObjectiveEditor", self:GetObjectiveEditorOptions())
    LibStub("AceConfigDialog-3.0"):SetDefaultSize(addonName.."ObjectiveEditor", 850, 600)
end

--*------------------------------------------------------------------------

function addon:GetObjectiveEditorOptions()
    self.options = {
        type = "group",
        name = L.addon..L["Objective Editor"],
        args = {
            includeAllChars = {
                order = 1,
                type = "group",
                name = L["Include All Characters"],
                childGroups = "select",
                args = self:GetObjectiveEditorIncludeAllCharsOptions(),
            },

            ------------------------------------------------------------

            includeBank = {
                order = 2,
                type = "group",
                name = L["Include Bank"],
                childGroups = "select",
                args = self:GetObjectiveEditorIncludeBankOptions(),
            },

            ------------------------------------------------------------

            includeGuildBank = {
                order = 3,
                type = "group",
                name = L["Include Guild Bank"],
                childGroups = "select",
                disabled = true,
                args = self:GetObjectiveEditorIncludeGuildBankOptions(),
            },

            ------------------------------------------------------------

            excluded = {
                order = 4,
                type = "group",
                name = L["Excluded"],
                disabled = true,
                args = self:GetObjectiveEditorExcludedOptions(),
            },
        },
    }

    return self.options
end

--*------------------------------------------------------------------------

function addon:GetObjectiveEditorIncludeAllCharsOptions()
    local options = {}

    if widget then
        local buttonDB = widget:GetButtonDB()
        local trackers = buttonDB.trackers

        for trackerKey, trackerInfo in pairs(trackers) do
            local trackerType, trackerID = self:ParseTrackerKey(trackerKey)
            self:GetTrackerDataTable(buttonDB, trackerType, trackerID, function(data)
                options[trackerKey] = {
                    order = trackerInfo.order,
                    type = "toggle",
                    width = "full",
                    name = data.name,
                    get = function()
                        return self:GetTrackerDBInfo(trackers, trackerKey, "includeAllChars")
                    end,
                    set = function(_, value)
                        self:SetTrackerDBValue(trackers, trackerKey, "includeAllChars", value)
                        widget:UpdateLayers()
                    end,
                }

                return options
            end)
        end
    end

    return options
end

------------------------------------------------------------

function addon:GetObjectiveEditorIncludeBankOptions()
    local options = {}

    if widget then
        local buttonDB = widget:GetButtonDB()
        local trackers = buttonDB.trackers

        for trackerKey, trackerInfo in pairs(trackers) do
            local trackerType, trackerID = self:ParseTrackerKey(trackerKey)
            self:GetTrackerDataTable(buttonDB, trackerType, trackerID, function(data)
                options[trackerKey] = {
                    order = trackerInfo.order,
                    type = "toggle",
                    width = "full",
                    name = data.name,
                    get = function()
                        return self:GetTrackerDBInfo(trackers, trackerKey, "includeBank")
                    end,
                    set = function(_, value)
                        self:SetTrackerDBValue(trackers, trackerKey, "includeBank", value)
                        widget:UpdateLayers()
                    end,
                }

                return options
            end)
        end
    end

    return options
end

------------------------------------------------------------

function addon:GetObjectiveEditorIncludeGuildBankOptions()
    local options = {

    }

    return options
end

------------------------------------------------------------

function addon:GetObjectiveEditorExcludedOptions()
    local options = {

    }

    return options
end