local addonName = ...
local U = LibStub("LibAddonUtils-1.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)
local addon = LibStub("AceAddon-3.0"):GetAddon(L.addonName)
local LSM = LibStub("LibSharedMedia-3.0")

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

addon.skins = {
    ["default"] = {
        anchor = {
            FloatingBG = {
                bgFile = "INTERFACE\\BUTTONS\\UI-QUICKSLOT",
                texCoord = {12/64, 52/64, 12/64, 52/64},
                bgColor = {1, 1, 1, 1},
            },
            Normal = {
            },
        },

        button = {
            FloatingBG = {
                bgFile = "INTERFACE\\BUTTONS\\UI-EMPTYSLOT-DISABLED",
                bgColor = {1, 1, 1, 1},
                texCoord = {10/64, 53/64, 10/64, 53/64},
            },
            Icon = {
                texCoord = {0, 1, 0, 1},
                insets = {left = 2.5, right = 2.5, top = 2, bottom = 2.5},
            },
            Flash = {
                bgFile = "INTERFACE\\BUTTONS\\WHITE8X8",
                insets = {left = 2, right = 2, top = 2, bottom = 2},
                blendMode = "ADD",
                bgColor = {1, 0, 0, 1},
            },
            Normal = {
                bgFile = "INTERFACE\\BUTTONS\\UI-QUICKSLOT2",
                texCoord = {12/64, 51/64, 12/64, 51/64},
                borderColor = {1, 1, 1, 1},
            },
            Pushed = {

            },
            Highlight = {
                bgFile = "INTERFACE\\BUTTONS\\BUTTONHILIGHT-SQUAREQUICKSLOT",
                insets = {left = 0, right = 2, top = 2, bottom = 0},
                bgColor = {1, 1, 1, 1},
            },
            Border = {
                bgFile = "INTERFACE\\BUTTONS\\UI-ACTIONBUTTON-BORDER",
                texCoord = {12/64, 50/64, 14/64, 52/64},
                anchor = "Icon",
                blendMode = "ADD",
            },
            AutoCastable = {
                bgFile = "INTERFACE\\BUTTONS\\UI-AUTOCASTABLEOVERLAY",
                texCoord = {14/64, 49/64, 14/64, 49/64},
                anchor = "Icon",
            },
        },

        frame = {
            bgFile = "INTERFACE\\DIALOGFRAME\\UI-DialogBox-Background-Dark",
            borderColor = {1, 1, 1, 1},
            insets = {left = 4, right = 4, top = 4, bottom = 4},
            edgeFile = "INTERFACE\\DIALOGFRAME\\UI-DIALOGBOX-BORDER", tile = false, tileSize = 0, edgeSize = 32,
            borderColor = {1, 1, 1, 1},
        },
    },

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    ["minimal"] = {
        anchor = {
            FloatingBG = {
                bgFile = "INTERFACE\\BUTTONS\\WHITE8X8",
                bgColor = {0, 0, 0, .5},
            },
            Normal = {
                bgFile = "INTERFACE\\ADDONS\\FARMINGBAR\\MEDIA\\ICONBORDERTHICK",
                texCoord = {4/64, 60/64, 4/64, 60/64}, -- 1px border (5 - borderSize, 64 - left)
                borderColor = {0, 0, 0, 1},
            },
        },

        button = {
            FloatingBG = {
                bgFile = "INTERFACE\\BUTTONS\\WHITE8X8",
                bgColor = {0, 0, 0, .5},
            },
            Icon = {
                texCoord = {6/64, 58/64, 6/64, 58/64},
                insets = {left = 1, right = 1, top = 1, bottom = 1},
            },
            Flash = {
                bgFile = "INTERFACE\\BUTTONS\\WHITE8X8",
                blendMode = "ADD",
                bgColor = {1, 0, 0, 1},
            },
            Normal = {
                bgFile = "INTERFACE\\ADDONS\\FARMINGBAR\\MEDIA\\ICONBORDERTHICK",
                texCoord = {4/64, 60/64, 4/64, 60/64}, -- 1px border (5 - borderSize, 64 - left)
                borderColor = {0, 0, 0, 1},
            },
            Pushed = {
                bgFile = "INTERFACE\\BUTTONS\\WHITE8X8",
                insets = {left = .75, right = .75, top = .75, bottom = .75},
                bgColor = {1, .82, 0, .15},
            },
            Highlight = {
                bgFile = "INTERFACE\\BUTTONS\\WHITE8X8",
                insets = {left = .75, right = .75, top = .75, bottom = .75},
                bgColor = {1, 1, 1, .15},
            },
            Border = {
                bgFile = "INTERFACE\\ADDONS\\FARMINGBAR\\MEDIA\\ICONBORDERTHICK",
                texCoord = {2/64, 62/64, 2/64, 62/64},
                anchor = "Icon",
                blendMode = "BLEND",
            },
            AutoCastable = {
                bgFile = "INTERFACE\\BUTTONS\\UI-AUTOCASTABLEOVERLAY",
                texCoord = {14/64, 49/64, 14/64, 49/64},
            },
        },

        frame = {
            bgFile = "INTERFACE\\BUTTONS\\WHITE8X8",
            bgColor = {0, 0, 0, .85},
            edgeFile = "INTERFACE\\BUTTONS\\WHITE8X8", tile = false, tileSize = 0, edgeSize = 1,
            borderColor = {1, 1, 1, .5},
        },
    },
}

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function addon:ApplyButtonSkin(button, skin)
    for k, v in pairs(skin) do
        local texture
        if button[string.format("Get%sTexture", k)] then
            button[string.format("Set%sTexture", k)](button, v.bgFile)
            texture = button[string.format("Get%sTexture", k)](button)
        else
            texture = _G[button:GetName() .. k]
            if texture.SetTexture then
                texture:SetTexture(v.bgFile)
            else
                texture:SetBackdrop(v)
            end
        end

        if texture then
            texture:SetAllPoints(v.anchor and button[v.anchor] or button)

            if v.bgColor then
                if texture.SetVertexColor then
                    texture:SetVertexColor(U.unpack(v.bgColor))
                else
                    texture:SetBackdropColor(U.unpack(v.bgColor))
                end
            end

            if v.borderColor then
                if texture.SetVertexColor then
                    texture:SetVertexColor(U.unpack(v.borderColor))
                else
                    texture:SetBackdropBorderColor(U.unpack(v.borderColor))
                end
            end

            if v.blendMode then
                texture:SetBlendMode(v.blendMode)
            end

            if v.insets then
                texture:SetPoint("TOPLEFT", v.insets.left, -v.insets.top)
                texture:SetPoint("BOTTOMRIGHT", -v.insets.right, v.insets.bottom)
            end

            texture:SetTexCoord(U.unpack(v.texCoord, {0, 1, 0, 1}))
        end
    end
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function addon:ApplyFrameSkin(frame)
    local skin = addon.skins[addon.db.profile.style.skin.name] or addon.db.global.skins[addon.db.profile.style.skin.name]

    frame:SetBackdrop(skin.frame)
    frame:SetBackdropColor(U.unpack(skin.frame.bgColor))
    frame:SetBackdropBorderColor(U.unpack(skin.frame.borderColor))
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function addon:UpdateButtonLayer(layer)
    for barID, bar in pairs(self.bars) do
        for buttonID, button in pairs(bar.buttons) do
            if layer == "CooldownEdge" then
                button.Cooldown:SetDrawEdge(self.db.profile.style.layers.CooldownEdge)
            elseif button[layer] then
                button[layer]:SetAllPoints()

                if layer == "AutoCastable" then
                    button:UpdateAutoCastable()
                elseif layer == "Border" then
                    button:UpdateBorder()
                elseif layer == "Cooldown" then
                    button:SetCooldown()
                end
            end
        end
    end
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function addon:UpdateFonts()
    for barID, bar in pairs(self.bars) do
        bar.anchor:ApplyFont()
        for buttonID, button in pairs(bar.buttons) do
            button:ApplyFont()
        end
    end
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function addon:UpdateMedia(event, mediaType, key)
    if mediaType == "font" and key == bar.db.font.face then
        addon:UpdateFonts()
    end
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function addon:UpdateSkin()
    local skin = self.skins[self.db.profile.style.skin.name] or self.db.global.skins[self.db.profile.style.skin.name]

    -- Updates bars and buttons
    for barID, bar in pairs(self.bars) do
        self:ApplyButtonSkin(bar.anchor, skin.anchor)

        for buttonID, button in pairs(bar.buttons) do
            self:ApplyButtonSkin(button, skin.button)

            if button.objective and button.objective.type then
                -- Update button icon texture if there's a button assigned to it.

                if button.objective.type == "item" then
                    U.CacheItem(button.objective.itemID, function(self) self.Icon:SetTexture(select(10, GetItemInfo(button.objective.itemID))) end, button)
                elseif button.objective.type == "currency" then
                    button.Icon:SetTexture(C_CurrencyInfo.GetCurrencyInfo and C_CurrencyInfo.GetCurrencyInfo(button.objective.currencyID) or select(3, GetCurrencyInfo(button.objective.currencyID)))
                else
                    button.Icon:SetTexture(button:GetBar().db.objectives[button.id].icon)
                end
            end
        end
    end

    -- Updates the coFrame skin
    self:ApplyFrameSkin(self.CoroutineUpdater)
end