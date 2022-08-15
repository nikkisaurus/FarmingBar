local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)

--[[ Callbacks ]]
local function frame_OnShow()
    for _, bar in pairs(private.bars) do
        bar:SetAlpha(bar:GetDB().alpha, true)
    end
end

local function frame_OnEvent(self, event, buttonClicked, ...)
    if event == "GLOBAL_MOUSE_DOWN" and (self:GetObjective() or self:GetAlternateObjective()) then
        -- Clear objective when right clicking or not dropping item on button
        if buttonClicked == "RightButton" or not strfind(GetMouseFocus():GetName() or "", "^FarmingBar_Button%d") then
            self:Clear()
            -- addon.movingButton = nil
        end
    end
end

local function frame_OnUpdate(self)
    if self:IsVisible() then
        local scale, x, y = self:GetEffectiveScale(), GetCursorPosition()
        self:SetPoint("CENTER", nil, "BOTTOMLEFT", (x / scale) + 50, (y / scale) - 20)
    end
end

--[[ Methods ]]
local methods = {
    Clear = function(self)
        -- local widget = addon.movingButton
        -- if widget then
        --     widget[1]:ClearObjective()
        -- end

        self.icon:SetTexture("")
        self.text:SetText("")
        self:Hide()

        for _, bar in pairs(private.bars) do
            bar:SetAlpha(bar:GetDB().alpha, true)
        end
    end,

    GetObjective = function(self)
        return self.text:GetText()
    end,

    GetAlternateObjective = function(self)
        -- return self.text:GetText(), self.objectiveInfo
    end,

    LoadObjective = function(self, objectiveTitle)
        local objectiveInfo = private.db.global.objectives[objectiveTitle]
        self.icon:SetTexture(private:GetObjectiveIcon(objectiveInfo))
        self.text:SetText(objectiveTitle)
        self.objectiveInfo = addon.CloneTable(objectiveInfo)
        self:Show()
    end,
}

--[[ Widget ]]
function private:InitializeObjectiveFrame()
    local frame = CreateFrame("Frame", "FarmingBarObjectiveFrame", UIParent)
    frame:SetSize(20, 20)
    frame:SetPoint("CENTER")
    frame:Hide()
    frame:SetFrameStrata("TOOLTIP")
    frame:RegisterEvent("GLOBAL_MOUSE_DOWN")
    private.ObjectiveFrame = frame

    frame:SetScript("OnUpdate", frame_OnUpdate)
    frame:SetScript("OnEvent", frame_OnEvent)
    frame:SetScript("OnShow", frame_OnShow)

    frame.icon = frame:CreateTexture(nil, "OVERLAY")
    frame.icon:SetAllPoints(frame)
    frame.icon:SetTexture("")

    frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.text:SetPoint("LEFT", frame.icon, "RIGHT", 5, 0)

    for method, func in pairs(methods) do
        frame[method] = func
    end
end
