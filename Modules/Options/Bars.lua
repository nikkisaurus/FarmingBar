local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)
local AceGUI = LibStub("AceGUI-3.0")

--[[ Callbacks ]]
local function tabGroup_OnGroupSelected(tabGroup, _, group)
    local barID = tabGroup:GetUserData("barID")
    local barDB = private.db.profile.bars[barID]
    local content = tabGroup:GetUserData("scrollContent")

    content:ReleaseChildren()

    if group == "general" then
        local label = AceGUI:Create("EditBox")
        label:SetLabel(L["Label"])
        label:SetFullWidth(true)
        label:SetUserData("NotifyChange", function()
            label:SetText(barDB.label)
        end)

        local alertsGroup = AceGUI:Create("InlineGroup")
        alertsGroup:SetTitle(L["Alerts"])
        alertsGroup:SetFullWidth(true)

        -- Alerts >>
        local barProgress = AceGUI:Create("CheckBox")
        barProgress:SetRelativeWidth(0.9)
        barProgress:SetLabel(L["Bar Progress"])
        private:SetOptionTooltip(barProgress, L["Track the number of completed objectives on this bar."])
        barProgress:SetDescription(L["Track the number of completed objectives on this bar."])

        barProgress:SetCallback("OnValueChanged", function(_, _, value)
            private.db.profile.bars[barID].alerts.barProgress = value
        end)
        barProgress:SetUserData("NotifyChange", function()
            barProgress:SetValue(barDB.alerts.barProgress)
        end)

        local completedObjectives = AceGUI:Create("CheckBox")
        completedObjectives:SetRelativeWidth(0.9)
        completedObjectives:SetLabel(L["Completed Objectives"])
        private:SetOptionTooltip(completedObjectives, L["Continue tracking objectives after completed."])
        completedObjectives:SetDescription(L["Continue tracking objectives after completed."])

        completedObjectives:SetCallback("OnValueChanged", function(_, _, value)
            private.db.profile.bars[barID].alerts.completedObjectives = value
        end)
        completedObjectives:SetUserData("NotifyChange", function()
            completedObjectives:SetValue(barDB.alerts.completedObjectives)
        end)

        local muteAll = AceGUI:Create("CheckBox")
        muteAll:SetRelativeWidth(0.9)
        muteAll:SetLabel(L["Mute All"])
        private:SetOptionTooltip(muteAll, L["Mute all alerts on this bar."])
        muteAll:SetDescription(L["Mute all alerts on this bar."])

        muteAll:SetCallback("OnValueChanged", function(_, _, value)
            private.db.profile.bars[barID].alerts.muteAll = value
        end)
        muteAll:SetUserData("NotifyChange", function()
            muteAll:SetValue(barDB.alerts.muteAll)
        end)

        private:AddChildren(alertsGroup, barProgress, completedObjectives, muteAll)
        -- Alerts <<

        local limitMats = AceGUI:Create("CheckBox")
        limitMats:SetRelativeWidth(0.9)
        limitMats:SetLabel(L["Limit Mats"])
        private:SetOptionTooltip(limitMats,
            L["Objectives on this bar cannot use materials already accounted for by another objective on the same bar."])
        limitMats:SetDescription(L[
            "Objectives on this bar cannot use materials already accounted for by another objective on the same bar."])

        limitMats:SetCallback("OnValueChanged", function(_, _, value)
            private.db.profile.bars[barID].limitMats = value
        end)
        limitMats:SetUserData("NotifyChange", function()
            limitMats:SetValue(barDB.limitMats)
        end)

        private:AddChildren(content, label, alertsGroup, limitMats)
    end

    private:NotifyChange(content)
end

--[[ Options ]]
function private:GetBarsOptions(treeGroup, subgroup)
    if subgroup then
        treeGroup:SetLayout("Fill")

        local tabGroup = AceGUI:Create("TabGroup")
        tabGroup:SetLayout("Fill")
        tabGroup:SetTabs({
            { value = "general", text = "General" }, -- limitMats, alerts, label
            { value = "appearance", text = "Appearance" }, -- backdrop, hidden, mouseover, alpha, scale
            { value = "layout", text = "Layout" }, -- movable, point, buttonGrowth, barAnchor
            { value = "buttons", text = "Buttons" }, --buttontexture, numButtons, buttonsPerAxis, buttonSize, buttonPadding
        })
        tabGroup:SetUserData("barID", tonumber(gsub(subgroup, "bar", "") or ""))
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
    end
end
