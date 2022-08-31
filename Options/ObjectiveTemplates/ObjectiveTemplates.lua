local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)

local funcs = {
    importObjectiveTemplate = function()
        print("Import")
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
