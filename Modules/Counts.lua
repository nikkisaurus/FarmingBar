local addonName = ...
local addon = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

-- *------------------------------------------------------------------------
-- Events

function addon:BAG_UPDATE_DELAYED(...)
	for trackerID, buttonIDs in pairs(self.trackers) do
		for _, buttonID in pairs(buttonIDs) do
			-- Get old count, then update count
			local bar = self.bars[buttonID[1]]
			local button = bar:GetButtons()[buttonID[2]]
			local buttonDB = button:GetButtonDB()
			local oldCount, oldTrackerCounts = button:GetCount()
			button:SetCount()

			local alerts = self:GetBarDBValue("alerts", buttonID[1], true)
			local alertInfo, alert, soundID
			if not alerts.muteAll and not buttonDB.mute then
				-- Get info for alerts
				local newCount, trackerCounts = button:GetCount()
				local objective = button:GetObjective()

				-- Change in objective count
				if oldCount ~= newCount then
					if objective and objective > 0 then
						if alerts.completedObjectives
							or (
							not alerts.completedObjectives
								and ((oldCount < objective) or (newCount < oldCount and newCount < objective))
							)
						then
							alert = "withObjective"

							if oldCount < objective and newCount >= objective then
								soundID = "objectiveComplete"
							else
								soundID = oldCount < newCount and "progress"
							end
						end
					else
						-- No objective
						alert = "withoutObjective"
						soundID = oldCount < newCount and "progress"
					end

					-- Setup alertInfo
					local difference = newCount - oldCount
					alertInfo = {
						objectiveTitle = buttonDB.title,
						objective = {
							color = (objective and objective > 0)
								and (newCount >= objective and "|cff00ff00" or "|cffffcc00")
								or "",
							count = objective,
						},
						oldCount = oldCount,
						newCount = newCount,
						difference = {
							sign = difference > 0 and "+" or difference < 0 and "",
							color = difference > 0 and "|cff00ff00" or difference < 0 and "|cffff0000",
							count = difference,
						},
					}
				end

				if alertInfo then
					self:SendAlert(bar, "button", alert, alertInfo, soundID)
				elseif trackerCounts then -- Change in tracker count
					for trackerKey, newTrackerCount in pairs(trackerCounts) do
						oldTrackerCount = oldTrackerCounts[trackerKey]
						if oldTrackerCount and oldTrackerCount ~= newTrackerCount then
							alert = "progress"
							soundID = oldTrackerCount < newTrackerCount and "progress"

							local trackerObjective = self:GetTrackerDBInfo(buttonDB.trackers, trackerKey, "objective")
							local difference, trackerDifference = newCount - oldCount, newTrackerCount - oldTrackerCount

							alertInfo = {
								objectiveTitle = buttonDB.title,
								objective = {
									color = (objective and objective > 0)
										and (newCount >= objective and "|cff00ff00" or "|cffffcc00")
										or "",
									count = objective,
								},
								trackerObjective = {
									color = newTrackerCount
										>= ((objective and objective > 0) and objective * trackerObjective or trackerObjective)
										and "|cff00ff00"
										or "|cffffcc00",
									count = (objective and objective > 0) and objective * trackerObjective
										or trackerObjective,
								},
								oldTrackerCount = oldTrackerCount,
								newTrackerCount = newTrackerCount,
								trackerDifference = {
									sign = trackerDifference > 0 and "+" or trackerDifference < 0 and "",
									color = trackerDifference > 0 and "|cff00ff00"
										or trackerDifference < 0 and "|cffff0000",
									count = trackerDifference,
								},
							}

							local trackerType, trackerID = self:ParseTrackerKey(trackerKey)

							if trackerType == "ITEM" then
								self.CacheItem(trackerID, function(bar, itemID, alert, alertInfo, soundID)
									alertInfo.trackerTitle = (GetItemInfo(itemID))
									addon:SendAlert(bar, "tracker", alert, alertInfo, soundID, true)
								end, bar, trackerID, alert, alertInfo, soundID)
							else
								alertInfo.trackerTitle = C_CurrencyInfo.GetCurrencyInfo(trackerID).name
								self:SendAlert(bar, "tracker", alert, alertInfo, soundID, true)
							end
						end
					end
				end
			end
		end
	end
end

addon.CURRENCY_DISPLAY_UPDATE = addon.BAG_UPDATE_DELAYED

-- *------------------------------------------------------------------------
-- Counts

function addon:GetDataStoreCurrencyCount(currencyID, trackerInfo)
	if #self:IsDataStoreLoaded() > 0 then
		return
	end -- Missing dependencies

	local DS = DataStore
	local count = 0

	if trackerInfo.includeAllChars then
		local currency = C_CurrencyInfo.GetCurrencyInfo(currencyID)
		local characters = DS:HashValueToSortedArray(DS:GetCharacters())
		for _, character in pairs(characters) do
			count = count + (select(2, DS:GetCurrencyInfoByName(character, currency.name)) or 0)
		end
	end

	return count
end

function addon:GetDataStoreItemCount(itemID, trackerInfo)
	if #self:IsDataStoreLoaded() > 0 then
		return
	end -- Missing dependencies

	local DS = DataStore
	local count = 0

	local characters = DS:HashValueToSortedArray(DS:GetCharacters())
	for _, character in pairs(characters) do
		if trackerInfo.includeAllChars or character == DS:GetCharacter() then
			local bags, bank = DS:GetContainerItemCount(character, itemID)
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

function addon:GetObjectiveCount(widget, objectiveTitle)
	local buttonDB = widget:GetButtonDB()
	local trackers = {}

	local count = 0
	local trackerCount
	if buttonDB.condition == "ANY" then
		for trackerKey, _ in pairs(buttonDB.trackers) do
			trackerCount = self:GetTrackerCount(buttonDB, trackerKey)
			count = count + trackerCount
			trackers[trackerKey] = self:GetTrackerCount(buttonDB, trackerKey, 1)
		end
	elseif buttonDB.condition == "ALL" then
		local pendingCount
		for trackerKey, _ in pairs(buttonDB.trackers) do
			trackerCount = self:GetTrackerCount(buttonDB, trackerKey)
			if not pendingCount then
				pendingCount = trackerCount
			else
				pendingCount = min(pendingCount, trackerCount)
			end
			trackers[trackerKey] = self:GetTrackerCount(buttonDB, trackerKey, 1)
		end
		count = count + (pendingCount or 0)
	elseif buttonDB.condition == "CUSTOM" then
		local func = loadstring("return " .. buttonDB.conditionInfo)
		if type(func) ~= "function" then
			return
		end

		local success, userFunc = pcall(func)
		if success and type(userFunc) == "function" then
			return tonumber(userFunc(buttonDB, addon.GetTrackerCount) or 0)
		end
	end

	return count > 0 and count or 0, trackers
end

function addon:GetTrackerCount(buttonDB, trackerKey, overrideObjective)
	local trackerType, trackerID = addon:ParseTrackerKey(trackerKey)
	local trackerInfo = buttonDB.trackers[trackerKey]
	local count

	if trackerType == "ITEM" then
		count = (trackerInfo.includeAllChars or trackerInfo.includeGuildBank)
			and addon:GetDataStoreItemCount(trackerID, trackerInfo)
			or GetItemCount(trackerID, trackerInfo.includeBank)
	elseif trackerType == "CURRENCY" then
		count = trackerInfo.includeAllChars and addon:GetDataStoreCurrencyCount(trackerID, trackerInfo)
			or (C_CurrencyInfo.GetCurrencyInfo(trackerID) and C_CurrencyInfo.GetCurrencyInfo(trackerID).quantity)
	end

	if not count then
		return 0
	end

	local excluded
	if addon.tcount(trackerInfo.exclude) > 0 then
		for excludedObjectiveTitle, _ in pairs(trackerInfo.exclude) do
			for _, bar in pairs(addon.bars) do
				for _, button in pairs(bar:GetUserData("buttons")) do
					if button:GetObjectiveTitle() == excludedObjectiveTitle and button:GetObjective() > 0 then
						-- Get the max amount used for the objective: either the objective itself or the count
						local maxCount = min(button:GetCount(), button:GetObjective())
						-- The number of of this tracker required for the objective is the tracker objective x max
						count = count - maxCount
					end
				end
			end
		end
	end

	count = floor(count / (overrideObjective or trackerInfo.objective or 1))

	-- -- If objective is excluded, get max objective
	-- -- If count > max objective while excluded, return max objective
	-- -- Surplus above objective goes toward the objective excluding this one
	-- -- Ex: if A has an objective of 20 and a count of 25 and B excludes A, A will show a count of 20 with objective complete and B will show a count of 5
	local objective
	-- for _, eObjectiveInfo in pairs(self:GetDBValue("global", "objectives")) do
	--     for _, eTrackerInfo in pairs(eObjectiveInfo.trackers) do
	--         if self:ObjectiveIsExcluded(eTrackerInfo.exclude, objectiveTitle) then
	--             objective = self:GetMaxTrackerObjective(objectiveTitle)
	--             break
	--         end
	--     end
	-- end

	count = (count > 0 and count or 0) * (trackerInfo.countsFor or 1)

	return objective and min(count, objective) or count
end

-- *------------------------------------------------------------------------
-- Validation

local missing = {}
function addon:IsDataStoreLoaded()
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
