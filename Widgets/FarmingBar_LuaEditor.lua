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

    OnRelease = function(self)
        self.window.obj:Release()
        self.editbox.obj:Release()
    end,

    LoadCode = function(self, info, text)
        self.editbox:SetUserData("info", info)
        self.editbox:SetText(text)
        self.frame:Show()
    end,

    SetStatusText = function(self, info)
        local scope, key, func, args = unpack(info)
        if not func then return end

        local editbox = self.editbox
        local window = self.window

        editbox.editBox:HookScript("OnUpdate", function()
            -- Update preview while typing
            local preview, err = func(addon, addon.unpack(args, {}), editbox:GetText())
            local saved = func(addon, addon.unpack(args, {}), _, info)
            local changed = preview ~= saved

            window:SetStatusText(changed and preview or saved)

            if err or not changed then
                editbox.button:Disable()
            else
                editbox.button:Enable()
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
