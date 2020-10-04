local addonName = ...
local U = LibStub("LibAddonUtils-1.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)
local addon = LibStub("AceAddon-3.0"):GetAddon(L.addonName)
local LSM = LibStub("LibSharedMedia-3.0")

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function addon:GetChatOptions()
    local options = {
        type = "group",
        name = L.addonName,
        args = {
            bar = {
                type = "group",
                name = "",
                args = {
                    add = {
                        type = "execute",
                        name = "",
                        desc = L._Commands(L, "bar", "c_addDesc"),
                        func = function(info)
                            if UnitAffectingCombat("player") then
                                addon:Print(L.CommandCombatError)
                                return
                            end

                            local input = info.input:gsub("[bB][aA][rR]%s[aA][dD][dD]", ""):gsub("^ ", "")
                            self:AddBar(input)

                            -- AddBar already calls Refresh()
                        end,
                    },

                    alpha = {
                        type = "execute",
                        name = "",
                        desc = L._Commands(L, "bar", "c_alphaDesc"),
                        func = function(info)
                            local _, _, alpha, barID = strsplit(" ", info.input)
                            alpha = tonumber(alpha)

                            if not alpha or alpha < 0 or alpha > 1 then
                                self:Print(L.GetErrorMessage("invalidAlpha", 0, 1))
                                return
                            elseif barID then
                                barID = tonumber(barID)

                                if not self:ValidateBar(barID) then
                                    self:Print(L.GetErrorMessage("invalidBarID"))
                                    return
                                end

                                self:SetDBValue("char.bars", "alpha", alpha, barID)
                                self.bars[barID]:SetAlpha(alpha)
                            else
                                self:SetMixedDBValues("char.bars", "alpha", alpha, function(bar)
                                    bar:SetAlpha(alpha)
                                end)
                            end

                            self:Refresh()
                        end,
                    },

                    buttons = {
                        type = "execute",
                        name = "",
                        desc = L._Commands(L, "bar", "c_buttonsDesc"),
                        func = function(info)
                            if UnitAffectingCombat("player") then
                                addon:Print(L.CommandCombatError)
                                return
                            end

                            local _, _, numButtons, barID = strsplit(" ", info.input)
                            numButtons = tonumber(numButtons)

                            if not numButtons or numButtons < 1 or numButtons > self.maxButtons then
                                self:Print(L.GetErrorMessage("invalidVisibleButtons", 1, self.maxButtons))
                                return
                            elseif barID then
                                barID = tonumber(barID)

                                if not self:ValidateBar(barID) then
                                    self:Print(L.GetErrorMessage("invalidBarID"))
                                    return
                                end

                                self:SetDBValue("char.bars", "visibleButtons", numButtons, barID)
                                self.bars[barID]:UpdateButtons("SetVisible")
                                self.bars[barID]:SetBackdrop()
                            else
                                self:SetMixedDBValues("char.bars", "visibleButtons", numButtons, function(bar)
                                    bar:UpdateButtons("SetVisible")
                                    bar:SetBackdrop()
                                end)
                            end

                            self:Refresh()
                        end,
                    },

                    empties = {
                        type = "execute",
                        name = "",
                        desc = L._Commands(L, "bar", "c_emptiesDesc"),
                        func = function(info)
                            local _, _, barID, noToggle = strsplit(" ", info.input)

                            if barID == "show" or barID == "hide" then -- Show or hide all bars
                                self:SetMixedDBValues("char.bars", "showEmpties", barID == "show" and true or false)
                            elseif barID then
                                barID = tonumber(barID)
                                if not self:ValidateBar(barID) then -- Change only this bar
                                    self:Print(L.GetErrorMessage("invalidBarID"))
                                    return
                                end

                                self:SetDBValue("char.bars", "showEmpties", not noToggle and "_toggle" or (noToggle == "show" and true or false), barID)
                            else -- Toggle all bars
                                self:SetMixedDBValues("char.bars", "showEmpties", "_toggle")
                            end

                            self:Refresh()
                        end,
                    },

                    font = {
                        type = "execute",
                        name = "",
                        desc = L._Commands(L, "bar", "c_fontDesc"),
                        func = function(info)
                            local _, _, fontSize, barID = strsplit(" ", info.input)
                            fontSize = tonumber(fontSize)

                            if not fontSize or fontSize < self.minFontSize or fontSize > self.maxFontSize then
                                self:Print(L.GetErrorMessage("invalidFontSize", self.minFontSize, self.maxFontSize))
                                return
                            elseif barID then
                                barID = tonumber(barID)

                                if not self:ValidateBar(barID) then
                                    self:Print(L.GetErrorMessage("invalidBarID"))
                                    return
                                end

                                self:SetDBValue("char.bars.font", "size", fontSize, barID)
                                self:UpdateFonts()
                            else
                                self:SetMixedDBValues("profile.style.font", "size", fontSize, function(bar)
                                    addon:SetDBValue("char.bars.font", "size", fontSize, bar.id)
                                    addon:UpdateFonts()
                                end)
                            end

                            self:Refresh()
                        end,
                    },

                    groups = {
                        type = "execute",
                        name = "",
                        desc = L._Commands(L, "bar", "c_groupsDesc"),
                        func = function(info)
                            if UnitAffectingCombat("player") then
                                addon:Print(L.CommandCombatError)
                                return
                            end

                            local _, _, groupSize, barID = strsplit(" ", info.input)
                            groupSize = tonumber(groupSize)

                            if not groupSize or groupSize < 1 or groupSize > self.maxButtons then
                                self:Print(L.GetErrorMessage("invalidGroupSize", 1, self.maxButtons))
                                return
                            elseif barID then
                                barID = tonumber(barID)

                                if not self:ValidateBar(barID) then
                                    self:Print(L.GetErrorMessage("invalidBarID"))
                                    return
                                end

                                self:SetDBValue("char.bars", "buttonsPerRow", groupSize, barID)
                                self.bars[barID]:UpdateButtons("Anchor")
                                self.bars[barID]:SetBackdrop()
                            else
                                self:SetMixedDBValues("char.bars", "buttonsPerRow", groupSize, function(bar)
                                    bar:UpdateButtons("Anchor")
                                    bar:SetBackdrop()
                                end)
                            end

                            self:Refresh()
                        end,
                    },

                    grow = {
                        type = "execute",
                        name = "",
                        desc = L._Commands(L, "bar", "c_growDesc"),
                        func = function(info)
                            if UnitAffectingCombat("player") then
                                addon:Print(L.CommandCombatError)
                                return
                            end

                            local _, _, buttonAnchor, groupAnchor, barID = strsplit(" ", info.input)
                            groupAnchor = (groupAnchor == "normal" and 1) or (groupAnchor == "reverse" and 2)

                            if not buttonAnchor or not self:GetDirection(buttonAnchor) then
                                self:Print(L.GetErrorMessage("invalidButtonDirection"))
                                return
                            elseif not groupAnchor then
                                self:Print(L.GetErrorMessage("invalidGroupDirection"))
                                return
                            end

                            buttonAnchor = tonumber(self:GetDirection(buttonAnchor))

                            if barID then
                                barID = tonumber(barID)

                                if not self:ValidateBar(barID) then
                                    self:Print(L.GetErrorMessage("invalidBarID"))
                                    return
                                end

                                self:SetDBValue("char.bars", "direction", buttonAnchor, barID)
                                self:SetDBValue("char.bars", "rowDirection", groupAnchor, barID)
                                self.bars[barID]:UpdateButtons("Anchor")
                                self.bars[barID]:SetBackdrop()
                            else
                                self:SetMixedDBValues("char.bars", "direction", buttonAnchor)
                                self:SetMixedDBValues("char.bars", "rowDirection", groupAnchor, function(bar)
                                    bar:UpdateButtons("Anchor")
                                    bar:SetBackdrop()
                                end)
                            end

                            self:Refresh()
                        end,
                    },

                    mouseover = {
                        type = "execute",
                        name = "",
                        desc = L._Commands(L, "bar", "c_mouseoverDesc"),
                        func = function(info)
                            local _, _, anchor, barID, noToggle = strsplit(" ", info.input)
                            local mouseover
                            if anchor == "anchor" then
                                mouseover = "anchorMouseover"
                            elseif anchor == "bar" then
                                mouseover = "mouseover"
                            else
                                self:Print(L.GetErrorMessage("invalidMouseoverFrame"))
                                return
                            end

                            if barID == "true" then -- Set mouseover true on all bars
                                self:SetMixedDBValues("char.bars", mouseover, true, function(bar)
                                    bar:SetMouseover()
                                end)
                            elseif barID == "false" then -- Set mouseover false on all bars
                                self:SetMixedDBValues("char.bars", mouseover, false, function(bar)
                                    bar:SetMouseover()
                                end)
                            elseif barID then
                                barID = tonumber(barID)

                                if not self:ValidateBar(barID) then -- Change only this bar
                                    self:Print(L.GetErrorMessage("invalidBarID"))
                                    return
                                end

                                if noToggle == "true" then
                                    self:SetDBValue("char.bars", mouseover, true, barID)
                                    self.bars[barID]:SetMouseover()
                                elseif noToggle == "false" then
                                    self:SetDBValue("char.bars", mouseover, false, barID)
                                    self.bars[barID]:SetMouseover()
                                else
                                    self:SetDBValue("char.bars", mouseover, "_toggle", barID)
                                    self.bars[barID]:SetMouseover()
                                end
                            else -- Toggle all bars
                                self:SetMixedDBValues("char.bars", mouseover, "_toggle", function(bar)
                                    bar:SetMouseover()
                                end)
                            end

                            self:Refresh()
                        end,
                    },

                    movable = {
                        type = "execute",
                        name = "",
                        desc = L._Commands(L, "bar", "c_movableDesc"),
                        func = function(info)
                            local _, _, barID, noToggle = strsplit(" ", info.input)

                            if barID == "lock" then -- Lock all bars
                                self:SetMixedDBValues("char.bars", "movable", false)
                                self:Print(L.BarMovableChanged(nil, false))
                            elseif barID == "unlock" then -- Unlock all bars
                                self:SetMixedDBValues("char.bars", "movable", true)
                                self:Print(L.BarMovableChanged(nil, true))
                            elseif barID then
                                barID = tonumber(barID)

                                if not self:ValidateBar(barID) then -- Change only this bar
                                    self:Print(L.GetErrorMessage("invalidBarID"))
                                    return
                                end

                                if noToggle == "lock" then
                                    self:SetDBValue("char.bars", "movable", false, barID)
                                    self:Print(L.BarMovableChanged(barID, false))
                                elseif noToggle == "unlock" then
                                    self:SetDBValue("char.bars", "movable", true, tonumber(barID))
                                    self:Print(L.BarMovableChanged(barID, true))
                                else
                                    self:SetDBValue("char.bars", "movable", "_toggle", tonumber(barID))
                                    self:Print(L.BarMovableChanged(barID, "_toggle"))
                                end
                            else -- Toggle all bars
                                self:SetMixedDBValues("char.bars", "movable", "_toggle")
                                self:Print(L.BarMovableChanged(nil, "_toggle"))
                            end

                            self:Refresh()
                        end,
                    },

                    mute = {
                        type = "execute",
                        name = "",
                        desc = L._Commands(L, "bar", "c_muteDesc"),
                        func = function(info)
                            local _, _, barID, noToggle = strsplit(" ", info.input)

                            if barID == "true" or barID == "false" then -- Track or untrack all bars
                                self:SetMixedDBValues("char.bars", "muteAlerts", barID == "true" and true or false)
                            elseif barID then
                                barID = tonumber(barID)
                                if not self:ValidateBar(barID) then -- Change only this bar
                                    self:Print(L.GetErrorMessage("invalidBarID"))
                                    return
                                end

                                self:SetDBValue("char.bars", "muteAlerts", not noToggle and "_toggle" or (noToggle == "true" and true or false), barID)
                            else -- Toggle all bars
                                self:SetMixedDBValues("char.bars", "muteAlerts", "_toggle")
                            end

                            self:Refresh()
                        end,
                    },

                    name = {
                        type = "execute",
                        name = "",
                        desc = L._Commands(L, "bar", "c_nameDesc"),
                        func = function(info)
                            local barID, input = info.input:match("^[bB][aA][rR]%s[nN][aA][mM][eE]%s(%d+)%s(.+)$")

                            if not barID or not input then
                                self:Print(L.GetErrorMessage("invalidBarNameArgs"))
                                return
                            end

                            barID = tonumber(barID)

                            if not self:ValidateBar(barID) then
                                self:Print(L.GetErrorMessage("invalidBarID"))
                                return
                            end

                            self.db.char.bars[barID].desc = input

                            self:UpdateBars()
                            self:Refresh()
                        end,
                    },

                    padding = {
                        type = "execute",
                        name = "",
                        desc = L._Commands(L, "bar", "c_paddingDesc"),
                        func = function(info)
                            if UnitAffectingCombat("player") then
                                addon:Print(L.CommandCombatError)
                                return
                            end

                            local _, _, padding, barID = strsplit(" ", info.input)
                            padding = tonumber(padding)

                            if not padding or padding < self.minButtonPadding or padding > self.maxButtonPadding then
                                self:Print(L.GetErrorMessage("invalidButtonPadding", self.minButtonPadding, self.maxButtonPadding))
                                return
                            elseif barID then
                                barID = tonumber(barID)

                                if not self:ValidateBar(barID) then
                                    self:Print(L.GetErrorMessage("invalidBarID"))
                                    return
                                end

                                self:SetDBValue("char.bars", "buttonPadding", padding, barID)
                                self.bars[barID]:UpdateButtons("Anchor")
                            else
                                self:SetMixedDBValues("char.bars", "buttonPadding", padding, function(bar)
                                    bar:UpdateButtons("Anchor")
                                end)
                            end

                            self:Refresh()
                        end,
                    },

                    remove = {
                        type = "execute",
                        name = "",
                        desc = L._Commands(L, "bar", "c_removeDesc"),
                        func = function(info)
                            if UnitAffectingCombat("player") then
                                addon:Print(L.CommandCombatError)
                                return
                            end

                            local _, _, barID, overwrite = strsplit(" ", info.input)

                            if not self:ValidateBar(barID) then
                                self:Print(L.GetErrorMessage("invalidBarID"))
                                return
                            end

                            addon:RemoveBar(barID, overwrite)

                            -- RemoveBar already calls Refresh()
                        end,
                    },

                    scale = {
                        type = "execute",
                        name = "",
                        desc = L._Commands(L, "bar", "c_scaleDesc"),
                        func = function(info)
                            if UnitAffectingCombat("player") then
                                addon:Print(L.CommandCombatError)
                                return
                            end

                            local _, _, scale, barID = strsplit(" ", info.input)
                            scale = tonumber(scale)

                            if not scale or scale < self.minScale or scale > self.maxScale then
                                self:Print(L.GetErrorMessage("invalidScale", self.minScale, self.maxScale))
                                return
                            elseif barID then
                                barID = tonumber(barID)

                                if not self:ValidateBar(barID) then
                                    self:Print(L.GetErrorMessage("invalidBarID"))
                                    return
                                end

                                self:SetDBValue("char.bars", "scale", scale, barID)
                                self.bars[barID]:SetScale(scale)
                            else
                                self:SetMixedDBValues("char.bars", "scale", scale, function(bar)
                                    bar:SetScale(scale)
                                end)
                            end

                            self:Refresh()
                        end,
                    },

                    size = {
                        type = "execute",
                        name = "",
                        desc = L._Commands(L, "bar", "c_sizeDesc"),
                        func = function(info)
                            if UnitAffectingCombat("player") then
                                addon:Print(L.CommandCombatError)
                                return
                            end

                            local _, _, size, barID = strsplit(" ", info.input)
                            size = tonumber(size)

                            if not size or size < self.minButtonSize or size > self.maxButtonSize then
                                self:Print(L.GetErrorMessage("invalidButtonSize", self.minButtonSize, self.maxButtonSize))
                                return
                            elseif barID then
                                barID = tonumber(barID)

                                if not self:ValidateBar(barID) then
                                    self:Print(L.GetErrorMessage("invalidBarID"))
                                    return
                                end

                                self:SetDBValue("char.bars", "buttonSize", size, barID)
                                self.bars[barID]:Size()
                                self.bars[barID]:UpdateButtons("Size")
                            else
                                self:SetMixedDBValues("char.bars", "buttonSize", size, function(bar)
                                    bar:Size()
                                    bar:UpdateButtons("Size")
                                end)
                            end

                            self:Refresh()
                        end,
                    },

                    track = {
                        type = "execute",
                        name = "",
                        desc = L._Commands(L, "bar", "c_trackDesc"),
                        func = function(info)
                            local _, _, barID, noToggle = strsplit(" ", info.input)

                            if barID == "true" or barID == "false" then -- Track or untrack all bars
                                self:SetMixedDBValues("char.bars", "trackProgress", barID == "true" and true or false)
                            elseif barID then
                                barID = tonumber(barID)
                                if not self:ValidateBar(barID) then -- Change only this bar
                                    self:Print(L.GetErrorMessage("invalidBarID"))
                                    return
                                end

                                self:SetDBValue("char.bars", "trackProgress", not noToggle and "_toggle" or (noToggle == "true" and true or false), barID)
                            else -- Toggle all bars
                                self:SetMixedDBValues("char.bars", "trackProgress", "_toggle")
                            end

                            self:Refresh()
                        end,
                    },

                    visibility = {
                        type = "execute",
                        name = "",
                        desc = L._Commands(L, "bar", "c_visibilityDesc"),
                        func = function(info)
                            if UnitAffectingCombat("player") then
                                addon:Print(L.CommandCombatError)
                                return
                            end

                            local _, _, barID, noToggle = strsplit(" ", info.input)

                            if barID == "show" then -- Show all bars
                                self:SetMixedDBValues("char.bars", "hidden", false, function(bar)
                                    bar:SetHidden()
                                end)
                            elseif barID == "hide" then -- Hide all bars
                                self:SetMixedDBValues("char.bars", "hidden", true, function(bar)
                                    bar:SetHidden()
                                end)
                            elseif barID then
                                barID = tonumber(barID)

                                if not self:ValidateBar(barID) then -- Change only this bar
                                    self:Print(L.GetErrorMessage("invalidBarID"))
                                    return
                                end

                                if noToggle == "show" then
                                    self:SetDBValue("char.bars", "hidden", false, barID)
                                elseif noToggle == "hide" then
                                    self:SetDBValue("char.bars", "hidden", true, barID)
                                else
                                    self:SetDBValue("char.bars", "hidden", "_toggle", barID)
                                end

                                self.bars[barID]:SetHidden()
                            else -- Toggle all bars
                                self:SetMixedDBValues("char.bars", "hidden", "_toggle", function(bar)
                                    bar:SetHidden()
                                end)
                            end

                            self:Refresh()
                        end,
                    },
                },
            },

            buttons = {
                type = "group",
                name = "",
                args = {
                    reindex = {
                        type = "execute",
                        name = "",
                        desc = L._Commands(L, "buttons", "c_reindexDesc"),
                        func = function(info)
                            local _, _, barID = strsplit(" ", info.input)

                            if barID then
                                barID = tonumber(barID)

                                if not self:ValidateBar(barID) then
                                    self:Print(L.GetErrorMessage("invalidBarID"))
                                    return
                                end

                                self.bars[barID]:ReindexButtons()
                            else
                                for barID, bar in pairs(self.bars) do
                                    bar:ReindexButtons()
                                end
                            end

                            self:Refresh()
                        end,
                    },

                    size = {
                        type = "execute",
                        name = "",
                        desc = L._Commands(L, "buttons", "c_sizeDesc"),
                        func = function(info)
                            if UnitAffectingCombat("player") then
                                addon:Print(L.CommandCombatError)
                                return
                            end

                            local _, _, barID = strsplit(" ", info.input)

                            if barID then
                                barID = tonumber(barID)

                                if not self:ValidateBar(barID) then
                                    self:Print(L.GetErrorMessage("invalidBarID"))
                                    return
                                end

                                self.bars[barID]:ReindexButtons(true)
                            else
                                for barID, bar in pairs(self.bars) do
                                    bar:ReindexButtons(true)
                                end
                            end

                            self:Refresh()
                        end,
                    },

                    clear = {
                        type = "execute",
                        name = "",
                        desc = L._Commands(L, "buttons", "c_clearDesc"),
                        func = function(info)
                            local _, _, barID = strsplit(" ", info.input)

                            if barID then
                                barID = tonumber(barID)

                                if not self:ValidateBar(barID) then
                                    self:Print(L.GetErrorMessage("invalidBarID"))
                                    return
                                end

                                self.bars[barID]:ClearItems()
                            else
                                for barID, bar in pairs(self.bars) do
                                    bar:ClearItems()
                                end
                            end

                            self:Refresh()
                        end,
                    },
                },
            },

            profile = {
                type = "group",
                name = "",
                args = {
                    reset = {
                        type = "execute",
                        name = "",
                        desc = L._Commands(L, "profile", "c_resetDesc"),
                        func = function(info)
                            if UnitAffectingCombat("player") then
                                addon:Print(L.CommandCombatError)
                                return
                            end

                            local _, _, overwrite = strsplit(" ", info.input)

                            addon:ResetProfile(overwrite)

                            self:Refresh()
                        end,
                    },
                },
            },

            template = {
                type = "group",
                name = "",
                args = {
                    delete = {
                        type = "execute",
                        name = "",
                        desc = L._Commands(L, "template", "c_deleteDesc"),
                        func = function(info)
                            local input = info.input:gsub("[tT][eE][mM][pP][lL][aA][tT][eE]%s[dD][eE][lL][eE][tT][eE]", ""):gsub("^ ", ""):gsub("[tT][pP][lL]%s[dD][eE][lL][eE][tT][eE]", ""):gsub("^ ", "")
                            input = strupper(input)

                            if input == "" then
                                self:Print(L.GetErrorMessage("invalidTemplate", input))
                                return
                            elseif not self.db.global.templates[input] then
                                self:Print(L.GetErrorMessage("invalidTemplateName", input))
                                return
                            end

                            self:DeleteTemplate(input)

                            self:Refresh()
                        end,
                    },

                    load = {
                        type = "execute",
                        name = "",
                        desc = L._Commands(L, "template", "c_loadDesc"),
                        func = function(info)
                            -- Split up the words and remove the commands
                            local words = {strsplit(" ", info.input)}
                            tremove(words, 2)
                            tremove(words, 1)

                            -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
                            -- Validate the barID

                            local barID = words[1]
                            barID = tonumber(barID)

                            if not self:ValidateBar(barID) then
                                self:Print(L.GetErrorMessage("invalidBarID"))
                                return
                            end

                            tremove(words, 1)

                            -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
                            -- Validate includeData

                            if not words[1] then
                                self:Print(L.GetErrorMessage("invalidIncludeData"))
                                return
                            end

                            local includeData = words[1] == "true" and true or false
                            tremove(words, 1)

                            -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
                            -- Validate saveOrder

                            if not words[1] then
                                self:Print(L.GetErrorMessage("invalidSaveOrder"))
                                return
                            end

                            local saveOrder = words[1] == "true" and true or false
                            tremove(words, 1)

                            -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
                            -- Validate templateName

                            if not words[1] then
                                self:Print(L.GetErrorMessage("invalidTemplate"))
                                return
                            end

                            local templateName = strupper(strjoin(" ", unpack(words)))

                            if not self.db.global.templates[templateName] then
                                self:Print(L.GetErrorMessage("invalidTemplateName", templateName))
                                return
                            end

                            self:LoadTemplate("user", barID, templateName, includeData, saveOrder)

                            self:Refresh()
                        end,
                    },

                    save = {
                        type = "execute",
                        name = "",
                        desc = L._Commands(L, "template", "c_saveDesc"),
                        func = function(info)
                            local barID, isSpace = info.input:match("^[tT][eE][mM][pP][lL][aA][tT][eE]%s[sS][aA][vV][eE]%s(%d+)(.?)")
                            local input = info.input:match("^[tT][eE][mM][pP][lL][aA][tT][eE]%s[sS][aA][vV][eE]%s%d+%s(.+)$")

                            if not barID and not input then
                                barID, isSpace = info.input:match("^[tT][pP][lL]%s[sS][aA][vV][eE]%s(%d+)(.?)")
                                input = info.input:match("^[tT][pP][lL]%s[sS][aA][vV][eE]%s%d+%s(.+)$")
                            end

                            -- Check if there character after barID is not a space
                            if isSpace and isSpace:find("%S") then
                                self:Print(L.GetErrorMessage("invalidBarID"))
                                return
                            end

                            barID = tonumber(barID)

                            if not self:ValidateBar(barID) then
                                self:Print(L.GetErrorMessage("invalidBarID"))
                                return
                            elseif not input then
                                self:Print(L.GetErrorMessage("missingTemplateName", input))
                                return
                            end

                            self:SaveTemplate(barID, input)

                            self:Refresh()
                        end,
                    },
                },
            },

            help = {
                type = "execute",
                name = "",
                func = function()
                    self:Open("help")
                end,
            },
        },
    }

    options.args.btns = options.args.buttons
    options.args.tpl = options.args.template

    return options
end

function addon:ValidateBar(barID)
    return barID and self.bars[tonumber(barID)] and self.db.char.bars[tonumber(barID)].enabled
end