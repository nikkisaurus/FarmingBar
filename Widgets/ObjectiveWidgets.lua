local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)
local AceGUI = LibStub("AceGUI-3.0")

local lists = {
    condition = {
        ALL = L["All"],
        ANY = L["Any"],
        CUSTOM = L["Custom"],
    },

    iconType = {
        AUTO = L["Auto"],
        FALLBACK = L["Fallback"],
    },

    onUseType = {
        ITEM = L["Item"],
        MACROTEXT = L["Macrotext"],
        NONE = L["None"],
    },

    templates = function()
        local templates = {}
        for templateName, _ in pairs(private.db.global.objectives) do
            templates[templateName] = templateName
        end
        return templates
    end,

    trackerType = {
        ITEM = L["Item"],
        CURRENCY = L["Currency"],
    },
}

local widgets = {
    applyTemplate = function()
        local widget = AceGUI:Create("Dropdown")
        widget:SetLabel(L["Apply Objective Template"])
        return widget
    end,

    icon = function()
        local widget = AceGUI:Create("Icon")
        widget:SetWidth(45)
        widget:SetImageSize(25, 25)
        return widget
    end,

    iconID = function()
        local widget = AceGUI:Create("EditBox")
        widget:SetLabel(L["Fallback Icon"])
        return widget
    end,

    iconType = function()
        local widget = AceGUI:Create("Dropdown")
        widget:SetLabel(L["Icon Type"])
        widget:SetList(lists.iconType)
        return widget
    end,

    onUseGroup = function()
        local widget = AceGUI:Create("InlineGroup")
        widget:SetTitle(L["OnUse"])
        widget:SetFullWidth(true)
        widget:SetLayout("Flow")
        return widget
    end,

    onUseItemID = function()
        local widget = AceGUI:Create("EditBox")
        widget:SetFullWidth(true)
        widget:SetLabel(L["ItemID"])
        return widget
    end,

    onUseItemIDPreview = function()
        local widget = AceGUI:Create("Label")
        widget:SetFullWidth(true)
        widget:SetImageSize(14, 14)
        return widget
    end,

    onUseMacrotext = function()
        local widget = AceGUI:Create("MultiLineEditBox")
        widget:SetFullWidth(true)
        widget:SetLabel(L["Macrotext"])
        return widget
    end,

    onUseType = function()
        local widget = AceGUI:Create("Dropdown")
        widget:SetList(lists.onUseType)
        widget:SetLabel(L["Type"])
        return widget
    end,

    saveTemplate = function()
        local widget = AceGUI:Create("Button")
        widget:SetText(L["Save Template"])
        return widget
    end,

    title = function()
        local widget = AceGUI:Create("EditBox")
        widget:SetRelativeWidth(2 / 3)
        widget:SetLabel(L["Objective Title"])
        return widget
    end,
}

function private:GetObjectiveWidget(widgetType, objectiveInfo)
    local NotifyChangeFuncs = {
        applyTemplate = function(self)
            self:SetList(lists.templates())
            self:SetDisabled(addon.tcount(private.db.global.objectives) == 0)
        end,

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

            addon.CacheItem(itemID, function(itemID, self)
                local itemName, _, _, _, _, _, _, _, _, icon = GetItemInfo(itemID)

                self:SetText(itemName)
                self:SetImage(icon)
            end, itemID, self)
        end,

        onUseMacrotext = function(self)
            self:SetText(objectiveInfo.onUse.macrotext)
            self:SetDisabled(objectiveInfo.onUse.type ~= "MACROTEXT")
        end,

        onUseType = function(self)
            self:SetValue(objectiveInfo.onUse.type)
        end,

        title = function(self)
            self:SetText(objectiveInfo.title)
        end,
    }

    local widget = widgets[widgetType]()
    widget:SetUserData("NotifyChange", NotifyChangeFuncs[widgetType])

    return widget, NotifyChangeFuncs[widgetType]
end
