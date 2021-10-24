local addonName = ...
local addon = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

--*------------------------------------------------------------------------
-- Anchors

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


function addon:GetAnchorPoints(grow)
    return anchors[grow].anchor, anchors[grow].relativeAnchor, anchors[grow].xOffset, anchors[grow].yOffset
end


function addon:GetRelativeAnchorPoints(grow)
    return self:GetAnchorPoints(anchors[grow[1]][grow[2]])
end


--*------------------------------------------------------------------------


function addon:UpdateButtons(objectiveTitle, callback, ...)
    -- Updates visual layers of all buttons on all bars
    for _, bar in pairs(self.bars) do
        local buttons = bar:GetUserData("buttons")
        if buttons then
            for _, button in pairs(buttons) do
                local buttonObjectiveTitle = button:GetObjectiveTitle()
                if buttonObjectiveTitle == objectiveTitle or not objectiveTitle then
                    if callback then
                        button[callback](button, ...)
                    else
                        button:UpdateLayers(objectiveTitle)
                    end
                end
            end
        end
    end
end