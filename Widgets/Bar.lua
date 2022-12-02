local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)
local AceGUI = LibStub("AceGUI-3.0")
local LSM = LibStub("LibSharedMedia-3.0")

local Type = "FarmingBar_Bar"
local Version = 1

local scripts = {
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

    OnEvent = function(frame, event)
        if event == "PLAYER_REGEN_ENABLED" then
            frame.obj:SetHidden()
        else
            frame.obj:SetHidden()
        end
    end,

    OnLeave = function(frame)
        frame.obj:SetMouseover()
    end,
}

local anchorScripts = {
    OnClick = function(anchor, mouseButton)
        local widget = anchor.obj
        if IsControlKeyDown() and mouseButton == "LeftButton" then
            widget:SetDBValue("movable", false)
            widget:SetMovable()
        elseif mouseButton == "RightButton" then
            private:LoadOptions("config", "bar" .. widget:GetID())
        end
    end,

    OnDragStart = function(anchor)
        anchor.obj.frame:StartMoving()
    end,

    OnDragStop = function(anchor)
        local widget = anchor.obj
        widget.frame:StopMovingOrSizing()
        widget:SetDBValue("point", { widget.frame:GetPoint() })
    end,

    OnEnter = function(anchor, ...)
        if not addon:IsHooked(anchor, "OnUpdate") then
            addon:HookScript(anchor, "OnUpdate", function()
                private:LoadTooltip(anchor, "ANCHOR_CURSOR", 0, 0, private:GetBarTooltip(anchor.obj))
            end)
        end

        local widget = anchor.obj
        widget:CallScript("OnEnter", widget.frame, ...)
    end,

    OnLeave = function(anchor, ...)
        if addon:IsHooked(anchor, "OnUpdate") then
            addon:Unhook(anchor, "OnUpdate")
        end

        private:ClearTooltip()

        local widget = anchor.obj
        widget:CallScript("OnLeave", widget.frame, ...)
    end,
}

local methods = {
    OnAcquire = function(widget)
        widget:SetUserData("buttons", {})
    end,

    OnRelease = function(widget)
        local buttons = widget:GetButtons()
        if not buttons then
            return
        end
        for _, button in pairs(buttons) do
            button:Release()
        end
    end,

    CallScript = function(widget, event, ...)
        widget.frame:GetScript(event)(...)
    end,

    Clear = function(widget)
        wipe(private.db.profile.bars[widget:GetID()].buttons)
        widget:UpdateButtons()
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

    GetButtons = function(widget)
        return widget:GetUserData("buttons")
    end,

    GetDB = function(widget)
        return private.db.profile.bars[widget:GetID()]
    end,

    GetID = function(widget)
        return widget:GetUserData("barID")
    end,

    GetProgress = function(widget)
        local complete, total = 0, 0
        for _, button in pairs(widget:GetButtons()) do
            local _, buttonDB = button:GetDB()
            if not button:IsEmpty() and buttonDB.objective > 0 then
                complete = complete + (button:IsObjectiveComplete() and 1 or 0)
                total = total + 1
            end
        end
        return complete, total
    end,

    Hide = function(widget)
        widget.frame:Hide()
        for _, button in pairs(widget:GetButtons()) do
            button:Hide()
        end
    end,

    LayoutButtons = function(widget)
        local barDB = widget:GetDB()
        local skin = private.db.global.skins[barDB.skin]
        local buttons = widget:GetButtons()

        for buttonID, button in pairs(buttons) do
            local row = ceil(buttonID / barDB.buttonsPerAxis)
            local newRow = mod(buttonID, barDB.buttonsPerAxis) == 1 or barDB.buttonsPerAxis == 1

            button:ClearAllPoints()
            button:SetSize(barDB.buttonSize, barDB.buttonSize)

            if buttonID == 1 then
                local anchorInfo = private.anchorPoints[barDB.buttonGrowth].button1[barDB.barAnchor]
                button:SetPoint(anchorInfo.anchor, widget.frame, anchorInfo.relAnchor, (anchorInfo.xCo * (barDB.buttonPadding + skin.backdrop.bgFile.tileSize)), anchorInfo.yCo * (barDB.buttonPadding + skin.backdrop.bgFile.tileSize))
            elseif newRow then
                local anchorInfo = private.anchorPoints[barDB.buttonGrowth].newRowButton[barDB.barAnchor]
                button:SetPoint(anchorInfo.anchor, buttons[buttonID - barDB.buttonsPerAxis].frame, anchorInfo.relAnchor, anchorInfo.xCo * barDB.buttonPadding, anchorInfo.yCo * barDB.buttonPadding)
            else
                local anchorInfo = private.anchorPoints[barDB.buttonGrowth].button[barDB.barAnchor]
                button:SetPoint(anchorInfo.anchor, buttons[buttonID - 1].frame, anchorInfo.relAnchor, anchorInfo.xCo * barDB.buttonPadding, anchorInfo.yCo * barDB.buttonPadding)
            end
        end

        -- Backdrop
        local width = (barDB.buttonSize * min(barDB.numButtons, barDB.buttonsPerAxis)) + (barDB.buttonPadding * (min(barDB.numButtons, barDB.buttonsPerAxis) + 1)) + (2 * skin.backdrop.bgFile.tileSize)
        local numRows = ceil(#buttons / barDB.buttonsPerAxis)
        local height = (barDB.buttonSize * numRows) + (barDB.buttonPadding * (numRows + 1)) + (2 * skin.backdrop.bgFile.tileSize)
        local growRow = barDB.buttonGrowth == "ROW"
        widget:SetSize(growRow and width or height, growRow and height or width)
    end,

    SetAlpha = function(widget, alpha, hideEmpty)
        widget.frame:SetAlpha(alpha)

        for _, button in pairs(widget:GetButtons()) do
            local isEmpty = hideEmpty and button:IsEmpty()
            button:SetAlpha(not private.ObjectiveFrame:GetObjective() and isEmpty and 0 or alpha)
        end
    end,

    SetBackdrop = function(widget)
        local barDB = widget:GetDB()
        local skin = private.db.global.skins[barDB.skin]

        local frame = widget.frame
        local texture = LSM:Fetch(LSM.MediaType.BACKGROUND, skin.backdrop.bgFile.bgFile)
        local edgeFile = LSM:Fetch(LSM.MediaType.BORDER, skin.backdrop.bgFile.edgeFile)
        local bgFile = addon:CloneTable(skin.backdrop.bgFile)
        bgFile.bgFile = texture
        bgFile.edgeFile = edgeFile
        frame:SetBackdrop(skin.backdrop.enabled and bgFile)
        frame:SetBackdropColor(unpack(skin.backdrop.bgColor))
        frame:SetBackdropBorderColor(unpack(skin.backdrop.borderColor))

        local anchor = widget.anchor
        anchor:SetBackdrop(bgFile)
        anchor:SetBackdropColor(unpack(skin.backdrop.bgColor))
        anchor:SetBackdropBorderColor(unpack(skin.backdrop.borderColor))
    end,

    SetDBValue = function(widget, key, value)
        private.db.profile.bars[widget:GetID()][key] = value
    end,

    SetEvents = function(widget)
        local barDB = widget:GetDB()

        widget.frame:UnregisterAllEvents()

        for _, event in pairs(barDB.hiddenEvents) do
            widget.frame:RegisterEvent(event)
        end

        widget.frame:RegisterEvent("PLAYER_REGEN_ENABLED")
    end,

    SetHeight = function(widget, height)
        widget.frame:SetHeight(height)
    end,

    SetHidden = function(widget)
        if UnitAffectingCombat("player") then
            return
        end

        local barDB = widget:GetDB()
        if not barDB then
            return
        end

        RegisterStateDriver(widget.frame, "visibility", barDB.hideInCombat and "[combat] hide" or "")
        for _, button in pairs(widget:GetButtons()) do
            RegisterStateDriver(button.frame, "visibility", barDB.hideInCombat and "[combat] hide" or "")
        end

        if barDB.overrideHidden then
            widget:Hide()
            return
        end

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
            else
                error(L["barDB.hidden must return a \"function\""])
            end
        else
            error(L["barDB.hidden must return a \"function\""])
        end
    end,

    SetID = function(widget, barID)
        if widget:GetID() then
            if private.db.global.debug.enabled then
                error(format(L["Bar is already assigned an ID: %d"], widget:GetID()))
            end
            return
        end

        widget.anchor.text:SetText(barID)

        widget:SetUserData("barID", barID)
        widget:DrawButtons()
        widget:Update()
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

    SetMovable = function(widget)
        local barDB = widget:GetDB()

        if barDB.movable then
            widget.anchor:Show()
        else
            widget.anchor:Hide()
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
        widget.anchor:SetPoint(anchorInfo.anchor, widget.frame, anchorInfo.relAnchor, anchorInfo.xCo * barDB.buttonPadding, anchorInfo.yCo * barDB.buttonPadding)

        widget:LayoutButtons()
    end,

    SetProgress = function(widget)
        local progress = widget:GetUserData("progress")
        local total = widget:GetUserData("total")

        local newProgress, newTotal = widget:GetProgress()

        if total == newTotal and progress ~= newProgress and newProgress <= newTotal then
            -- An objective has been lost or met
            private:AlertBar(widget, progress, total, newProgress, newTotal)
        end

        widget:SetUserData("progress", newProgress)
        widget:SetUserData("total", newTotal)
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

        for _, button in pairs(widget:GetButtons()) do
            button:Show()
        end
    end,

    Update = function(widget)
        widget:DrawButtons()
        widget:SetBackdrop()
        widget:SetPoints()
        widget:SetHidden()
        widget:SetMouseover()
        widget:SetMovable()
        widget:SetScale()
        widget:UpdateFontstrings()
        widget:SetEvents()
    end,

    UpdateButtons = function(widget)
        widget:UpdateButtonTextures()
        widget:UpdateFontstrings()
        for _, button in pairs(widget:GetButtons()) do
            button:SetCount()
        end
    end,

    UpdateButtonTextures = function(widget)
        for _, button in pairs(widget:GetButtons()) do
            button:SetTextures()
            button:SetIconTextures()
        end
    end,

    UpdateFontstrings = function(widget)
        for _, button in pairs(widget:GetButtons()) do
            button:SetFontstrings()
        end

        local fontDB = private.db.profile.style.font
        widget.anchor.text:SetFont(LSM:Fetch("font", fontDB.face), fontDB.size, fontDB.outline)
    end,
}

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
    anchor:SetFrameStrata("MEDIUM")
    anchor:SetFrameLevel(2)
    anchor:SetMovable(true)
    anchor:RegisterForDrag("LeftButton")
    anchor:RegisterForClicks("AnyUp", "AnyDown")
    anchor:SetClampedToScreen(true)
    anchor.text = anchor:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
    anchor.text:SetPoint("CENTER", 0, 0)

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
