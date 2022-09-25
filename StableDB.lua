FarmingBarDB = {
    ["char"] = {
        ["Nikketa - Hyjal"] = {
            ["bars"] = {
                {
                    ["enabled"] = true,
                    ["position"] = {
                        "TOPLEFT", -- [1]
                        nil, -- [2]
                        "TOPLEFT", -- [3]
                        319.3611450195313, -- [4]
                        -193.3908996582031, -- [5]
                    },
                    ["objectives"] = {
                        {
                            ["type"] = "currency",
                            ["objective"] = 475,
                            ["currencyID"] = 1191,
                        }, -- [1]
                        {
                            ["type"] = "item",
                            ["title"] = "Relics",
                            ["includeBank"] = false,
                            ["objective"] = 300,
                            ["itemID"] = 190189,
                        }, -- [2]
                        {
                            ["items"] = {
                                172045, -- [1]
                                172049, -- [2]
                            },
                            ["type"] = "mixedItems",
                            ["title"] = "Food",
                            ["includeBank"] = false,
                            ["icon"] = "133949",
                            ["objective"] = 20,
                        }, -- [3]
                        {
                            ["items"] = {
                                [172232] = 1,
                                [172231] = 2,
                            },
                            ["type"] = "shoppingList",
                            ["title"] = "Enchant",
                            ["includeBank"] = true,
                            ["icon"] = "463531",
                            ["objective"] = 3,
                        }, -- [4]
                    },
                }, -- [1]
            },
        },
    },
    ["profileKeys"] = {
        ["Nikketa - Hyjal"] = "Default",
    },
    ["global"] = {
        ["commands"] = {
            ["fbar"] = false,
            ["fb"] = true,
            ["farmbar"] = false,
            ["farm"] = false,
        },
        ["tooltips"] = {
            ["mod"] = "Shift",
            ["button"] = false,
            ["enableMod"] = false,
            ["bar"] = false,
        },
        ["alerts"] = {
            ["barChat"] = false,
            ["chatFrame"] = "ChatFrame6",
            ["barScreen"] = false,
            ["barSound"] = false,
            ["sound"] = false,
            ["screen"] = false,
            ["chat"] = false,
        },
        ["sounds"] = {
            ["objectiveCleared"] = "MSBT Cooldown",
            ["barComplete"] = "BugSack: Fatality",
            ["farmingProgress"] = "MSBT Low Health",
            ["objectiveComplete"] = "None",
            ["objectiveSet"] = "Loot Coin",
            ["barProgress"] = "MSBT Low Mana",
        },
    },
    ["profiles"] = {
        ["Default"] = {},
    },
}
