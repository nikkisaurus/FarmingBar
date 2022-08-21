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

    -- Add children
    private:AddChildren(onUseGroup, onUseType, onUseItemIDPreview, onUseItemID, onUseMacrotext)
    private:AddChildren(content, icon, title, iconType, iconID, onUseGroup)
end

local function GetTrackerContent(objectiveInfo, content)
    local widget = content:GetUserData("widget")
    local barID, buttonID = widget:GetID()
    local objectiveTitle = objectiveInfo.title

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
                self:ReleaseChildren()

                -- Callbacks
                local function multiplier_OnEnterPressed(self, _, value)
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

                -- Add children
                if #trackerInfo.altIDs > 0 then
                    private:AddChildren(self, removeTxt, labelTxt, multiplierTxt)
                end

                for altKey, altInfo in addon.pairs(trackerInfo.altIDs) do
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
                    private:AddChildren(self, remove, label, multiplier)
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

            includeAlts = function(self)
                self:SetValue(trackerInfo.includeAlts)
            end,

            includeBank = function(self)
                self:SetValue(trackerInfo.includeBank)
            end,

            includeGuildBank = function(self)
                for guild, enabled in pairs(trackerInfo.includeGuildBank) do
                    self:SetItemValue(guild, enabled)
                end
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
            private:NotifyChange(scrollContent)
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

        local function includeAlts_OnValueChanged(_, _, value)
            private.db.global.objectives[objectiveTitle].trackers[trackerKey].includeAlts = value
        end

        local function includeBank_OnValueChanged(_, _, value)
            private.db.global.objectives[objectiveTitle].trackers[trackerKey].includeBank = value
        end

        local function includeGuildBank_OnValueChanged(_, _, value, checked)
            private.db.global.objectives[objectiveTitle].trackers[trackerKey].includeGuildBank[value] = checked
            private:NotifyChange(scrollContent)
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
            condition:SetList(private.lists.condition)
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
            trackerType:SetList(private.lists.trackerType)

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

            local includeGuildBank = AceGUI:Create("Dropdown")
            includeGuildBank:SetList(private:GetGuildsList())
            includeGuildBank:SetLabel(L["Include Guild Bank"])
            includeGuildBank:SetMultiselect(true)
            includeGuildBank:SetCallback("OnValueChanged", includeGuildBank_OnValueChanged)
            includeGuildBank:SetUserData("NotifyChange", NotifyChangeFuncs.includeGuildBank)

            local includeBank = AceGUI:Create("CheckBox")
            includeBank:SetLabel(L["Include Bank"])
            includeBank:SetCallback("OnValueChanged", includeBank_OnValueChanged)
            includeBank:SetUserData("NotifyChange", NotifyChangeFuncs.includeBank)

            local includeAlts = AceGUI:Create("CheckBox")
            includeAlts:SetLabel(L["Include Alts"])
            local missing = private:GetMissingDataStoreModules()
            if #missing > 0 then
                local msg = L["Missing dependencies"] .. ": "

                for i = 1, #missing do
                    msg = msg .. (i > 1 and ", " or "") .. missing[i]
                end

                msg = addon.ColorFontString(msg, "RED")

                private:SetOptionTooltip(includeAlts, msg, true)
                includeAlts:SetDescription(msg)
                includeAlts:SetRelativeWidth(0.9)
            end
            includeAlts:SetCallback("OnValueChanged", includeAlts_OnValueChanged)
            includeAlts:SetUserData("NotifyChange", NotifyChangeFuncs.includeAlts)

            local newAltID = AceGUI:Create("InlineGroup")
            newAltID:SetTitle(L["New Alt ID"])
            newAltID:SetFullWidth(true)
            newAltID:SetLayout("Flow")

            local altType = AceGUI:Create("Dropdown")
            altType:SetLabel(L["Type"])
            altType:SetList(private.lists.trackerType)

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
            private:AddChildren(scrollContent, header, objective)
            if #missing == 0 then
                private:AddChildren(scrollContent, includeGuildBank)
            end
            private:AddChildren(scrollContent, includeBank, includeAlts, newAltID, altIDsGroup, deleteTracker)
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
    editor:SetLayout("Fill")
    editor:SetWidth(700)
    editor:SetHeight(600)
    editor:Show()
    editor:ReleaseChildren()
    private.editor = editor

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
