local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)

function private:ConvertDB_V5()
    if private.db.global.objectives then
        for objectiveTitle, objective in pairs(private.db.global.objectives) do
            for trackerKey, tracker in pairs(objective.trackers) do
                if not tracker.name or tracker.name == "" then
                    addon:Cache(strlower(tracker.type), tracker.id, function(success, id, private, objectiveTitle, trackerKey)
                        if success then
                            local tracker = private.db.global.objectives[objectiveTitle].trackers[trackerKey]
                            local name = private:GetTrackerInfo(tracker.type, id)
                            tracker.name = name or ""
                        end
                    end, { private, objectiveTitle, trackerKey })
                end

                for altIDKey, altID in pairs(tracker.altIDs) do
                    if not altID.name or altID.name == "" then
                        addon:Cache(strlower(altID.type), altID.id, function(success, id, private, FarmingBarDB, profileName, barID, buttonID, trackerKey, altIDKey)
                            if success then
                                local altID = private.db.global.objectives[objectiveTitle].trackers[trackerKey].altIDs[altIDKey]
                                local name = private:GetTrackerInfo(altID.type, id)
                                altID.name = name or ""
                            end
                        end, { private, FarmingBarDB, profileName, barID, buttonID, trackerKey, altIDKey })
                    end
                end
            end
        end
    end

    if FarmingBarDB.profiles then
        for profileName, profile in pairs(FarmingBarDB.profiles) do
            for barID, bar in pairs(profile.bars) do
                for buttonID, button in pairs(bar.buttons) do
                    for trackerKey, tracker in pairs(button.trackers) do
                        if not tracker.name or tracker.name == "" then
                            addon:Cache(strlower(tracker.type), tracker.id, function(success, id, private, FarmingBarDB, profileName, barID, buttonID, trackerKey)
                                if success then
                                    local tracker = FarmingBarDB.profiles[profileName].bars[barID].buttons[buttonID].trackers[trackerKey]
                                    local name = private:GetTrackerInfo(tracker.type, id)
                                    tracker.name = name or ""
                                end
                            end, { private, FarmingBarDB, profileName, barID, buttonID, trackerKey })
                        end
                        for altIDKey, altID in pairs(tracker.altIDs) do
                            if not altID.name or altID.name == "" then
                                addon:Cache(strlower(altID.type), altID.id, function(success, id, private, FarmingBarDB, profileName, barID, buttonID, trackerKey, altIDKey)
                                    if success then
                                        local altID = FarmingBarDB.profiles[profileName].bars[barID].buttons[buttonID].trackers[trackerKey].altIDs[altIDKey]
                                        local name = private:GetTrackerInfo(altID.type, id)
                                        altID.name = name or ""
                                    end
                                end, { private, FarmingBarDB, profileName, barID, buttonID, trackerKey, altIDKey })
                            end
                        end
                    end
                end
            end
        end
    end
end
