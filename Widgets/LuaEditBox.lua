local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)
local AceGUI = LibStub("AceGUI-3.0")
local LSM = LibStub("LibSharedMedia-3.0")

local Type = "FarmingBar_LuaEditBox"
local Version = 1

-- [[ Scripts ]]
local scripts = {
    expandButton_OnClick = function(expandButton)
        local widget = expandButton.obj
        private.options:Hide()

        local editor = AceGUI:Create("FarmingBar_LuaEditor")
        editor:SetTitle(format("%s %s", L.addonName, L["Lua Editor"]))
        editor:LoadCode(widget, widget:GetUserData("OnEnterPressed"))
        editor:SetCallback("OnClose", function(self)
            private:LoadOptions()
        end)
    end,

    editBox_OnTextChanged = function(widget)
        local dbFunc = widget:GetUserData("dbFunc")
        widget.button:SetEnabled(widget:GetText() ~= dbFunc)
    end,
}

--[[ Methods ]]
local methods = {
    --[[ Widget ]]
    OnAcquire = function(widget)
        local editbox = widget.editBox
        addon.indent.enable(editbox, _, 4) -- adds syntax highlighting
    end,

    OnRelease = function(widget)
        addon.indent.disable(widget.editBox)
        widget.editBox:SetEnabled(true)
        widget.button:SetEnabled(true)
    end,

    --[[ Frame ]]
    Initialize = function(widget, dbFunc, OnEnterPressed)
        widget:SetUserData("OnEnterPressed", OnEnterPressed)
        widget:SetCallback("OnEnterPressed", function(...)
            OnEnterPressed(...)
            widget:SetUserData("dbFunc", (select(3, ...)))
        end)
        widget:SetUserData("dbFunc", dbFunc)
    end,

    SetDisabled = function(self, flag)
        self.editBox:SetEnabled(not flag)
        self.button:SetEnabled(not flag)
        self.expandButton:SetEnabled(not flag)
    end,
}

--[[ Constructor ]]
local function Constructor()
    --[[ Frame ]]
    local frame = AceGUI:Create("MultiLineEditBox")
    -- Fix misaligned editbox label
    frame.label:SetHeight(frame.label:GetStringHeight() + 6)
    frame:SetCallback("OnTextChanged", scripts.editBox_OnTextChanged)
    frame.editBox:SetScript("OnTextSet", function(_, ...)
        scripts.editBox_OnTextChanged(frame, ...)
    end)

    local expandButton = CreateFrame("Button", nil, frame.frame, "UIPanelButtonTemplate")
    expandButton:SetText(L["Expand"])
    expandButton:SetHeight(22)
    expandButton:SetWidth(expandButton.Text:GetStringWidth() + 24)
    expandButton:SetPoint("LEFT", frame.button, "RIGHT", 4, 0)
    expandButton:SetScript("OnClick", scripts.expandButton_OnClick)

    --[[ ElvUI skin ]]
    if IsAddOnLoaded("ElvUI") then
        local E = unpack(_G["ElvUI"])
        local S = E:GetModule("Skins")
        S:HandleButton(expandButton)
    end

    --[[ Widget ]]
    local widget = frame
    widget.editBox = frame.editBox
    widget.type = Type
    widget.expandButton = expandButton

    expandButton.obj = widget

    for method, func in pairs(methods) do
        widget[method] = func
    end

    return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
