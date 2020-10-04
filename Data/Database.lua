local addonName = ...
local U = LibStub("LibAddonUtils-1.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)
local addon = LibStub("AceAddon-3.0"):GetAddon(L.addonName)

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function addon:ConvertDB(currentVersion, oldVersion, oldGlobalDB, oldCharDB)
    if currentVersion == 2 and not oldVersion then

        if oldGlobalDB then
            -- Convert alert settings
            for k, v in pairs(oldGlobalDB.settings.alerts) do
                self.db.global.alerts[k] = v
            end

            -- Convert tooltip settings
            for k, v in pairs(oldGlobalDB.settings.tooltip) do
                self.db.global.tooltips[k] = v
            end

            -- Convert skin settings
            self.db.profile.style.skin.type = "builtin"
            self.db.profile.style.skin.name = oldGlobalDB.settings.style

            -- Convert templates
            for templateName, templateItems in pairs(oldGlobalDB.templates) do
                self.db.global.templates[templateName] = {}

                for _, itemID in pairs(templateItems) do
                    tinsert(self.db.global.templates[templateName], {
                        type = "item",
                        itemID = itemID,
                        includeBank = false,
                    })
                end
            end
        end

        if oldCharDB then
            -- Convert bars
            self.db.char.numBars = 0

            for barID, barDB in pairs(oldCharDB.bars) do
                self.db.char.numBars = self.db.char.numBars + 1

                self.db.char.bars[barID].enabled = true

                self.db.char.bars[barID].movable = barDB.movable
                self.db.char.bars[barID].hidden = barDB.hidden

                self.db.char.bars[barID].visibleButtons = barDB.numButtons
                self.db.char.bars[barID].direction = addon:GetDirection(barDB.orientation)

                self.db.char.bars[barID].alpha = barDB.alpha
                self.db.char.bars[barID].scale = barDB.scale
                self.db.char.bars[barID].position = barDB.point

                for buttonID, itemTable in pairs(barDB.items) do
                    self.db.char.bars[barID].objectives[buttonID] = {
                        type = "item",
                        itemID = itemTable.itemID,
                        includeBank = itemTable.includeBank,
                        objective = itemTable.objective,
                    }
                end
            end
        end

    end
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function addon:GetDB(dbType, id, buttonID)
    local db = self.db

    if dbType:find("^char.bars") then
        db = db.char.bars[id]
        dbType = dbType:gsub("^char.bars", ""):gsub("^.", "")
    elseif dbType:find("^global.objectives") then
        db = db.global.objectives[id]
        dbType = dbType:gsub("^global.objectives", ""):gsub("^.", "")
    end

    local path = {strsplit(".", dbType)}

    for k, v in pairs(path) do
        if v ~= "" then
            db = db[v]
        end
    end

    if buttonID then
        db = db[buttonID]
    end

    return db
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function addon:GetDBValue(dbType, info, ...)
    info = type(info) == "table" and info[#info] or info
    local db = self:GetDB(dbType, ...)
    return db and db[info]
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

local keys = {}
function addon:GetMixedDBValues(dbType, info, dbType2)
    wipe(keys)
    if info.option.type == "select" then
        for k, v in pairs(type(info.option.values) == "table" and info.option.values or info.option.values()) do
            keys[k] = 0
        end
    elseif info.option.type == "toggle" then
        keys.enabled = 0
        keys.disabled = 0
    end

    local total = 0
    for barID, bar in pairs(self.bars) do
        if bar.db.enabled then
            total = total + 1
            if self:GetDBValue(dbType, info, barID) then
                if info.option.type == "toggle" then
                    keys.enabled = keys.enabled + 1
                else
                    keys[self:GetDBValue(dbType, info, barID)] = (keys[self:GetDBValue(dbType, info, barID)] or 0) + 1
                end
            elseif info.option.type == "toggle" then
                keys.disabled = keys.disabled + 1
            elseif dbType2 then
                keys[self:GetDBValue(dbType2, info)] = (keys[self:GetDBValue(dbType2, info)] or 0) + 1
            end
        end
    end

    for k, v in pairs(keys) do
        if v == total then
            if k == "enabled" then
                return true
            elseif k == "disabled" then
                return false
            else
                return k
            end
        end
    end
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function addon:SetDBValue(dbType, info, value, ...)
    local db = self:GetDB(dbType, ...)
    if not db then return end
    info = type(info) == "table" and info[#info] or info
    if value == "_toggle" then
        if db[info] then
            db[info] = false
        else
            db[info] = true
        end
    else
        db[info] = value
    end
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function addon:SetMixedDBValues(dbType, info, value, callback)
    for barID, bar in pairs(self.bars) do
        self:SetDBValue(dbType, info, value, barID)
        if callback then
            callback(bar)
        end
    end
end