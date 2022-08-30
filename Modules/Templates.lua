local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)

function private:TemplateExists(templateName)
    return private.db.global.templates[templateName]
end

function private:SaveTemplate(barID, templateName)
    local widget = private.bars[barID]
    local barDB = widget:GetDB()
    private.db.global.templates[templateName] = addon.CloneTable(barDB.buttons)
end
