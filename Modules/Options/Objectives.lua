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

    trackerType = {
        ITEM = L["Item"],
        CURRENCY = L["Currency"],
    },

    onUseType = {
        ITEM = L["Item"],
        MACROTEXT = L["Macrotext"],
        NONE = L["None"],
    },
}

--[[ Menus ]]
local function GetTrackerMenu(objectiveTitle)
    local menu = {
        {
            value = "trackers",
            text = L["Trackers"],
        },
    }

    local numTrackers = addon.tcount(private.db.global.objectives[objectiveTitle].trackers)

    if numTrackers > 0 then
        menu[1].children = {}
    end

    for trackerKey, trackerInfo in addon.pairs(private.db.global.objectives[objectiveTitle].trackers) do
        local trackerName = private:GetObjectiveTemplateTrackerName(trackerInfo.type, trackerInfo.id)
        tinsert(menu[1].children, {
            value = trackerKey,
            text = trackerName,
            icon = private:GetObjectiveTemplateTrackerIcon(trackerInfo.type, trackerInfo.id),
        })
    end

    if numTrackers > 0 then
        sort(menu[1].children, function(a, b)
            return a.text < b.text
        end)
    end

    return menu
end

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

        trackerTree = function(self)
            self:SetTree(GetTrackerMenu(objectiveTitle))
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

    local function trackerTree_OnGroupSelected(trackerTree, _, path)
        local group, subgroup = strsplit("\001", path)
        local scrollContent = trackerTree:GetUserData("scrollContent")
        scrollContent:ReleaseChildren()

        if not subgroup then
            -- Callbacks
            local function trackerID_OnEnterPressed(trackerType, self, _, value)
                local pendingTrackerType = trackerType:GetValue()

                if pendingTrackerType == "ITEM" then
                    local itemID = private:ValidateItem(value)
                    if itemID then
                        if not private:ObjectiveTemplateTrackerExists(objectiveTitle, pendingTrackerType, itemID) then
                            local subgroup =
                                private:AddObjectiveTemplateTracker(objectiveTitle, pendingTrackerType, itemID)
                            private:NotifyChange(content)

                            local itemName = private:GetObjectiveTemplateTrackerName(pendingTrackerType, itemID)
                            trackerTree:SelectByPath(group, subgroup)
                        else
                            private.options:SetStatusText(L["Tracker already exists within this objective."])
                            self:HighlightText()
                        end
                    else
                        private.options:SetStatusText(L["Invalid itemID."])
                        self:HighlightText()
                    end
                elseif pendingTrackerType == "CURRENCY" then
                else
                    private.options:SetStatusText(L["Please select a tracker type."])
                    self:ClearFocus()
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

            local addTrackerGroup = AceGUI:Create("InlineGroup")
            addTrackerGroup:SetTitle(L["New Tracker"])
            addTrackerGroup:SetFullWidth(true)
            addTrackerGroup:SetLayout("Flow")

            local trackerType = AceGUI:Create("Dropdown")
            trackerType:SetLabel(L["Type"])
            trackerType:SetList(lists.trackerType)

            local trackerID = AceGUI:Create("EditBox")
            trackerID:SetLabel(L["Currency/Item ID"])
            trackerID:SetCallback("OnEnterPressed", function(...)
                trackerID_OnEnterPressed(trackerType, ...)
            end)

            -- Add children
            private:AddChildren(addTrackerGroup, trackerType, trackerID)
            private:AddChildren(scrollContent, condition, conditionFunc, addTrackerGroup)
        else
            local trackerInfo = objectiveInfo.trackers[tonumber(subgroup)]
            local trackerName = private:GetObjectiveTemplateTrackerName(trackerInfo.type, trackerInfo.id)

            -- NotifyChange
            local NotifyChangeFuncs = {
                objective = function(self)
                    self:SetText(trackerInfo.objective)
                end,
            }

            -- Callbacks
            local function deleteTracker_OnClick()
                local deleteFunc = function()
                    private:DeleteObjectiveTemplateTracker(objectiveTitle, tonumber(subgroup))
                    private:NotifyChange(content)
                    trackerTree:SelectByPath(group)
                end

                private:ShowConfirmationDialog(
                    format(
                        L["Are you sure you want to delete %s from objective template \"%s\"?"],
                        trackerName,
                        objectiveTitle
                    ),
                    deleteFunc
                )
            end

            local function objective_OnEnterPressed(self, _, value)
                local objective = tonumber(value) or 1
                objective = objective < 1 and 1 or objective

                self:ClearFocus()
                private.db.global.objectives[objectiveTitle].trackers[tonumber(subgroup)].objective = objective
                private:NotifyChange(scrollContent)
            end

            -- Widgets
            local header = AceGUI:Create("Label")
            header:SetFullWidth(true)
            header:SetFontObject(GameFontNormal)
            header:SetColor(1, 0.82, 0)
            header:SetText(trackerName)
            header:SetImage(private:GetObjectiveTemplateTrackerIcon(trackerInfo.type, trackerInfo.id))
            header:SetImageSize(14, 14)

            local objective = AceGUI:Create("EditBox")
            objective:SetLabel(L["Objective"])
            objective:SetCallback("OnEnterPressed", objective_OnEnterPressed)
            objective:SetUserData("NotifyChange", NotifyChangeFuncs.objective)

            local altIDsGroup = AceGUI:Create("InlineGroup")
            altIDsGroup:SetTitle(L["Alt IDs"])
            altIDsGroup:SetFullWidth(true)
            altIDsGroup:SetLayout("Flow")

            altIDsGroup:SetUserData("NotifyChange", function()
                altIDsGroup:ReleaseChildren()

                local altIDType = AceGUI:Create("Dropdown")
                altIDType:SetLabel(L["Type"])
                altIDType:SetList(lists.trackerType)

                local altID = AceGUI:Create("EditBox")
                altID:SetLabel(L["Currency/Item ID"])
                altID:SetCallback("OnEnterPressed", altID_OnEnterPressed)

                local spacer = AceGUI:Create("Label")
                spacer:SetFullWidth(true)
                spacer:SetText(" ")

                for _, altIDInfo in pairs(trackerInfo.altIDs) do
                    local remove = AceGUI:Create("InteractiveLabel")
                    remove:SetRelativeWidth(2 / 16)
                    remove:SetText("X")
                    remove:SetCallback("OnClick", remove_OnClick) -- TODO

                    local label = AceGUI:Create("Label")
                    label:SetRelativeWidth(12 / 16)
                    label:SetImageSize(14, 14)
                    label:SetUserData("NotifyChange", function(self)
                        self:SetText(private:GetObjectiveTemplateTrackerName(altIDInfo.type, altIDInfo.id))
                        self:SetImage(private:GetObjectiveTemplateTrackerIcon(altIDInfo.type, altIDInfo.id))
                    end)

                    local multiplier = AceGUI:Create("EditBox")
                    multiplier:SetRelativeWidth(2 / 16)
                    multiplier:SetUserData("NotifyChange", function(self)
                        self:SetText(altIDInfo.multiplier)
                    end)
                    multiplier:SetCallback("OnEnterPressed", multiplier_OnEnterPressed) -- TODO

                    private:AddChildren(altIDsGroup, altIDType, altID, spacer, remove, label, multiplier)
                end

                scrollContent:DoLayout()
            end)

            local deleteTracker = AceGUI:Create("Button")
            deleteTracker:SetText(DELETE)
            deleteTracker:SetCallback("OnClick", deleteTracker_OnClick)

            -- Add children
            private:AddChildren(scrollContent, header, objective, altIDsGroup, deleteTracker)
            private:NotifyChange(altIDsGroup)
        end

        private:NotifyChange(scrollContent)
    end

    -- Widgets
    local trackerTree = AceGUI:Create("TreeGroup")
    trackerTree:SetFullWidth(true)
    trackerTree:SetLayout("Fill")
    trackerTree:SetCallback("OnGroupSelected", trackerTree_OnGroupSelected)
    trackerTree:SetUserData("NotifyChange", NotifyChangeFuncs.trackerTree)

    local scrollContainer = AceGUI:Create("SimpleGroup")
    scrollContainer:SetFullWidth(true)
    scrollContainer:SetLayout("Fill")
    trackerTree:AddChild(scrollContainer)

    local scrollContent = AceGUI:Create("ScrollFrame")
    scrollContent:SetLayout("Flow")
    scrollContainer:AddChild(scrollContent)
    trackerTree:SetUserData("scrollContent", scrollContent)

    -- Add children
    private:AddChildren(content, trackerTree)
    private:NotifyChange(trackerTree)
end

--[[ Callbacks ]]
local function tabGroup_OnGroupSelected(tabGroup, _, group)
    local objectiveTitle = tabGroup:GetUserData("objectiveTitle")

    tabGroup:ReleaseChildren()

    if group == "general" then
        local scrollContainer = AceGUI:Create("SimpleGroup")
        scrollContainer:SetFullWidth(true)
        scrollContainer:SetLayout("Fill")
        tabGroup:AddChild(scrollContainer)

        local scrollContent = AceGUI:Create("ScrollFrame")
        scrollContent:SetLayout("Flow")
        scrollContainer:AddChild(scrollContent)
        tabGroup:SetUserData("scrollContent", scrollContent)

        GetGeneralContent(objectiveTitle, scrollContent)
        private:NotifyChange(scrollContent)
    elseif group == "trackers" then
        GetTrackerContent(objectiveTitle, tabGroup)
        private:NotifyChange(tabGroup)
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

        private:AddChildren(treeGroup, tabGroup)
        tabGroup:SelectTab("trackers")
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
