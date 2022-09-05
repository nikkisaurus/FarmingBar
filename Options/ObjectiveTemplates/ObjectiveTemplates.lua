local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)
local AceGUI = LibStub("AceGUI-3.0")
local LibDeflate = LibStub("LibDeflate")

local funcs = {
    importObjectiveTemplate = function()
        local importFrame = AceGUI:Create("Frame")
        importFrame:SetTitle(L.addonName .. " - " .. L["Import Frame"])
        importFrame:SetLayout("Fill")
        importFrame:SetCallback("OnClose", function(self)
            self:Release()
            private:LoadOptions()
        end)

        local editbox = AceGUI:Create("MultiLineEditBox")
        editbox:SetLabel("")
        editbox:DisableButton(true)
        importFrame:AddChild(editbox)
        editbox:SetFocus()

        editbox:SetCallback("OnTextChanged", function(self)
            -- Decode
            local decoded = LibDeflate:DecodeForPrint(self:GetText())
            if not decoded then
                return
            end
            local decompressed = LibDeflate:DecompressDeflate(decoded)
            if not decompressed then
                return
            end
            local success, objectiveTemplate = LibStub("LibSerialize"):Deserialize(decompressed)
            if not success then
                return
            end

            importFrame:Fire("OnClose")
            private:CloseOptions()

            -- Create objective import frame
            local importObjective = AceGUI:Create("Window")
            importObjective:SetTitle(L.addonName .. " - " .. L["Import"])
            importObjective:SetLayout("Flow")
            importObjective:SetWidth(240)
            importObjective:SetHeight(240)
            importObjective:SetCallback("OnClose", function(self)
                self:Release()
                private:LoadOptions()
            end)

            local icon = AceGUI:Create("Icon")
            icon:SetWidth(50)
            icon:SetImage(private:GetObjectiveIcon(objectiveTemplate))
            icon:SetImageSize(40, 40)
            importObjective:AddChild(icon)

            local objective = AceGUI:Create("Label")
            objective:SetText(addon.ColorFontString(objectiveTemplate.title, "SEXBLUE"))
            objective:SetFontObject(GameFontNormalLarge)
            importObjective:AddChild(objective)

            local warning = AceGUI:Create("Label")
            warning:SetFullWidth(true)
            warning:SetText(addon.ColorFontString(L.CustomCodeWarning, "red"))
            importObjective:AddChild(warning)

            local spacer = AceGUI:Create("Label")
            spacer:SetFullWidth(true)
            spacer:SetText(" ")
            importObjective:AddChild(spacer)

            local codeButton = AceGUI:Create("Button")
            codeButton:SetText(L["View Code"])
            importObjective:AddChild(codeButton)

            local codeFrame
            codeButton:SetCallback("OnClick", function()
                codeFrame = codeFrame or AceGUI:Create("Frame")
                codeFrame:SetTitle(L.addonName .. " - " .. L["Code Viewer"])
                codeFrame:SetLayout("Fill")
                codeFrame:SetCallback("OnClose", function(self)
                    self:Release()
                    codeFrame = nil
                end)

                local treeGroup = AceGUI:Create("TreeGroup")
                treeGroup:SetFullWidth(true)
                treeGroup:SetLayout("Fill")
                codeFrame:AddChild(treeGroup)

                treeGroup:SetTree({
                    {
                        value = "customTracker",
                        text = L["Custom Tracker Condition"],
                        func = function()
                            return objectiveTemplate.condition.func
                        end,
                    },
                    {
                        value = "macrotext",
                        text = L["On Use Macrotext"],
                        func = function()
                            return objectiveTemplate.onUse.macrotext
                        end,
                    },
                })

                local editbox = AceGUI:Create("MultiLineEditBox")
                editbox:DisableButton(true)
                editbox:SetDisabled(true)
                treeGroup:AddChild(editbox)

                treeGroup:SetCallback("OnGroupSelected", function(treeGroup, _, value)
                    for _, v in pairs(treeGroup.tree) do
                        if v.value == value then
                            editbox:SetText(v.func())
                            return
                        end
                    end

                    editbox:SetText("")
                end)

                treeGroup:SelectByValue("customTracker")
            end)

            local codeButton = AceGUI:Create("Button")
            codeButton:SetText(L["Import"])
            importObjective:AddChild(codeButton)

            codeButton:SetCallback("OnClick", function()
                if codeFrame then
                    codeFrame:Fire("OnClose")
                end
                importObjective:Fire("OnClose")

                local newObjectiveTemplateName = private:AddObjectiveTemplate(objectiveTemplate)
                private:LoadOptions("objectiveTemplates", newObjectiveTemplateName)
            end)
        end)

        -- Hide options
        private:CloseOptions()
        importFrame:Show()
    end,

    newObjectiveTemplate = function()
        private:AddObjectiveTemplate()
    end,

    objectiveTemplate = function(objectiveTemplateName, mouseButton)
        if mouseButton == "LeftButton" then
            private:PickupObjectiveTemplate(objectiveTemplateName)
        elseif mouseButton == "RightButton" then
            private:SelectOptionsPath("objectiveTemplates", objectiveTemplateName)
        end
    end,

    removeObjectiveTemplate = function(_, objectiveTemplateName)
        private:DeleteObjectiveTemplate(objectiveTemplateName)
        private:RefreshOptions()
    end,

    removeObjectiveTemplate_Confirm = function(_, objectiveTemplateName)
        return format(L["Are you sure you want to delete the objective template \"%s\"?"], objectiveTemplateName)
    end,
}

function private:GetObjectiveTemplatesList()
    local values, sorting = {}, {}

    for objectiveTemplateName, _ in addon.pairs(private.db.global.objectives) do
        values[objectiveTemplateName] = objectiveTemplateName
        tinsert(sorting, objectiveTemplateName)
    end

    return values, sorting
end

function private:GetObjectiveTemplatesOptions()
    local values, sorting = private:GetObjectiveTemplatesList()

    local options = {
        newObjectiveTemplate = {
            order = 1,
            type = "execute",
            name = NEW,
            func = funcs.newObjectiveTemplate,
        },

        importObjectiveTemplate = {
            order = 2,
            type = "execute",
            name = L["Import"],
            func = funcs.importObjectiveTemplate,
        },

        removeObjectiveTemplate = {
            order = 3,
            type = "select",
            style = "dropdown",
            values = values,
            sorting = sorting,
            name = L["Remove Objective Template"],
            confirm = funcs.removeObjectiveTemplate_Confirm,
            set = funcs.removeObjectiveTemplate,
        },

        objectiveTemplatesList = {
            order = 4,
            type = "group",
            inline = true,
            name = L["Objective Templates"],
            args = {},
        },
    }

    local i = 101
    for objectiveTemplateName, objectiveTemplate in addon.pairs(private.db.global.objectives) do
        options.objectiveTemplatesList.args[objectiveTemplateName] = {
            order = i,
            type = "execute",
            dialogControl = "FarmingBar_Icon",
            image = private:GetObjectiveIcon(objectiveTemplate),
            width = 0.25,
            name = objectiveTemplateName,
            func = function(_, mouseButton)
                funcs.objectiveTemplate(objectiveTemplateName, mouseButton)
            end,
        }

        options[objectiveTemplateName] = {
            order = i,
            type = "group",
            childGroups = "tab",
            name = objectiveTemplateName,
            args = private:GetObjectiveTemplateOptions(objectiveTemplateName),
        }

        i = i + 1
    end

    return options
end
