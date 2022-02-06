local addonName = ...
local addon = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

local ACD = LibStub("AceConfigDialog-3.0")

local anchoredLayers = {
	Border = true,
	AccountOverlay = true,
	AutoCastable = true,
}

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
			disabled = true,
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

				for skinID, _ in addon.pairs(skins, addon.sortSkins) do
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
	for skinID, skinInfo in addon.pairs(skins, addon.sortSkins) do
		-- Create skin options
		count = count + 1
		options[skinID] = {
			order = count,
			type = "group",
			name = skinID,
			desc = skinInfo.desc,
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
				buttonLayers = {
					order = 3,
					type = "group",
					name = L["Button Layers"],
					args = {},
				},
				manage = {
					order = 4,
					type = "group",
					name = L["Manage"],
					args = {
						description = {
							order = 1,
							type = "input",
							width = "full",
							name = L["Description"],
							get = function()
								return skinInfo.desc
							end,
							set = function(_, value)
								skins[skinID].desc = value
							end,
						},
						copyFrom = {
							order = 2,
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

								for skin, _ in addon.pairs(skins, addon.sortSkins) do
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
							order = 3,
							type = "execute",
							name = L["Duplicate Skin"],
							func = function()
								addon:DuplicateSkin(skinID)
							end,
						},
						exportSkin = {
							order = 4,
							type = "execute",
							name = L["Export Skin"],
							disabled = true,
							func = function() end,
						},
						removeSkin = {
							order = 5,
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

		-- Bar texture options
		for key, value in pairs(skins[skinID].bar) do
			options[skinID].args.barTextures.args[key] = {
				type = "group",
				inline = true,
				name = L.GetBarTextureTitle(key),
				get = function(info)
					return addon:GetDBValue(
						"global",
						format("%s.%s.%s.%s.%s", "skins", skinID, "bar", key, info[#info])
					)
				end,
				set = function(info, value)
					addon:SetDBValue(
						"global",
						format("%s.%s.%s.%s.%s", "skins", skinID, "bar", key, info[#info]),
						value
					)

					addon:UpdateBars()
				end,
				args = {
					chooseTexture = {
						order = 1,
						type = "execute",
						name = L["Explore Textures"],
						disabled = true,
						func = function() end,
					},
					texture = {
						order = 2,
						type = "input",
						width = "full",
						name = L["Texture"],
					},
					texCoords = {
						order = 3,
						type = "input",
						name = L["Tex Coords"],
						validate = function(_, value)
							if value == "" then
								return true
							end

							value = gsub(value, "%s", "")
							local coords = { strsplit(",", value) }
							for _, v in pairs(coords) do
								v = tonumber(v)
								if not v or v < 0 or v > 1 then
									return
								end
							end

							local numCoords = addon.tcount(coords)
							if numCoords == 4 or numCoords == 8 then
								return true
							end
						end,
						get = function(info)
							local coords = addon:GetDBValue(
								"global",
								format("%s.%s.%s.%s.%s", "skins", skinID, "bar", key, info[#info])
							)
							return strjoin(",", unpack(coords))
						end,
						set = function(info, value)
							if value == "" then
								addon:SetDBValue(
									"global",
									format("%s.%s.%s.%s.%s", "skins", skinID, "bar", key, info[#info]),
									{ 0, 1, 0, 1 }
								)

								addon:UpdateBars()
								return
							end

							value = gsub(value, "%s", "")
							local coords = { strsplit(",", value) }
							for k, v in pairs(coords) do
								coords[k] = tonumber(v)
							end

							addon:SetDBValue(
								"global",
								format("%s.%s.%s.%s.%s", "skins", skinID, "bar", key, info[#info]),
								coords
							)
							addon:UpdateBars()
						end,
					},
					color = {
						order = 4,
						type = "color",
						name = L["Color"],
						hasAlpha = true,
						get = function(info)
							local color = {}
							local val = addon:GetDBValue(
								"global",
								format("%s.%s.%s.%s.%s", "skins", skinID, "bar", key, info[#info])
							)

							if #color == 0 then
								for k, v in addon.pairs(val) do
									if v > 1 then
										v = v / 255
									end
									tinsert(color, v)
								end
							else
								for k, v in addon.pairs(val) do
									if v > 1 then
										v = v / 255
									end
									if color[k] ~= v then
										return
									end
								end
							end

							return unpack(color)
						end,
						set = function(info, ...)
							skins[skinID].bar[key][info[#info]] = { ... }
							addon:UpdateBars()
						end,
					},
				},
			}
		end

		-- Button texture options
		for key, value in pairs(skins[skinID].button) do
			if key ~= "layers" then
				options[skinID].args.buttonTextures.args[key] = {
					order = 0,
					type = "group",
					inline = true,
					name = key,
					get = function(info)
						return addon:GetDBValue(
							"global",
							format("%s.%s.%s.%s.%s", "skins", skinID, "button", key, info[#info])
						)
					end,
					set = function(info, value)
						addon:SetDBValue(
							"global",
							format("%s.%s.%s.%s.%s", "skins", skinID, "button", key, info[#info]),
							value
						)

						addon:UpdateBars()
					end,
					args = {
						chooseTexture = {
							order = 1,
							type = "execute",
							name = L["Explore Textures"],
							disabled = true,
							func = function() end,
						},
						texture = {
							order = 2,
							type = "input",
							width = "full",
							name = L["Texture"],
						},
						texCoords = {
							order = 3,
							type = "input",
							name = L["Tex Coords"],
							validate = function(_, value)
								if value == "" then
									return true
								end

								value = gsub(value, "%s", "")
								local coords = { strsplit(",", value) }
								for _, v in pairs(coords) do
									v = tonumber(v)
									if not v or v < 0 or v > 1 then
										return
									end
								end

								local numCoords = addon.tcount(coords)
								if numCoords == 4 or numCoords == 8 then
									return true
								end
							end,
							get = function(info)
								local coords = addon:GetDBValue(
									"global",
									format("%s.%s.%s.%s.%s", "skins", skinID, "button", key, info[#info])
								) or { 0, 1, 0, 1 }

								return strjoin(",", unpack(coords))
							end,
							set = function(info, value)
								if value == "" then
									addon:SetDBValue(
										"global",
										format("%s.%s.%s.%s.%s", "skins", skinID, "button", key, info[#info]),
										{ 0, 1, 0, 1 }
									)

									addon:UpdateBars()
									return
								end

								value = gsub(value, "%s", "")
								local coords = { strsplit(",", value) }
								for k, v in pairs(coords) do
									coords[k] = tonumber(v)
								end

								addon:SetDBValue(
									"global",
									format("%s.%s.%s.%s.%s", "skins", skinID, "button", key, info[#info]),
									coords
								)
								addon:UpdateBars()
							end,
						},
						insets = {
							order = 4,
							type = "input",
							name = L["Insets"],
							validate = function(_, value)
								if value == "" then
									return true
								end

								value = gsub(value, "%s", "")
								local insets = { strsplit(",", value) }
								for _, v in pairs(insets) do
									v = tonumber(v)
									if not v then
										return
									end
								end

								local numInsets = addon.tcount(insets)
								if numInsets == 4 then
									return true
								end
							end,
							get = function(info)
								local insets = addon:GetDBValue(
									"global",
									format("%s.%s.%s.%s.%s", "skins", skinID, "button", key, info[#info])
								) or { 0, 0, 0, 0 }
								return strjoin(",", unpack(insets))
							end,
							set = function(info, value)
								if value == "" then
									addon:SetDBValue(
										"global",
										format("%s.%s.%s.%s.%s", "skins", skinID, "button", key, info[#info]),
										{ 0, 0, 0, 0 }
									)

									addon:UpdateBars()
									return
								end

								value = gsub(value, "%s", "")
								local insets = { strsplit(",", value) }
								for k, v in pairs(insets) do
									insets[k] = tonumber(v)
								end

								addon:SetDBValue(
									"global",
									format("%s.%s.%s.%s.%s", "skins", skinID, "button", key, info[#info]),
									insets
								)
								addon:UpdateBars()
							end,
						},
						blendMode = {
							order = 5,
							type = "select",
							style = "dropdown",
							name = L["Blend Mode"],
							values = {
								DISABLE = L["Disable"],
								BLEND = L["Blend"],
								ALPHAKEY = L["AlphaKey"],
								ADD = L["Add"],
								MOD = L["Mod"],
							},
							sorting = { "DISABLE", "BLEND", "ALPHAKEY", "ADD", "MOD" },
						},
						color = {
							order = 6,
							type = "color",
							name = L["Color"],
							hasAlpha = true,
							get = function(info)
								local color = {}
								local val = addon:GetDBValue(
									"global",
									format("%s.%s.%s.%s.%s", "skins", skinID, "button", key, info[#info])
								) or { 1, 1, 1, 1 }

								if #color == 0 then
									for k, v in addon.pairs(val) do
										if v > 1 then
											v = v / 255
										end
										tinsert(color, v)
									end
								else
									for k, v in addon.pairs(val) do
										if v > 1 then
											v = v / 255
										end
										if color[k] ~= v then
											return
										end
									end
								end

								return unpack(color)
							end,
							set = function(info, ...)
								skins[skinID].button[key][info[#info]] = { ... }
								addon:UpdateBars()
							end,
						},
					},
				}
			end
		end

		-- Button Layer options
		for key, value in pairs(skins[skinID].button.layers) do
			options[skinID].args.buttonLayers.args[key] = {
				order = 0,
				type = "group",
				inline = true,
				name = key,
				get = function(info)
					return addon:GetDBValue(
						"global",
						format("%s.%s.%s.%s.%s", "skins", skinID, "button.layers", key, info[#info])
					)
				end,
				set = function(info, value)
					addon:SetDBValue(
						"global",
						format("%s.%s.%s.%s.%s", "skins", skinID, "button.layers", key, info[#info]),
						value
					)

					addon:UpdateBars()
				end,
				args = {
					chooseTexture = {
						order = 1,
						type = "execute",
						name = L["Explore Textures"],
						disabled = true,
						func = function() end,
					},
					texture = {
						order = 2,
						type = "input",
						width = "full",
						name = L["Texture"],
					},
					texCoords = {
						order = 3,
						type = "input",
						name = L["Tex Coords"],
						validate = function(_, value)
							if value == "" then
								return true
							end

							value = gsub(value, "%s", "")
							local coords = { strsplit(",", value) }
							for _, v in pairs(coords) do
								v = tonumber(v)
								if not v or v < 0 or v > 1 then
									return
								end
							end

							local numCoords = addon.tcount(coords)
							if numCoords == 4 or numCoords == 8 then
								return true
							end
						end,
						get = function(info)
							local coords = addon:GetDBValue(
								"global",
								format("%s.%s.%s.%s.%s", "skins", skinID, "button.layers", key, info[#info])
							) or { 0, 1, 0, 1 }

							return strjoin(",", unpack(coords))
						end,
						set = function(info, value)
							if value == "" then
								addon:SetDBValue(
									"global",
									format("%s.%s.%s.%s.%s", "skins", skinID, "button.layers", key, info[#info]),
									{ 0, 1, 0, 1 }
								)

								addon:UpdateBars()
								return
							end

							value = gsub(value, "%s", "")
							local coords = { strsplit(",", value) }
							for k, v in pairs(coords) do
								coords[k] = tonumber(v)
							end

							addon:SetDBValue(
								"global",
								format("%s.%s.%s.%s.%s", "skins", skinID, "button.layers", key, info[#info]),
								coords
							)
							addon:UpdateBars()
						end,
					},
					insets = {
						order = 4,
						type = "input",
						name = L["Insets"],
						validate = function(_, value)
							if value == "" then
								return true
							end

							value = gsub(value, "%s", "")
							local insets = { strsplit(",", value) }
							for _, v in pairs(insets) do
								v = tonumber(v)
								if not v then
									return
								end
							end

							local numInsets = addon.tcount(insets)
							if numInsets == 4 then
								return true
							end
						end,
						get = function(info)
							local insets = addon:GetDBValue(
								"global",
								format("%s.%s.%s.%s.%s", "skins", skinID, "button.layers", key, info[#info])
							) or { 0, 0, 0, 0 }
							return strjoin(",", unpack(insets))
						end,
						set = function(info, value)
							if value == "" then
								addon:SetDBValue(
									"global",
									format("%s.%s.%s.%s.%s", "skins", skinID, "button.layers", key, info[#info]),
									{ 0, 0, 0, 0 }
								)

								addon:UpdateBars()
								return
							end

							value = gsub(value, "%s", "")
							local insets = { strsplit(",", value) }
							for k, v in pairs(insets) do
								insets[k] = tonumber(v)
							end

							addon:SetDBValue(
								"global",
								format("%s.%s.%s.%s.%s", "skins", skinID, "button.layers", key, info[#info]),
								insets
							)
							addon:UpdateBars()
						end,
					},
					blendMode = {
						order = 5,
						type = "select",
						style = "dropdown",
						name = L["Blend Mode"],
						values = {
							DISABLE = L["Disable"],
							BLEND = L["Blend"],
							ALPHAKEY = L["AlphaKey"],
							ADD = L["Add"],
							MOD = L["Mod"],
						},
						sorting = { "DISABLE", "BLEND", "ALPHAKEY", "ADD", "MOD" },
					},
					color = {
						order = 7,
						type = "color",
						name = L["Color"],
						hasAlpha = true,
						get = function(info)
							local color = {}
							local val = addon:GetDBValue(
								"global",
								format("%s.%s.%s.%s.%s", "skins", skinID, "button.layers", key, info[#info])
							) or { 1, 1, 1, 1 }

							if #color == 0 then
								for k, v in addon.pairs(val) do
									if v > 1 then
										v = v / 255
									end
									tinsert(color, v)
								end
							else
								for k, v in addon.pairs(val) do
									if v > 1 then
										v = v / 255
									end
									if color[k] ~= v then
										return
									end
								end
							end

							return unpack(color)
						end,
						set = function(info, ...)
							skins[skinID].button[key][info[#info]] = { ... }
							addon:UpdateBars()
						end,
					},
				},
			}

			if anchoredLayers[key] then
				options[skinID].args.buttonLayers.args[key].args.anchor = {
					order = 6,
					type = "select",
					style = "dropdown",
					name = L["Anchor"],
					values = function()
						local values = {}

						for K, V in pairs(skins[skinID].button.layers) do
							if not anchoredLayers[K] then
								values[K] = K
							end
						end

						return values
					end,
				}
			end
		end
	end

	return options
end
