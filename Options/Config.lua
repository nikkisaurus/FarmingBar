local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

local pairs = pairs
local abs = math.abs
local Config = addon.Config

--*------------------------------------------------------------------------

local anchors = {
    TOPLEFT = L["Topleft"],
    TOP = L["Top"],
    TOPRIGHT = L["Topright"],
    LEFT = L["Left"],
    CENTER = L["Center"],
    RIGHT = L["Right"],
    BOTTOMLEFT = L["Bottomleft"],
    BOTTOM = L["Bottom"],
    BOTTOMRIGHT = L["Bottomright"],
}

------------------------------------------------------------

local anchorSort = {"TOPLEFT", "TOP", "TOPRIGHT", "LEFT", "CENTER", "RIGHT", "BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT"}

------------------------------------------------------------

local mainTabGroupTabs = {
    {text = L["Bar"], value = "barTab"},
    {text = L["Button"], value = "buttonTab"}
}

--*------------------------------------------------------------------------

local function GetBarList()
    local list = {}
    for k, v in pairs(addon.bars) do
        list[k] = L["Bar"].." "..k
    end

    return list
end

------------------------------------------------------------

local function GetBuiltInTemplates()
    local list = {}
    local sort = {}

    for templateName, _ in addon.pairs(addon.templates) do
        list[templateName] = templateName
        tinsert(sort, templateName)
    end

    return list, sort
end

------------------------------------------------------------

local function GetUserTemplates()
    local list = {}
    local sort = {}

    for templateName, _ in addon.pairs(FarmingBar.db.global.templates) do
        list[templateName] = templateName
        tinsert(sort, templateName)
    end

    return list, sort
end

--*------------------------------------------------------------------------

local function buttonWrap_OnValueChanged(self)
    local bar = addon.bars[Config:GetSelectedBar()]
    addon:SetBarDBInfo("buttonWrap", self:GetValue(), Config:GetSelectedBar()) --! needs fixed for when 1 button per
    bar:AnchorButtons()
    self.editbox:ClearFocus()
end

------------------------------------------------------------

local function countAnchor_OnValueChanged(self, _, selected)
    addon:SetBarDBInfo("button.fontStrings.count.anchor", selected, Config:GetSelectedBar())
    addon:UpdateButtons()
end

------------------------------------------------------------

local function countXOffset_OnValueChanged(self)
    addon:SetBarDBInfo("button.fontStrings.count.xOffset", self:GetValue(), Config:GetSelectedBar())
    addon:UpdateButtons()
    self.editbox:ClearFocus()
end

------------------------------------------------------------

local function countYOffset_OnValueChanged(self)
    addon:SetBarDBInfo("button.fontStrings.count.yOffset", self:GetValue(), Config:GetSelectedBar())
    addon:UpdateButtons()
    self.editbox:ClearFocus()
end

------------------------------------------------------------

local function mainTabGroup_OnGroupSelected(self, _, selected)
    local barID = Config:GetSelectedBar()
    if barID then
        Config:GetUserData("selectedTabs")[barID] = selected
    end

    ------------------------------------------------------------

    self:ReleaseChildren()

    local mainContent = AceGUI:Create("ScrollFrame")
    mainContent:SetLayout("Flow")
    Config:SetUserData("mainContent", mainContent)
    self:AddChild(mainContent)

    ------------------------------------------------------------

    if selected == "barTab" then
        addon:Config_LoadBarTab(mainContent)
    elseif selected == "buttonTab" then
        addon:Config_LoadButtonTab(mainContent)
    end
end

------------------------------------------------------------

local function numVisibleButtons_OnValueChanged(self)
    local bar = addon.bars[Config:GetSelectedBar()]
    addon:SetBarDBInfo("numVisibleButtons", self:GetValue(), Config:GetSelectedBar()) --! needs fixed to update buttons as added/removed (I don't remember what this comment was talking about??)
    bar:UpdateVisibleButtons()
    self.editbox:ClearFocus()
end

------------------------------------------------------------

local function objectiveAnchor_OnValueChanged(self, _, selected)
    addon:SetBarDBInfo("button.fontStrings.objective.anchor", selected, Config:GetSelectedBar())
    addon:UpdateButtons()
end

------------------------------------------------------------

local function objectiveXOffset_OnValueChanged(self)
    addon:SetBarDBInfo("button.fontStrings.objective.xOffset", self:GetValue(), Config:GetSelectedBar())
    addon:UpdateButtons()
    self.editbox:ClearFocus()
end

------------------------------------------------------------

local function objectiveYOffset_OnValueChanged(self)
    addon:SetBarDBInfo("button.fontStrings.objective.yOffset", self:GetValue(), Config:GetSelectedBar())
    addon:UpdateButtons()
    self.editbox:ClearFocus()
end

------------------------------------------------------------

local function padding_OnValueChanged(self)
    local bar = addon.bars[Config:GetSelectedBar()]
    addon:SetBarDBInfo("button.padding", self:GetValue(), Config:GetSelectedBar())
    bar:SetSize()
    bar:AnchorButtons()
    self.editbox:ClearFocus()
end

------------------------------------------------------------

local function size_OnValueChanged(self)
    local bar = addon.bars[Config:GetSelectedBar()]
    addon:SetBarDBInfo("button.size", self:GetValue(), Config:GetSelectedBar())
    bar:SetSize()
    self.editbox:ClearFocus()
end

------------------------------------------------------------

local function title_OnEnterPressed(self)
    addon:SetBarDBInfo("title", self:GetText(), Config:GetSelectedBar(), true)
    self:ClearFocus()
end

--*------------------------------------------------------------------------

local methods = {
    ClearSelectedBar = function(self)
        self:GetUserData("mainPanel"):ReleaseChildren()
        self:SetUserData("selectedBar")
    end,

    ------------------------------------------------------------

    GetBarButton = function(self, barID)
        for _, button in pairs(self:GetUserData("barList").children) do
            if button:GetBarID() == barID then
                return button
            end
        end
    end,

    ------------------------------------------------------------

    GetSelectedBar = function(self)
        return self:GetUserData("selectedBar")
    end,

    ------------------------------------------------------------

    GetSelectedTab = function(self, barID)
        return self:GetUserData("selectedTabs")[barID]
    end,

    ------------------------------------------------------------

    Load = function(self, barID)
        self.frame:Show()
        self:GetBarButton(barID or 0):Select()
        self:RefreshBars()
    end,

    ------------------------------------------------------------

    LoadBars = function(self)
        addon:AddBarButton(0)
        for barID, barDB in addon.pairs(addon.bars) do
            addon:AddBarButton(barID)
        end
        Config:RefreshBars()
    end,

    ------------------------------------------------------------

    RefreshBars = function(self)
        local barList = self:GetUserData("barList")
        local buttons = barList.children
        local numBars = #addon.bars

        ------------------------------------------------------------

        local numDeleted = #buttons - (numBars + 1)
        if numDeleted > 0 then
            self:ReleaseChild(buttons[#buttons])
            for i = 1, numBars do
                buttons[i + 1]:SetBarID(i)
            end
        end

        ------------------------------------------------------------

        if numDeleted < 0 then
            local numNewBars = abs(numDeleted)
            for i = 1, numNewBars do
                addon:AddBarButton((#buttons - 1) + i)
            end
        end

        ------------------------------------------------------------

        for key, button in pairs(buttons) do
            local barTitle = addon:GetBarTitle(key)
            if button:GetBarTitle() ~= barTitle then
                button:UpdateBarTitle()
            end
        end

        local barID = self:GetSelectedBar()
        local title = self:GetUserData("title")
        if barID and title then
            title:SetText(barList.children[barID + 1]:GetBarTitle())
        end

        ------------------------------------------------------------

        barList:DoLayout()
    end,

    ------------------------------------------------------------

    ReleaseChild = function(self, widget)
        -- Releasing widgets doesn't remove them from the parent container's children table, so we need to do it manually
        -- Remove the userdata reference to prevent error about already having been released

        widget = self:GetUserData(widget) or widget
        if not widget.parent then return end
        local children = widget.parent.children

        for key, child in pairs(children) do
            if widget == child then
                child:Release()
                self:SetUserData(widget)
                tremove(children, key)
            end
        end
    end,

    ------------------------------------------------------------

    SelectBar = function(self, barID)
        local barList = self:GetUserData("barList")
        local mainPanel = self:GetUserData("mainPanel")
        self:SetUserData("selectedBar", barID)

        mainPanel:ReleaseChildren()

        if barID then
            local title = AceGUI:Create("FarmingBar_InteractiveLabel")
            title:SetFullWidth(true)
            title:SetFontObject(GameFontNormalLarge)
            title:SetText(barList.children[barID + 1]:GetBarTitle())
            title:SetJustifyH("LEFT")
            mainPanel:AddChild(title)
            self:SetUserData("title", title)

            ------------------------------------------------------------

            local mainTabGroup = AceGUI:Create("TabGroup")
            mainTabGroup:SetFullWidth(true)
            mainTabGroup:SetFullHeight(true)
            mainTabGroup:SetLayout("Fill")
            mainTabGroup:SetTabs(mainTabGroupTabs)
            mainPanel:AddChild(mainTabGroup)
            self:SetUserData("mainTabGroup", mainTabGroup)

            mainTabGroup:SetCallback("OnGroupSelected", mainTabGroup_OnGroupSelected)
            mainTabGroup:SelectTab(self:GetSelectedTab(barID) or (FarmingBar.db.global.debug.ConfigButtons and "buttonTab" or "barTab"))
        end
    end,
}

--*------------------------------------------------------------------------

function addon:InitializeConfig()
    Config = AceGUI:Create("FarmingBar_Frame")
    Config:SetTitle("Farming Bar "..L["Config"])
    Config:SetLayout("FB30_SidebarGroup")
    Config:SetUserData("selectedTabs", {})
    Config:SetUserData("sidebarDenom", 4)
    addon.Config = Config

    for method, func in pairs(methods) do
        Config[method] = func
    end

    -- ------------------------------------------------------------

    local sidebar = AceGUI:Create("FarmingBar_InlineGroup")
    sidebar:SetLayout("Fill")
    Config:AddChild(sidebar)

    ------------------------------------------------------------

    local barList = AceGUI:Create("ScrollFrame")
    barList:SetLayout("FB30_List")
    sidebar:AddChild(barList)
    Config:SetUserData("barList", barList)

    ------------------------------------------------------------

    local mainPanel = AceGUI:Create("FarmingBar_InlineGroup")
    mainPanel:SetLayout("Flow")
    Config:AddChild(mainPanel)
    Config:SetUserData("mainPanel", mainPanel)

    ------------------------------------------------------------

    Config:LoadBars()

    ------------------------------------------------------------
    --Debug-----------------------------------------------------
    ------------------------------------------------------------
    if FarmingBar.db.global.debug.Config then
        C_Timer.After(1, function()
            Config:Load()
            local barButtons = barList.children
            if #barButtons > 1 then
                barButtons[2]:Select()
            end
        end)
    end
    ------------------------------------------------------------
    ------------------------------------------------------------
end

--*------------------------------------------------------------------------

function addon:AddBarButton(barID)
    local barList = Config:GetUserData("barList")

    local button = AceGUI:Create("FarmingBar_BarButton")
    button:SetFullWidth(true)
    button:SetBarID(barID)
    barList:AddChild(button)
    barList:DoLayout()

    return button
end

--*------------------------------------------------------------------------

function addon:Config_LoadBarTab(tabContent)
    local barID = Config:GetSelectedBar()
    local bar = barID > 0 and self.bars[barID]
    local barDB = barID > 0 and FarmingBar.db.profile.bars[barID]
    local charDB = barID > 0 and FarmingBar.db.char.bars[barID]

    if barID == 0 then
        local addBar = AceGUI:Create("Button")
        addBar:SetFullWidth(true)
        addBar:SetText(L["Add Bar"])
        tabContent:AddChild(addBar)

        addBar:SetCallback("OnClick", function() self:CreateBar() end)
    elseif barDB and charDB then
        local title = AceGUI:Create("EditBox")
        title:SetFullWidth(true)
        title:SetText(charDB.title)
        title:SetLabel("*"..L["Title"])
        tabContent:AddChild(title)

        title:SetCallback("OnEnterPressed", title_OnEnterPressed)

        --*------------------------------------------------------------------------

        local alertsGroup = AceGUI:Create("InlineGroup")
        alertsGroup:SetFullWidth(true)
        alertsGroup:SetTitle("*"..L["Alerts"])
        alertsGroup:SetLayout("Flow")
        tabContent:AddChild(alertsGroup)

        ------------------------------------------------------------

        local muteAll = AceGUI:Create("CheckBox")
        muteAll:SetRelativeWidth(1/3)
        muteAll:SetValue(charDB.alerts.muteAll)
        muteAll:SetLabel(L["Mute All"])
        alertsGroup:AddChild(muteAll)

        muteAll:SetCallback("OnValueChanged", function(self)
            addon:SetBarDBInfo("alerts.muteAll", self:GetValue(), Config:GetSelectedBar(), true)
        end)

        ------------------------------------------------------------

        local barProgress = AceGUI:Create("CheckBox")
        barProgress:SetRelativeWidth(1/3)
        barProgress:SetValue(charDB.alerts.barProgress)
        barProgress:SetLabel(L["Bar Progress"])
        barProgress:SetDisabled(true) -- ! temporary until implemented
        alertsGroup:AddChild(barProgress)

        barProgress:SetCallback("OnValueChanged", function(self)
            addon:SetBarDBInfo("alerts.barProgress", self:GetValue(), Config:GetSelectedBar(), true)
        end)

        ------------------------------------------------------------

        local completedObjectives = AceGUI:Create("CheckBox")
        completedObjectives:SetRelativeWidth(1/3)
        completedObjectives:SetValue(charDB.alerts.completedObjectives)
        completedObjectives:SetLabel(L["Completed Objectives"])
        completedObjectives:SetDisabled(true) -- ! temporary until implemented
        alertsGroup:AddChild(completedObjectives)

        completedObjectives:SetCallback("OnValueChanged", function(self)
            addon:SetBarDBInfo("alerts.completedObjectives", self:GetValue(), Config:GetSelectedBar(), true)
        end)

        --*------------------------------------------------------------------------

        local visibilityGroup = AceGUI:Create("InlineGroup")
        visibilityGroup:SetFullWidth(true)
        visibilityGroup:SetTitle(L["Visibility"])
        visibilityGroup:SetLayout("Flow")
        tabContent:AddChild(visibilityGroup)

        ------------------------------------------------------------

        local hidden = AceGUI:Create("CheckBox")
        hidden:SetRelativeWidth(1/2)
        hidden:SetValue(barDB.hidden)
        hidden:SetLabel(L["Hidden"])
        visibilityGroup:AddChild(hidden)

        hidden:SetCallback("OnValueChanged", function(self)
            addon:SetBarDBInfo("hidden", self:GetValue(), Config:GetSelectedBar())
            bar:SetHidden()
        end)

        ------------------------------------------------------------

        local showEmpty = AceGUI:Create("CheckBox")
        showEmpty:SetRelativeWidth(1/2)
        showEmpty:SetValue(barDB.showEmpty)
        showEmpty:SetLabel(L["Show Empty Buttons"])
        showEmpty:SetDisabled(true) -- ! temporary until implemented
        visibilityGroup:AddChild(showEmpty)

        showEmpty:SetCallback("OnValueChanged", function(self)
            addon:SetBarDBInfo("showEmpty", self:GetValue(), Config:GetSelectedBar())
        end) -- !

        ------------------------------------------------------------

        local mouseover = AceGUI:Create("CheckBox")
        mouseover:SetRelativeWidth(1/2)
        mouseover:SetValue(barDB.mouseover)
        mouseover:SetLabel(L["Show on Mouseover"])
        mouseover:SetDisabled(true) -- ! temporary until implemented
        visibilityGroup:AddChild(mouseover)

        mouseover:SetCallback("OnValueChanged", function(self)
            addon:SetBarDBInfo("mouseover", self:GetValue(), Config:GetSelectedBar())
        end) -- !

        ------------------------------------------------------------

        local anchorMouseover = AceGUI:Create("CheckBox")
        anchorMouseover:SetRelativeWidth(1/2)
        anchorMouseover:SetValue(barDB.anchorMouseover)
        anchorMouseover:SetLabel(L["Show on Anchor Mouseover"])
        anchorMouseover:SetDisabled(true) -- ! temporary until implemented
        visibilityGroup:AddChild(anchorMouseover)

        anchorMouseover:SetCallback("OnValueChanged", function(self)
            addon:SetBarDBInfo("anchorMouseover", self:GetValue(), Config:GetSelectedBar())
        end) -- !

        --*------------------------------------------------------------------------

        local pointGroup = AceGUI:Create("InlineGroup")
        pointGroup:SetFullWidth(true)
        pointGroup:SetTitle(L["Point"])
        pointGroup:SetLayout("Flow")
        tabContent:AddChild(pointGroup)

        ------------------------------------------------------------

        local growDirection = AceGUI:Create("Dropdown")
        growDirection:SetRelativeWidth(1/2)
        growDirection:SetLabel(L["Growth Direction"])
        growDirection:SetList({RIGHT = L["Right"], LEFT = L["Left"], UP = L["Up"], DOWN = L["Down"]}, {"RIGHT", "LEFT", "UP", "DOWN"})
        growDirection:SetValue(barDB.grow[1])
        pointGroup:AddChild(growDirection)

        growDirection:SetCallback("OnValueChanged", function(self, _, selected)
            FarmingBar.db.profile.bars[Config:GetSelectedBar()].grow[1] = selected
            bar:AnchorButtons()
        end)

        ------------------------------------------------------------

        local growType = AceGUI:Create("Dropdown")
        growType:SetRelativeWidth(1/2)
        growType:SetLabel(L["Growth Type"])
        growType:SetList({NORMAL = L["Normal"], REVERSE = L["Reverse"]}, {"NORMAL", "REVERSE"})
        growType:SetValue(barDB.grow[2])
        pointGroup:AddChild(growType)

        growType:SetCallback("OnValueChanged", function(self, _, selected)
            FarmingBar.db.profile.bars[Config:GetSelectedBar()].grow[2] = selected
            bar:AnchorButtons()
        end)

        ------------------------------------------------------------

        local movable = AceGUI:Create("CheckBox")
        movable:SetRelativeWidth(1/2)
        movable:SetValue(barDB.movable)
        movable:SetLabel(L["Movable"])
        pointGroup:AddChild(movable)

        movable:SetCallback("OnValueChanged", function(self)
            addon:SetBarDBInfo("movable", self:GetValue(), Config:GetSelectedBar())
            bar:SetMovable()
        end)

        --*------------------------------------------------------------------------

        local styleGroup = AceGUI:Create("InlineGroup")
        styleGroup:SetFullWidth(true)
        styleGroup:SetTitle(L["Style"])
        styleGroup:SetLayout("Flow")
        tabContent:AddChild(styleGroup)

        ------------------------------------------------------------

        local scale = AceGUI:Create("Slider")
        scale:SetRelativeWidth(1/2)
        scale:SetLabel(L["Scale"])
        scale:SetSliderValues(self.minScale, self.maxScale, .01)
        scale:SetValue(barDB.scale)
        styleGroup:AddChild(scale)

        scale:SetCallback("OnValueChanged", function(self, ...)
            addon:SetBarDBInfo("scale", self:GetValue(), Config:GetSelectedBar())
            bar:SetScale()
            self.editbox:ClearFocus()
        end)

        ------------------------------------------------------------

        local alpha = AceGUI:Create("Slider")
        alpha:SetRelativeWidth(1/2)
        alpha:SetLabel(L["Alpha"])
        alpha:SetSliderValues(0, 1, .01)
        alpha:SetValue(barDB.alpha)
        styleGroup:AddChild(alpha)

        alpha:SetCallback("OnValueChanged", function(self)
            addon:SetBarDBInfo("alpha", self:GetValue(), Config:GetSelectedBar())
            bar:SetAlpha()
            self.editbox:ClearFocus()
        end)

        --*------------------------------------------------------------------------

        local templateGroup = AceGUI:Create("InlineGroup")
        templateGroup:SetFullWidth(true)
        templateGroup:SetTitle("*"..L["Template"])
        templateGroup:SetLayout("Flow")
        tabContent:AddChild(templateGroup)

        ------------------------------------------------------------

        local saveAsTemplate = AceGUI:Create("EditBox")
        saveAsTemplate:SetFullWidth(true)
        saveAsTemplate:SetLabel(L["Save as Template"])
        templateGroup:AddChild(saveAsTemplate)

        saveAsTemplate:SetCallback("OnEnterPressed", function(self)
            addon:SaveTemplate(barID, self:GetText())
            self:ClearFocus()
            self:SetText()
            Config:GetUserData("loadUserTemplate"):SetDisabled(false)
            Config:GetUserData("loadUserTemplate"):SetList(GetUserTemplates())
            LibStub("AceConfigRegistry-3.0"):NotifyChange(addonName)
        end)

        ------------------------------------------------------------

        local loadTemplate = AceGUI:Create("Dropdown")
        loadTemplate:SetRelativeWidth(1/2)
        loadTemplate:SetLabel(L["Load Template"])
        loadTemplate:SetList(GetBuiltInTemplates())
        templateGroup:AddChild(loadTemplate)
        Config:SetUserData("loadTemplate", loadTemplate)

        loadTemplate:SetCallback("OnValueChanged", function(self, _, selected)
            addon:LoadTemplate(nil, barID, selected)
            self:SetValue()
        end)

        ------------------------------------------------------------

        local loadUserTemplate = AceGUI:Create("Dropdown")
        loadUserTemplate:SetRelativeWidth(1/2)
        loadUserTemplate:SetLabel(L["Load User Template"])
        loadUserTemplate:SetList(GetUserTemplates())
        loadUserTemplate:SetDisabled(self.tcount(FarmingBar.db.global.templates) == 0)
        templateGroup:AddChild(loadUserTemplate)
        Config:SetUserData("loadUserTemplate", loadUserTemplate)

        loadUserTemplate:SetCallback("OnValueChanged", function(self, _, selected)
            if FarmingBar.db.global.settings.preserveTemplateData == "PROMPT" then
                local dialog = StaticPopup_Show("FARMINGBAR_INCLUDE_TEMPLATE_DATA", selected)
                if dialog then
                    dialog.data = {barID, selected}
                end
            else
                if FarmingBar.db.global.settings.preserveTemplateOrder == "PROMPT" then
                    local dialog = StaticPopup_Show("FARMINGBAR_SAVE_TEMPLATE_ORDER", selected)
                    if dialog then
                        dialog.data = {barID, selected, FarmingBar.db.global.settings.preserveTemplateData == "ENABLED"}
                    end
                else
                    addon:LoadTemplate("user", barID, selected, FarmingBar.db.global.settings.preserveTemplateData == "ENABLED", FarmingBar.db.global.settings.preserveTemplateOrder == "ENABLED")
                end
            end
            self:SetValue()
        end)

        --*------------------------------------------------------------------------

        local charSpecific = AceGUI:Create("Label")
        charSpecific:SetFullWidth(true)
        charSpecific:SetText(L.Config_bar_charSpecific)
        tabContent:AddChild(charSpecific)
    end

    tabContent:DoLayout()
end

------------------------------------------------------------

function addon:Config_LoadButtonTab(tabContent)
    local barID = Config:GetSelectedBar()
    local bar = barID > 0 and self.bars[barID]
    local barDB = barID > 0 and FarmingBar.db.profile.bars[barID]

    if barID == 0 then
    elseif barID then
        local buttonGroup = AceGUI:Create("InlineGroup")
        buttonGroup:SetFullWidth(true)
        buttonGroup:SetTitle(L["Buttons"])
        buttonGroup:SetLayout("Flow")
        tabContent:AddChild(buttonGroup)

        ------------------------------------------------------------

        local numVisibleButtons = AceGUI:Create("Slider")
        numVisibleButtons:SetRelativeWidth(1/2)
        numVisibleButtons:SetLabel(L["Number of Buttons"])
        numVisibleButtons:SetSliderValues(0, self.maxButtons, 1)
        numVisibleButtons:SetValue(barDB.numVisibleButtons)
        buttonGroup:AddChild(numVisibleButtons)

        numVisibleButtons:SetCallback("OnValueChanged", numVisibleButtons_OnValueChanged)

        ------------------------------------------------------------

        local buttonWrap = AceGUI:Create("Slider")
        buttonWrap:SetRelativeWidth(1/2)
        buttonWrap:SetLabel(L["Buttons Per Wrap"])
        buttonWrap:SetSliderValues(1, self.maxButtons, 1)
        buttonWrap:SetValue(barDB.buttonWrap)
        buttonGroup:AddChild(buttonWrap)

        buttonWrap:SetCallback("OnValueChanged", buttonWrap_OnValueChanged)

        --*------------------------------------------------------------------------

        local styleGroup = AceGUI:Create("InlineGroup")
        styleGroup:SetFullWidth(true)
        styleGroup:SetTitle(L["Style"])
        styleGroup:SetLayout("Flow")
        tabContent:AddChild(styleGroup)

        ------------------------------------------------------------

        local size = AceGUI:Create("Slider")
        size:SetRelativeWidth(1/2)
        size:SetLabel(L["Size"])
        size:SetSliderValues(self.minButtonSize, self.maxButtonSize, 1)
        size:SetValue(barDB.button.size)
        styleGroup:AddChild(size)

        size:SetCallback("OnValueChanged", size_OnValueChanged)

        ------------------------------------------------------------

        local padding = AceGUI:Create("Slider")
        padding:SetRelativeWidth(1/2)
        padding:SetLabel(L["Padding"])
        padding:SetSliderValues(self.minButtonPadding, self.maxButtonPadding, 1)
        padding:SetValue(barDB.button.padding)
        styleGroup:AddChild(padding)

        padding:SetCallback("OnValueChanged", padding_OnValueChanged)

        ------------------------------------------------------------

        local countText = AceGUI:Create("Heading")
        countText:SetFullWidth(true)
        countText:SetText(L["Count Fontstring"])
        styleGroup:AddChild(countText)

        ------------------------------------------------------------

        local countAnchor = AceGUI:Create("Dropdown")
        countAnchor:SetFullWidth(true)
        countAnchor:SetLabel(L["Anchor"])
        countAnchor:SetList(anchors, anchorSort)
        countAnchor:SetValue(barDB.button.fontStrings.count.anchor)
        styleGroup:AddChild(countAnchor)

        countAnchor:SetCallback("OnValueChanged", countAnchor_OnValueChanged)

        ------------------------------------------------------------

        local countXOffset = AceGUI:Create("Slider")
        countXOffset:SetRelativeWidth(1/2)
        countXOffset:SetLabel(L["X Offset"])
        countXOffset:SetSliderValues(-self.OffsetX, self.OffsetX, 1)
        countXOffset:SetValue(barDB.button.fontStrings.count.xOffset)
        styleGroup:AddChild(countXOffset)

        countXOffset:SetCallback("OnValueChanged", countXOffset_OnValueChanged)

        ------------------------------------------------------------

        local countYOffset = AceGUI:Create("Slider")
        countYOffset:SetRelativeWidth(1/2)
        countYOffset:SetLabel(L["Y Offset"])
        countYOffset:SetSliderValues(-self.OffsetY, self.OffsetY, 1)
        countYOffset:SetValue(barDB.button.fontStrings.count.yOffset)
        styleGroup:AddChild(countYOffset)

        countYOffset:SetCallback("OnValueChanged", countYOffset_OnValueChanged)

        ------------------------------------------------------------

        local objectiveText = AceGUI:Create("Heading")
        objectiveText:SetFullWidth(true)
        objectiveText:SetText(L["Objective Fontstring"])
        styleGroup:AddChild(objectiveText)

        ------------------------------------------------------------

        local objectiveAnchor = AceGUI:Create("Dropdown")
        objectiveAnchor:SetFullWidth(true)
        objectiveAnchor:SetLabel(L["Anchor"])
        objectiveAnchor:SetList(anchors, anchorSort)
        objectiveAnchor:SetValue(barDB.button.fontStrings.objective.anchor)
        styleGroup:AddChild(objectiveAnchor)

        objectiveAnchor:SetCallback("OnValueChanged", objectiveAnchor_OnValueChanged)

        ------------------------------------------------------------

        local objectiveXOffset = AceGUI:Create("Slider")
        objectiveXOffset:SetRelativeWidth(1/2)
        objectiveXOffset:SetLabel(L["X Offset"])
        objectiveXOffset:SetSliderValues(-self.OffsetX, self.OffsetX, 1)
        objectiveXOffset:SetValue(barDB.button.fontStrings.objective.xOffset)
        styleGroup:AddChild(objectiveXOffset)

        objectiveXOffset:SetCallback("OnValueChanged", objectiveXOffset_OnValueChanged)

        ------------------------------------------------------------

        local objectiveYOffset = AceGUI:Create("Slider")
        objectiveYOffset:SetRelativeWidth(1/2)
        objectiveYOffset:SetLabel(L["Y Offset"])
        objectiveYOffset:SetSliderValues(-self.OffsetY, self.OffsetY, 1)
        objectiveYOffset:SetValue(barDB.button.fontStrings.objective.yOffset)
        styleGroup:AddChild(objectiveYOffset)

        objectiveYOffset:SetCallback("OnValueChanged", objectiveYOffset_OnValueChanged)

        --*------------------------------------------------------------------------

        local operationsGroup = AceGUI:Create("InlineGroup")
        operationsGroup:SetFullWidth(true)
        operationsGroup:SetTitle(L["Operations"])
        operationsGroup:SetLayout("Flow")
        tabContent:AddChild(operationsGroup)

        ------------------------------------------------------------

        local clearButtons = AceGUI:Create("Button")
        clearButtons:SetRelativeWidth(1/3)
        clearButtons:SetText("*"..L["Clear Buttons"])
        operationsGroup:AddChild(clearButtons)

        clearButtons:SetCallback("OnClick", function() addon:ClearBar(barID) end)

        ------------------------------------------------------------

        local reindexButtons = AceGUI:Create("Button")
        reindexButtons:SetRelativeWidth(1/3)
        reindexButtons:SetText("*"..L["Reindex Buttons"])
        operationsGroup:AddChild(reindexButtons)

        reindexButtons:SetCallback("OnClick", function() addon:ReindexButtons(barID) end)

        ------------------------------------------------------------

        local sizeBarToButtons = AceGUI:Create("Button")
        sizeBarToButtons:SetRelativeWidth(1/3)
        sizeBarToButtons:SetText("**"..L["Size Bar to Buttons"])
        operationsGroup:AddChild(sizeBarToButtons)

        sizeBarToButtons:SetCallback("OnClick",function() addon:SizeBarToButtons(barID) end)

        --*------------------------------------------------------------------------

        local charSpecific = AceGUI:Create("Label")
        charSpecific:SetFullWidth(true)
        charSpecific:SetText(L.Config_bar_charSpecific)
        tabContent:AddChild(charSpecific)

        ------------------------------------------------------------

        local mixedSpecific = AceGUI:Create("Label")
        mixedSpecific:SetFullWidth(true)
        mixedSpecific:SetText(L.Config_bar_mixedSpecific)
        tabContent:AddChild(mixedSpecific)
    end

    tabContent:DoLayout()
end