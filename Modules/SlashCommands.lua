local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)

function private:InitializeSlashCommands()
    for command, enabled in pairs(private.db.global.settings.commands) do
        if enabled then
            addon:RegisterChatCommand(command, "HandleSlashCommand")
        else
            addon:UnregisterChatCommand(command)
        end
    end

    addon:RegisterChatCommand("craft", "CraftTradeSkill")
end

function addon:HandleSlashCommand(input)
    LibStub("AceConfigCmd-3.0").HandleCommand(addon, "farmingbar", addonName .. "Commands", input)
end

local tradeskillIDs = {
    FIRSTAID = 129,
    BLACKSMITHING = 164,
    LEATHERWORKING = 165,
    ALCHEMY = 171,
    HERBALISM = 182,
    COOKING = 185,
    MINING = 186,
    TAILORING = 197,
    ENGINEERING = 202,
    ENCHANTING = 333,
    FISHING = 356,
    SKINNING = 393,
    JEWELCRAFTING = 755,
    INSCRIPTION = 773,
    ARCHEOLOGY = 794,
}

function private:CraftRecipe(recipeName)
    for _, id in pairs(C_TradeSkillUI.GetAllRecipeIDs()) do
        local recipeInfo = C_TradeSkillUI.GetRecipeInfo(id)
        if strupper(recipeInfo.name) == recipeName then
            C_TradeSkillUI.CraftRecipe(recipeInfo.recipeID)
            return
        end
    end

    addon:Print(L.UnknownRecipe(recipeName))
end

function addon:CraftTradeSkill(input)
    input = strupper(input)
    local inputTable = { strsplit(" ", input) }
    local skillID = inputTable[1]
    tremove(inputTable, 1)
    local recipeName = strjoin(" ", unpack(inputTable))

    if strfind(input, "^FIRST AID ") then
        skillID = "FIRSTAID"
        recipeName = recipeName == "AID" and nil or gsub(recipeName, "^AID ", "")
    end
    skillID = tradeskillIDs[strupper(skillID)]

    if not skillID then
        addon:Print(L.InvalidCraftSkillID)
        return
    elseif not recipeName or recipeName == "" then
        addon:Print(L.MissingCraftRecipeName)
        return
    end

    if not C_TradeSkillUI.IsTradeSkillReady() then
        C_TradeSkillUI.OpenTradeSkill(skillID)
        private:CraftRecipe(recipeName)
        C_TradeSkillUI.CloseTradeSkill()
    else
        private:CraftRecipe(recipeName)
    end
end

function private:GetSlashCommandOptions()
    local options = {
        type = "group",
        name = L.addonName,
        guiHidden = true,
        args = {
            bar = {
                type = "group",
                name = "bar",
                desc = format(
                    "%s (%s | %s | %s | %s)",
                    L["Configure bar settings."],
                    addon.ColorFontString("alpha", "LIGHTBLUE"),
                    addon.ColorFontString("buttons", "LIGHTBLUE"),
                    addon.ColorFontString("movable", "LIGHTBLUE"),
                    addon.ColorFontString("scale", "LIGHTBLUE")
                ),
                args = {
                    alpha = {
                        type = "execute",
                        name = "",
                        desc = format(
                            "%s (%s)",
                            L["Sets bar alpha."],
                            addon.ColorFontString("barID[0+] alpha[0-1]", "LIGHTBLUE")
                        ),
                        validate = function(info)
                            local _, command, barID, alpha = strsplit(" ", info.input:trim())
                            barID = tonumber(barID)
                            alpha = tonumber(alpha)

                            if not barID or (barID ~= 0 and not private.bars[barID]) then
                                return L["Invalid barID. To apply to all bars, use barID 0."]
                            elseif not alpha or alpha < 0 or alpha > 1 then
                                return L["Invalid alpha value. Please provide an integer between 0 and 1."]
                            end
                            return true
                        end,
                        func = function(info)
                            local _, command, barID, alpha = strsplit(" ", info.input:trim())
                            barID = tonumber(barID)
                            alpha = tonumber(alpha)

                            if barID == 0 then
                                private:SetMixedBarDBValues("alpha", alpha, nil, function(barID)
                                    private.bars[barID]:SetMouseover()
                                end)
                            else
                                private.db.profile.bars[barID].alpha = alpha
                                private.bars[barID]:SetMouseover()
                            end
                        end,
                    },
                    buttons = {
                        type = "execute",
                        name = "",
                        desc = format(
                            "%s (%s)",
                            L["Set the number of buttons on bar."],
                            addon.ColorFontString(
                                format("barID[0+] numButtons[0-%d]", private.CONST.MAX_BUTTONS),
                                "LIGHTBLUE"
                            )
                        ),
                        validate = function(info)
                            local _, command, barID, numButtons = strsplit(" ", info.input:trim())
                            barID = tonumber(barID)
                            numButtons = tonumber(numButtons)

                            if not barID or (barID ~= 0 and not private.bars[barID]) then
                                return L["Invalid barID. To apply to all bars, use barID 0."]
                            elseif not numButtons or numButtons < 1 or numButtons > private.CONST.MAX_BUTTONS then
                                return format(
                                    L["Please specify the number of buttons from 0 to %d."],
                                    private.CONST.MAX_BUTTONS
                                )
                            end
                        end,
                        func = function(info)
                            local _, command, barID, numButtons = strsplit(" ", info.input:trim())
                            barID = tonumber(barID)
                            numButtons = tonumber(numButtons)

                            if barID == 0 then
                                private:SetMixedBarDBValues("numButtons", numButtons, nil, function(barID)
                                    private.bars[barID]:DrawButtons()
                                    private.bars[barID]:LayoutButtons()
                                    private.bars[barID]:SetScale()
                                end)
                            else
                                private.db.profile.bars[barID].numButtons = numButtons
                                private.bars[barID]:DrawButtons()
                                private.bars[barID]:LayoutButtons()
                                private.bars[barID]:SetScale()
                            end
                        end,
                    },
                    scale = {
                        type = "execute",
                        name = "",
                        desc = format(
                            "%s (%s)",
                            L["Sets bar scale."],
                            addon.ColorFontString(
                                format(
                                    "barID[0+] scale[%s-%s]",
                                    tostring(private.CONST.MIN_SCALE),
                                    tostring(private.CONST.MAX_SCALE)
                                ),
                                "LIGHTBLUE"
                            )
                        ),
                        validate = function(info)
                            local _, command, barID, scale = strsplit(" ", info.input:trim())
                            barID = tonumber(barID)
                            scale = tonumber(scale)

                            if not barID or (barID ~= 0 and not private.bars[barID]) then
                                return L["Invalid barID. To apply to all bars, use barID 0."]
                            elseif not scale or scale < private.CONST.MIN_SCALE or scale > private.CONST.MAX_SCALE then
                                return format(
                                    L["Invalid scale value. Please provide an integer between %s and %s."],
                                    tostring(private.CONST.MIN_SCALE),
                                    tostring(private.CONST.MAX_SCALE)
                                )
                            end
                            return true
                        end,
                        func = function(info)
                            local _, command, barID, scale = strsplit(" ", info.input:trim())
                            barID = tonumber(barID)
                            scale = tonumber(scale)

                            if barID == 0 then
                                private:SetMixedBarDBValues("scale", scale, nil, function(barID)
                                    private.bars[barID]:SetScale()
                                end)
                            else
                                private.db.profile.bars[barID].scale = scale
                                private.bars[barID]:SetScale()
                            end
                        end,
                    },
                    movable = {
                        type = "execute",
                        name = "",
                        desc = format(
                            "%s (%s)",
                            L["Lock or unlock bar."],
                            addon.ColorFontString("barID[0+] [true | false | toggle]", "LIGHTBLUE")
                        ),
                        validate = function(info)
                            local _, command, barID, movable = strsplit(" ", info.input:trim())
                            barID = tonumber(barID)

                            if not barID or (barID ~= 0 and not private.bars[barID]) then
                                return L["Invalid barID. To apply to all bars, use barID 0."]
                            elseif not movable then
                                return L["Please specify movable type: true, false, toggle."]
                            end
                        end,
                        func = function(info)
                            local _, command, barID, movable = strsplit(" ", info.input:trim())
                            barID = tonumber(barID)

                            local function SetMovable(barID)
                                if movable == "true" then
                                    private.db.profile.bars[barID].movable = true
                                elseif movable == "false" then
                                    private.db.profile.bars[barID].movable = false
                                elseif movable == "toggle" then
                                    if private.db.profile.bars[barID].movable then
                                        private.db.profile.bars[barID].movable = false
                                    else
                                        private.db.profile.bars[barID].movable = true
                                    end
                                end
                                private.bars[barID]:SetMovable()
                            end

                            if barID == 0 then
                                for BarID, _ in pairs(private.bars) do
                                    SetMovable(BarID)
                                end
                            else
                                SetMovable(barID)
                            end
                        end,
                    },
                },
            },
            disable = {
                type = "execute",
                name = "",
                desc = L["Disable profile."],
                func = function()
                    private.db.profile.enabled = false
                    addon:Disable()
                end,
            },
            enable = {
                type = "execute",
                name = "",
                desc = L["Enable profile."],
                func = function()
                    private.db.profile.enabled = true
                    addon:Enable()
                end,
            },
            profile = {
                type = "execute",
                name = "",
                desc = format("%s (%s)", L["Swap profiles."], addon.ColorFontString("profileName", "LIGHTBLUE")),
                func = function(info)
                    local _, profileName = strsplit(" ", info.input:trim())
                    if not profileName then
                        return
                    end
                    for _, profile in pairs(private.db:GetProfiles()) do
                        if strlower(profileName) == strlower(profile) then
                            private.db:SetProfile(profile)
                        end
                    end
                end,
            },
            show = {
                type = "execute",
                name = "",
                desc = L["Show options frame."],
                func = function()
                    private:LoadOptions()
                end,
            },
            tooltips = {
                type = "group",
                name = "",
                desc = format(
                    "%s (%s | %s | %s | %s | %s)",
                    L["Toggle tooltips."],
                    addon.ColorFontString("bar", "LIGHTBLUE"),
                    addon.ColorFontString("button", "LIGHTBLUE"),
                    addon.ColorFontString("disable", "LIGHTBLUE"),
                    addon.ColorFontString("enable", "LIGHTBLUE"),
                    addon.ColorFontString("toggle", "LIGHTBLUE")
                ),
                args = {
                    bar = {
                        type = "execute",
                        name = "",
                        desc = L["Toggle bar tooltips."],
                        func = function()
                            if private.db.global.settings.tooltips.bar then
                                private.db.global.settings.tooltips.bar = false
                            else
                                private.db.global.settings.tooltips.bar = true
                            end
                        end,
                    },
                    button = {
                        type = "execute",
                        name = "",
                        desc = L["Toggle button tooltips."],
                        func = function()
                            if private.db.global.settings.tooltips.button then
                                private.db.global.settings.tooltips.button = false
                            else
                                private.db.global.settings.tooltips.button = true
                            end
                        end,
                    },
                    disable = {
                        type = "execute",
                        name = "",
                        desc = L["Enable all tooltips."],
                        func = function()
                            private.db.global.settings.tooltips.button = false
                            private.db.global.settings.tooltips.bar = false
                        end,
                    },
                    enable = {
                        type = "execute",
                        name = "",
                        desc = L["Enable all tooltips."],
                        func = function()
                            private.db.global.settings.tooltips.button = true
                            private.db.global.settings.tooltips.bar = true
                        end,
                    },
                    toggle = {
                        type = "execute",
                        name = "",
                        desc = L["Toggle all tooltips."],
                        func = function()
                            if private.db.global.settings.tooltips.bar then
                                private.db.global.settings.tooltips.bar = false
                            else
                                private.db.global.settings.tooltips.bar = true
                            end

                            if private.db.global.settings.tooltips.button then
                                private.db.global.settings.tooltips.button = false
                            else
                                private.db.global.settings.tooltips.button = true
                            end
                        end,
                    },
                },
            },
        },
    }

    return options
end
