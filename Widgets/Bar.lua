local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)
local AceGUI = LibStub("AceGUI-3.0")

local Type = "FarmingBar_Bar"
local Version = 1

-- [[ Scripts ]]
local scripts = {
    --[[ Drag ]]
    OnDragStart = function(frame)
        frame:StartMoving()
    end,

    OnReceiveDrag = function(frame)
        frame:StopMovingOrSizing()
        frame.obj:SetDBValue("point", { frame:GetPoint() })
    end,

    --[[ Mouseover ]]
    OnEnter = function(frame)
        local widget = frame.obj
        local barDB = widget:GetDB()

        if barDB.mouseover then
            widget:SetAlpha(barDB.alpha)
        end
    end,

    OnLeave = function(frame)
        frame.obj:SetMouseover()
    end,
}

--[[ Methods ]]
local methods = {
    --[[ Widget ]]
    OnAcquire = function(widget)
        widget:SetUserData("buttons", {})
    end,

    CallScript = function(widget, event, ...)
        widget.frame:GetScript(event)(...)
    end,

    --[[ Frame ]]
    Hide = function(widget)
        widget.frame:Hide()
    end,

    SetAlpha = function(widget, alpha)
        widget.frame:SetAlpha(alpha)

        for _, button in pairs(widget:GetButtons()) do
            button:SetAlpha(alpha)
        end
    end,

    SetHeight = function(widget, height)
        widget.frame:SetHeight(height)
    end,

    SetHidden = function(widget)
        local barDB = widget:GetDB()

        local func = loadstring("return " .. barDB.hidden)
        if type(func) == "function" then
            local success, userFunc = pcall(func)
            if success and type(userFunc) == "function" then
                local hidden = userFunc()
                if hidden then
                    widget:Hide()
                else
                    widget:Show()
                end

                for _, button in pairs(widget:GetButtons()) do
                    if hidden then
                        button:Hide()
                    else
                        button:Show()
                    end
                end
            else
                error(L["barDB.hidden must return a \"function\""])
            end
        else
            error(L["barDB.hidden must return a \"function\""])
        end
    end,

    SetMouseover = function(widget)
        local barDB = widget:GetDB()

        if barDB.mouseover then
            widget:SetAlpha(0)
        else
            widget:SetAlpha(barDB.alpha)
        end
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
        local frame = widget.frame
        frame:SetBackdrop(backdropInfo or private.defaults.bar.backdrop.bgFile)
        frame:SetBackdropColor(addon.unpack(bgColor, private.defaults.bar.backdrop.bgColor))
        frame:SetBackdropBorderColor(addon.unpack(borderColor, private.defaults.bar.backdrop.borderColor))
    end,

    --[[ Database ]]
    GetDB = function(widget)
        return private.db.profile.bars[widget:GetID()]
    end,

    GetID = function(widget)
        return widget:GetUserData("barID")
    end,

    SetDBValue = function(widget, key, value)
        private.db.profile.bars[widget:GetID()][key] = value
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
        widget:Update()
    end,

    Update = function(widget)
        local barDB = widget:GetDB()
        widget:SetBackdrop(not barDB.backdrop.enabled and {})
        widget:SetPoint(unpack(barDB.point))
        widget:LayoutButtons()
        widget:SetHidden()
        widget:SetMouseover()
    end,

    --[[ Buttons ]]
    GetButtons = function(widget)
        return widget:GetUserData("buttons")
    end,

    DrawButtons = function(widget)
        local buttons = widget:GetButtons()
        local barDB = widget:GetDB()

        if barDB.numButtons > #buttons then
            for i = #buttons + 1, barDB.numButtons do
                local button = AceGUI:Create("FarmingBar_Button")
                button:SetID(widget:GetID(), i)
                tinsert(buttons, button)
            end
        elseif #buttons > barDB.numButtons then
            -- TODO
            print("Remove buttons")
        end
    end,

    LayoutButtons = function(widget)
        local barDB = widget:GetDB()
        local buttons = widget:GetButtons()

        for buttonID, button in pairs(buttons) do
            local row = ceil(buttonID / barDB.buttonsPerAxis)
            local newRow = mod(buttonID, barDB.buttonsPerAxis) == 1

            button:ClearAllPoints()

            if buttonID == 1 then
                local anchorInfo = private.anchorPoints[barDB.buttonGrowth].button1[barDB.barAnchor]
                button:SetPoint(anchorInfo.anchor, widget.frame, anchorInfo.relAnchor,
                    anchorInfo.xCo * barDB.buttonPadding,
                    anchorInfo.yCo * barDB.buttonPadding)
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
        local width = (barDB.buttonSize * barDB.buttonsPerAxis) + (barDB.buttonPadding * (barDB.buttonsPerAxis + 1))
        local numRows = ceil(#buttons / barDB.buttonsPerAxis)
        local height = (barDB.buttonSize * numRows) + (barDB.buttonPadding * (numRows + 1))
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
