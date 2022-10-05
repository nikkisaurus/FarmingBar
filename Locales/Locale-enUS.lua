local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0")
local L = LibStub("AceLocale-3.0"):NewLocale(addonName, "enUS", true)
LibStub("LibAddonUtils-1.0"):Embed(addon)

L.addonName = "Farming Bar"

private.status = {
    options = {
        objectiveTemplates = {
            newTrackerType = "ITEM",
            newAltIDType = "ITEM",
        },
        bar = {},
    },
    objectiveEditor = {
        newTrackerType = "ITEM",
        newAltIDType = "ITEM",
    },
}

L[" for help."] = true
L[" to configure bars."] = true
L[" to configure settings."] = true
L[" to configure this bar."] = true
L[" to enable/disable the active profile."] = true
L[" to lock and hide anchor."] = true
L["%d more..."] = true
L["%s Text"] = true
L["* The following settings are profile specific."] = true
L["Add Tracker"] = true
L["Add"] = true
L["Alert formats must be a function returning a string value."] = true
L["Alert formats must be a string value. Please be sure if statements are properly formatted and do not cause a Lua error."] = true
L["Alerts"] = true
L["All Bars"] = true
L["All"] = true
L["Alpha"] = true
L["AlphaKey"] = true
L["Alt ID already exists for this tracker."] = true
L["Alt ID"] = true
L["Alt IDs"] = true
L["Alt"] = true
L["Alts"] = true
L["Anchor"] = true
L["Any"] = true
L["Appearance"] = true
L["Apply Objective Template"] = true
L["Are you sure you want to clear Bar %d?"] = true
L["Are you sure you want to clear this button?"] = true
L["Are you sure you want to delete the objective template \"%s\"?"] = true
L["Are you sure you want to overwrite \"%s\" with \"%s\"?"] = true
L["Are you sure you want to overwrite Bar %d Button %d with objective template \"%s\"?"] = true
L["Are you sure you want to remove %s from %s?"] = true
L["Are you sure you want to remove %s from the tracker \"%s\"?"] = true
L["Are you sure you want to remove Bar %d?"] = true
L["Are you sure you want to remove skin \"%s\"?"] = true
L["Are you sure you want to reset bar alerts format?"] = true
L["Are you sure you want to reset button alerts format?"] = true
L["Are you sure you want to reset this bar's hidden function?"] = true
L["Are you sure you want to reset tracker alerts format?"] = true
L["Auction Close"] = true
L["Auction Open"] = true
L["Auto Loot"] = true
L["Auto"] = true
L["Automatically loot items when using an objective, regardless of whether auto loot is enabled in game settings."] = true
L["Backdrop"] = true
L["Background Color"] = true
L["Background"] = true
L["Bank"] = true
L["Bar Anchor"] = true
L["Bar Backdrop"] = true
L["Bar Complete"] = true
L["Bar is already assigned an ID: %d"] = true
L["Bar Progress"] = true
L["Bar Tooltips"] = true
L["Bar"] = true
L["barDB.hidden must return a \"function\""] = true
L["Blend Mode"] = true
L["BLEND"] = true
L["Blend"] = true
L["Border"] = true
L["Button Growth"] = true
L["Button is already assigned an ID: %d:%d"] = true
L["Button Padding"] = true
L["Button Size"] = true
L["Button textures may be controlled by Masque and must be disabled through its settings for skins to be applied."] = true
L["Button Textures"] = true
L["Button Tooltips"] = true
L["Button"] = true
L["Buttons Per Axis"] = true
L["Buttons"] = true
L["Chat frame for chat alerts from this bar."] = true
L["Chat Frame"] = true
L["Chat Frame"] = true
L["Chat"] = true
L["Choose"] = true
L["Clear Bar"] = true
L["Clear"] = true
L["clearObjective"] = "Clear Goal"
L["Code Viewer"] = true
L["Color"] = true
L["Completed Goals"] = true
L["Condition"] = true
L["Config"] = true
L["Configure bar settings."] = true
L["Confirm"] = true
L["Continue tracking farming progress after goal completion."] = true
L["Control"] = true
L["Converted Currency"] = true
L["Converted Item"] = true
L["Copy From"] = true
L["Count"] = true
L["Currency"] = true
L["Custom Condition"] = true
L["Custom Condition: Invalid function"] = true
L["Custom Condition: Syntax error"] = true
L["Custom Tracker Condition"] = true
L["Custom"] = true
L["Default chat frame for chat alerts. * Profile"] = true
L["Disable active profile."] = true
L["Disable all tooltips."] = true
L["Disable"] = true
L["Disabled"] = true
L["dragObjective"] = "Drag Objective"
L["Draw Layer"] = true
L["Duplicate"] = true
L["Enable active profile."] = true
L["Enable all tooltips."] = true
L["Enable chat alerts."] = true
L["Enable screen alerts."] = true
L["Enable sound alerts."] = true
L["Enable this slash command."] = true
L["Enable"] = true
L["Event \"%s\" doesn't exist."] = true
L["Events"] = true
L["Expand Tooltip"] = true
L["Expand"] = true
L["Export Frame"] = true
L["Export"] = true
L["Fallback"] = true
L["Farming Progress"] = true
L["First"] = true
L["Font Face"] = true
L["Font Outline"] = true
L["Font Size"] = true
L["Fonts"] = true
L["Format Type"] = true
L["Format"] = true
L["Function"] = true
L["General"] = true
L["Gloss"] = true
L["Goal Cleared"] = true
L["Goal Complete"] = true
L["Goal Set"] = true
L["Goal"] = true
L["Guild Bank"] = true
L["Help"] = true
L["Hidden (Override Func)"] = true
L["Hidden must be a function returning a boolean value."] = true
L["Hidden"] = true
L["Hides the bar, regardless of the output from the custom hidden function."] = true
L["Highlight"] = true
L["Hints"] = true
L["Hold this key down while hovering over a button to view additional tooltip details."] = true
L["Icon Border Thick"] = true
L["Icon Border"] = true
L["Icon ID"] = true
L["Icon Selector"] = true
L["Icon"] = true
L["Import Frame"] = true
L["Import"] = true
L["Include Alts"] = true
L["Include Bank"] = true
L["Include counts from alts for this tracker."] = true
L["Include counts from the bank for this tracker."] = true
L["Include counts from the selected guild bank(s) for this tracker."] = true
L["Include Guild Bank"] = true
L["Include"] = true
L["Insets"] = true
L["Invalid alpha value. Please provide an integer between 0 and 1."] = true
L["Invalid anchor: bottomleft | bottomright | topleft | topright"] = true
L["Invalid barID. To apply to all bars, use barID 0."] = true
L["Invalid currency ID."] = true
L["Invalid growth: col | row"] = true
L["Invalid item ID."] = true
L["Invalid scale value. Please provide an integer between %s and %s."] = true
L["Invalid template name."] = true
L["Invalid Tracker/Alt ID"] = true
L["Invalid tradeskill name."] = true
L["Item ID"] = true
L["Item"] = true
L["Keybinds"] = true
L["Label"] = true
L["Last"] = true
L["Layer"] = true
L["Layout"] = true
L["Left Button"] = true
L["Left-click to pickup this objective."] = true
L["Left-click to pickup this objective.\nRight-click to edit this objective."] = true
L["Limit Mats"] = true
L["Lock or unlock bar."] = true
L["Loot Coin"] = true
L["Lua Editor"] = true
L["Macrotext"] = true
L["Manage"] = true
L["Miscellaneous"] = true
L["Mod"] = true
L["Modifier"] = true
L["Monochrome"] = true
L["Mouse Button"] = true
L["Mouseover"] = true
L["Movable"] = true
L["Move canceled; please open bank frame."] = true
L["moveAllToBank"] = "Move All to Bank"
L["moveObjective"] = "Move Objective"
L["moveObjectiveToBank"] = "Move Goal to Bank"
L["Multiplier"] = true
L["Mute alerts for this button."] = true
L["Mute alerts for this objective."] = true
L["Mute all alerts on this bar."] = true
L["Mute All"] = true
L["Mute"] = true
L["Name"] = true
L["New Skin"] = true
L["New"] = true
L["None"] = true
L["Normal"] = true
L["Objective Editor"] = true
L["Objective Templates"] = true
L["Objective"] = true
L["Objectives on this bar cannot use materials already accounted for by another objective on the same bar."] = true
L["On Use Macrotext"] = true
L["onUse"] = "On Use"
L["OnUse"] = "On Use"
L["Outline"] = true
L["Overlay"] = true
L["Page"] = true
L["Please specify a number between %d and %d."] = true
L["Please specify a number between %s and %s."] = true
L["Please specify a tradeskill recipe name."] = true
L["Please specify movable type: true, false, toggle."] = true
L["Preview"] = true
L["Pushed"] = true
L["Quest Activate"] = true
L["Quest Complete"] = true
L["Quest Failed"] = true
L["Refresh hidden status on these events."] = true
L["Remove Alt ID"] = true
L["Remove Objective Template"] = true
L["Remove Skin"] = true
L["Reset Bar Alert"] = true
L["Reset both string and function bar formats."] = true
L["Reset both string and function button formats."] = true
L["Reset Button Alert"] = true
L["Reset Hidden"] = true
L["Reset Tracker Alert"] = true
L["Right Button"] = true
L["Save as Template"] = true
L["Save Template"] = true
L["Scale"] = true
L["Screen"] = true
L["Set bar alpha."] = true
L["Set bar scale."] = true
L["Set the amount of this tracker required to count toward one of this objective."] = true
L["Set the anchor of the button to the bar."] = true
L["Set the default padding of bar buttons."] = true
L["Set the default size of bar buttons."] = true
L["Set the direction buttons grow: row (horizontally) or col (vertically)."] = true
L["Set the direction of bar's growth."] = true
L["Set the goal for the objective."] = true
L["Set the goal for the tracker."] = true
L["Set the ID of the item to use when using this objective."] = true
L["Set the ID or path of the icon texture."] = true
L["Set the macrotext to be run when using this objective."] = true
L["Set the new count for the objective."] = true
L["Set the new count for the tracker."] = true
L["Set the new goal progress for the bar."] = true
L["Set the number of buttons before a bar wraps to a new column or row."] = true
L["Set the number of buttons on bar."] = true
L["Set the number of buttons per axis."] = true
L["Set the number of buttons per bar."] = true
L["Set the number of goals for the bar."] = true
L["Set the old count for the objective."] = true
L["Set the old count for the tracker."] = true
L["Set the old goal progress for the bar."] = true
L["Set the order of this tracker."] = true
L["Set the padding of bar's buttons."] = true
L["Set the size of bar's buttons."] = true
L["Set the sound played when a goal is cleared from an objective."] = true
L["Set the sound played when a goal is met for an objective."] = true
L["Set the sound played when a goal is set for an objective."] = true
L["Set the sound played when all goals are met on a bar."] = true
L["Set the sound played when progress is made toward an objective."] = true
L["Set the sound played when progress is made towards a bar's goals."] = true
L["Set the spacing between buttons."] = true
L["Set the type of action performed when using this objective."] = true
L["Settings"] = true
L["Shadow"] = true
L["Shift"] = true
L["Shift+left-click to choose this icon."] = true
L["Show all details on tooltips without holding the modifier key."] = true
L["Show Cooldown"] = true
L["Show Details"] = true
L["Show Edge"] = true
L["Show Empty"] = true
L["Show hints on tooltips without holding the modifier key."] = true
L["Show Hints"] = true
L["Show Hyperlink"] = true
L["Show item hyperlink on button tooltips."] = true
L["Show options frame."] = true
L["Show this bar only on mouseover."] = true
L["Show tooltips when hovering over a bar's anchor."] = true
L["Show tooltips when hovering over a button."] = true
L["showObjectiveEditBox"] = "Show Goal EditBox"
L["showObjectiveEditor"] = "Show Objective Editor"
L["showQuickAddCurrencyEditBox"] = "Show Quick-Add Currency EditBox"
L["showQuickAddEditBox"] = "Show Quick-Add EditBox"
L["Shows a backdrop on empty buttons."] = true
L["Shows the cooldown swipe animation on buttons."] = true
L["Skin"] = true
L["Skins"] = true
L["Slash Commands"] = true
L["Solid Border"] = true
L["Sound"] = true
L["Sounds"] = true
L["String"] = true
L["Style"] = true
L["Swap profiles."] = true
L["Template exists."] = true
L["Templates"] = true
L["TexCoords"] = true
L["Texture"] = true
L["The ID of a tracker which is equivalent to this tracker."] = true
L["Thick Outline"] = true
L["Toggle all tooltips."] = true
L["Toggle bar tooltips."] = true
L["Toggle button tooltips."] = true
L["Toggle tooltips."] = true
L["Tooltips"] = true
L["Track the number of completed goals on this bar."] = true
L["Tracker already exists for this objective."] = true
L["Tracker ID"] = true
L["Tracker Key"] = true
L["Tracker Type"] = true
L["Tracker"] = true
L["Trackers"] = true
L["Type"] = true
L["UI ActionButton Border"] = true
L["UI EmptySlot White"] = true
L["Use GameTooltip"] = true
L["Use the GameTooltip for bar and button tooltips instead of Farming Bar's default tooltip."] = true
L["User Templates"] = true
L["View Code"] = true
L["X-Offset"] = true
L["Y-Offset"] = true

L.OptionsHelp = function()
    -- Type 1 = string, 2 = group, 3 = header
    local strs = {
        {
            3,
            format("Farming Bar - Version %.1f", 3.0),
        },
        {
            1,
            format("Farming Bar allows you to create an unlimited number of bars to track items and complex objectives. You can either place an item on the bar or create an objective template to drag onto the bar. Once a button is tracking a farming objective, options become available to customize and edit. By default, %s opens the Objective Editor, where you can edit properties similar to the Objective Template Builder. You can also set an goal for each farming objective; just %s the button and enter your goal into the editbox. Other actions that can be performed on buttons can be seen in the Hints section at the bottom of the button's tooltip.", addon.ColorFontString("control+right-click", "LIGHTBLUE"), addon.ColorFontString("control+left-click", "LIGHTBLUE")),
        },
        {
            3,
            "Issues",
        },
        {
            1,
            format("For any bugs or feature requests, please create a ticket at %s. General questions should be left as comments at %s.", addon.ColorFontString("tinyurl.com/farmingbarissues", "LIGHTBLUE"), addon.ColorFontString("tinyurl.com/farmingbarwow", "LIGHTBLUE")),
        },
        {
            2,
            "Alerts",
            {
                {
                    1,
                    "Custom alerts should return your alert as a string. If you choose to use the function format type, it will be provided a table with information about the alert and a color table for quick access to red, green, and gold colors. If you choose the string format type, you will be able to use several placeholders, outlined below.",
                },
                {
                    4,
                    "Bar Alerts",
                    {
                        {
                            1,
                            format("%s = %s", addon.ColorFontString("%b", "LIGHTBLUE"), "bar ID name"),
                        },
                        {
                            1,
                            format("%s = %s", addon.ColorFontString("%B", "LIGHTBLUE"), "long bar name"),
                        },
                        {
                            1,
                            format("%s = %s", addon.ColorFontString("%c", "LIGHTBLUE"), "new progress count"),
                        },
                        {
                            1,
                            format("%s = %s", addon.ColorFontString("%d", "LIGHTBLUE"), "difference"),
                        },
                        {
                            1,
                            format("%s = %s", addon.ColorFontString("%n", "LIGHTBLUE"), "bar name"),
                        },
                        {
                            1,
                            format("%s = %s", addon.ColorFontString("%p", "LIGHTBLUE"), "percentage of completion"),
                        },
                        {
                            1,
                            format("%s = %s", addon.ColorFontString("%r", "LIGHTBLUE"), "remainder of completion"),
                        },
                        {
                            1,
                            format("%s = %s", addon.ColorFontString("%t", "LIGHTBLUE"), "new progress total"),
                        },
                    },
                },
                {
                    4,
                    "Button Alerts",
                    {
                        {
                            1,
                            format("%s = %s", addon.ColorFontString("%c", "LIGHTBLUE"), "new count"),
                        },
                        {
                            1,
                            format("%s = %s", addon.ColorFontString("%C", "LIGHTBLUE"), "old count"),
                        },
                        {
                            1,
                            format("%s = %s", addon.ColorFontString("%d", "LIGHTBLUE"), "difference"),
                        },
                        {
                            1,
                            format("%s = %s", addon.ColorFontString("%g", "LIGHTBLUE"), "goal"),
                        },
                        {
                            1,
                            format("%s = %s", addon.ColorFontString("%O", "LIGHTBLUE"), "repititions of completion"),
                        },
                        {
                            1,
                            format("%s = %s", addon.ColorFontString("%p", "LIGHTBLUE"), "percentage of completion"),
                        },
                        {
                            1,
                            format("%s = %s", addon.ColorFontString("%r", "LIGHTBLUE"), "remainder of completion"),
                        },
                        {
                            1,
                            format("%s = %s", addon.ColorFontString("%t", "LIGHTBLUE"), "objective title"),
                        },
                    },
                },
                {
                    4,
                    "Colors",
                    {
                        {
                            1,
                            format("%s = %s", addon.ColorFontString("%color%", "LIGHTBLUE"), "||r - closes out color codes"),
                        },
                        {
                            1,
                            format("%s = %s", addon.ColorFontString("%diffColor%", "LIGHTBLUE"), "green or red, depending on whether difference is positive or negative"),
                        },
                        {
                            1,
                            addon.ColorFontString("%gold%", "LIGHTBLUE"),
                        },
                        {
                            1,
                            addon.ColorFontString("%green%", "LIGHTBLUE"),
                        },
                        {
                            1,
                            format("%s = %s", addon.ColorFontString("%progressColor%", "LIGHTBLUE"), "green or yellow, depending on whether progress is positive or negative"),
                        },
                        {
                            1,
                            addon.ColorFontString("%red%", "LIGHTBLUE"),
                        },
                    },
                },
                {
                    4,
                    "If Statements",
                    {
                        {
                            1,
                            addon.ColorFontString("%if(condition,then,else)if%", "LIGHTBLUE"),
                        },
                        {
                            1,
                            format("If statements can be used to control when certain pieces of text are displayed within your alert and must follow the format above. \"condition\" should be a lua expression and when true, \"then\" will show up in your alert, otherwise \"else\" will. You must provide a comma after \"then\", even if you have a blank \"else\" statement. For example: %s would mean \"if goal is equal to zero (goal is not set), then print x, else print nothing\".", addon.ColorFontString("%if(%g==0,x,)if%", "LIGHTBLUE")),
                        },
                    },
                },
                {
                    4,
                    "Tracker Alerts",
                    {
                        {
                            1,
                            format("%s = %s", addon.ColorFontString("%c", "LIGHTBLUE"), "new count"),
                        },
                        {
                            1,
                            format("%s = %s", addon.ColorFontString("%C", "LIGHTBLUE"), "old count"),
                        },
                        {
                            1,
                            format("%s = %s", addon.ColorFontString("%d", "LIGHTBLUE"), "difference"),
                        },
                        {
                            1,
                            format("%s = %s", addon.ColorFontString("%g", "LIGHTBLUE"), "objective goal"),
                        },
                        {
                            1,
                            format("%s = %s", addon.ColorFontString("%G", "LIGHTBLUE"), "tracker goal total"),
                        },
                        {
                            1,
                            format("%s = %s", addon.ColorFontString("%p", "LIGHTBLUE"), "percentage of completion"),
                        },
                        {
                            1,
                            format("%s = %s", addon.ColorFontString("%r", "LIGHTBLUE"), "remainder of completion"),
                        },
                        {
                            1,
                            format("%s = %s", addon.ColorFontString("%t", "LIGHTBLUE"), "objective title"),
                        },
                        {
                            1,
                            format("%s = %s", addon.ColorFontString("%T", "LIGHTBLUE"), "tracker title"),
                        },
                    },
                },
            },
        },
        {
            2,
            "Objective Templates",
            {
                {
                    1,
                    "The Objective Template Builder allows you to create highly customizable farming objectives, which can be placed onto a bar by left-clicking the objective's icon. Objectives consist of trackers, which are individual items or currencies that have their own goals to meet before counting towards the objective. By default, an objective is not met until the objective of all trackers is met. However, you can mix and match trackers by using the tracker condition \"ALL\". Additionally, if you are comfortable with Lua, you can create a custom function to control how your objective is counted.",
                },
                {
                    4,
                    "Alt IDs",
                    {
                        {
                            1,
                            "Trackers have alt IDs, which are items or currencies that are equivalent to the main tracker. For each alt ID, you can set a multiplier to indicate how many count toward 1 tracker. For example, a [Sacred Shard] may have an alt ID [Eternal Crystal] with a multiplier of 3, meaning each Eternal Crystal counts as 3 [Sacred Shard] (given your tracker objective is 1). Multipliers will also accept fractions and decimals; for example, an [Eternal Air] may have an alt ID [Crystallized Air] with a multiplier of 1/10, so that 10 [Crystallized Air] counts as 1 Eternal Air.",
                        },
                    },
                },
                {
                    4,
                    "Auto Icon",
                    {
                        {
                            1,
                            "By default, auto icon will attempt to use an icon from an objective's on use item. However, if on use is not an item, it will use the icon from the first tracker or the default miscellaneous icon.",
                        },
                    },
                },
                {
                    4,
                    "Custom Condition",
                    {
                        {
                            1,
                            "Custom conditions are provided with the trackers database table and the default function used to calculate a tracker's count. From each tracker configuration, the tracker key can be edited to change the order of keys provided by the trackers table. Your custom function must return an integer indicating the count of your objective, and you have complete freedom within this function to calculate it.",
                        },
                    },
                },
                {
                    4,
                    "On Use",
                    {
                        {
                            1,
                            "An objective's on use setting controls the behavior of the button when used. For example, when you place an item on a bar, by default, it's on use is to use the item placed. With the Objective Template Builder, you can specify any item, regardless of whether it's being tracked, for its on use effect. Additionally, you can supply a macrotext to be run when using your objective, including the built-in \"/craft profession recipe name\" command, which allows you to craft a profession item on use.",
                        },
                    },
                },
                {
                    4,
                    "Trackers",
                    {
                        {
                            1,
                            "Each tracker has its own individual goal and can be set to include other sources separately. While \"include bank\" is available by default, users with the DataStore addon (including plugins: DataStore, DataStore_Auctions, DataStore_Characters, DataStore_Containers, DataStore_Currencies, DataStore_Inventory, DataStore_Mails) may track items and currencies on alts and even from guild banks.",
                        },
                    },
                },
            },
        },
        {
            2,
            "Miscellaneous",
            {
                {
                    4,
                    "Commands",
                    {
                        {
                            1,
                            format("Command documentation can be accessed via the command %s.", addon.ColorFontString("/farmingbar help", "LIGHTBLUE")),
                        },
                    },
                },
                {
                    4,
                    "Hidden Funcs",
                    {
                        {
                            1,
                            "Hidden funcs allow you to set special conditions to hide your bars, such as by your professions, character name, zone, etc. Naturally, some situations may be variable, so you can specify events to listen for to update your bar's hidden status. Ultimately, your hidden func should return true to hide the bar or false/nil to show it. If you have enabled Hidden (Override Func), your bar will be hidden, even if your function doesn't return true.",
                        },
                    },
                },
                {
                    4,
                    "Skins",
                    {
                        {
                            1,
                            "The Skin Editor allows you to customize each layer of your buttons. Note that if you are using Masque, its settings take precedent over both built-in and user skins. If you would like your skin to override Masque, disable Farming Bar in its settings.",
                        },
                    },
                },
                {
                    4,
                    "Templates",
                    {
                        {
                            1,
                            "Templates are a collection of farming objectives that you can easily load onto new bars. When you create a template, it saves a snapshot of the bar at the moment, including button IDs, objectives, and settings. It will not, however, change your bar settings.",
                        },
                    },
                },
            },
        },
    }

    return strs
end

local function GetCommandString(actionInfo)
    -- Ctrl+right-click
    local mods = private:StringToTitle(gsub(actionInfo.modifier, "-", "+")) -- Put in title case and replace - with +
    local button = gsub(actionInfo.button, "Button", "")
    button = mods == "" and button or format("+%s", strlower(button))
    local clickType = actionInfo.type and "drag" or "click"

    return addon.ColorFontString(format("%s%s-%s", mods, button, clickType), "TORQUISEBLUE")
end

L.ButtonHints = function(action, actionInfo)
    local actions = {
        useItem = format("%s to use the display item or run the display macrotext.", GetCommandString(actionInfo)),
        moveObjective = format("%s to move this objective.", GetCommandString(actionInfo)),
        dragObjective = format("%s to move this objective.", GetCommandString(actionInfo)),
        clearObjective = format("%s to clear this objective.", GetCommandString(actionInfo)),
        showObjectiveEditBox = format("%s to show the goal editbox.", GetCommandString(actionInfo)),
        showQuickAddEditBox = format("%s to show the quick add editbox.", GetCommandString(actionInfo)),
        showQuickAddCurrencyEditBox = format("%s to show the currency quick add editbox.", GetCommandString(actionInfo)),
        showObjectiveEditor = format("%s to show the objective editor.", GetCommandString(actionInfo)),
        moveObjectiveToBank = format("%s to move all items until the objective to your bank.", GetCommandString(actionInfo)),
        moveAllToBank = format("%s to move all items to your bank.", GetCommandString(actionInfo)),
    }

    return actions[action] or ""
end

L.GetTexCoordID = function(id)
    local ids = {
        [1] = "Left",
        [2] = "Right",
        [3] = "Top",
        [4] = "Bottom",
    }
    return ids[id]
end

L.UnknownRecipe = function(recipeName)
    return format("You do not know the recipe: %s. If you believe this is an error, please manually open your tradeskill and try again.", recipeName)
end
