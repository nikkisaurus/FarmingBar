local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

local AceGUI = LibStub("AceGUI-3.0", true)

--*------------------------------------------------------------------------

AceGUI:RegisterLayout("FB30_2RowFill", function(content, children)
    for i = 1, 2 do
        local child = children[i]
        if child then
            local frame = child.frame
            frame:SetWidth(content:GetWidth())

            if i == 1 then
                frame:SetPoint("TOPLEFT")
            elseif i == 2 then
                frame:SetPoint("TOPLEFT", children[1].frame, "BOTTOMLEFT", 0, 0)
                frame:SetPoint("BOTTOMRIGHT")
            end

            if child.DoLayout then
                child:DoLayout()
            end
        end
    end

    if content.obj.LayoutFinished then
        content.obj:LayoutFinished(nil, nil)
    end
end)

--*------------------------------------------------------------------------

AceGUI:RegisterLayout("FB30_2RowSplitBottom", function(content, children)
    for i = 1, 3 do
        local child = children[i]
        if child then
            local frame = child.frame

            if i == 1 then
                frame:SetWidth(content:GetWidth())
                frame:SetPoint("TOPLEFT", 5, 0)
            elseif i == 2 then
                frame:SetWidth(content:GetWidth() / 4)
                frame:SetPoint("TOPLEFT", children[1].frame, "BOTTOMLEFT", 0, 0)
                frame:SetPoint("BOTTOM")
            elseif i == 3 then
                frame:SetWidth((content:GetWidth() / 4) * 3)
                frame:SetPoint("TOPLEFT", children[2].frame, "TOPRIGHT", 10, 0)
                frame:SetPoint("BOTTOMRIGHT", -5, 0)
            end

            if child.DoLayout then
                child:DoLayout()
            end
        end
    end

    if content.obj.LayoutFinished then
        content.obj:LayoutFinished(nil, nil)
    end
end)