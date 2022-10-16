local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)

local function frame_OnShow()
    for _, bar in pairs(private.bars) do
        bar:SetMouseover()
    end
end

local function frame_OnEvent(self, event, buttonClicked, ...)
    local hasObjective, altWidget = self:GetObjective()
    if event == "GLOBAL_MOUSE_DOWN" and (hasObjective or altWidget) then
        -- Clear objective when right clicking or not dropping item on button
        if buttonClicked == "RightButton" or not strfind(GetMouseFocus():GetName() or "", "^FarmingBar_Button%d") then
            self:Clear()
            if altWidget then
                altWidget:Clear()
            end
        end
    end
end

local function frame_OnUpdate(self)
    if self:IsVisible() then
        local scale, x, y = self:GetEffectiveScale(), GetCursorPosition()
        self:SetPoint("CENTER", nil, "BOTTOMLEFT", (x / scale) + 50, (y / scale) - 20)
    end
end

local methods = {
    Clear = function(self)
        self.icon:SetTexture("")
        self.text:SetText("")
        self:Hide()

        self.objectiveInfo = nil
        self.altWidget = nil

        for _, bar in pairs(private.bars) do
            bar:SetMouseover()
        end
    end,

    GetObjective = function(self)
        return self.objectiveInfo, self.altWidget
    end,

    LoadObjective = function(self, objectiveInfo, objectiveTitle)
        ClearCursor()
        self.icon:SetTexture(private:GetObjectiveIcon(objectiveInfo))
        self.text:SetText(objectiveTitle or "")
        self.objectiveInfo = addon:CloneTable(objectiveInfo)
        self:Show()
    end,

    SetAltWidget = function(self, widget)
        self.altWidget = widget
    end,
}

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
