local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)
local AceGUI = LibStub("AceGUI-3.0")

--[[ Content ]]
local function GetGeneralContent(objectiveTitle, content)
    local objectiveInfo = private.db.global.objectives[objectiveTitle]

    local icon = AceGUI:Create("Icon")
    icon:SetImageSize(25, 25)
    icon:SetWidth(45)

    icon:SetUserData("NotifyChange", function()
        icon:SetImage(private:GetObjectiveIcon(objectiveInfo))
    end)


    local title = AceGUI:Create("EditBox")
    title:SetRelativeWidth(2 / 3)
    title:SetLabel(L["Objective Title"])

    title:SetCallback("OnEnterPressed", function(_, _, value)
        if private:ObjectiveTemplateExists(value) then
            private.options:SetStatusText(L["Objective template exists."])
        else
            private:RenameObjectiveTemplate(objectiveTitle, value)
            local treeGroup = private.options:GetUserData("menu")
            private:UpdateMenu(treeGroup)
            treeGroup:SelectByPath("Objectives", value)
        end
    end)
    title:SetUserData("NotifyChange", function()
        title:SetText(objectiveTitle)
    end)

    local iconType = AceGUI:Create("Dropdown")
    iconType:SetList(
        {
            AUTO = L["Auto"],
            FALLBACK = L["Fallback"],
        }
    )
    iconType:SetLabel(L["Icon Type"])

    iconType:SetCallback("OnValueChanged", function(_, _, value)
        private.db.global.objectives[objectiveTitle].icon.type = value
        private:NotifyChange(content)
    end)
    iconType:SetUserData("NotifyChange", function()
        iconType:SetValue(objectiveInfo.icon.type)

    end)

    local iconID = AceGUI:Create("EditBox")
    iconID:SetLabel(L["Fallback Icon"])

    iconID:SetCallback("OnEnterPressed", function(_, _, value)
        private.db.global.objectives[objectiveTitle].icon.id = tonumber(value) or 134400
        private:NotifyChange(content)
    end)
    iconID:SetUserData("NotifyChange", function()
        iconID:SetText(objectiveInfo.icon.id)
    end)

    local onUseType = AceGUI:Create("Dropdown")
    onUseType:SetList(
        {
            ITEM = L["Item"],
            MACROTEXT = L["Macrotext"],
            NONE = L["None"],
        }
    )
    onUseType:SetLabel(L["OnUse Type"])

    onUseType:SetCallback("OnValueChanged", function(_, _, value)
        private.db.global.objectives[objectiveTitle].onUse.type = value
        private:NotifyChange(content)
    end)
    onUseType:SetUserData("NotifyChange", function()
        onUseType:SetValue(objectiveInfo.onUse.type)
    end)

    local onUseAction = AceGUI:Create("MultiLineEditBox")
    onUseAction:SetFullWidth(true)
    onUseAction:SetLabel(L["OnUse Action"])

    onUseAction:SetCallback("OnEnterPressed", function(_, _, value)
        private.db.global.objectives[objectiveTitle].onUse.action = value
        private:NotifyChange(content)
    end)
    onUseAction:SetUserData("NotifyChange", function()
        onUseAction:SetText(objectiveInfo.onUse.action)
    end)


    private:AddChildren(content, icon, title, iconType, iconID, onUseType, onUseAction)
    private:NotifyChange(content)
end

local function GetTrackerContent()

end

local function GetManageContent(objectiveTitle, content)

end

--[[ Callbacks ]]
local function tabGroup_OnGroupSelected(tabGroup, _, group)
    local objectiveTitle = tabGroup:GetUserData("objectiveTitle")
    local content = tabGroup:GetUserData("scrollContent")


    content:ReleaseChildren()

    if group == "general" then
        GetGeneralContent(objectiveTitle, content)
        private:NotifyChange(content)
    elseif group == "trackers" then
        GetTrackerContent(objectiveTitle, content)
        private:NotifyChange(content)
    elseif group == "manage" then
        GetManageContent(objectiveTitle, content)
    end
end

--[[ Options ]]
function private:GetObjectivesOptions(treeGroup, subgroup)
    if subgroup then
        treeGroup:SetLayout("Fill")

        local tabGroup = AceGUI:Create("TabGroup")
        tabGroup:SetLayout("Fill")
        tabGroup:SetTabs({
            { value = "general", text = L["General"] },
            { value = "trackers", text = L["Trackers"] },
            { value = "manage", text = L["Manage"] },
        })
        tabGroup:SetUserData("objectiveTitle", subgroup)
        tabGroup:SetCallback("OnGroupSelected", tabGroup_OnGroupSelected)

        local scrollContainer = AceGUI:Create("SimpleGroup")
        scrollContainer:SetFullWidth(true)
        scrollContainer:SetLayout("Fill")
        tabGroup:AddChild(scrollContainer)

        local scrollContent = AceGUI:Create("ScrollFrame")
        scrollContent:SetLayout("Flow")
        scrollContainer:AddChild(scrollContent)
        tabGroup:SetUserData("scrollContent", scrollContent)

        private:AddChildren(treeGroup, tabGroup)
        tabGroup:SelectTab("general")
    end
end
