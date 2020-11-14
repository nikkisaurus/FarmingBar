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
            mainTabGroup:SelectTab(self:GetSelectedTab(barID) or "barTab")
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
            local barID = Config:GetSelectedBar()
            FarmingBar.db.char.bars[barID].grow[1] = selected
            addon.bars[barID]:DoLayout()
            Config:RefreshBars()
        end)

        ------------------------------------------------------------

        local growType = AceGUI:Create("Dropdown")
        growType:SetRelativeWidth(1/2)
        growType:SetLabel(L["Growth Type"])
        growType:SetList({NORMAL = L["Normal"], REVERSE = L["Reverse"]}, {"NORMAL", "REVERSE"})
        growType:SetValue(barDB.grow[2])
        pointGroup:AddChild(growType)

        growType:SetCallback("OnValueChanged", function(self, _, selected)
            local barID = Config:GetSelectedBar()
            FarmingBar.db.char.bars[barID].grow[2] = selected
            addon.bars[barID]:DoLayout()
            Config:RefreshBars()
        end)

        ------------------------------------------------------------

        local movable = AceGUI:Create("CheckBox")
        movable:SetRelativeWidth(1/2)
        movable:SetValue(barDB.movable)
        movable:SetLabel(L["Movable"])
        pointGroup:AddChild(movable)

        movable:SetCallback("OnValueChanged", function(self)
            addon:SetBarDBInfo("movable", self:GetValue(), Config:GetSelectedBar())
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
        -- builtInTemplate:SetList({NORMAL = L["Normal"], REVERSE = L["Reverse"]}, {"NORMAL", "REVERSE"})
        loadTemplate:SetDisabled(true) -- ! temporary until implemented
        templateGroup:AddChild(loadTemplate)
        Config:SetUserData("loadTemplate", loadTemplate)

        loadTemplate:SetCallback("OnValueChanged", function(self, _, selected)
        end)

        ------------------------------------------------------------

        local loadUserTemplate = AceGUI:Create("Dropdown")
        loadUserTemplate:SetRelativeWidth(1/2)
        loadUserTemplate:SetLabel(L["Load User Template"])
        -- builtInTemplate:SetList({NORMAL = L["Normal"], REVERSE = L["Reverse"]}, {"NORMAL", "REVERSE"})
        loadUserTemplate:SetDisabled(true) -- ! temporary until implemented
        templateGroup:AddChild(loadUserTemplate)
        Config:SetUserData("loadUserTemplate", loadUserTemplate)

        loadUserTemplate:SetCallback("OnValueChanged", function(self, _, selected)
        end)

        --*------------------------------------------------------------------------

        local fontGroup = AceGUI:Create("InlineGroup")
        fontGroup:SetFullWidth(true)
        fontGroup:SetTitle(L["Font"])
        fontGroup:SetLayout("Flow")
        tabContent:AddChild(fontGroup)

        ------------------------------------------------------------

        local fontFace = AceGUI:Create("LSM30_Font")
        fontFace:SetRelativeWidth(1/2)
        fontFace:SetLabel(L["Font Face"])
        fontFace:SetList(AceGUIWidgetLSMlists.font)
        fontFace:SetValue(barDB.font.face or FarmingBar.db.profile.style.font.face)
        fontGroup:AddChild(fontFace)

        ------------------------------------------------------------

        local fontOutline = AceGUI:Create("Dropdown")
        fontOutline:SetRelativeWidth(1/2)
        fontOutline:SetLabel(L["Font Outline"])
        fontOutline:SetList({MONOCHROME = L["Monochrome"], OUTLINE = L["Outline"], THICKOUTLINE = L["Thickoutline"], NONE = L["None"]}, {"MONOCHROME", "OUTLINE", "THICKOUTLINE", "NONE"})
        fontOutline:SetValue(barDB.font.outline or FarmingBar.db.profile.style.font.outline)
        fontGroup:AddChild(fontOutline)

        ------------------------------------------------------------

        local fontSize = AceGUI:Create("Slider")
        fontSize:SetLabel(L["Font Size"])
        fontSize:SetSliderValues(self.minFontSize, self.maxFontSize, 1)
        fontSize:SetValue(barDB.font.size or FarmingBar.db.profile.style.font.size)
        fontGroup:AddChild(fontSize)
    end

    tabContent:DoLayout()
end

------------------------------------------------------------

function addon:Config_LoadButtonTab(tabContent)
end