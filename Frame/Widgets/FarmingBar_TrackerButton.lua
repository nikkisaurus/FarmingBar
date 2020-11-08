local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

local pairs = pairs
local CreateFrame, UIParent = CreateFrame, UIParent
local ObjectiveBuilder, trackerList

--*------------------------------------------------------------------------

local Type = "FarmingBar_TrackerButton"
local Version = 1

--*------------------------------------------------------------------------

local function frame_OnClick(self, buttonClicked, ...)
    local widget = self.obj
    local selected = widget:GetUserData("selected")

    ------------------------------------------------------------

    local buttons = trackerList.children
    local first, target

    if IsShiftKeyDown() then
        for key, button in pairs(buttons) do
            if button == trackerList:GetUserData("lastSelected") then
                first = key
            elseif button == widget then
                target = key
            end
        end
    elseif not IsControlKeyDown() then
        if selected and buttonClicked == "RightButton" then
            widget:ShowMenu()
            return
        end

        for key, button in pairs(buttons) do
            button:SetSelected(false)
        end
    end

    ------------------------------------------------------------

    widget:SetSelected(true)

    if first and target then
        local offset = (first < target) and 1 or -1
        for i = first + offset, target - offset, offset do
            buttons[i]:SetSelected(true, true)
        end
    end

    ------------------------------------------------------------

    if buttonClicked == "RightButton" then
        widget:ShowMenu()
    else
        PlaySound(852)
        print(widget:GetUserData("trackerName"))
    end

    widget:Fire("OnClick", buttonClicked, ...)
end

--*------------------------------------------------------------------------

local methods = {
    OnAcquire = function(self)
        ObjectiveBuilder = addon.ObjectiveBuilder
        trackerList = ObjectiveBuilder:GetUserData("trackerList")

        self:SetHeight(25)
        self.text:SetText("")
        self.icon:SetTexture(134400)

        self:SetSelected(false)
    end,

    ------------------------------------------------------------

    Select = function(self)
        print("COW")
        self.frame:Click()
    end,

    ------------------------------------------------------------

    SetSelected = function(self, selected, supressLastSelected)
        self:SetUserData("selected", selected)

        if not supressLastSelected then
            trackerList:SetUserData("lastSelected", self)
        end

        if selected then
            self.frame:LockHighlight()
        else
            self.frame:UnlockHighlight()
        end
    end,

    ------------------------------------------------------------

    SetTracker = function(self, trackerInfo)
        self:SetUserData("trackerType", trackerInfo.trackerType)
        self:SetUserData("trackerID", trackerInfo.trackerID)

        addon:GetTrackerDataTable(trackerInfo.trackerType, trackerInfo.trackerID, function(data)
            self:SetUserData("trackerName", data.name)
            self:SetUserData("trackerIcon", data.icon)

            self.text:SetText(data.name)
            self.icon:SetTexture(data.icon)
        end)
    end,

    ------------------------------------------------------------

    ShowMenu = function(self)
        local numSelectedButtons = 0

        for _, button in pairs(trackerList.children) do
            if button:GetUserData("selected") then
                numSelectedButtons = numSelectedButtons + 1
            end
        end

        ------------------------------------------------------------

        local menu = {
            {
                text = numSelectedButtons > 1 and L["Delete All"] or L["Delete"],
                notCheckable = true,
                func = function() addon:DeleteTracker() end,
            },

            {text = "", notCheckable = true, notClickable = true},

            {
                text = L["Close"],
                notCheckable = true,
            },
        }

        ------------------------------------------------------------

        EasyMenu(menu, addon.MenuFrame, self.frame, 0, 0, "MENU")
    end,
}

--*------------------------------------------------------------------------

local function Constructor()
    local frame = CreateFrame("Button", nil, UIParent)
	frame:Hide()
    -- frame:RegisterForDrag("LeftButton")
    frame:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    frame:SetScript("OnClick", frame_OnClick)
    -- frame:SetScript("OnDragStart", frame_OnDragStart)
	-- frame:SetScript("OnEnter", frame_OnEnter)
	-- frame:SetScript("OnLeave", frame_OnLeave)
	-- frame:SetScript("OnReceiveDrag", frame_OnReceiveDrag)

    ------------------------------------------------------------

    local background = frame:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints(frame)
    background:SetTexture(130783)
    background:SetVertexColor(1, 1, 1, .05)

    frame:SetHighlightTexture(130783)
    frame:GetHighlightTexture():SetVertexColor(1, 1, 1, .15)

    ------------------------------------------------------------

    local icon = frame:CreateTexture(nil, "ARTWORK")
    icon:SetSize(20, 20)
    icon:SetPoint("LEFT", 0, 0)

    ------------------------------------------------------------

    local text = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    text:SetJustifyH("LEFT")
    text:SetWordWrap(false)
    text:SetPoint("TOPLEFT", icon, "TOPRIGHT", 5, -2)
    text:SetPoint("RIGHT")

    ------------------------------------------------------------

    local widget = {
		type  = Type,
        frame = frame,
        icon = icon,
        text = text,
    }

    frame.obj = widget

    for method, func in pairs(methods) do
        widget[method] = func
    end

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)