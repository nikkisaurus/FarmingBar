local addonName = ...
local addon = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)


--*------------------------------------------------------------------------
-- Built-in templates

addon.templates = {
    ["CLOTH"] = {
        {itemID = 2589, objectiveTitle = "item:Linen Cloth"},
        {itemID = 4306, objectiveTitle = "item:Silk Cloth"},
        {itemID = 4338, objectiveTitle = "item:Mageweave Cloth"},
        {itemID = 2592, objectiveTitle = "item:Wool Cloth"},
        {itemID = 14256, objectiveTitle = "item:Felcloth"},
        {itemID = 14047, objectiveTitle = "item:Runecloth"},
        {itemID = 2997, objectiveTitle = "item:Bolt of Woolen Cloth"},
        {itemID = 2996, objectiveTitle = "item:Bolt of Linen Cloth"},
        {itemID = 14342, objectiveTitle = "item:Mooncloth"},
        {itemID = 14048, objectiveTitle = "item:Bolt of Runecloth"},
        {itemID = 4339, objectiveTitle = "item:Bolt of Mageweave"},
        {itemID = 4305, objectiveTitle = "item:Bolt of Silk Cloth"},
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
        --[===[@non-retail@
        {itemID = 11174, objectiveTitle = "item:Lesser Nether Essence"},
        {itemID = 11175, objectiveTitle = "item:Greater Nether Essence"},
        {itemID = 11135, objectiveTitle = "item:Greater Mystic Essence"},
        {itemID = 11082, objectiveTitle = "item:Greater Astral Essence"},
        {itemID = 11134, objectiveTitle = "item:Lesser Mystic Essence"},
        {itemID = 10998, objectiveTitle = "item:Lesser Astral Essence"},
        {itemID = 11137, objectiveTitle = "item:Vision Dust"},
        {itemID = 11083, objectiveTitle = "item:Soul Dust"},
        {itemID = 11176, objectiveTitle = "item:Dream Dust"},
        {itemID = 11138, objectiveTitle = "item:Small Glowing Shard"},
        {itemID = 11177, objectiveTitle = "item:Small Radiant Shard"},
        {itemID = 11178, objectiveTitle = "item:Large Radiant Shard"},
        {itemID = 11139, objectiveTitle = "item:Large Glowing Shard"},
        {itemID = 20725, objectiveTitle = "item:Nexus Crystal"},
        {itemID = 10978, objectiveTitle = "item:Small Glimmering Shard"},
        {itemID = 11084, objectiveTitle = "item:Large Glimmering Shard"},
        --@end-non-retail@]===]
    },
    --@retail@
    ["ENCHANTING (BC)"] = {
        {itemID = 22448, objectiveTitle = "item:Small Prismatic Shard"},
        {itemID = 22449, objectiveTitle = "item:Large Prismatic Shard"},
        {itemID = 22447, objectiveTitle = "item:Lesser Planar Essence"},
        {itemID = 22445, objectiveTitle = "item:Arcane Dust"},
        {itemID = 22450, objectiveTitle = "item:Void Crystal"},
        {itemID = 22446, objectiveTitle = "item:Greater Planar Essence"},
    },
    ["ENCHANTING (WRATH)"] = {
        {itemID = 34055, objectiveTitle = "item:Greater Cosmic Essence"},
        {itemID = 34057, objectiveTitle = "item:Abyss Crystal"},
        {itemID = 34054, objectiveTitle = "item:Infinite Dust"},
        {itemID = 34052, objectiveTitle = "item:Dream Shard"},
        {itemID = 34056, objectiveTitle = "item:Lesser Cosmic Essence"},
        {itemID = 34053, objectiveTitle = "item:Small Dream Shard"},
    },
    ["ENCHANTING (CATA)"] = {
        {itemID = 52719, objectiveTitle = "item:Greater Celestial Essence"},
        {itemID = 52720, objectiveTitle = "item:Small Heavenly Shard"},
        {itemID = 52555, objectiveTitle = "item:Hypnotic Dust"},
        {itemID = 52718, objectiveTitle = "item:Lesser Celestial Essence"},
        {itemID = 52722, objectiveTitle = "item:Maelstrom Crystal"},
        {itemID = 52721, objectiveTitle = "item:Heavenly Shard"},
    },
    ["ENCHANTING (MOP)"] = {
        {itemID = 74247, objectiveTitle = "item:Ethereal Shard"},
        {itemID = 74249, objectiveTitle = "item:Spirit Dust"},
        {itemID = 74252, objectiveTitle = "item:Small Ethereal Shard"},
        {itemID = 74250, objectiveTitle = "item:Mysterious Essence"},
        {itemID = 74248, objectiveTitle = "item:Sha Crystal"},
    },
    ["ENCHANTING (WOD)"] = {
        {itemID = 115502, objectiveTitle = "item:Small Luminous Shard"},
        {itemID = 113588, objectiveTitle = "item:Temporal Crystal"},
        {itemID = 109693, objectiveTitle = "item:Draenic Dust"},
        {itemID = 115504, objectiveTitle = "item:Fractured Temporal Crystal"},
        {itemID = 111245, objectiveTitle = "item:Luminous Shard"},
    },
    ["ENCHANTING (LEGION)"] = {
        {itemID = 124440, objectiveTitle = "item:Arkhana"},
        {itemID = 124442, objectiveTitle = "item:Chaos Crystal"},
        {itemID = 124441, objectiveTitle = "item:Leylight Shard"},
    },
    ["ENCHANTING (BFA)"] = {
        {itemID = 152876, objectiveTitle = "item:Umbra Shard"},
        {itemID = 152875, objectiveTitle = "item:Gloom Dust"},
        {itemID = 152877, objectiveTitle = "item:Veiled Crystal"},
    },
    ["ENCHANTING (SL)"] = {
        {itemID = 172232, objectiveTitle = "item:Eternal Crystal"},
        {itemID = 172230, objectiveTitle = "item:Soul Dust"},
        {itemID = 172231, objectiveTitle = "item:Sacred Shard"},
    },
    --@end-retail@

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
    --@retail@
    ["FISHING (BC)"] = {
        {itemID = 27435, objectiveTitle = "item:Figluster's Mudfish"},
        {itemID = 27422, objectiveTitle = "item:Barbed Gill Trout"},
        {itemID = 33823, objectiveTitle = "item:Bloodfin Catfish"},
        {itemID = 27437, objectiveTitle = "item:Icefin Bluefish"},
        {itemID = 33824, objectiveTitle = "item:Crescent-Tail Skullfish"},
        {itemID = 27515, objectiveTitle = "item:Huge Spotted Feltail"},
        {itemID = 27439, objectiveTitle = "item:Furious Crawdad"},
        {itemID = 27429, objectiveTitle = "item:Zangarian Sporefish"},
        {itemID = 27516, objectiveTitle = "item:Enormous Barbed Gill Trout"},
        {itemID = 27425, objectiveTitle = "item:Spotted Feltail"},
    },
    ["FISHING (WRATH)"] = {
        {itemID = 41805, objectiveTitle = "item:Borean Man O' War"},
        {itemID = 41801, objectiveTitle = "item:Moonglow Cuttlefish"},
        {itemID = 41812, objectiveTitle = "item:Barrelhead Goby"},
        {itemID = 41806, objectiveTitle = "item:Musselback Sculpin"},
        {itemID = 41813, objectiveTitle = "item:Nettlefish"},
        {itemID = 41809, objectiveTitle = "item:Glacial Salmon"},
        {itemID = 41808, objectiveTitle = "item:Bonescale Snapper"},
        {itemID = 41807, objectiveTitle = "item:Dragonfin Angelfish"},
        {itemID = 41803, objectiveTitle = "item:Rockfin Grouper"},
        {itemID = 41810, objectiveTitle = "item:Fangtooth Herring"},
        {itemID = 41802, objectiveTitle = "item:Imperial Manta Ray"},
    },
    ["FISHING (CATA)"] = {
        {itemID = 53065, objectiveTitle = "item:Albino Cavefish"},
        {itemID = 53062, objectiveTitle = "item:Sharptooth"},
        {itemID = 53071, objectiveTitle = "item:Algaefin Rockfish"},
        {itemID = 53066, objectiveTitle = "item:Blackbelly Mudfish"},
        {itemID = 53072, objectiveTitle = "item:Deepsea Sagefish"},
        {itemID = 53069, objectiveTitle = "item:Murglesnout"},
        {itemID = 53068, objectiveTitle = "item:Lavascale Catfish"},
        {itemID = 53067, objectiveTitle = "item:Striped Lurker"},
        {itemID = 53064, objectiveTitle = "item:Highland Guppy"},
        {itemID = 53070, objectiveTitle = "item:Fathom Eel"},
        {itemID = 53063, objectiveTitle = "item:Mountain Trout"},
    },
    ["FISHING (MOP)"] = {
        {itemID = 74856, objectiveTitle = "item:Jade Lungfish"},
        {itemID = 86544, objectiveTitle = "item:Spinefish Alpha"},
        {itemID = 74861, objectiveTitle = "item:Tiger Gourami"},
        {itemID = 74860, objectiveTitle = "item:Redbelly Mandarin"},
        {itemID = 86542, objectiveTitle = "item:Flying Tiger Gourami"},
        {itemID = 83064, objectiveTitle = "item:Spinefish"},
        {itemID = 86545, objectiveTitle = "item:Mimic Octopus"},
        {itemID = 74865, objectiveTitle = "item:Krasarang Paddlefish"},
        {itemID = 74864, objectiveTitle = "item:Reef Octopus"},
        {itemID = 74863, objectiveTitle = "item:Jewel Danio"},
        {itemID = 74859, objectiveTitle = "item:Emperor Salmon"},
        {itemID = 74866, objectiveTitle = "item:Golden Carp"},
        {itemID = 74857, objectiveTitle = "item:Giant Mantis Shrimp"},
    },
    ["FISHING (WOD)"] = {
        {itemID = 111595, objectiveTitle = "item:Crescent Saberfish"},
        {itemID = 111666, objectiveTitle = "item:Fire Ammonite"},
        {itemID = 111665, objectiveTitle = "item:Sea Scorpion"},
        {itemID = 127141, objectiveTitle = "item:Bloated Thresher"},
        {itemID = 124669, objectiveTitle = "item:Darkmoon Daggermaw"},
        {itemID = 127991, objectiveTitle = "item:Felmouth Frenzy"},
        {itemID = 111669, objectiveTitle = "item:Jawless Skulker"},
        {itemID = 111668, objectiveTitle = "item:Fat Sleeper"},
        {itemID = 111667, objectiveTitle = "item:Blind Lake Sturgeon"},
        {itemID = 111664, objectiveTitle = "item:Abyssal Gulper Eel"},
        {itemID = 118565, objectiveTitle = "item:Savage Piranha"},
        {itemID = 111663, objectiveTitle = "item:Blackwater Whiptail"},
    },
    ["FISHING (LEGION)"] = {
        {itemID = 139660, objectiveTitle = "item:Ancient Highmountain Salmon"},
        {itemID = 133714, objectiveTitle = "item:Silverscale Minnow"},
        {itemID = 133716, objectiveTitle = "item:Soggy Drakescale"},
        {itemID = 133712, objectiveTitle = "item:Frost Worm"},
        {itemID = 133713, objectiveTitle = "item:Moosehorn Hook"},
        {itemID = 133717, objectiveTitle = "item:Enchanted Lure"},
        {itemID = 133707, objectiveTitle = "item:Nightmare Nightcrawler"},
        {itemID = 133721, objectiveTitle = "item:Message in a Beer Bottle"},
        {itemID = 133723, objectiveTitle = "item:Stunned, Angry Shark"},
        {itemID = 133709, objectiveTitle = "item:Funky Sea Snail"},
        {itemID = 133708, objectiveTitle = "item:Drowned Thistleleaf"},
        {itemID = 133703, objectiveTitle = "item:Pearlescent Conch"},
        {itemID = 133705, objectiveTitle = "item:Rotten Fishbone"},
        {itemID = 133724, objectiveTitle = "item:Decayed Whale Blubber"},
        {itemID = 133719, objectiveTitle = "item:Sleeping Murloc"},
        {itemID = 133704, objectiveTitle = "item:Rusty Queenfish Brooch"},
        {itemID = 133715, objectiveTitle = "item:Ancient Vrykul Ring"},
        {itemID = 146962, objectiveTitle = "item:Golden Minnow"},
        {itemID = 133701, objectiveTitle = "item:Skrog Toenail"},
        {itemID = 124108, objectiveTitle = "item:Mossgill Perch"},
        {itemID = 139655, objectiveTitle = "item:Terrorfin"},
        {itemID = 139666, objectiveTitle = "item:Tainted Runescale Koi"},
        {itemID = 139663, objectiveTitle = "item:Thundering Stormray"},
        {itemID = 139656, objectiveTitle = "item:Thorned Flounder"},
        {itemID = 139659, objectiveTitle = "item:Coldriver Carp"},
        {itemID = 139667, objectiveTitle = "item:Axefish"},
        {itemID = 139664, objectiveTitle = "item:Magic-Eater Frog"},
        {itemID = 139654, objectiveTitle = "item:Ghostly Queenfish"},
        {itemID = 139657, objectiveTitle = "item:Ancient Mossgill"},
        {itemID = 139662, objectiveTitle = "item:Graybelly Lobster"},
        {itemID = 139652, objectiveTitle = "item:Leyshimmer Blenny"},
        {itemID = 133720, objectiveTitle = "item:Demonic Detritus"},
        {itemID = 139669, objectiveTitle = "item:Ancient Black Barracuda"},
        {itemID = 133731, objectiveTitle = "item:Mountain Puffer"},
        {itemID = 124110, objectiveTitle = "item:Stormray"},
        {itemID = 124107, objectiveTitle = "item:Cursed Queenfish"},
        {itemID = 133607, objectiveTitle = "item:Silver Mackerel"},
        {itemID = 124112, objectiveTitle = "item:Black Barracuda"},
        {itemID = 124109, objectiveTitle = "item:Highmountain Salmon"},
        {itemID = 139653, objectiveTitle = "item:Nar'thalas Hermit"},
        {itemID = 138967, objectiveTitle = "item:Big Fountain Goldfish"},
        {itemID = 133734, objectiveTitle = "item:Oodelfjisk"},
        {itemID = 138114, objectiveTitle = "item:Gloaming Frenzy"},
        {itemID = 124111, objectiveTitle = "item:Runescale Koi"},
    },
    ["FISHING (BFA)"] = {
        {itemID = 152547, objectiveTitle = "item:Great Sea Catfish"},
        {itemID = 152543, objectiveTitle = "item:Sand Shifter"},
        {itemID = 162515, objectiveTitle = "item:Midnight Salmon"},
        {itemID = 152549, objectiveTitle = "item:Redtail Loach"},
        {itemID = 160711, objectiveTitle = "item:Aromatic Fish Oil"},
        {itemID = 168302, objectiveTitle = "item:Viper Fish"},
        {itemID = 167562, objectiveTitle = "item:Ionized Minnow"},
        {itemID = 168646, objectiveTitle = "item:Mauve Stinger"},
        {itemID = 152544, objectiveTitle = "item:Slimy Mackerel"},
    },
    ["FISHING (SL)"] = {
        {itemID = 173035, objectiveTitle = "item:Pocked Bonefish"},
        {itemID = 173037, objectiveTitle = "item:Elysian Thade"},
        {itemID = 173034, objectiveTitle = "item:Silvergill Pike"},
        {itemID = 173039, objectiveTitle = "item:Iridescent Amberjack Bait"},
        {itemID = 173041, objectiveTitle = "item:Pocked Bonefish Bait"},
        {itemID = 173042, objectiveTitle = "item:Spinefin Piranha Bait"},
        {itemID = 173043, objectiveTitle = "item:Elysian Thade Bait"},
        {itemID = 173038, objectiveTitle = "item:Lost Sole Bait"},
        {itemID = 173032, objectiveTitle = "item:Lost Sole"},
        {itemID = 173036, objectiveTitle = "item:Spinefin Piranha"},
        {itemID = 173040, objectiveTitle = "item:Silvergill Pike Bait"},
        {itemID = 173033, objectiveTitle = "item:Iridescent Amberjack"},
    },
    --@end-retail@

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
    --@retail@
    ["LOCKBOXES (BC)"] = {
        {itemID = 29569, objectiveTitle = "item:Strong Junkbox"},
        {itemID = 31952, objectiveTitle = "item:Khorium Lockbox"},
    },
    ["LOCKBOXES (WRATH)"] = {
        {itemID = 43624, objectiveTitle = "item:Titanium Lockbox"},
        {itemID = 45986, objectiveTitle = "item:Tiny Titanium Lockbox"},
        {itemID = 43622, objectiveTitle = "item:Froststeel Lockbox"},
        {itemID = 43575, objectiveTitle = "item:Reinforced Junkbo"},
    },
    ["LOCKBOXES (CATA)"] = {
        {itemID = 68729, objectiveTitle = "item:Elementium Lockbox"},
        {itemID = 63349, objectiveTitle = "item:Flame-Scarred Junkbox"},
    },
    ["LOCKBOXES (MOP)"] = {
        {itemID = 88567, objectiveTitle = "item:Ghost Iron Lockbox"},
        {itemID = 88165, objectiveTitle = "item:Vine-Cracked Junkbox"},
    },
    ["LOCKBOXES (WOD)"] = {
        {itemID = 116920, objectiveTitle = "item:True Steel Lockbox"},
        {itemID = 106895, objectiveTitle = "item:Iron-Bound Junkbox"},
    },
    ["LOCKBOXES (LEGION)"] = {
        {itemID = 121331, objectiveTitle = "item:Leystone Lockbox"},
    },
    ["LOCKBOXES (BFA)"] = {
        {itemID = 169475, objectiveTitle = "item:Barnacled Lockbox"},
    },
    ["LOCKBOXES (SL)"] = {
        {itemID = 179311, objectiveTitle = "item:Oxxein Lockbox"},
        {itemID = 180522, objectiveTitle = "item:Phaedrum Lockbox"},
        {itemID = 180533, objectiveTitle = "item:Solenium Lockbox"},
        {itemID = 180532, objectiveTitle = "item:Laestrite Lockbox"},
    },
    --@end-retail@

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
    --@retail@
    ["HERBALISM (BC)"] = {
        {itemID = 22794, objectiveTitle = "item:Fel Lotus"},
        {itemID = 22789, objectiveTitle = "item:Terocone"},
        {itemID = 22785, objectiveTitle = "item:Felweed"},
        {itemID = 22793, objectiveTitle = "item:Mana Thistle"},
        {itemID = 22792, objectiveTitle = "item:Nightmare Vine"},
        {itemID = 22791, objectiveTitle = "item:Netherbloom"},
        {itemID = 22787, objectiveTitle = "item:Ragveil"},
        {itemID = 22790, objectiveTitle = "item:Ancient Lichen"},
        {itemID = 22786, objectiveTitle = "item:Dreaming Glory"},
    },
    ["HERBALISM (WRATH)"] = {
        {itemID = 36903, objectiveTitle = "item:Adder's Tongue"},
        {itemID = 36907, objectiveTitle = "item:Talandra's Rose"},
        {itemID = 36908, objectiveTitle = "item:Frost Lotus"},
        {itemID = 36906, objectiveTitle = "item:Icethorn"},
        {itemID = 36905, objectiveTitle = "item:Lichbloom"},
        {itemID = 36901, objectiveTitle = "item:Goldclover"},
        {itemID = 36904, objectiveTitle = "item:Tiger Lily"},
        {itemID = 37921, objectiveTitle = "item:Deadnettle"},
    },
    ["HERBALISM (CATA)"] = {
        {itemID = 52983, objectiveTitle = "item:Cinderbloom"},
        {itemID = 52988, objectiveTitle = "item:Whiptail"},
        {itemID = 52986, objectiveTitle = "item:Heartblossom"},
        {itemID = 52987, objectiveTitle = "item:Twilight Jasmine"},
        {itemID = 52984, objectiveTitle = "item:Stormvine"},
        {itemID = 52985, objectiveTitle = "item:Azshara's Veil"},
    },
    ["HERBALISM (MOP)"] = {
        {itemID = 72237, objectiveTitle = "item:Rain Poppy"},
        {itemID = 89639, objectiveTitle = "item:Desecrated Herb"},
        {itemID = 72234, objectiveTitle = "item:Green Tea Leaf"},
        {itemID = 72238, objectiveTitle = "item:Golden Lotus"},
        {itemID = 79010, objectiveTitle = "item:Snow Lily"},
        {itemID = 72235, objectiveTitle = "item:Silkweed"},
        {itemID = 79011, objectiveTitle = "item:Fool's Cap"},
    },
    ["HERBALISM (WOD)"] = {
        {itemID = 109126, objectiveTitle = "item:Gorgrond Flytrap"},
        {itemID = 109127, objectiveTitle = "item:Starflower"},
        {itemID = 109124, objectiveTitle = "item:Frostweed"},
        {itemID = 109125, objectiveTitle = "item:Fireweed"},
        {itemID = 109128, objectiveTitle = "item:Nagrand Arrowbloom"},
        {itemID = 109129, objectiveTitle = "item:Talador Orchid"},
    },
    ["HERBALISM (LEGION)"] = {
        {itemID = 151565, objectiveTitle = "item:Astral Glory"},
        {itemID = 124103, objectiveTitle = "item:Foxflower"},
        {itemID = 124101, objectiveTitle = "item:Aethril"},
        {itemID = 124102, objectiveTitle = "item:Dreamleaf"},
        {itemID = 124104, objectiveTitle = "item:Fjarnskaggl"},
        {itemID = 124105, objectiveTitle = "item:Starlight Rose"},
        {itemID = 128304, objectiveTitle = "item:Yseralline Seed"},
        {itemID = 129289, objectiveTitle = "item:Felwort Seed"},
        {itemID = 124106, objectiveTitle = "item:Felwort"},
    },
    ["HERBALISM (BFA)"] = {
        {itemID = 168487, objectiveTitle = "item:Zin'anthid"},
        {itemID = 152506, objectiveTitle = "item:Star Moss"},
        {itemID = 152505, objectiveTitle = "item:Riverbud"},
        {itemID = 152510, objectiveTitle = "item:Anchor Weed"},
        {itemID = 152509, objectiveTitle = "item:Siren's Pollen"},
        {itemID = 152507, objectiveTitle = "item:Akunda's Bite"},
        {itemID = 152508, objectiveTitle = "item:Winter's Kiss"},
        {itemID = 152511, objectiveTitle = "item:Sea Stalk"},
    },
    ["HERBALISM (SL)"] = {
        {itemID = 168586, objectiveTitle = "item:Rising Glory"},
        {itemID = 169701, objectiveTitle = "item:Death Blossom"},
        {itemID = 168583, objectiveTitle = "item:Widowbloom"},
        {itemID = 168589, objectiveTitle = "item:Marrowroot"},
        {itemID = 170554, objectiveTitle = "item:Vigil's Torch"},
        {itemID = 171315, objectiveTitle = "item:Nightshade"},
    },
    --@end-retail@

    --@retail@
    ["MECHAGON (BFA)"] = {
        {itemID = 167562, objectiveTitle = "item:Ionized Minnow"},
        {itemID = 168961, objectiveTitle = "item:Exothermic Evaporator Coil"},
        {itemID = 168215, objectiveTitle = "item:Machined Gear Assembly"},
        {itemID = 169610, objectiveTitle = "item:S.P.A.R.E. Crate"},
        {itemID = 168264, objectiveTitle = "item:Recycling Requisition"},
        {itemID = 166971, objectiveTitle = "item:Empty Energy Cell"},
        {itemID = 166970, objectiveTitle = "item:Energy Cell"},
        {itemID = 168266, objectiveTitle = "item:Strange Recycling Requisition"},
        {itemID = 168217, objectiveTitle = "item:Hardened Spring"},
        {itemID = 168216, objectiveTitle = "item:Tempered Plating"},
        {itemID = 168258, objectiveTitle = "item:Bundle of Recyclable Parts"},
        {itemID = 168832, objectiveTitle = "item:Galvanic Oscillator"},
        {itemID = 166846, objectiveTitle = "item:Spare Parts"},
        {itemID = 168327, objectiveTitle = "item:Chain Ignitercoil"},
    },
    --@end-retail@

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
    --@retail@
    ["MINING (BC)"] = {
        {itemID = 23424, objectiveTitle = "item:Fel Iron Ore"},
        {itemID = 23426, objectiveTitle = "item:Khorium Ore"},
        {itemID = 23427, objectiveTitle = "item:Eternium Ore"},
        {itemID = 23425, objectiveTitle = "item:Adamantite Ore"},
    },
    ["MINING (WRATH)"] = {
        {itemID = 36909, objectiveTitle = "item:Cobalt Ore"},
        {itemID = 36910, objectiveTitle = "item:Titanium Ore"},
        {itemID = 36912, objectiveTitle = "item:Saronite Ore"},
    },
    ["MINING (CATA)"] = {
        {itemID = 53038, objectiveTitle = "item:Obsidium Ore"},
        {itemID = 52183, objectiveTitle = "item:Pyrite Ore"},
        {itemID = 52185, objectiveTitle = "item:Elementium Ore"},
    },
    ["MINING (MOP)"] = {
        {itemID = 72092, objectiveTitle = "item:Ghost Iron Ore"},
        {itemID = 72094, objectiveTitle = "item:Black Trillium Ore"},
        {itemID = 72103, objectiveTitle = "item:White Trillium Ore"},
        {itemID = 72093, objectiveTitle = "item:Kyparite"},
    },
    ["MINING (WOD)"] = {
        {itemID = 108042, objectiveTitle = "item:Draenic Iron Ore"},
        {itemID = 109119, objectiveTitle = "item:True Iron Ore"},
        {itemID = 109118, objectiveTitle = "item:Blackrock Ore"},
    },
    ["MINING (LEGION)"] = {
        {itemID = 123918, objectiveTitle = "item:Leystone Ore"},
        {itemID = 151564, objectiveTitle = "item:Empyrium"},
        {itemID = 124444, objectiveTitle = "item:Infernal Brimstone"},
        {itemID = 123919, objectiveTitle = "item:Felslate"},
    },
    ["MINING (BFA)"] = {
        {itemID = 152512, objectiveTitle = "item:Monelite Ore"},
        {itemID = 152513, objectiveTitle = "item:Platinum Ore"},
        {itemID = 168185, objectiveTitle = "item:Osmenite Ore"},
        {itemID = 152579, objectiveTitle = "item:Storm Silver Ore"},
    },
    ["MINING (SL)"] = {
        {itemID = 171830, objectiveTitle = "item:Oxxein Ore"},
        {itemID = 177061, objectiveTitle = "item:Twilight Bark"},
        {itemID = 171829, objectiveTitle = "item:Solenium Ore"},
        {itemID = 171841, objectiveTitle = "item:Shaded Stone"},
        {itemID = 171840, objectiveTitle = "item:Porous Stone"},
        {itemID = 171832, objectiveTitle = "item:Sinvyr Ore"},
        {itemID = 171831, objectiveTitle = "item:Phaedrum Ore"},
        {itemID = 171828, objectiveTitle = "item:Laestrite Ore"},
        {itemID = 171833, objectiveTitle = "item:Elethium Ore"},
    },
    --@end-retail@

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
    --@retail@
    ["SKINNING (BC)"] = {
        {itemID = 25649, objectiveTitle = "item:Knothide Leather Scraps"},
        {itemID = 25708, objectiveTitle = "item:Thick Clefthoof Leather"},
        {itemID = 25707, objectiveTitle = "item:Fel Hide"},
        {itemID = 21887, objectiveTitle = "item:Knothide Leather"},
    },
    ["SKINNING (WRATH)"] = {
        {itemID = 38557, objectiveTitle = "item:Icy Dragonscale"},
        {itemID = 33567, objectiveTitle = "item:Borean Leather Scraps"},
        {itemID = 38558, objectiveTitle = "item:Nerubian Chitin"},
        {itemID = 33568, objectiveTitle = "item:Borean Leather"},
        {itemID = 44128, objectiveTitle = "item:Arctic Fur"},
        {itemID = 38561, objectiveTitle = "item:Jormungar Scale"},
    },
    ["SKINNING (CATA)"] = {
        {itemID = 52982, objectiveTitle = "item:Deepsea Scale"},
        {itemID = 52979, objectiveTitle = "item:Blackened Dragonscale"},
        {itemID = 67495, objectiveTitle = "item:Strange Bloated Stomach"},
        {itemID = 52980, objectiveTitle = "item:Pristine Hide"},
        {itemID = 52976, objectiveTitle = "item:Savage Leather"},
        {itemID = 52977, objectiveTitle = "item:Savage Leather Scraps"},
    },
    ["SKINNING (MOP)"] = {
        {itemID = 72162, objectiveTitle = "item:Sha-Touched Leather"},
        {itemID = 72163, objectiveTitle = "item:Magnificent Hide"},
        {itemID = 79101, objectiveTitle = "item:Prismatic Scale"},
        {itemID = 72201, objectiveTitle = "item:Plump Intestines"},
        {itemID = 72120, objectiveTitle = "item:Exotic Leather"},
    },
    ["SKINNING (WOD)"] = {
        {itemID = 110610, objectiveTitle = "item:Raw Beast Hide Scraps"},
        {itemID = 110611, objectiveTitle = "item:Burnished Leather"},
        {itemID = 110609, objectiveTitle = "item:Raw Beast Hide"},
    },
    ["SKINNING (LEGION)"] = {
        {itemID = 124113, objectiveTitle = "item:Stonehide Leather"},
        {itemID = 151566, objectiveTitle = "item:Fiendish Leather"},
        {itemID = 124116, objectiveTitle = "item:Felhide"},
        {itemID = 124115, objectiveTitle = "item:Stormscale"},
    },
    ["SKINNING (BFA)"] = {
        {itemID = 152541, objectiveTitle = "item:Coarse Leather"},
        {itemID = 153051, objectiveTitle = "item:Mistscale"},
        {itemID = 154722, objectiveTitle = "item:Tempest Hide"},
        {itemID = 168650, objectiveTitle = "item:Cragscale"},
        {itemID = 154165, objectiveTitle = "item:Calcified Bone"},
        {itemID = 154164, objectiveTitle = "item:Blood-Stained Bone"},
        {itemID = 168649, objectiveTitle = "item:Dredged Leather"},
        {itemID = 153050, objectiveTitle = "item:Shimmerscale"},
    },
    ["SKINNING (SL)"] = {
        {itemID = 172093, objectiveTitle = "item:Desolate Leather Scraps"},
        {itemID = 177279, objectiveTitle = "item:Gaunt Sinew"},
        {itemID = 172092, objectiveTitle = "item:Pallid Bone"},
        {itemID = 172096, objectiveTitle = "item:Heavy Desolate Leather"},
        {itemID = 172094, objectiveTitle = "item:Callous Hide"},
        {itemID = 172097, objectiveTitle = "item:Heavy Callous Hide"},
        {itemID = 172089, objectiveTitle = "item:Desolate Leather"},
    },
    --@end-retail@
}


--*------------------------------------------------------------------------
-- Create template


function addon:SaveTemplate(barID, templateName, overwrite)
    templateName = strupper(templateName)

    if self:GetDBValue("global", "templates")[templateName] and not overwrite then
        -- Confirm overwrite
        local dialog = StaticPopup_Show("FARMINGBAR_CONFIRM_OVERWRITE_TEMPLATE", templateName)
        if dialog then
            dialog.data = barID
            dialog.data2 = templateName
        end
    else
        self:GetDBValue("global", "templates")[templateName] = {}

        -- Add items from bar to the template
        local buttons = self.bars[barID]:GetButtons()

        for buttonID, button in pairs(buttons) do
            if not button:IsEmpty() then
                self:GetDBValue("global", "templates")[templateName][tostring(buttonID)] = self:CloneTable(button:GetButtonDB())
            end
        end

        self:Print(format(L.TemplateSaved, barID, templateName))
    end
end


--*------------------------------------------------------------------------
-- Manage


function addon:DeleteTemplate(templateName)
    self.db.global.templates[templateName] = nil
    self:Print(format(L.TemplateDeleted, templateName))
end


function addon:LoadTemplate(templateType, barID, templateName, withData, saveOrder)
    local template = templateType == "user" and self:GetDBValue("global", "templates")[strupper(templateName)] or self.templates[strupper(templateName)]
    local bar = self.bars[barID]

    -- Clear items off the bar
    self:ClearBar(barID)

    -- Make sure we have enough visible buttons for the template
    local numTemplateButtons = addon.tcount(template)
    if saveOrder then
        -- Get the key for the last template item
        for buttonID, _ in self.pairs(template, function(a, b) return tonumber(a) < tonumber(b) end) do
            numTemplateButtons = tonumber(buttonID)
        end
    end

    if bar:GetBarDB().numVisibleButtons < numTemplateButtons then
        self:SetBarDBValue("numVisibleButtons", numTemplateButtons, barID)
        bar:UpdateVisibleButtons()
    end

    -- Add templates to bar
    local buttons = bar:GetButtons()
    i = 1
    for buttonID, objective in pairs(template) do
        if templateType == "user" then
            id = saveOrder and tonumber(buttonID) or i
            i = i + 1

            self:CreateObjectiveFromUserTemplate(buttons[id], objective, withData)
        else
            self:CreateObjectiveFromTemplate(buttons[buttonID], objective)
        end
    end

    -- Reindex bars
    if not saveOrder then
        self:ReindexButtons(barID)
    end
end