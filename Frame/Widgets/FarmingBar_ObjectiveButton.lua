local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

local pairs = pairs
local CreateFrame, UIParent = CreateFrame, UIParent

--*------------------------------------------------------------------------

local Type = "FarmingBar_ObjectiveButton"
local Version = 1

--*------------------------------------------------------------------------

local function FocusRenamingEditBox()
    for _, button in addon.pairs(addon.ObjectiveBuilder.objectiveList.children, function(a, b) return a > b end) do
        if button.editbox:IsVisible() then
            button.editbox:SetFocus()
            button.editbox:HighlightText()
            break
        end
    end
end

--*------------------------------------------------------------------------

local function Control_OnClick(self, buttonClicked)
    local ObjectiveBuilder = addon.ObjectiveBuilder
    local widget = self.widget
    local selected = widget:GetUserData("selected")

    ------------------------------------------------------------

    local buttons = ObjectiveBuilder.objectiveList.children
    local currentKey, lastSelectedKey

    if IsShiftKeyDown() then
        for key, button in pairs(buttons) do
            if button == ObjectiveBuilder.objectiveList:GetUserData("lastSelected") then
                lastSelectedKey = key
            elseif button == widget then
                currentKey = key
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
    if lastSelectedKey then
        local offset = (lastSelectedKey < currentKey) and 1 or -1
        for i = lastSelectedKey + offset, currentKey - offset, offset do
            buttons[i]:SetSelected(true, true)
        end
    end

    ------------------------------------------------------------

    if buttonClicked == "RightButton" then
        widget:ShowMenu()
    else
        PlaySound(852) -- SOUNDKIT.IG_MAINMENU_OPTION
        addon:ObjectiveBuilder_DrawTabs()
        ObjectiveBuilder:SelectObjective(widget:GetUserData("objectiveTitle"))
    end
end

------------------------------------------------------------

local function Control_OnDragStart(self)
    addon.DragFrame:Load(self.widget:GetUserData("objectiveTitle"))
end

------------------------------------------------------------

local function Control_OnDragStop(self)
    addon.DragFrame:Clear()
end

------------------------------------------------------------

local function Control_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", 0, 0)
    addon:GetObjectiveButtonTooltip(self.widget, GameTooltip)
    GameTooltip:Show()
end

------------------------------------------------------------

local function Control_OnLeave(self)
    GameTooltip:ClearLines()
    GameTooltip:Hide()
end

------------------------------------------------------------

local function Control_OnReceiveDrag(self)

end

--*------------------------------------------------------------------------

local function EditBox_OnEscapePressed(self)
    addon.ObjectiveBuilder.objectiveList:GetUserData("renaming")[self.widget:GetUserData("objectiveTitle")] = false

    self:Hide()
    FocusRenamingEditBox()
end

------------------------------------------------------------

local function EditBox_OnEnterPressed(self)
    local widget = self.widget
    local oldObjectiveTitle = widget:GetUserData("objectiveTitle")
    local newObjectiveTitle = self:GetText()

    if newObjectiveTitle ~= oldObjectiveTitle then
        addon:RenameObjective(oldObjectiveTitle, newObjectiveTitle)
    end
    widget:SetObjective(newObjectiveTitle)

    addon.ObjectiveBuilder:LoadObjectives(newObjectiveTitle)
    addon.ObjectiveBuilder.objectiveList:GetUserData("renaming")[oldObjectiveTitle] = false

    self:Hide()
    FocusRenamingEditBox()
end

------------------------------------------------------------

local function EditBox_OnHide(self)
    self:ClearFocus()
    self:SetText("")

    local widget = self.widget
    widget.text:Show()
    widget.text:SetText(widget:GetUserData("objectiveTitle"))
end

------------------------------------------------------------

local function EditBox_OnShow(self)
    local widget = self.widget
    local objectiveTitle = widget:GetUserData("objectiveTitle")
    addon.ObjectiveBuilder.objectiveList:GetUserData("renaming")[objectiveTitle] = true

    widget.text:Hide()
    self:SetText(objectiveTitle)
    self:SetFocus()
    self:HighlightText()
end


--*------------------------------------------------------------------------

local methods = {
    OnAcquire = function(self)
        self:SetSelected(false)
        self.icon:SetTexture(134400)
        self.editbox:Hide()
    end,

    ------------------------------------------------------------

    RenameObjective = function(self)
        self.editbox:Show()
    end,

    ------------------------------------------------------------

    SetObjective = function(self, objectiveTitle)
        self:SetUserData("objectiveTitle", objectiveTitle)
        self.text:SetText(objectiveTitle)
        self.icon:SetTexture(addon:GetObjectiveIcon(objectiveTitle))
        if addon.ObjectiveBuilder.objectiveList:GetUserData("renaming")[self:GetUserData("objectiveTitle")] then
            self:RenameObjective()
        end
    end,

    ------------------------------------------------------------

    SetSelected = function(self, selected, supressLastSelected)
        self:SetUserData("selected", selected)
        if not supressLastSelected then
            addon.ObjectiveBuilder.objectiveList:SetUserData("lastSelected", self)
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
        for _, button in pairs(addon.ObjectiveBuilder.objectiveList.children) do
            if button:GetUserData("selected") then
                numSelectedButtons = numSelectedButtons + 1
            end
        end

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

        EasyMenu(menu, addon.MenuFrame, self.frame, 0, 0, "MENU")
    end,
}

--*------------------------------------------------------------------------

local function Constructor()
    local frame = CreateFrame("Button", nil, UIParent, "OptionsListButtonTemplate, SecureHandlerDragTemplate")
    frame:SetHeight(35)

    frame:EnableMouse(true)
    frame:RegisterForClicks("AnyUp")
    frame:RegisterForDrag("LeftButton")

	frame:SetScript("OnClick", Control_OnClick)
    frame:SetScript("OnDragStart", Control_OnDragStart)
    frame:SetScript("OnDragStop", Control_OnDragStop)
	frame:SetScript("OnEnter", Control_OnEnter)
	frame:SetScript("OnLeave", Control_OnLeave)
	frame:SetScript("OnReceiveDrag", Control_OnReceiveDrag)
    frame:SetScript("OnUpdate", Control_OnUpdate)

    frame:SetPushedTextOffset(0, 0)
    frame:GetHighlightTexture():SetVertexColor(0.5, 0.5, 0.5, .5)
    frame:SetNormalTexture("Interface\\BUTTONS\\UI-LISTBOX-HIGHLIGHT2")

    local normal = frame:GetNormalTexture()
    normal:SetBlendMode("ADD")
    normal:SetVertexColor(.4, .4, .4, .25)

    local icon = frame:CreateTexture(nil, "OVERLAY")
    icon:SetSize(25, 25)
    icon:SetPoint("LEFT", frame, "LEFT", 3, 0)

    local text = frame:GetFontString()
    text:SetPoint("TOPLEFT", icon, "TOPRIGHT", 3, -1)
    text:SetPoint("RIGHT", -3, 0)
    text:SetJustifyH("LEFT")

	local editbox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
	editbox:SetAutoFocus(false)
	editbox:SetFontObject(ChatFontNormal)
	editbox:SetScript("OnEscapePressed", EditBox_OnEscapePressed)
	editbox:SetScript("OnEnterPressed", EditBox_OnEnterPressed)
	editbox:SetScript("OnHide", EditBox_OnHide)
	editbox:SetScript("OnShow", EditBox_OnShow)
	editbox:SetTextInsets(0, 0, 3, 3)
	editbox:SetMaxLetters(256)
	editbox:SetPoint("LEFT", icon, "RIGHT", 7, 0)
	editbox:SetPoint("RIGHT", -5, 5)
    editbox:SetHeight(19)

    ------------------------------------------------------------

    local widget = {
		type  = Type,
        frame = frame,
        icon = icon,
        text = text,
        editbox = editbox,
    }

    frame.widget, editbox.widget = widget, widget

    for method, func in pairs(methods) do
        widget[method] = func
    end

    if IsAddOnLoaded("ElvUI") then
        local E = unpack(_G["ElvUI"])
        local S = E:GetModule('Skins')

		S:HandleEditBox(widget.editbox)
    end

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)