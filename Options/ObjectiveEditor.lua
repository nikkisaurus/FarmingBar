local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)
local AceGUI = LibStub("AceGUI-3.0")

--[[ Content ]]
local function GetGeneralContent(objectiveInfo, content)
    local widget = content.parent.parent:GetUserData("widget")
    local barID, buttonID = widget:GetID()
    local objectiveTitle = objectiveInfo.title

    -- Callbacks
    local callbacks = {
        applyTemplate = function(self, _, value)
            local confirmFunc = function()
                widget:SetObjectiveInfo(addon.CloneTable(private.db.global.objectives[value]))
                private:ShowObjectiveEditor(widget)
            end

            local barID, buttonID = widget:GetID()
            private:ShowConfirmationDialog(
                format(
                    L["Are you sure you want to overwrite Bar %d Button %d with objective template \"%s\"?"],
                    barID,
                    buttonID,
                    value
                ),
                confirmFunc
            )

            self:SetValue()
        end,

        iconID = function(self, _, value)
            private.db.profile.bars[barID].buttons[buttonID].icon.id = tonumber(value) or 134400
            private:NotifyChange(content)
            widget:SetIconTextures()
            self:ClearFocus()
        end,

        iconType = function(_, _, value)
            private.db.profile.bars[barID].buttons[buttonID].icon.type = value
            private:NotifyChange(content)
            widget:SetIconTextures()
        end,

        onUseitemID = function(self, _, value)
            local itemID = private:ValidateItem(value)
            if itemID then
                private.db.profile.bars[barID].buttons[buttonID].onUse.itemID = itemID
                private:NotifyChange(content)
                widget:SetAttributes()
                widget:SetIconTextures()
                self:ClearFocus()
            else
                private.editor:SetStatusText(L["Invalid itemID."])
                self:HighlightText()
            end
        end,

        onUseMacrotext = function(_, _, value)
            private.db.profile.bars[barID].buttons[buttonID].onUse.macrotext = value
            private:NotifyChange(content)
            widget:SetAttributes()
        end,

        onUseType = function(_, _, value)
            private.db.profile.bars[barID].buttons[buttonID].onUse.type = value
            private:NotifyChange(content)
            widget:SetAttributes()
            widget:SetIconTextures()
        end,

        saveTemplate = function()
            local newObjectiveTitle = private:AddObjectiveTemplate(objectiveInfo)
            private:LoadOptions()
            private:UpdateMenu(private.options:GetUserData("menu"), "Objectives", newObjectiveTitle)
            private:NotifyChange(content)
        end,

        title = function(self, _, value)
            private.db.profile.bars[barID].buttons[buttonID].title = value
            self:ClearFocus()
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

    local applyTemplate = private:GetObjectiveWidget("applyTemplate", objectiveInfo)
    applyTemplate:SetCallback("OnValueChanged", callbacks.applyTemplate)
    private.editor:SetUserData("applyTemplate", applyTemplate)

    local saveTemplate = private:GetObjectiveWidget("saveTemplate", objectiveInfo)
    saveTemplate:SetCallback("OnClick", callbacks.saveTemplate)

    -- Add children
    private:AddChildren(onUseGroup, onUseType, onUseItemIDPreview, onUseItemID, onUseMacrotext)
    private:AddChildren(content, icon, title, iconType, iconID, onUseGroup, applyTemplate, saveTemplate)
end

local function GetTrackerContent(objectiveInfo, content)
    local widget = content:GetUserData("widget")
    local barID, buttonID = widget:GetID()
    local objectiveTitle = objectiveInfo.title

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
                private.db.profile.bars[barID].buttons[buttonID].condition.type = value
                widget:SetCount()
                private:NotifyChange(scrollContent)
            end,

            conditionFunc = function(_, _, value)
                local err
                local func = loadstring("return " .. value)
                if type(func) == "function" then
                    local success, userFunc = pcall(func)
                    if success and type(userFunc) == "function" then
                        private.db.profile.bars[barID].buttons[buttonID].condition.func = value
                        widget:SetCount()
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
                    private.db.profile.bars[barID].buttons[buttonID].trackers[trackerKey] = nil
                    private:NotifyChange(content)
                    widget:SetCount()
                end

                local trackerInfo = objectiveInfo.trackers[trackerKey]

                private:ShowConfirmationDialog(
                    format(
                        L["Are you sure you want to delete %s from Bar %d Button %d?"],
                        private:GetObjectiveTemplateTrackerName(trackerInfo.type, trackerInfo.id),
                        barID,
                        buttonID
                    ),
                    deleteFunc
                )
            end,

            includeAlts = function(_, _, value)
                private.db.profile.bars[barID].buttons[buttonID].trackers[trackerKey].includeAlts = value
                widget:SetCount()
            end,

            includeBank = function(_, _, value)
                private.db.profile.bars[barID].buttons[buttonID].trackers[trackerKey].includeBank = value
                widget:SetCount()
            end,

            includeGuildBank = function(_, _, value, checked)
                private.db.profile.bars[barID].buttons[buttonID].trackers[trackerKey].includeGuildBank[value] = checked
                widget:SetCount()
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

                private.db.profile.bars[barID].buttons[buttonID].trackers[trackerKey].altIDs[self:GetUserData("altKey")].multiplier =
                    multiplier
                private:NotifyChange(self.parent)
                widget:SetCount()
            end,

            remove = function(self)
                private.db.profile.bars[barID].buttons[buttonID].trackers[trackerKey].altIDs[self:GetUserData("altKey")] =
                    nil
                private:NotifyChange(self.parent.parent)
                widget:SetCount()
            end,

            objective = function(self, _, value)
                local objective = tonumber(value) or 1
                objective = objective < 1 and 1 or objective

                self:ClearFocus()
                private.db.profile.bars[barID].buttons[buttonID].trackers[trackerKey].objective = objective
                widget:SetCount()
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
            trackerID:SetUserData("barID", barID)
            trackerID:SetUserData("buttonID", buttonID)
            trackerID:SetCallback("OnEnterPressed", function(self, _, value)
                local isValid = private:ValidateTracker({
                    widgetType = "button",
                    trackerType = "tracker",
                    widget = self,
                    frame = private.editor,
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
            altID:SetUserData("barID", barID)
            altID:SetUserData("buttonID", buttonID)
            altID:SetCallback("OnEnterPressed", function(self, _, value)
                local isValid = private:ValidateTracker({
                    widgetType = "button",
                    trackerType = "altID",
                    widget = self,
                    frame = private.editor,
                    objectiveInfo = objectiveInfo,
                    trackerKey = trackerKey,
                    pendingType = altType:GetValue(),
                    id = value,
                })

                private:NotifyChange(content)
                widget:SetCount()
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
    local objectiveInfo = tabGroup:GetUserData("objectiveInfo")

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

        GetGeneralContent(objectiveInfo, scrollContent)
        private:NotifyChange(scrollContent)
    elseif group == "trackers" then
        GetTrackerContent(objectiveInfo, tabGroup)
        private:NotifyChange(tabGroup)
    end
end

--[[ Widgets ]]
function private:ShowObjectiveEditor(widget)
    local _, buttonDB = widget:GetDB()
    local barID, buttonID = widget:GetID()

    local editor = private.editor or AceGUI:Create("Frame")
    editor:SetTitle(format("%s %s - %d:%d", L.addonName, L["Objective Editor"], barID, buttonID))
    editor:SetUserData("barID", barID)
    editor:SetUserData("buttonID", buttonID)
    editor:SetLayout("Fill")
    editor:SetWidth(700)
    editor:SetHeight(600)
    editor:Show()
    editor:ReleaseChildren()
    private.editor = editor

    if private.options then
        private.options:Hide()
    end

    local tabGroup = AceGUI:Create("TabGroup")
    tabGroup:SetLayout("Fill")
    tabGroup:SetTabs({
        { value = "general", text = L["General"] },
        { value = "trackers", text = L["Trackers"] },
    })
    tabGroup:SetUserData("objectiveInfo", buttonDB)
    tabGroup:SetUserData("widget", widget)
    tabGroup:SetCallback("OnGroupSelected", tabGroup_OnGroupSelected)
    tabGroup:SelectTab("general")

    private:AddChildren(editor, tabGroup)
end
