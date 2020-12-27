local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

--*------------------------------------------------------------------------

addon.templates = {
    ["CLOTH"] = {2589,2592,4306,4338,14047,14256},
    ["ELEMENTAL"] = {7078,7076,12803,7080,12808,7082,7069,7067,7068,7070},
    ["ENCHANTING"] = {10940,11083,11137,11176,16204,10938,10939,10998,11082,11134,11135,11174,11175,16202,16203,10978,11084,11138,11139,11177,11178,14343,14344,20725},
    ["FISHING"] = {6291,6303,6289,6361,6317,21071,6308,8365,6362,21153,13759,4603,13754,13760,13758,13888,13889},
    ["LOCKBOXES"] = {16882,6712,4632,4633,4634,16883,4636,16884,4637,4638,16885,5758,5759,5760},
    ["HERBALISM"] = {2449,2447,765,785,2450,2452,2453,3820,3355,3369,3356,3357,3818,3821,3358,3819,8153,4625,8831,8836,8838,8839,8845,8846,13464,13463,13465,13466,13467,13468},
    ["MINING"] = {2835,2775,2770,2836,2771,2776,2838,2772,7912,3858,10620,7911,12365,11370},
    ["MINING:BARS"] = {2842,2840,2841,3576,3575,3577,3859,3860,11371,12359,6037,17771},
    ["SKINNING"] = {7286,7392,2934,783,2318,4232,2319,4235,4234,8167,8169,4304,8154,8165,15415,15423,15417,15422,15412,8171,8170,15419,15416,15408,17012,15414,15410},
    ["TAILORING:CLOTH"] = {2589,2996,2592,2997,4306,4305,4338,4339,14047,14048,14256,14342},
}

------------------------------------------------------------

--@retail@
addon.templates["BC:CLOTH"] = {21877,21840,21842,21844,24271,24272,21845}
addon.templates["WRATH:CLOTH"] = {33470,41510,41511,41595,41593,41594}
addon.templates["CATA:CLOTH"] = {53010,53643,54440}
addon.templates["MOP:CLOTH"] = {72988,82441,82447}
addon.templates["WOD:CLOTH"] = {111557,111556}
addon.templates["LEGION:CLOTH"] = {124437,127004,151567}
addon.templates["BFA:CLOTH"] = {152576,152577,167738,158378}
addon.templates["SL:CLOTH"] = {172439,173204,173202}

addon.templates["BC:ENCHANT"] = {22445,22447,22446,22449,22448,22450}
addon.templates["WRATH:ENCHANT"] = {34054,34056,34055,34052,34053,34057}
addon.templates["CATA:ENCHANT"] = {52722,52721,52720,52719,52718,52555}
addon.templates["MOP:ENCHANT"] = {74249,74250,74252,74247,74248}
addon.templates["WOD:ENCHANT"] = {109693,111247,115502,111245,113589,115504,113588}
addon.templates["LEGION:ENCHANT"] = {124440,124441,124442}
addon.templates["BFA:ENCHANT"] = {152875,152876,152877}
addon.templates["SL:ENCHANT"] = {172232,172231,172230}

addon.templates["BC:FISHING"] = {27422,27425,27429,27435,27437,2743,27439,27515,27516,33823,33824}
addon.templates["WRATH:FISHING"] = {41801,41802,41803,41805,41806,41807,41808,41809,41810,41812,41813}
addon.templates["CATA:FISHING"] = {53062,53063,53064,53065,53066,53067,53068,53069,53070,53071,53072}
addon.templates["MOP:FISHING"] = {74856,74857,74859,74860,74861,74863,74864,74865,74866,83064,86542,86544,86545}
addon.templates["WOD:FISHING"] = {111595,111663,111664,111665,111666,111667,111668,111669,118565,124669,127141,127991}
addon.templates["BFA:FISHING"] = {152543,152544,152547,152549,162515,167562,168302,168646,160711}
addon.templates["SL:FISHING"] = {173035,173033,173036,173034,173037,173032,173038,173043,173040,173041,173039,173042}

addon.templates["BC:HERBS"] = {22785,22786,22789,22787,22790,22791,22792,22793,22794}
addon.templates["WRATH:HERBS"] = {36901,37921,36904,36907,36903,36905,36906,36908}
addon.templates["CATA:HERBS"] = {52983,52984,52985,52986,52988,52987}
addon.templates["MOP:HERBS"] = {72234,72235,72237,79010,79011,72238,89639}
addon.templates["WOD:HERBS"] = {109125,109129,109128,109127,109126,109124,109130}
addon.templates["LEGION:HERBS"] = {124103,124106,151565,124102,124101,128304,124105,129289,124104}
addon.templates["BFA:HERBS"] = {152505,152511,152506,152507,152508,152509,152510,168487}
addon.templates["SL:HERBS"] = {168586,168589,170554,168583,169701,171315}

addon.templates["BC:LOCKBOX"] = {29569,31952}
addon.templates["WRATH:LOCKBOX"] = {43624,43575,45986,43622}
addon.templates["CATA:LOCKBOX"] = {68729,63349}
addon.templates["MOP:LOCKBOX"] = {88567,88165}
addon.templates["WOD:LOCKBOX"] = {116920,106895}
addon.templates["LEGION:LOCKBOX"] = {121331}
addon.templates["BFA:LOCKBOX"] = {169475}
addon.templates["SL:LOCKBOX"] = {179311,180532,180522,180533}

addon.templates["BFA:MECHAGON"] = {169610,166846,168266,168264,168258,168215,168216,168217,167562,166970,166971,168832,168327,168961}

addon.templates["BC:MINING"] = {23424,23425,23426,23427}
addon.templates["WRATH:MINING"] = {36909,36912,36910}
addon.templates["CATA:MINING"] = {53038,52185,52183}
addon.templates["MOP:MINING"] = {72092,72093,72094,72103}
addon.templates["WOD:MINING"] = {108042,109118,109119}
addon.templates["LEGION:MINING"] = {123918,123919,151564,124444}
addon.templates["BFA:MINING"] = {152512,152579,152513,168185}
addon.templates["SL:MINING"] = {171828,171833,171829,171830,171831,171832,171840,171841,177061}

addon.templates["BC:SKIN"] = {25649,21887,25708,25707}
addon.templates["WRATH:SKIN"] = {33567,33568,38557,38561,38558,44128}
addon.templates["CATA:SKIN"] = {52977,52976,52979,52982,52980,67495}
addon.templates["MOP:SKIN"] = {72162,72120,79101,72163,72201}
addon.templates["WOD:SKIN"] = {110610,110609,110611}
addon.templates["LEGION:SKIN"] = {124113,124115,151566,124116}
addon.templates["BFA:SKIN"] = {152541,153050,154164,154722,153051,154165,168650,168649}
addon.templates["SL:SKIN"] = {172093,172089,172094,172092,177279,172096,172097}
--@end-retail@

--*------------------------------------------------------------------------

function addon:DeleteTemplate(templateName)
    FarmingBar.db.global.templates[templateName] = nil
    addon:Print(string.format(L.TemplateDeleted, templateName))
end

------------------------------------------------------------

function addon:LoadTemplate(templateType, barID, templateName, withData, saveOrder)
    local template

    if templateType == "user" then
        template = FarmingBar.db.global.templates[strupper(templateName)]
    else
        local db = self.templates[strupper(templateName)]
        template = {}

        -- This removes invalid itemIDs (from different game versions) but preserves the actual template.
        for buttonID, itemID in pairs(db) do
            if GetItemInfoInstant(itemID) then
                self:CacheItem(itemID, function(template, itemID)
                    local name = GetItemInfo(itemID)
                    local objectiveTitle = "item:"..name
                    tinsert(template, {objectiveTitle = objectiveTitle, itemID = itemID})
                end, template, itemID)

            else
                -- self:Printf("Invalid itemID: %d", itemID)
            end
        end
    end

    -- Clear items off the bar
    addon:ClearBar(barID)

    -- Add template items to the bar
    local bar = self.bars[barID]
    local buttons = bar:GetUserData("buttons")
    if saveOrder then
        for i = 1, self.maxButtons do
            local templateInfo = template[tostring(i)]
            if templateInfo then
                local numVisibleButtons = bar:GetUserData("barDB").numVisibleButtons
                if numVisibleButtons < i then
                    self:SetBarDBInfo("numVisibleButtons", i, barID)
                    bar:UpdateVisibleButtons()
                end
                buttons[i]:SetObjectiveID(templateInfo.objectiveTitle, withData and templateInfo.objective)
            end
        end
    else
        local i = 1
        for _, templateInfo in pairs(template) do
            local numVisibleButtons = bar:GetUserData("barDB").numVisibleButtons
            if numVisibleButtons < i then
                self:SetBarDBInfo("numVisibleButtons", i, barID)
                bar:UpdateVisibleButtons()
            end
            if not addon:GetObjectiveInfo(templateInfo.objectiveTitle) then
                objectiveTitle = self:CreateObjectiveFromID(templateInfo.objectiveTitle, templateInfo.itemID, buttons[i])
                buttons[i]:SetObjectiveID(templateInfo.objectiveTitle, withData and templateInfo.objective)
            else
                buttons[i]:SetObjectiveID(templateInfo.objectiveTitle, withData and templateInfo.objective)
            end
            i = i + 1
        end
    end
end

------------------------------------------------------------

function addon:SaveTemplate(barID, templateName, overwrite)
    templateName = strupper(templateName)

    if FarmingBar.db.global.templates[templateName] and not overwrite then
        -- Confirm overwrite
        local dialog = StaticPopup_Show("FARMINGBAR_CONFIRM_OVERWRITE_TEMPLATE", templateName)
        if dialog then
            dialog.data = barID
            dialog.data2 = templateName
        end
    else
        FarmingBar.db.global.templates[templateName] = {}

        -- Add items from bar to the template
        local buttons = self.bars[barID]:GetUserData("buttons")

        for buttonID, button in pairs(buttons) do
            local objectiveTitle = button:GetObjectiveTitle()
            if objectiveTitle then
                FarmingBar.db.global.templates[templateName][tostring(buttonID)] = {objectiveTitle = objectiveTitle, objective = button:GetObjective()}
            end
        end

        -- addon:Print(L.TemplateSaved(barID, templateName))
    end
end