local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)
local AceGUI = LibStub("AceGUI-3.0")

--[[ Content ]]
local function GetAppearanceContent(barID, barDB, content)
    local displayGroup = AceGUI:Create("InlineGroup")
    displayGroup:SetTitle(L["Display"])
    displayGroup:SetFullWidth(true)
    displayGroup:SetLayout("Flow")

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
    scale:SetSliderValues(0.25, 4, 0.01)
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
    private:SetOptionTooltip(mouseover, L["Show this bar only on mouseover."], true)
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
    private:SetOptionTooltip(showEmpty, L["Shows a backdrop on empty buttons."], true)
    showEmpty:SetDescription(L["Shows a backdrop on empty buttons."])

    showEmpty:SetCallback("OnValueChanged", function(_, _, value)
        private.db.profile.bars[barID].showEmpty = value
        private.bars[barID]:SetMouseover()
    end)
    showEmpty:SetUserData("NotifyChange", function()
        showEmpty:SetValue(barDB.showEmpty)
    end)

    local hidden = AceGUI:Create("FarmingBar_LuaEditBox")
    hidden:SetFullWidth(true)
    hidden:SetLabel(L["Hidden"])

    hidden:Initialize(barDB.hidden, function(_, _, text)
        local err
        local func = loadstring("return " .. text)
        if type(func) == "function" then
            local success, userFunc = pcall(func)
            if success and type(userFunc) == "function" then
                private.db.profile.bars[barID].hidden = text
                private.bars[barID]:SetHidden()
            else
                err = L["Hidden must be a function returning a boolean value."]
            end
        else
            err = L["Hidden must be a function returning a boolean value."]
        end
        private.options:SetStatusText(err)
        private:NotifyChange(content)
    end)

    -- TODO: Implement OnEnterPressed with function validation

    hidden:SetUserData("NotifyChange", function()
        hidden:SetText(barDB.hidden)
    end)

    local resetHidden = AceGUI:Create("Button")
    resetHidden:SetText(L["Reset Hidden"])

    resetHidden:SetCallback("OnClick", function()
        private:ShowConfirmationDialog(L["Are you sure you want to reset this bar's hidden function?"], function()
            private.db.profile.bars[barID].hidden = private.defaults.bar.hidden
            private:NotifyChange(content)
        end)
    end)

    private:AddChildren(displayGroup, alpha, scale, mouseover, showEmpty, hidden, resetHidden)

    local layoutGroup = AceGUI:Create("InlineGroup")
    layoutGroup:SetTitle(L["Layout"])
    layoutGroup:SetFullWidth(true)
    layoutGroup:SetLayout("Flow")

    local barAnchor = AceGUI:Create("Dropdown")
    barAnchor:SetLabel(L["Bar Anchor"])
    barAnchor:SetList({
        TOPLEFT = "TOPLEFT",
        TOPRIGHT = "TOPRIGHT",
        BOTTOMLEFT = "BOTTOMLEFT",
        BOTTOMRIGHT = "BOTTOMRIGHT",
    })

    barAnchor:SetCallback("OnValueChanged", function(_, _, value)
        private.db.profile.bars[barID].barAnchor = value
        private.bars[barID]:SetPoints()
    end)
    barAnchor:SetUserData("NotifyChange", function()
        barAnchor:SetValue(barDB.barAnchor)
    end)

    local buttonGrowth = AceGUI:Create("Dropdown")
    buttonGrowth:SetLabel(L["Button Growth"])
    buttonGrowth:SetList({
        ROW = "ROW",
        COL = "COL",
    })

    buttonGrowth:SetCallback("OnValueChanged", function(_, _, value)
        private.db.profile.bars[barID].buttonGrowth = value
        private.bars[barID]:SetPoints()
    end)
    buttonGrowth:SetUserData("NotifyChange", function()
        buttonGrowth:SetValue(barDB.buttonGrowth)
    end)

    local movable = AceGUI:Create("CheckBox")
    movable:SetRelativeWidth(0.9)
    movable:SetLabel(L["Movable"])

    movable:SetCallback("OnValueChanged", function(_, _, value)
        private.db.profile.bars[barID].movable = value
        private.bars[barID]:SetMovable()
    end)
    movable:SetUserData("NotifyChange", function()
        movable:SetValue(barDB.movable)
    end)

    private:AddChildren(layoutGroup, barAnchor, buttonGrowth, movable)

    local buttonsGroup = AceGUI:Create("InlineGroup")
    buttonsGroup:SetTitle(L["Buttons"])
    buttonsGroup:SetFullWidth(true)
    buttonsGroup:SetLayout("Flow")

    local numButtons = AceGUI:Create("Slider")
    numButtons:SetSliderValues(1, private.defaults.maxButtons, 1)
    numButtons:SetLabel(L["Buttons"])

    numButtons:SetCallback("OnValueChanged", function(_, _, value)
        private.db.profile.bars[barID].numButtons = value
        private.bars[barID]:DrawButtons()
        private.bars[barID]:LayoutButtons()
    end)
    numButtons:SetUserData("NotifyChange", function()
        numButtons:SetValue(barDB.numButtons)
    end)

    local buttonsPerAxis = AceGUI:Create("Slider")
    buttonsPerAxis:SetSliderValues(1, private.defaults.maxButtons, 1)
    buttonsPerAxis:SetLabel(L["Buttons Per Axis"])

    buttonsPerAxis:SetCallback("OnValueChanged", function(_, _, value)
        private.db.profile.bars[barID].buttonsPerAxis = value
        private.bars[barID]:SetPoints()
    end)
    buttonsPerAxis:SetUserData("NotifyChange", function()
        buttonsPerAxis:SetValue(barDB.buttonsPerAxis)
    end)

    local buttonPadding = AceGUI:Create("Slider")
    buttonPadding:SetSliderValues(private.defaults.minPadding, private.defaults.maxPadding, 1)
    buttonPadding:SetLabel(L["Button Padding"])

    buttonPadding:SetCallback("OnValueChanged", function(_, _, value)
        private.db.profile.bars[barID].buttonPadding = value
        private.bars[barID]:SetPoints()
    end)
    buttonPadding:SetUserData("NotifyChange", function()
        buttonPadding:SetValue(barDB.buttonPadding)
    end)

    local buttonSize = AceGUI:Create("Slider")
    buttonSize:SetSliderValues(private.defaults.minButtonSize, private.defaults.maxButtonSize, 1)
    buttonSize:SetLabel(L["Button Size"])

    buttonSize:SetCallback("OnValueChanged", function(_, _, value)
        private.db.profile.bars[barID].buttonSize = value
        private.bars[barID]:SetPoints()
    end)
    buttonSize:SetUserData("NotifyChange", function()
        buttonSize:SetValue(barDB.buttonSize)
    end)

    private:AddChildren(buttonsGroup, numButtons, buttonsPerAxis, buttonPadding, buttonSize)
    private:AddChildren(content, displayGroup, layoutGroup, buttonsGroup)
end

local function GetGeneralContent(barID, barDB, content)
    local label = AceGUI:Create("EditBox")
    label:SetLabel(L["Label"])
    label:SetFullWidth(true)
    label:SetUserData("NotifyChange", function()
        label:SetText(barDB.label)
    end)

    local limitMats = AceGUI:Create("CheckBox")
    limitMats:SetRelativeWidth(0.9)
    limitMats:SetLabel(L["Limit Mats"])
    private:SetOptionTooltip(
        limitMats,
        L["Objectives on this bar cannot use materials already accounted for by another objective on the same bar."],
        true
    )
    limitMats:SetDescription(
        L["Objectives on this bar cannot use materials already accounted for by another objective on the same bar."]
    )

    limitMats:SetCallback("OnValueChanged", function(_, _, value)
        private.db.profile.bars[barID].limitMats = value
    end)
    limitMats:SetUserData("NotifyChange", function()
        limitMats:SetValue(barDB.limitMats)
    end)

    local alertsGroup = AceGUI:Create("InlineGroup")
    alertsGroup:SetTitle(L["Alerts"])
    alertsGroup:SetFullWidth(true)

    local barProgress = AceGUI:Create("CheckBox")
    barProgress:SetRelativeWidth(0.9)
    barProgress:SetLabel(L["Bar Progress"])
    private:SetOptionTooltip(barProgress, L["Track the number of completed objectives on this bar."], true)
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
    private:SetOptionTooltip(completedObjectives, L["Continue tracking objectives after completed."], true)
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
    private:SetOptionTooltip(muteAll, L["Mute all alerts on this bar."], true)
    muteAll:SetDescription(L["Mute all alerts on this bar."])

    muteAll:SetCallback("OnValueChanged", function(_, _, value)
        private.db.profile.bars[barID].alerts.muteAll = value
    end)
    muteAll:SetUserData("NotifyChange", function()
        muteAll:SetValue(barDB.alerts.muteAll)
    end)

    private:AddChildren(alertsGroup, barProgress, completedObjectives, muteAll)
    private:AddChildren(content, label, limitMats, alertsGroup)
end

local function GetSkinsContent(barID, barDB, content)
    local backdropGroup = AceGUI:Create("InlineGroup")
    backdropGroup:SetTitle(L["Backdrop"])
    backdropGroup:SetFullWidth(true)
    backdropGroup:SetLayout("Flow")

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
        private.bars[barID].anchor:SetBackdropColor(...)
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
        private.bars[barID].anchor:SetBackdropBorderColor(...)
    end)
    borderColor:SetCallback("OnValueConfirmed", function(_, _, ...)
        private.db.profile.bars[barID].backdrop.borderColor = { ... }
        private.bars[barID]:SetBackdrop()
    end)
    borderColor:SetUserData("NotifyChange", function()
        borderColor:SetColor(unpack(barDB.backdrop.borderColor))
    end)

    private:AddChildren(backdropGroup, enableBackdrop, backdrop, bgColor, border, borderColor)
    private:AddChildren(content, backdropGroup)

    if private.MSQ then
        local MSQWarning = AceGUI:Create("Label")
        MSQWarning:SetFullWidth(true)
        MSQWarning:SetColor(1, 0, 0)
        MSQWarning:SetText(
            L["Button textures may be controlled by Masque and must be disabled through its settings for these to be applied."]
        )

        private:AddChildren(content, MSQWarning)
    end

    local buttonTextureGroup = AceGUI:Create("DropdownGroup")
    buttonTextureGroup:SetTitle(L["Button Textures"])
    buttonTextureGroup:SetFullWidth(true)
    buttonTextureGroup:SetLayout("Flow")
    buttonTextureGroup:SetGroupList({
        backdrop = "BACKDROP",
        gloss = "GLOSS",
        highlight = "HIGHLIGHT",
        icon = "ICON",
        iconBorder = "ICONBORDER",
        normal = "NORMAL",
        pushed = "PUSHED",
        shadow = "SHADOW",
    })
    buttonTextureGroup:SetGroup()

    buttonTextureGroup:SetCallback("OnGroupSelected", function(self, _, layerName)
        self:ReleaseChildren()

        local texture = AceGUI:Create("LSM30_Background")
        texture:SetLabel(L["Texture"])
        texture:SetList(AceGUIWidgetLSMlists.background)

        texture:SetCallback("OnValueChanged", function(_, _, value)
            private.db.profile.bars[barID].buttonTextures[layerName].texture = value
            private:NotifyChange(self)
            private.bars[barID]:UpdateButtonTextures()
        end)
        texture:SetUserData("NotifyChange", function()
            texture:SetValue(barDB.buttonTextures[layerName].texture)
        end)

        local blendMode = AceGUI:Create("Dropdown")
        blendMode:SetLabel(L["Blend Mode"])
        blendMode:SetList({
            DISABLE = "DISABLE",
            BLEND = "BLEND",
            ALPHAKEY = "ALPHAKEY",
            ADD = "ADD",
            MOD = "MOD",
        })

        blendMode:SetCallback("OnValueChanged", function(_, _, value)
            private.db.profile.bars[barID].buttonTextures[layerName].blendMode = value
            private.bars[barID]:UpdateButtonTextures()
        end)
        blendMode:SetUserData("NotifyChange", function()
            blendMode:SetValue(barDB.buttonTextures[layerName].blendMode)
        end)

        local drawLayer = AceGUI:Create("Dropdown")
        drawLayer:SetLabel(L["Draw Layer"])
        drawLayer:SetList({
            BACKGROUND = "BACKGROUND",
            BORDER = "BORDER",
            ARTWORK = "ARTWORK",
            OVERLAY = "OVERLAY",
            HIGHLIGHT = "HIGHLIGHT",
        })

        drawLayer:SetCallback("OnValueChanged", function(_, _, value)
            private.db.profile.bars[barID].buttonTextures[layerName].drawLayer = value
            private.bars[barID]:UpdateButtonTextures()
        end)
        drawLayer:SetUserData("NotifyChange", function()
            drawLayer:SetValue(barDB.buttonTextures[layerName].drawLayer)
        end)

        local layer = AceGUI:Create("Slider")
        layer:SetSliderValues(-8, 7, 1)
        layer:SetLabel(L["Layer"])

        layer:SetCallback("OnValueChanged", function(_, _, value)
            private.db.profile.bars[barID].buttonTextures[layerName].layer = value
            private.bars[barID]:UpdateButtonTextures()
        end)
        layer:SetUserData("NotifyChange", function()
            layer:SetValue(barDB.buttonTextures[layerName].layer)
        end)

        local textureColor = AceGUI:Create("ColorPicker")
        textureColor:SetLabel(L["Color"])
        textureColor:SetHasAlpha(true)

        textureColor:SetCallback("OnValueChanged", function(_, _, ...)
            for _, button in pairs(private.bars[barID]:GetButtons()) do
                button[layerName]:SetVertexColor(...)
            end
        end)
        textureColor:SetCallback("OnValueConfirmed", function(_, _, ...)
            private.db.profile.bars[barID].buttonTextures[layerName].color = { ... }
            private.bars[barID]:UpdateButtonTextures()
        end)
        textureColor:SetUserData("NotifyChange", function()
            textureColor:SetColor(unpack(barDB.buttonTextures[layerName].color))
        end)

        local hidden = AceGUI:Create("CheckBox")
        hidden:SetLabel(L["Hidden"])

        hidden:SetCallback("OnValueChanged", function(_, _, value)
            private.db.profile.bars[barID].buttonTextures[layerName].hidden = value
            private.bars[barID]:UpdateButtonTextures()
        end)
        hidden:SetUserData("NotifyChange", function()
            hidden:SetValue(barDB.buttonTextures[layerName].hidden)
        end)

        local texCoords = AceGUI:Create("InlineGroup")
        texCoords:SetTitle(L["TexCoords"])
        texCoords:SetFullWidth(true)
        texCoords:SetLayout("Flow")

        for i = 1, 4 do
            local texCoord = AceGUI:Create("Slider")
            texCoord:SetSliderValues(0, 1, 0.01)
            texCoord:SetLabel(L.GetTexCoordID(i))

            texCoord:SetCallback("OnValueChanged", function(_, _, value)
                private.db.profile.bars[barID].buttonTextures[layerName].texCoords[i] = value
                private.bars[barID]:UpdateButtonTextures()
            end)
            texCoord:SetUserData("NotifyChange", function()
                texCoord:SetValue(barDB.buttonTextures[layerName].texCoords[i])
            end)

            private:AddChildren(texCoords, texCoord)
        end

        local insets = AceGUI:Create("InlineGroup")
        insets:SetTitle(L["Insets"])
        insets:SetFullWidth(true)
        insets:SetLayout("Flow")

        for i = 1, 4 do
            local insetID = L.GetTexCoordID(i)
            local inset = AceGUI:Create("Slider")
            inset:SetSliderValues(-10, 10, 1)
            inset:SetLabel(insetID)

            inset:SetCallback("OnValueChanged", function(_, _, value)
                private.db.profile.bars[barID].buttonTextures[layerName].insets[strlower(insetID)] = value
                private.bars[barID]:UpdateButtonTextures()
            end)
            inset:SetUserData("NotifyChange", function()
                inset:SetValue(barDB.buttonTextures[layerName].insets[strlower(insetID)])
            end)

            private:AddChildren(insets, inset)
        end

        local reset = AceGUI:Create("Button")
        reset:SetText(L["Reset to Default"])

        reset:SetCallback("OnClick", function()
            private:ShowConfirmationDialog(L["Are you sure you want to reset this texture?"], function()
                private.db.profile.bars[barID].buttonTextures[layerName] =
                    addon.CloneTable(private.defaults.bar.buttonTextures[layerName])
                private:NotifyChange(self)
                private.bars[barID]:UpdateButtonTextures()
            end)
        end)

        if layerName == "icon" then
            private:AddChildren(self, blendMode, drawLayer, layer, textureColor, texCoords, insets, reset)
        elseif layerName == "iconBorder" then
            private:AddChildren(self, texture, blendMode, drawLayer, layer, hidden, texCoords, insets, reset)
        else
            private:AddChildren(
                self,
                texture,
                blendMode,
                drawLayer,
                layer,
                textureColor,
                hidden,
                texCoords,
                insets,
                reset
            )
        end
        private:NotifyChange(self)
        content:DoLayout()
    end)

    private:AddChildren(content, buttonTextureGroup)
end

local function GetManageContent(barID, barDB, content) end

--[[ Callbacks ]]
local function tabGroup_OnGroupSelected(tabGroup, _, group)
    local barID = tabGroup:GetUserData("barID")
    local barDB = private.db.profile.bars[barID]
    local content = tabGroup:GetUserData("scrollContent")

    content:ReleaseChildren()

    if group == "general" then
        GetGeneralContent(barID, barDB, content)
    elseif group == "appearance" then
        GetAppearanceContent(barID, barDB, content)
    elseif group == "skins" then
        GetSkinsContent(barID, barDB, content)
    elseif group == "manage" then
        GetManageContent(barID, barDB, content)
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
            { value = "general", text = L["General"] },
            { value = "appearance", text = L["Appearance"] },
            { value = "skins", text = L["Skins"] },
            { value = "manage", text = L["Manage"] },
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
        tabGroup:SelectTab("general")
    end
end
