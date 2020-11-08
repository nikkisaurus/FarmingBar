local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

local pairs = pairs
local CreateFrame, UIParent = CreateFrame, UIParent
local ObjectiveBuilder, objectiveList

--*------------------------------------------------------------------------

local Type = "FarmingBar_ObjectiveButton"
local Version = 1

--*------------------------------------------------------------------------

local function FocusRenamingEditBox()
    for _, button in addon.pairs(objectiveList.children, function(a, b) return a > b end) do
        if button.editbox:IsVisible() then
            button.editbox:SetFocus()
            button.editbox:HighlightText()
            break
        end
    end
end

-- --*------------------------------------------------------------------------

local function EditBox_OnEnterPressed(self)
    local widget = self.obj
    local oldObjectiveTitle = widget:GetUserData("objectiveTitle")
    local newObjectiveTitle = self:GetText()

    if newObjectiveTitle ~= oldObjectiveTitle then
        addon:RenameObjective(oldObjectiveTitle, newObjectiveTitle)
    end

    widget:SetObjective(newObjectiveTitle)

    ObjectiveBuilder:RefreshObjectives()
    ObjectiveBuilder:SelectObjective(newObjectiveTitle)
    objectiveList:GetUserData("renaming")[oldObjectiveTitle] = false

    self:Hide()
    FocusRenamingEditBox()
end

------------------------------------------------------------

local function EditBox_OnEscapePressed(self)
    objectiveList:GetUserData("renaming")[self.obj:GetUserData("objectiveTitle")] = false
    ObjectiveBuilder:RefreshObjectives()

    self:Hide()
    FocusRenamingEditBox()
end

------------------------------------------------------------

local function EditBox_OnHide(self)
    self:ClearFocus()
    self:SetText("")

    local widget = self.obj
    widget.text:Show()
    widget.text:SetText(widget:GetUserData("objectiveTitle"))
end

------------------------------------------------------------

local function EditBox_OnShow(self)
    local widget = self.obj
    local objectiveTitle = widget:GetUserData("objectiveTitle")
    objectiveList:GetUserData("renaming")[objectiveTitle] = true

    widget.text:Hide()
    self:SetText(objectiveTitle)
    self:SetFocus()
    self:HighlightText()
end

------------------------------------------------------------

local function frame_OnClick(self, buttonClicked, ...)
    local widget = self.obj
    local selected = widget:GetUserData("selected")

    ------------------------------------------------------------

    local buttons = objectiveList.children
    local first, target

    if IsShiftKeyDown() then
        for key, button in pairs(buttons) do
            if button == objectiveList:GetUserData("lastSelected") then
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
            local button = buttons[i]
            if not button:GetUserData("filtered") then
                button:SetSelected(true, true)
            end
        end
    end

    ------------------------------------------------------------

    if buttonClicked == "RightButton" then
        widget:ShowMenu()
    else
        PlaySound(852)
        ObjectiveBuilder:SelectObjective(widget:GetUserData("objectiveTitle"))
    end

    widget:Fire("OnClick", buttonClicked, ...)
end

------------------------------------------------------------

local function frame_OnDragStart(self)
    addon.DragFrame:Load(self.obj:GetUserData("objectiveTitle"))
end

------------------------------------------------------------

local function frame_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", 0, 0)
    addon:GetObjectiveButtonTooltip(self.obj, GameTooltip)
    GameTooltip:Show()
end

------------------------------------------------------------

local function frame_OnLeave(self)
    GameTooltip:ClearLines()
    GameTooltip:Hide()
end

------------------------------------------------------------

local function frame_OnReceiveDrag(self)
    -- TODO
end

--*------------------------------------------------------------------------

local methods = {
    OnAcquire = function(self)
        ObjectiveBuilder = addon.ObjectiveBuilder
        objectiveList = ObjectiveBuilder:GetUserData("objectiveList")

        self:SetHeight(25)
        self.text:SetText("")
        self.icon:SetTexture(134400)
        self.editbox:Hide()

        self:SetSelected(false)
    end,

    ------------------------------------------------------------

    GetObjective = function(self)
        return self:GetUserData("objectiveTitle")
    end,

    ------------------------------------------------------------

    RefreshIcon = function(self)
        self.icon:SetTexture(addon:GetObjectiveIcon(self:GetObjective()))
    end,

    ------------------------------------------------------------

    RenameObjective = function(self)
        self.editbox:Show()
    end,

    ------------------------------------------------------------

    Select = function(self)
        self.frame:Click()
    end,

    ------------------------------------------------------------

    SetObjective = function(self, objectiveTitle)
        self:SetUserData("objectiveTitle", objectiveTitle)
        self.text:SetText(objectiveTitle)
        self.icon:SetTexture(addon:GetObjectiveIcon(objectiveTitle))
        if objectiveList:GetUserData("renaming")[self:GetUserData("objectiveTitle")] then
            self:RenameObjective()
        end
    end,

    ------------------------------------------------------------

    SetSelected = function(self, selected, supressLastSelected)
        self:SetUserData("selected", selected)

        if not supressLastSelected then
            objectiveList:SetUserData("lastSelected", self)
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

        for _, button in pairs(objectiveList.children) do
            if button:GetUserData("selected") then
                numSelectedButtons = numSelectedButtons + 1
            end
        end

        ------------------------------------------------------------

        local menu = {
            {
                notCheckable = true,
                text = numSelectedButtons > 1 and L["Duplicate All"] or L["Duplicate"],
                func = function() addon:DuplicateSelectedObjectives() end,
            },

            {notCheckable = true, notClickable = true, text = ""},

            {
                notCheckable = true,
                text = numSelectedButtons > 1 and L["Delete All"] or L["Delete"],
                func = function() addon:DeleteSelectedObjectives() end,
            },

            {notCheckable = true, notClickable = true, text = ""},

            {
                notCheckable = true,
                text = L["Close"],
            }

        }

        ------------------------------------------------------------

        if numSelectedButtons == 1 then
            tinsert(menu, 1, {
                notCheckable = true,
                text = L["Rename"],
                func = function() self:RenameObjective() end,
            })

            tinsert(menu, 3, {
                notCheckable = true,
                disabled = true,
                text = L["Export"],
                func = function() end,
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
    frame:SetScript("OnDragStart", frame_OnDragStart)
	frame:SetScript("OnEnter", frame_OnEnter)
	frame:SetScript("OnLeave", frame_OnLeave)
	frame:SetScript("OnReceiveDrag", frame_OnReceiveDrag)

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

	local editbox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
	editbox:SetAutoFocus(false)
	editbox:SetFontObject(ChatFontNormal)
	editbox:SetMaxLetters(256)
	editbox:SetTextInsets(0, 0, 3, 3)
	editbox:SetPoint("LEFT", icon, "RIGHT", 7, 0)
	editbox:SetPoint("RIGHT", -5, 5)
    editbox:SetHeight(19)

	editbox:SetScript("OnEscapePressed", EditBox_OnEscapePressed)
	editbox:SetScript("OnEnterPressed", EditBox_OnEnterPressed)
	editbox:SetScript("OnHide", EditBox_OnHide)
    editbox:SetScript("OnShow", EditBox_OnShow)

    ------------------------------------------------------------

    if IsAddOnLoaded("ElvUI") then
        local E = unpack(_G["ElvUI"])
        local S = E:GetModule('Skins')

		S:HandleEditBox(editbox)
    end

    ------------------------------------------------------------

    local widget = {
		type  = Type,
        frame = frame,
        icon = icon,
        text = text,
        editbox = editbox,
    }

    frame.obj, editbox.obj = widget, widget

    for method, func in pairs(methods) do
        widget[method] = func
    end

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)