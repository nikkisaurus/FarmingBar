local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)
local AceGUI = LibStub("AceGUI-3.0")
local LibSerialize = LibStub("LibSerialize")
local LibDeflate = LibStub("LibDeflate")

-- TODO: Save position when changing groups

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

    local function icon_OnClick(self)
        if addon.tcount(objectiveInfo.trackers) == 0 then
            private.options:SetStatusText(L["Objective template must contain at least one tracker."])
        else
            private:PickupObjectiveTemplate(objectiveTitle)
        end
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
    icon:SetCallback("OnClick", icon_OnClick)
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
        objectiveTemplatesGroup = function(self)
            -- Widgets
            for objectiveTitle, objectiveInfo in addon.pairs(private.db.global.objectives) do
                -- Callbacks
                local function objective_OnClick(self)
                    if addon.tcount(objectiveInfo.trackers) == 0 then
                        private.options:SetStatusText(L["Objective template must contain at least one tracker."])
                    else
                        private:PickupObjectiveTemplate(objectiveTitle)
                    end
                end

                local objective = AceGUI:Create("Icon")
                objective:SetWidth(44, 42)
                objective:SetImageSize(40, 40)
                objective:SetImage(private:GetObjectiveIcon(objectiveInfo))
                objective:SetLabel(objectiveTitle)
                private:SetOptionTooltip(objective, objectiveTitle)
                objective:SetCallback("OnClick", objective_OnClick)

                private:AddChildren(self, objective)
            end
        end,

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

    local objectiveTemplatesGroup = AceGUI:Create("InlineGroup")
    objectiveTemplatesGroup:SetTitle(L["Objective Templates"])
    objectiveTemplatesGroup:SetFullWidth(true)
    objectiveTemplatesGroup:SetLayout("Flow")
    objectiveTemplatesGroup:SetUserData("NotifyChange", NotifyChangeFuncs.objectiveTemplatesGroup)

    -- Add children
    private:AddChildren(content, newObjective, importObjective, deleteObjective, objectiveTemplatesGroup)
    private:NotifyChange(content)
end

local function GetTrackerContent(objectiveTitle, content)
    local objectiveInfo = private.db.global.objectives[objectiveTitle]

    -- NotifyChange
    local NotifyChangeFuncs = {
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
        local trackerKey = tonumber(subgroup)
        local trackerInfo = objectiveInfo.trackers[trackerKey]
        local trackerName = trackerInfo and private:GetObjectiveTemplateTrackerName(trackerInfo.type, trackerInfo.id)
            or {}

        local scrollContent = trackerTree:GetUserData("scrollContent")
        scrollContent:ReleaseChildren()

        -- NotifyChange
        local NotifyChangeFuncs = {
            altIDsGroup = function(self)
                -- ! Resizing window rapidly sometimes causes game to freeze
                self:ReleaseChildren()
                for i, child in pairs(self.children) do
                    if i > 3 then
                        child:Release()
                    end
                end

                -- Callbacks
                local function multiplier_OnEnterPressed(self, _, value)
                    -- TODO: turn string rationals into decimals
                    local multiplier = tonumber(value) or 1
                    multiplier = multiplier > 0 and multiplier or 1

                    self:ClearFocus()

                    private.db.global.objectives[objectiveTitle].trackers[trackerKey].altIDs[self:GetUserData("altKey")].multiplier =
                        multiplier
                    private:NotifyChange(content)
                end

                local function remove_OnClick(self)
                    private:DeleteObjectiveTemplateTrackerAltID(objectiveTitle, trackerKey, self:GetUserData("altKey"))
                    private:NotifyChange(content)
                end

                -- Widgets
                local removeTxt = AceGUI:Create("Label")
                removeTxt:SetColor(1, 0.82, 0)
                removeTxt:SetRelativeWidth(1 / 16)
                removeTxt:SetText(" ")

                local labelTxt = AceGUI:Create("Label")
                labelTxt:SetColor(1, 0.82, 0)
                labelTxt:SetRelativeWidth(11 / 16)
                labelTxt:SetText(L["Item/Currency Name"])

                local multiplierTxt = AceGUI:Create("Label")
                multiplierTxt:SetColor(1, 0.82, 0)
                multiplierTxt:SetRelativeWidth(4 / 16)
                multiplierTxt:SetText(L["Multiplier"])

                for altKey, altInfo in pairs(trackerInfo.altIDs or {}) do
                    local remove = AceGUI:Create("InteractiveLabel")
                    remove:SetRelativeWidth(1 / 16)
                    remove:SetText("X")
                    remove:SetCallback("OnClick", remove_OnClick)
                    remove:SetUserData("altKey", altKey)

                    local label = AceGUI:Create("Label")
                    label:SetRelativeWidth(11 / 16)
                    label:SetImageSize(14, 14)
                    label:SetUserData("NotifyChange", function(self)
                        self:SetText(private:GetObjectiveTemplateTrackerName(altInfo.type, altInfo.id))
                        self:SetImage(private:GetObjectiveTemplateTrackerIcon(altInfo.type, altInfo.id))
                    end)

                    local multiplier = AceGUI:Create("EditBox")
                    multiplier:SetRelativeWidth(4 / 16)
                    multiplier:SetCallback("OnEnterPressed", multiplier_OnEnterPressed)
                    multiplier:SetUserData("altKey", altKey)
                    multiplier:SetUserData("NotifyChange", function(self)
                        self:SetText(altInfo.multiplier)
                    end)

                    -- Add children
                    private:AddChildren(self, removeTxt, labelTxt, multiplierTxt, remove, label, multiplier)
                end

                scrollContent:DoLayout()
            end,

            condition = function(self)
                self:SetValue(objectiveInfo.condition.type)
            end,

            conditionFunc = function(self)
                self:SetText(objectiveInfo.condition.func)
                self:SetDisabled(objectiveInfo.condition.type ~= "CUSTOM")
            end,

            objective = function(self)
                self:SetText(trackerInfo.objective)
            end,
        }

        -- Callbacks
        scrollContent:SetUserData("_OnEnterPressed", function(_Type, pendingType, widget, id)
            if pendingType then
                local validID = pendingType == "ITEM" and private:ValidateItem(id)
                    or pendingType == "CURRENCY" and private:ValidateCurrency(id)

                if validID then
                    local exists = _Type == "tracker"
                            and private:ObjectiveTemplateTrackerExists(objectiveTitle, pendingType, validID)
                        or _Type == "altID"
                            and private:ObjectiveTemplateTrackerAltIDExists(
                                objectiveTitle,
                                trackerKey,
                                pendingType,
                                validID
                            )

                    if not exists then
                        if _Type == "tracker" then
                            local subgroup = private:AddObjectiveTemplateTracker(objectiveTitle, pendingType, validID)
                            local itemName = private:GetObjectiveTemplateTrackerName(pendingType, validID)
                            trackerTree:SelectByPath(group, subgroup)
                        elseif _Type == "altID" then
                            private:AddObjectiveTemplateTrackerAltID(objectiveTitle, trackerKey, pendingType, validID)
                        end

                        private:NotifyChange(content)
                        widget:SetText()
                    else
                        private.options:SetStatusText(L["Invalid input: duplicate entry."])
                        widget:HighlightText()
                    end
                else
                    private.options:SetStatusText(L["Invalid item/currency ID."])
                    widget:HighlightText()
                end
            else
                private.options:SetStatusText(L["Please select type: item or currency."])
            end

            widget:ClearFocus()
        end)

        local function deleteTracker_OnClick()
            local deleteFunc = function()
                private:DeleteObjectiveTemplateTracker(objectiveTitle, trackerKey)
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
            private.db.global.objectives[objectiveTitle].trackers[trackerKey].objective = objective
            private:NotifyChange(scrollContent)
        end

        -- Widgets
        if not subgroup then
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
            trackerID:SetCallback("OnEnterPressed", function(self, _, value)
                scrollContent:GetUserData("_OnEnterPressed")("tracker", trackerType:GetValue(), self, value)
            end)

            -- Add children
            private:AddChildren(addTrackerGroup, trackerType, trackerID)
            private:AddChildren(scrollContent, condition, conditionFunc, addTrackerGroup)
        else
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

            local newAltID = AceGUI:Create("InlineGroup")
            newAltID:SetTitle(L["New Alt ID"])
            newAltID:SetFullWidth(true)
            newAltID:SetLayout("Flow")

            local altType = AceGUI:Create("Dropdown")
            altType:SetLabel(L["Type"])
            altType:SetList(lists.trackerType)

            local altID = AceGUI:Create("EditBox")
            altID:SetLabel(L["Currency/Item ID"])
            altID:SetCallback("OnEnterPressed", function(self, _, value)
                scrollContent:GetUserData("_OnEnterPressed")("altID", altType:GetValue(), self, value)
            end)

            local altIDsGroup = AceGUI:Create("InlineGroup")
            altIDsGroup:SetTitle(L["Alt IDs"])
            altIDsGroup:SetFullWidth(true)
            altIDsGroup:SetLayout("Flow")
            altIDsGroup:SetUserData("NotifyChange", NotifyChangeFuncs.altIDsGroup)

            local deleteTracker = AceGUI:Create("Button")
            deleteTracker:SetText(DELETE)
            deleteTracker:SetCallback("OnClick", deleteTracker_OnClick)

            -- Add children
            private:AddChildren(newAltID, altType, altID)
            private:AddChildren(scrollContent, header, objective, newAltID, altIDsGroup, deleteTracker)
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
