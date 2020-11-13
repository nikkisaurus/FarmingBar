local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

local pairs = pairs
local abs = math.abs
local Config = addon.Config

--*------------------------------------------------------------------------

local function GetBarList()
    local list = {}
    for k, v in pairs(addon.bars) do
        list[k] = L["Bar"].." "..k
    end

    return list
end

--*------------------------------------------------------------------------

local function removeBar_OnValueChanged(self, _, selected)
    -- print(selected)
end

--*------------------------------------------------------------------------

local methods = {
    Load = function(self, barID)
        Config.frame:Show()
        Config:RefreshBars()
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
    mainPanel:SetLayout("Fill")
    Config:AddChild(mainPanel)

    ------------------------------------------------------------

    local mainContent = AceGUI:Create("ScrollFrame")
    mainContent:SetLayout("FB30_List")
    mainContent:SetUserData("childPadding", 10)
    mainPanel:AddChild(mainContent)

    ------------------------------------------------------------

    Config:LoadBars()
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

function addon:Config_LoadAllBars()
    -- print("all")
end

------------------------------------------------------------

function addon:Config_LoadBar(barID)
    -- print(barID)
end


    -- ------------------------------------------------------------

    -- local addBar = AceGUI:Create("Button")
    -- addBar:SetText(L["Add Bar"])
    -- -- addBar:SetTextHighlight(1, .82, 0, 1)
    -- -- addBar:SetWordWrap(false)
    -- -- addBar:SetIcon(514607, nil, 13, 13)
    -- topPanel:AddChild(addBar)

    -- addBar:SetCallback("OnClick", function() self:CreateBar() end)

    -- ------------------------------------------------------------

    -- local removeBar = AceGUI:Create("Dropdown")
    -- removeBar:SetWidth(200)
    -- removeBar:SetLabel(L["Remove Bar"])
    -- removeBar:SetList(GetBarList())
    -- topPanel:AddChild(removeBar)

    -- removeBar:SetCallback("OnValueChanged", removeBar_OnValueChanged)
