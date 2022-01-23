local addonName = ...
local addon = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

-- Optional libraries
local ACD = LibStub("AceConfigDialog-3.0")
local AceGUI = LibStub("AceGUI-3.0", true)
local LSM = LibStub("LibSharedMedia-3.0")

local Type = "FarmingBar_LuaEditBox"
local Version = 1

-- *------------------------------------------------------------------------
-- Widget methods

local methods = {
    OnAcquire = function(self)
        self.editBox:HookScript("OnTextChanged", function(this)   
            local info = self:GetUserData("info")
            local scope, key, func, args = unpack(info)
            if not func or not addon[func] then
                return
            else
                func = addon[func]
            end

            -- Updates whether the accept button is active, based on the validity of the userInput
            local preview, err = func(addon, addon.unpack(args, {}), this:GetText())

            C_Timer.After(0.01, function()
                if err then
                    self.button:Disable()
                else
                    self.button:Enable()
                end
            end)
        end)
    end,

    OnRelease = function(self)
        self.frame.obj:Release()
        addon:Unhook(self.editbox, "OnTextChanged")
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
        local info = frame:GetUserData("info")
        local scope, key, func = unpack(info)

        local editor = AceGUI:Create("FarmingBar_LuaEditor")
        frame:SetUserData("editor", editor)
        editor.frame:Show()
        ACD:Close(addonName)

        editor:SetTitle(format("%s %s", L.addon, L["Lua Editor"]))
        editor:LoadCode(info, frame:GetText())
        editor:SetCallback("OnClose", function(self)
            self:Release()
            ACD:Open(addonName)
        end)
    end)

    expandButton:SetScript("OnShow", function()
        local option = frame.userdata.option
        local info = option and option.arg

        frame:SetUserData("info", info)
    end)

    -- Fix misaligned editbox label
    frame.label:SetHeight(frame.label:GetStringHeight() + 6)

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
