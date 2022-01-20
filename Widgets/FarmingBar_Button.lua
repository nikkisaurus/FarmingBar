local addonName = ...
local addon = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

-- Optional libraries
local ACD = LibStub("AceConfigDialog-3.0")
local AceGUI = LibStub("AceGUI-3.0", true)
local LSM = LibStub("LibSharedMedia-3.0")

local Type = "FarmingBar_Button"
local Version = 1

-- *------------------------------------------------------------------------
-- Keybinds

local postClickMethods = {
    clearObjective = function(self, ...)
        self.obj:ClearObjective()
    end,

    moveObjective = function(self, ...)
        local widget = self.obj

        if not widget:IsEmpty() and not addon.movingButton then
            widget.Flash:Show()
            UIFrameFlash(widget.Flash, 0.5, 0.5, -1)
            addon.movingButton = {widget, addon:CloneTable(widget:GetButtonDB())}
        elseif addon.movingButton then
            widget:SwapButtons(addon.movingButton)
        end
        addon:UpdateButtons()
    end,

    showObjectiveEditBox = function(self, ...)
        local widget = self.obj
        if not widget:IsEmpty() then
            widget.objectiveEditBox:Show()
        end
    end,

    showQuickAddEditBox = function(self, ...)
        self.obj:SetUserData("quickAddEditbox", "ITEM")
        self.obj.quickAddEditBox:Show()
    end,

    -- @retail@
    showQuickAddCurrencyEditBox = function(self, ...)
        self.obj:SetUserData("quickAddEditbox", "CURRENCY")
        self.obj.quickAddEditBox:Show()
    end,
    -- @end-retail@

    showObjectiveEditor = function(self, ...)
        local widget = self.obj
        if not widget:IsEmpty() then
            addon:InitializeObjectiveEditorOptions(widget)
            ACD:SelectGroup(addonName .. "ObjectiveEditor", "objective")
            ACD:Open(addonName .. "ObjectiveEditor")
        end
    end,

    moveObjectiveToBank = function(self, ...)
        print("Keybind in maintenenance.")
    end,

    moveAllToBank = function(self, ...)
        print("Keybind in maintenenance.")
    end,
}

-- *------------------------------------------------------------------------
-- Frame methods

local function EditBox_OnEscapePressed(self)
    self:ClearFocus()
    self:Hide()
end

local function EditBox_OnShow(self)
    local widget = self.obj
    local width = widget.frame:GetWidth()
    self:SetSize(width, width / 2)
    self:SetFocus()
end

local function EditBox_OnTextChanged(self)
    self:SetText(string.gsub(self:GetText(), "[%s%c%p%a]", ""))
end

local function frame_OnDragStart(self, buttonClicked, ...)
    local widget = self.obj
    if widget:IsEmpty() then
        return
    end

    local keybinds = addon:GetDBValue("global", "settings.keybinds.button.dragObjective")
    if buttonClicked == keybinds.button then
        local mod = addon:GetModifierString()

        if mod == keybinds.modifier then
            widget:SetUserData("isDragging", true)
            addon.movingButton = {widget, addon:CloneTable(widget:GetButtonDB())}
            addon.DragFrame:LoadObjective(widget)
            -- widget:ClearObjective()
        end
    end
end

local function frame_OnDragStop(self)
    self.obj:SetUserData("isDragging")
end

local function frame_OnEnter(self)
    local widget = self.obj
    local barDB = widget:GetBarDB()

    widget:GetBar():SetAlpha(not barDB.anchorMouseover)

    local tooltip = widget:GetUserData("tooltip")
    if tooltip and not addon.DragFrame:GetObjective() then
        addon.tooltip:SetScript("OnUpdate", function()
            addon.tooltip:ClearLines()
            addon.tooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", 0, 0)
            addon[tooltip](addon, widget, addon.tooltip)
            addon.tooltip:Show()
        end)
        addon.tooltip:GetScript("OnUpdate")()
    end
end

local function frame_OnLeave(self)
    local widget = self.obj
    local barDB = widget:GetBarDB()

    widget:GetBar():SetAlpha(false)

    local tooltip = widget:GetUserData("tooltip")
    if tooltip and not addon.DragFrame:GetObjective() then
        addon.tooltip:ClearLines()
        addon.tooltip:Hide()
        addon.tooltip:SetScript("OnUpdate", nil)
    end
end

local function frame_OnEvent(self, event, ...)
    local widget = self.obj
    if widget:IsEmpty() then
        return
    end

    if event == "PLAYER_REGEN_ENABLED" then
        widget:SetAttribute()
        self:UnregisterEvent(event)
        -- TODO: print combat left
    elseif event == "SPELL_UPDATE_COOLDOWN" then
        local buttonDB = widget:GetButtonDB()
        local validTrackerID, trackerType = addon:ValidateTrackerData(buttonDB.action, buttonDB.actionInfo)

        if addon:GetDBValue("profile", "style.buttonLayers.Cooldown") and trackerType == "ITEM" and validTrackerID then
            local fontDB = addon:GetDBValue("profile", "style.font")
            widget.Cooldown:GetRegions():SetFont(LSM:Fetch("font", fontDB.face), fontDB.size, fontDB.outline)

            local startTime, duration, enable = GetItemCooldown(buttonDB.actionInfo)
            widget.Cooldown:SetCooldown(startTime, duration)
            widget.Cooldown:Show()
        else
            widget.Cooldown:SetCooldown(0, 0)
            widget.Cooldown:Hide()
        end
    end
end

local function frame_OnReceiveDrag(self)
    local widget = self.obj
    local objectiveTitle, objectiveInfo = addon.DragFrame:GetObjective()

    if addon.movingButton then
        if addon.movingButton[1] == self.obj then
            addon.movingButton = nil
        else
            widget:SwapButtons(addon.movingButton)
        end
    elseif objectiveTitle then
        addon:CreateObjectiveFromDragFrame(widget, objectiveInfo)
    else
        widget:ClearObjective()
        addon:CreateObjectiveFromCursor(widget)
    end

    addon.DragFrame:Clear()
end

local function frame_PostClick(self, buttonClicked, ...)
    local widget = self.obj
    if widget:GetUserData("isDragging") then
        return
    end
    local cursorType, cursorID = GetCursorInfo()
    local objectiveTitle, objectiveInfo = addon.DragFrame:GetObjective()

    if cursorType == "item" and not IsModifierKeyDown() and buttonClicked == "LeftButton" then
        widget:ClearObjective()
        addon:CreateObjectiveFromCursor(widget)
        return
    elseif objectiveTitle then
        if addon.movingButton then
            widget:SwapButtons(addon.movingButton)
        else
            addon:CreateObjectiveFromDragFrame(widget, objectiveInfo)
        end
        addon.DragFrame:Clear()
        return
    end

    ClearCursor()

    local keybinds = addon:GetDBValue("global", "settings.keybinds.button")

    for keybind, keybindInfo in pairs(keybinds) do
        if buttonClicked == keybindInfo.button then
            local mod = addon:GetModifierString()

            if mod == keybindInfo.modifier then
                local func = postClickMethods[keybind]
                if func then
                    func(self, keybindInfo, buttonClicked, ...)
                end
            end
        end
    end
end

local function objectiveEditBox_OnEnterPressed(self)
    local objective = tonumber(self:GetText())
    objective = objective and (objective > 0 and objective)
    self.obj:SetObjective(objective)

    if addon:GetDBValue("global", "settings.alerts.button.sound.enabled") then
        PlaySoundFile(LSM:Fetch("sound", addon:GetDBValue("global", "settings.alerts.button.sound")[objective and "objectiveSet" or "objectiveCleared"]))
    end

    self:ClearFocus()
    self:Hide()
end

local function objectiveEditBox_OnEditFocusGained(self)
    self:SetText(self.obj:GetObjective() or "")
    C_Timer.After(.001, function()
        self:HighlightText()
    end)
end

local function quickAddEditBox_OnEnterPressed(self)
    local widget = self.obj
    local ID = tonumber(self:GetText())

    if ID then
        if widget:GetUserData("quickAddEditbox") == "ITEM" then
            if GetItemInfoInstant(ID) then
                widget:ClearObjective()
                addon:CreateObjectiveFromItemID(widget, ID)
            else
                addon:ReportError(format(L.InvalidItemID, ID))
            end
        else
            if C_CurrencyInfo.GetCurrencyInfo(ID) then
                widget:ClearObjective()
                addon:CreateObjectiveFromCurrencyID(widget, ID)
            else
                addon:ReportError(format(L.InvalidCurrencyID, ID))
            end
        end
    end

    self:SetText("")
    self:ClearFocus()
    self:Hide()
end

-- *------------------------------------------------------------------------
-- Widget methods

local methods = {
    OnAcquire = function(self)
        self:SetUserData("tooltip", "GetButtonTooltip")

        self.frame:ClearAllPoints()
        self.frame:Show()

        self.objectiveEditBox:Hide()
        self.quickAddEditBox:Hide()

        self:UpdateLayers()
    end,

    OnRelease = function(self)
        addon:InitializeTrackers()
    end,

    Anchor = function(self)
        local barDB = self:GetUserData("barDB")
        local buttons = self:GetUserData("buttons")
        local buttonID = self:GetUserData("buttonID")

        local anchor, relativeAnchor, xOffset, yOffset = addon:GetAnchorPoints(barDB.grow[1])

        self:ClearAllPoints()
        if buttonID == 1 then
            self:SetPoint(anchor, self:GetUserData("bar").frame, relativeAnchor, xOffset * barDB.button.padding, yOffset * barDB.button.padding)
        else
            if math.fmod(buttonID, barDB.buttonWrap) == 1 or barDB.buttonWrap == 1 then
                local anchor, relativeAnchor, xOffset, yOffset = addon:GetRelativeAnchorPoints(barDB.grow)
                self:SetPoint(anchor, buttons[buttonID - barDB.buttonWrap].frame, relativeAnchor, xOffset * barDB.button.padding, yOffset * barDB.button.padding)
            else
                self:SetPoint(anchor, buttons[buttonID - 1].frame, relativeAnchor, xOffset * barDB.button.padding, yOffset * barDB.button.padding)
            end
        end

        local bar = self:GetUserData("bar")
        local lastButton = self:GetUserData("buttons")[barDB.numVisibleButtons]
        if bar and lastButton then
            bar:UpdateBackdrop(lastButton)
        end
    end,

    ApplySkin = function(self)
        addon:SkinButton(self, self:GetDBValue("profile", "style.skin"))
        self:UpdateLayers()
    end,

    ClearObjective = function(self)
        self:SetUserData("objective")
        local buttonDB = self:GetButtonDB()
        for k, v in pairs(buttonDB) do
            if k == "trackers" then
                for trackerKey, trackerInfo in pairs(v) do
                    buttonDB.trackers[trackerKey] = nil
                end
            else
                if k == "template" and v then
                    addon:RemoveObjectiveTemplateInstance(buttonDB.template, self:GetButtonID())
                end
                buttonDB[k] = addon:GetBarDBValue("objectives", 0, true)[0][k]
            end
        end

        self:UpdateLayers()
        ACD:Close(addonName .. "ObjectiveEditor")
    end,

    ClearTrackerInfo = function(self)
        if self:IsEmpty() then
            return
        end

        for trackerKey, trackerInfo in pairs(self:GetButtonDB().trackers) do
            trackerInfo.includeAllChars = false
            trackerInfo.includeBank = false
            -- @retail@
            if trackerInfo.includeGuildBank then
                wipe(trackerInfo.includeGuildBank)
            end
            -- @end-retail@
            if trackerInfo.exclude then
                wipe(trackerInfo.exclude)
            end
        end
    end,

    GetBar = function(self)
        return self:GetUserData("bar")
    end,

    GetBarDB = function(self)
        return self:GetUserData("barDB")
    end,

    GetBarID = function(self)
        return self:GetUserData("barID")
    end,

    GetButtonDB = function(self)
        return self:GetBarID() and addon:GetBarDBValue("objectives", self:GetUserData("barID"), true)[self:GetUserData("buttonID")]
    end,

    GetButtonID = function(self)
        local barID = self:GetUserData("barID")
        local buttonID = self:GetUserData("buttonID")

        return format("%d:%d", barID, buttonID)
    end,

    GetCount = function(self)
        return self:GetUserData("count") or 0, self:GetUserData("trackerCounts") or {}
    end,

    GetObjective = function(self)
        return not self:IsEmpty() and self:GetButtonDB().objective
    end,

    GetObjectiveTitle = function(self)
        return not self:IsEmpty() and self:GetButtonDB().title
    end,

    HasObjective = function(self)
        return not self:IsEmpty() and self:GetObjective() and self:GetObjective() > 0
    end,

    IsEmpty = function(self)
        return not self:GetBarID() or self:GetButtonDB().title == ""
    end,

    IsObjectiveComplete = function(self)
        return not self:IsEmpty() and self:GetObjective() and self:GetObjective() > 0 and self:GetCount() >= self:GetObjective()
    end,

    RemoveObjectiveTemplateLink = function(self)
        if self:IsEmpty() then
            return
        end
        local instances = addon:GetDBValue("global", "objectives")[self:GetObjectiveTitle()].instances
        if not instances then
            return
        end

        local buttonDB = self:GetButtonDB()
        for k, v in pairs(instances) do
            if k ~= "instances" then
                buttonDB[k] = v
            end
        end
        buttonDB.template = false
    end,

    SetAlpha = function(self, alpha)
        self.frame:SetAlpha(alpha or self:GetBarDB().alpha)
    end,

    SetAttribute = function(self)
        local info = addon:GetDBValue("global", "settings.keybinds.button.useItem")
        local buttonType = (info.modifier ~= "" and (info.modifier .. "-") or "") .. "type" .. (info.button == "RightButton" and 2 or 1)
        local isEmpty = self:IsEmpty()
        local buttonDB = self:GetButtonDB()

        if not isEmpty and self.frame:GetAttribute(buttonType) == "macro" and buttonDB.action == "MACROTEXT" then
            if self.frame:GetAttribute("macrotext") == buttonDB.actionInfo then
                return
            end
        elseif not isEmpty and self.frame:GetAttribute(buttonType) == "item" and buttonDB.action == "ITEM" then
            if self.frame:GetAttribute("item") == ("item" .. buttonDB.actionInfo) then
                return
            end
        end

        if UnitAffectingCombat("player") then
            self.frame:RegisterEvent("PLAYER_REGEN_ENABLED")
            -- TODO: print combat error
            return
        end

        self.frame:SetAttribute(buttonType, nil)
        self.frame:SetAttribute("item", nil)
        self.frame:SetAttribute("macrotext", nil)

        if isEmpty then
            return
        end

        if buttonDB.action == "ITEM" and buttonDB.actionInfo then
            self.frame:SetAttribute(buttonType, "item")
            self.frame:SetAttribute("item", "item:" .. buttonDB.actionInfo)
        elseif buttonDB.action == "MACROTEXT" then
            self.frame:SetAttribute(buttonType, "macro")
            self.frame:SetAttribute("macrotext", buttonDB.actionInfo)
        end
    end,

    SetBar = function(self, bar, buttonID)
        self:SetUserData("bar", bar)
        self:SetUserData("barID", bar:GetUserData("barID"))
        self:SetUserData("barDB", bar:GetUserData("barDB"))
        self:SetUserData("buttons", bar:GetUserData("buttons"))
        self:SetUserData("buttonID", buttonID)

        self:Anchor()
        self:SetAlpha()
        self:SetSize()
        self:UpdateLayers()
    end,

    SetCount = function(self)
        local style = addon:GetDBValue("profile", "style.font.fontStrings.count")
        local isEmpty = self:IsEmpty()
        if not isEmpty then
            local count, trackerCounts = addon:GetObjectiveCount(self)
            self:SetUserData("count", count)
            self:SetUserData("trackerCounts", trackerCounts)
        end

        self.Count:SetText(not isEmpty and addon.iformat(self:GetCount(), 2, true) or "")
        self:UpdateObjective()

        if isEmpty then
            return
        end

        if style.style == "ITEMQUALITY" then
            local itemQuality = 0

            for k, v in pairs(self:GetButtonDB().trackers) do
                local trackerType, trackerID = addon:ParseTrackerKey(k)
                itemQuality = trackerType == "ITEM" and max(itemQuality, C_Item.GetItemQualityByID(trackerID)) or itemQuality
            end

            if itemQuality > 1 then

                local r, g, b = GetItemQualityColor(itemQuality)
                self.Count:SetTextColor(r, g, b, 1)
            end
        elseif style.style == "INCLUDEAUTOLAYERS" then
            local total_char, included_char, notIncluded_char = addon:GetObjectiveIncludedLayers(self, "includeAllChars")
            local total_bank, included_bank, notIncluded_bank = addon:GetObjectiveIncludedLayers(self, "includeBank")

            if notIncluded_char == total_char and notIncluded_bank == total_bank then
                -- Neither includeAllChars or includeBank
                self.Count:SetTextColor(1, 1, 1, 1)
            elseif included_char == total_char then
                if included_bank == total_bank then
                    -- includeAllChars and includeBank
                    self.Count:SetTextColor(64 / 255, 224 / 255, 208 / 255, 1)
                else
                    -- includeAllChars
                    self.Count:SetTextColor(1, 31 / 51, 0, 1)
                end
            elseif included_bank == total_bank then
                -- includeBank
                self.Count:SetTextColor(1, .82, 0, 1)
            else
                -- Mixture
                self.Count:SetTextColor(0.5, 0.5, 0.5, 1)
            end
        elseif style.style == "INCLUDEALLCHARS" then
            local total, included, notIncluded = addon:GetObjectiveIncludedLayers(self, "includeAllChars")
            if notIncluded == total then
                self.Count:SetTextColor(1, 1, 1, 1)
            elseif included == total then
                self.Count:SetTextColor(1, 31 / 51, 0, 1)
            else
                self.Count:SetTextColor(.5, .5, .5, 1)
            end
        elseif style.style == "INCLUDEBANK" then
            local total, included, notIncluded = addon:GetObjectiveIncludedLayers(self, "includeBank")
            if notIncluded == total then
                self.Count:SetTextColor(1, 1, 1, 1)
            elseif included == total then
                self.Count:SetTextColor(1, .82, 0, 1)
            else
                self.Count:SetTextColor(.5, .5, .5, 1)
            end
        elseif style.style == "CUSTOM" then
            self.Count:SetTextColor(unpack(style.color))
        else
            self.Count:SetTextColor(1, 1, 1, 1)
        end
    end,

    SetDBValue = function(self, key, value)
        addon:SetButtonDBValues(key, value, self:GetBarID(), self:GetUserData("buttonID"))
    end,

    SetFontStringSettings = function(self, fontString)
        local fontDB = addon:GetDBValue("profile", "style.font")
        self.Count:SetFont(LSM:Fetch("font", fontDB.face), fontDB.size, fontDB.outline)
        self.Objective:SetFont(LSM:Fetch("font", fontDB.face), fontDB.size, fontDB.outline)

        if not self:GetUserData("barDB") or not self:GetUserData("barDB").button then
            return
        end
        local db = self:GetUserData("barDB").button.fontStrings[strlower(fontString)]

        self[fontString]:ClearAllPoints()
        self[fontString]:SetSize(0, 0)

        self[fontString]:SetPoint(db.anchor, self.frame, db.anchor, db.xOffset, db.yOffset)
        self[fontString]:SetJustifyH((db.anchor:find("RIGHT") and "RIGHT") or (db.anchor:find("LEFT") and "LEFT") or "CENTER")
    end,

    SetHidden = function(self)
        local barDB = self:GetUserData("barDB")
        if barDB and barDB.hidden then
            self.frame:Hide()
        else
            self.frame:Show()
        end
    end,

    SetIcon = function(self)
        self.Icon:SetTexture(self:IsEmpty() and "" or addon:GetObjectiveIcon(self))
    end,

    SetObjective = function(self, objective)
        local bar = self:GetUserData("bar")
        local progressCount, progressTotal = bar:GetProgress()

        local oldObjective = self:GetObjective() or 0
        objective = tonumber(objective)

        self:SetUserData("objective", objective)
        self:SetDBValue("objective", objective)
        self:UpdateObjective()

        local newProgressCount, newProgressTotal = bar:GetProgress()
        -- bar:AlertProgress("objectiveSet", newProgressTotal > progressTotal and "complete" or "lost")

        addon:UpdateButtons()
    end,

    SetPoint = function(self, ...) -- point, anchor, relpoint, x, y
        self.frame:SetPoint(...)
    end,

    SetSize = function(self)
        local frameSize = self:GetUserData("barDB").button.size

        self.frame:SetSize(frameSize, frameSize)
        self.Count:SetWidth(frameSize)
        self.Objective:SetWidth(frameSize)
    end,

    SwapButtons = function(self, movingButton)
        local buttonDB = {
            trackers = {},
        }
        local currentButtonDB = self:GetButtonDB()
        local moveButtonDB = movingButton[1]:GetButtonDB()

        -- Update template links
        local moveTemplate = moveButtonDB.template
        local currentTemplate = currentButtonDB.template
        if moveTemplate then
            addon:RemoveObjectiveTemplateInstance(moveTemplate, movingButton[1]:GetButtonID())
            addon:CreateObjectiveTemplateInstance(moveTemplate, self:GetButtonID())
        end
        if currentTemplate then
            addon:RemoveObjectiveTemplateInstance(currentTemplate, self:GetButtonID())
            addon:CreateObjectiveTemplateInstance(currentTemplate, movingButton[1]:GetButtonID())
        end

        -- Swap button data
        for k, v in pairs(moveButtonDB) do
            if k == "trackers" then
                for trackerKey, trackerInfo in pairs(v) do
                    buttonDB.trackers[trackerKey] = {}
                    for key, value in pairs(trackerInfo) do
                        buttonDB.trackers[trackerKey][key] = value
                    end
                    moveButtonDB.trackers[trackerKey] = nil
                end
            else
                buttonDB[k] = v
                moveButtonDB[k] = currentButtonDB[k]
            end
        end

        for k, v in pairs(currentButtonDB) do
            if k == "trackers" then
                for trackerKey, trackerInfo in pairs(v) do
                    moveButtonDB.trackers[trackerKey] = {}
                    for key, value in pairs(trackerInfo) do
                        moveButtonDB.trackers[trackerKey][key] = value
                    end
                    currentButtonDB.trackers[trackerKey] = nil
                end
                for trackerKey, trackerInfo in pairs(buttonDB.trackers) do
                    currentButtonDB.trackers[trackerKey] = {}
                    for key, value in pairs(trackerInfo) do
                        currentButtonDB.trackers[trackerKey][key] = value
                    end
                end
            else
                currentButtonDB[k] = buttonDB[k]
            end
        end

        -- Update visuals
        UIFrameFlashStop(movingButton[1].Flash)
        movingButton[1].Flash:Hide()
        self:UpdateLayers()
        movingButton[1]:UpdateLayers()

        addon.movingButton = nil
    end,

    ToggleTrackerValue = function(self, value)
        if value == "includeAllChars" then
            local missingDependencies = addon:IsDataStoreLoaded()
            if #missingDependencies > 0 then
                addon:ReportError(format(L.MissingIncludeAllCharsDependecies, strjoin(", ", unpack(missingDependencies))))
            end
        end

        local trackers = self:GetButtonDB().trackers

        -- Get count before and after toggling value to use for alerts
        local oldCount = addon:GetObjectiveCount(self)
        for trackerID, _ in pairs(trackers) do
            addon:SetTrackerDBValue(trackers, trackerID, value, "_TOGGLE_")
        end
        local newCount = addon:GetObjectiveCount(self)

        -- Send custom alert
        self.frame:GetScript("OnEvent")(self.frame, "FARMINGBAR_UPDATE_COUNT", oldCount, newCount)

        self:UpdateLayers()
    end,

    UpdateAutoLayer = function(self)
        -- AccountOverlay
        if not self:IsEmpty() and addon:GetDBValue("profile", "style.buttonLayers.AccountOverlay") then
            local total, included, notIncluded = addon:GetObjectiveIncludedLayers(self, "includeAllChars")
            if notIncluded == total then
                self.AccountOverlay:Hide()
            else
                self.AccountOverlay:SetDesaturated(included ~= total and 1)
                self.AccountOverlay:Show()
            end
        else
            self.AccountOverlay:Hide()
        end

        -- AutoCastable
        if not self:IsEmpty() and addon:GetDBValue("profile", "style.buttonLayers.AutoCastable") then
            local total, included, notIncluded = addon:GetObjectiveIncludedLayers(self, "includeBank")
            if notIncluded == total then
                self.AutoCastable:Hide()
            else
                self.AutoCastable:SetDesaturated(included ~= total and 1)
                self.AutoCastable:Show()
            end
        else
            self.AutoCastable:Hide()
        end
    end,

    UpdateBorder = function(self)
        self.Border:Hide()
        if not self:IsEmpty() and addon:GetDBValue("profile", "style.buttonLayers.Border") then
            local itemQuality = 0

            for k, v in pairs(self:GetButtonDB().trackers) do
                local trackerType, trackerID = addon:ParseTrackerKey(k)
                itemQuality = trackerType == "ITEM" and max(itemQuality, C_Item.GetItemQualityByID(trackerID) or 0) or itemQuality
            end

            if itemQuality > 1 then
                local r, g, b = GetItemQualityColor(itemQuality)
                self.Border:SetVertexColor(r, g, b, 1)
                self.Border:Show()
            end
        end
    end,

    UpdateCooldown = function(self)
        self.Cooldown:SetDrawEdge(addon:GetDBValue("profile", "style.buttonLayers.CooldownEdge"))
    end,

    UpdateDB = function(self)
        local buttonDB = self:GetButtonDB()
        if not buttonDB then
            return
        end

        local template = buttonDB.template
        if template then
            local template_ref = addon:GetDBValue("global", "objectives")[template]
            -- Check for changes in template
            for k, v in pairs(template_ref) do
                if k ~= "instances" then
                    if k == "trackers" then
                        for key, value in pairs(v) do
                            local trackerType, trackerID = addon:ParseTrackerKey(key)
                            for K, V in pairs(value) do
                                if buttonDB.trackers[key][K] ~= V then
                                    buttonDB.trackers[key][K] = V
                                    self:UpdateLayers()
                                end
                            end
                        end
                    else
                        if buttonDB[k] ~= v then
                            buttonDB[k] = v
                            self:UpdateLayers()
                        end
                    end
                end
            end
            for k, v in pairs(buttonDB.trackers) do
                if not template_ref.trackers[k] or template_ref.trackers[k].order == 0 then
                    buttonDB.trackers[k] = nil
                end
            end
        end
    end,

    UpdateLayers = function(self)
        self:SetHidden()
        self:UpdateDB()
        addon:SkinButton(self, addon:GetDBValue("profile", "style.skin"))
        self:SetFontStringSettings("Count")
        self:SetFontStringSettings("Objective")
        self:SetIcon()
        self:SetCount()
        self:UpdateObjective()
        self:UpdateAutoLayer()
        self:UpdateBorder()
        self:UpdateCooldown()
        self:SetAttribute()
        addon:InitializeTrackers()
    end,

    UpdateObjective = function(self)
        local buttonDB = self:GetButtonDB()

        if buttonDB and buttonDB.objective and buttonDB.objective > 0 then
            local formattedObjective, objective = addon.iformat(buttonDB.objective, 2)
            self.Objective:SetText(formattedObjective)

            local count = addon:GetObjectiveCount(self)

            if count >= objective then
                self.Objective:SetTextColor(0, 1, 0, 1)
                if floor(count / objective) > 1 then
                    self.Objective:SetText(formattedObjective .. "*")
                end
            else
                self.Objective:SetTextColor(1, .82, 0, 1)
            end
        else
            self.Objective:SetText("")
        end
    end,
}

-- *------------------------------------------------------------------------
-- Constructor

local function Constructor()
    local frame = CreateFrame("Button", Type .. AceGUI:GetNextWidgetNum(Type), UIParent, "SecureActionButtonTemplate, SecureHandlerDragTemplate")
    frame:SetScale(UIParent:GetEffectiveScale())
    frame:Hide()
    frame:RegisterForClicks("AnyUp")
    frame:RegisterForDrag("LeftButton", "RightButton")
    frame:SetScript("OnDragStart", frame_OnDragStart)
    frame:SetScript("OnDragStop", frame_OnDragStop)
    frame:SetScript("OnEvent", frame_OnEvent)
    frame:SetScript("OnReceiveDrag", frame_OnReceiveDrag)
    frame:SetScript("OnEnter", frame_OnEnter)
    frame:SetScript("OnLeave", frame_OnLeave)
    frame:SetScript("PostClick", frame_PostClick)

    frame:RegisterEvent("SPELL_UPDATE_COOLDOWN")

    local FloatingBG = frame:CreateTexture("$parentFloatingBG", "BACKGROUND", nil, 1)
    FloatingBG:SetAllPoints(frame)

    local Icon = frame:CreateTexture("$parentIcon", "BACKGROUND", nil, 2)
    Icon:SetAllPoints(frame)

    local Flash = frame:CreateTexture("$parentFlash", "BACKGROUND", nil, 3)
    Flash:SetAllPoints(frame)
    Flash:Hide()

    local Border = frame:CreateTexture("$parentBorder", "BORDER", nil, 1)
    Border:SetAllPoints(frame)
    Border:Hide()

    local AccountOverlay = frame:CreateTexture("$parentAccountOverlay", "OVERLAY", nil, 2)
    AccountOverlay:SetAllPoints(frame)

    local AutoCastable = frame:CreateTexture("$parentAutoCastable", "OVERLAY", nil, 3)
    AutoCastable:SetAllPoints(frame)

    local Count = frame:CreateFontString(nil, "OVERLAY", nil, 4)

    local Objective = frame:CreateFontString(nil, "OVERLAY", nil, 4)

    local Cooldown = CreateFrame("Cooldown", "$parentCooldown", frame, "CooldownFrameTemplate")
    Cooldown:SetAllPoints(frame)

    local objectiveEditBox = CreateFrame("EditBox", nil, frame)
    objectiveEditBox:SetFrameStrata("TOOLTIP")
    objectiveEditBox:SetPoint("TOPLEFT")
    objectiveEditBox:SetPoint("TOPRIGHT")
    objectiveEditBox:SetAutoFocus(false)
    objectiveEditBox:SetMaxLetters(15)
    objectiveEditBox:SetFont([[Fonts\FRIZQT__.TTF]], 12, "OUTLINE")

    objectiveEditBox.background = objectiveEditBox:CreateTexture(nil, "BACKGROUND")
    objectiveEditBox.background:SetTexture([[INTERFACE\BUTTONS\WHITE8X8]])
    objectiveEditBox.background:SetVertexColor(0, 0, 0, .5)
    objectiveEditBox.background:SetAllPoints(objectiveEditBox)

    objectiveEditBox:SetScript("OnEnterPressed", objectiveEditBox_OnEnterPressed)
    objectiveEditBox:SetScript("OnEscapePressed", EditBox_OnEscapePressed)
    objectiveEditBox:SetScript("OnEditFocusGained", objectiveEditBox_OnEditFocusGained)
    objectiveEditBox:SetScript("OnEditFocusLost", EditBox_OnEscapePressed)
    objectiveEditBox:SetScript("OnShow", EditBox_OnShow)
    objectiveEditBox:SetScript("OnTextChanged", EditBox_OnTextChanged)

    local quickAddEditBox = CreateFrame("EditBox", nil, frame)
    quickAddEditBox:SetFrameStrata("TOOLTIP")
    quickAddEditBox:SetPoint("BOTTOMLEFT")
    quickAddEditBox:SetPoint("BOTTOMRIGHT")
    quickAddEditBox:SetAutoFocus(false)
    quickAddEditBox:SetMaxLetters(15)
    quickAddEditBox:SetFont([[Fonts\FRIZQT__.TTF]], 12, "OUTLINE")

    quickAddEditBox.background = quickAddEditBox:CreateTexture(nil, "BACKGROUND")
    quickAddEditBox.background:SetTexture([[INTERFACE\BUTTONS\WHITE8X8]])
    quickAddEditBox.background:SetVertexColor(0, 0, 0, .5)
    quickAddEditBox.background:SetAllPoints(quickAddEditBox)

    quickAddEditBox:SetScript("OnEnterPressed", quickAddEditBox_OnEnterPressed)
    quickAddEditBox:SetScript("OnEscapePressed", EditBox_OnEscapePressed)
    quickAddEditBox:SetScript("OnEditFocusLost", EditBox_OnEscapePressed)
    quickAddEditBox:SetScript("OnShow", EditBox_OnShow)
    quickAddEditBox:SetScript("OnTextChanged", EditBox_OnTextChanged)

    local widget = {
        type = Type,
        frame = frame,
        FloatingBG = FloatingBG,
        Icon = Icon,
        Flash = Flash,
        Border = Border,
        AccountOverlay = AccountOverlay,
        AutoCastable = AutoCastable,
        Count = Count,
        Objective = Objective,
        Cooldown = Cooldown,
        objectiveEditBox = objectiveEditBox,
        quickAddEditBox = quickAddEditBox,
    }

    frame.obj, objectiveEditBox.obj, quickAddEditBox.obj = widget, widget, widget

    for method, func in pairs(methods) do
        widget[method] = func
    end

    return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
