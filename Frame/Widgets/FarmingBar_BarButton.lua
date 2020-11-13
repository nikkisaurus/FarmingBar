local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

local pairs = pairs
-- local strfind = string.find
local CreateFrame, UIParent = CreateFrame, UIParent
local Config, barList

--*------------------------------------------------------------------------

local Type = "FarmingBar_BarButton"
local Version = 1

-- --*------------------------------------------------------------------------

local function frame_OnClick(self, buttonClicked, ...)
    local widget = self.obj
    local barID = widget:GetBarID()
    local selected = widget:GetUserData("selected")

    ------------------------------------------------------------

    local buttons = barList.children
    local first, target

    -- Deselect "All Bars" button; never allow it to be selected with other buttons
    buttons[1]:SetSelected(false, true)

    if IsShiftKeyDown() then
        for key, button in pairs(buttons) do
            if button == barList:GetUserData("lastSelected") then
                first = key
            elseif button == widget then
                target = key
            end
        end
    elseif not IsControlKeyDown() or barID == 0 then
        if selected and buttonClicked == "RightButton" then
            widget:ShowMenu()
            return
        end

        for key, button in pairs(buttons) do
            button:SetSelected(false)
        end
    end

    ------------------------------------------------------------


    if first and target then
        if barID ~= 0 then
            widget:SetSelected(true)
        end
        local offset = (first < target) and 1 or -1
        for i = first + offset, target - offset, offset do
            buttons[i]:SetSelected(true, true)
        end
    else
        widget:SetSelected(true)
    end

    ------------------------------------------------------------

    if buttonClicked == "RightButton" then
        widget:ShowMenu()
    elseif barID == 0 then
        PlaySound(852)
        addon:Config_LoadAllBars()
    else
        PlaySound(852)
        addon:Config_LoadBar(barID)
    end

    widget:Fire("OnClick", buttonClicked, ...)
end

------------------------------------------------------------

-- local function frame_OnLeave(self)
--     GameTooltip:ClearLines()
--     GameTooltip:Hide()
-- end

--*------------------------------------------------------------------------

local methods = {
    OnAcquire = function(self)
        Config = addon.Config
        barList = Config:GetUserData("barList")
        -- self:SetUserData("tooltip", "GetObjectiveButtonTooltip")

        self:SetHeight(25)
        self.text:SetText("")

        self:SetSelected(false)
    end,

    ------------------------------------------------------------

    GetBarID = function(self)
        return self:GetUserData("barID")
    end,

    ------------------------------------------------------------

    GetBarTitle = function(self)
        return self:GetUserData("barTitle")
    end,

    ------------------------------------------------------------

    Select = function(self)
        self.frame:Click()
    end,

    ------------------------------------------------------------

    SetBarID = function(self, barID)
        local barTitle = addon:GetBarTitle(barID)
        self:SetUserData("barID", barID)
        self:SetUserData("barTitle", barTitle)
        self.text:SetText(barTitle)
    end,

    ------------------------------------------------------------

    SetSelected = function(self, selected, supressLastSelected)
        self:SetUserData("selected", selected)

        if not supressLastSelected then
            barList:SetUserData("lastSelected", self)
        end

        if selected then
            self.frame:LockHighlight()
        else
            self.frame:UnlockHighlight()
        end
    end,

    ------------------------------------------------------------

    ShowMenu = function(self)
        local numSelectedButtons = 0

        for _, button in pairs(barList.children) do
            if button:GetUserData("selected") then
                numSelectedButtons = numSelectedButtons + 1
            end
        end

        ------------------------------------------------------------

        local menu = {
            {notCheckable = true, notClickable = true, text = ""},

            {
                notCheckable = true,
                text = L["Close"],
            }

        }

        ------------------------------------------------------------

        if self:GetBarID() == 0 then
            tinsert(menu, 1, {
                notCheckable = true,
                text = L["Remove All"],
                func = function() StaticPopup_Show("FARMINGBAR_CONFIRM_REMOVE_ALL_BARS") end,
            })
        else
            tinsert(menu, 1, {
                notCheckable = true,
                text = numSelectedButtons > 1 and L["Remove Selected"] or L["Remove"],
                func = function() addon:RemoveSelectedBars() end,
            })
        end

        ------------------------------------------------------------

        EasyMenu(menu, addon.MenuFrame, self.frame, 0, 0, "MENU")
    end,
}

--*------------------------------------------------------------------------

local function Constructor()
    local frame = CreateFrame("Button", nil, UIParent)
	frame:Hide()
    frame:RegisterForDrag("LeftButton")
    frame:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    frame:SetScript("OnClick", frame_OnClick)
	-- frame:SetScript("OnLeave", frame_OnLeave)

    ------------------------------------------------------------

    local background = frame:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints(frame)
    background:SetTexture(130783)
    background:SetVertexColor(1, 1, 1, .05)

    frame:SetHighlightTexture(130783)
    frame:GetHighlightTexture():SetVertexColor(1, 1, 1, .15)
    ------------------------------------------------------------

    local text = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    text:SetJustifyH("LEFT")
    text:SetWordWrap(false)
    text:SetPoint("LEFT", 0, 0)
    text:SetPoint("RIGHT")

    ------------------------------------------------------------

    local widget = {
		type  = Type,
        frame = frame,
        text = text,
    }

    frame.obj = widget

    for method, func in pairs(methods) do
        widget[method] = func
    end

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)