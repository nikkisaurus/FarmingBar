local addonName = ...
local addon = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

-- Optional libraries
local ACD = LibStub("AceConfigDialog-3.0")
local AceGUI = LibStub("AceGUI-3.0", true)
local LSM = LibStub("LibSharedMedia-3.0")

local Type = "FarmingBar_Editor"
local Version = 1

-- *------------------------------------------------------------------------
-- Widget methods

local methods = {
    OnAcquire = function(self)
        self.frame:Hide()
    end,

    LoadCode = function(self, ...)
        self.editbox:SetUserData("dbArgs", {...})
        self.editbox:SetText(addon:GetDBValue(unpack(self.editbox:GetUserData("dbArgs"))))
        self.frame:Show()
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
    editbox:SetCallback("OnEnterPressed", function(self, _, text)
        tinsert(self:GetUserData("dbArgs"), text)
        addon:SetDBValue(unpack(self:GetUserData("dbArgs")))
        self.obj:Release()
    end)
    window:AddChild(editbox)

    local widget = {
        type = Type,
        window = window,
        frame = frame,
        editbox = editbox,
    }

    window.obj, frame.obj, editbox.obj = widget, widget, widget

    for method, func in pairs(methods) do
        widget[method] = func
    end

    return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
