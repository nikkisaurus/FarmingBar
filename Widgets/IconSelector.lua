local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)
-- Optional libraries
local ACD = LibStub("AceConfigDialog-3.0")
local AceGUI = LibStub("AceGUI-3.0", true)
local LSM = LibStub("LibSharedMedia-3.0")

local Type = "FarmingBar_IconSelector"
local Version = 1

-- *------------------------------------------------------------------------

local function PageButton_OnClick(button, buttonID)
    local widget = button.obj
    local page, newPage = widget:GetUserData("page")

    if buttonID == 1 then
        newPage = 1
    elseif buttonID == 2 then
        newPage = page - 1
    elseif buttonID == 3 then
        newPage = page + 1
    elseif buttonID == 4 then
        newPage = widget:GetUserData("numPages")
    end

    widget:LoadPage(newPage)
end

local function SelectIcon(widget, iconID)
    widget:Fire("OnClose", iconID)
end

-- *------------------------------------------------------------------------
-- Widget methods

local methods = {
    OnAcquire = function(self)
        self.frame:Show()
        self.searchbox:SetText("")
        self.searchbox:SetFocus()
        self:LoadIcons()
    end,

    OnRelease = function(self)
        local objectiveTitle = self:GetUserData("objectiveTitle")
        if type(objectiveTitle) == "string" then
            C_Timer.After(0.1, function()
                private:LoadOptions()
            end)
        else -- button widget
            C_Timer.After(0.1, function()
                private:LoadObjectiveEditor(objectiveTitle)
            end)
        end
    end,

    LoadIcons = function(self, filter)
        -- Get displayed icons
        local icons = {}
        for iconID, iconName in pairs(private.FileData) do
            if
                not filter
                or filter == ""
                or strfind(strlower(iconName), strlower(filter))
                or tonumber(filter) and strfind(iconID, tonumber(filter))
            then
                tinsert(icons, { iconID = iconID, iconName = iconName })
            end
        end
        self:SetUserData("icons", icons)

        -- Determine the number of icons per page
        local numIcons = addon.tcount(icons)
        local numPages = ceil(numIcons / private.CONST.MAX_ICONS)
        self:SetUserData("page", 1)
        self:SetUserData("numPages", numPages)

        self:SetPageText()

        self:LoadPage(1)
    end,

    LoadObjective = function(self, objectiveTitle)
        self:SetUserData("objectiveTitle", objectiveTitle)
        if type(objectiveTitle) == "string" then
            self.window:SetTitle(format("%s %s - %s", L.addonName, L["Icon Selector"], objectiveTitle))
        else -- button widget
            local barID, buttonID = objectiveTitle:GetID()
            self.window:SetTitle(format("%s %s (%d:%d)", L.addonName, L["Icon Selector"], barID, buttonID))
        end
        self:SetIcon(objectiveTitle)
    end,

    LoadPage = function(self, page)
        self.iconGroup:ReleaseChildren()

        local icons = self:GetUserData("icons")
        self:SetUserData("page", page)
        self:UpdateButtons()
        self:SetPageText()

        for i = 1, 500 do
            local iconInfo = icons[i * page]
            if iconInfo then
                -- Create widget
                local iconID = iconInfo.iconID
                local icon = AceGUI:Create("Icon")
                icon:SetImageSize(35, 35)
                icon:SetWidth(40)
                icon:SetImage(iconID)
                self.iconGroup:AddChild(icon)

                -- Setup func
                icon:SetCallback("OnClick", function()
                    if IsShiftKeyDown() then
                        SelectIcon(self, iconID)
                    else
                        self:SetIcon(_, iconID)
                    end
                end)

                -- Setup tooltip
                icon:SetCallback("OnEnter", function()
                    private:LoadTooltip(icon.frame, "ANCHOR_BOTTOMRIGHT", 0, 0, {
                        {
                            line = private.FileData[iconID],
                            color = { 1, 0.82, 0, 1 },
                        },
                        {
                            line = L["Shift+left-click to choose this icon."],
                            color = { 1, 1, 1, 1 },
                        },
                    })
                end)

                icon:SetCallback("OnLeave", function()
                    private:ClearTooltip()
                end)
            else
                return
            end
        end
    end,

    SetIcon = function(self, objectiveTitle, iconID)
        local objectiveInfo, icon

        if type(objectiveTitle) == "string" then
            objectiveInfo = private.db.global.objectives[objectiveTitle]
            icon = objectiveInfo and private:GetObjectiveIcon(objectiveInfo) or iconID
        else -- button widget
            local _, buttonDB = objectiveTitle:GetDB()
            icon = buttonDB and buttonDB.icon.id
        end

        self.icon:SetImage(icon)
        self.icon:SetText(format("%d (%s)", icon, private.FileData[icon]))

        self:SetUserData("iconID", icon)
    end,

    SetPageText = function(self)
        self.iconScrollFrame:SetTitle(
            format("%s %d/%d", L["Page"], self:GetUserData("page"), self:GetUserData("numPages"))
        )
    end,

    UpdateButtons = function(self)
        local page = self:GetUserData("page")
        local numPages = self:GetUserData("numPages")

        self.first:SetDisabled(page == 1)
        self.previous:SetDisabled((page - 1) == 0)
        self.next:SetDisabled((page + 1) > numPages)
        self.last:SetDisabled(page == numPages)
    end,
}

-- *------------------------------------------------------------------------
-- Constructor

local function Constructor()
    local window = AceGUI:Create("Frame")
    window:SetTitle(L.addonName)
    window:SetLayout("Flow")

    local frame = window.frame
    private:AddSpecialFrame(frame, "FarmingBar_IconSelector")

    local icon = AceGUI:Create("InteractiveLabel")
    icon:SetFullWidth(true)
    icon:SetImageSize(35, 35)
    icon:SetImage(134400)
    window:AddChild(icon)

    icon:SetCallback("OnClick", function(self)
        if IsShiftKeyDown() then
            SelectIcon(self.obj, self.obj:GetUserData("iconID"))
        end
    end)

    icon:SetCallback("OnEnter", function()
        private:LoadTooltip(icon.frame, "ANCHOR_TOPLEFT", 0, 0, {
            {
                line = L["Shift+left-click to choose this icon."],
                color = { 1, 1, 1, 1 },
            },
        })
    end)

    icon:SetCallback("OnLeave", function()
        private:ClearTooltip()
    end)

    local searchbox = AceGUI:Create("EditBox")
    searchbox:SetFullWidth(true)
    searchbox:SetLabel(SEARCH)
    searchbox:DisableButton(true)
    window:AddChild(searchbox)

    searchbox:SetCallback("OnEnterPressed", function(self)
        self:ClearFocus()
    end)

    searchbox:SetCallback("OnTextChanged", function(self)
        self.obj:LoadIcons(self:GetText())
    end)

    local first = AceGUI:Create("Button")
    first:SetText(L["First"])
    first:SetRelativeWidth(1 / 4)
    window:AddChild(first)

    first:SetCallback("OnClick", function(self)
        PageButton_OnClick(self, 1)
    end)

    local previous = AceGUI:Create("Button")
    previous:SetText(PREVIOUS)
    previous:SetRelativeWidth(1 / 4)
    window:AddChild(previous)

    previous:SetCallback("OnClick", function(self)
        PageButton_OnClick(self, 2)
    end)

    local next = AceGUI:Create("Button")
    next:SetText(NEXT)
    next:SetRelativeWidth(1 / 4)
    window:AddChild(next)

    next:SetCallback("OnClick", function(self)
        PageButton_OnClick(self, 3)
    end)

    local last = AceGUI:Create("Button")
    last:SetText(L["Last"])
    last:SetRelativeWidth(1 / 4)
    window:AddChild(last)

    last:SetCallback("OnClick", function(self)
        PageButton_OnClick(self, 4)
    end)

    local iconScrollFrame = AceGUI:Create("InlineGroup")
    iconScrollFrame:SetFullWidth(true)
    iconScrollFrame:SetFullHeight(true)
    iconScrollFrame:SetLayout("Fill")
    iconScrollFrame:SetTitle(L["Page"])
    window:AddChild(iconScrollFrame)

    local iconGroup = AceGUI:Create("ScrollFrame")
    iconGroup:SetLayout("Flow")
    iconScrollFrame:AddChild(iconGroup)

    local widget = {
        type = Type,
        window = window,
        frame = frame,
        icon = icon,
        searchbox = searchbox,
        iconScrollFrame = iconScrollFrame,
        iconGroup = iconGroup,
        first = first,
        previous = previous,
        next = next,
        last = last,
    }

    for key, value in pairs(widget) do
        if key ~= "type" then
            value.obj = widget
        end
    end

    for method, func in pairs(methods) do
        widget[method] = func
    end

    return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
