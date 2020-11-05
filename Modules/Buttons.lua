local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

--*------------------------------------------------------------------------

function addon:ClearDeletedObjectives()
    for _, bar in pairs(self.bars) do
        for _, button in pairs(bar:GetUserData("buttons")) do
            local objectiveTitle = button:GetUserData("objectiveTitle")
            if objectiveTitle and not FarmingBar.db.global.objectives[objectiveTitle] then
                FarmingBar.db.char.bars[bar:GetUserData("barID")].objectives[button:GetUserData("buttonID")] = nil
                button:ClearObjective()
            end
        end
    end
end

------------------------------------------------------------

function addon:UpdateButtons(objectiveTitle)
    for _, bar in pairs(self.bars) do
        for _, button in pairs(bar:GetUserData("buttons")) do
            local buttonObjectiveTitle = button:GetUserData("objectiveTitle")
            if buttonObjectiveTitle == objectiveTitle then
                button:UpdateLayers(objectiveTitle)
            end
        end
    end
end

------------------------------------------------------------

function addon:UpdateRenamedObjectiveButton(oldObjectiveTitle, newObjectiveTitle)
    for _, bar in pairs(self.bars) do
        for _, button in pairs(bar:GetUserData("buttons")) do
            local objectiveTitle = button:GetUserData("objectiveTitle")
            print(objectiveTitle, oldObjectiveTitle, newObjectiveTitle)
            if objectiveTitle and objectiveTitle == oldObjectiveTitle then
                button:SetObjectiveID(newObjectiveTitle)
            end
        end
    end
end