local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)
local AceGUI = LibStub("AceGUI-3.0")
local LSM = LibStub("LibSharedMedia-3.0")

local Type = "FarmingBar_LuaEditor"
local Version = 1

local scripts = {
    OnTextChanged = function(editbox)
        editbox.obj.button:Enable()
    end,

    OnTextSet = function(editbox)
        editbox.obj.button:Enable()
    end,
}

local methods = {
    OnAcquire = function(widget)
        widget:Show()
        addon.indent.enable(widget.editbox, _, 4) -- adds syntax highlighting
        widget.status = {}
    end,

    OnRelease = function(widget)
        addon.indent.disable(widget.editbox)

        for script, _ in pairs(scripts) do
            widget.editbox:HookScript(script)
        end

        widget.window.closebutton:HookScript("OnClick")
    end,

    LoadCode = function(widget, sourceEditbox, OnEnterPressed, validate)
        widget.editbox:SetText(sourceEditbox:GetText())
        widget.editbox.obj:SetCallback("OnEnterPressed", function(...)
            local validated = validate(select(3, ...))
            if type(validated) == "boolean" and validated then
                private:LoadOptions()
                widget.window:Release()

                OnEnterPressed(...)
            else
                C_Timer.After(0.25, function()
                    widget.button:Enable()
                end)
            end
        end)
    end,

    SetStatusText = function(widget, text)
        widget.statustext:SetText(text)
    end,

    Show = function(widget)
        widget.frame:Show()
    end,
}

local function Constructor()
    local window = AceGUI:Create("Window")
    window:SetLayout("FILL")
    window:SetTitle(L.addonName .. " " .. L["Lua Editor"])

    window.closebutton:HookScript("OnClick", function()
        private:LoadOptions()
    end)

    local frame = window.frame
    frame:SetClampedToScreen(true)
    frame:SetPoint("CENTER", 0, 0)
    frame:Hide()

    local editbox = AceGUI:Create("MultiLineEditBox")
    editbox:SetLabel("")
    window:AddChild(editbox)

    for script, func in pairs(scripts) do
        editbox.editBox:HookScript(script, func)
    end

    local statustext = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    statustext:SetPoint("TOPLEFT", editbox.button, "TOPRIGHT", 2, 0)
    statustext:SetPoint("RIGHT", -10, 0)
    statustext:SetPoint("BOTTOM", editbox.button, "BOTTOM", 0, 0)

    local widget = {
        type = Type,
        window = window,
        statustext = statustext,
        title = window.title,
        frame = frame,
        editbox = editbox.editBox,
        button = editbox.button,
    }

    window.obj, frame.obj, editbox.obj = widget, widget, widget

    for method, func in pairs(methods) do
        widget[method] = func
    end

    return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
