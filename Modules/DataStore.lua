local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)

local missing = {}

function private:GetDataStoreCurrencyCount(currencyID)
    if private:MissingDataStore() then
        return
    end
    local DS = DataStore
    local characters = DS:HashValueToSortedArray(DS:GetCharacters())
    local currency = C_CurrencyInfo.GetCurrencyInfo(currencyID)
    local count = 0

    for _, character in pairs(characters) do
        count = count + (select(2, DS:GetCurrencyInfoByName(character, currency.name)) or 0)
    end

    return count
end

function private:GetDataStoreItemCount(itemID, trackerInfo)
    if private:MissingDataStore() then
        return
    end
    local DS = DataStore
    local count = 0

    local characters = DS:HashValueToSortedArray(DS:GetCharacters())
    for _, character in pairs(characters) do
        if trackerInfo.includeAlts or character == DS:GetCharacter() then
            local bags, bank, void, reagentBank, reagentBag = DS:GetContainerItemCount(character, itemID)
            bags = bags + reagentBag
            bank = bank + void + reagentBank
            local mail = DS:GetMailItemCount(character, itemID) or 0
            local auction = DS:GetAuctionHouseItemCount(character, itemID) or 0
            local inventory = DS:GetInventoryItemCount(character, itemID) or 0

            count = count + bags + (trackerInfo.includeBank and bank or 0) + mail + auction + inventory
        end
    end

    local guilds = DS:HashValueToSortedArray(DS:GetGuilds())
    for guildName, guild in pairs(guilds) do
        -- From what I see, there is no function in DataStore to check the guild faction by the ID, so checking from the db instead
        if trackerInfo.includeGuildBank[guild] and DS.db.global.Guilds[guild].faction == UnitFactionGroup("player") then
            count = count + DS:GetGuildBankItemCount(guild, itemID)
        end
    end

    count = count == 0 and GetItemCount(itemID, trackerInfo.includeBank) or count

    return count
end

function private:GetGuildsList()
    if private:MissingDataStore() then
        return {}
    end
    local DS = DataStore
    local guilds = {}

    for guildName, guild in pairs(DS:GetGuilds()) do
        guilds[guild] = guildName
    end

    return guilds
end

function private:GetMissingDataStoreModules()
    wipe(missing)

    if not IsAddOnLoaded("DataStore") then
        tinsert(missing, "DataStore")
    end

    if not IsAddOnLoaded("DataStore_Auctions") then
        tinsert(missing, "DataStore_Auctions")
    end

    if not IsAddOnLoaded("DataStore_Characters") then
        tinsert(missing, "DataStore_Characters")
    end

    if not IsAddOnLoaded("DataStore_Containers") then
        tinsert(missing, "DataStore_Containers")
    end

    --@retail@
    if not IsAddOnLoaded("DataStore_Currencies") then
        tinsert(missing, "DataStore_Currencies")
    end
    --@end-retail@

    if not IsAddOnLoaded("DataStore_Inventory") then
        tinsert(missing, "DataStore_Inventory")
    end

    if not IsAddOnLoaded("DataStore_Mails") then
        tinsert(missing, "DataStore_Mails")
    end

    return missing
end

function private:MissingDataStore()
    return #private:GetMissingDataStoreModules() > 0
end
