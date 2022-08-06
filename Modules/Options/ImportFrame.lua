local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)
local AceGUI = LibStub("AceGUI-3.0")
local LibSerialize = LibStub("LibSerialize")
local LibDeflate = LibStub("LibDeflate")

function private:LoadImportFrame()
    local importFrame, codeFrame, importObjective

    -- Callbacks
    local function editbox_OnTextChanged(self)
        -- Decode
        local decoded = LibDeflate:DecodeForPrint(self:GetText())
        if not decoded then
            return
        end

        local decompressed = LibDeflate:DecompressDeflate(decoded)
        if not decompressed then
            return
        end

        local success, objectiveInfo = LibSerialize:Deserialize(decompressed)
        if not success then
            return
        end

        importFrame:Release()

        -- Callbacks
        local function codeButton_OnClick()
            -- Callbacks
            local function codeFrame_OnClose(self)
                self:Release()
                codeFrame = nil
            end

            -- Widgets
            codeFrame = codeFrame or AceGUI:Create("Frame")
            codeFrame:SetTitle(L.addonName .. " - " .. L["Code Viewer"])
            codeFrame:SetLayout("Fill")
            codeFrame:SetCallback("OnClose", codeFrame_OnClose)

            local editbox = AceGUI:Create("MultiLineEditBox")
            editbox:SetLabel(L["Custom Tracker Condition"])
            editbox:DisableButton(true)
            editbox:SetDisabled(true)
            editbox:SetText(objectiveInfo.condition.func)
            codeFrame:AddChild(editbox)
        end

        local function importButton_OnClick()
            if codeFrame then
                codeFrame:Release()
            end
            importObjective:Release()

            local newObjectiveTitle =
                private:IncrementString(L["Imported Objective"], private, "ObjectiveTemplateExists")
            private.db.global.objectives[newObjectiveTitle] = addon.CloneTable(objectiveInfo)
            private:UpdateMenu(private.options:GetUserData("menu"), "Objectives", newObjectiveTitle)
        end

        -- Widgets
        importObjective = AceGUI:Create("Window")
        importObjective:SetTitle(L.addonName .. " - " .. L["Import"])
        importObjective:SetLayout("Flow")
        importObjective:SetWidth(300)
        importObjective:SetHeight(200)
        importObjective:Show()
        importObjective:SetPoint("TOP", 0, -200)
        importObjective.frame:SetFrameStrata("FULLSCREEN_DIALOG")

        local icon = AceGUI:Create("Icon")
        icon:SetFullWidth(true)
        icon:SetImage(private:GetObjectiveIcon(objectiveInfo))
        icon:SetImageSize(40, 40)

        local warning = AceGUI:Create("Label")
        warning:SetFullWidth(true)
        warning:SetText(addon.ColorFontString(L.CustomCodeWarning, "red"))

        local spacer = AceGUI:Create("Label")
        spacer:SetFullWidth(true)
        spacer:SetText(" ")

        local codeButton = AceGUI:Create("Button")
        codeButton:SetRelativeWidth(0.5)
        codeButton:SetText(L["View Code"])
        codeButton:SetCallback("OnClick", codeButton_OnClick)

        local importButton = AceGUI:Create("Button")
        importButton:SetRelativeWidth(0.5)
        importButton:SetText(L["Import"])
        importButton:SetCallback("OnClick", importButton_OnClick)

        -- Add Children
        private:AddChildren(importObjective, icon, warning, spacer, codeButton, importButton)
    end

    local function importFrame_OnClose(self)
        self:Release()
    end

    -- Widgets
    importFrame = AceGUI:Create("Frame")
    importFrame:SetTitle(L.addonName .. " - " .. L["Import Frame"])
    importFrame:SetLayout("Fill")
    importFrame:SetCallback("OnClose", importFrame_OnClose)

    local editbox = AceGUI:Create("MultiLineEditBox")
    editbox:SetLabel("")
    editbox:DisableButton(true)
    editbox:SetCallback("OnTextChanged", editbox_OnTextChanged)
    editbox:SetFocus()

    -- Add Children
    private:AddChildren(importFrame, editbox)
    importFrame:Show()
end
