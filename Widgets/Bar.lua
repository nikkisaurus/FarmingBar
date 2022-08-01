local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)
local AceGUI = LibStub("AceGUI-3.0")

local Type = "FarmingBar_Bar"
local Version = 1

-- [[ Scripts ]]
local scripts = {
    OnDragStart = function(frame)
        frame:StartMoving()
    end,

    OnReceiveDrag = function(frame)
        frame:StopMovingOrSizing()
    end,
}

--[[ Methods ]]
local methods = {
    --[[ Widget ]]
    OnAcquire = function(widget)
        widget:SetUserData("buttons", {})
        widget:SetBackdrop()
        widget:SetPoint("CENTER")
        widget:Show()
    end,

    --[[ Frame ]]
    SetHeight = function(widget, height)
        widget.frame:SetHeight(height)
    end,

    SetPoint = function(widget, ...)
        widget.frame:SetPoint(...)
    end,

    SetSize = function(widget, width, height)
        widget:SetWidth(width)
        widget:SetHeight(height or width)
    end,

    SetWidth = function(widget, width)
        widget.frame:SetWidth(width)
    end,

    Show = function(widget)
        widget.frame:Show()
    end,

    --[[ Backdrop ]]
    SetBackdrop = function(widget, backdropInfo, bgColor, borderColor)
        widget.frame:SetBackdrop(backdropInfo or private.defaults.bar.backdrop.bgFile)
        widget.frame:SetBackdropColor(addon.unpack(bgColor, private.defaults.bar.backdrop.bgColor))
        widget.frame:SetBackdropBorderColor(addon.unpack(borderColor, private.defaults.bar.backdrop.borderColor))
    end,

    --[[ Database ]]
    GetDB = function(widget)
        return private.db.profile.bars[widget:GetID()]
    end,

    GetID = function(widget)
        return widget:GetUserData("barID")
    end,

    SetID = function(widget, barID)
        if widget:GetID() then
            if private.db.global.debug.enabled then
                error(format(L["Bar is already assigned an ID: %d"], widget:GetID()))
            end
            return
        end

        widget:SetUserData("barID", barID)
        widget:DrawButtons()
    end,

    --[[ Buttons ]]
    DrawButtons = function(widget)
        local buttons = widget:GetUserData("buttons")
        local barDB = widget:GetDB()

        if barDB.numButtons > #buttons then
            for i = #buttons + 1, barDB.numButtons do
                local button = AceGUI:Create("FarmingBar_Button")
                button:SetID(widget:GetID(), i)
                tinsert(buttons, button)
            end
        end

        widget:LayoutButtons()
    end,

    LayoutButtons = function(widget)
        local barDB = widget:GetDB()
        local buttons = widget:GetUserData("buttons")

        for buttonID, button in pairs(buttons) do
            local row = ceil(buttonID / barDB.buttonsPerAxis)
            local newRow = mod(buttonID, barDB.buttonsPerAxis) == 1

            button:ClearAllPoints()

            if buttonID == 1 then
                local anchorInfo = private.anchorPoints[barDB.buttonGrowth].button1[barDB.barAnchor]
                button:SetPoint(anchorInfo.anchor, widget.frame, anchorInfo.relAnchor,
                    anchorInfo.xCo * (barDB.buttonPadding + barDB.buttonBackdrop.bgFile.edgeSize),
                    anchorInfo.yCo * (barDB.buttonPadding + barDB.buttonBackdrop.bgFile.edgeSize))
            elseif newRow then
                local anchorInfo = private.anchorPoints[barDB.buttonGrowth].newRowButton[barDB.barAnchor]
                button:SetPoint(anchorInfo.anchor, buttons[buttonID - barDB.buttonsPerAxis].frame, anchorInfo.relAnchor,
                    anchorInfo.xCo * barDB.buttonPadding,
                    anchorInfo.yCo * barDB.buttonPadding)
            else
                local anchorInfo = private.anchorPoints[barDB.buttonGrowth].button[barDB.barAnchor]
                button:SetPoint(anchorInfo.anchor, buttons[buttonID - 1].frame, anchorInfo.relAnchor,
                    anchorInfo.xCo * barDB.buttonPadding,
                    anchorInfo.yCo * barDB.buttonPadding)
            end
        end

        -- Backdrop
        local width = (barDB.buttonSize * barDB.buttonsPerAxis) + (barDB.buttonPadding * (barDB.buttonsPerAxis + 1)) +
            (2 * barDB.buttonBackdrop.bgFile.edgeSize)
        local numRows = ceil(#buttons / barDB.buttonsPerAxis)
        local height = (barDB.buttonSize * numRows) + (barDB.buttonPadding * (numRows + 1)) +
            (2 * barDB.buttonBackdrop.bgFile.edgeSize)
        local growRow = barDB.buttonGrowth == "ROW"
        widget:SetSize(growRow and width or height, growRow and height or width)
    end,
}

--[[ Constructor ]]
local function Constructor()
    --[[ Frame ]]
    local frame = CreateFrame("Frame", Type .. AceGUI:GetNextWidgetNum(Type), UIParent, "BackdropTemplate")
    frame:SetFrameStrata("MEDIUM")
    frame:SetFrameLevel(0)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")

    for script, func in pairs(scripts) do
        frame:SetScript(script, func)
    end

    --[[ Widget ]]
    local widget = {
        frame = frame,
        type = Type,
    }

    frame.obj = widget

    for method, func in pairs(methods) do
        widget[method] = func
    end

    AceGUI:RegisterAsWidget(widget)

    return widget
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
