local addonName = ...
local addon = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

-- *------------------------------------------------------------------------
-- Defaults

local panelBackdrop = {
	bgFile = 130871,
	tile = true,
	tileSize = 16,
	edgeFile = 137057,
	edgeSize = 16,
	insets = {
		left = 3,
		right = 3,
		top = 3,
		bottom = 3,
	},
}

addon.skins = {
	FarmingBar_Default = {
		bar = {
			FloatingBG = {
				texture = [[INTERFACE\BUTTONS\UI-QUICKSLOT]],
				texCoords = { 12 / 64, 52 / 64, 12 / 64, 52 / 64 },
				color = { 1, 1, 1, 1 },
			},
			Normal = {
				texture = "",
				texCoords = { 0, 1, 0, 1 },
				color = { 1, 1, 1, 1 },
			},
		},
		button = {
			Normal = {
				texture = "INTERFACE\\BUTTONS\\UI-QUICKSLOT2",
				texCoords = { 12 / 64, 51 / 64, 12 / 64, 51 / 64 },
				color = { 1, 1, 1, 1 },
				blendMode = "BLEND",
				insets = { 0, 0, 0, 0 },
			},
			Pushed = {
				texture = "INTERFACE\\BUTTONS\\UI-QUICKSLOT2",
				texCoords = { 12 / 64, 51 / 64, 12 / 64, 51 / 64 },
				color = { 1, 1, 1, 1 },
				blendMode = "BLEND",
				insets = { 0, 0, 0, 0 },
			},
			Highlight = {
				texture = "INTERFACE\\BUTTONS\\BUTTONHILIGHT-SQUAREQUICKSLOT",
				texCoords = { 0, 1, 0, 1 },
				color = { 1, 1, 1, 1 },
				blendMode = "ADD",
				insets = { 2, 2, 0, 0 },
			},
			layers = {
				FloatingBG = {
					texture = [[INTERFACE\BUTTONS\UI-EMPTYSLOT-DISABLED]],
					texCoords = { 10 / 64, 53 / 64, 10 / 64, 53 / 64 },
					color = { 1, 1, 1, 1 },
					blendMode = "BLEND",
					insets = { 0, 0, 0, 0 },
				},
				Icon = {
					texture = "",
					texCoords = { 0, 1, 0, 1 },
					color = { 1, 1, 1, 1 },
					blendMode = "BLEND",
					insets = { 2, 2.5, 2.5, 2.5 },
				},
				Flash = {
					texture = "INTERFACE\\BUTTONS\\WHITE8X8",
					texCoords = { 0, 1, 0, 1 },
					color = { 1, 0, 0, 1 },
					blendMode = "ADD",
					insets = { 2, 2, 2, 2 },
				},
				Border = {
					texture = "INTERFACE\\BUTTONS\\UI-ACTIONBUTTON-BORDER",
					texCoords = { 12 / 64, 50 / 64, 14 / 64, 52 / 64 },
					color = { 1, 1, 1, 1 },
					blendMode = "ADD",
					insets = { 0, 0, 0, 0 },
					anchor = "Icon",
				},
				AccountOverlay = {
					texture = [[INTERFACE\ADDONS\FARMINGBAR\MEDIA\4POINTDIAMOND]],
					texCoords = { 0.1, 0.9, 0.1, 0.9 },
					color = { 1, 33 / 51, 0, 1 },
					blendMode = "BLEND",
					insets = { -2, -2, -2, -2 },
					anchor = "Icon",
				},
				AutoCastable = {
					texture = "INTERFACE\\BUTTONS\\UI-AUTOCASTABLEOVERLAY",
					texCoords = { 14 / 64, 49 / 64, 14 / 64, 49 / 64 },
					color = { 1, 1, 1, 1 },
					blendMode = "BLEND",
					insets = { 0, 0, 0, 0 },
					anchor = "Icon",
				},
			},
		},
	},
	FarmingBar_Minimal = {
		bar = {
			FloatingBG = {
				texture = [[INTERFACE\BUTTONS\WHITE8X8]],
				texCoords = { 0, 1, 0, 1 },
				color = { 0, 0, 0, 0.5 },
			},
			Normal = {
				texture = "INTERFACE\\ADDONS\\FARMINGBAR\\MEDIA\\ICONBORDERTHICK",
				texCoords = { 4 / 64, 60 / 64, 4 / 64, 60 / 64 }, -- 1px border (5 - borderSize, 64 - left)
				color = { 0, 0, 0, 1 },
			},
		},
		button = {
			Normal = {
				texture = "INTERFACE\\ADDONS\\FARMINGBAR\\MEDIA\\ICONBORDERTHICK",
				texCoords = { 4 / 64, 60 / 64, 4 / 64, 60 / 64 }, -- 1px border (5 - borderSize, 64 - left)
				color = { 0, 0, 0, 1 },
				blendMode = "BLEND",
				insets = { 0, 0, 0, 0 },
			},
			Pushed = {
				texture = "INTERFACE\\BUTTONS\\WHITE8X8",
				texCoords = { 0, 1, 0, 1 },
				color = { 1, 0.82, 0, 0.15 },
				blendMode = "ADD",
				insets = { 0.75, 0.75, 0.75, 0.75 },
			},
			Highlight = {
				texture = "INTERFACE\\BUTTONS\\WHITE8X8",
				texCoords = { 0, 1, 0, 1 },
				color = { 1, 1, 1, 0.15 },
				blendMode = "ADD",
				insets = { 0.75, 0.75, 0.75, 0.75 },
			},
			layers = {
				FloatingBG = {
					texture = [[INTERFACE\BUTTONS\WHITE8X8]],
					texCoords = { 0, 1, 0, 1 },
					color = { 0, 0, 0, 0.5 },
					blendMode = "BLEND",
					insets = { 0, 0, 0, 0 },
				},
				Icon = {
					texture = "",
					texCoords = { 6 / 64, 58 / 64, 6 / 64, 58 / 64 },
					color = { 1, 1, 1, 1 },
					blendMode = "BLEND",
					insets = { 1, 1, 1, 1 },
				},
				Flash = {
					texture = "INTERFACE\\BUTTONS\\WHITE8X8",
					texCoords = { 0, 1, 0, 1 },
					color = { 1, 0, 0, 1 },
					blendMode = "ADD",
					insets = { 0, 0, 0, 0 },
				},
				Border = {
					texture = "INTERFACE\\ADDONS\\FARMINGBAR\\MEDIA\\ICONBORDERTHICK",
					texCoords = { 2 / 64, 62 / 64, 2 / 64, 62 / 64 },
					color = { 1, 1, 1, 1 },
					blendMode = "BLEND",
					insets = { 0, 0, 0, 0 },
					anchor = "Icon",
				},
				AccountOverlay = {
					texture = [[INTERFACE\ADDONS\FARMINGBAR\MEDIA\4POINTDIAMOND]],
					texCoords = { 0.1, 0.9, 0.1, 0.9 },
					color = { 1, 33 / 51, 0, 1 },
					blendMode = "BLEND",
					insets = { -2, -2, -2, -2 },
					anchor = "Icon",
				},
				AutoCastable = {
					texture = "INTERFACE\\BUTTONS\\UI-AUTOCASTABLEOVERLAY",
					texCoords = { 14 / 64, 49 / 64, 14 / 64, 49 / 64 },
					color = { 1, 1, 1, 1 },
					blendMode = "BLEND",
					insets = { 0, 0, 0, 0 },
				},
			},
		},
	},
}

-- *------------------------------------------------------------------------
-- Strip textures

function addon:StripBarTextures(bar)
	local frame = bar.anchor

	bar.FloatingBG:SetTexCoord(0, 1, 0, 1)
	bar.FloatingBG:SetVertexColor(1, 1, 1, 1)
	bar.FloatingBG:SetTexture("")

	if not frame:GetNormalTexture() then
		return
	end

	frame:GetNormalTexture():SetTexCoord(0, 1, 0, 1)
	frame:GetNormalTexture():SetVertexColor(1, 1, 1, 1)
	frame:SetNormalTexture("")
end

function addon:StripButtonTextures(button)
	local frame = button.frame

	for layerName, layer in pairs(addon.skins.FarmingBar_Default.button) do
		if layerName == "layers" then
			for layerName, _ in pairs(layer) do
				local texture = button[layerName]

				texture:SetTexCoord(0, 1, 0, 1)
				texture:SetVertexColor(1, 1, 1, 1)
				texture:SetBlendMode("BLEND")
				texture:SetPoint("TOPLEFT", 0, 0)
				texture:SetPoint("BOTTOMRIGHT", 0, 0)
				texture:SetTexture("")
			end
		else
			local texture = frame["Get" .. layerName .. "Texture"](frame)
			if not texture then
				return
			end

			texture:SetTexCoord(0, 1, 0, 1)
			texture:SetVertexColor(1, 1, 1, 1)
			texture:SetBlendMode("BLEND")
			texture:SetPoint("TOPLEFT", 0, 0)
			texture:SetPoint("BOTTOMRIGHT", 0, 0)
			texture:SetTexture("")
		end
	end
end

-- *------------------------------------------------------------------------
-- Skin

function addon:SetPanelBackdrop(panel)
	panel:SetBackdrop(panelBackdrop)
	panel:SetBackdropColor(0.1, 0.1, 0.1, 0.5)
	panel:SetBackdropBorderColor(0.4, 0.4, 0.4)
end

function addon:SkinBar(bar, skin)
	self:StripBarTextures(bar)

	skin = (strmatch(skin, "^FarmingBar_") and self.skins[skin] or self:GetDBValue("global", "skins")[skin]).bar
	local frame = bar.anchor

	if frame:GetNormalTexture() then
		frame:SetNormalTexture(skin.Normal.texture)
		frame:GetNormalTexture():SetTexCoord(unpack(skin.Normal.texCoords))
		frame:GetNormalTexture():SetVertexColor(unpack(skin.Normal.color))
	end

	bar.FloatingBG:SetTexture(skin.FloatingBG.texture)
	bar.FloatingBG:SetTexCoord(unpack(skin.FloatingBG.texCoords))
	bar.FloatingBG:SetVertexColor(unpack(skin.FloatingBG.color))
	bar.FloatingBG:SetAllPoints(frame)

	self:ApplyMasqueSkin("anchor", frame)
end

function addon:SkinButton(button, skin)
	self:StripButtonTextures(button)

	skin = (strmatch(skin, "^FarmingBar_") and addon.skins[skin] or self:GetDBValue("global", "skins")[skin]).button
	local frame = button.frame

	for layerName, layer in pairs(skin) do
		if layerName == "layers" then
			for layerName, layer in pairs(layer) do
				local texture = button[layerName]
				local top, right, bottom, left = unpack(layer.insets)

				texture:SetTexture(layer.texture)
				texture:SetTexCoord(unpack(layer.texCoords))
				texture:SetVertexColor(unpack(layer.color))
				texture:SetBlendMode(layer.blendMode)
				texture:SetAllPoints(layer.anchor and button[layer.anchor] or frame)
				texture:SetPoint("TOPLEFT", left, -top)
				texture:SetPoint("BOTTOMRIGHT", -right, bottom)
			end
		else
			frame["Set" .. layerName .. "Texture"](frame, layer.texture)
			local texture = frame["Get" .. layerName .. "Texture"](frame)
			local top, right, bottom, left = unpack(layer.insets)

			texture:SetTexCoord(unpack(layer.texCoords))
			texture:SetVertexColor(unpack(layer.color))
			texture:SetBlendMode(layer.blendMode)
			texture:SetAllPoints(layer.anchor and button[layer.anchor] or frame)
			texture:SetPoint("TOPLEFT", left, -top)
			texture:SetPoint("BOTTOMRIGHT", -right, bottom)
		end
	end

	self:ApplyMasqueSkin("button", frame)
end

-- *------------------------------------------------------------------------
-- Masque

local function MSQ_Callback(...)
	for _, bar in pairs(addon.bars) do
		bar:ApplySkin()
	end
end

function addon:Initialize_Masque()
	local MSQ, MSQVersion = LibStub("Masque", true)
	if MSQ and MSQVersion >= 90001 then
		self.MSQ = {
			anchor = MSQ:Group(L.addon, "Anchor"),
			button = MSQ:Group(L.addon, "Button", true),
		}

		self.MSQ.anchor:SetCallback(MSQ_Callback)
		self.MSQ.button:SetCallback(MSQ_Callback)
	end
	return MSQ
end

function addon:ApplyMasqueSkin(buttonType, button)
	if not self.MSQ or self.MSQ[buttonType].db.Disabled or not button.widget then
		return
	end

	if buttonType == "button" then
		self:StripButtonTextures(button.widget)
	elseif buttonType == "anchor" then
		self:StripBarTextures(button.widget)
	end

	self.MSQ[buttonType]:AddButton(button)
	self.MSQ[buttonType]:ReSkin(true)
end

-- *------------------------------------------------------------------------
-- Skin Editor

function addon:SkinExists(title)
	return type(self:GetDBValue("global", "skins")[title].desc) == "string"
end

function addon:CreateSkin(skinID, overwrite)
	local defaultTitle, newSkinTitle = L["Skin"]

	-- Skin exists, so we need to add a number to the end
	if (self:SkinExists(defaultTitle .. " 1") or skinID) and not overwrite then
		local i = 2
		while not newSkinTitle do
			local title = format("%s %d", defaultTitle, i)

			if not self:SkinExists(title) then
				newSkinTitle = title
			else
				i = i + 1
			end
		end
	else
		newSkinTitle = defaultTitle .. " 1"
	end

	-- Create skin
	local skin = self:GetDBValue("global", "skins")[newSkinTitle]
	skin.desc = newSkinTitle

	-- Refresh options
	self:RefreshOptions()
	LibStub("AceConfigDialog-3.0"):SelectGroup(addonName, "skinEditor", "skins", newSkinTitle)

	return newSkinTitle
end

function addon:RemoveSkin(skin)
	if self:GetDBValue("profile", "style.skin") == skin then
		self:SetDBValue("profile", "style.skin", "FarmingBar_Default")
		self:UpdateBars()
	end

	self:GetDBValue("global", "skins")[skin] = nil
	self:RefreshOptions()
end

function addon:DuplicateSkin(skinID)
	local skins = self:GetDBValue("global", "skins")
	local newSkinTitle = self:CreateSkin(skinID)

	skins[newSkinTitle] = self:CloneTable(skins[skinID])
	skins[newSkinTitle].desc = newSkinTitle

	self:RefreshOptions()
end
