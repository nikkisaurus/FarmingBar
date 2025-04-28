local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)

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

    addon:Print(private.defaultChatFrame, L.UnknownRecipe(recipeName))
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
        addon:Print(private.defaultChatFrame, L["Invalid tradeskill name."])
        return
    elseif not recipeName or recipeName == "" then
        addon:Print(private.defaultChatFrame, L["Please specify a tradeskill recipe name."])
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

function addon:HandleSlashCommand(input)
    if not input or input == "" then
        private:LoadOptions()
    else
        LibStub("AceConfigCmd-3.0").HandleCommand(addon, "farmingbar", addonName .. "Commands", strlower(input) ~= "help" and input or "")
    end
end

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
