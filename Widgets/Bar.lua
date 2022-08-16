local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)
local AceGUI = LibStub("AceGUI-3.0")
local LSM = LibStub("LibSharedMedia-3.0")

local Type = "FarmingBar_Bar"
local Version = 1

-- [[ Scripts ]]
local scripts = {
    --[[ Mouseover ]]
    OnEnter = function(frame)
        local widget = frame.obj
        local barDB = widget:GetDB()
        local cursorType, itemID = GetCursorInfo()
        local hasObjective = private.ObjectiveFrame:GetObjective()
        local show = (cursorType == "item" and itemID) or hasObjective

        if barDB.mouseover then
            widget:SetAlpha(barDB.alpha, not show and not barDB.showEmpty)
        end
    end,

    OnLeave = function(frame)
        frame.obj:SetMouseover()
    end,
}

local anchorScripts = {
    --[[ Click ]]
    OnClick = function(anchor)
        if IsControlKeyDown() then
            local widget = anchor.obj
            widget:SetDBValue("movable", false)
            widget:SetMovable()
        end
    end,

    -- [[ Drag ]]
    OnDragStart = function(anchor)
        anchor.obj.frame:StartMoving()
    end,

    OnDragStop = function(anchor)
        local widget = anchor.obj
        widget.frame:StopMovingOrSizing()
        widget:SetDBValue("point", { widget.frame:GetPoint() })
    end,

    --[[ Tooltip ]]
    OnEnter = function(anchor, ...)
        private:LoadTooltip(anchor, "ANCHOR_CURSOR", 0, 0, {
            {
                line = L["Control+click to lock and hide anchor."],
                color = private.CONST.TOOLTIP_DESC,
            },
        })

        local widget = anchor.obj
        widget:CallScript("OnEnter", widget.frame, ...)
    end,

    OnLeave = function(anchor, ...)
        private:ClearTooltip()
        local widget = anchor.obj
        widget:CallScript("OnLeave", widget.frame, ...)
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

    Update = function(widget)
        widget:SetBackdrop()
        widget:SetPoints()
        widget:SetHidden()
        widget:SetMouseover()
        widget:SetMovable()
        widget:SetScale()
    end,

    --[[ Frame ]]
    Hide = function(widget)
        widget.frame:Hide()
    end,

    SetAlpha = function(widget, alpha, hideEmpty)
        widget.frame:SetAlpha(alpha)

        for _, button in pairs(widget:GetButtons()) do
            local isEmpty = hideEmpty and button:IsEmpty()
            button:SetAlpha(not private.ObjectiveFrame:GetObjective() and isEmpty and 0 or alpha)
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

    SetMovable = function(widget)
        local barDB = widget:GetDB()

        if barDB.movable then
            widget.anchor:Show()
        else
            widget.anchor:Hide()
        end
    end,

    SetMouseover = function(widget)
        local barDB = widget:GetDB()
        local cursorType, itemID = GetCursorInfo()
        local hasObjective = private.ObjectiveFrame:GetObjective()
        local show = (cursorType == "item" and itemID) or hasObjective

        if barDB.mouseover then
            widget:SetAlpha(show and barDB.alpha or 0)
        else
            widget:SetAlpha(barDB.alpha, not show and not barDB.showEmpty)
        end
    end,

    SetPoint = function(widget, ...)
        widget.frame:SetPoint(...)
    end,

    SetPoints = function(widget)
        local barDB = widget:GetDB()
        local anchorInfo = private.anchorPoints.anchor[barDB.barAnchor]

        widget:ClearAllPoints()
        widget:SetPoint(unpack(barDB.point))

        widget.anchor:ClearAllPoints()
        widget.anchor:SetPoint(
            anchorInfo.anchor,
            widget.frame,
            anchorInfo.relAnchor,
            anchorInfo.xCo * barDB.buttonPadding,
            anchorInfo.yCo * barDB.buttonPadding
        )

        widget:LayoutButtons()
    end,

    SetScale = function(widget)
        local barDB = widget:GetDB()
        widget.frame:SetScale(barDB.scale)

        for _, button in pairs(widget:GetButtons()) do
            button.frame:SetScale(barDB.scale)
        end
    end,

    SetSize = function(widget, width, height)
        widget:SetWidth(width)
        widget:SetHeight(height or width)

        local barDB = widget:GetDB()
        local anchorSize = barDB.buttonSize * (2 / 3)
        widget.anchor:SetSize(anchorSize, anchorSize)
    end,

    SetWidth = function(widget, width)
        widget.frame:SetWidth(width)
    end,

    Show = function(widget)
        widget.frame:Show()
    end,

    --[[ Backdrop ]]
    SetBackdrop = function(widget)
        local barDB = widget:GetDB()

        local frame = widget.frame
        local texture = LSM:Fetch(LSM.MediaType.BACKGROUND, barDB.backdrop.bgFile.bgFile)
        local edgeFile = LSM:Fetch(LSM.MediaType.BORDER, barDB.backdrop.bgFile.edgeFile)
        local bgFile = addon.CloneTable(barDB.backdrop.bgFile)
        bgFile.bgFile = texture
        bgFile.edgeFile = edgeFile
        frame:SetBackdrop(barDB.backdrop.enabled and bgFile)
        frame:SetBackdropColor(unpack(barDB.backdrop.bgColor))
        frame:SetBackdropBorderColor(unpack(barDB.backdrop.borderColor))

        local anchor = widget.anchor
        anchor:SetBackdrop(bgFile)
        anchor:SetBackdropColor(unpack(barDB.backdrop.bgColor))
        anchor:SetBackdropBorderColor(unpack(barDB.backdrop.borderColor))
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
            for i = #buttons, barDB.numButtons + 1, -1 do
                buttons[i]:Release()
                tremove(buttons, i)
            end
        end
    end,

    LayoutButtons = function(widget)
        local barDB = widget:GetDB()
        local buttons = widget:GetButtons()

        for buttonID, button in pairs(buttons) do
            local row = ceil(buttonID / barDB.buttonsPerAxis)
            local newRow = mod(buttonID, barDB.buttonsPerAxis) == 1 or barDB.buttonsPerAxis == 1

            button:ClearAllPoints()
            button:SetSize(barDB.buttonSize, barDB.buttonSize)

            if buttonID == 1 then
                local anchorInfo = private.anchorPoints[barDB.buttonGrowth].button1[barDB.barAnchor]
                button:SetPoint(
                    anchorInfo.anchor,
                    widget.frame,
                    anchorInfo.relAnchor,
                    (anchorInfo.xCo * (barDB.buttonPadding + barDB.backdrop.bgFile.tileSize)),
                    anchorInfo.yCo * (barDB.buttonPadding + barDB.backdrop.bgFile.tileSize)
                )
            elseif newRow then
                local anchorInfo = private.anchorPoints[barDB.buttonGrowth].newRowButton[barDB.barAnchor]
                button:SetPoint(
                    anchorInfo.anchor,
                    buttons[buttonID - barDB.buttonsPerAxis].frame,
                    anchorInfo.relAnchor,
                    anchorInfo.xCo * barDB.buttonPadding,
                    anchorInfo.yCo * barDB.buttonPadding
                )
            else
                local anchorInfo = private.anchorPoints[barDB.buttonGrowth].button[barDB.barAnchor]
                button:SetPoint(
                    anchorInfo.anchor,
                    buttons[buttonID - 1].frame,
                    anchorInfo.relAnchor,
                    anchorInfo.xCo * barDB.buttonPadding,
                    anchorInfo.yCo * barDB.buttonPadding
                )
            end
        end

        -- Backdrop
        local width = (barDB.buttonSize * barDB.buttonsPerAxis)
            + (barDB.buttonPadding * (barDB.buttonsPerAxis + 1))
            + (2 * barDB.backdrop.bgFile.tileSize)
        local numRows = ceil(#buttons / barDB.buttonsPerAxis)
        local height = (barDB.buttonSize * numRows)
            + (barDB.buttonPadding * (numRows + 1))
            + (2 * barDB.backdrop.bgFile.tileSize)
        local growRow = barDB.buttonGrowth == "ROW"
        widget:SetSize(growRow and width or height, growRow and height or width)
    end,

    UpdateButtonTextures = function(widget)
        for _, button in pairs(widget:GetButtons()) do
            button:SetTextures()
            button:SetIconTextures()
        end
    end,
}

--[[ Constructor ]]
local function Constructor()
    --[[ Frame ]]
    local frame = CreateFrame("Frame", Type .. AceGUI:GetNextWidgetNum(Type), UIParent, "BackdropTemplate")
    frame:SetFrameStrata("MEDIUM")
    frame:SetFrameLevel(0)
    frame:SetMovable(true)
    frame:SetClampedToScreen(true)

    for script, func in pairs(scripts) do
        frame:SetScript(script, func)
    end

    --[[ Anchor ]]
    local anchor = CreateFrame("Button", nil, frame, "BackdropTemplate")
    anchor:SetNormalTexture([[INTERFACE\ADDONS\FARMINGBAR\MEDIA\UNLOCK]])
    anchor:SetFrameStrata("MEDIUM")
    anchor:SetFrameLevel(2)
    anchor:SetMovable(true)
    anchor:RegisterForDrag("LeftButton")
    anchor:SetClampedToScreen(true)

    for script, func in pairs(anchorScripts) do
        anchor:SetScript(script, func)
    end

    --[[ Widget ]]
    local widget = {
        frame = frame,
        anchor = anchor,
        type = Type,
    }

    frame.obj = widget
    anchor.obj = widget

    for method, func in pairs(methods) do
        widget[method] = func
    end

    AceGUI:RegisterAsWidget(widget)

    return widget
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
