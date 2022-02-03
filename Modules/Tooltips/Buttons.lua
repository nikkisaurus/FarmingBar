local addonName, ns = ...
local addon = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

-- Optional libraries
local utils = LibStub("LibAddonUtils-1.0")

-- *------------------------------------------------------------------------

local buttonCommandSort = {
	useItem = 1, -- right
	clearObjective = 2, -- shift+right
	moveObjective = 3, -- left
	dragObjective = 4, -- shift+left drag
	showObjectiveEditBox = 5, -- ctrl+left
	showQuickAddEditBox = 6, -- alt+left
	--@retail@
	showQuickAddCurrencyEditBox = 7, -- alt+right
	--@end-retail@
	showObjectiveEditor = 8, -- ctrl+right
	moveObjectiveToBank = 9, -- alt+ctrl+right
	moveAllToBank = 10, -- alt+ctrl+left
}

local function CountTrackerKeys(trackers, key)
	local count = 0
	for _, tracker in pairs(trackers) do
		if not key and tracker then
			count = count + 1
		else
			for k, v in pairs(tracker) do
				if k == key and v then
					count = count + 1
				end
			end
		end
	end
	return count
end

local function InsertPending(lines, pending)
	for _, line in pairs(pending) do
		tinsert(lines, line)
	end
	return lines
end

function addon:GetButtonTooltip(widget, tooltip)
	local buttonDB = widget:GetButtonDB()
	local hideEmpty = not widget:GetBar():GetBarDB().showEmpty and widget:IsEmpty()
	if not self:GetDBValue("global", "settings.tooltips.button") or not buttonDB or hideEmpty then
		return
	end

	local kv = self.tooltip_keyvalue
	local desc = self.tooltip_desc
	local lines, pending = {}

	if not widget:IsEmpty() then
		-- Objective item/currency
		if buttonDB.action and buttonDB.actionInfo and (buttonDB.action == "ITEM" or buttonDB.action == "CURRENCY") then
			pending = {
				{
					link = true,
					line = format("%s:%s", string.lower(buttonDB.action), buttonDB.actionInfo),
					color = desc,
				},
				{
					line = " ",
					color = desc,
				},
				{
					line = " ",
					color = desc,
				},
				{
					texture = true,
					line = 389194,
					size = {
						width = 200,
						height = 10,
					},
				},
			}

			lines = InsertPending(lines, pending)
		end

		-- Objective title/template
		pending = {
			{
				double = true,
				k = L["Title"],
				v = buttonDB.title,
				color = kv,
			},
			{
				double = true,
				k = L["Template"],
				v = buttonDB.template or L["NONE"],
				color = kv,
			},
		}

		lines = InsertPending(lines, pending)

		-- Objective info
		local modifierEnabled = self:GetDBValue("global", "settings.tooltips.condensedTooltip")
		if (modifierEnabled and self:IsTooltipMod()) or not modifierEnabled then
			--  Display action type and info
			if buttonDB.action and buttonDB.actionInfo then
				if buttonDB.action == "MACROTEXT" then -- MACROTEXT
					tinsert(lines, {
						double = true,
						k = L["Action"],
						v = strsub(buttonDB.actionInfo, 1, 15) .. (strlen(buttonDB.actionInfo) > 15 and "..." or ""),
						color = kv,
					})
				else
					self:GetTrackerDataTable(buttonDB, buttonDB.action, buttonDB.actionInfo, function(data) -- OTHERS
						tinsert(lines, {
							double = true,
							k = L["Action"],
							v = strsub(data.name, 1, 15) .. (strlen(data.name) > 15 and "..." or ""),
							color = kv,
						})
					end)
				end
			else -- NONE
				tinsert(lines, {
					double = true,
					k = L["Action"],
					v = L["None"],
					color = kv,
				})
			end

			local count = widget:GetCount()

			pending = {
				{
					double = true,
					k = L["Condition"],
					v = L[strsub(buttonDB.condition, 1, 1) .. strlower(strsub(buttonDB.condition, 2))],
					color = kv,
				},
				{
					line = " ",
					color = desc,
				},
				{
					double = true,
					k = L["Count"],
					v = self.iformat(count, 1),
					color = kv,
				},
			}

			lines = InsertPending(lines, pending)

			-- Trackers
			local numTrackers = self.tcount(buttonDB.trackers)

			-- Objective
			local objective = widget:GetObjective()

			pending = {
				{
					double = true,
					k = L["Objective"],
					v = (objective and objective > 0) and objective or L["FALSE"],
					color = kv,
				},
			}

			lines = InsertPending(lines, pending)

			if objective and objective > 0 then
				pending = {
					{
						double = true,
						k = L["Objective Complete"],
						v = count >= objective and floor(count / objective) .. "x" or L["FALSE"],
						color = kv,
					},
				}

				lines = InsertPending(lines, pending)
			end

			pending = {
				{
					line = " ",
					color = desc,
				},
				{
					double = true,
					k = L["Include All Characters"],
					v = numTrackers == 1
							and (buttonDB.trackers[self:GetFirstTracker(widget)].includeAllChars and L["TRUE"] or L["FALSE"])
						or format("%d / %d", CountTrackerKeys(buttonDB.trackers, "includeAllChars"), numTrackers),
					color = kv,
				},
				{
					double = true,
					k = L["Include Bank"],
					v = numTrackers == 1
							and (buttonDB.trackers[self:GetFirstTracker(widget)].includeBank and L["TRUE"] or L["FALSE"])
						or format("%d / %d", CountTrackerKeys(buttonDB.trackers, "includeBank"), numTrackers),
					color = kv,
				},
			}

			if numTrackers == 1 then
				local includeGuildBank = buttonDB.trackers[self:GetFirstTracker(widget)].includeGuildBank
				local included = 0
				local numGuilds = 0
				local DS = DataStore

				if DS then
					for guildName, guild in self.pairs(DS:GetGuilds(DS.ThisRealm, DS.ThisAccount)) do
						if DS.db.global.Guilds[guild].faction == UnitFactionGroup("player") then
							numGuilds = numGuilds + 1
							included = includeGuildBank[guild] and (included + 1) or included
						end
					end

					tinsert(pending, {
						double = true,
						k = L["Include Guild Bank"],
						v = format("%d / %d", included, numGuilds),
						color = kv,
					})

					lines = InsertPending(lines, pending)
				end
			else
				local DS = DataStore

				if DS then
					lines = InsertPending(lines, {
						{
							line = L["Include Guild Bank"],
							color = kv,
						},
					})
				end

				local trackerCount = 0
				for tracker, trackerInfo in
					self.pairs(buttonDB.trackers, function(a, b)
						return buttonDB.trackers[a].order < buttonDB.trackers[b].order
					end)
				do
					trackerCount = trackerCount + 1

					local included = 0
					local numGuilds = 0

					if DS then
						for guildName, guild in self.pairs(DS:GetGuilds(DS.ThisRealm, DS.ThisAccount)) do
							if DS.db.global.Guilds[guild].faction == UnitFactionGroup("player") then
								numGuilds = numGuilds + 1
								included = trackerInfo.includeGuildBank[guild] and (included + 1) or included
							end
						end

						local trackerType, trackerID = self:ParseTrackerKey(tracker)
						self:GetTrackerDataTable(buttonDB, trackerType, trackerID, function(data)
							if trackerCount == (self.maxTooltipTrackers + 1) then -- Shorten list
								pending = {
									{
										line = format("%d %s...", numTrackers - self.maxTooltipTrackers, L["more"]),
										color = desc,
									},
									{
										texture = true,
										line = 134400,
									},
								}

								lines = InsertPending(lines, pending)
							elseif trackerCount < self.maxTooltipTrackers then
								pending = {
									{
										double = true,
										k = data.name,
										v = format("%d / %d", included, numGuilds),
										color = desc,
									},
									{
										texture = true,
										line = data.icon,
									},
								}

								lines = InsertPending(lines, pending)
							end
						end)
					end
				end
			end

			-- Trackers
			pending = {
				{
					line = " ",
					color = desc,
				},
				{
					double = true,
					k = L["Trackers"],
					v = numTrackers,
					color = kv,
				},
			}

			lines = InsertPending(lines, pending)

			local trackerCount = 0
			for key, trackerInfo in
				self.pairs(buttonDB.trackers, function(a, b)
					return buttonDB.trackers[a].order < buttonDB.trackers[b].order
				end)
			do
				trackerCount = trackerCount + 1
				if trackerCount > self.maxTooltipTrackers then -- Shorten list
					pending = {
						{
							line = format("%d %s...", numTrackers - self.maxTooltipTrackers, L["more"]),
							color = desc,
						},
						{
							texture = true,
							line = 134400,
						},
					}

					lines = InsertPending(lines, pending)
					break
				else
					local trackerType, trackerID = self:ParseTrackerKey(key)

					self:GetTrackerDataTable(buttonDB, trackerType, trackerID, function(data)
						-- Get count
						local trackerCount = self:GetTrackerCount(widget, key)
						local trackerRawCount

						if trackerType == "ITEM" then
							trackerRawCount = (trackerInfo.includeAllChars or trackerInfo.includeGuildBank)
									and self:GetDataStoreItemCount(trackerID, trackerInfo)
								or GetItemCount(trackerID, trackerInfo.includeBank)
						elseif trackerType == "CURRENCY" and trackerID ~= "" then
							trackerRawCount = trackerInfo.includeAllChars
									and self:GetDataStoreCurrencyCount(trackerID, trackerInfo)
								or (
									C_CurrencyInfo.GetCurrencyInfo(trackerID)
									and C_CurrencyInfo.GetCurrencyInfo(trackerID).quantity
								)
						end

						-- If custom condition, display trackerRawCount instead of the default counter
						if data.conditionInfo == "" then
							pending = {
								{
									double = true,
									k = data.name,
									v = format(
										"%s%d%s|r (%d / %d)",
										((objective and objective > 0) and (trackerCount < objective))
												and utils.ChatColors["YELLOW"]
											or utils.ChatColors["GREEN"],
										trackerCount,
										(objective and objective > 0) and " / " .. objective or "",
										trackerRawCount,
										(
												(trackerInfo.objective and trackerInfo.objective > 0)
													and trackerInfo.objective
												or 1
											) * ((objective and objective > 0) and objective or 1)
									),
									color = desc,
								},
							}
						else
							pending = {
								{
									double = true,
									k = data.name,
									v = trackerRawCount,
									color = desc,
								},
							}
						end

						tinsert(pending, {
							texture = true,
							line = data.icon,
						})

						lines = InsertPending(lines, pending)
					end)
				end
			end
		end
	end

	-- ButtonID
	pending = {
		{
			line = " ",
			color = desc,
		},
		{
			double = true,
			k = L["Button ID"],
			v = widget:GetButtonID(),
			color = kv,
		},
	}

	lines = InsertPending(lines, pending)

	-- Hints
	if self:GetDBValue("global", "settings.hints.buttons") then
		tinsert(lines, {
			line = " ",
			color = desc,
		})

		if self:IsTooltipMod() then
			tinsert(lines, {
				line = format("%s:", L["Hints"]),
				color = desc,
			})

			if widget:IsEmpty() then
				pending = {
					{
						line = L.ButtonHints(
							"showQuickAddEditBox",
							self:GetDBValue("global", "settings.keybinds.button.showQuickAddEditBox")
						),
						color = desc,
					},
					--@retail@
					{
						line = L.ButtonHints(
							"showQuickAddCurrencyEditBox",
							self:GetDBValue("global", "settings.keybinds.button.showQuickAddCurrencyEditBox")
						),
						color = desc,
					},
					--@end-retail@
					{
						line = L.ButtonHints(
							"showObjectiveEditor",
							self:GetDBValue("global", "settings.keybinds.button.showObjectiveEditor")
						),
						color = desc,
					},
				}

				lines = InsertPending(lines, pending)
			else
				for k, v in
					self.pairs(self:GetDBValue("global", "settings.keybinds.button"), function(a, b)
						return buttonCommandSort[a] < buttonCommandSort[b]
					end)
				do
					tinsert(lines, {
						line = L.ButtonHints(k, v),
						color = desc,
					})
				end
			end
		else
			tinsert(lines, {
				double = true,
				k = L["Expand Tooltip"] .. ":",
				v = L[self:GetDBValue("global", "settings.tooltips.modifier")],
				color = kv,
			})
		end
	end

	return lines
end
