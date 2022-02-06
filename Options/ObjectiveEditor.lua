local addonName = ...
local addon = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

-- Optional libraries
local ACD = LibStub("AceConfigDialog-3.0")

-- *------------------------------------------------------------------------
-- Initialize

local widget
function addon:InitializeObjectiveEditorOptions(...)
	widget = ...
	LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName .. "ObjectiveEditor", self:GetObjectiveEditorOptions())
	LibStub("AceConfigDialog-3.0"):SetDefaultSize(addonName .. "ObjectiveEditor", 525, 400)
end

function addon:GetObjectiveEditorOptions()
	local barID, buttonID, buttonDB
	if widget then
		barID, buttonID = widget:GetBarID(), widget:GetUserData("buttonID")
		buttonDB = widget:GetButtonDB()
	end

	local options = {
		type = "group",
		name = format("%s - %s", L.addon, L["Objective Editor"]),
		args = {
			template = {
				order = 1,
				type = "select",
				style = "dropdown",
				name = L["Objective Template"],
				desc = L.ObjectiveEditor_template,
				values = function()
					local values = {
						none = L["None"],
					}

					for templateName, template in pairs(addon:GetDBValue("global", "objectives")) do
						values[templateName] = template.title
					end

					return values
				end,
				get = function(info)
					return buttonDB.template
				end,
				set = function(_, value)
					if value == "none" then
						-- Remove the template link, but don't delete the objective
						widget:RemoveObjectiveTemplateLink()
						return
					end
					-- Update button's template name
					widget:SetDBValue("template", value)
					-- Add link to template's instances
					addon:CreateObjectiveTemplateInstance(value, widget:GetButtonID())
					-- Clear includeAllChars, includeBank, includeGuildBank, and exclude from button trackers
					widget:ClearTrackerInfo()
					--  Update button to match template info
					widget:UpdateLayers()
					-- Update objective editor
					addon:InitializeObjectiveEditorOptions(widget)
					C_Timer.After(0, function()
						ACD:Open(addonName .. "ObjectiveEditor")
					end)
				end,
			},
			editTemplate = {
				order = 2,
				type = "execute",
				width = "half",
				name = L["Edit"],
				desc = L["Edit Template"],
				disabled = function()
					return not buttonDB.template
				end,
				func = function()
					ACD:SelectGroup(addonName, "objectiveBuilder", "objectives", buttonDB.template)
					ACD:Open(addonName)
				end,
			},
			createTemplate = {
				order = 3,
				type = "execute",
				width = "half",
				name = L["Create"],
				desc = L.ObjectiveEditor_CreateTemplate,
				disabled = function()
					return not buttonDB.title or buttonDB.title == "" or buttonDB.template
				end,
				func = function()
					local objectiveTitle = addon:DuplicateObjective(buttonDB.title, buttonDB)

					-- Update button's template name
					widget:SetDBValue("template", objectiveTitle)
					-- Add link to template's instances
					addon:CreateObjectiveTemplateInstance(objectiveTitle, widget:GetButtonID())

					ACD:SelectGroup(addonName, "objectiveBuilder", "objectives", objectiveTitle)
					ACD:Open(addonName)
				end,
			},
			mute = {
				order = 4,
				type = "toggle",
				name = L["Mute Alerts"],
				width = 0.75,
				disabled = function()
					return not buttonDB.title or buttonDB.title == ""
				end,
				get = function()
					return buttonDB.mute
				end,
				set = function(_, value)
					widget:SetDBValue("mute", value)
				end,
			},
			tracker0 = {
				order = 5,
				type = "group",
				name = L["All Trackers"],
				args = self:GetObjectiveEditorOptions_Tracker(0, widget:GetButtonDB().trackers),
			},
		},
	}

	if widget then
		for trackerKey, trackerInfo in self.pairs(widget:GetButtonDB().trackers) do
			local trackerType, trackerID = self:ParseTrackerKey(trackerKey)

			self:GetTrackerDataTable(widget:GetButtonDB(), trackerType, trackerID, function(data)
				options.args[trackerKey] = {
					order = trackerInfo.order + 4,
					type = "group",
					name = data.name,
					args = self:GetObjectiveEditorOptions_Tracker(trackerKey, trackerInfo, data),
				}
				return options
			end)
		end
	end

	return options
end

-- *------------------------------------------------------------------------
-- Load options

function addon:GetObjectiveEditorOptions_IncludeAllChars()
	local options = {}

	-- Check for missing DataStore dependencies
	local missingDependencies = self:IsDataStoreLoaded()
	if addon.tcount(missingDependencies) > 0 then
		local red = LibStub("LibAddonUtils-1.0").ChatColors["RED"]

		options["missingDependencies"] = {
			order = 0,
			type = "description",
			width = "full",
			name = format(
				L.MissingIncludeAllCharsDependecies,
				red .. strjoin("|r, " .. red, unpack(missingDependencies))
			),
		}
	end

	-- Load trackers
	if widget then
		local buttonDB = widget:GetButtonDB()
		local trackers = buttonDB.trackers

		for trackerKey, trackerInfo in pairs(trackers) do
			local trackerType, trackerID = self:ParseTrackerKey(trackerKey)

			self:GetTrackerDataTable(buttonDB, trackerType, trackerID, function(data)
				options[trackerKey] = {
					order = trackerInfo.order,
					type = "toggle",
					width = "full",
					name = data.name,
					get = function()
						return self:GetTrackerDBInfo(trackers, trackerKey, "includeAllChars")
					end,
					set = function(_, value)
						self:SetTrackerDBValue(trackers, trackerKey, "includeAllChars", value)
						widget:UpdateLayers()
					end,
				}

				return options
			end)
		end
	end

	return options
end

function addon:GetObjectiveEditorOptions_IncludeBank()
	local options = {}

	-- Load trackers
	if widget then
		local buttonDB = widget:GetButtonDB()
		local trackers = buttonDB.trackers

		for trackerKey, trackerInfo in pairs(trackers) do
			local trackerType, trackerID = self:ParseTrackerKey(trackerKey)
			self:GetTrackerDataTable(buttonDB, trackerType, trackerID, function(data)
				options[trackerKey] = {
					order = trackerInfo.order,
					type = "toggle",
					width = "full",
					name = data.name,
					get = function()
						return addon:GetTrackerDBInfo(trackers, trackerKey, "includeBank")
					end,
					set = function(_, value)
						addon:SetTrackerDBValue(trackers, trackerKey, "includeBank", value)
						widget:UpdateLayers()
					end,
				}

				return options
			end)
		end
	end

	return options
end

function addon:GetObjectiveEditorOptions_Objective()
	if not widget then
		return {}
	end
	local barID, buttonID = widget:GetBarID(), widget:GetUserData("buttonID")
	local buttonDB = widget:GetButtonDB()

	return {}
end

function addon:GetObjectiveEditorOptions_Tracker(trackerKey, trackerInfo, data)
	if not widget then
		return {}
	end

	local options
	if trackerKey == 0 then
		local trackers = trackerInfo

		options = {
			includeAllChars = {
				order = 1,
				type = "toggle",
				tristate = true,
				width = "full",
				name = L["Include All Characters"],
				disabled = function()
					return #addon:IsDataStoreLoaded() > 0
				end,
				get = function()
					local count = 0
					for trackerKey, trackerInfo in pairs(trackers) do
						count = addon:GetTrackerDBInfo(trackers, trackerKey, "includeAllChars") and (count + 1) or count
					end

					if count == 0 then
						return false
					elseif count == addon.tcount(trackers) then
						return true
					else
						return nil
					end
				end,
				set = function(_, value)
					for trackerKey, trackerInfo in pairs(trackers) do
						addon:SetTrackerDBValue(trackers, trackerKey, "includeAllChars", value)
						widget:SetCount()
					end
					addon:UpdateBars()
				end,
			},
			includeBank = {
				order = 2,
				type = "toggle",
				tristate = true,
				width = "full",
				name = L["Include Bank"],
				disabled = function()
					return #addon:IsDataStoreLoaded() > 0
				end,
				get = function()
					local count = 0
					for trackerKey, trackerInfo in pairs(trackers) do
						count = addon:GetTrackerDBInfo(trackers, trackerKey, "includeBank") and (count + 1) or count
					end

					if count == 0 then
						return false
					elseif count == addon.tcount(trackers) then
						return true
					else
						return nil
					end
				end,
				set = function(_, value)
					for trackerKey, trackerInfo in pairs(trackers) do
						addon:SetTrackerDBValue(trackers, trackerKey, "includeBank", value)
						widget:SetCount()
					end
					addon:UpdateBars()
				end,
			},
		}

		if IsAddOnLoaded("DataStore") then
			options.includeGuildBank = {
				order = 3,
				type = "group",
				inline = true,
				name = L["Include Guild Bank"],
				disabled = function()
					return #addon:IsDataStoreLoaded() > 0
				end,
				args = {},
			}
			for trackerKey, trackerInfo in pairs(trackers) do
				trackers[trackerKey].includeGuildBank = trackers[trackerKey].includeGuildBank or {}

				local DS = DataStore
				if DS then
					for guildName, guild in addon.pairs(DS:GetGuilds(DS.ThisRealm, DS.ThisAccount)) do
						if DS.db.global.Guilds[guild].faction == UnitFactionGroup("player") then
							options.includeGuildBank.args[guild] = {
								type = "toggle",
								tristate = true,
								width = "full",
								name = guildName,
								get = function()
									local count = 0
									for trackerKey, trackerInfo in pairs(trackers) do
										count = addon:GetTrackerDBInfo(trackers, trackerKey, "includeGuildBank")[guild]
												and (count + 1)
											or count
									end

									if count == 0 then
										return false
									elseif count == addon.tcount(trackers) then
										return true
									else
										return nil
									end
								end,
								set = function(_, value)
									for trackerKey, trackerInfo in pairs(trackers) do
										addon:GetTrackerDBInfo(trackers, trackerKey, "includeGuildBank")[guild] = value
										widget:SetCount()
									end
								end,
							}
						end
					end
				end
			end
		end
	else
		local trackerType, trackerID = self:ParseTrackerKey(trackerKey)
		local trackers = widget:GetButtonDB().trackers

		options = {
			includeAllChars = {
				order = 1,
				type = "toggle",
				width = "full",
				name = L["Include All Characters"],
				disabled = function()
					return #addon:IsDataStoreLoaded() > 0
				end,
				get = function()
					return addon:GetTrackerDBInfo(trackers, trackerKey, "includeAllChars")
				end,
				set = function(_, value)
					addon:SetTrackerDBValue(trackers, trackerKey, "includeAllChars", value)
					widget:SetCount()
				end,
			},
		}

		if trackerType == "ITEM" then
			options.includeBank = {
				order = 2,
				type = "toggle",
				width = "full",
				name = L["Include Bank"],
				get = function()
					return addon:GetTrackerDBInfo(trackers, trackerKey, "includeBank")
				end,
				set = function(_, value)
					addon:SetTrackerDBValue(trackers, trackerKey, "includeBank", value)
					widget:SetCount()
				end,
			}
			if IsAddOnLoaded("DataStore") then
				options.includeGuildBank = {
					order = 3,
					type = "group",
					inline = true,
					name = L["Include Guild Bank"],
					disabled = function()
						return #addon:IsDataStoreLoaded() > 0
					end,
					args = {},
				}

				trackers[trackerKey].includeGuildBank = trackers[trackerKey].includeGuildBank or {}

				local DS = DataStore
				if DS then
					for guildName, guild in self.pairs(DS:GetGuilds(DS.ThisRealm, DS.ThisAccount)) do
						if DS.db.global.Guilds[guild].faction == UnitFactionGroup("player") then
							options.includeGuildBank.args[guild] = {
								type = "toggle",
								width = "full",
								name = guildName,
								get = function()
									return addon:GetTrackerDBInfo(trackers, trackerKey, "includeGuildBank")[guild]
								end,
								set = function(_, value)
									addon:GetTrackerDBInfo(trackers, trackerKey, "includeGuildBank")[guild] = value
									widget:SetCount()
								end,
							}
						end
					end
				end
			end
		end
	end

	return options
end
