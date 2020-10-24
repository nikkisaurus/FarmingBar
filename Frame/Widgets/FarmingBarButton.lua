local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)


--*------------------------------------------------------------------------

local Type = "FarmingBarButton"
local Version = 1

--*------------------------------------------------------------------------

local function Control_OnEnter(self)
    if addon.DragFrame:IsVisible() then
        self.widget:SetUserData("objectiveTitle", addon.DragFrame.text:GetText())
    end
end

local function Control_OnLeave(self)
    self.widget:SetUserData("objectiveTitle")
end

local function Control_OnReceiveDrag(self)
    local widget = self.widget
    local objectiveTitle = widget:GetUserData("objectiveTitle")


    if objectiveTitle then
        widget:SetObjective(objectiveTitle)
    elseif not objectiveTitle then
        local cursorType, cursorID = GetCursorInfo()
        ClearCursor()

        if cursorType == "item" then
            addon:CacheItem(cursorID, function(itemID)
                local defaultInfo = addon:GetDefaultObjective()
                defaultInfo.icon = C_Item.GetItemIconByID(itemID)
                defaultInfo.displayRef.trackerType = "ITEM"
                defaultInfo.displayRef.trackerID = itemID

                local tracker = addon:GetDefaultTracker()
                tracker.trackerType = "ITEM"
                tracker.trackerID = itemID

                tinsert(defaultInfo.trackers, tracker)

                local objectiveTitle = addon:CreateObjective((select(1, GetItemInfo(itemID))), defaultInfo, not addon.ObjectiveBuilder:IsVisible())
                widget:SetObjective(objectiveTitle)
            end, cursorID)
            return
        end
    end
end

--*------------------------------------------------------------------------

local methods = {
    OnAcquire = function(self)
        self.frame:ClearAllPoints()
        self.frame:Show()
    end,

    SetCount = function(self, count)
        self.Count:SetText(count)
    end,

    SetIcon = function(self, icon)
        self.Icon:SetTexture(icon)
    end,

    SetObjective = function(self, objectiveTitle)
        self:SetIcon(addon:GetObjectiveIcon(objectiveTitle))
        self:SetCount(addon:GetObjectiveCount(objectiveTitle))
    end,

    SetPoint = function(self, ...) --point, anchor, relpoint, x, y
        self.frame:SetPoint(...)
    end,

    SetSize = function(self, ...) --width, height
        self.frame:SetSize(...)
        self.Count:SetWidth(self.frame:GetWidth())
    end,
}

--*------------------------------------------------------------------------

local function Constructor()
    local frame = CreateFrame("Button", nil, UIParent, "SecureActionButtonTemplate, SecureHandlerDragTemplate")
	frame:SetScript("OnEnter", Control_OnEnter)
	frame:SetScript("OnLeave", Control_OnLeave)
	frame:SetScript("OnReceiveDrag", Control_OnReceiveDrag)

    local FloatingBG = frame:CreateTexture("$parentFloatingBG", "BACKGROUND", nil, -7)
    FloatingBG:SetAllPoints(frame)

    local Icon = frame:CreateTexture("$parentIcon", "BACKGROUND", nil, -6)
    Icon:SetAllPoints(frame)

    local Flash = frame:CreateTexture("$parentFlash", "BACKGROUND", nil, -5)
    Flash:SetAllPoints(frame)
    Flash:Hide()

    local Border = frame:CreateTexture("$parentBorder", "BORDER")
    Border:SetAllPoints(frame)
    Border:Hide()

    local AutoCastable = frame:CreateTexture("$parentAutoCastable", "OVERLAY")
    AutoCastable:SetAllPoints(frame)
    AutoCastable:Hide()

    local Count = frame:CreateFontString(nil, "OVERLAY")
    Count:SetFont([[Fonts\FRIZQT__.TTF]], 12, "NORMAL")
    Count:SetPoint("BOTTOMRIGHT", -2, 2)

    ------------------------------------------------------------

    local widget = {
		type  = Type,
        frame = frame,
        FloatingBG = FloatingBG,
        Icon = Icon,
        Flash = Flash,
        Border = Border,
        AutoCastable = AutoCastable,
        Count = Count,
    }

    frame.widget = widget

    for method, func in pairs(methods) do
        widget[method] = func
    end

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)