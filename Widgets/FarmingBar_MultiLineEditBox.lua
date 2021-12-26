local addonName = ...
local addon = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

-- Optional libraries
local ACD = LibStub("AceConfigDialog-3.0")
local AceGUI = LibStub("AceGUI-3.0", true)
local LSM = LibStub("LibSharedMedia-3.0")

local Type = "FarmingBar_MultiLineEditBox"
local Version = 1

-- *------------------------------------------------------------------------
-- Widget methods

local methods = {
    OnAcquire = function(self)
    end,
}

-- *------------------------------------------------------------------------
-- Constructor

local function Constructor()
    local frame = AceGUI:Create("MultiLineEditBox")
    addon.indent.enable(frame.editBox, _, 4) -- adds syntax highlighting

    local expandButton = CreateFrame("Button", Type .. AceGUI:GetNextWidgetNum(Type) .. "ExpandButton", frame.frame, "UIPanelButtonTemplate")
    expandButton:SetText(L["Expand"])
    expandButton:SetHeight(22)
    expandButton:SetWidth(expandButton.Text:GetStringWidth() + 24)
    expandButton:SetPoint("LEFT", frame.button, "RIGHT", 4, 0)
    expandButton:SetScript("OnClick", function()
        local scope, key = unpack(frame:GetUserData("info"))
        local editor = LibStub("AceGUI-3.0", true):Create("FarmingBar_Editor")
        editor:SetTitle(format("%s %s", L.addon, L["Editor"]))
        editor:LoadCode(scope, key)
        editor:SetCallback("OnClose", function(widget)
            widget.frame:Hide()
            ACD:SelectGroup(addonName, "settings")
            ACD:Open(addonName)
        end)
        ACD:Close(addonName)
        editor.frame:Show()
    end)
    expandButton:SetScript("OnShow", function()
        local option = frame.userdata.option
        local info = option and option.arg

        frame:SetUserData("info", info)
    end)

    if IsAddOnLoaded("ElvUI") then
        local E = unpack(_G["ElvUI"])
        local S = E:GetModule("Skins")
        S:HandleButton(expandButton)
    end

    local widget = frame
    widget.expandButton = expandButton

    for method, func in pairs(methods) do
        widget[method] = func
    end

    return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
