local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

local pairs = pairs
local abs = math.abs
local Config = addon.Config

--*------------------------------------------------------------------------

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

--*------------------------------------------------------------------------

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

local function removeBar_OnValueChanged(self, _, selected)
    -- print(selected)
end

------------------------------------------------------------

local function title_OnEnterPressed(self)
    addon:SetBarDBInfo("title", self:GetText(), Config:GetSelectedBar())
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
    local barDB = barID > 0 and FarmingBar.db.char.bars[barID]

    if barID == 0 then
        local addBar = AceGUI:Create("Button")
        addBar:SetFullWidth(true)
        addBar:SetText(L["Add Bar"])
        tabContent:AddChild(addBar)

        addBar:SetCallback("OnClick", function() self:CreateBar() end)
    elseif barDB then
        local title = AceGUI:Create("EditBox")
        title:SetFullWidth(true)
        title:SetText(barDB.title)
        title:SetLabel(L["Title"])
        tabContent:AddChild(title)

        title:SetCallback("OnEnterPressed", title_OnEnterPressed)

        --*------------------------------------------------------------------------

        local alertsGroup = AceGUI:Create("InlineGroup")
        alertsGroup:SetFullWidth(true)
        alertsGroup:SetTitle(L["Alerts"])
        alertsGroup:SetLayout("Flow")
        tabContent:AddChild(alertsGroup)

        ------------------------------------------------------------

        local muteAll = AceGUI:Create("CheckBox")
        muteAll:SetRelativeWidth(1/3)
        muteAll:SetValue(barDB.alerts.muteAll)
        muteAll:SetLabel(L["Mute All"])
        alertsGroup:AddChild(muteAll)

        muteAll:SetCallback("OnValueChanged", function(self)
            addon:SetBarDBInfo("alerts.muteAll", self:GetValue(), Config:GetSelectedBar())
        end)

        ------------------------------------------------------------

        local barProgress = AceGUI:Create("CheckBox")
        barProgress:SetRelativeWidth(1/3)
        barProgress:SetValue(barDB.alerts.barProgress)
        barProgress:SetLabel(L["Bar Progress"])
        barProgress:SetDisabled(true) -- ! temporary until implemented
        alertsGroup:AddChild(barProgress)

        barProgress:SetCallback("OnValueChanged", function(self)
            addon:SetBarDBInfo("alerts.barProgress", self:GetValue(), Config:GetSelectedBar())
        end)

        ------------------------------------------------------------

        local completedObjectives = AceGUI:Create("CheckBox")
        completedObjectives:SetRelativeWidth(1/3)
        completedObjectives:SetValue(barDB.alerts.completedObjectives)
        completedObjectives:SetLabel(L["Completed Objectives"])
        completedObjectives:SetDisabled(true) -- ! temporary until implemented
        alertsGroup:AddChild(completedObjectives)

        completedObjectives:SetCallback("OnValueChanged", function(self)
            addon:SetBarDBInfo("alerts.completedObjectives", self:GetValue(), Config:GetSelectedBar())
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
            bar:SetHidden(barDB.hidden)
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
            FarmingBar.db.char.bars[Config:GetSelectedBar()].grow[1] = selected
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
            FarmingBar.db.char.bars[Config:GetSelectedBar()].grow[2] = selected
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
            bar:SetMovable(barDB.movable)
        end)

        --*------------------------------------------------------------------------

        local styleGroup = AceGUI:Create("InlineGroup")
        styleGroup:SetFullWidth(true)
        styleGroup:SetTitle(L["Style"])
        styleGroup:SetLayout("Flow")
        tabContent:AddChild(styleGroup)

        ------------------------------------------------------------

        local fontFace = AceGUI:Create("LSM30_Font")
        fontFace:SetRelativeWidth(1/2)
        fontFace:SetLabel(L["Font Face"])
        fontFace:SetList(AceGUIWidgetLSMlists.font)
        fontFace:SetValue(barDB.font.face or FarmingBar.db.profile.style.font.face)
        fontFace:SetDisabled(true) -- ! temporary until implemented
        styleGroup:AddChild(fontFace)

        fontFace:SetCallback("OnValueChanged", function(self, _, selected)
            addon:SetBarDBInfo("font.face", selected, Config:GetSelectedBar())
            self:SetValue(selected)
        end)

        ------------------------------------------------------------

        local fontOutline = AceGUI:Create("Dropdown")
        fontOutline:SetRelativeWidth(1/2)
        fontOutline:SetLabel(L["Font Outline"])
        fontOutline:SetList({MONOCHROME = L["Monochrome"], OUTLINE = L["Outline"], THICKOUTLINE = L["Thickoutline"], NONE = L["None"]}, {"MONOCHROME", "OUTLINE", "THICKOUTLINE", "NONE"})
        fontOutline:SetValue(barDB.font.outline or FarmingBar.db.profile.style.font.outline)
        fontOutline:SetDisabled(true) -- ! temporary until implemented
        styleGroup:AddChild(fontOutline)

        fontOutline:SetCallback("OnValueChanged", function(self, _, selected)
            addon:SetBarDBInfo("font.outline", selected, Config:GetSelectedBar())
        end)

        ------------------------------------------------------------

        local fontSize = AceGUI:Create("Slider")
        fontSize:SetRelativeWidth(1/3)
        fontSize:SetLabel(L["Font Size"])
        fontSize:SetSliderValues(self.minFontSize, self.maxFontSize, 1)
        fontSize:SetValue(barDB.font.size or FarmingBar.db.profile.style.font.size)
        fontSize:SetDisabled(true) -- ! temporary until implemented
        styleGroup:AddChild(fontSize)

        fontSize:SetCallback("OnValueChanged", function(self)
            addon:SetBarDBInfo("font.size", self:GetValue(), Config:GetSelectedBar())
        end)

        ------------------------------------------------------------

        local scale = AceGUI:Create("Slider")
        scale:SetRelativeWidth(1/3)
        scale:SetLabel(L["Scale"])
        scale:SetSliderValues(self.minScale, self.maxScale)
        scale:SetValue(barDB.scale)
        styleGroup:AddChild(scale)

        scale:SetCallback("OnValueChanged", function(self, ...)
            addon:SetBarDBInfo("scale", self:GetValue(), Config:GetSelectedBar())
            bar:SetScale(barDB.scale)
        end)

        ------------------------------------------------------------

        local alpha = AceGUI:Create("Slider")
        alpha:SetRelativeWidth(1/3)
        alpha:SetLabel(L["Alpha"])
        alpha:SetSliderValues(0, 1)
        alpha:SetValue(barDB.alpha)
        styleGroup:AddChild(alpha)

        alpha:SetCallback("OnValueChanged", function(self)
            addon:SetBarDBInfo("alpha", self:GetValue(), Config:GetSelectedBar())
            bar:SetAlpha(barDB.alpha)
        end)

        --*------------------------------------------------------------------------

        local templateGroup = AceGUI:Create("InlineGroup")
        templateGroup:SetFullWidth(true)
        templateGroup:SetTitle(L["Template"])
        templateGroup:SetLayout("Flow")
        tabContent:AddChild(templateGroup)

        ------------------------------------------------------------

        local saveAsTemplate = AceGUI:Create("EditBox")
        saveAsTemplate:SetFullWidth(true)
        saveAsTemplate:SetLabel(L["Save as Template"])
        saveAsTemplate:SetDisabled(true) -- ! temporary until implemented
        templateGroup:AddChild(saveAsTemplate)

        saveAsTemplate:SetCallback("OnEnterPressed", function(self)
            print("Save as template", self:GetText())
            self:ClearFocus()
            self:SetText()
        end)

        ------------------------------------------------------------

        local loadTemplate = AceGUI:Create("Dropdown")
        loadTemplate:SetRelativeWidth(1/2)
        loadTemplate:SetLabel(L["Load Template"])
        -- loadTemplate:SetList({}, {})
        loadTemplate:SetDisabled(true) -- ! temporary until implemented
        templateGroup:AddChild(loadTemplate)
        Config:SetUserData("loadTemplate", loadTemplate)

        loadTemplate:SetCallback("OnValueChanged", function(self, _, selected)
        end)

        ------------------------------------------------------------

        local loadUserTemplate = AceGUI:Create("Dropdown")
        loadUserTemplate:SetRelativeWidth(1/2)
        loadUserTemplate:SetLabel(L["Load User Template"])
        -- loadUserTemplate:SetList({}, {})
        loadUserTemplate:SetDisabled(true) -- ! temporary until implemented
        templateGroup:AddChild(loadUserTemplate)
        Config:SetUserData("loadUserTemplate", loadUserTemplate)

        loadUserTemplate:SetCallback("OnValueChanged", function(self, _, selected)
        end)
    end

    tabContent:DoLayout()
end

------------------------------------------------------------

function addon:Config_LoadButtonTab(tabContent)
    local barID = Config:GetSelectedBar()
    local bar = barID > 0 and self.bars[barID]
    local barDB = barID > 0 and FarmingBar.db.char.bars[barID]

    if barID == 0 then
    elseif barID then
        local operationsGroup = AceGUI:Create("InlineGroup")
        operationsGroup:SetFullWidth(true)
        operationsGroup:SetTitle(L["Operations"])
        operationsGroup:SetLayout("Flow")
        tabContent:AddChild(operationsGroup)

        ------------------------------------------------------------

        local clearButtons = AceGUI:Create("Button")
        clearButtons:SetRelativeWidth(1/3)
        clearButtons:SetText(L["Clear Buttons"])
        clearButtons:SetDisabled(true) -- ! temporary until implemented
        operationsGroup:AddChild(clearButtons)

        clearButtons:SetCallback("OnClick", function() print("Clear buttons") end)

        ------------------------------------------------------------

        local reindexButtons = AceGUI:Create("Button")
        reindexButtons:SetRelativeWidth(1/3)
        reindexButtons:SetText(L["Reindex Buttons"])
        reindexButtons:SetDisabled(true) -- ! temporary until implemented
        operationsGroup:AddChild(reindexButtons)

        reindexButtons:SetCallback("OnClick", function() print("Reindex buttons") end)

        ------------------------------------------------------------

        local sizeBarToButtons = AceGUI:Create("Button")
        sizeBarToButtons:SetRelativeWidth(1/3)
        sizeBarToButtons:SetText(L["Size Bar to Buttons"])
        sizeBarToButtons:SetDisabled(true) -- ! temporary until implemented
        operationsGroup:AddChild(sizeBarToButtons)

        sizeBarToButtons:SetCallback("OnClick", function() print("Size bar to buttons") end)

        --*------------------------------------------------------------------------

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

        numVisibleButtons:SetCallback("OnValueChanged", function(self)
            addon:SetBarDBInfo("numVisibleButtons", self:GetValue(), Config:GetSelectedBar()) --! needs fixed to update buttons as added/removed
            bar:AnchorButtons()
        end)

        ------------------------------------------------------------

        local buttonWrap = AceGUI:Create("Slider")
        buttonWrap:SetRelativeWidth(1/2)
        buttonWrap:SetLabel(L["Buttons Per Wrap"])
        buttonWrap:SetSliderValues(1, self.maxButtons, 1)
        buttonWrap:SetValue(barDB.buttonWrap)
        buttonGroup:AddChild(buttonWrap)

        buttonWrap:SetCallback("OnValueChanged", function(self)
            addon:SetBarDBInfo("buttonWrap", self:GetValue(), Config:GetSelectedBar()) --! needs fixed for when 1 button per
            bar:AnchorButtons()
        end)

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

        size:SetCallback("OnValueChanged", function(self)
            addon:SetBarDBInfo("button.size", self:GetValue(), Config:GetSelectedBar())
            bar:SetSize(barDB.button.size)
        end)

        ------------------------------------------------------------

        local padding = AceGUI:Create("Slider")
        padding:SetRelativeWidth(1/2)
        padding:SetLabel(L["Padding"])
        padding:SetSliderValues(self.minButtonPadding, self.maxButtonPadding, 1)
        padding:SetValue(barDB.button.padding)
        styleGroup:AddChild(padding)

        padding:SetCallback("OnValueChanged", function(self)
            addon:SetBarDBInfo("button.padding", self:GetValue(), Config:GetSelectedBar())
            bar:SetSize(barDB.button.size)
            bar:AnchorButtons()
        end)

        ------------------------------------------------------------

        local countText = AceGUI:Create("Heading")
        countText:SetFullWidth(true)
        countText:SetText(L["Count Text"])
        styleGroup:AddChild(countText)

        ------------------------------------------------------------

        local countAnchor = AceGUI:Create("Dropdown")
        countAnchor:SetFullWidth(true)
        countAnchor:SetLabel(L["Anchor"])
        countAnchor:SetList(
            {
                TOPLEFT = L["Topleft"],
                TOP = L["Top"],
                TOPRIGHT = L["Topright"],
                LEFT = L["Left"],
                CENTER = L["Center"],
                RIGHT = L["Right"],
                BOTTOMLEFT = L["Bottomleft"],
                BOTTOM = L["Bottom"],
                BOTTOMRIGHT = L["Bottomright"],
            },
            {"TOPLEFT", "TOP", "TOPRIGHT", "LEFT", "CENTER", "RIGHT", "BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT"}
        )
        countAnchor:SetValue(barDB.button.fontStrings.count.anchor)
        countAnchor:SetDisabled(true) -- ! temporary until implemented
        styleGroup:AddChild(countAnchor)

        countAnchor:SetCallback("OnValueChanged", function(self, _, selected)
            addon:SetBarDBInfo("button.fontStrings.count.anchor", selected, Config:GetSelectedBar())
        end)

        ------------------------------------------------------------

        local countXOffset = AceGUI:Create("Slider")
        countXOffset:SetRelativeWidth(1/2)
        countXOffset:SetLabel(L["X Offset"])
        countXOffset:SetSliderValues(-self.OffsetX, self.OffsetX, 1)
        countXOffset:SetValue(barDB.button.fontStrings.count.xOffset)
        countXOffset:SetDisabled(true) -- ! temporary until implemented
        styleGroup:AddChild(countXOffset)

        countXOffset:SetCallback("OnValueChanged", function(self)
            addon:SetBarDBInfo("button.fontStrings.count.xOffset", self:GetValue(), Config:GetSelectedBar())
        end)

        ------------------------------------------------------------

        local countYOffset = AceGUI:Create("Slider")
        countYOffset:SetRelativeWidth(1/2)
        countYOffset:SetLabel(L["Y Offset"])
        countYOffset:SetSliderValues(-self.OffsetY, self.OffsetY, 1)
        countYOffset:SetValue(barDB.button.fontStrings.count.yOffset)
        countYOffset:SetDisabled(true) -- ! temporary until implemented
        styleGroup:AddChild(countYOffset)

        countYOffset:SetCallback("OnValueChanged", function(self)
            addon:SetBarDBInfo("button.fontStrings.count.yOffset", self:GetValue(), Config:GetSelectedBar())
        end)

        ------------------------------------------------------------

        local objectiveText = AceGUI:Create("Heading")
        objectiveText:SetFullWidth(true)
        objectiveText:SetText(L["Objective Text"])
        styleGroup:AddChild(objectiveText)

        ------------------------------------------------------------

        local objectiveAnchor = AceGUI:Create("Dropdown")
        objectiveAnchor:SetFullWidth(true)
        objectiveAnchor:SetLabel(L["Anchor"])
        objectiveAnchor:SetList(
            {
                TOPLEFT = L["Topleft"],
                TOP = L["Top"],
                TOPRIGHT = L["Topright"],
                LEFT = L["Left"],
                CENTER = L["Center"],
                RIGHT = L["Right"],
                BOTTOMLEFT = L["Bottomleft"],
                BOTTOM = L["Bottom"],
                BOTTOMRIGHT = L["Bottomright"],
            },
            {"TOPLEFT", "TOP", "TOPRIGHT", "LEFT", "CENTER", "RIGHT", "BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT"}
        )
        objectiveAnchor:SetValue(barDB.button.fontStrings.objective.anchor)
        objectiveAnchor:SetDisabled(true) -- ! temporary until implemented
        styleGroup:AddChild(objectiveAnchor)

        objectiveAnchor:SetCallback("OnValueChanged", function(self, _, selected)
            addon:SetBarDBInfo("button.fontStrings.objective.anchor", selected, Config:GetSelectedBar())
        end)

        ------------------------------------------------------------

        local objectiveXOffset = AceGUI:Create("Slider")
        objectiveXOffset:SetRelativeWidth(1/2)
        objectiveXOffset:SetLabel(L["X Offset"])
        objectiveXOffset:SetSliderValues(-self.OffsetX, self.OffsetX, 1)
        objectiveXOffset:SetValue(barDB.button.fontStrings.objective.xOffset)
        objectiveXOffset:SetDisabled(true) -- ! temporary until implemented
        styleGroup:AddChild(objectiveXOffset)

        objectiveXOffset:SetCallback("OnValueChanged", function(self)
            addon:SetBarDBInfo("button.fontStrings.objective.xOffset", self:GetValue(), Config:GetSelectedBar())
        end)

        ------------------------------------------------------------

        local objectiveYOffset = AceGUI:Create("Slider")
        objectiveYOffset:SetRelativeWidth(1/2)
        objectiveYOffset:SetLabel(L["Y Offset"])
        objectiveYOffset:SetSliderValues(-self.OffsetY, self.OffsetY, 1)
        objectiveYOffset:SetValue(barDB.button.fontStrings.objective.yOffset)
        objectiveYOffset:SetDisabled(true) -- ! temporary until implemented
        styleGroup:AddChild(objectiveYOffset)

        objectiveYOffset:SetCallback("OnValueChanged", function(self)
            addon:SetBarDBInfo("button.fontStrings.objective.yOffset", self:GetValue(), Config:GetSelectedBar())
        end)
    end

    tabContent:DoLayout()
end