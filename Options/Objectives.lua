local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)
local AceGUI = LibStub("AceGUI-3.0")
local LibSerialize = LibStub("LibSerialize")
local LibDeflate = LibStub("LibDeflate")

-- TODO: Save position when changing groups

--[[ Lists ]]
private.lists = {
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

--[[ Content ]]
local function GetGeneralContent(objectiveTitle, content)
    local objectiveInfo = private.db.global.objectives[objectiveTitle]

    -- Callbacks
    local callbacks = {
        deleteObjective = function()
            local deleteFunc = function()
                private:DeleteObjectiveTemplate(objectiveTitle)
                private:UpdateMenu(private.options:GetUserData("menu"), "Objectives")
            end

            private:ShowConfirmationDialog(
                format(L["Are you sure you want to delete the objective template \"%s\"?"], objectiveTitle),
                deleteFunc
            )
        end,

        duplicateObjective = function()
            local newObjectiveTitle = private:DuplicateObjectiveTemplate(objectiveTitle)
            private:UpdateMenu(private.options:GetUserData("menu"), "Objectives", newObjectiveTitle)
        end,

        exportObjective = function()
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
        end,

        icon = function(self)
            if addon.tcount(objectiveInfo.trackers) == 0 then
                private.options:SetStatusText(L["Objective template must contain at least one tracker."])
            else
                private:PickupObjectiveTemplate(objectiveTitle)
            end
        end,

        iconID = function(_, _, value)
            private.db.global.objectives[objectiveTitle].icon.id = tonumber(value) or 134400
            private:NotifyChange(content)
        end,

        iconType = function(_, _, value)
            private.db.global.objectives[objectiveTitle].icon.type = value
            private:NotifyChange(content)
        end,

        onUseItemID = function(self, _, value)
            local itemID = private:ValidateItem(value)
            if itemID then
                private.db.global.objectives[objectiveTitle].onUse.itemID = itemID
                private:NotifyChange(content)
                self:ClearFocus()
            else
                private.options:SetStatusText(L["Invalid itemID."])
                self:HighlightText()
            end
        end,

        onUseMacrotext = function(_, _, value)
            private.db.global.objectives[objectiveTitle].onUse.macrotext = value
            private:NotifyChange(content)
        end,

        onUseType = function(_, _, value)
            private.db.global.objectives[objectiveTitle].onUse.type = value
            private:NotifyChange(content)
        end,

        title = function(_, _, value)
            if private:ObjectiveTemplateExists(value) then
                private.options:SetStatusText(L["Objective template exists."])
            else
                private:RenameObjectiveTemplate(objectiveTitle, value)
                private:UpdateMenu(private.options:GetUserData("menu"), "Objectives", value)
            end
        end,
    }

    -- Widgets
    local icon = private:GetObjectiveWidget("icon", objectiveInfo)
    icon:SetCallback("OnClick", callbacks.icon)

    local title = private:GetObjectiveWidget("title", objectiveInfo)
    title:SetCallback("OnEnterPressed", callbacks.title)

    local iconType = private:GetObjectiveWidget("iconType", objectiveInfo)
    iconType:SetCallback("OnValueChanged", callbacks.iconType)

    local iconID = private:GetObjectiveWidget("iconID", objectiveInfo)
    iconID:SetCallback("OnEnterPressed", callbacks.iconID)

    local onUseGroup = private:GetObjectiveWidget("onUseGroup", objectiveInfo)

    local onUseType = private:GetObjectiveWidget("onUseType", objectiveInfo)
    onUseType:SetCallback("OnValueChanged", callbacks.onUseType)

    local onUseItemIDPreview = private:GetObjectiveWidget("onUseItemIDPreview", objectiveInfo)

    local onUseItemID = private:GetObjectiveWidget("onUseItemID", objectiveInfo)
    onUseItemID:SetCallback("OnEnterPressed", callbacks.onUseItemID)

    local onUseMacrotext = private:GetObjectiveWidget("onUseMacrotext", objectiveInfo)
    onUseMacrotext:SetCallback("OnEnterPressed", callbacks.onUseMacrotext)

    local duplicateObjective = AceGUI:Create("Button")
    duplicateObjective:SetText(L["Duplicate"])
    duplicateObjective:SetCallback("OnClick", callbacks.duplicateObjective)

    local exportObjective = AceGUI:Create("Button")
    exportObjective:SetText(L["Export"])
    exportObjective:SetCallback("OnClick", callbacks.exportObjective)

    local deleteObjective = AceGUI:Create("Button")
    deleteObjective:SetText(L["Delete"])
    deleteObjective:SetCallback("OnClick", callbacks.deleteObjective)

    -- Add children
    private:AddChildren(onUseGroup, onUseType, onUseItemIDPreview, onUseItemID, onUseMacrotext)
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
            self:ReleaseChildren()
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
            local list = private.lists.deleteObjective()
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
        private.db.global.objectives[newObjectiveTitle].title = newObjectiveTitle
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

    -- Widgets
    local trackerTree = private:GetTrackerWidgets("trackerTree", objectiveInfo)
    trackerTree:SetCallback("OnGroupSelected", function(self, _, path)
        local group, subgroup = strsplit("\001", path)
        local trackerKey = tonumber(subgroup)

        local scrollContent = self:GetUserData("scrollContent")
        scrollContent:ReleaseChildren()

        -- Callbacks
        local callbacks = {
            _OnEnterPressed = function() end,

            condition = function(_, _, value)
                private.db.global.objectives[objectiveTitle].condition.type = value
                private:NotifyChange(content)
            end,

            conditionFunc = function(_, _, value)
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
            end,

            deleteTracker = function()
                local deleteFunc = function()
                    trackerTree:SelectByPath(group)
                    private:DeleteObjectiveTemplateTracker(objectiveTitle, trackerKey)
                    private:NotifyChange(content)
                end

                local trackerInfo = objectiveInfo.trackers[trackerKey]

                private:ShowConfirmationDialog(
                    format(
                        L["Are you sure you want to delete %s from objective template \"%s\"?"],
                        private:GetObjectiveTemplateTrackerName(trackerInfo.type, trackerInfo.id),
                        objectiveTitle
                    ),
                    deleteFunc
                )
            end,

            includeAlts = function(_, _, value)
                private.db.global.objectives[objectiveTitle].trackers[trackerKey].includeAlts = value
            end,

            includeBank = function(_, _, value)
                private.db.global.objectives[objectiveTitle].trackers[trackerKey].includeBank = value
            end,

            includeGuildBank = function(_, _, value, checked)
                private.db.global.objectives[objectiveTitle].trackers[trackerKey].includeGuildBank[value] = checked
                private:NotifyChange(scrollContent)
            end,

            multiplier = function(self, _, value)
                local num, den = strsplit("/", value)
                local multiplier

                if den then
                    num = tonumber(num)
                    den = tonumber(den)
                    if num and den and den ~= 0 then
                        multiplier = addon.round(num / den, 3)
                    else
                        multiplier = 1
                    end
                else
                    multiplier = tonumber(value) or 1
                end

                multiplier = multiplier > 0 and multiplier or 1

                self:ClearFocus()

                private.db.global.objectives[objectiveTitle].trackers[trackerKey].altIDs[self:GetUserData("altKey")].multiplier =
                    multiplier
                private:NotifyChange(self.parent)
            end,

            remove = function(self)
                private:DeleteObjectiveTemplateTrackerAltID(objectiveTitle, trackerKey, self:GetUserData("altKey"))
                private:NotifyChange(self.parent.parent)
            end,

            objective = function(self, _, value)
                local objective = tonumber(value) or 1
                objective = objective < 1 and 1 or objective

                self:ClearFocus()
                private.db.global.objectives[objectiveTitle].trackers[trackerKey].objective = objective
                private:NotifyChange(scrollContent)
            end,
        }

        -- Widgets
        if not subgroup then
            local condition = private:GetTrackerWidgets("condition", objectiveInfo, trackerKey)
            condition:SetCallback("OnValueChanged", callbacks.condition)

            local conditionFunc = private:GetTrackerWidgets("conditionFunc", objectiveInfo, trackerKey)
            conditionFunc:Initialize(objectiveInfo.condition.func, callbacks.conditionFunc)

            local addTrackerGroup = private:GetTrackerWidgets("addTrackerGroup", objectiveInfo, trackerKey)

            local trackerType = private:GetTrackerWidgets("trackerType", objectiveInfo, trackerKey)

            local trackerID = private:GetTrackerWidgets("trackerID", objectiveInfo, trackerKey)
            trackerID:SetCallback("OnEnterPressed", function(self, _, value)
                local isValid = private:ValidateTracker({
                    widgetType = "template",
                    trackerType = "tracker",
                    widget = self,
                    frame = private.options,
                    objectiveInfo = objectiveInfo,
                    trackerKey = trackerKey,
                    pendingType = trackerType:GetValue(),
                    id = value,
                })
                if isValid then
                    private:NotifyChange(content)
                    trackerTree:SelectByPath(group, isValid)
                end
            end)

            -- -- Add children
            private:AddChildren(addTrackerGroup, trackerType, trackerID)
            private:AddChildren(scrollContent, condition, conditionFunc, addTrackerGroup)
        else
            local header = private:GetTrackerWidgets("header", objectiveInfo, trackerKey)

            local objective = private:GetTrackerWidgets("objective", objectiveInfo, trackerKey)
            objective:SetCallback("OnEnterPressed", callbacks.objective)

            local includeBank = private:GetTrackerWidgets("includeBank", objectiveInfo, trackerKey)
            includeBank:SetCallback("OnValueChanged", callbacks.includeBank)

            local includeGuildBank = private:GetTrackerWidgets("includeGuildBank", objectiveInfo, trackerKey)
            includeGuildBank:SetCallback("OnValueChanged", callbacks.includeGuildBank)

            local includeAlts = private:GetTrackerWidgets("includeAlts", objectiveInfo, trackerKey)
            includeAlts:SetCallback("OnValueChanged", callbacks.includeAlts)

            local dependencies = private:GetTrackerWidgets("dependencies", objectiveInfo, trackerKey)

            local newAltID = private:GetTrackerWidgets("newAltID", objectiveInfo, trackerKey)

            local altType = private:GetTrackerWidgets("altType", objectiveInfo, trackerKey)

            local altID = private:GetTrackerWidgets("altID", objectiveInfo, trackerKey)
            altID:SetCallback("OnEnterPressed", function(self, _, value)
                local isValid = private:ValidateTracker({
                    widgetType = "template",
                    trackerType = "altID",
                    widget = self,
                    frame = private.options,
                    objectiveInfo = objectiveInfo,
                    trackerKey = trackerKey,
                    pendingType = altType:GetValue(),
                    id = value,
                })

                private:NotifyChange(scrollContent)
            end)

            local altIDsGroup = private:GetTrackerWidgets("altIDsGroup", objectiveInfo, trackerKey)

            local removeTxt = private:GetTrackerWidgets("removeTxt", objectiveInfo, trackerKey)

            local labelTxt = private:GetTrackerWidgets("labelTxt", objectiveInfo, trackerKey)

            local multiplierTxt = private:GetTrackerWidgets("multiplierTxt", objectiveInfo, trackerKey)

            local altIDsList = private:GetTrackerWidgets("altIDsList", objectiveInfo, trackerKey)
            altIDsList:SetUserData("NotifyChange", function(self)
                self:ReleaseChildren()

                for altKey, altInfo in addon.pairs(objectiveInfo.trackers[trackerKey].altIDs) do
                    local remove = private:GetTrackerWidgets("remove", objectiveInfo, trackerKey)
                    remove:SetUserData("altKey", altKey)
                    remove:SetCallback("OnClick", callbacks.remove)

                    local label = private:GetTrackerWidgets("label", objectiveInfo, trackerKey)
                    label:SetUserData("altInfo", altInfo)

                    local multiplier = private:GetTrackerWidgets("multiplier", objectiveInfo, trackerKey)
                    multiplier:SetUserData("altKey", altKey)
                    multiplier:SetUserData("altInfo", altInfo)
                    multiplier:SetCallback("OnEnterPressed", callbacks.multiplier)

                    -- Add children
                    private:AddChildren(self, remove, label, multiplier)
                end

                self.parent.parent:DoLayout()
            end)

            local deleteTracker = private:GetTrackerWidgets("deleteTracker", objectiveInfo, trackerKey)
            deleteTracker:SetCallback("OnClick", callbacks.deleteTracker)

            -- Add children
            private:AddChildren(newAltID, altType, altID)
            private:AddChildren(altIDsGroup, removeTxt, labelTxt, multiplierTxt, altIDsList)
            private:AddChildren(
                scrollContent,
                header,
                objective,
                includeBank,
                includeGuildBank,
                includeAlts,
                dependencies,
                newAltID,
                altIDsGroup,
                deleteTracker
            )
        end

        private:NotifyChange(scrollContent)
    end)

    -- Add children
    private:AddChildren(content, trackerTree)
    private:NotifyChange(trackerTree)
    trackerTree:SelectByPath("trackers")
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
