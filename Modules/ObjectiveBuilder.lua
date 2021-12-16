local addonName = ...
local U = LibStub("LibAddonUtils-1.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)
local addon = LibStub("AceAddon-3.0"):GetAddon(L.addonName)
local AceGUI = LibStub("AceGUI-3.0")

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function addon:CreateObjectiveBuilder()
    local container = AceGUI:Create("Frame")
    container:SetWidth(400)
    container:SetHeight(525)
    container:SetTitle(L._ObjectiveBuilder("title"))
    container:SetLayout("Fill")
    container:Hide()

    addon:CreateObjectiveIconSelector()

    _G["FarmingBarObjectiveBuilderFrame"] = container.frame
    tinsert(UISpecialFrames, "FarmingBarObjectiveBuilderFrame")

    self.ObjectiveBuilder = container

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    local frame = AceGUI:Create("ScrollFrame")
    frame:SetLayout("Flow")
    container:AddChild(frame)

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    local groupDropdown = AceGUI:Create("DropdownGroup")
    groupDropdown:SetFullWidth(true)
    groupDropdown:SetDropdownWidth(200)
    groupDropdown:SetLayout("Flow")

    groupDropdown:SetGroupList({
        --@retail@
        currency = L["Currency"],
        --@end-retail@
        item = L["Item"],
        mixedItems = L["Mixed Items"],
        shoppingList = L["Shopping List"],
    })

    function groupDropdown:DrawContainer(group)
        if group == "currency" then
            addon:DrawCurrencyGroup(self)
        elseif group == "item" then
            addon:DrawItemGroup(self)
        elseif group == "mixedItems" then
            addon:DrawMixedItemsGroup(self)
        elseif group == "shoppingList" then
            addon:DrawShoppingListGroup(self)
        end
    end

    groupDropdown:SetCallback("OnGroupSelected", function(self, _, group)
        self:ReleaseChildren()
        self:DrawContainer(group)
    end)

    frame:AddChild(groupDropdown)

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- Load function

    function container:Load(button)
        self.button = button
        self:SetStatusText(string.format(L["Button ID"] .. " %s:%s", button:GetBar().id, button.id))

        groupDropdown:SetGroup(button.objective and button.objective.type)
        frame:DoLayout()

        self:Show()
    end
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function addon:CreateObjectiveIconSelector()
    --@retail@
    local InterfaceIcons = self:GetFileDataRetail()
    --@end-retail@

    --[===[@non-retail@
    local InterfaceIcons = self:GetFileDataClassic()
    --@end-non-retail@]===]

    local container = AceGUI:Create("Frame")
    container:SetWidth(600)
    container:SetHeight(425)
    container:SetTitle("Farming Bar Objective Icon Selector")
    container:SetLayout("Fill")
    container:Hide()

    _G["FarmingBarObjectiveIconSelectorFrame"] = container.frame
    tinsert(UISpecialFrames, "FarmingBarObjectiveIconSelectorFrame")

    self.ObjectiveIconSelector = container

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    local frame = AceGUI:Create("ScrollFrame")
    frame:SetLayout("Flow")
    container:AddChild(frame)

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- Interface

    local previewLabel, searchEditBox, pageLabel, iconsGroupScrollFrame, iconsGroupScrollChild, firstButton, prevButton, nextButton, lastButton, chooseButton

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    previewLabel = AceGUI:Create("Label")
    previewLabel:SetFullWidth(true)
    previewLabel:SetImageSize(30, 30)

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    searchEditBox = AceGUI:Create("EditBox")
    searchEditBox:SetFullWidth(true)
    searchEditBox:SetLabel(L["Search"])

    local icons = {}

    searchEditBox:SetCallback("OnTextChanged", function(self, _, text)
        iconsGroupScrollChild:LoadPage(iconsGroupScrollChild.page)
    end)

    searchEditBox:SetCallback("OnEnterPressed", function(self)
        if IsControlKeyDown() then
            chooseButton:Click()
        else
            self:ClearFocus()
        end
    end)

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    pageLabel = AceGUI:Create("Label")
    pageLabel:SetText(L["Page"])
    pageLabel:SetColor(1, .82, 0)

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    iconsGroupScrollFrame = AceGUI:Create("SimpleGroup")
    iconsGroupScrollFrame:SetFullWidth(true)
    iconsGroupScrollFrame:SetHeight(200)
    iconsGroupScrollFrame:SetLayout("Fill")

    iconsGroupScrollChild = AceGUI:Create("ScrollFrame")
    iconsGroupScrollChild:SetLayout("Flow")
    iconsGroupScrollFrame:AddChild(iconsGroupScrollChild)

    function iconsGroupScrollChild:LoadPage(page)
        local searchTxt = searchEditBox:GetText()

        wipe(icons)
        for k, v in pairs(InterfaceIcons) do
            if searchTxt == "" or strfind(strlower(v), strlower(searchTxt)) then
                tinsert(icons, k)
            end
        end

        self.maxPages = ceil(#icons / 500) > 0 and ceil(#icons / 500) or 1
        self.page = page <= self.maxPages and page or self.maxPages
        pageLabel:SetText(string.format(L["Page"] .. " %d/%d", self.page, self.maxPages))

        self:ReleaseChildren()
        self:PauseLayout()

        for i = 1, 500 do
            if icons[i * page] then
                local icon = AceGUI:Create("Icon")
                icon:SetWidth(50)
                icon:SetImageSize(40, 40)
                icon:SetImage(icons[i * page])
                self:AddChild(icon)
                
                icon:SetCallback("OnClick", function(self, _, key)
                    iconsGroupScrollChild.selectedIcon = icons[i * iconsGroupScrollChild.page]
                    local name = string.format("%d (%s)", iconsGroupScrollChild.selectedIcon, InterfaceIcons[iconsGroupScrollChild.selectedIcon] or "")

                    previewLabel:SetImage(iconsGroupScrollChild.selectedIcon)
                    previewLabel:SetText(name)
                    container:SetStatusText(name)

                    C_Timer.After(.01, function()
                        searchEditBox:SetFocus()
                    end)
                end)
            end
        end

        self:ResumeLayout()
        self:SetScroll(0)
        self:DoLayout()
    end

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    firstButton = AceGUI:Create("Button")
    firstButton:SetRelativeWidth(1/4)
    firstButton:SetText(L["First"])

    firstButton:SetCallback("OnClick", function(self, _, key)
        iconsGroupScrollChild:LoadPage(1)
    end)

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    prevButton = AceGUI:Create("Button")
    prevButton:SetRelativeWidth(1/4)
    prevButton:SetText(L["Previous"])

    prevButton:SetCallback("OnClick", function(self, _, key)
        if iconsGroupScrollChild.page == 1 then return end
        iconsGroupScrollChild:LoadPage(iconsGroupScrollChild.page - 1)
    end)

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    nextButton = AceGUI:Create("Button")
    nextButton:SetRelativeWidth(1/4)
    nextButton:SetText(L["Next"])

    nextButton:SetCallback("OnClick", function(self, _, key)
        if iconsGroupScrollChild.page >= iconsGroupScrollChild.maxPages then return end
        iconsGroupScrollChild:LoadPage(iconsGroupScrollChild.page + 1)
    end)

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    lastButton = AceGUI:Create("Button")
    lastButton:SetRelativeWidth(1/4)
    lastButton:SetText(L["Last"])

    lastButton:SetCallback("OnClick", function(self, _, key)
        iconsGroupScrollChild:LoadPage(iconsGroupScrollChild.maxPages)
    end)

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    chooseButton = AceGUI:Create("Button")
    chooseButton:SetFullWidth(true)
    chooseButton:SetText(L["Choose"])

    function chooseButton:Click(_, key)
        self.editbox:SetText(iconsGroupScrollChild.selectedIcon)
        container:Hide()
        self.quantity:SetFocus()
        self.quantity:HighlightText()
    end

    chooseButton:SetCallback("OnClick", chooseButton.Click)

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    frame:AddChild(previewLabel)
    frame:AddChild(searchEditBox)
    frame:AddChild(pageLabel)
    frame:AddChild(iconsGroupScrollFrame)
    frame:AddChild(firstButton)
    frame:AddChild(prevButton)
    frame:AddChild(nextButton)
    frame:AddChild(lastButton)
    frame:AddChild(chooseButton)

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- Load function

    function container:Load(editbox, quantity)
        chooseButton.editbox = editbox
        chooseButton.quantity = quantity

        searchEditBox:SetText()
        previewLabel:SetImage(134400)
        previewLabel:SetText(string.format("%d (%s)", 134400, InterfaceIcons[134400]))

        frame:DoLayout()

        iconsGroupScrollChild:LoadPage(1)

        self:Show()
        searchEditBox:SetFocus()
    end
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function addon:DrawCurrencyGroup(parent)
    local descriptionLabel, separator, previewLabel, currencyDropdown, currencyEditBox, objectiveEditBox, updateButton, resetButton

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    descriptionLabel = AceGUI:Create("Label")
    descriptionLabel:SetFullWidth(true)
    descriptionLabel:SetText(L._ObjectiveBuilder("currencyDesc"))

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    separator = AceGUI:Create("Heading")
    separator:SetFullWidth(true)

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    previewLabel = AceGUI:Create("Label")
    previewLabel:SetFullWidth(true)
    previewLabel:SetImageSize(15, 15)

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    currencyDropdown = AceGUI:Create("Dropdown")
    currencyDropdown:SetFullWidth(true)
    currencyDropdown:SetList(addon.currencies, addon.sortedCurrencies)

    currencyDropdown:SetCallback("OnValueChanged", function(self, _, key)
        local currencyName, icon
        local currency = C_CurrencyInfo.GetCurrencyInfo(key)
        currencyName = currency and currency.name
        icon = currency and currency.iconFileID

        currencyEditBox:SetText(key)
        previewLabel:SetImage(icon)
        previewLabel:SetText(currencyName)

        currencyEditBox:SetFocus()
        currencyEditBox:HighlightText()

        parent:DoLayout()
    end)

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    currencyEditBox = AceGUI:Create("EditBox")
    currencyEditBox:SetWidth(100)
    currencyEditBox:SetLabel(L["Currency ID"])

    currencyEditBox:SetCallback("OnTextChanged", function(self, _, text)
        local currencyName, icon
        local currency = C_CurrencyInfo.GetCurrencyInfo(tonumber(text) or 0)

        currencyName = currency and currency.name
        icon = currency and currency.iconFileID

        if currencyName ~= "" then
            previewLabel:SetImage(icon)
            previewLabel:SetText(currencyName)
        else
            previewLabel:SetImage()
            previewLabel:SetText()
        end

        parent:DoLayout()
    end)

    currencyEditBox:SetCallback("OnEnterPressed", function(self)
        if IsControlKeyDown() then
            updateButton:Click()
        elseif not IsShiftKeyDown() then
            objectiveEditBox:SetFocus()
            objectiveEditBox:HighlightText()
        end
    end)

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    objectiveEditBox = AceGUI:Create("EditBox")
    objectiveEditBox:SetWidth(100)
    objectiveEditBox:SetLabel(L["Objective"])
    objectiveEditBox:SetMaxLetters(15)

    objectiveEditBox:SetCallback("OnEnterPressed", function(self)
        if IsControlKeyDown() then
            updateButton:Click()
        elseif IsShiftKeyDown() then
            currencyEditBox:SetFocus()
            currencyEditBox:HighlightText()
        else
            self:ClearFocus()
        end
    end)


    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    updateButton = AceGUI:Create("Button")
    updateButton:SetRelativeWidth(1/2)
    updateButton:SetText(L["Update Button"])

    function updateButton:Click(self)
        local currencyID = tonumber(currencyEditBox:GetText())
        local objective = tonumber(objectiveEditBox:GetText()) or 0
        objective = objective > 0 and objective or nil
        local button = addon.ObjectiveBuilder.button

        if not currencyID or currencyID == "" or not C_CurrencyInfo.GetCurrencyInfo(currencyID) then
            addon:Print(L.GetErrorMessage("invalidCurrency", currencyEditBox:GetText()))
        else
            local oldObjective = button.objective and button.objective.objective
            local progressCount, progressTotal = button:GetBar():GetProgress()

            button:SetObjectiveID("currency", currencyID, nil, {type = "currency", currencyID = currencyID, objective = objective})
            addon.ObjectiveBuilder:Hide()

            -- Alert bar progress
            local noChange = not oldObjective and (not objective or objective == 0)
            noChange = noChange and noChange or (oldObjective and oldObjective == objective)

            if button.objective.type == "mixedItems" or button.objective.type == "shoppingList" or noChange then return end

            button:GetBar():AlertProgress(progressCount, progressTotal, objective and (button:GetCount() >= objective))
        end
    end

    updateButton:SetCallback("OnClick", updateButton.Click)

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    resetButton = AceGUI:Create("Button")
    resetButton:SetRelativeWidth(1/2)
    resetButton:SetText(L["Reset"])

    resetButton:SetCallback("OnClick", function(self)
        parent:ReleaseChildren()
        addon:DrawCurrencyGroup(parent)
    end)

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    if self.ObjectiveBuilder.button.objective and self.ObjectiveBuilder.button.objective.type == "currency" then
        local currencyID = tonumber(self.ObjectiveBuilder.button.objective.currencyID)
        local currencyName, icon
        local currency = C_CurrencyInfo.GetCurrencyInfo(currencyID)
        currencyName = currency and currency.name
        icon = currency and currency.iconFileID

        currencyDropdown:SetValue(currencyID)
        currencyEditBox:SetText(currencyID)

        -- Need to format the number as a string to prevent scientific notation
        local objective = string.format("%.0f", tonumber(self.ObjectiveBuilder.button.objective.objective) or 0)
        objective = objective == "0" and "" or objective
        objectiveEditBox:SetText(objective)

        previewLabel:SetImage(icon)
        previewLabel:SetText(currencyName)

        currencyEditBox:SetFocus()
        currencyEditBox:HighlightText()

        parent:DoLayout()
    end

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    parent:AddChild(descriptionLabel)
    parent:AddChild(separator)
    parent:AddChild(previewLabel)
    parent:AddChild(currencyDropdown)
    parent:AddChild(currencyEditBox)
    parent:AddChild(objectiveEditBox)
    parent:AddChild(updateButton)
    parent:AddChild(resetButton)

    currencyEditBox:SetFocus()
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function addon:DrawItemGroup(parent)
    local descriptionLabel, separator, previewLabel, itemEditBox, objectiveEditBox, titleEditBox, updateButton, resetButton

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    descriptionLabel = AceGUI:Create("Label")
    descriptionLabel:SetFullWidth(true)
    descriptionLabel:SetText(L._ObjectiveBuilder("itemDesc"))

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    separator = AceGUI:Create("Heading")
    separator:SetFullWidth(true)

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    previewLabel = AceGUI:Create("Label")
    previewLabel:SetFullWidth(true)
    previewLabel:SetImageSize(15, 15)

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    itemEditBox = AceGUI:Create("EditBox")
    itemEditBox:SetWidth(200)
    itemEditBox:SetLabel(L["Item ID or Name"])

    itemEditBox:SetCallback("OnTextChanged", function(self, _, text)
        local itemID = GetItemInfoInstant(text)

        if itemID then
            U.CacheItem(itemID, function(itemID)
                local itemName, _, _, _, _, _, _, _, _, icon = GetItemInfo(itemID)

                previewLabel:SetImage(icon)
                previewLabel:SetText(itemName)
            end, itemID)
        else
            previewLabel:SetImage()
            previewLabel:SetText()
        end

        parent:DoLayout()
    end)

    itemEditBox:SetCallback("OnEnterPressed", function(self)
        if IsControlKeyDown() then
            updateButton:Click()
        elseif not IsShiftKeyDown() then
            objectiveEditBox:SetFocus()
            objectiveEditBox:HighlightText()
        end
    end)

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    objectiveEditBox = AceGUI:Create("EditBox")
    objectiveEditBox:SetWidth(100)
    objectiveEditBox:SetLabel(L["Objective"])
    objectiveEditBox:SetMaxLetters(15)

    objectiveEditBox:SetCallback("OnEnterPressed", function(self)
        if IsControlKeyDown() then
            updateButton:Click()
        elseif IsShiftKeyDown() then
            itemEditBox:SetFocus()
            itemEditBox:HighlightText()
        else
            titleEditBox:SetFocus()
            titleEditBox:HighlightText()
        end
    end)

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    titleEditBox = AceGUI:Create("EditBox")
    titleEditBox:SetFullWidth(true)
    titleEditBox:SetLabel(L["Title"])

    titleEditBox:SetCallback("OnEnterPressed", function(self)
        if IsControlKeyDown() then
            updateButton:Click()
        elseif IsShiftKeyDown() then
            objectiveEditBox:SetFocus()
            objectiveEditBox:HighlightText()
        else
            self:ClearFocus()
        end
    end)

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    updateButton = AceGUI:Create("Button")
    updateButton:SetRelativeWidth(1/2)
    updateButton:SetText(L["Update Button"])

    function updateButton:Click(self)
        local item = itemEditBox:GetText()
        local itemID = GetItemInfoInstant(item)
        local objective = tonumber(objectiveEditBox:GetText())
        local title = titleEditBox:GetText()
        local button = addon.ObjectiveBuilder.button

        if itemID then
            local oldObjective =  button.objective and button.objective.objective
            local progressCount, progressTotal = button:GetBar():GetProgress()

            button:SetObjectiveID("item", itemID, {title = title}, {type = "item", title = title, itemID = itemID, objective = objective, includeBank = false})
            addon.ObjectiveBuilder:Hide()

            -- Alert bar progress
            local noChange = not oldObjective and (not objective or objective == 0)
            noChange = noChange and noChange or (oldObjective and oldObjective == objective)

            if button.objective.type == "mixedItems" or button.objective.type == "shoppingList" or noChange then return end

            button:GetBar():AlertProgress(progressCount, progressTotal, objective and (button:GetCount() >= objective))
        elseif item and item ~= 0 then
            addon:Print(L.GetErrorMessage("invalidItemID", item))
        end
    end

    updateButton:SetCallback("OnClick", updateButton.Click)

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    resetButton = AceGUI:Create("Button")
    resetButton:SetRelativeWidth(1/2)
    resetButton:SetText(L["Reset"])

    resetButton:SetCallback("OnClick", function(self)
        parent:ReleaseChildren()
        addon:DrawItemGroup(parent)
    end)

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    if self.ObjectiveBuilder.button.objective and self.ObjectiveBuilder.button.objective.type and self.ObjectiveBuilder.button.objective.type == "item" then
        itemEditBox:SetText(self.ObjectiveBuilder.button.objective.itemID)
        titleEditBox:SetText(self.ObjectiveBuilder.button.objective.title)

        -- Need to format the number as a string to prevent scientific notation
        local objective = string.format("%.0f", tonumber(self.ObjectiveBuilder.button.objective.objective) or 0)
        objective = objective == "0" and "" or objective
        objectiveEditBox:SetText(objective)

        itemEditBox:SetFocus()
        itemEditBox:HighlightText()

        -- Wait for the item to cache before updating the preview
        U.CacheItem(self.ObjectiveBuilder.button.objective.itemID, function(itemID)
            local itemName, _, _, _, _, _, _, _, _, icon = GetItemInfo(itemID)
            previewLabel:SetImage(icon)
            previewLabel:SetText(itemName)
        end, self.ObjectiveBuilder.button.objective.itemID)
    end

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    parent:AddChild(descriptionLabel)
    parent:AddChild(separator)
    parent:AddChild(previewLabel)
    parent:AddChild(itemEditBox)
    parent:AddChild(objectiveEditBox)
    parent:AddChild(titleEditBox)
    parent:AddChild(updateButton)
    parent:AddChild(resetButton)

    itemEditBox:SetFocus()
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function addon:DrawMixedItemsGroup(parent)
    local descriptionLabel, titleEditBox, iconEditBox, iconChooseButton, objectiveEditBox, addItemEditBox, itemGroupInstructions, itemGroupScrollFrame, itemGroupScrollChild, updateButton, resetButton

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    descriptionLabel = AceGUI:Create("Label")
    descriptionLabel:SetFullWidth(true)
    descriptionLabel:SetText(L._ObjectiveBuilder("mixedItemsDesc"))

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    titleEditBox = AceGUI:Create("EditBox")
    titleEditBox:SetFullWidth(true)
    titleEditBox:SetLabel(L["Title"])

    titleEditBox:SetCallback("OnEnterPressed", function()
        if not IsShiftKeyDown() then
            iconEditBox:SetFocus()
            iconEditBox:HighlightText()
        end
    end)

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    iconEditBox = AceGUI:Create("EditBox")
    iconEditBox:SetWidth(200)
    iconEditBox:SetLabel(L["Icon"])

    iconEditBox:SetCallback("OnEnterPressed", function()
        if IsControlKeyDown() then
            self.ObjectiveIconSelector:Load(iconEditBox, objectiveEditBox)
        elseif IsShiftKeyDown() then
            titleEditBox:SetFocus()
            titleEditBox:HighlightText()
        else
            objectiveEditBox:SetFocus()
            objectiveEditBox:HighlightText()
        end
    end)

    iconChooseButton = AceGUI:Create("Button")
    iconChooseButton:SetWidth(100)
    iconChooseButton:SetText(L["Choose"])

    iconChooseButton:SetCallback("OnClick", function()
        self.ObjectiveIconSelector:Load(iconEditBox, objectiveEditBox)
    end)

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    objectiveEditBox = AceGUI:Create("EditBox")
    objectiveEditBox:SetWidth(100)
    objectiveEditBox:SetLabel(L["Quantity"])
    objectiveEditBox:SetMaxLetters(15)

    objectiveEditBox:SetCallback("OnEnterPressed", function()
        if IsShiftKeyDown() then
            iconEditBox:SetFocus()
            iconEditBox:HighlightText()
        else
            addItemEditBox:SetFocus()
            addItemEditBox:HighlightText()
        end
    end)

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    addItemEditBox = AceGUI:Create("EditBox")
    addItemEditBox:SetWidth(200)
    addItemEditBox:SetLabel(L["Add Item"])

    addItemEditBox:SetCallback("OnEnterPressed", function(self, _, text)
        if IsControlKeyDown() then
            updateButton:Click()
        elseif IsShiftKeyDown() then
            objectiveEditBox:SetFocus()
            objectiveEditBox:HighlightText()
        else
            local itemID = GetItemInfoInstant(text)

            if itemID then
                U.CacheItem(itemID, function(itemID)
                    if not tContains(itemGroupScrollChild.items, itemID) then
                        tinsert(itemGroupScrollChild.items, itemID)
                        itemGroupScrollChild:DrawContainer()
                    end
                    self:SetText()
                end, itemID)
            else
                addon:Print(L.GetErrorMessage("invalidItemID", text))
                self:HighlightText()
            end
        end
    end)

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    itemGroupInstructions = AceGUI:Create("Label")
    itemGroupInstructions:SetFullWidth(true)
    itemGroupInstructions:SetText(L._ObjectiveBuilder("removeItem"))

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    itemGroupScrollFrame = AceGUI:Create("SimpleGroup")
    itemGroupScrollFrame:SetFullWidth(true)
    itemGroupScrollFrame:SetFullHeight(false)
    itemGroupScrollFrame:SetHeight(100)
    itemGroupScrollFrame:SetLayout("Fill")

    itemGroupScrollChild = AceGUI:Create("ScrollFrame")
    itemGroupScrollChild:SetHeight(100)
    itemGroupScrollChild:SetLayout("Flow")
    itemGroupScrollFrame:AddChild(itemGroupScrollChild)

    itemGroupScrollChild.items = {}

    function itemGroupScrollChild:DrawContainer()
        self:ReleaseChildren()

        sort(self.items, function(a, b) return GetItemInfoInstant(a) < GetItemInfoInstant(b) end)

        for k, v in pairs(self.items) do
            U.CacheItem(v, function(itemID)
                local itemName, _, _, _, _, _, _, _, _, icon = GetItemInfo(itemID)

                local label = AceGUI:Create("InteractiveLabel")
                label:SetFullWidth(true)
                label:SetText(itemName)
                label:SetImage(icon)
                label:SetImageSize(15, 15)

                label:SetCallback("OnClick", function(_, _, button)
                    if button == "RightButton" then
                        tremove(self.items, k)
                        self:DrawContainer()
                    end
                end)

                self:AddChild(label)
            end, v)
        end
    end

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    updateButton = AceGUI:Create("Button")
    updateButton:SetRelativeWidth(1/2)
    updateButton:SetText(L["Update Button"])

    function updateButton:Click(self)
        local title = titleEditBox:GetText()
        local icon = iconEditBox:GetText() ~= "" and iconEditBox:GetText() or 134400
        local objective = tonumber(objectiveEditBox:GetText()) or 0

        if title == "" then
            addon:Print(L.GetErrorMessage("invalidObjectiveTitle"))
        elseif objective <= 0 then
            addon:Print(L.GetErrorMessage("invalidObjectiveQuantity"))
        elseif U.tcount(itemGroupScrollChild.items) < 2 then
            addon:Print(L.GetErrorMessage("invalidListQuantity"))
        else
            addon.ObjectiveBuilder.button:SetObjectiveID("mixedItems", itemGroupScrollChild.items, {title = title, objective = objective, icon = icon})
            addon.ObjectiveBuilder:Hide()
        end
    end

    updateButton:SetCallback("OnClick", updateButton.Click)

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    resetButton = AceGUI:Create("Button")
    resetButton:SetRelativeWidth(1/2)
    resetButton:SetText(L["Reset"])

    resetButton:SetCallback("OnClick", function(self)
        parent:ReleaseChildren()
        addon:DrawMixedItemsGroup(parent)
    end)

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    if self.ObjectiveBuilder.button.objective and self.ObjectiveBuilder.button.objective.type and self.ObjectiveBuilder.button.objective.type == "mixedItems" then
        local objectiveTable = self.ObjectiveBuilder.button.objective

        titleEditBox:SetText(objectiveTable.title)
        iconEditBox:SetText(objectiveTable.icon)
        objectiveEditBox:SetText(objectiveTable.objective)

        for k, v in pairs(objectiveTable.items) do
            if not tContains(itemGroupScrollChild.items, v) then
                tinsert(itemGroupScrollChild.items, v)
            end
        end

        titleEditBox:SetFocus()
        titleEditBox:HighlightText()

        itemGroupScrollChild:DrawContainer()
    end

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    parent:AddChild(descriptionLabel)
    parent:AddChild(titleEditBox)
    parent:AddChild(iconEditBox)
    parent:AddChild(iconChooseButton)
    parent:AddChild(objectiveEditBox)
    parent:AddChild(addItemEditBox)
    parent:AddChild(itemGroupInstructions)
    parent:AddChild(itemGroupScrollFrame)
    parent:AddChild(updateButton)
    parent:AddChild(resetButton)

    titleEditBox:SetFocus()
end
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function addon:DrawShoppingListGroup(parent)
    local descriptionLabel, titleEditBox, iconEditBox, iconChooseButton, objectiveEditBox, addItemEditBox, itemGroupInstructions, itemGroupScrollFrame, itemGroupScrollChild, updateButton, resetButton

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    descriptionLabel = AceGUI:Create("Label")
    descriptionLabel:SetFullWidth(true)
    descriptionLabel:SetText(L._ObjectiveBuilder("shoppingListDesc"))

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    titleEditBox = AceGUI:Create("EditBox")
    titleEditBox:SetFullWidth(true)
    titleEditBox:SetLabel(L["Title"])

    titleEditBox:SetCallback("OnEnterPressed", function()
        if not IsShiftKeyDown() then
            iconEditBox:SetFocus()
            iconEditBox:HighlightText()
        end
    end)

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    iconEditBox = AceGUI:Create("EditBox")
    iconEditBox:SetWidth(200)
    iconEditBox:SetLabel(L["Icon"])

    iconEditBox:SetCallback("OnEnterPressed", function()
        if IsControlKeyDown() then
            self.ObjectiveIconSelector:Load(iconEditBox, objectiveEditBox)
        elseif IsShiftKeyDown() then
            titleEditBox:SetFocus()
            titleEditBox:HighlightText()
        else
            objectiveEditBox:SetFocus()
            objectiveEditBox:HighlightText()
        end
    end)

    iconChooseButton = AceGUI:Create("Button")
    iconChooseButton:SetWidth(100)
    iconChooseButton:SetText(L["Choose"])

    iconChooseButton:SetCallback("OnClick", function()
        self.ObjectiveIconSelector:Load(iconEditBox, objectiveEditBox)
    end)

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    objectiveEditBox = AceGUI:Create("EditBox")
    objectiveEditBox:SetWidth(100)
    objectiveEditBox:SetLabel(L["Quantity"])
    objectiveEditBox:SetMaxLetters(15)

    objectiveEditBox:SetCallback("OnEnterPressed", function()
        if IsShiftKeyDown() then
            iconEditBox:SetFocus()
            iconEditBox:HighlightText()
        else
            addItemEditBox:SetFocus()
            addItemEditBox:HighlightText()
        end
    end)

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    addItemEditBox = AceGUI:Create("EditBox")
    addItemEditBox:SetWidth(200)
    addItemEditBox:SetLabel(L["Add Item"])

    addItemEditBox:SetCallback("OnEnterPressed", function(self, _, text)
        if IsControlKeyDown() then
            updateButton:Click()
        elseif IsShiftKeyDown() then
            objectiveEditBox:SetFocus()
            objectiveEditBox:HighlightText()
        else
            local itemID = GetItemInfoInstant(text)

            if itemID then
                local quantity = tonumber(objectiveEditBox:GetText()) or 0

                if quantity <= 0 then
                    addon:Print(L.GetErrorMessage("invalidObjectiveQuantity"))
                else
                    U.CacheItem(itemID, function(itemID)
                        itemGroupScrollChild.items[itemID] = quantity
                        itemGroupScrollChild:DrawContainer()
                        self:SetText()
                        objectiveEditBox:SetText()
                        objectiveEditBox:SetFocus()
                    end, itemID)
                end
            else
                addon:Print(L.GetErrorMessage("invalidItemID", text))
                self:HighlightText()
            end
        end
    end)

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    itemGroupInstructions = AceGUI:Create("Label")
    itemGroupInstructions:SetFullWidth(true)
    itemGroupInstructions:SetText(string.format("%s %s", L._ObjectiveBuilder("editItem"), L._ObjectiveBuilder("removeItem")))

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    itemGroupScrollFrame = AceGUI:Create("SimpleGroup")
    itemGroupScrollFrame:SetFullWidth(true)
    itemGroupScrollFrame:SetFullHeight(false)
    itemGroupScrollFrame:SetHeight(100)
    itemGroupScrollFrame:SetLayout("Fill")

    itemGroupScrollChild = AceGUI:Create("ScrollFrame")
    itemGroupScrollChild:SetHeight(100)
    itemGroupScrollChild:SetLayout("Flow")
    itemGroupScrollFrame:AddChild(itemGroupScrollChild)

    itemGroupScrollChild.items = {}

    function itemGroupScrollChild:DrawContainer()
        self:ReleaseChildren()

        for k, v in U.pairs(self.items, function(a, b) return GetItemInfoInstant(a) > GetItemInfoInstant(b) end) do
            U.CacheItem(k, function(itemID)
                local itemName, _, _, _, _, _, _, _, _, icon = GetItemInfo(itemID)
                local objective = self.items[k]

                local label = AceGUI:Create("InteractiveLabel")
                label:SetFullWidth(true)
                label:SetText(string.format("%s x%d", itemName, objective))
                label:SetImage(icon)
                label:SetImageSize(15, 15)

                label:SetCallback("OnClick", function(_, _, button)
                    if button == "RightButton" then
                        self.items[k] = nil
                        self:DrawContainer()
                    else
                        addItemEditBox:SetText(itemID)
                        objectiveEditBox:SetText(objective)
                        C_Timer.After(0.1, function()
                            objectiveEditBox:SetFocus()
                            objectiveEditBox:HighlightText()
                        end)
                    end
                end)

                self:AddChild(label)
            end, k)
        end
    end

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    updateButton = AceGUI:Create("Button")
    updateButton:SetRelativeWidth(1/2)
    updateButton:SetText(L["Update Button"])

    function updateButton:Click(self)
        local title = titleEditBox:GetText()
        local icon = iconEditBox:GetText() ~= "" and iconEditBox:GetText() or 134400

        if title == "" then
            addon:Print(L.GetErrorMessage("invalidObjectiveTitle"))
        elseif U.tcount(itemGroupScrollChild.items) < 2 then
            addon:Print(L.GetErrorMessage("invalidListQuantity"))
        else
            local objective = 0
            for k, v in pairs(itemGroupScrollChild.items) do
                objective = objective + v
            end

            addon.ObjectiveBuilder.button:SetObjectiveID("shoppingList", itemGroupScrollChild.items, {title = title, objective = objective, icon = icon})
            addon.ObjectiveBuilder:Hide()
        end
    end

    updateButton:SetCallback("OnClick", updateButton.Click)

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    resetButton = AceGUI:Create("Button")
    resetButton:SetRelativeWidth(1/2)
    resetButton:SetText(L["Reset"])

    resetButton:SetCallback("OnClick", function(self)
        parent:ReleaseChildren()
        addon:DrawShoppingListGroup(parent)
    end)

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    if self.ObjectiveBuilder.button.objective and self.ObjectiveBuilder.button.objective.type and self.ObjectiveBuilder.button.objective.type == "shoppingList" then
        local objectiveTable = self.ObjectiveBuilder.button.objective

        titleEditBox:SetText(objectiveTable.title)
        iconEditBox:SetText(objectiveTable.icon)

        for k, v in pairs(objectiveTable.items) do
            itemGroupScrollChild.items[k] = v
        end

        titleEditBox:SetFocus()
        titleEditBox:HighlightText()

        itemGroupScrollChild:DrawContainer()
    end

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    parent:AddChild(descriptionLabel)
    parent:AddChild(titleEditBox)
    parent:AddChild(iconEditBox)
    parent:AddChild(iconChooseButton)
    parent:AddChild(objectiveEditBox)
    parent:AddChild(addItemEditBox)
    parent:AddChild(itemGroupInstructions)
    parent:AddChild(itemGroupScrollFrame)
    parent:AddChild(updateButton)
    parent:AddChild(resetButton)

    titleEditBox:SetFocus()
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function addon:SortObjectives(tbl)
    sort(tbl, function(a, b)
        local objectiveA = (a.type == "item" and a.itemID) or (a.type == "currency" and a.currencyID) or a.title
        local objectiveB = (b.type == "item" and b.itemID) or (b.type == "currency" and b.currencyID) or b.title

        return tostring(objectiveA) < tostring(objectiveB)
    end)
end