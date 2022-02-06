local addonName = ...
local addon = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

local ACD = LibStub("AceConfigDialog-3.0")

-- *------------------------------------------------------------------------

function addon:GetSkinEditorOptions()
	local skins = addon:GetDBValue("global", "skins")

	local options = {
		new = {
			order = 1,
			type = "execute",
			width = 0.75,
			name = L["New"],
			func = function()
				addon:CreateSkin()
			end,
		},
		importSkin = {
			order = 2,
			type = "execute",
			width = 0.75,
			name = L["Import"],
			func = function() end,
		},
		remove = {
			order = 3,
			type = "select",
			style = "dropdown",
			name = L["Remove Skin"],
			disabled = function()
				return addon.tcount(skins) == 0
			end,
			confirm = function(_, value)
				return format(L.Options_skinEditor_skins_remove, value)
			end,
			values = function()
				local values = {}

				for skinID, skinInfo in addon.pairs(skins) do
					values[skinID] = skinID
				end

				return values
			end,
			sorting = function()
				local sorting = {}

				for skinID, _ in
					addon.pairs(skins, function(a, b)
						local prefixA, numA = strsplit(" ", a)
						local prefixB, numB = strsplit(" ", b)

						return tonumber(numA) < tonumber(numB)
					end)
				do
					tinsert(sorting, skinID)
				end

				return sorting
			end,
			set = function(_, value)
				addon:RemoveSkin(value)
			end,
		},
		skins = {
			order = 4,
			type = "group",
			name = L["Skins"],
			disabled = function()
				return addon.tcount(skins) == 0
			end,
			args = addon:GetSkinEditorOptions_Skins(skins),
		},
	}

	return options
end

function addon:GetSkinEditorOptions_Skins(skins)
	local options = {}

	local count = 1
	for skinID, skinInfo in
		addon.pairs(skins, function(a, b)
			local prefixA, numA = strsplit(" ", a)
			local prefixB, numB = strsplit(" ", b)

			return tonumber(numA) < tonumber(numB)
		end)
	do
		count = count + 1
		options[skinID] = {
			order = count,
			type = "group",
			name = skinID,
			childGroups = "tab",
			args = {
				barTextures = {
					order = 1,
					type = "group",
					name = L["Bar Textures"],
					args = {},
				},
				buttonTextures = {
					order = 2,
					type = "group",
					name = L["Button Textures"],
					args = {},
				},
				manage = {
					order = 3,
					type = "group",
					name = L["Manage"],
					args = {
						copyFrom = {
							order = 1,
							type = "select",
							style = "dropdown",
							name = L["Copy From"],
							values = function()
								local values = {
									FarmingBar_Default = "FarmingBar_Default",
									FarmingBar_Minimal = "FarmingBar_Minimal",
								}

								for skin, _ in pairs(addon:GetDBValue("global", "skins")) do
									values[skin] = skin
								end

								return values
							end,
							sorting = function()
								local sorting = { "FarmingBar_Default", "FarmingBar_Minimal" }

								for skin, _ in
									addon.pairs(skins, function(a, b)
										local prefixA, numA = strsplit(" ", a)
										local prefixB, numB = strsplit(" ", b)

										return tonumber(numA) < tonumber(numB)
									end)
								do
									if skin ~= skinID then
										tinsert(sorting, skin)
									end
								end

								return sorting
							end,
							set = function(_, value)
								local desc = skins[skinID].desc
								skins[skinID] = addon:CloneTable(addon.skins[value] or skins[value])
								skins[skinID].desc = desc

								if addon:GetDBValue("profile", "style.skin") == skinID then
									self:UpdateBars()
								end

								addon:RefreshOptions()
							end,
						},
						duplicateSkin = {
							order = 2,
							type = "execute",
							name = L["Duplicate Skin"],
							func = function()
								addon:DuplicateSkin(skinID)
							end,
						},
						exportSkin = {
							order = 3,
							type = "execute",
							name = L["Export Skin"],
							func = function() end,
						},
						removeSkin = {
							order = 4,
							type = "execute",
							name = L["Remove Skin"],
							confirm = function()
								return format(L.Options_skinEditor_skins_remove, skinID)
							end,
							func = function()
								addon:RemoveSkin(skinID)
							end,
						},
					},
				},
			},
		}
	end

	return options
end
