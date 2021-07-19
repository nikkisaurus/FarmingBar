local addonName = ...
local addon = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

local ACD = LibStub("AceConfigDialog-3.0")
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
local LSM = LibStub("LibSharedMedia-3.0")

------------------------------------------------------------

local _G = _G
local fmod, floor = math.fmod, math.floor
local format, strlower, tonumber = string.format, string.lower, tonumber

------------------------------------------------------------

local Type = "FarmingBar_Button"
local Version = 1

--*------------------------------------------------------------------------

local postClickMethods = {
    clearObjective = function(self, ...)
        self.obj:ClearObjective()
    end,

    ------------------------------------------------------------

    moveObjective = function(self, ...)
        local widget = self.obj

        if not widget:IsEmpty() and not addon.moveButton then
            widget.Flash:Show()
            UIFrameFlash(widget.Flash, 0.5, 0.5, -1)
            addon.moveButton = {widget, addon:CloneTable(widget:GetButtonDB())}
        elseif addon.moveButton then
            widget:SwapButtons(addon.moveButton)
        end
    end,

    ------------------------------------------------------------

    showObjectiveEditBox = function(self, ...)
        local widget = self.obj
        if not widget:IsEmpty() then
            widget.objectiveEditBox:Show()
        end
    end,

    ------------------------------------------------------------

    showQuickAddEditBox = function(self, ...)
        self.obj.quickAddEditBox:Show()
    end,

    ------------------------------------------------------------

    includeAllChars = function(self, ...)
        local widget = self.obj
        if not widget:IsEmpty() then
            if addon.tcount(widget:GetButtonDB().trackers) > 1 then
                addon:InitializeObjectiveEditorOptions(widget)
                ACD:SelectGroup(addonName.."ObjectiveEditor", "includeAllChars")
                ACD:Open(addonName.."ObjectiveEditor")
            else
                widget:ToggleTrackerValue("includeAllChars")
            end
        end
    end,

    ------------------------------------------------------------

    includeBank = function(self, ...)
        local widget = self.obj
        if not widget:IsEmpty() then
            if addon.tcount(widget:GetButtonDB().trackers) > 1 then
                addon:InitializeObjectiveEditorOptions(widget)
                ACD:SelectGroup(addonName.."ObjectiveEditor", "includeBank")
                ACD:Open(addonName.."ObjectiveEditor")
            else
                widget:ToggleTrackerValue("includeBank")
            end
        end
    end,

    ------------------------------------------------------------

    includeGuildBank = function(self, ...)
        print("Keybind in maintenenance.")
    end,

    ------------------------------------------------------------

    moveObjectiveToBank = function(self, ...)
        print("Keybind in maintenenance.")
    end,

    ------------------------------------------------------------

    moveAllToBank = function(self, ...)
        print("Keybind in maintenenance.")
    end,
}

--*------------------------------------------------------------------------

local function EditBox_OnEscapePressed(self)
    self:ClearFocus()
    self:Hide()
end

------------------------------------------------------------

local function EditBox_OnShow(self)
    local widget = self.obj
    local width = widget.frame:GetWidth()
    self:SetSize(width, width / 2)
    self:SetFocus()
end

------------------------------------------------------------

local function EditBox_OnTextChanged(self)
    self:SetText(string.gsub(self:GetText(), "[%s%c%p%a]", ""))
end

------------------------------------------------------------

local function frame_OnDragStart(self, buttonClicked, ...)
    local widget = self.obj
    if widget:IsEmpty() then return end

    local keybinds = addon:GetDBValue("global", "settings.keybinds.button.dragObjective")
    if buttonClicked == keybinds.button then
        local mod = addon:GetModifierString()

        if mod == keybinds.modifier then
            widget:SetUserData("isDragging", true)
            addon.moveButton = {widget, addon:CloneTable(widget:GetButtonDB())}
            addon.DragFrame:LoadObjective(widget)
            -- widget:ClearObjective()
        end
    end
end

------------------------------------------------------------

local function frame_OnDragStop(self)
    self.obj:SetUserData("isDragging")
end

------------------------------------------------------------

local function frame_OnEvent(self, event, ...)
    local widget = self.obj
    if widget:IsEmpty() then return end
    local alerts = addon:GetBarDBValue("alerts", widget:GetBarID(), true)
    local buttonDB = widget:GetButtonDB()

    if event == "BAG_UPDATE" or event == "BAG_UPDATE_COOLDOWN" or event == "CURRENCY_DISPLAY_UPDATE" or event == "FARMINGBAR_UPDATE_COUNT" then
        local oldCount, newCount = ...
        if event ~= "FARMINGBAR_UPDATE_COUNT" then
            oldCount = widget:GetCount()
            newCount = addon:GetObjectiveCount(widget)
        end
        local objective = widget:GetUserData("objective")
        local alert, soundID, barAlert

        if newCount ~= oldCount then
            if not alerts.muteAll then
                if objective then
                    if alerts.completedObjectives or (not alerts.completedObjectives and ((oldCount < objective) or (newCount < oldCount and newCount < objective))) then
                        alert = addon:GetDBValue("global", "settings.alerts.button.format.withObjective")

                        if oldCount < objective and newCount >= objective then
                            soundID = "objectiveComplete"
                            barAlert = "complete"
                        else
                            soundID = oldCount < newCount and "farmingProgress"
                            -- Have to check if we lost an objective
                            if oldCount >= objective and newCount < objective then
                                barAlert = "lost"
                            end
                        end
                    end
                else
                    alert = addon:GetDBValue("global", "settings.alerts.button.format.withoutObjective")
                    soundID = oldCount < newCount and "progress"
                end

                local alertInfo = {
                    objectiveTitle = buttonDB.title,
                    objective = objective,
                    oldCount = oldCount,
                    newCount = newCount,
                    difference = newCount - oldCount,
                }

                -- Play alerts
                if addon:GetDBValue("global", "settings.alerts.button.chat") and alert then
                    addon:Print(addon:ParseAlert(alert, alertInfo))
                end

                if addon:GetDBValue("global", "settings.alerts.button.screen") and alert then
                    -- if not addon.CoroutineUpdater:IsVisible() then
                        UIErrorsFrame:AddMessage(addon:ParseAlert(alert, alertInfo), 1, 1, 1)
                    -- else
                    --     addon.CoroutineUpdater.alert:SetText(addon:ParseAlert(alert, alertInfo))
                    -- end
                end

                if addon:GetDBValue("global", "settings.alerts.button.sound.enabled") and soundID then
                    PlaySoundFile(LSM:Fetch("sound", addon:GetDBValue("global", "settings.alerts.button.sound")[soundID]))
                end

                if barAlert then
                    -- local progressCount, progressTotal = self:GetBar():GetProgress()

                    -- if barAlert == "complete" then
                    --     progressCount = progressCount - 1
                    -- elseif barAlert == "lost" then
                    --     progressCount = progressCount + 1
                    -- end

                    -- self:GetBar():AlertProgress(progressCount, progressTotal)
                end
            end

            widget:UpdateLayers()
        end
    elseif event == "PLAYER_REGEN_ENABLED" then
        widget:SetAttribute()
        self:UnregisterEvent(event)
        -- TODO: print combat left
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local buttonDB = widget:GetButtonDB()
        local validTrackerID, trackerType = addon:ValidateObjectiveData(buttonDB.action, buttonDB.actionInfo)

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

------------------------------------------------------------

local function frame_OnReceiveDrag(self)
    local widget = self.obj
    local objectiveTitle, objectiveInfo = addon.DragFrame:GetObjective()

    if addon.moveButton then
        if addon.moveButton[1] == self.obj then
            addon.moveButton = nil
        else
            widget:SwapButtons(addon.moveButton)
        end
    elseif objectiveTitle then
        addon:CreateObjectiveFromDragFrame(widget, objectiveInfo)
    else
        widget:ClearObjective()
        addon:CreateObjectiveFromCursor(widget)
    end

    addon.DragFrame:Clear()
end

------------------------------------------------------------

local function frame_PostClick(self, buttonClicked, ...)
    local widget = self.obj
    if widget:GetUserData("isDragging") then return end
    local cursorType, cursorID = GetCursorInfo()
    local objectiveTitle, objectiveInfo = addon.DragFrame:GetObjective()

    if cursorType == "item" and not IsModifierKeyDown() and buttonClicked == "LeftButton" then
        widget:ClearObjective()
        addon:CreateObjectiveFromCursor(widget)
        return
    elseif objectiveTitle then
        if addon.moveButton then
            widget:SwapButtons(addon.moveButton)
        else
            addon:CreateObjectiveFromDragFrame(widget, objectiveInfo)
        end
        addon.DragFrame:Clear()
        return
    end

    ClearCursor()

    ------------------------------------------------------------

    local keybinds = addon.db.global.settings.keybinds.button

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

------------------------------------------------------------

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

------------------------------------------------------------

local function objectiveEditBox_OnEditFocusGained(self)
    self:SetText(self.obj:GetObjective() or "")
    C_Timer.After(.001, function()
        self:HighlightText()
    end)
end

------------------------------------------------------------

local function quickAddEditBox_OnEnterPressed(self)
    local itemID = tonumber(self:GetText())

    if itemID then
        if GetItemInfoInstant(itemID) then
            addon:CreateObjectiveFromItemID(self.obj, itemID)
        else
            addon:ReportError(format(L.InvalidItemID, itemID))
        end
    end

    self:SetText("")
    self:ClearFocus()
    self:Hide()
end

--*------------------------------------------------------------------------

local methods = {
    OnAcquire = function(self)
        self:SetUserData("tooltip", "GetButtonTooltip")

        self.frame:ClearAllPoints()
        self.frame:Show()

        self.objectiveEditBox:Hide()
        self.quickAddEditBox:Hide()

        self:UpdateLayers()
    end,

    ------------------------------------------------------------

    Anchor = function(self)
        local barDB = self:GetUserData("barDB")
        local buttons = self:GetUserData("buttons")
        local buttonID = self:GetUserData("buttonID")

        ------------------------------------------------------------

        local anchor, relativeAnchor, xOffset, yOffset = addon:GetAnchorPoints(barDB.grow[1])

        self:ClearAllPoints()
        if buttonID == 1 then
            self:SetPoint(anchor, self:GetUserData("bar").frame, relativeAnchor, xOffset * barDB.button.padding, yOffset * barDB.button.padding)
        else
            if fmod(buttonID, barDB.buttonWrap) == 1 or barDB.buttonWrap == 1 then
                local anchor, relativeAnchor, xOffset, yOffset = addon:GetRelativeAnchorPoints(barDB.grow)
                self:SetPoint(anchor, buttons[buttonID - barDB.buttonWrap].frame, relativeAnchor, xOffset * barDB.button.padding, yOffset * barDB.button.padding)
            else
                self:SetPoint(anchor, buttons[buttonID - 1].frame, relativeAnchor, xOffset * barDB.button.padding, yOffset * barDB.button.padding)
            end
        end
    end,

    ------------------------------------------------------------

    ApplySkin = function(self)
        addon:SkinButton(self, self:GetDBValue("profile", "style.skin"))
        self:UpdateLayers()
    end,

    ------------------------------------------------------------

    ClearObjective = function(self)
        self:SetUserData("objective")
        local buttonDB = self:GetButtonDB()
        for k, v in pairs(buttonDB) do
            if k == "trackers" then
                for trackerKey, trackerInfo in pairs(v) do
                    buttonDB.trackers[trackerKey] = nil
                end
            else
                buttonDB[k] = addon.db.char.bars[0].objectives[0][k]
            end
        end

        self.frame:UnregisterEvent("BAG_UPDATE")
        self.frame:UnregisterEvent("BAG_UPDATE_COOLDOWN")
        --@retail@
        self.frame:UnregisterEvent("CURRENCY_DISPLAY_UPDATE")
        --@end-retail@

        self:UpdateLayers()
        addon:UpdateButtons()
    end,

    ------------------------------------------------------------

    GetBarDB = function(self)
        return self:GetUserData("barDB")
    end,

    ------------------------------------------------------------

    GetBarID = function(self)
        return self:GetUserData("barID")
    end,

    ------------------------------------------------------------

    GetButtonDB = function(self)
        return self:GetBarID() and addon:GetBarDBValue(nil, self:GetUserData("barID"), true).objectives[self:GetUserData("buttonID")]
    end,

    ------------------------------------------------------------

    GetButtonID = function(self)
        local barID = self:GetUserData("barID")
        local buttonID = self:GetUserData("buttonID")

        return format("%d:%d", barID, buttonID)
    end,

    ------------------------------------------------------------

    GetCount = function(self)
        return self:GetUserData("count") or 0
    end,
    ------------------------------------------------------------

    GetObjective = function(self)
        return not self:IsEmpty() and self:GetButtonDB().objective
    end,

    ------------------------------------------------------------

    GetObjectiveTitle = function(self)
        return not self:IsEmpty() and self:GetButtonDB().title
    end,

    ------------------------------------------------------------

    IsEmpty = function(self)
        return not self:GetBarID() or self:GetButtonDB().title == ""
    end,

    ------------------------------------------------------------

    SetAlpha = function(self)
        self.frame:SetAlpha(self:GetUserData("barDB").alpha)
    end,

    ------------------------------------------------------------

    SetAttribute = function(self)
        local info = addon:GetDBValue("global", "settings.keybinds.button.useItem")
        local buttonType = (info.modifier ~= "" and (info.modifier.."-") or "").."type"..(info.button == "RightButton" and 2 or 1)
        local isEmpty = self:IsEmpty()
        local buttonDB = self:GetButtonDB()

        if not isEmpty and self.frame:GetAttribute(buttonType) == "macro" and buttonDB.action == "MACROTEXT" then
            if self.frame:GetAttribute("macrotext") == buttonDB.actionInfo then
                return
            end
        elseif not isEmpty and self.frame:GetAttribute(buttonType) == "item" and buttonDB.action == "ITEM" then
            if self.frame:GetAttribute("item") == ("item"..buttonDB.actionInfo) then
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

        if isEmpty then return end

        if buttonDB.action == "ITEM" and buttonDB.actionInfo then
            self.frame:SetAttribute(buttonType, "item")
            self.frame:SetAttribute("item", "item:"..buttonDB.actionInfo)
        elseif buttonDB.action == "MACROTEXT" then
            self.frame:SetAttribute(buttonType, "macro")
            self.frame:SetAttribute("macrotext", buttonDB.actionInfo)
        end
    end,

    ------------------------------------------------------------

    SetBar = function(self, bar, buttonID)
        self:SetUserData("bar", bar)
        self:SetUserData("barID", bar:GetUserData("barID"))
        self:SetUserData("barDB", bar:GetUserData("barDB"))
        self:SetUserData("buttons", bar:GetUserData("buttons"))
        self:SetUserData("buttonID", buttonID)

        self:Anchor()
        self:SetAlpha()
        self:SetScale()
        self:SetSize(bar.frame:GetWidth() / .9, bar.frame:GetHeight() / .9)
        self:SetHidden()
        self:UpdateLayers()
    end,

    ------------------------------------------------------------

    SetCount = function(self)
        local style = addon:GetDBValue("profile", "style.font.fontStrings.count")
        local isEmpty = self:IsEmpty()
        if not isEmpty then
            self:SetUserData("count", addon:GetObjectiveCount(self))
        end

        self.Count:SetText(not isEmpty and addon.iformat(self:GetCount(), 2, true) or "")
        self:UpdateObjective()

        if isEmpty then return end

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
            local total_char, included_char, notIncluded_char = addon:IsObjectiveAutoLayerIncluded(self, "includeAllChars")
            local total_bank, included_bank, notIncluded_bank = addon:IsObjectiveAutoLayerIncluded(self, "includeBank")

            if notIncluded_char == total_char and notIncluded_bank == total_bank then
                -- Neither includeAllChars or includeBank
                self.Count:SetTextColor(1, 1, 1, 1)
            elseif included_char == total_char then
                if included_bank == total_bank then
                    -- includeAllChars and includeBank
                    self.Count:SetTextColor(64/255, 224/255, 208/255, 1)
                else
                    -- includeAllChars
                    self.Count:SetTextColor(1, 31/51, 0, 1)
                end
            elseif included_bank == total_bank then
                -- includeBank
                self.Count:SetTextColor(1, .82, 0, 1)
            else
                -- Mixture
                self.Count:SetTextColor(0.5, 0.5, 0.5, 1)
            end

            -- local total, included, notIncluded = addon:IsObjectiveAutoLayerIncluded(self, "includeAllChars")

            -- if notIncluded == total  then
            --     self.Count:SetTextColor(1, 1, 1, 1)
            -- elseif included == total then
            --     local total2, included2, notIncluded2 = addon:IsObjectiveAutoLayerIncluded(self, "includeBank")

            --     if notIncluded == total  then
            --         self.Count:SetTextColor(1, 31/51, 0, 1)
            --     elseif included == total then
            --         self.Count:SetTextColor(64/255, 224/255, 208/255, 1)
            --     else
            --         self.Count:SetTextColor(.5, .5, .5, 1)
            --     end
            -- else
            --     self.Count:SetTextColor(.5, .5, .5, 1)
            -- end
        elseif style.style == "INCLUDEALLCHARS" then
            local total, included, notIncluded = addon:IsObjectiveAutoLayerIncluded(self, "includeAllChars")
            if notIncluded == total  then
                self.Count:SetTextColor(1, 1, 1, 1)
            elseif included == total then
                self.Count:SetTextColor(1, 31/51, 0, 1)
            else
                self.Count:SetTextColor(.5, .5, .5, 1)
            end
        elseif style.style == "INCLUDEBANK" then
            local total, included, notIncluded = addon:IsObjectiveAutoLayerIncluded(self, "includeBank")
            if notIncluded == total  then
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

    ------------------------------------------------------------

    SetDBValue = function(self, key, value)
        -- addon:SetBarDBValue(key, value, self:GetBarID(), isCharDB)
        addon:SetButtonDBValues(key, value, self:GetBarID(), self:GetUserData("buttonID"))
    end,

    ------------------------------------------------------------

    SetFontStringSettings = function(self, fontString)
        local fontDB = addon:GetDBValue("profile", "style.font")
        self.Count:SetFont(LSM:Fetch("font", fontDB.face), fontDB.size, fontDB.outline)
        self.Objective:SetFont(LSM:Fetch("font", fontDB.face), fontDB.size, fontDB.outline)

        if not self:GetUserData("barDB") or not self:GetUserData("barDB").button then return end
        local db = self:GetUserData("barDB").button.fontStrings[strlower(fontString)]

        self[fontString]:ClearAllPoints()
        self[fontString]:SetSize(0, 0)

        self[fontString]:SetPoint(db.anchor, self.frame, db.anchor, db.xOffset, db.yOffset)
        self[fontString]:SetJustifyH((db.anchor:find("RIGHT") and "RIGHT") or (db.anchor:find("LEFT") and "LEFT") or "CENTER")
    end,

    ------------------------------------------------------------

    SetHidden = function(self)
        if self:GetUserData("barDB").hidden then
            self.frame:Hide()
        else
            self.frame:Show()
        end
    end,

    ------------------------------------------------------------

    SetIcon = function(self)
        self.Icon:SetTexture(self:IsEmpty() and "" or addon:GetObjectiveIcon(self))
    end,

    ------------------------------------------------------------

    SetObjective = function(self, objective)
        objective = tonumber(objective)
        self:SetUserData("objective", objective)
        self:SetDBValue("objective", objective)
        self:UpdateObjective()
        addon:UpdateButtons()
    end,

    ------------------------------------------------------------

    SetPoint = function(self, ...) --point, anchor, relpoint, x, y
        self.frame:SetPoint(...)
    end,

    ------------------------------------------------------------

    SetScale = function(self)
        self.frame:SetScale(self:GetUserData("barDB").scale)
    end,

    ------------------------------------------------------------

    SetSize = function(self, width, height)
        self.frame:SetSize(width, height)
        self.Count:SetWidth(width)
        self.Objective:SetWidth(width)
    end,

    ------------------------------------------------------------

    SwapButtons = function(self, moveButton)
        local buttonDB = {trackers = {}}
        local currentButtonDB = self:GetButtonDB()
        local moveButtonDB = moveButton[1]:GetButtonDB()

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

        UIFrameFlashStop(moveButton[1].Flash)
        moveButton[1].Flash:Hide()

        self:UpdateLayers()
        moveButton[1]:UpdateLayers()
        addon.moveButton = nil
    end,

    ------------------------------------------------------------

    ToggleTrackerValue = function(self, value)
        if value == "includeAllChars" then
            local missingDependencies = self:IsDataStoreLoaded()
            if #missingDependencies > 0 then
                options["missingDependencies"] = {
                    order = 0,
                    type = "description",
                    width = "full",
                    name = format(L.MissingIncludeAllCharsDependecies, strjoin(", ", unpack(missingDependencies)))
                }
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

    ------------------------------------------------------------

    UpdateAutoLayer = function(self)
        -- AccountOverlay
        if not self:IsEmpty() and addon:GetDBValue("profile", "style.buttonLayers.AccountOverlay") then
            local total, included, notIncluded = addon:IsObjectiveAutoLayerIncluded(self, "includeAllChars")
            if notIncluded == total  then
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
            local total, included, notIncluded = addon:IsObjectiveAutoLayerIncluded(self, "includeBank")
            if notIncluded == total  then
                self.AutoCastable:Hide()
            else
                self.AutoCastable:SetDesaturated(included ~= total and 1)
                self.AutoCastable:Show()
            end
        else
            self.AutoCastable:Hide()
        end
    end,

    ------------------------------------------------------------

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

    ------------------------------------------------------------

    UpdateCooldown = function(self)
        self.Cooldown:SetDrawEdge(addon:GetDBValue("profile", "style.buttonLayers.CooldownEdge"))
    end,

    ------------------------------------------------------------

    UpdateEvents = function(self)
        if self:IsEmpty() then
            self.frame:UnregisterEvent("BAG_UPDATE")
            self.frame:UnregisterEvent("BAG_UPDATE_COOLDOWN")
            --@retail@
            self.frame:UnregisterEvent("CURRENCY_DISPLAY_UPDATE")
            --@end-retail@
        else
            self.frame:RegisterEvent("BAG_UPDATE")
            self.frame:RegisterEvent("BAG_UPDATE_COOLDOWN")
            --@retail@
            self.frame:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
            --@end-retail@
        end
    end,

    ------------------------------------------------------------

    UpdateLayers = function(self)
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
        self:UpdateEvents()
    end,

    ------------------------------------------------------------

    UpdateObjective = function(self)
        local buttonDB = self:GetButtonDB()

        if buttonDB and buttonDB.objective and buttonDB.objective > 0 then
            local formattedObjective, objective = addon.iformat(buttonDB.objective, 2)
            self.Objective:SetText(formattedObjective)

            local count = addon:GetObjectiveCount(self)

            if count >= objective then
                self.Objective:SetTextColor(0, 1 , 0, 1)
                if floor(count / objective) > 1 then
                    self.Objective:SetText(formattedObjective.."*")
                end
            else
                self.Objective:SetTextColor(1, .82, 0, 1)
            end
        else
            self.Objective:SetText("")
        end
    end,
}

--*------------------------------------------------------------------------

local function Constructor()
    local frame = CreateFrame("Button", Type.. AceGUI:GetNextWidgetNum(Type), UIParent, "SecureActionButtonTemplate, SecureHandlerDragTemplate")
	frame:Hide()
    frame:RegisterForClicks("AnyUp")
    frame:RegisterForDrag("LeftButton", "RightButton")
	frame:SetScript("OnDragStart", frame_OnDragStart)
	frame:SetScript("OnDragStop", frame_OnDragStop)
	frame:SetScript("OnEvent", frame_OnEvent)
	frame:SetScript("OnReceiveDrag", frame_OnReceiveDrag)
    frame:SetScript("PostClick", frame_PostClick)

    frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    frame:RegisterEvent("BANKFRAME_OPENED")
    frame:RegisterEvent("BANKFRAME_CLOSED")

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


    ------------------------------------------------------------

    local widget = {
		type  = Type,
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