local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

local pairs, sort, tinsert = pairs, table.sort, table.insert
local format, strupper = string.format, string.upper
local GetItemInfoInstant, StaticPopup_Show = GetItemInfoInstant, StaticPopup_Show

--*------------------------------------------------------------------------

addon.templates = {
    ["CLOTH"] = {
        {itemID = 2589, objectiveTitle = "item:Linen Cloth"},
        {itemID = 4306, objectiveTitle = "item:Silk Cloth"},
        {itemID = 4338, objectiveTitle = "item:Mageweave Cloth"},
        {itemID = 2592, objectiveTitle = "item:Wool Cloth"},
        {itemID = 14256, objectiveTitle = "item:Felcloth"},
        {itemID = 14047, objectiveTitle = "item:Runecloth"},
    },
    --@retail@
    ["CLOTH (BC)"] = {
        {itemID = 21845, objectiveTitle = "item:Primal Mooncloth"},
        {itemID = 24271, objectiveTitle = "item:Spellcloth"},
        {itemID = 24272, objectiveTitle = "item:Shadowcloth"},
        {itemID = 21842, objectiveTitle = "item:Bolt of Imbued Netherweave"},
        {itemID = 21844, objectiveTitle = "item:Bolt of Soulcloth"},
        {itemID = 21840, objectiveTitle = "item:Bolt of Netherweave"},
        {itemID = 21877, objectiveTitle = "item:Netherweave Cloth"},
    },
    ["CLOTH (WRATH)"] = {
        {itemID = 21845, objectiveTitle = "item:Primal Mooncloth"},
        {itemID = 24271, objectiveTitle = "item:Spellcloth"},
        {itemID = 24272, objectiveTitle = "item:Shadowcloth"},
        {itemID = 21842, objectiveTitle = "item:Bolt of Imbued Netherweave"},
        {itemID = 21844, objectiveTitle = "item:Bolt of Soulcloth"},
        {itemID = 21840, objectiveTitle = "item:Bolt of Netherweave"},
        {itemID = 21877, objectiveTitle = "item:Netherweave Cloth"},
        {itemID = 41595, objectiveTitle = "item:Spellweave"},
        {itemID = 41510, objectiveTitle = "item:Bolt of Frostweave"},
        {itemID = 33470, objectiveTitle = "item:Frostweave Cloth"},
        {itemID = 41594, objectiveTitle = "item:Moonshroud"},
        {itemID = 41593, objectiveTitle = "item:Ebonweave"},
        {itemID = 41511, objectiveTitle = "item:Bolt of Imbued Frostweave"},
    },
    ["CLOTH (CATA)"] = {
        {itemID = 53010, objectiveTitle = "item:Embersilk Cloth"},
        {itemID = 54440, objectiveTitle = "item:Dreamcloth"},
        {itemID = 53643, objectiveTitle = "item:Bolt of Embersilk Cloth"},
    },
    ["CLOTH (MOP)"] = {
        {itemID = 82441, objectiveTitle = "item:Bolt of Windwool Cloth"},
        {itemID = 72988, objectiveTitle = "item:Windwool Cloth"},
        {itemID = 82447, objectiveTitle = "item:Imperial Silk"},
    },
    ["CLOTH (WOD)"] = {
        {itemID = 111557, objectiveTitle = "item:Sumptuous Fur"},
        {itemID = 111556, objectiveTitle = "item:Hexweave Cloth"},
    },
    ["CLOTH (LEGION)"] = {
        {itemID = 124437, objectiveTitle = "item:Shal'dorei Silk"},
        {itemID = 151567, objectiveTitle = "item:Lightweave Cloth"},
        {itemID = 127004, objectiveTitle = "item:Imbued Silkweave"},
    },
    ["CLOTH (BFA)"] = {
        {itemID = 152576, objectiveTitle= "item:Tidespray Linen"},
        {itemID = 158378, objectiveTitle= "item:Embroidered Deep Sea Satin"},
        {itemID = 152577, objectiveTitle= "item:Deep Sea Satin"},
        {itemID = 167738, objectiveTitle= "item:Gilded Seaweave"},
    },
    ["CLOTH (SL)"] = {
        {itemID = 172439, objectiveTitle = "item:Enchanted Lightless Silk"},
        {itemID = 173202, objectiveTitle = "item:Shrouded Cloth"},
        {itemID = 173204, objectiveTitle = "item:Lightless Silk"},
    },
    --@end-retail@
    ["ELEMENTAL"] = {
        {itemID = 7080, objectiveTitle = "item:Essence of Water"},
        {itemID = 12808, objectiveTitle = "item:Essence of Undeath"},
        {itemID = 7067, objectiveTitle = "item:Elemental Earth"},
        {itemID = 12803, objectiveTitle = "item:Living Essence"},
        {itemID = 7070, objectiveTitle = "item:Elemental Water"},
        {itemID = 7076, objectiveTitle = "item:Essence of Earth"},
        {itemID = 7078, objectiveTitle = "item:Essence of Fire"},
        {itemID = 7068, objectiveTitle = "item:Elemental Fire"},
        {itemID = 7082, objectiveTitle = "item:Essence of Air"},
        {itemID = 7069, objectiveTitle = "item:Elemental Air"},
    },
    ["ENCHANTING"] = {
        {itemID = 10938, objectiveTitle = "item:Lesser Magic Essence"},
        {itemID = 10939, objectiveTitle = "item:Greater Magic Essence"},
        {itemID = 14343, objectiveTitle = "item:Small Brilliant Shard"},
        {itemID = 16204, objectiveTitle = "item:Light Illusion Dust"},
        {itemID = 10940, objectiveTitle = "item:Strange Dust"},
        {itemID = 14344, objectiveTitle = "item:Large Brilliant Shard"},
        {itemID = 16203, objectiveTitle = "item:Greater Eternal Essence"},
        {itemID = 16202, objectiveTitle = "item:Lesser Eternal Essence"},
        --[===[@non-retail@{itemID = 11174, objectiveTitle = "item:"},--@end-non-retail@]===]
        --[===[@non-retail@{itemID = 11175, objectiveTitle = "item:"},--@end-non-retail@]===]
        --[===[@non-retail@{itemID = 11135, objectiveTitle = "item:"},--@end-non-retail@]===]
        --[===[@non-retail@{itemID = 11082, objectiveTitle = "item:"},--@end-non-retail@]===]
        --[===[@non-retail@{itemID = 11134, objectiveTitle = "item:"},--@end-non-retail@]===]
        --[===[@non-retail@{itemID = 10998, objectiveTitle = "item:"},--@end-non-retail@]===]
        --[===[@non-retail@{itemID = 11137, objectiveTitle = "item:"},--@end-non-retail@]===]
        --[===[@non-retail@{itemID = 11083, objectiveTitle = "item:"},--@end-non-retail@]===]
        --[===[@non-retail@{itemID = 11176, objectiveTitle = "item:"},--@end-non-retail@]===]
        --[===[@non-retail@{itemID = 11138, objectiveTitle = "item:"},--@end-non-retail@]===]
        --[===[@non-retail@{itemID = 11177, objectiveTitle = "item:"},--@end-non-retail@]===]
        --[===[@non-retail@{itemID = 11178, objectiveTitle = "item:"},--@end-non-retail@]===]
        --[===[@non-retail@{itemID = 11139, objectiveTitle = "item:"},--@end-non-retail@]===]
        --[===[@non-retail@{itemID = 20725, objectiveTitle = "item:"},--@end-non-retail@]===]
        --[===[@non-retail@{itemID = 10978, objectiveTitle = "item:"},--@end-non-retail@]===]
        --[===[@non-retail@{itemID = 11084, objectiveTitle = "item:"},--@end-non-retail@]===]
    },
    ["FISHING"] = {
        {itemID = 21071, objectiveTitle = "item:Raw Sagefish"},
        {itemID = 6289, objectiveTitle = "item:Raw Longjaw Mud Snapper"},
        {itemID = 6361, objectiveTitle = "item:Raw Rainbow Fin Albacore"},
        {itemID = 6291, objectiveTitle = "item:Raw Brilliant Smallfish"},
        {itemID = 6303, objectiveTitle = "item:Raw Slitherskin Mackerel"},
        {itemID = 13888, objectiveTitle = "item:Darkclaw Lobster"},
        {itemID = 13889, objectiveTitle = "item:Raw Whitescale Salmon"},
        {itemID = 6317, objectiveTitle = "item:Raw Loch Frenzy"},
        {itemID = 13759, objectiveTitle = "item:Raw Nightfin Snapper"},
        {itemID = 13754, objectiveTitle = "item:Raw Glossy Mightfish"},
        {itemID = 13760, objectiveTitle = "item:Raw Sunscale Salmon"},
        {itemID = 4603, objectiveTitle = "item:Raw Spotted Yellowtail"},
        {itemID = 13758, objectiveTitle = "item:Raw Redgill"},
        {itemID = 6308, objectiveTitle = "item:Raw Bristle Whisker Catfish"},
        {itemID = 21153, objectiveTitle = "item:Raw Greater Sagefish"},
        {itemID = 6362, objectiveTitle = "item:Raw Rockscale Cod"},
        {itemID = 8365, objectiveTitle = "item:Raw Mithril Head Trout"},
    },
    ["LOCKBOXES"] = {
        {itemID = 16883, objectiveTitle = "item:Worn Junkbox"},
        {itemID = 4636, objectiveTitle = "item:Strong Iron Lockbox"},
        {itemID = 4634, objectiveTitle = "item:Iron Lockbox"},
        {itemID = 6712, objectiveTitle = "item:Clockwork Box"},
        {itemID = 4632, objectiveTitle = "item:Ornate Bronze Lockbox"},
        {itemID = 5758, objectiveTitle = "item:Mithril Lockbox"},
        {itemID = 16882, objectiveTitle = "item:Battered Junkbox"},
        {itemID = 16885, objectiveTitle = "item:Heavy Junkbox"},
        {itemID = 4633, objectiveTitle = "item:Heavy Bronze Lockbox"},
        {itemID = 5760, objectiveTitle = "item:Eternium Lockbox"},
        {itemID = 5759, objectiveTitle = "item:Thorium Lockbox"},
        {itemID = 16884, objectiveTitle = "item:Sturdy Junkbox"},
        {itemID = 4638, objectiveTitle = "item:Reinforced Steel Lockbox"},
        {itemID = 4637, objectiveTitle = "item:Steel Lockbox"},
    },
    ["HERBALISM"] = {
        {itemID = 2453, objectiveTitle = "item:Bruiseweed"},
        {itemID = 2452, objectiveTitle = "item:Swiftthistle"},
        {itemID = 2450, objectiveTitle = "item:Briarthorn"},
        {itemID = 2447, objectiveTitle = "item:Peacebloom"},
        {itemID = 13467, objectiveTitle = "item:Icecap"},
        {itemID = 13466, objectiveTitle = "item:Sorrowmoss"},
        {itemID = 2449, objectiveTitle = "item:Earthroot"},
        {itemID = 13465, objectiveTitle = "item:Mountain Silversage"},
        {itemID = 13463, objectiveTitle = "item:Dreamfoil"},
        {itemID = 765, objectiveTitle = "item:Silverleaf"},
        {itemID = 13464, objectiveTitle = "item:Golden Sansam"},
        {itemID = 8846, objectiveTitle = "item:Gromsblood"},
        {itemID = 8838, objectiveTitle = "item:Sungrass"},
        {itemID = 8831, objectiveTitle = "item:Purple Lotus"},
        {itemID = 8839, objectiveTitle = "item:Blindweed"},
        {itemID = 8845, objectiveTitle = "item:Ghost Mushroom"},
        {itemID = 785, objectiveTitle = "item:Mageroyal"},
        {itemID = 8836, objectiveTitle = "item:Arthas' Tears"},
        {itemID = 3819, objectiveTitle = "item:Dragon's Teeth"},
        {itemID = 4625, objectiveTitle = "item:Firebloom"},
        {itemID = 8153, objectiveTitle = "item:Wildvine"},
        {itemID = 3357, objectiveTitle = "item:Liferoot"},
        {itemID = 3821, objectiveTitle = "item:Goldthorn"},
        {itemID = 3358, objectiveTitle = "item:Khadgar's Whisker"},
        {itemID = 13468, objectiveTitle = "item:Black Lotus"},
        {itemID = 3818, objectiveTitle = "item:Fadeleaf"},
        {itemID = 3355, objectiveTitle = "item:Wild Steelbloom"},
        {itemID = 3369, objectiveTitle = "item:Grave Moss"},
        {itemID = 3356, objectiveTitle = "item:Kingsblood"},
        {itemID = 3820, objectiveTitle = "item:Stranglekelp"},
    },
    ["MINING"] = {
        {itemID = 2835, objectiveTitle = "item:Rough Stone"},
        {itemID = 2775, objectiveTitle = "item:Silver Ore"},
        {itemID = 12365, objectiveTitle = "item:Dense Stone"},
        {itemID = 11370, objectiveTitle = "item:Dark Iron Ore"},
        {itemID = 10620, objectiveTitle = "item:Thorium Ore"},
        {itemID = 7911, objectiveTitle = "item:Truesilver Ore"},
        {itemID = 2838, objectiveTitle = "item:Heavy Stone"},
        {itemID = 7912, objectiveTitle = "item:Solid Stone"},
        {itemID = 3858, objectiveTitle = "item:Mithril Ore"},
        {itemID = 2772, objectiveTitle = "item:Iron Ore"},
        {itemID = 2771, objectiveTitle = "item:Tin Ore"},
        {itemID = 2776, objectiveTitle = "item:Gold Ore"},
        {itemID = 2770, objectiveTitle = "item:Copper Ore"},
        {itemID = 2836, objectiveTitle = "item:Coarse Stone"},
    },
    ["MINING: BARS"] = {
        {itemID = 3576, objectiveTitle = "item:Tin Bar"},
        {itemID = 3575, objectiveTitle = "item:Iron Bar"},
        {itemID = 17771, objectiveTitle = "item:Enchanted Elementium Bar"},
        {itemID = 2840, objectiveTitle = "item:Copper Bar"},
        {itemID = 2841, objectiveTitle = "item:Bronze Bar"},
        {itemID = 2842, objectiveTitle = "item:Silver Bar"},
        {itemID = 12359, objectiveTitle = "item:Thorium Bar"},
        {itemID = 6037, objectiveTitle = "item:Truesilver Bar"},
        {itemID = 11371, objectiveTitle = "item:Dark Iron Bar"},
        {itemID = 3860, objectiveTitle = "item:Mithril Bar"},
        {itemID = 3577, objectiveTitle = "item:Gold Bar"},
        {itemID = 3859, objectiveTitle = "item:Steel Bar"},
    },
    ["SKINNING"] = {
        {itemID = 2318, objectiveTitle = "item:Light Leather"},
        {itemID = 4232, objectiveTitle = "item:Medium Hide"},
        {itemID = 7392, objectiveTitle = "item:Green Whelp Scale"},
        {itemID = 2934, objectiveTitle = "item:Ruined Leather Scraps"},
        {itemID = 783, objectiveTitle = "item:Light Hide"},
        {itemID = 15416, objectiveTitle = "item:Black Dragonscale"},
        {itemID = 15408, objectiveTitle = "item:Heavy Scorpid Scale"},
        {itemID = 8171, objectiveTitle = "item:Rugged Hide"},
        {itemID = 8170, objectiveTitle = "item:Rugged Leather"},
        {itemID = 15419, objectiveTitle = "item:Warbear Leather"},
        {itemID = 17012, objectiveTitle = "item:Core Leather"},
        {itemID = 15414, objectiveTitle = "item:Red Dragonscale"},
        {itemID = 15412, objectiveTitle = "item:Green Dragonscale"},
        {itemID = 15417, objectiveTitle = "item:Devilsaur Leather"},
        {itemID = 15422, objectiveTitle = "item:Frostsaber Leather"},
        {itemID = 15423, objectiveTitle = "item:Chimera Leather"},
        {itemID = 15415, objectiveTitle = "item:Blue Dragonscale"},
        {itemID = 7286, objectiveTitle = "item:Black Whelp Scale"},
        {itemID = 8169, objectiveTitle = "item:Thick Hide"},
        {itemID = 8167, objectiveTitle = "item:Turtle Scale"},
        {itemID = 8165, objectiveTitle = "item:Worn Dragonscale"},
        {itemID = 15410, objectiveTitle = "item:Scale of Onyxia"},
        {itemID = 8154, objectiveTitle = "item:Scorpid Scale"},
        {itemID = 4304, objectiveTitle = "item:Thick Leather"},
        {itemID = 2319, objectiveTitle = "item:Medium Leather"},
        {itemID = 4234, objectiveTitle = "item:Heavy Leather"},
        {itemID = 4235, objectiveTitle = "item:Heavy Hide"},
    },
    ["TAILORING: CLOTH"] = {
        {itemID = 2592, objectiveTitle = "item:Wool Cloth"},
        {itemID = 2997, objectiveTitle = "item:Bolt of Woolen Cloth"},
        {itemID = 2996, objectiveTitle = "item:Bolt of Linen Cloth"},
        {itemID = 14256, objectiveTitle = "item:Felcloth"},
        {itemID = 2589, objectiveTitle = "item:Linen Cloth"},
        {itemID = 14342, objectiveTitle = "item:Mooncloth"},
        {itemID = 14047, objectiveTitle = "item:Runecloth"},
        {itemID = 14048, objectiveTitle = "item:Bolt of Runecloth"},
        {itemID = 4338, objectiveTitle = "item:Mageweave Cloth"},
        {itemID = 4339, objectiveTitle = "item:Bolt of Mageweave"},
        {itemID = 4306, objectiveTitle = "item:Silk Cloth"},
        {itemID = 4305, objectiveTitle = "item:Bolt of Silk Cloth"},
    },
}

------------------------------------------------------------

--@retail@

-- addon.templates["BC:ENCHANT"] = {22445,22447,22446,22449,22448,22450}
-- addon.templates["WRATH:ENCHANT"] = {34054,34056,34055,34052,34053,34057}
-- addon.templates["CATA:ENCHANT"] = {52722,52721,52720,52719,52718,52555}
-- addon.templates["MOP:ENCHANT"] = {74249,74250,74252,74247,74248}
-- addon.templates["WOD:ENCHANT"] = {109693,111247,115502,111245,113589,115504,113588}
-- addon.templates["LEGION:ENCHANT"] = {124440,124441,124442}
-- addon.templates["BFA:ENCHANT"] = {152875,152876,152877}
-- addon.templates["SL:ENCHANT"] = {172232,172231,172230}

-- addon.templates["BC:FISHING"] = {27422,27425,27429,27435,27437,2743,27439,27515,27516,33823,33824}
-- addon.templates["WRATH:FISHING"] = {41801,41802,41803,41805,41806,41807,41808,41809,41810,41812,41813}
-- addon.templates["CATA:FISHING"] = {53062,53063,53064,53065,53066,53067,53068,53069,53070,53071,53072}
-- addon.templates["MOP:FISHING"] = {74856,74857,74859,74860,74861,74863,74864,74865,74866,83064,86542,86544,86545}
-- addon.templates["WOD:FISHING"] = {111595,111663,111664,111665,111666,111667,111668,111669,118565,124669,127141,127991}
-- addon.templates["BFA:FISHING"] = {152543,152544,152547,152549,162515,167562,168302,168646,160711}
-- addon.templates["SL:FISHING"] = {173035,173033,173036,173034,173037,173032,173038,173043,173040,173041,173039,173042}

-- addon.templates["BC:HERBS"] = {22785,22786,22789,22787,22790,22791,22792,22793,22794}
-- addon.templates["WRATH:HERBS"] = {36901,37921,36904,36907,36903,36905,36906,36908}
-- addon.templates["CATA:HERBS"] = {52983,52984,52985,52986,52988,52987}
-- addon.templates["MOP:HERBS"] = {72234,72235,72237,79010,79011,72238,89639}
-- addon.templates["WOD:HERBS"] = {109125,109129,109128,109127,109126,109124,109130}
-- addon.templates["LEGION:HERBS"] = {124103,124106,151565,124102,124101,128304,124105,129289,124104}
-- addon.templates["BFA:HERBS"] = {152505,152511,152506,152507,152508,152509,152510,168487}
-- addon.templates["SL:HERBS"] = {168586,168589,170554,168583,169701,171315}

-- addon.templates["BC:LOCKBOX"] = {29569,31952}
-- addon.templates["WRATH:LOCKBOX"] = {43624,43575,45986,43622}
-- addon.templates["CATA:LOCKBOX"] = {68729,63349}
-- addon.templates["MOP:LOCKBOX"] = {88567,88165}
-- addon.templates["WOD:LOCKBOX"] = {116920,106895}
-- addon.templates["LEGION:LOCKBOX"] = {121331}
-- addon.templates["BFA:LOCKBOX"] = {169475}
-- addon.templates["SL:LOCKBOX"] = {179311,180532,180522,180533}

-- addon.templates["BFA:MECHAGON"] = {169610,166846,168266,168264,168258,168215,168216,168217,167562,166970,166971,168832,168327,168961}

-- addon.templates["BC:MINING"] = {23424,23425,23426,23427}
-- addon.templates["WRATH:MINING"] = {36909,36912,36910}
-- addon.templates["CATA:MINING"] = {53038,52185,52183}
-- addon.templates["MOP:MINING"] = {72092,72093,72094,72103}
-- addon.templates["WOD:MINING"] = {108042,109118,109119}
-- addon.templates["LEGION:MINING"] = {123918,123919,151564,124444}
-- addon.templates["BFA:MINING"] = {152512,152579,152513,168185}
-- addon.templates["SL:MINING"] = {171828,171833,171829,171830,171831,171832,171840,171841,177061}

-- addon.templates["BC:SKIN"] = {25649,21887,25708,25707}
-- addon.templates["WRATH:SKIN"] = {33567,33568,38557,38561,38558,44128}
-- addon.templates["CATA:SKIN"] = {52977,52976,52979,52982,52980,67495}
-- addon.templates["MOP:SKIN"] = {72162,72120,79101,72163,72201}
-- addon.templates["WOD:SKIN"] = {110610,110609,110611}
-- addon.templates["LEGION:SKIN"] = {124113,124115,151566,124116}
-- addon.templates["BFA:SKIN"] = {152541,153050,154164,154722,153051,154165,168650,168649}
-- addon.templates["SL:SKIN"] = {172093,172089,172094,172092,177279,172096,172097}
--@end-retail@

--*------------------------------------------------------------------------

function addon:DeleteTemplate(templateName)
    FarmingBar.db.global.templates[templateName] = nil
    FarmingBar:Print(format(L.TemplateDeleted, templateName))
end

------------------------------------------------------------

function addon:LoadTemplate(templateType, barID, templateName, withData, saveOrder)
    -- Get template table
    local template = {}
    if templateType == "user" then
        template = FarmingBar.db.global.templates[strupper(templateName)]
    else
        -- This removes invalid itemIDs (from different game versions) but preserves the actual template.
        for buttonID, objective in pairs(self.templates[strupper(templateName)]) do
            if GetItemInfoInstant(objective.itemID) then
                tinsert(template, objective)
            else
                FarmingBar:Print(format(L.InvalidItemID, objective.itemID))
            end
        end
    end

    ------------------------------------------------------------

    -- Clear items off the bar
    self:ClearBar(barID)

    ------------------------------------------------------------

    -- Make sure we have enough visible buttons for the template
    local bar = self.bars[barID]
    local buttons = bar:GetUserData("buttons")
    local numVisibleButtons = bar:GetUserData("barDB").numVisibleButtons
    local numTemplateButtons = addon.tcount(template)

    if saveOrder then
        -- Get the key for the last template item
        local i = 0
        for buttonID, _ in pairs(template) do
            i = i + 1
            if i == numTemplateButtons then
                numTemplateButtons = tonumber(buttonID)
            end
        end
    end

    if numVisibleButtons < numTemplateButtons then
        self:SetBarDBInfo("numVisibleButtons", numTemplateButtons, barID)
        bar:UpdateVisibleButtons()
    end

    ------------------------------------------------------------

    -- Add template items to the bar
    local i = 0
    for buttonID, objective in pairs(template) do
        i = saveOrder and tonumber(buttonID) or (i + 1)
        local objectiveTitle = objective.objectiveTitle
        if not self:GetObjectiveInfo(objectiveTitle) then
            objectiveTitle = self:CreateObjectiveFromID(objectiveTitle, objective.itemID)
        end
        buttons[i]:SetObjectiveID(objective.objectiveTitle, withData and objective.objective)
    end

    ------------------------------------------------------------

    -- Reindex bars
    if not saveOrder then
        self:ReindexButtons(barID)
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

        FarmingBar:Print(format(L.TemplateSaved, barID, templateName))
    end
end