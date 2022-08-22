local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)
local AceGUI = LibStub("AceGUI-3.0")
local LSM = LibStub("LibSharedMedia-3.0")

local Type = "FarmingBar_LuaEditor"
local Version = 1

-- [[ Scripts ]]
local scripts = {
    editBox_OnTextChanged = function(widget)
        local luaEditBox = widget:GetUserData("luaEditBox")
        local dbFunc = luaEditBox:GetUserData("dbFunc")
        widget.button:SetEnabled(widget:GetText() ~= dbFunc)
    end,
}

--[[ Methods ]]
local methods = {
    --[[ Widget ]]
    OnAcquire = function(widget)
        widget.frame:Show()
        addon.indent.enable(widget.editBox, _, 4) -- adds syntax highlighting
    end,

    OnRelease = function(widget)
        addon.indent.disable(widget.editBox)
    end,

    --[[ Content ]]
    LoadCode = function(widget, luaEditBox, OnEnterPressed)
        widget.editbox:SetUserData("luaEditBox", luaEditBox)
        widget.editbox:SetText(luaEditBox:GetText())
        widget.editbox:SetCallback("OnEnterPressed", function(...)
            OnEnterPressed(...)
            luaEditBox:SetUserData("dbFunc", (select(3, ...)))
            widget.window:Release()
        end)
    end,

    SetStatusText = function(widget, text)
        widget.window:SetStatusText(text)
    end,

    SetTitle = function(widget, title)
        widget.window:SetTitle(title)
    end,

    Show = function(widget)
        widget.frame:Show()
    end,
}

--[[ Constructor ]]
local function Constructor()
    local window = AceGUI:Create("Frame")
    window:SetLayout("FILL")

    local frame = window.frame
    frame:SetClampedToScreen(true)
    frame:SetPoint("CENTER", 0, 0)
    frame:Show()

    local editbox = AceGUI:Create("MultiLineEditBox")
    editbox:SetLabel("")
    editbox:SetCallback("OnTextChanged", scripts.editBox_OnTextChanged)
    editbox.editBox:SetScript("OnTextSet", function(_, ...)
        scripts.editBox_OnTextChanged(editbox, ...)
    end)
    window:AddChild(editbox)

    local widget = {
        type = Type,
        window = window,
        frame = frame,
        editbox = editbox,
        editBox = editbox.editBox,
        statustext = window.statustext,
    }

    window.obj, frame.obj, editbox.obj = widget, widget, widget

    for method, func in pairs(methods) do
        widget[method] = func
    end

    return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
