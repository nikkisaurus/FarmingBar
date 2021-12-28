local addonName = ...
local addon = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

-- Optional libraries
local ACD = LibStub("AceConfigDialog-3.0")
local AceGUI = LibStub("AceGUI-3.0", true)
local LSM = LibStub("LibSharedMedia-3.0")

local Type = "FarmingBar_LuaEditor"
local Version = 1

-- *------------------------------------------------------------------------
-- Widget methods

local methods = {
    OnAcquire = function(self)
        self.frame:Hide()
    end,

    LoadCode = function(self, info, text)
        self.editbox:SetUserData("info", info)
        self.editbox:SetText(text)
        self.frame:Show()
    end,

    SetStatusText = function(self, info)
        local func = addon[info[3]] and addon[info[3]]
        if not func then return end

        local editbox = self.editbox
        local window = self.window

        editbox.editBox:HookScript("OnUpdate", function()
            local preview, err = func(addon, editbox:GetText(), info[4])
            if err then
                editbox.button:Disable()
                window:SetStatusText(preview)
            else
                editbox.button:Enable()
                if preview ~= window.statustext:GetText() then
                    window:SetStatusText(preview)
                end
            end
        end)
    end,

    SetTitle = function(self, title)
        self.window:SetTitle(title)
    end,
}

-- *------------------------------------------------------------------------
-- Constructor

local function Constructor()
    local window = AceGUI:Create("Frame")
    window:SetLayout("FILL")

    local frame = window.frame
    frame:SetClampedToScreen(true)
    frame:SetPoint("CENTER", 0, 0)
    frame:Show()

    local editbox = AceGUI:Create("MultiLineEditBox")
    addon.indent.enable(editbox.editBox, _, 4) -- adds syntax highlighting
    editbox:SetLabel("")
    window:AddChild(editbox)

    editbox:SetCallback("OnEnterPressed", function(self, _, text)
        local info = self:GetUserData("info")
        addon:SetDBValue(info[1], info[2], text)
        self.obj:Release()
    end)

    local widget = {
        type = Type,
        window = window,
        frame = frame,
        editbox = editbox,
        statustext = window.statustext
    }

    window.obj, frame.obj, editbox.obj = widget, widget, widget

    for method, func in pairs(methods) do
        widget[method] = func
    end

    return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
