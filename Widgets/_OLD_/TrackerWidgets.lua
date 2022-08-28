local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)
local AceGUI = LibStub("AceGUI-3.0")

local lists = {}

--[[ Menus ]]
local function GetTrackerMenu(objectiveInfo)
    local menu = {
        {
            value = "trackers",
            text = L["Trackers"],
        },
    }

    local numTrackers = addon.tcount(objectiveInfo.trackers)

    if numTrackers > 0 then
        menu[1].children = {}
    end

    for trackerKey, trackerInfo in addon.pairs(objectiveInfo.trackers) do
        private:CacheItem(trackerKey)
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

local widgets = {
    addTrackerGroup = function()
        local widget = AceGUI:Create("InlineGroup")
        widget:SetTitle(L["New Tracker"])
        widget:SetFullWidth(true)
        widget:SetLayout("Flow")
        return widget
    end,

    altID = function()
        local widget = AceGUI:Create("EditBox")
        widget:SetLabel(L["Currency/Item ID"])
        return widget
    end,

    altIDsGroup = function()
        local widget = AceGUI:Create("InlineGroup")
        widget:SetTitle(L["Alt IDs"])
        widget:SetFullWidth(true)
        widget:SetLayout("Flow")
        return widget
    end,

    altIDsList = function()
        local widget = AceGUI:Create("SimpleGroup")
        widget:SetFullWidth(true)
        widget:SetLayout("Flow")
        return widget
    end,

    altType = function()
        local widget = AceGUI:Create("Dropdown")
        widget:SetLabel(L["Type"])
        widget:SetList(private.lists.trackerType)
        return widget
    end,

    condition = function()
        local widget = AceGUI:Create("Dropdown")
        widget:SetLabel(L["Condition"])
        widget:SetList(private.lists.condition)
        return widget
    end,

    conditionFunc = function()
        local widget = AceGUI:Create("FarmingBar_LuaEditBox")
        widget:SetFullWidth(true)
        widget:SetLabel(L["Custom Condition"])
        return widget
    end,

    deleteTracker = function()
        local widget = AceGUI:Create("Button")
        widget:SetText(DELETE)
        return widget
    end,

    dependencies = function()
        local widget = AceGUI:Create("Label")
        widget:SetFullWidth(true)
        widget:SetColor(1, 0, 0)
        return widget
    end,

    header = function()
        local widget = AceGUI:Create("Label")
        widget:SetFullWidth(true)
        widget:SetFontObject(GameFontNormal)
        widget:SetColor(1, 0.82, 0)
        widget:SetImageSize(14, 14)
        return widget
    end,

    includeAlts = function()
        local widget = AceGUI:Create("CheckBox")
        widget:SetLabel(L["Include Alts"])
        return widget
    end,

    includeBank = function()
        local widget = AceGUI:Create("CheckBox")
        widget:SetLabel(L["Include Bank"])
        return widget
    end,

    includeGuildBank = function()
        local widget = AceGUI:Create("Dropdown")
        widget:SetList(private:GetGuildsList())
        widget:SetLabel(L["Include Guild Bank"])
        widget:SetMultiselect(true)
        return widget
    end,

    label = function()
        local widget = AceGUI:Create("Label")
        widget:SetRelativeWidth(11 / 16)
        widget:SetImageSize(14, 14)
        return widget
    end,

    labelTxt = function()
        local widget = AceGUI:Create("Label")
        widget:SetColor(1, 0.82, 0)
        widget:SetRelativeWidth(11 / 16)
        widget:SetText(L["Item/Currency Name"])
        return widget
    end,

    multiplier = function()
        local widget = AceGUI:Create("EditBox")
        widget:SetRelativeWidth(4 / 16)
        widget:SetUserData("altKey", altKey)
        return widget
    end,

    multiplierTxt = function()
        local widget = AceGUI:Create("Label")
        widget:SetColor(1, 0.82, 0)
        widget:SetRelativeWidth(4 / 16)
        widget:SetText(L["Multiplier"])
        return widget
    end,

    newAltID = function()
        local widget = AceGUI:Create("InlineGroup")
        widget:SetTitle(L["New Alt ID"])
        widget:SetFullWidth(true)
        widget:SetLayout("Flow")
        return widget
    end,

    objective = function()
        local widget = AceGUI:Create("EditBox")
        widget:SetLabel(L["Objective"])
        return widget
    end,

    remove = function()
        local widget = AceGUI:Create("InteractiveLabel")
        widget:SetRelativeWidth(1 / 16)
        widget:SetText("X")
        return widget
    end,

    removeTxt = function()
        local widget = AceGUI:Create("Label")
        widget:SetColor(1, 0.82, 0)
        widget:SetRelativeWidth(1 / 16)
        widget:SetText(" ")
        return widget
    end,

    trackerID = function()
        local widget = AceGUI:Create("EditBox")
        widget:SetLabel(L["Currency/Item ID"])
        return widget
    end,

    trackerTree = function()
        local widget = AceGUI:Create("TreeGroup")
        widget:SetFullWidth(true)
        widget:SetLayout("Fill")

        local scrollContainer = AceGUI:Create("SimpleGroup")
        scrollContainer:SetFullWidth(true)
        scrollContainer:SetLayout("Fill")
        widget:AddChild(scrollContainer)

        local scrollContent = AceGUI:Create("ScrollFrame")
        scrollContent:SetLayout("Flow")
        scrollContainer:AddChild(scrollContent)
        widget:SetUserData("scrollContent", scrollContent)

        return widget
    end,

    trackerType = function()
        local widget = AceGUI:Create("Dropdown")
        widget:SetLabel(L["Type"])
        widget:SetList(private.lists.trackerType)
        return widget
    end,
}

function private:GetTrackerWidgets(widgetType, objectiveInfo, trackerKey)
    local trackerInfo = objectiveInfo.trackers[trackerKey]
    local trackerName = trackerInfo and private:GetObjectiveTemplateTrackerName(trackerInfo.type, trackerInfo.id) or {}

    local NotifyChangeFuncs = {
        dependencies = function(self)
            local missing = private:GetMissingDataStoreModules()
            local msg = ""
            if #missing > 0 then
                msg = L["Missing dependencies"] .. ": "

                for i = 1, #missing do
                    msg = msg .. (i > 1 and ", " or "") .. missing[i]
                end

                -- msg = addon.ColorFontString(msg, "RED")
            end
            self:SetText(msg)
            self.parent:DoLayout()
        end,

        header = function(self)
            self:SetText(trackerName)
            self:SetImage(private:GetObjectiveTemplateTrackerIcon(trackerInfo.type, trackerInfo.id))
        end,

        label = function(self)
            local altInfo = self:GetUserData("altInfo")
            self:SetText(private:GetObjectiveTemplateTrackerName(altInfo.type, altInfo.id))
            self:SetImage(private:GetObjectiveTemplateTrackerIcon(altInfo.type, altInfo.id))
        end,

        multiplier = function(self)
            self:SetText(self:GetUserData("altInfo").multiplier)
        end,

        trackerTree = function(self)
            self:SetTree(GetTrackerMenu(objectiveInfo))
        end,

        -- altIDsList = function(self)
        --     self:ReleaseChildren()

        --     for altKey, altInfo in addon.pairs(trackerInfo.altIDs) do
        --         local remove = AceGUI:Create("InteractiveLabel")
        --         remove:SetRelativeWidth(1 / 16)
        --         remove:SetText("X")
        --         remove:SetUserData("altKey", altKey)

        --         local label = AceGUI:Create("Label")
        --         label:SetRelativeWidth(11 / 16)
        --         label:SetImageSize(14, 14)
        --         label:SetUserData("NotifyChange", function(self)
        --             self:SetText(private:GetObjectiveTemplateTrackerName(altInfo.type, altInfo.id))
        --             self:SetImage(private:GetObjectiveTemplateTrackerIcon(altInfo.type, altInfo.id))
        --         end)

        --         local multiplier = AceGUI:Create("EditBox")
        --         multiplier:SetRelativeWidth(4 / 16)
        --         multiplier:SetUserData("altKey", altKey)

        --         multiplier:SetUserData("NotifyChange", function(self)
        --             self:SetText(altInfo.multiplier)
        --         end)

        --         -- Add children
        --         private:AddChildren(self, remove, label, multiplier)
        --     end

        --     self.parent.parent:DoLayout()
        -- end,

        -- altIDsGroup = function(self)
        --     self:ReleaseChildren()

        --     -- Callback

        --     -- Widgets
        --     local removeTxt = AceGUI:Create("Label")
        --     removeTxt:SetColor(1, 0.82, 0)
        --     removeTxt:SetRelativeWidth(1 / 16)
        --     removeTxt:SetText(" ")

        --     local labelTxt = AceGUI:Create("Label")
        --     labelTxt:SetColor(1, 0.82, 0)
        --     labelTxt:SetRelativeWidth(11 / 16)
        --     labelTxt:SetText(L["Item/Currency Name"])

        --     local multiplierTxt = AceGUI:Create("Label")
        --     multiplierTxt:SetColor(1, 0.82, 0)
        --     multiplierTxt:SetRelativeWidth(4 / 16)
        --     multiplierTxt:SetText(L["Multiplier"])

        --     -- Add children
        --     if #trackerInfo.altIDs > 0 then
        --         private:AddChildren(self, removeTxt, labelTxt, multiplierTxt)
        --     end

        --     for altKey, altInfo in addon.pairs(trackerInfo.altIDs) do
        --         local remove = AceGUI:Create("InteractiveLabel")
        --         remove:SetRelativeWidth(1 / 16)
        --         remove:SetText("X")
        --         remove:SetCallback("OnClick", remove_OnClick)
        --         remove:SetUserData("altKey", altKey)

        --         local label = AceGUI:Create("Label")
        --         label:SetRelativeWidth(11 / 16)
        --         label:SetImageSize(14, 14)
        --         label:SetUserData("NotifyChange", function(self)
        --             self:SetText(private:GetObjectiveTemplateTrackerName(altInfo.type, altInfo.id))
        --             self:SetImage(private:GetObjectiveTemplateTrackerIcon(altInfo.type, altInfo.id))
        --         end)

        --         local multiplier = AceGUI:Create("EditBox")
        --         multiplier:SetRelativeWidth(4 / 16)
        --         multiplier:SetCallback("OnEnterPressed", multiplier_OnEnterPressed)
        --         multiplier:SetUserData("altKey", altKey)
        --         multiplier:SetUserData("NotifyChange", function(self)
        --             self:SetText(altInfo.multiplier)
        --         end)

        --         -- Add children
        --         private:AddChildren(self, remove, label, multiplier)
        --     end

        --     scrollContent:DoLayout()
        -- end,

        condition = function(self)
            self:SetValue(objectiveInfo.condition.type)
        end,

        conditionFunc = function(self)
            self:SetText(objectiveInfo.condition.func)
            self:SetDisabled(objectiveInfo.condition.type ~= "CUSTOM")
        end,

        includeAlts = function(self)
            self:SetValue(trackerInfo.includeAlts)
            self:SetDisabled(private:MissingDataStore())
        end,

        includeBank = function(self)
            self:SetValue(trackerInfo.includeBank)
        end,

        includeGuildBank = function(self)
            for guild, enabled in pairs(trackerInfo.includeGuildBank) do
                self:SetItemValue(guild, enabled)
            end
            self:SetDisabled(private:MissingDataStore())
        end,

        objective = function(self)
            self:SetText(trackerInfo.objective)
        end,
    }

    local widget = widgets[widgetType]()
    widget:SetUserData("NotifyChange", NotifyChangeFuncs[widgetType])

    return widget
end

function private:ValidateTracker(info)
    local widgetType = info.widgetType -- button, template
    local trackerType = info.trackerType -- tracker, altID

    local widget = info.widget
    local frame = info.frame

    local objectiveInfo = info.objectiveInfo
    local trackerKey = info.trackerKey

    local pendingType = info.pendingType
    local id = info.id

    local subgroup
    if pendingType then
        local validID = pendingType == "ITEM" and private:ValidateItem(id)
            or pendingType == "CURRENCY" and private:ValidateCurrency(id)

        if validID then
            local exists, barID, buttonID, button
            if widgetType == "template" then
                exists = trackerType == "tracker"
                        and private:ObjectiveTemplateTrackerExists(objectiveInfo.title, pendingType, validID)
                    or trackerType == "altID"
                        and private:ObjectiveTemplateTrackerAltIDExists(
                            objectiveInfo.title,
                            trackerKey,
                            pendingType,
                            validID
                        )
            elseif widgetType == "button" then
                barID = widget:GetUserData("barID")
                buttonID = widget:GetUserData("buttonID")
                button = private.bars[barID]:GetButtons()[buttonID]
                exists = trackerType == "tracker" and button:TrackerExists(pendingType, validID)
                    or trackerType == "altID" and button:TrackerAltIDExists(trackerKey, pendingType, validID)
            end

            if not exists then
                if widgetType == "template" then
                    if trackerType == "tracker" then
                        subgroup = private:AddObjectiveTemplateTracker(objectiveInfo.title, pendingType, validID)
                        local itemName = private:GetObjectiveTemplateTrackerName(pendingType, validID)
                    elseif trackerType == "altID" then
                        subgroup = private:AddObjectiveTemplateTrackerAltID(
                            objectiveInfo.title,
                            trackerKey,
                            pendingType,
                            validID
                        )
                    end
                elseif widgetType == "button" then
                    if trackerType == "tracker" then
                        subgroup = button:AddTracker(pendingType, validID)
                    elseif trackerType == "altID" then
                        button:AddTrackerAltID(trackerKey, pendingType, validID)
                    end
                end

                widget:SetText()
            else
                frame:SetStatusText(L["Invalid input: duplicate entry."])
                widget:HighlightText()
            end
        else
            frame:SetStatusText(L["Invalid item/currency ID."])
            widget:HighlightText()
        end
    else
        frame:SetStatusText(L["Please select type: item or currency."])
    end

    widget:ClearFocus()
    return subgroup
end
