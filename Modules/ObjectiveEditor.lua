local addonName = ...
local addon = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)


--*------------------------------------------------------------------------
-- Initialize


local widget
function addon:InitializeObjectiveEditorOptions(...)
    widget = ...
    LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName.."ObjectiveEditor", self:GetObjectiveEditorOptions())
    LibStub("AceConfigDialog-3.0"):SetDefaultSize(addonName.."ObjectiveEditor", 425, 300)
end


function addon:GetObjectiveEditorOptions()
    local options = {
        type = "group",
        name = format("%s %s", L.addon, L["Objective Editor"]),
        args = {
            objective = {
                order = 0,
                type = "group",
                name = widget and widget:GetObjectiveTitle() or "",
                childGroups = "select",
                args = self:GetObjectiveEditorOptions_Objective(),
            },
            trackers = {
                order = 1,
                type = "group",
                name = L["Trackers"],
                args = {},
            },
        },
    }

    if widget then
        for trackerKey, trackerInfo in self.pairs(widget:GetButtonDB().trackers) do
            local trackerType, trackerID = self:ParseTrackerKey(trackerKey)

            self:GetTrackerDataTable(widget:GetButtonDB(), trackerType, trackerID, function(data)
                options.args.trackers.args[trackerKey] = {
                    order = trackerInfo.order,
                    type = "group",
                    name = data.name,
                    args = self:GetObjectiveEditorOptions_Tracker(trackerKey, trackerInfo),
                }
                return options
            end)
        end
    end

    return options
end


--*------------------------------------------------------------------------
-- Load options


function addon:GetObjectiveEditorOptions_IncludeAllChars()
    local options = {
    }

    -- Check for missing DataStore dependencies
    local missingDependencies = self:IsDataStoreLoaded()
    if #missingDependencies > 0 then
        local red = LibStub("LibAddonUtils-1.0").ChatColors["RED"]

        options["missingDependencies"] = {
            order = 0,
            type = "description",
            width = "full",
            name = format(L.MissingIncludeAllCharsDependecies, red..strjoin("|r, "..red, unpack(missingDependencies))),
        }
    end

    -- Load trackers
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


function addon:GetObjectiveEditorOptions_IncludeBank()
    local options = {}

    -- Load trackers
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
                        return addon:GetTrackerDBInfo(trackers, trackerKey, "includeBank")
                    end,
                    set = function(_, value)
                        addon:SetTrackerDBValue(trackers, trackerKey, "includeBank", value)
                        widget:UpdateLayers()
                    end,
                }

                return options
            end)
        end
    end

    return options
end


function addon:GetObjectiveEditorOptions_Objective()
    if not widget then return {} end
    local barID, buttonID = widget:GetBarID(), widget:GetUserData("buttonID")

    return {
        mute = {
            order = 1,
            type = "toggle",
            name = L["Mute"],
            get = function()
                return addon:GetButtonDBValue("mute", barID, buttonID)
            end,
            set = function(_, value)
                addon:SetButtonDBValues("mute", value, barID, buttonID)
            end,
        },
    }
end


function addon:GetObjectiveEditorOptions_Tracker()
    return {}
end