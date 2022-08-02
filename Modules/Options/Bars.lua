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
    elseif group == "appearance" then
        local alpha = AceGUI:Create("Slider")
        alpha:SetSliderValues(0, 1, 0.1)
        alpha:SetLabel(L["Alpha"])

        alpha:SetCallback("OnValueChanged", function(_, _, value)
            private.db.profile.bars[barID].alpha = value
            private.bars[barID]:SetMouseover()
        end)
        alpha:SetUserData("NotifyChange", function()
            alpha:SetValue(barDB.alpha)
        end)

        local scale = AceGUI:Create("Slider")
        scale:SetSliderValues(0.25, 4, .01)
        scale:SetLabel(L["Scale"])

        scale:SetCallback("OnValueChanged", function(_, _, value)
            private.db.profile.bars[barID].scale = value
            private.bars[barID]:SetScale()
        end)
        scale:SetUserData("NotifyChange", function()
            scale:SetValue(barDB.scale)
        end)

        local mouseover = AceGUI:Create("CheckBox")
        mouseover:SetRelativeWidth(0.9)
        mouseover:SetLabel(L["Mouseover"])
        private:SetOptionTooltip(mouseover, L["Show this bar only on mouseover."])
        mouseover:SetDescription(L["Show this bar only on mouseover."])

        mouseover:SetCallback("OnValueChanged", function(_, _, value)
            private.db.profile.bars[barID].mouseover = value
            private.bars[barID]:SetMouseover()
        end)
        mouseover:SetUserData("NotifyChange", function()
            mouseover:SetValue(barDB.mouseover)
        end)

        local showEmpty = AceGUI:Create("CheckBox")
        showEmpty:SetRelativeWidth(0.9)
        showEmpty:SetLabel(L["Show Empty"])
        private:SetOptionTooltip(showEmpty, L["Shows a backdrop on empty buttons."])
        showEmpty:SetDescription(L["Shows a backdrop on empty buttons."])

        showEmpty:SetCallback("OnValueChanged", function(_, _, value)
            private.db.profile.bars[barID].showEmpty = value
            private.bars[barID]:SetMouseover()
        end)
        showEmpty:SetUserData("NotifyChange", function()
            showEmpty:SetValue(barDB.showEmpty)
        end)

        local hidden = AceGUI:Create("MultiLineEditBox")
        hidden:SetFullWidth(true)
        hidden:SetLabel(L["Hidden"])

        -- TODO: Implement OnEnterPressed with function validation

        hidden:SetUserData("NotifyChange", function()
            hidden:SetText(barDB.hidden)
        end)

        -- TODO: Add confirmation for reset
        local resetHidden = AceGUI:Create("Button")
        resetHidden:SetText(L["Reset Hidden"])

        resetHidden:SetCallback("OnClick", function()
            private.db.profile.bars[barID].hidden = private.defaults.bar.hidden
            private:NotifyChange(content)
        end)

        local backdropGroup = AceGUI:Create("InlineGroup")
        backdropGroup:SetTitle(L["Backdrop"])
        backdropGroup:SetFullWidth(true)
        backdropGroup:SetLayout("Flow")

        -- Backdrop >>
        local enableBackdrop = AceGUI:Create("CheckBox")
        enableBackdrop:SetFullWidth(true)
        enableBackdrop:SetLabel(L["Enable"])

        enableBackdrop:SetCallback("OnValueChanged", function(_, _, value)
            private.db.profile.bars[barID].backdrop.enabled = value
            private.bars[barID]:SetBackdrop()
        end)
        enableBackdrop:SetUserData("NotifyChange", function()
            enableBackdrop:SetValue(barDB.backdrop.enabled)
        end)

        local backdrop = AceGUI:Create("LSM30_Background")
        backdrop:SetLabel(L["Background"])
        backdrop:SetList(AceGUIWidgetLSMlists.background)

        backdrop:SetCallback("OnValueChanged", function(_, _, value)
            private.db.profile.bars[barID].backdrop.bgFile.bgFile = value
            private:NotifyChange(backdropGroup)
            private.bars[barID]:SetBackdrop()
        end)
        backdrop:SetUserData("NotifyChange", function()
            backdrop:SetValue(barDB.backdrop.bgFile.bgFile)
        end)

        local bgColor = AceGUI:Create("ColorPicker")
        bgColor:SetLabel(L["Background Color"])
        bgColor:SetHasAlpha(true)

        bgColor:SetCallback("OnValueConfirmed", function(_, _, ...)
            private.db.profile.bars[barID].backdrop.bgColor = { ... }
            private.bars[barID]:SetBackdrop()
        end)
        bgColor:SetCallback("OnValueChanged", function(_, _, ...)
            private.bars[barID].frame:SetBackdropColor(...)
        end)
        bgColor:SetUserData("NotifyChange", function()
            bgColor:SetColor(unpack(barDB.backdrop.bgColor))
        end)

        local border = AceGUI:Create("LSM30_Border")
        border:SetLabel(L["Border"])
        border:SetList(AceGUIWidgetLSMlists.border)

        border:SetCallback("OnValueChanged", function(_, _, value)
            private.db.profile.bars[barID].backdrop.bgFile.edgeFile = value
            private:NotifyChange(backdropGroup)
            private.bars[barID]:SetBackdrop()
        end)
        border:SetUserData("NotifyChange", function()
            border:SetValue(barDB.backdrop.bgFile.edgeFile)
        end)

        local borderColor = AceGUI:Create("ColorPicker")
        borderColor:SetLabel(L["Border Color"])
        borderColor:SetHasAlpha(true)

        borderColor:SetCallback("OnValueChanged", function(_, _, ...)
            private.bars[barID].frame:SetBackdropBorderColor(...)
        end)
        borderColor:SetCallback("OnValueConfirmed", function(_, _, ...)
            private.db.profile.bars[barID].backdrop.borderColor = { ... }
            private.bars[barID]:SetBackdrop()
        end)
        borderColor:SetUserData("NotifyChange", function()
            borderColor:SetColor(unpack(barDB.backdrop.borderColor))
        end)
        -- Backdrop <<

        private:AddChildren(backdropGroup, enableBackdrop, backdrop, bgColor, border, borderColor)
        private:AddChildren(content, alpha, scale, mouseover, showEmpty, hidden, resetHidden, backdropGroup)
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
            { value = "general", text = "General" },
            { value = "appearance", text = "Appearance" },
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
