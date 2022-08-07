local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)
local AceGUI = LibStub("AceGUI-3.0")
local LibSerialize = LibStub("LibSerialize")
local LibDeflate = LibStub("LibDeflate")

--[[ Lists ]]
local lists = {
    condition = {
        ALL = L["All"],
        ANY = L["Any"],
        CUSTOM = L["Custom"],
    },

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

        onUseItemID = function(self)
            self:SetText(objectiveInfo.onUse.itemID)
            self:SetDisabled(objectiveInfo.onUse.type ~= "ITEM")
        end,

        onUseItemIDPreview = function(self)
            local itemID = objectiveInfo.onUse.itemID

            if objectiveInfo.onUse.type ~= "ITEM" or not itemID then
                self:SetText()
                self:SetImage()
                return
            end

            private:CacheItem(itemID)
            local itemName, _, _, _, _, _, _, _, _, icon = GetItemInfo(itemID)

            self:SetText(itemName)
            self:SetImage(icon)
        end,

        onUseMacrotext = function(self)
            self:SetText(objectiveInfo.onUse.macrotext)
            self:SetDisabled(objectiveInfo.onUse.type ~= "MACROTEXT")
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

    local function onUseitemID_OnEnterPressed(self, _, value)
        local itemID = private:ValidateItem(value)
        if itemID then
            private.db.global.objectives[objectiveTitle].onUse.itemID = itemID
            private:NotifyChange(content)
            self:ClearFocus()
        else
            private.options:SetStatusText(L["Invalid itemID."])
            self:HighlightText()
        end
    end

    local function onUseMacrotext_OnEnterPressed(_, _, value)
        private.db.global.objectives[objectiveTitle].onUse.macrotext = value
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

    local onUseGroup = AceGUI:Create("InlineGroup")
    onUseGroup:SetTitle(L["OnUse"])
    onUseGroup:SetFullWidth(true)
    onUseGroup:SetLayout("Flow")

    local onUseType = AceGUI:Create("Dropdown")
    onUseType:SetList(lists.onUseType)
    onUseType:SetLabel(L["Type"])
    onUseType:SetCallback("OnValueChanged", onUseType_OnValueChanged)
    onUseType:SetUserData("NotifyChange", NotifyChangeFuncs.onUseType)

    local onUseItemIDPreview = AceGUI:Create("Label")
    onUseItemIDPreview:SetFullWidth(true)
    onUseItemIDPreview:SetImageSize(14, 14)
    onUseItemIDPreview:SetUserData("NotifyChange", NotifyChangeFuncs.onUseItemIDPreview)

    local onUseItemID = AceGUI:Create("EditBox")
    onUseItemID:SetFullWidth(true)
    onUseItemID:SetLabel(L["ItemID"])
    onUseItemID:SetCallback("OnEnterPressed", onUseitemID_OnEnterPressed)
    onUseItemID:SetUserData("NotifyChange", NotifyChangeFuncs.onUseItemID)

    local onUseMacrotext = AceGUI:Create("MultiLineEditBox")
    onUseMacrotext:SetFullWidth(true)
    onUseMacrotext:SetLabel(L["Macrotext"])
    onUseMacrotext:SetCallback("OnEnterPressed", onUseMacrotext_OnEnterPressed)
    onUseMacrotext:SetUserData("NotifyChange", NotifyChangeFuncs.onUseMacrotext)

    private:AddChildren(onUseGroup, onUseType, onUseItemIDPreview, onUseItemID, onUseMacrotext)

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
        onUseGroup,
        duplicateObjective,
        exportObjective,
        deleteObjective
    )
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

local function GetTrackerContent(objectiveTitle, content)
    local objectiveInfo = private.db.global.objectives[objectiveTitle]

    -- NotifyChange
    local NotifyChangeFuncs = {
        condition = function(self)
            self:SetValue(objectiveInfo.condition.type)
        end,

        conditionFunc = function(self)
            self:SetText(objectiveInfo.condition.func)
            self:SetDisabled(objectiveInfo.condition.type ~= "CUSTOM")
        end,
    }

    -- Callback
    local function condition_OnValueChanged(_, _, value)
        private.db.global.objectives[objectiveTitle].condition.type = value
        private:NotifyChange(content)
    end

    local function conditionFunc_OnEnterPressed(_, _, value)
        local err
        local func = loadstring("return " .. value)
        if type(func) == "function" then
            local success, userFunc = pcall(func)
            if success and type(userFunc) == "function" then
                private.db.global.objectives[objectiveTitle].condition.func = value
                private:NotifyChange(content)
            else
                err = L["Hidden must be a function returning a boolean value."]
            end
        else
            err = L["Hidden must be a function returning a boolean value."]
        end
    end

    -- Widgets
    local condition = AceGUI:Create("Dropdown")
    condition:SetLabel(L["Condition"])
    condition:SetList(lists.condition)
    condition:SetCallback("OnValueChanged", condition_OnValueChanged)
    condition:SetUserData("NotifyChange", NotifyChangeFuncs.condition)

    local conditionFunc = AceGUI:Create("FarmingBar_LuaEditBox")
    conditionFunc:SetFullWidth(true)
    conditionFunc:SetLabel(L["Custom Condition"])
    conditionFunc:Initialize(objectiveInfo.condition.func, conditionFunc_OnEnterPressed)
    conditionFunc:SetUserData("NotifyChange", NotifyChangeFuncs.conditionFunc)

    -- Add Children
    private:AddChildren(content, condition, conditionFunc)
    private:NotifyChange(content)
end

--[[ Callbacks ]]
local function tabGroup_OnGroupSelected(tabGroup, _, group)
    local objectiveTitle = tabGroup:GetUserData("objectiveTitle")
    local content = tabGroup:GetUserData("scrollContent")

    content:ReleaseChildren()

    if group == "general" then
        GetGeneralContent(objectiveTitle, content)
    elseif group == "trackers" then
        GetTrackerContent(objectiveTitle, content)
    end
    private:NotifyChange(content)
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
