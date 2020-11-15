local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

--*------------------------------------------------------------------------

local anchors = {
    RIGHT = {
        anchor = "TOPLEFT",
        relativeAnchor = "TOPRIGHT",
        xOffset = 1,
        yOffset = 0,
        NORMAL = "DOWN",
        REVERSE = "UP",
    },
    LEFT = {
        anchor = "TOPRIGHT",
        relativeAnchor = "TOPLEFT",
        xOffset = -1,
        yOffset = 0,
        NORMAL = "DOWN",
        REVERSE = "UP",
    },
    UP = {
        anchor = "BOTTOMLEFT",
        relativeAnchor = "TOPLEFT",
        xOffset = 0,
        yOffset = 1,
        NORMAL = "RIGHT",
        REVERSE = "LEFT",
    },
    DOWN = {
        anchor = "TOPLEFT",
        relativeAnchor = "BOTTOMLEFT",
        xOffset = 0,
        yOffset = -1,
        NORMAL = "RIGHT",
        REVERSE = "LEFT",
    },
}

------------------------------------------------------------

function addon:GetAnchorPoints(grow)
    return anchors[grow].anchor, anchors[grow].relativeAnchor, anchors[grow].xOffset, anchors[grow].yOffset
end

function addon:GetRelativeAnchorPoints(grow)
    return addon:GetAnchorPoints(anchors[grow[1]][grow[2]])
end

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
        local buttons = bar:GetUserData("buttons")
        if buttons then
            for _, button in pairs(buttons) do
                local buttonObjectiveTitle = button:GetUserData("objectiveTitle")
                if buttonObjectiveTitle == objectiveTitle or not objectiveTitle then
                    button:UpdateLayers(objectiveTitle)
                end
            end
        end
    end
end

------------------------------------------------------------

function addon:UpdateRenamedObjectiveButtons(oldObjectiveTitle, newObjectiveTitle)
    for _, bar in pairs(self.bars) do
        for _, button in pairs(bar:GetUserData("buttons")) do
            local objectiveTitle = button:GetUserData("objectiveTitle")
            if objectiveTitle == oldObjectiveTitle then
                button:SetObjectiveID(newObjectiveTitle)
            end
        end
    end
end