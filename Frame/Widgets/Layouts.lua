local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

local AceGUI = LibStub("AceGUI-3.0", true)

local pairs, wipe = pairs, table.wipe

--*------------------------------------------------------------------------

-- from AceGUI-3.0.lua
-- Used to set width/height without calling the layout function (e.g. when we're calling during the layout function)
local layoutrecursionblock = nil
local function safelayoutcall(object, func, ...)
	layoutrecursionblock = true
	object[func](object, ...)
	layoutrecursionblock = nil
end

--*------------------------------------------------------------------------

AceGUI:RegisterLayout("FB30_PaddedList", function(content, children)
    for i = 1, #children do
        local child = children[i]
        if child then
            local frame = child.frame
            frame:SetWidth(content:GetWidth() - 10)

            if i == 1 then
                frame:SetPoint("TOPLEFT", 5, -5)
            else
                local padding = (content.obj and content.obj:GetUserData("childPadding")) or (content.widget and content.widget:GetUserData("childPadding")) or 5
                frame:SetPoint("TOPLEFT", children[i - 1].frame, "BOTTOMLEFT", 0, -padding)
            end

            if child.height == "fill" then
                frame:SetPoint("BOTTOM")
                break
            end

            if child.DoLayout then
                child:DoLayout()
            end
        end
    end

    if content.obj.LayoutFinished then
        content.obj:LayoutFinished()
    end
end)

--*------------------------------------------------------------------------

-- scroll:SetLayout("FB30_Table")
-- scroll:SetUserData("table", {
--     {
--         cols = {
--             {width = "fill"},
--         },
--         rowHeight = 20,
--     },
--     {
--         cols = {
--             {width = "relative", height = 500, relWidth = 1/3, vOffset = -5},
--             {width = 5, height = "row", vOffset = 50},
--             {width = "relative", relWidth = 1/3, vOffset = -50},
--         },
--         hpadding = 5,
--         vOffset = 10,
--         rowHeight = "stretch",
--     },
--     {
--         cols = {
--             {width = "fill"},
--         },
--     },
-- })

-- table is set as a table filled with row tables
-- row tables can include the arguments: cols (table), rowHeight (integer, "fill" to fill to bottom of frame or "stretch" to stretch all cells to the max height of the row), hpadding (horizontal padding between cells (cols)), vOffset (vertical offset; note that same row offsets will be in relation to the first cell in a row)
-- rowHeight fills will stop after next row
-- cols tables consist of cell (col) tables and can include the arguments: width ("fill", "relative", or an integer), relWidth (required if width is set to "relative"; integer), height (integer or "row" to match max row height), vOffset (integer)
-- col table settings for height and hpadding will take precedence over row settings, but vOffset will compound

-- any children unaccounted for within the table userdata will not be displayed (in the example above, 5 children are shown: 1, 3, 1)
-- haven't decided whether or not I want everything to fit without overflowing or let that be a user problem to set up correctly; for now I'm not implementing this

-- add setting: constrainOverflow

local fillToRow = {}

AceGUI:RegisterLayout("FB30_Table", function(content, children)
    if layoutrecursionblock then return end
    local container = content.obj or content.widget
    local tableInfo = container:GetUserData("table")
    if not tableInfo then return end

    local contentWidth = content.width or content:GetWidth() or 0
    local height = 0

    local i = 1
    for row, rowInfo in pairs(tableInfo) do
        local colsFilled = 0
        local rowHeight = rowInfo.vOffset or 0

        for col, colInfo in pairs(rowInfo.cols) do
            local child = children[i]
            if not child then break end

            local frame = child.frame
            local frameWidth = child:GetUserData("userWidth") or colInfo.width or frame.width or frame:GetWidth() or 0
            local frameHeight = colInfo.height or rowInfo.rowHeight or frame.height or frame:GetHeight() or 0

            if not tonumber(frameHeight) then -- rowInfo.rowHeight == "stretch" or colInfo.height == "row"
                fillToRow[i] = true
                frameHeight = (tonumber(rowInfo.rowHeight) and rowInfo.rowHeight) or (tonumber(colInfo.height) and colInfo.height) or frame.height or frame:GetHeight() or 0
            end

            local hpadding = colInfo.hpadding or rowInfo.hpadding or 0
            local vOffset = colInfo.vOffset or 0

            ------------------------------------------------------------

            frame:Show()
            frame:ClearAllPoints()

            if i == 1 then
                -- first child
                frame:SetPoint("TOPLEFT")
                frame:SetPoint("BOTTOM", content, "TOP", 0, -frameHeight)
                colsFilled = colsFilled + 1
            elseif colsFilled == 0 then
                -- new row
                frame:SetPoint("TOPLEFT", 0, -(height + rowHeight + vOffset))
                frame:SetPoint("BOTTOM", content, "TOP", 0, -(frameHeight + height))
                colsFilled = colsFilled + 1
            elseif colsFilled <= #rowInfo.cols then
                -- same row
                frame:SetPoint("TOPLEFT", children[i - 1].frame, "TOPRIGHT", hpadding, -vOffset)
                frame:SetPoint("BOTTOM", content, "TOP", 0, -(frameHeight + height))
                colsFilled = colsFilled + 1
            end

            ------------------------------------------------------------

            if frameWidth == "fill" then
                safelayoutcall(child, "SetWidth", contentWidth)
                frame:SetPoint("RIGHT")
            elseif frameWidth == "relative" then
				child.relWidth = child.relWidth or colInfo.relWidth or 0
				safelayoutcall(child, "SetWidth", contentWidth * child.relWidth)
            else
				safelayoutcall(child, "SetWidth", frameWidth)
            end

            if child.DoLayout then
                child:DoLayout()
            end

            frameWidth = frame:GetWidth()

            ------------------------------------------------------------

            rowHeight = math.max(rowHeight, frameHeight)
            i = i + 1
        end

        height = height + rowHeight

        -- Set rows to max rowHeight after the whole row is drawn, to make sure we have the overall height
        for numChild, _ in pairs(fillToRow) do
            local child = children[numChild]
            local frame = child.frame

            if rowInfo.rowHeight == "fill" then
                frame:SetPoint("BOTTOM", 0, 0)
            else
                frame:SetPoint("BOTTOM", content, "TOP", 0, -height)
            end

            if child.DoLayout then
                child:DoLayout()
            end
        end

        if rowInfo.rowHeight == "fill" then
            -- won't draw any more rows if this row is filling
            break
        end

        wipe(fillToRow)
    end

    ------------------------------------------------------------

    if container.LayoutFinished then
        container:LayoutFinished(nil, height)
    end
end)