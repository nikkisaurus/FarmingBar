local addonName = ...
local addon = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

-- *------------------------------------------------------------------------
-- Events

local function DragFrame_OnShow()
    for _, bar in pairs(addon.bars) do
        bar:SetAlpha(true)
    end
end

local function DragFrame_OnEvent(self, event, buttonClicked, ...)
    if event == "GLOBAL_MOUSE_DOWN" then
        -- Clear objective when right clicking or not dropping item on button
        if buttonClicked == "RightButton" or (self:GetObjective() and not strfind(GetMouseFocus():GetName() or "", "^FarmingBar_Button%d")) then
            self:Clear()
            addon.movingButton = nil
        end
    end
end

local function DragFrame_OnUpdate(self)
    if self:IsVisible() then
        local scale, x, y = self:GetEffectiveScale(), GetCursorPosition()
        self:SetPoint("CENTER", nil, "BOTTOMLEFT", (x / scale) + 50, (y / scale) - 20)
    end
end

-- *------------------------------------------------------------------------
-- Methods

local methods = {
    Clear = function(self)
        local widget = addon.movingButton
        if widget then
            widget[1]:ClearObjective()
        end

        self.icon:SetTexture("")
        self.text:SetText("")
        self:Hide()

        for _, bar in pairs(addon.bars) do
            bar:SetAlpha()
        end
    end,

    GetObjective = function(self)
        return self.text:GetText(), self.objectiveInfo
    end,

    LoadObjective = function(self, widget)
        local buttonDB = widget:GetButtonDB()

        self.icon:SetTexture(buttonDB.icon)
        self.icon:SetTexture(addon:GetObjectiveIcon(widget))

        self.text:SetText(buttonDB.title)

        self:Show()
    end,

    LoadObjectiveTemplate = function(self, objectiveTitle)
        local objectiveInfo = addon:GetDBValue("global", "objectives")[objectiveTitle]

        self.icon:SetTexture(objectiveInfo.icon)
        self.icon:SetTexture(addon:GetObjectiveTemplateIcon(objectiveTitle))

        self.text:SetText(objectiveTitle)

        self.objectiveInfo = addon:CloneTable(objectiveInfo)
        self.objectiveInfo.template = objectiveTitle

        self:Show()
    end,
}

-- *------------------------------------------------------------------------

function addon:InitializeDragFrame()
    local DragFrame = CreateFrame("Frame", "FarmingBarDragFrame", UIParent)
    DragFrame:SetSize(20, 20)
    DragFrame:SetPoint("CENTER")
    DragFrame:Hide()
    DragFrame:SetFrameStrata("TOOLTIP")
    addon.DragFrame = DragFrame

--@retail@

    DragFrame:RegisterEvent("GLOBAL_MOUSE_DOWN")
    --@end-retail@
    DragFrame:SetScript("OnUpdate", DragFrame_OnUpdate)
    DragFrame:SetScript("OnEvent", DragFrame_OnEvent)
    DragFrame:SetScript("OnShow", DragFrame_OnShow)

    DragFrame.icon = DragFrame:CreateTexture(nil, "OVERLAY")
    DragFrame.icon:SetAllPoints(DragFrame)
    DragFrame.icon:SetTexture("")

    DragFrame.text = DragFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    DragFrame.text:SetPoint("LEFT", DragFrame.icon, "RIGHT", 5, 0)

    for method, func in pairs(methods) do
        DragFrame[method] = func
    end
end
