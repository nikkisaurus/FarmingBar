local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)
local AceGUI = LibStub("AceGUI-3.0")
local LibSerialize = LibStub("LibSerialize")
local LibDeflate = LibStub("LibDeflate")

--[[ Lists ]]
local lists = {
    deleteObjective = function()
        local objectives = {}

        for objectiveTitle, _ in addon.pairs(private.db.global.objectives) do
            objectives[objectiveTitle] = objectiveTitle
        end

        return objectives
    end,

    iconType = {
        AUTO = L["Auto"],
        FALLBACK = L["Fallback"],
    },

    onUseType = {
        ITEM = L["Item"],
        MACROTEXT = L["Macrotext"],
        NONE = L["None"],
    },
}

--[[ Content ]]
local function GetGeneralContent(objectiveTitle, content)
    local objectiveInfo = private.db.global.objectives[objectiveTitle]

    -- NotifyChange
    local NotifyChangeFuncs = {
        icon = function(self)
            self:SetImage(private:GetObjectiveIcon(objectiveInfo))
        end,

        iconID = function(self)
            self:SetText(objectiveInfo.icon.id)
        end,

        iconType = function(self)
            self:SetValue(objectiveInfo.icon.type)
        end,

        onUseAction = function(self)
            self:SetText(objectiveInfo.onUse.action)
        end,

        onUseType = function(self)
            self:SetValue(objectiveInfo.onUse.type)
        end,

        title = function(self)
            self:SetText(objectiveTitle)
        end,
    }

    -- Callbacks
    local function deleteObjective_OnClick()
        local deleteFunc = function()
            private:DeleteObjectiveTemplate(objectiveTitle)
            private:UpdateMenu(private.options:GetUserData("menu"), "Objectives")
        end

        private:ShowConfirmationDialog(
            format(L["Are you sure you want to delete the objective template \"%s\"?"], objectiveTitle),
            deleteFunc
        )
    end

    local function exportObjective_OnClick()
        local exportFrame = AceGUI:Create("Frame")
        exportFrame:SetTitle(L.addonName .. " - " .. L["Export Frame"])
        exportFrame:SetLayout("Fill")
        exportFrame:SetCallback("OnClose", function(self)
            self:Release()
        end)

        local editbox = AceGUI:Create("MultiLineEditBox")
        editbox:SetLabel(objectiveTitle)
        editbox:DisableButton(true)
        exportFrame:AddChild(editbox)

        local serialized = LibSerialize:Serialize(objectiveInfo)
        local compressed = LibDeflate:CompressDeflate(serialized)
        local encoded = LibDeflate:EncodeForPrint(compressed)

        editbox:SetText(encoded)
        editbox:SetFocus()
        editbox:HighlightText()
        exportFrame:Show()
    end

    local function duplicateObjective_OnClick()
        local newObjectiveTitle = private:DuplicateObjectiveTemplate(objectiveTitle)
        private:UpdateMenu(private.options:GetUserData("menu"), "Objectives", newObjectiveTitle)
    end

    local function iconID_OnEnterPressed(_, _, value)
        private.db.global.objectives[objectiveTitle].icon.id = tonumber(value) or 134400
        private:NotifyChange(content)
    end

    local function iconType_OnValueChanged(_, _, value)
        private.db.global.objectives[objectiveTitle].icon.type = value
        private:NotifyChange(content)
    end

    local function onUseAction_OnEnterPressed(_, _, value)
        private.db.global.objectives[objectiveTitle].onUse.action = value
        private:NotifyChange(content)
    end

    local function onUseType_OnValueChanged(_, _, value)
        private.db.global.objectives[objectiveTitle].onUse.type = value
        private:NotifyChange(content)
    end

    local function title_OnEnterPressed(_, _, value)
        if private:ObjectiveTemplateExists(value) then
            private.options:SetStatusText(L["Objective template exists."])
        else
            private:RenameObjectiveTemplate(objectiveTitle, value)
            private:UpdateMenu(private.options:GetUserData("menu"), "Objectives", value)
        end
    end

    -- Widgets
    local icon = AceGUI:Create("Icon")
    icon:SetWidth(45)
    icon:SetImageSize(25, 25)
    icon:SetUserData("NotifyChange", NotifyChangeFuncs.icon)

    local title = AceGUI:Create("EditBox")
    title:SetRelativeWidth(2 / 3)
    title:SetLabel(L["Objective Title"])
    title:SetCallback("OnEnterPressed", title_OnEnterPressed)
    title:SetUserData("NotifyChange", NotifyChangeFuncs.title)

    local iconType = AceGUI:Create("Dropdown")
    iconType:SetLabel(L["Icon Type"])
    iconType:SetList(lists.iconType)
    iconType:SetCallback("OnValueChanged", iconType_OnValueChanged)
    iconType:SetUserData("NotifyChange", NotifyChangeFuncs.iconType)

    local iconID = AceGUI:Create("EditBox")
    iconID:SetLabel(L["Fallback Icon"])
    iconID:SetCallback("OnEnterPressed", iconID_OnEnterPressed)
    iconID:SetUserData("NotifyChange", NotifyChangeFuncs.iconID)

    local onUseType = AceGUI:Create("Dropdown")
    onUseType:SetList(lists.onUseType)
    onUseType:SetLabel(L["OnUse Type"])
    onUseType:SetCallback("OnValueChanged", onUseType_OnValueChanged)
    onUseType:SetUserData("NotifyChange", NotifyChangeFuncs.onUseType)

    local onUseAction = AceGUI:Create("MultiLineEditBox")
    onUseAction:SetFullWidth(true)
    onUseAction:SetLabel(L["OnUse Action"])
    onUseAction:SetCallback("OnEnterPressed", onUseAction_OnEnterPressed)
    onUseAction:SetUserData("NotifyChange", NotifyChangeFuncs.onUseAction)

    local duplicateObjective = AceGUI:Create("Button")
    duplicateObjective:SetText(L["Duplicate"])
    duplicateObjective:SetCallback("OnClick", duplicateObjective_OnClick)

    local exportObjective = AceGUI:Create("Button")
    exportObjective:SetText(L["Export"])
    exportObjective:SetCallback("OnClick", exportObjective_OnClick)

    local deleteObjective = AceGUI:Create("Button")
    deleteObjective:SetText(L["Delete"])
    deleteObjective:SetCallback("OnClick", deleteObjective_OnClick)

    -- Add children
    private:AddChildren(
        content,
        icon,
        title,
        iconType,
        iconID,
        onUseType,
        onUseAction,
        duplicateObjective,
        exportObjective,
        deleteObjective
    )
    private:NotifyChange(content)
end

local function GetObjectiveContent(content)
    local NotifyChangeFuncs = {
        deleteObjective = function(self)
            local list = lists.deleteObjective()
            if addon.tcount(list) == 0 then
                self:SetDisabled(true)
            else
                self:SetDisabled(false)
            end
            self:SetList(list)
        end,
    }

    -- Callbacks
    local function deleteObjective_OnValueChanged(self, _, value)
        local deleteFunc = function()
            private:DeleteObjectiveTemplate(value)
            private:UpdateMenu(private.options:GetUserData("menu"))
            private:NotifyChange(content)
        end

        private:ShowConfirmationDialog(
            format(L["Are you sure you want to delete the objective template \"%s\"?"], value),
            deleteFunc
        )

        self:SetValue()
    end

    local function importObjective_OnClick()
        private:LoadImportFrame()
    end

    local function newObjective_OnClick()
        local newObjectiveTitle = private:IncrementString(L["New"], private, "ObjectiveTemplateExists")
        private.db.global.objectives[newObjectiveTitle] = addon.CloneTable(private.defaults.objective)
        private:UpdateMenu(private.options:GetUserData("menu"), "Objectives", newObjectiveTitle)
    end

    -- Widgets
    local newObjective = AceGUI:Create("Button")
    newObjective:SetText(L["New"])
    newObjective:SetCallback("OnClick", newObjective_OnClick)

    local importObjective = AceGUI:Create("Button")
    importObjective:SetText(L["Import"])
    importObjective:SetCallback("OnClick", importObjective_OnClick)

    local deleteObjective = AceGUI:Create("Dropdown")
    deleteObjective:SetLabel(L["Delete Objective Template"])
    deleteObjective:SetCallback("OnValueChanged", deleteObjective_OnValueChanged)
    deleteObjective:SetUserData("NotifyChange", NotifyChangeFuncs.deleteObjective)

    -- Add children
    private:AddChildren(content, newObjective, importObjective, deleteObjective)
    private:NotifyChange(content)
end

local function GetTrackerContent() end

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
    end
end

--[[ Options ]]
function private:GetObjectivesOptions(treeGroup, subgroup)
    treeGroup:SetLayout("Fill")

    if subgroup then
        local tabGroup = AceGUI:Create("TabGroup")
        tabGroup:SetLayout("Fill")
        tabGroup:SetTabs({
            { value = "general", text = L["General"] },
            { value = "trackers", text = L["Trackers"] },
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
    else
        local scrollContainer = AceGUI:Create("SimpleGroup")
        scrollContainer:SetFullWidth(true)
        scrollContainer:SetLayout("Fill")
        treeGroup:AddChild(scrollContainer)

        local scrollContent = AceGUI:Create("ScrollFrame")
        scrollContent:SetLayout("Flow")
        scrollContainer:AddChild(scrollContent)

        GetObjectiveContent(scrollContent)
    end
end
