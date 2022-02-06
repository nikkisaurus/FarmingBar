local addonName = ...
local addon = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

-- *------------------------------------------------------------------------

local anchors = {
	TOPLEFT = L["Topleft"],
	TOP = L["Top"],
	TOPRIGHT = L["Topright"],
	LEFT = L["Left"],
	CENTER = L["Center"],
	RIGHT = L["Right"],
	BOTTOMLEFT = L["Bottomleft"],
	BOTTOM = L["Bottom"],
	BOTTOMRIGHT = L["Bottomright"],
}

local anchorSort = { "TOPLEFT", "TOP", "TOPRIGHT", "LEFT", "CENTER", "RIGHT", "BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT" }

-- https://wowwiki-archive.fandom.com/wiki/USERAPI_RGBToHex
local function RGBToHex(r, g, b)
	r = r <= 255 and r >= 0 and r or 0
	g = g <= 255 and g >= 0 and g or 0
	b = b <= 255 and b >= 0 and b or 0
	return string.format("%02x%02x%02x", r, g, b)
end

-- *------------------------------------------------------------------------
-- Get options

function addon:GetConfigOptions()
	local options = {
		addBar = {
			order = 1,
			type = "execute",
			width = 0.75,
			name = L["New"],
			func = function()
				self:CreateBar()
			end,
		},
		spacer = {
			order = 2,
			type = "description",
			name = " ",
			width = 0.05,
		},
		enableDisable = {
			order = 3,
			type = "select",
			name = L["Enable / Disable"],
			disabled = function()
				return self.tcount(self:GetDBValue("profile", "bars")) == 0
			end,
			values = function()
				local values = {}
				local bars = self:GetDBValue("profile", "bars")

				for barID, _ in pairs(bars) do
					values[barID] = L["Bar"] .. " " .. barID
				end

				return values
			end,
			sorting = function()
				local sorting = {}
				local bars = self:GetDBValue("profile", "bars")

				for barID, _ in pairs(bars) do
					tinsert(sorting, barID)
				end

				return sorting
			end,
			set = function(_, barID)
				self:SetBarDisabled(barID, "_TOGGLE_")
			end,
		},
		RemoveBar = {
			order = 4,
			type = "select",
			name = L["Remove Bar"],
			disabled = function()
				return self.tcount(self:GetDBValue("profile", "bars")) == 0
			end,
			values = function()
				local values = {}
				local bars = self:GetDBValue("profile", "bars")

				for barID, _ in pairs(bars) do
					values[barID] = L["Bar"] .. " " .. barID
				end

				return values
			end,
			sorting = function()
				local sorting = {}
				local bars = self:GetDBValue("profile", "bars")

				for barID, _ in pairs(bars) do
					tinsert(sorting, barID)
				end

				return sorting
			end,
			confirm = function(_, barID)
				return format(L.ConfirmRemoveBar, barID)
			end,
			set = function(_, barID)
				self:RemoveBar(barID)
			end,
		},
		bar0 = {
			order = 5,
			type = "group",
			name = L["All Bars"],
			childGroups = "tab",
			disabled = function()
				return #addon.bars < 2
			end,
			args = {
				bar = {
					order = 1,
					type = "group",
					name = L["Bar"],
					args = self:GetBarConfigOptions(0),
				},
				button = {
					order = 2,
					type = "group",
					name = L["Button"],
					args = self:GetButtonConfigOptions(0),
				},
			},
		},
		container = {
			order = 6,
			type = "group",
			name = L["Bars"],
			disabled = function()
				return #addon.bars == 0
			end,
			args = {},
		},
	}

	for barID, _ in pairs(self:GetDBValue("profile", "bars")) do
		local barName = L["Bar"] .. " " .. barID

		options.container.args["bar" .. barID] = {
			order = barID,
			type = "group",
			name = barName,
			childGroups = "tab",
			args = {
				bar = {
					order = 1,
					type = "group",
					name = L["Bar"],
					args = self:GetBarConfigOptions(barID),
				},
				button = {
					order = 2,
					type = "group",
					name = L["Button"],
					args = self:GetButtonConfigOptions(barID),
				},
				manage = {
					order = 3,
					type = "group",
					name = L["Manage"],
					args = self:GetManageConfigOptions(barID),
				},
			},
		}
	end

	return options
end

function addon:GetBarConfigOptions(barID)
	local options

	if barID == 0 then -- Config all bars
		options = {
			alerts = {
				order = 1,
				type = "group",
				inline = true,
				width = "full",
				name = "*" .. L["Alerts"],
				get = function(info)
					local count = 0
					for barID, _ in pairs(addon.bars) do
						count = addon:GetBarDBValue("alerts." .. info[#info], barID, true) and (count + 1) or count
					end

					if count == 0 then
						return false
					elseif count == #addon.bars then
						return true
					else
						return nil
					end
				end,
				set = function(info, value)
					for barID, _ in pairs(addon.bars) do
						addon:SetBarDBValue("alerts." .. info[#info], value, barID, true)
					end
				end,
				args = {
					muteAll = {
						order = 1,
						type = "toggle",
						tristate = true,
						name = L["Mute All"],
					},
					barProgress = {
						order = 2,
						type = "toggle",
						tristate = true,
						name = L["Bar Progress"],
					},
					completedObjectives = {
						order = 3,
						type = "toggle",
						tristate = true,
						name = L["Completed Objectives"],
					},
				},
			},
			visibility = {
				order = 2,
				type = "group",
				inline = true,
				width = "full",
				name = L["Visibility"],
				get = function(info)
					local count = 0
					for barID, _ in pairs(addon.bars) do
						count = addon:GetBarDBValue(info[#info], barID) and (count + 1) or count
					end

					if count == 0 then
						return false
					elseif count == #addon.bars then
						return true
					else
						return nil
					end
				end,
				set = function(info, value)
					for barID, bar in pairs(addon.bars) do
						addon:SetBarDBValue(info[#info], value, barID)
						bar:SetAlpha()
					end
				end,
				args = {
					showEmpty = {
						order = 1,
						type = "toggle",
						tristate = true,
						name = L["Show Empty Buttons"],
					},
					mouseover = {
						order = 2,
						type = "toggle",
						tristate = true,
						name = L["Show on Mouseover"],
					},
					anchorMouseover = {
						order = 3,
						type = "toggle",
						tristate = true,
						name = L["Show on Anchor Mouseover"],
					},
					hidden = {
						order = 4,
						type = "toggle",
						tristate = true,
						name = L["Hidden"],
						set = function(info, value)
							for barID, bar in pairs(addon.bars) do
								addon:SetBarDBValue(info[#info], value, barID)
								bar:SetHidden()
							end
						end,
					},
				},
			},
			point = {
				order = 3,
				type = "group",
				inline = true,
				width = "full",
				name = L["Point"],
				args = {
					growthDirection = {
						order = 1,
						type = "select",
						name = L["Growth Direction"],
						values = {
							RIGHT = L["Right"],
							LEFT = L["Left"],
							UP = L["Up"],
							DOWN = L["Down"],
						},
						sorting = { "RIGHT", "LEFT", "UP", "DOWN" },
						get = function()
							local direction
							for barID, _ in pairs(addon.bars) do
								local grow = addon:GetBarDBValue("grow", barID)[1]
								if not direction then
									direction = grow
								elseif direction ~= grow then
									return
								end
							end

							return direction
						end,
						set = function(_, value)
							for barID, bar in pairs(addon.bars) do
								addon:GetDBValue("profile", "bars")[barID].grow[1] = value
								bar:AnchorButtons()
							end
						end,
					},
					growthType = {
						order = 2,
						type = "select",
						name = L["Anchor"],
						values = {
							DOWN = L["Normal"],
							UP = L["Reverse"],
						},
						sorting = { "DOWN", "UP" },
						get = function()
							local direction
							for barID, _ in pairs(addon.bars) do
								local grow = addon:GetBarDBValue("grow", barID)[2]
								if not direction then
									direction = grow
								elseif direction ~= grow then
									return
								end
							end

							return direction
						end,
						set = function(info, value)
							for barID, bar in pairs(addon.bars) do
								addon:GetDBValue("profile", "bars")[barID].grow[2] = value
								bar:AnchorButtons()
							end
						end,
					},
					movable = {
						order = 3,
						type = "toggle",
						name = L["Movable"],
						get = function(info)
							local count = 0
							for barID, _ in pairs(addon.bars) do
								count = addon:GetBarDBValue(info[#info], barID) and (count + 1) or count
							end

							if count == 0 then
								return false
							elseif count == #addon.bars then
								return true
							else
								return nil
							end
						end,
						set = function(info, value)
							for barID, bar in pairs(addon.bars) do
								addon:SetBarDBValue(info[#info], value, barID)
								bar:SetMovable()
							end
						end,
					},
				},
			},
			style = {
				order = 4,
				type = "group",
				inline = true,
				width = "full",
				name = L["Style"],
				get = function(info)
					local value
					for barID, _ in pairs(addon.bars) do
						local val = addon:GetBarDBValue(info[#info], barID)
						if not value then
							value = val
						elseif value ~= val then
							return
						end
					end

					return value
				end,
				args = {
					alpha = {
						order = 1,
						type = "range",
						name = L["Alpha"],
						min = 0,
						max = 1,
						step = 0.01,
						set = function(info, value)
							for barID, bar in pairs(addon.bars) do
								addon:SetBarDBValue(info[#info], value, barID)
								bar:SetAlpha()
							end
						end,
					},
					backdropPadding = {
						order = 2,
						type = "range",
						name = L["Backdrop Padding"],
						min = 0,
						max = 10,
						step = 1,
						set = function(info, value)
							for barID, bar in pairs(addon.bars) do
								addon:SetBarDBValue(info[#info], value, barID)
								bar:SetBackdropAnchor()
							end
						end,
					},
					backdrop = {
						order = 3,
						type = "select",
						style = "dropdown",
						control = "LSM30_Background",
						name = L["Backdrop"],
						values = AceGUIWidgetLSMlists.background,
						set = function(info, value)
							for barID, bar in pairs(addon.bars) do
								addon:SetBarDBValue(info[#info], value, barID)
								bar:UpdateBackdrop()
							end
						end,
					},
					backdropColor = {
						order = 4,
						type = "color",
						name = L["Backdrop Color"],
						hasAlpha = true,
						get = function(info)
							local color = {}
							for barID, bar in pairs(addon.bars) do
								local val = addon:GetBarDBValue(info[#info], barID)
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
							end

							return unpack(color)
						end,
						set = function(info, ...)
							for barID, bar in pairs(addon.bars) do
								addon:SetBarDBValue(info[#info], { ... }, barID)
								bar:UpdateBackdrop()
							end
						end,
					},
				},
			},
			charSpecific = {
				order = 5,
				type = "description",
				width = "full",
				name = L.Options_Config("charSpecific"),
			},
		}
	else -- Config barID
		options = {
			title = {
				order = 1,
				type = "input",
				width = "full",
				name = "*" .. L["Title"],
				get = function()
					return addon:GetBarDBValue("title", barID, true)
				end,
				set = function(_, value)
					addon:SetBarDBValue("title", value, barID, true)
				end,
			},
			alerts = {
				order = 2,
				type = "group",
				inline = true,
				width = "full",
				name = "*" .. L["Alerts"],
				get = function(info)
					return addon:GetBarDBValue("alerts." .. info[#info], barID, true)
				end,
				set = function(info, value)
					addon:SetBarDBValue("alerts." .. info[#info], value, barID, true)
				end,
				args = {
					muteAll = {
						order = 1,
						type = "toggle",
						name = L["Mute All"],
					},
					barProgress = {
						order = 2,
						type = "toggle",
						name = L["Bar Progress"],
					},
					completedObjectives = {
						order = 3,
						type = "toggle",
						name = L["Completed Objectives"],
					},
				},
			},
			visibility = {
				order = 3,
				type = "group",
				inline = true,
				width = "full",
				name = L["Visibility"],
				get = function(info)
					return addon:GetBarDBValue(info[#info], barID)
				end,
				set = function(info, value)
					addon:SetBarDBValue(info[#info], value, barID)
					self.bars[barID]:SetAlpha()
				end,
				args = {
					showEmpty = {
						order = 1,
						type = "toggle",
						name = L["Show Empty Buttons"],
					},
					mouseover = {
						order = 2,
						type = "toggle",
						name = L["Show on Mouseover"],
					},
					anchorMouseover = {
						order = 3,
						type = "toggle",
						name = L["Show on Anchor Mouseover"],
					},
					hidden = {
						order = 4,
						type = "toggle",
						name = L["Hidden"],
						set = function(info, value)
							addon:SetBarDBValue(info[#info], value, barID)
							self.bars[barID]:SetHidden()
						end,
					},
					customHideEvents = {
						order = 5,
						type = "input",
						name = L["Custom Hide Events"],
						desc = L.CustomHideEventsDesc,
						width = "full",
						validate = function(_, input)
							if input == "" then
								return true
							end
							input = gsub(input, " ", "")
							local events = { strsplit(",", input) }
							for _, event in pairs(events) do
								local frame = addon.bars[barID].frame
								local success = pcall(frame.RegisterEvent, frame, event)
								if not success then
									return L.InvalidEvent(event)
								end
							end
							return true
						end,
						get = function(info)
							return table.concat(addon:GetBarDBValue("customHide.events", barID), ",")
						end,
						set = function(info, value)
							value = gsub(value, " ", "")
							addon:SetBarDBValue(
								"customHide.events",
								value == "" and {} or { strsplit(",", value) },
								barID
							)
							addon.bars[barID]:SetHidden()
						end,
					},
					customHide = {
						order = 6,
						type = "input",
						name = L["Custom Hide Function"],
						width = "full",
						multiline = true,
						dialogControl = "FarmingBar_LuaEditBox",
						validate = function(_, input)
							local success, err = pcall(loadstring("return " .. input))
							return success or (L["Custom Hide Function"] .. ": " .. err)
						end,
						get = function(info)
							return addon:GetBarDBValue("customHide.func", barID)
						end,
						set = function(info, value)
							addon:SetBarDBValue("customHide.func", value, barID)
							addon.bars[barID]:SetHidden()
						end,
						arg = { "profile", "customHide.func", "UpdateBars", { "SetHidden" }, barID },
					},
				},
			},
			point = {
				order = 4,
				type = "group",
				inline = true,
				width = "full",
				name = L["Point"],
				args = {
					growthDirection = {
						order = 1,
						type = "select",
						name = L["Growth Direction"],
						values = {
							RIGHT = L["Right"],
							LEFT = L["Left"],
							UP = L["Up"],
							DOWN = L["Down"],
						},
						sorting = { "RIGHT", "LEFT", "UP", "DOWN" },
						get = function()
							return addon:GetBarDBValue("grow", barID)[1]
						end,
						set = function(info, value)
							addon:GetDBValue("profile", "bars")[barID].grow[1] = value
							self.bars[barID]:AnchorButtons()
						end,
					},
					growthType = {
						order = 2,
						type = "select",
						name = L["Anchor"],
						values = {
							DOWN = L["Normal"],
							UP = L["Reverse"],
						},
						sorting = { "DOWN", "UP" },
						get = function()
							return addon:GetBarDBValue("grow", barID)[2]
						end,
						set = function(info, value)
							addon:GetDBValue("profile", "bars")[barID].grow[2] = value
							self.bars[barID]:AnchorButtons()
						end,
					},
					movable = {
						order = 3,
						type = "toggle",
						name = L["Movable"],
						get = function(info)
							return addon:GetBarDBValue(info[#info], barID)
						end,
						set = function(info, value)
							addon:SetBarDBValue(info[#info], value, barID)
							self.bars[barID]:SetMovable()
						end,
					},
				},
			},
			style = {
				order = 5,
				type = "group",
				inline = true,
				width = "full",
				name = L["Style"],
				get = function(info)
					return addon:GetBarDBValue(info[#info], barID)
				end,
				args = {
					alpha = {
						order = 1,
						type = "range",
						name = L["Alpha"],
						min = 0,
						max = 1,
						step = 0.01,
						set = function(info, value)
							addon:SetBarDBValue(info[#info], value, barID)
							self.bars[barID]:SetAlpha()
						end,
					},
					backdropPadding = {
						order = 2,
						type = "range",
						name = L["Backdrop Padding"],
						min = 0,
						max = 10,
						step = 1,
						set = function(info, value)
							addon:SetBarDBValue(info[#info], value, barID)
							self.bars[barID]:SetBackdropAnchor()
						end,
					},
					backdrop = {
						order = 3,
						type = "select",
						style = "dropdown",
						control = "LSM30_Background",
						name = L["Backdrop"],
						values = AceGUIWidgetLSMlists.background,
						set = function(info, value)
							addon:SetBarDBValue(info[#info], value, barID)
							self.bars[barID]:UpdateBackdrop()
						end,
					},
					backdropColor = {
						order = 4,
						type = "color",
						name = L["Backdrop Color"],
						hasAlpha = true,
						get = function(info)
							return unpack(addon:GetBarDBValue(info[#info], barID))
						end,
						set = function(info, ...)
							addon:SetBarDBValue(info[#info], { ... }, barID)
							self.bars[barID]:UpdateBackdrop()
						end,
					},
				},
			},
			charSpecific = {
				order = 6,
				type = "description",
				width = "full",
				name = L.Options_Config("charSpecific"),
			},
		}
	end

	return options
end

function addon:GetButtonConfigOptions(barID)
	local options

	if barID == 0 then
		options = {
			buttons = {
				order = 1,
				type = "group",
				inline = true,
				width = "full",
				name = L["Buttons"],
				get = function(info)
					local value
					for barID, _ in pairs(addon.bars) do
						local val = addon:GetBarDBValue(info[#info], barID)
						if not value then
							value = val
						elseif value ~= val then
							return
						end
					end

					return value
				end,
				args = {
					numVisibleButtons = {
						order = 1,
						type = "range",
						name = L["Number of Buttons"],
						min = 0,
						max = self.maxButtons,
						step = 1,
						set = function(info, value)
							for barID, bar in pairs(addon.bars) do
								addon:SetBarDBValue(info[#info], value, barID)
								bar:UpdateVisibleButtons()
								bar:SetBackdropAnchor()
							end
						end,
					},
					buttonWrap = {
						order = 2,
						type = "range",
						name = L["Buttons Per Wrap"],
						min = 1,
						max = self.maxButtons,
						step = 1,
						set = function(info, value)
							for barID, bar in pairs(addon.bars) do
								addon:SetBarDBValue(info[#info], value, barID)
								bar:AnchorButtons()
							end
						end,
					},
				},
			},
			style = {
				order = 2,
				type = "group",
				inline = true,
				width = "full",
				name = L["Style"],
				args = {
					size = {
						order = 1,
						type = "range",
						name = L["Size"],
						min = self.minButtonSize,
						max = self.maxButtonSize,
						step = 1,
						get = function(info)
							local value
							for barID, _ in pairs(addon.bars) do
								local val = addon:GetBarDBValue("button." .. info[#info], barID)
								if not value then
									value = val
								elseif value ~= val then
									return
								end
							end

							return value
						end,
						set = function(info, value)
							for barID, bar in pairs(addon.bars) do
								addon:SetBarDBValue("button." .. info[#info], value, barID)
								bar:SetSize()
							end
						end,
					},
					padding = {
						order = 2,
						type = "range",
						name = L["Padding"],
						min = self.minButtonPadding,
						max = self.maxButtonPadding,
						step = 1,
						get = function(info)
							local value
							for barID, _ in pairs(addon.bars) do
								local val = addon:GetBarDBValue("button." .. info[#info], barID)
								if not value then
									value = val
								elseif value ~= val then
									return
								end
							end

							return value
						end,
						set = function(info, value)
							for barID, bar in pairs(addon.bars) do
								addon:SetBarDBValue("button." .. info[#info], value, barID)
								bar:SetSize()
								bar:AnchorButtons()
							end
						end,
					},
					countHeader = {
						order = 3,
						type = "header",
						name = L["Count Fontstring"],
					},
					countAnchor = {
						order = 4,
						type = "select",
						name = L["Anchor"],
						values = anchors,
						sorting = anchorSort,
						get = function(info)
							local value
							for barID, _ in pairs(addon.bars) do
								local val = addon:GetBarDBValue("button.fontStrings.count.anchor", barID)
								if not value then
									value = val
								elseif value ~= val then
									return
								end
							end

							return value
						end,
						set = function(info, value)
							for barID, _ in pairs(addon.bars) do
								addon:SetBarDBValue("button.fontStrings.count.anchor", value, barID)
								addon:UpdateButtons()
							end
						end,
					},
					countXOffset = {
						order = 5,
						type = "range",
						name = L["X Offset"],
						min = -self.OffsetX,
						max = self.OffsetX,
						step = 1,
						get = function(info)
							local value
							for barID, _ in pairs(addon.bars) do
								local val = addon:GetBarDBValue("button.fontStrings.count.xOffset", barID)
								if not value then
									value = val
								elseif value ~= val then
									return
								end
							end

							return value
						end,
						set = function(info, value)
							for barID, _ in pairs(addon.bars) do
								addon:SetBarDBValue("button.fontStrings.count.xOffset", value, barID)
								addon:UpdateButtons()
							end
						end,
					},
					countYOffset = {
						order = 6,
						type = "range",
						name = L["Y Offset"],
						min = -self.OffsetY,
						max = self.OffsetY,
						step = 1,
						get = function(info)
							local value
							for barID, _ in pairs(addon.bars) do
								local val = addon:GetBarDBValue("button.fontStrings.count.yOffset", barID)
								if not value then
									value = val
								elseif value ~= val then
									return
								end
							end

							return value
						end,
						set = function(info, value)
							for barID, _ in pairs(addon.bars) do
								addon:SetBarDBValue("button.fontStrings.count.yOffset", value, barID)
								addon:UpdateButtons()
							end
						end,
					},
					objectiveHeader = {
						order = 7,
						type = "header",
						name = L["Objective Fontstring"],
					},
					objectiveAnchor = {
						order = 8,
						type = "select",
						name = L["Anchor"],
						values = anchors,
						sorting = anchorSort,
						get = function(info)
							local value
							for barID, _ in pairs(addon.bars) do
								local val = addon:GetBarDBValue("button.fontStrings.objective.anchor", barID)
								if not value then
									value = val
								elseif value ~= val then
									return
								end
							end

							return value
						end,
						set = function(info, value)
							for barID, _ in pairs(addon.bars) do
								addon:SetBarDBValue("button.fontStrings.objective.anchor", value, barID)
								addon:UpdateButtons()
							end
						end,
					},
					objectiveXOffset = {
						order = 9,
						type = "range",
						name = L["X Offset"],
						min = -self.OffsetX,
						max = self.OffsetX,
						step = 1,
						get = function(info)
							local value
							for barID, _ in pairs(addon.bars) do
								local val = addon:GetBarDBValue("button.fontStrings.objective.xOffset", barID)
								if not value then
									value = val
								elseif value ~= val then
									return
								end
							end

							return value
						end,
						set = function(info, value)
							for barID, _ in pairs(addon.bars) do
								addon:SetBarDBValue("button.fontStrings.objective.xOffset", value, barID)
								addon:UpdateButtons()
							end
						end,
					},
					objectiveYOffset = {
						order = 10,
						type = "range",
						name = L["Y Offset"],
						min = -self.OffsetY,
						max = self.OffsetY,
						step = 1,
						get = function(info)
							local value
							for barID, _ in pairs(addon.bars) do
								local val = addon:GetBarDBValue("button.fontStrings.objective.yOffset", barID)
								if not value then
									value = val
								elseif value ~= val then
									return
								end
							end

							return value
						end,
						set = function(info, value)
							for barID, _ in pairs(addon.bars) do
								addon:SetBarDBValue("button.fontStrings.objective.yOffset", value, barID)
								addon:UpdateButtons()
							end
						end,
					},
				},
			},
		}
	else
		options = {
			buttons = {
				order = 1,
				type = "group",
				inline = true,
				width = "full",
				name = L["Buttons"],
				get = function(info)
					return self:GetBarDBValue(info[#info], barID)
				end,
				args = {
					numVisibleButtons = {
						order = 1,
						type = "range",
						name = L["Number of Buttons"],
						min = 0,
						max = self.maxButtons,
						step = 1,
						set = function(info, value)
							self:SetBarDBValue(info[#info], value, barID)
							self.bars[barID]:UpdateVisibleButtons()
							self.bars[barID]:SetBackdropAnchor()
						end,
					},
					buttonWrap = {
						order = 2,
						type = "range",
						name = L["Buttons Per Wrap"],
						min = 1,
						max = self.maxButtons,
						step = 1,
						set = function(info, value)
							self:SetBarDBValue(info[#info], value, barID)
							self.bars[barID]:AnchorButtons()
						end,
					},
				},
			},
			style = {
				order = 2,
				type = "group",
				inline = true,
				width = "full",
				name = L["Style"],
				args = {
					size = {
						order = 1,
						type = "range",
						name = L["Size"],
						min = self.minButtonSize,
						max = self.maxButtonSize,
						step = 1,
						get = function(info)
							return self:GetBarDBValue("button." .. info[#info], barID)
						end,
						set = function(info, value)
							self:SetBarDBValue("button." .. info[#info], value, barID)
							self.bars[barID]:SetSize()
						end,
					},
					padding = {
						order = 2,
						type = "range",
						name = L["Padding"],
						min = self.minButtonPadding,
						max = self.maxButtonPadding,
						step = 1,
						get = function(info)
							return self:GetBarDBValue("button." .. info[#info], barID)
						end,
						set = function(info, value)
							self:SetBarDBValue("button." .. info[#info], value, barID)
							self.bars[barID]:SetSize()
							self.bars[barID]:AnchorButtons()
						end,
					},
					countHeader = {
						order = 3,
						type = "header",
						name = L["Count Fontstring"],
					},
					countAnchor = {
						order = 4,
						type = "select",
						name = L["Anchor"],
						values = anchors,
						sorting = anchorSort,
						get = function(info)
							return self:GetBarDBValue("button.fontStrings.count.anchor", barID)
						end,
						set = function(info, value)
							self:SetBarDBValue("button.fontStrings.count.anchor", value, barID)
							self:UpdateButtons()
						end,
					},
					countXOffset = {
						order = 5,
						type = "range",
						name = L["X Offset"],
						min = -self.OffsetX,
						max = self.OffsetX,
						step = 1,
						get = function(info)
							return self:GetBarDBValue("button.fontStrings.count.xOffset", barID)
						end,
						set = function(info, value)
							self:SetBarDBValue("button.fontStrings.count.xOffset", value, barID)
							self:UpdateButtons()
						end,
					},
					countYOffset = {
						order = 6,
						type = "range",
						name = L["Y Offset"],
						min = -self.OffsetY,
						max = self.OffsetY,
						step = 1,
						get = function(info)
							return self:GetBarDBValue("button.fontStrings.count.yOffset", barID)
						end,
						set = function(info, value)
							self:SetBarDBValue("button.fontStrings.count.yOffset", value, barID)
							self:UpdateButtons()
						end,
					},
					objectiveHeader = {
						order = 7,
						type = "header",
						name = L["Objective Fontstring"],
					},
					objectiveAnchor = {
						order = 8,
						type = "select",
						name = L["Anchor"],
						values = anchors,
						sorting = anchorSort,
						get = function(info)
							return self:GetBarDBValue("button.fontStrings.objective.anchor", barID)
						end,
						set = function(info, value)
							self:SetBarDBValue("button.fontStrings.objective.anchor", value, barID)
							self:UpdateButtons()
						end,
					},
					objectiveXOffset = {
						order = 9,
						type = "range",
						name = L["X Offset"],
						min = -self.OffsetX,
						max = self.OffsetX,
						step = 1,
						get = function(info)
							return self:GetBarDBValue("button.fontStrings.objective.xOffset", barID)
						end,
						set = function(info, value)
							self:SetBarDBValue("button.fontStrings.objective.xOffset", value, barID)
							self:UpdateButtons()
						end,
					},
					objectiveYOffset = {
						order = 10,
						type = "range",
						name = L["Y Offset"],
						min = -self.OffsetY,
						max = self.OffsetY,
						step = 1,
						get = function(info)
							return self:GetBarDBValue("button.fontStrings.objective.yOffset", barID)
						end,
						set = function(info, value)
							self:SetBarDBValue("button.fontStrings.objective.yOffset", value, barID)
							self:UpdateButtons()
						end,
					},
				},
			},
		}
	end

	return options
end

function addon:GetManageConfigOptions(barID)
	local options = {
		enabled = {
			order = 0,
			type = "toggle",
			width = "full",
			name = "Enabled",
			get = function()
				return addon:GetBarDBValue("enabled", barID)
			end,
			set = function(_, value)
				addon:SetBarDBValue("enabled", value, barID)
				addon:SetBarDisabled(barID, value)
			end,
		},
		template = {
			order = 1,
			type = "group",
			inline = true,
			width = "full",
			name = "*" .. L["Template"],
			args = {
				title = {
					order = 1,
					type = "input",
					name = L["Save as Template"],
					set = function(_, value)
						self:SaveTemplate(barID, value)
					end,
				},
				builtinTemplate = {
					order = 2,
					type = "select",
					name = L["Load Template"],
					values = function()
						local values = {}

						for templateName, _ in self.pairs(self.templates) do
							values[templateName] = templateName
						end

						return values
					end,
					sorting = function()
						local sorting = {}

						for templateName, _ in self.pairs(self.templates) do
							tinsert(sorting, templateName)
						end

						return sorting
					end,
					set = function(_, templateName)
						self:LoadTemplate(nil, barID, templateName)
					end,
				},
				userTemplate = {
					order = 2,
					type = "select",
					name = L["Load User Template"],
					disabled = function()
						return self.tcount(addon:GetDBValue("global", "templates")) == 0
					end,
					values = function()
						local values = {}

						for templateName, _ in self.pairs(addon:GetDBValue("global", "templates")) do
							values[templateName] = templateName
						end

						return values
					end,
					sorting = function()
						local sorting = {}

						for templateName, _ in self.pairs(addon:GetDBValue("global", "templates")) do
							tinsert(sorting, templateName)
						end

						return sorting
					end,
					set = function(_, templateName)
						if addon:GetDBValue("global", "settings.misc.preserveTemplateData") == "PROMPT" then
							local dialog = StaticPopup_Show("FARMINGBAR_INCLUDE_TEMPLATE_DATA", templateName)
							if dialog then
								dialog.data = { barID, templateName }
							end
						else
							if addon:GetDBValue("global", "settings.misc.preserveTemplateOrder") == "PROMPT" then
								local dialog = StaticPopup_Show("FARMINGBAR_SAVE_TEMPLATE_ORDER", templateName)
								if dialog then
									dialog.data = {
										barID,
										templateName,
										addon:GetDBValue("global", "settings.misc.preserveTemplateData") == "ENABLED",
									}
								end
							else
								addon:LoadTemplate(
									"user",
									barID,
									templateName,
									addon:GetDBValue("global", "settings.misc.preserveTemplateData") == "ENABLED",
									addon:GetDBValue("global", "settings.misc.preserveTemplateOrder") == "ENABLED"
								)
							end
						end
					end,
				},
			},
		},
		operations = {
			order = 2,
			type = "group",
			inline = true,
			width = "full",
			name = L["Operations"],
			args = {
				clearButtons = {
					order = 1,
					type = "execute",
					name = "*" .. L["Clear Buttons"],
					func = function()
						self:ClearBar(barID)
					end,
				},
				reindexButtons = {
					order = 2,
					type = "execute",
					name = "*" .. L["Reindex Buttons"],
					func = function()
						self:ReindexButtons(barID)
					end,
				},
				sizeBarToButtons = {
					order = 3,
					type = "execute",
					name = "**" .. L["Resize Bar"],
					func = function()
						self:SizeBarToButtons(barID)
					end,
				},
			},
		},

		CopyFrom = {
			order = 3,
			type = "select",
			style = "dropdown",
			name = "Copy From",
			disabled = function()
				return addon.tcount(addon.bars) <= 1
			end,
			values = function()
				local values = {}

				for id, _ in pairs(addon:GetDBValue("profile", "bars")) do
					if id ~= barID and id ~= "**" then
						values[id] = format("%s %d", L["Bar"], id)
					end
				end
				return values
			end,
			set = function(info, value)
				local bars = addon:GetDBValue("profile", "bars")
				local point = bars[barID].point
				bars[barID] = addon:CloneTable(bars[value])
				-- Preserve bar position, so there are not issues with moving a bar below another, and enabled status
				bars[barID].point = addon:CloneTable(point)
				-- Redraw bars
				addon:ReleaseAllBars()
				addon:InitializeBars()
				addon:RefreshOptions()
			end,
		},
		DuplicateBar = {
			order = 4,
			type = "execute",
			name = L["Duplicate Bar"],
			func = function()
				local newBarID = addon:CreateBar()

				local bars = addon:GetDBValue("profile", "bars")
				local point = bars[newBarID].point
				bars[newBarID] = addon:CloneTable(bars[barID])
				-- Preserve bar position, so there are not issues with moving a bar below another, and enabled status
				bars[newBarID].point = addon:CloneTable(point)
				-- Redraw bars
				addon:ReleaseAllBars()
				addon:InitializeBars()
				addon:RefreshOptions()
			end,
		},
		RemoveBar = {
			order = 5,
			type = "execute",
			name = L["Remove Bar"],
			confirm = function()
				return format(L.ConfirmRemoveBar, barID)
			end,
			func = function()
				self:RemoveBar(barID)
			end,
		},
		spacer = {
			order = 6,
			type = "description",
			name = "",
		},
		charSpecific = {
			order = 7,
			type = "description",
			width = "full",
			name = L.Options_Config("charSpecific"),
		},
		mixedSpecific = {
			order = 8,
			type = "description",
			width = "full",
			name = L.Options_Config("mixedSpecific"),
		},
	}

	return options
end
