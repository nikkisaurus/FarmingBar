local addonName = ...
local L = LibStub("AceLocale-3.0"):NewLocale(addonName, "enUS", true)
local U = LibStub("LibAddonUtils-1.0")

L.addonName = "Farming Bar"

local gold = U.ChatColors["GOLD"]
local green = U.ChatColors["GREEN"]
local lightblue = U.ChatColors["LIGHTBLUE"]
local red = U.ChatColors["RED"]

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- STRINGS ------------------------------------------------------------------------------------------------------------
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

L["About"] = true
L["Add Bar"] = true
L["Add Item"] = true
L["Alerts"] = true
L["Alert Formats"] = true
L["Alpha"] = true
L["Alt"] = true
L["Args"] = true
L["Anchor"] = true
L["Anchor Mouseover"] = true
L["Auction Close"] = true
L["Auction Open"] = true
L["Auto Loot Items"] = true
L["Bank Inclusion"] = true
L["Bank Overlay"] = true
L["Bar"] = true
L["Bar Alert Formats"] = true
L["Bar Alerts"] = true
L["Bar Complete"] = true
L["Bar Direction"] = true
L["Bar Has Name"] = true
L["Bar Options"] = true
L["Bar Progress"] = true
L["Bars"] = true
L["Bar Tips"] = true
L["Bottom"] = true
L["BOTTOM"] = true
L["BOTTOMLEFT"] = true
L["BOTTOMRIGHT"] = true
L["Bottom/Right"] = true
L["Button"] = true
L["Button Alerts"] = true
L["Button ID"] = true
L["Button Layers"] = true
L["Button Options"] = true
L["Button Padding"] = true
L["Button Size"] = true
L["Button Tips"] = true
L["Buttons"] = true
L["Buttons Per Row/Column"] = true
L["Cancel"] = true
L["CENTER"] = true
L["Chat"] = true
L["Choose"] = true
L["Clear Buttons"] = true
L["Color"] = true
L["Command Aliases"] = true
L["Commands"] = true
L["Config: Bars"] = true
L["Config: Buttons"] = true
L["Control"] = true
L["Cooldown Edge"] = true
L["Cooldown Swipe"] = true
L["Count Color"] = true
L["Count Text"] = true
L["Custom"] = true
L["Currency"] = true
L["Currency ID"] = true
L["Count"] = true
L["default"] = true
L["Delete User Template"] = true
L["Down"] = true
L["Enable Modifier"] = true
L["Example"] = true
L["FALSE"] = true
L["Farming Progress"] = true
L["First"] = true
L["Font"] = true
L["Font Face"] = true
L["Font Outline"] = true
L["Font Size"] = true
L["Growth Direction"] = true
L["Has Objective"] = true
L["Help"] = true
L["Hidden"] = true
L["Icon"] = true
L["Include Bank"] = true
L["Include Data"] = true
L["Include Data Prompt"] = true
L["Item"] = true
L["Items"] = true
L["Item ID"] = true
L["Item ID or Name"] = true
L["Item Level"] = true
L["Item Quality"] = true
L["Last"] = true
L["Left"] = true
L["LEFT"] = true
L["Load Built-In Template"] = true
L["Load User Template"] = true
L["Locked"] = true
L["Loot Coin"] = true
L["minimal"] = true
L["Mixed Items"] = true
L["Modifier"] = true
L["MONOCHROME"] = true
L["Mouseover"] = true
L["Movable"] = true
L["Mute Alerts"] = true
L["Name/Description"] = true
L["New"] = true
L["New Count Preview"] = true
L["Next"] = true
L["No"] = true
L["No Objective"] = true
L["NONE"] = true
L["Normal"] = true
L["Objective"] = true
L["Objective Builder"] = true
L["Objective Cleared"] = true
L["Objective Complete"] = true
L["Objective Preview"] = true
L["Objective Set"] = true
L["Objective Text"] = true
L["Old Count Preview"] = true
L["Other"] = true
L["OUTLINE"] = true
L["Page"] = true
L["Position"] = true
L["Preview"] = true
L["Previous"] = true
L["Profile Settings"] = true
L["Progress"] = true
L["Progress Count"] = true
L["Progress Total"] = true
L["Quantity"] = true
L["Quest Activate"] = true
L["Quest Complete"] = true
L["Quest Failed"] = true
L["Range"] = true
L["Reindex Buttons"] = true
L["Remove Bar"] = true
L["Reset"] = true
L["Reset Character Database"] = true
L["Reverse"] = true
L["Right"] = true
L["RIGHT"] = true
L["Row/Column Direction"] = true
L["Save Order"] = true
L["Save Order Prompt"] = true
L["Scale"] = true
L["Screen"] = true
L["Search"] = true
L["Settings"] = true
L["Shift"] = true
L["Show Empty Buttons"] = true
L["Shopping List"] = true
L["Shopping Lists"] = true
L["Track Completed Objectives"] = true
L["Size Bar to Buttons"] = true
L["Skin"] = true
L["Sound"] = true
L["Sounds"] = true
L["Stack Size"] = true
L["Style Editor"] = true
L["Templates"] = true
L["THICKOUTLINE"] = true
L["Title"] = true
L["Tooltips"] = true
L["Top"] = true
L["TOP"] = true
L["TOPLEFT"] = true
L["TOPRIGHT"] = true
L["Top/Left"] = true
L["Total Maximum"] = true
L["Track Progress"] = true
L["TRUE"] = true
L["Type"] = true
L["Unlocked"] = true
L["Up"] = true
L["Update Button"] = true
L["Visible Buttons"] = true
L["X Offset"] = true
L["Y Offset"] = true
L["Yes"] = true


-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- ABOUT --------------------------------------------------------------------------------------------------------------
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

L._About = function(str)
    local strs = {
        aboutDesc = "Farming Bar is an action bar addon to display and track objective goals. It was inspired by FarmIt (© Chillz) with the goal of improvement and maintenance. Be sure to explore the interface and settings to familiarize yourself with the differences between these addons.",
        differenceHeader = "Why Farming Bar?",
        differenceDesc1 = "Farming Bar offers a user-friendly configuration panel and several new features. Anything that could be done by slash commands can instead be changed with this interface. You may be familiar with some features from FarmIt, but there have been a lot of changes both behind the scenes and up-front. As such, be sure to familiarize yourself with the little quirks that may be different than you're used to.",
        differenceDesc2 = "A few examples of new features that Farming Bar offers are: expanded visual customization, custom objectives, additional shortcuts when clicking buttons and bars, Masque support, and more!",
        whatsNewHeader = "What's new in this version of Farming Bar?",
        whatsNewDesc = "Please see CHANGELOG.md in your addon folder for a thorough list of current changes.",
    }

    return strs[str]
end


-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- BARS ---------------------------------------------------------------------------------------------------------------
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

L._Bars = function(str, var)
    local strs = {
        addBarExecuteDesc = "Creates a new bar.",
        alphaDesc = "Sets the alpha of the bar and its buttons.",
        anchorCountDesc = "Anchor the count text in relation to the button.",
        anchorMouseoverToggleDesc = "Hides the bar's anchor until you hover over it.",
        anchorObjectiveDesc = "Anchor the objective text in relation to the button.",
        buttonPaddingDesc = "Sets the padding between buttons.",
        buttonSizeDesc = "Sets the button size.",
        buttonsPerRowDesc = "Sets the number of buttons per row/column.",
        clearButtonsExecuteDesc = "Removes the items off all buttons on the bar.",
        configAllDesc = "All settings on this page will configure all bars and overwrite any per-bar settings.",
        deleteTemplateSelectConfirm = string.format("Are you sure you want to permanently delete the template \"%s\"?", var or ""),
        deleteTemplateSelectDesc = "Permanently deletes a user-defined template.",
        descDesc = "Sets the name/description for this bar.",
        directionDesc = "Sets the orientation of buttons in relation to the bar's anchor.",
        hiddenToggleDesc = "Hides the bar.",
        loadTemplateSelect1Desc = "Load items from a built-in template onto this bar.",
        loadTemplateSelect2Desc = "Load items from a user-defined template onto this bar.",
        mouseoverToggleDesc = "Hides the bar until you hover over it.",
        movableToggleDesc = "Allows the bar to be moved.",
        muteDesc = "Mutes alerts for this bar.",
        newTemplateInputDesc = "Create a new template of the items on this bar.",
        profileFontDesc = "Per-bar font settings will override profile settings. These settings will only apply to new bars and bars which haven't overriden these fonts. You can change the font for all bars at once on the main Config page.",
        reindexButtonsExecuteDesc = "Reindexes items on the buttons in this bar so that there are no empty bars in between items.",
        removeBarConfirm = string.format("Are you sure you want to permanently remove bar %d?", var or ""),
        removeBarDropDownDesc = "Permanently deletes a bar.",
        removeBarExecuteDesc = "Removes the bar currently being configured.",
        resetCharExecuteConfirm = "Are you sure you want to reset your character database? Doing so will delete all bars and their item settings.",
        resetCharExecuteDesc = "Resets the current character profile to its defaults. This only affects bar settings and objectives.",
        rowDirectionDesc = "Sets the orientation of buttons in rows/columns in relation to previous rows/columns.",
        scaleDesc = "Sets the scale of the bar and its buttons.",
        showEmptiesDesc = "Shows visible buttons that have no items assigned to them.",
        sizeBarExecuteDesc = "Reindexes buttons and sets the number of visible buttons to the number of items on the bar.",
        trackCompletedObjectivesToggleDesc = "Enables farming updates for buttons after its objective has been completed.",
        trackProgressDesc = "Tracks the number of completed objectives on the bar.",
        visibleButtonsDesc = "Sets the number of visible buttons.",
        xOffsetCountDesc = "Adjusts the horizontal offset of the count text.",
        xOffsetObjectiveDesc = "Adjusts the horizontal offset of the objective text.",
        yOffsetCountDesc = "Adjusts the vertical offset of the count text.",
        yOffsetObjectiveDesc = "Adjusts the vertical offset of the objective text.",
    }

    return strs[str]
end


-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- COMMANDS -----------------------------------------------------------------------------------------------------------
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

L._Commands = function(l, group, str, range1, range2)
    local strs = {}

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
    -- [[Localization strings]] --
    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    local args = {
        alphaValue = {"alphaValue", "i"},
        barID = {"barID", "i"},
        barName = {"bar name", "s"},
        bool = {"true||false", "b"},
        buttonGrowth = {"up||down||right||left", "s"},
        buttonSize = {"buttonSize", "i"},
        fontSize = {"fontSize", "i"},
        groupGrowth = {"normal||reverse", "s"},
        groupSize = {"groupSize", "i"},
        movability = {"lock||unlock", "b"},
        mouseoverAnchor = {"bar||anchor", "s"},
        paddingSize = {"paddingSize", "i"},
        scaleValue = {"scaleValue", "i"},
        templateName = {"template name", "s"},
        visibility = {"show||hide", "b"},
        visibleButtons = {"visibleButtons", "i"},
    }

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    if group == "bar" then

        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
        -- [[Localization strings]] --
        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

        local descriptions = {
            add = "Creates a new bar.",
            alpha = "Sets the alpha of the specified bar or all bars and its buttons.",
            buttons = "Sets the number of visible buttons for the specified bar or all bars.",
            empties = "Toggles the show-empty-buttons property for the specified bar or all bars. Use the show/hide arguments to override the toggle behavior.",
            font = "Sets the font size of the text on the specified bar or all bars.",
            groups = "Sets the number of buttons per row/column of the specified bar or all bars.",
            grow = "Changes the orientation of the specified bar or all bars. You must specify both button direction and group (row/column) direction.",
            mouseover = "Toggles the mouseover property for the specified anchor or bar frame, showing it only when the mouse is over it. Use the true/false arguments to override the toggle behavior.",
            movable = "Toggles the movability of the specified bar or all bars. Use the lock/unlock arguments to override the toggle behavior.",
            mute = "Toggles mute for button alerts on the specified bar or all bars.",
            name = "Sets the name/description for the specified bar.",
            padding = "Sets the padding between buttons on the specified bar or all bars.",
            remove = "Permanently deletes the specified bar. Use the true/false arguments to skip confirmation.",
            scale = "Sets the scale of the specified bar or all bars and its buttons.",
            size = "Sets the size of the buttons on the specified bar or all bars.",
            track = "Toggles progress tracking for the specified bar or all bars.",
            visibility = "Toggles the visibility of the specified bar or all bars. Use the show/hide arguments to override the toggle behavior.",
        }

        local examples = {
            add = "/farmingbar bar add\n/farmingbar bar add My New Bar",
            alpha = "/farmingbar bar alpha 1\n/farmingbar bar alpha .75 1",
            buttons = "/farmingbar bar buttons 12\n/farmingbar bar buttons 12 1",
            empties = "/farmingbar bar empties\n/farmingbar bar empties 1\n/farmingbar bar empties 1 hide\n/farmingbar bar empties show",
            font = "/farmingbar bar font 12\n/farmingbar bar font 12 1",
            groups = "/farmingbar bar groups 12\n/farmingbar bar groups 12 1",
            grow = "/farmingbar bar grow up normal\n/farmingbar bar grow left reverse 1",
            mouseover = "/farmingbar bar mouseover bar\n/farmingbar bar mouseover anchor 1\n/farmingbar bar mouseover bar 1 hide\n/farmingbar bar mouseover bar show",
            movable = "/farmingbar bar movable\n/farmingbar bar movable 1\n/farmingbar bar movable unlock",
            mute = "/farmingbar bar mute 1\n/farmingbar bar mute 1 true\n/farmingbar bar mute false",
            name = "/farmingbar bar name 1 I just renamed this bar!",
            padding = "/farmingbar bar padding 2\n/farmingbar bar padding 2 1",
            remove = "/farmingbar bar remove 1\n/farmingbar bar remove 1 true",
            scale = "/farmingbar bar scale .5\n/farmingbar bar scale .5 1",
            size = "/farmingbar bar size 35\n/farmingbar bar size 35 1",
            track = "/farmingbar bar track 1\n/farmingbar bar track 1 true\n/farmingbar bar track false",
            visibility = "/farmingbar bar visibility\n/farmingbar bar visibility 1\n/farmingbar bar visibility 1 hide\n/farmingbar bar visibility show",
        }

        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

        strs.c_addDesc = string.format("%s %s: %s[%s]|r", descriptions.add, l.Args, gold, args.barName[1])
        strs.i_addArgsDesc = string.format("%s: %s[%s]|r(%s)", l.Args, gold, args.barName[1], args.barName[2])
        strs.i_addDesc = descriptions.add
        strs.i_addExDesc = string.format("%s: %s%s|r", l.Example, lightblue, examples.add)

        strs.c_alphaDesc = string.format("%s %s: %s[%s]|r %s[%s]|r", descriptions.alpha, l.Args, red, args.alphaValue[1], gold, args.barID[1])
        strs.i_alphaArgsDesc = string.format("%s: %s[%s]|r(%s) %s[%s]|r(%s)", l.Args, red, args.alphaValue[1], args.alphaValue[2], gold, args.barID[1], args.barID[2])
        strs.i_alphaRangeDesc = string.format("%s: %s%d|r-%s%d|r", l.Range, green, range1, green, range2)
        strs.i_alphaDesc = descriptions.alpha
        strs.i_alphaExDesc = string.format("%s: %s%s|r", l.Example, lightblue, examples.alpha)

        strs.c_buttonsDesc = string.format("%s %s: %s[%s]|r %s[%s]|r", descriptions.buttons, l.Args, red, args.visibleButtons[1], gold, args.barID[1])
        strs.i_buttonsArgsDesc = string.format("%s: %s[%s]|r(%s) %s[%s]|r(%s)", l.Args, red, args.visibleButtons[1], args.visibleButtons[2], gold, args.barID[1], args.barID[2])
        strs.i_buttonsRangeDesc = string.format("%s: %s%d|r-%s%d|r", l.Range, green, range1, green, range2)
        strs.i_buttonsDesc = descriptions.buttons
        strs.i_buttonsExDesc = string.format("%s: %s%s|r", l.Example, lightblue, examples.buttons)

        strs.c_emptiesDesc = string.format("%s %s: %s[%s]|r %s[%s]|r", descriptions.empties, l.Args, gold, args.barID[1], gold, args.visibility[1])
        strs.i_emptiesArgsDesc = string.format("%s: %s[%s]|r(%s) %s[%s]|r(%s)", l.Args, gold, args.barID[1], args.barID[2], gold, args.visibility[1], args.visibility[2])
        strs.i_emptiesDesc = descriptions.empties
        strs.i_emptiesExDesc = string.format("%s: %s%s|r", l.Example, lightblue, examples.empties)

        strs.c_fontDesc = string.format("%s %s: %s[%s]|r %s[%s]|r", descriptions.font, l.Args, red, args.fontSize[1], gold, args.barID[1])
        strs.i_fontArgsDesc = string.format("%s: %s[%s]|r(%s) %s[%s]|r(%s)", l.Args, red, args.fontSize[1], args.fontSize[2], gold, args.barID[1], args.barID[2])
        strs.i_fontRangeDesc = string.format("%s: %s%d|r-%s%d|r", l.Range, green, range1, green, range2)
        strs.i_fontDesc = descriptions.font
        strs.i_fontExDesc = string.format("%s: %s%s|r", l.Example, lightblue, examples.font)

        strs.c_groupsDesc = string.format("%s %s: %s[%s]|r %s[%s]|r", descriptions.groups, l.Args, red, args.groupSize[1], gold, args.barID[1])
        strs.i_groupsArgsDesc = string.format("%s: %s[%s]|r(%s) %s[%s]|r(%s)", l.Args, red, args.groupSize[1], args.groupSize[2], gold, args.barID[1], args.barID[2])
        strs.i_groupsRangeDesc = string.format("%s: %s%d|r-%s%d|r", l.Range, green, range1, green, range2)
        strs.i_groupsDesc = descriptions.groups
        strs.i_groupsExDesc = string.format("%s: %s%s|r", l.Example, lightblue, examples.groups)

        strs.c_growDesc = string.format("%s %s: %s[%s]|r %s[%s]|r %s[%s]|r", descriptions.grow, l.Args, red, args.buttonGrowth[1], red, args.groupGrowth[1], gold, args.barID[1])
        strs.i_growArgsDesc = string.format("%s: %s[%s]|r(%s) %s[%s]|r(%s) %s[%s]|r(%s)", l.Args, red, args.buttonGrowth[1], args.buttonGrowth[2], red, args.groupGrowth[1], args.groupGrowth[2], gold, args.barID[1], args.barID[2])
        strs.i_growRangeDesc = string.format("%s: %s%d|r-%s%d|r", l.Range, green, range1, green, range2)
        strs.i_growDesc = descriptions.grow
        strs.i_growExDesc = string.format("%s: %s%s|r", l.Example, lightblue, examples.grow)

        strs.c_mouseoverDesc = string.format("%s %s: %s[%s]|r %s[%s]|r %s[%s]|r", descriptions.mouseover, l.Args, red, args.mouseoverAnchor[1], gold, args.barID[1], gold, args.bool[1])
        strs.i_mouseoverArgsDesc = string.format("%s: %s[%s]|r(%s) %s[%s]|r(%s) %s[%s]|r(%s)", l.Args, red, args.mouseoverAnchor[1], args.mouseoverAnchor[2], gold, args.barID[1], args.barID[2], gold, args.bool[1], args.bool[2])
        strs.i_mouseoverDesc = descriptions.mouseover
        strs.i_mouseoverExDesc = string.format("%s: %s%s|r", l.Example, lightblue, examples.mouseover)

        strs.c_movableDesc = string.format("%s %s: %s[%s]|r %s[%s]|r", descriptions.movable, l.Args, gold, args.barID[1], gold, args.movability[1])
        strs.i_movableArgsDesc = string.format("%s: %s[%s]|r(%s) %s[%s]|r(%s)", l.Args, gold, args.barID[1], args.barID[2], gold, args.movability[1], args.movability[2])
        strs.i_movableDesc = descriptions.movable
        strs.i_movableExDesc = string.format("%s: %s%s|r", l.Example, lightblue, examples.movable)

        strs.c_muteDesc = string.format("%s %s: %s[%s]|r %s[%s]|r", descriptions.mute, l.Args, gold, args.barID[1], gold, args.bool[1])
        strs.i_muteArgsDesc = string.format("%s: %s[%s]|r(%s) %s[%s]|r(%s)", l.Args, gold, args.barID[1], args.barID[2], gold, args.bool[1], args.bool[2])
        strs.i_muteDesc = descriptions.mute
        strs.i_muteExDesc = string.format("%s: %s%s|r", l.Example, lightblue, examples.mute)

        strs.c_nameDesc = string.format("%s %s: %s[%s]|r %s[%s]|r", descriptions.name, l.Args, red, args.barID[1], gold, args.barName[1])
        strs.i_nameArgsDesc = string.format("%s: %s[%s]|r(%s) %s[%s]|r(%s)", l.Args, red, args.barID[1], args.barID[2], gold, args.barName[1], args.barName[2])
        strs.i_nameDesc = descriptions.name
        strs.i_nameExDesc = string.format("%s: %s%s|r", l.Example, lightblue, examples.name)

        strs.c_paddingDesc = string.format("%s %s: %s[%s]|r %s[%s]|r", descriptions.padding, l.Args, red, args.paddingSize[1], gold, args.barID[1])
        strs.i_paddingArgsDesc = string.format("%s: %s[%s]|r(%s) %s[%s]|r(%s)", l.Args, red, args.paddingSize[1], args.paddingSize[2], gold, args.barID[1], args.barID[2])
        strs.i_paddingRangeDesc = string.format("%s: %s%d|r-%s%d|r", l.Range, green, range1, green, range2)
        strs.i_paddingDesc = descriptions.padding
        strs.i_paddingExDesc = string.format("%s: %s%s|r", l.Example, lightblue, examples.padding)

        strs.c_removeDesc = string.format("%s %s: %s[%s]|r %s[%s]|r", descriptions.remove, l.Args, red, args.barID[1], gold, args.bool[1])
        strs.i_removeArgsDesc = string.format("%s: %s[%s]|r(%s) %s[%s]|r(%s)", l.Args, red, args.barID[1], args.barID[2], gold, args.bool[1], args.bool[2])
        strs.i_removeDesc = descriptions.remove
        strs.i_removeExDesc = string.format("%s: %s%s|r", l.Example, lightblue, examples.remove)

        strs.c_scaleDesc = string.format("%s %s: %s[%s]|r %s[%s]|r", descriptions.scale, l.Args, red, args.scaleValue[1], gold, args.barID[1])
        strs.i_scaleArgsDesc = string.format("%s: %s[%s]|r(%s) %s[%s]|r(%s)", l.Args, red, args.scaleValue[1], args.scaleValue[2], gold, args.barID[1], args.barID[2])
        strs.i_scaleRangeDesc = string.format("%s: %s-%d", l.Range, tostring(range1), range2)
        strs.i_scaleDesc = descriptions.scale
        strs.i_scaleExDesc = string.format("%s: %s%s|r", l.Example, lightblue, examples.scale)

        strs.c_sizeDesc = string.format("%s %s: %s[%s]|r %s[%s]|r", descriptions.size, l.Args, red, args.buttonSize[1], gold, args.barID[1])
        strs.i_sizeArgsDesc = string.format("%s: %s[%s]|r(%s) %s[%s]|r(%s)", l.Args, red, args.buttonSize[1], args.buttonSize[2], gold, args.barID[1], args.barID[2])
        strs.i_sizeRangeDesc = string.format("%s: %s%d|r-%s%d|r", l.Range, green, range1, green, range2)
        strs.i_sizeDesc = descriptions.size
        strs.i_sizeExDesc = string.format("%s: %s%s|r", l.Example, lightblue, examples.size)

        strs.c_trackDesc = string.format("%s %s: %s[%s]|r %s[%s]|r", descriptions.track, l.Args, gold, args.barID[1], gold, args.bool[1])
        strs.i_trackArgsDesc = string.format("%s: %s[%s]|r(%s) %s[%s]|r(%s)", l.Args, gold, args.barID[1], args.barID[2], gold, args.bool[1], args.bool[2])
        strs.i_trackDesc = descriptions.track
        strs.i_trackExDesc = string.format("%s: %s%s|r", l.Example, lightblue, examples.track)

        strs.c_visibilityDesc = string.format("%s %s: %s[%s]|r %s[%s]|r", descriptions.visibility, l.Args, gold, args.barID[1], gold, args.visibility[1])
        strs.i_visibilityArgsDesc = string.format("%s: %s[%s]|r(%s) %s[%s]|r(%s)", l.Args, gold, args.barID[1], args.barID[2], gold, args.visibility[1], args.visibility[2])
        strs.i_visibilityDesc = descriptions.visibility
        strs.i_visibilityExDesc = string.format("%s: %s%s|r", l.Example, lightblue, examples.visibility)

    elseif group == "buttons" then

        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
        -- [[Localization strings]] --
        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

        local descriptions = {
            clear = "Removes the items off all buttons on the specified bar or all bars.",
            reindex = "Reindexes items on the buttons for the specified bar or all bars so that there are no empty bars in between items.",
            size = "Reindexes buttons and sets the number of visible buttons to the number of items on the specified bar or all bars.",
        }

        local examples = {
            clear = "/farmingbar buttons clear\n/farmingbar buttons clear 1",
            reindex = "/farmingbar buttons reindex\n/farmingbar buttons reindex 1",
            size = "/farmingbar buttons size\n/farmingbar buttons size 1",
        }

        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

        strs.c_clearDesc = string.format("%s %s: %s[%s]|r", descriptions.clear, l.Args, gold, args.barID[1])
        strs.i_clearArgsDesc = string.format("%s: %s[%s]|r(%s)", l.Args, gold, args.templateName[1], args.templateName[2])
        strs.i_clearDesc = descriptions.clear
        strs.i_clearExDesc = string.format("%s: %s%s|r", l.Example, lightblue, examples.clear)

        strs.c_reindexDesc = string.format("%s %s: %s[%s]|r", descriptions.reindex, l.Args, gold, args.barID[1])
        strs.i_reindexArgsDesc = string.format("%s: %s[%s]|r(%s)", l.Args, gold, args.barID[1], args.barID[2])
        strs.i_reindexDesc = descriptions.reindex
        strs.i_reindexExDesc = string.format("%s: %s%s|r", l.Example, lightblue, examples.reindex)

        strs.c_sizeDesc = string.format("%s %s: %s[%s]|r", descriptions.size, l.Args, gold, args.barID[1])
        strs.i_sizeArgsDesc = string.format("%s: %s[%s]|r(%s)", l.Args, gold, args.barID[1], args.barID[2])
        strs.i_sizeDesc = descriptions.size
        strs.i_sizeExDesc = string.format("%s: %s%s|r", l.Example, lightblue, examples.size)

    elseif group == "profile" then
        local descriptions = {
            reset = "Resets the current character profile to its defaults. This only affects bar settings and objectives. Use the true/false arguments to skip confirmation.",
        }

        local examples = {
            reset = "/farmingbar profile reset\n/farmingbar profile reset true",
        }

        strs.c_resetDesc = string.format("%s %s: %s[%s]|r", descriptions.reset, l.Args, gold, args.bool[1])
        strs.i_resetArgsDesc = string.format("%s: %s[%s]|r(%s)", l.Args, gold, args.bool[1], args.bool[2])
        strs.i_resetDesc = descriptions.reset
        strs.i_resetExDesc = string.format("%s: %s%s|r", l.Example, lightblue, examples.reset)

    elseif group == "template" then

        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
        -- [[Localization strings]] --
        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

        local descriptions = {
            delete = "Permanently deletes the specified user-defined template.",
            load = "Load items from a user-defined template onto the specified bar. The first true/false argument specifies whether or not to include objective data. The second true/false argument specifies whether or not to save the objective order.",
            save = "Creates a new template of the items on the specified bar.",
        }

        local examples = {
            delete = "/farmingbar template delete My New Template",
            load = "/farmingbar template load 1 true false My New Template",
            save = "/farmingbar template save 1 My New Template",
        }

        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

        strs.c_deleteDesc = string.format("%s %s: %s[%s]|r", descriptions.delete, l.Args, red, args.barID[1])
        strs.i_deleteArgsDesc = string.format("%s: %s[%s]|r(%s)", l.Args, red, args.templateName[1], args.templateName[2])
        strs.i_deleteDesc = descriptions.delete
        strs.i_deleteExDesc = string.format("%s: %s%s|r", l.Example, lightblue, examples.delete)

        strs.c_loadDesc = string.format("%s %s: %s[%s]|r %s[%s]|r %s[%s]|r %s[%s]|r", descriptions.load, l.Args, red, args.barID[1], red, args.bool[1], red, args.bool[1], red, args.templateName[1])
        strs.i_loadArgsDesc = string.format("%s: %s[%s]|r(%s) %s[%s]|r(%s) %s[%s]|r(%s) %s[%s]|r(%s)", l.Args, red, args.barID[1], args.barID[2], red, args.bool[1], args.bool[2], red, args.bool[1], args.bool[2], red, args.templateName[1], args.templateName[2])
        strs.i_loadDesc = descriptions.load
        strs.i_loadExDesc = string.format("%s: %s%s|r", l.Example, lightblue, examples.load)

        strs.c_saveDesc = string.format("%s %s: %s[%s]|r %s[%s]|r", descriptions.save, l.Args, red, args.barID[1], red, args.templateName[1])
        strs.i_saveArgsDesc = string.format("%s: %s[%s]|r(%s) %s[%s]|r(%s)", l.Args, red, args.barID[1], args.barID[2], red, args.templateName[1], args.templateName[2])
        strs.i_saveDesc = descriptions.save
        strs.i_saveExDesc = string.format("%s: %s%s|r", l.Example, lightblue, examples.save)

    else

        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
        -- [[Localization strings]] --
        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

        strs.howToUseDesc = string.format("Farming Bar slash commands can be accessed using the %s/farmingbar|r, %s/farmbar|r, %s/farm|r, %s/fbar|r, and %s/fb|r slash commands. This documentation is sorted by the main arguments and then further broken down (accessible in the menu to the left) by more specific arguments. This is not meant to be an in-depth guide on how to use every command, but feel free to reach out if you feel any specific command needs more explanation.", lightblue, lightblue, lightblue, lightblue, lightblue)

        strs.limitationsHeader = "Limitations"
        strs.limitationsDesc = string.format("Certain slash commands cannot be used in combat as they require either hardware events or protected Blizzard functions to execute. These commands include /farmingbar: %s[bar add]|r, %s[bar buttons]|r, %s[bar group]|r, %s[bar grow]|r, %s[bar padding]|r, %s[bar remove]|r, %s[bar scale]|r, %s[bar size]|r, %s[bar visibility]|r, %s[button size]|r.", lightblue, lightblue, lightblue, lightblue, lightblue, lightblue, lightblue, lightblue, lightblue, lightblue)
        strs.limitationsDesc2 = "Some commands which set or clear objectives during combat may have limited ability until you leave combat. There will be a chat message informing you when item attributes become available upon rest."
        strs.limitationsDesc3 = "There are currently no slash commands implemented for button count text size, anchors and offsets; button objective text size, anchors, and offsets; font face and outlines; or a bar's track completed objectives. These options are either better suited to the GUI or not necessary, but if enough people are interested in having them added, it may happen in the future."

        strs.argsHeader = "Arguments"
        strs.argsDesc = "Arguments are listed in this documentation and denoted by [] square brackets. Following each arg is a letter inside parentheses which indicates the type of the variable: (b)oolean, (i)nteger, (s)string. Arguments colored in red are required and yellow are optional."

        strs.aliasHeader = "Aliases"
        strs.aliasDesc = "Some commands have aliases to shorten the length of the command for convenience/macros. Aliases are listed after the main command in the menu to the left."

        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    end

    return strs[str]
end


-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- HELP ---------------------------------------------------------------------------------------------------------------
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

L._Help = function(l, group, var)
    local strs = {}

    if group == "alertFormats" then
        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
        -- [[Localization strings]] --
        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

        local desc = "There are two alert types available to customize: one that tracks items with an objective goal and one that tracks items without. You can adjust alert formats under the Button Options section of the Alert Formats Settings tab. The preview boxes will show you what your alert will look like in real time. Use the sliders (Objective Preview, New Count Preview, Old Count Preview) to adjust the settings of this preview.\n\nKeep in mind that all variables are case sensitive."

        local variables = "Variables"
        local colors = "Colors"

        local alertFormatsLines = {
            [1 .. variables] = {
                [1] = {"c", "new count"},
                [2] = {"C", "old count"},
                [3] = {"d", "difference between the new and old counts"},
                [4] = {"n", "name of the objective"},
                [5] = {"o", "objective goal"},
                [6] = {"O", "number of times the objective has been met"},
                [7] = {"p", "percentage of the objective complete"},
                [8] = {"r", "number of items required to complete objective"},
                [9] = {"t", "title of an item objective"},
                [10] = {"escapeDesc", "escapes variables"},
            },

            [2 .. colors] = {
                [1] = {"progressColor", "colors the following text green if the objective has been met or yellow if it hasn't"},
                [2] = {"diffColor", "colors the following text green if the difference between the new and old counts is a positive number and red if it's negative"},
                [3] = {"color", "used to close a color variable"},
            },

            [3 .. "Basic Example"] = {
                [1] = {"basicExCode", string.format("%s%s|r", lightblue, "Farming progress: %n (%diffColor%%d%color%)")},
                [2] = {"basicExPreview1", string.format("Farming progress: Zin'anthid (%s+5|r)", green)},
                [3] = {"basicExPreview2", string.format("Farming progress: Zin'anthid (%s-200|r)", red)},
                [4] = {"basicExSpacer4", " "},
                [5] = {"basicExDesc", "In the example above, notice how the difference is wrapped between %diffColor% and %color% to ensure that the coloring stops before the closing parenthesis."},
            },

            [4 .. "If Statements"] = {
                [1] = {"ifsDesc1", string.format("If statements can be used to write different text depending on a condition. The syntax to write an if statement is %s%%if(condition,text,elseText)if%%|r. The only parts of that syntax that should be changed are %scondition|r, %stext|r, and %selseText|r.", lightblue, green, green, green)},
                [2] = {"ifsSpacer2", " "},
                [3] = {"ifsDesc2", string.format("While you're not exactly writing real lua for this if statement, condition will be executed as lua and is subject to any errors as a result. You can use objective information variables within this condition as they will be evaluated first. %stext and elseText are required.|r If you want to leave either of these fields blank, don't type anything, but keep the commas used to separate these arguments.", red)},
            },

            [5 .. "Advanced Example"] = {
                [1] = {"advExCode", string.format("%s%s|r", lightblue, "%if(%p>=100,Objective complete!,)if%%if(%p>100 and %O>1, %Ox!,)if%%if(%p<100,Farming update:,)if% %n (%diffColor%%d%color%), %progressColor%%c/%o%color% (%if(%p>100,100,%p)if%%)%if(%r>0, %r to go,)if%")},
                [2] = {"advExPreview1", string.format("Farming update: Zin'anthid (%s-75|r), %s175/200|r (87%%) 25 to go", red, gold)},
                [3] = {"advExPreview2", string.format("Objective complete! 2x! Zin'anthid (%s+450|r), %s450/200|r (100%%)", green, green)},
                [4] = {"advExSpacer4", " "},
                [5] = {"advExDesc", string.format("%sLet's break the above example down.|r", gold)},
                [6] = {"advExDesc2", "The first if statement checks if %p (percentage of objective complete) is greater than or equal to 100 and if so, adds the text \"Objective complete!\". Notice how this is followed by a comma, no text and then the ending parenthesis and if%. This means that nothing will be printed if the condition isn't true. The purpose of this if statement is only to add text."},
                [7] = {"advExSpacer7", " "},
                [8] = {"advExDesc3", "Following the first if statement is another that checks if %p is greater than 100 and %O (number of times objective has been met) is greater than 1. If this evaluates true, it adds the text \" 2x!\", assuming %O is 2. Note that the space after the comma separating the arguments of the if statement is displayed. Also, just like the previous example, we don't want to display anything if the condition is false."},
                [9] = {"advExSpacer9", " "},
                [10] = {"advExDesc4", "At the end of this starting section, we have an if statement that checks if %p is less than 100. This is basically the else to the previous two if statements. If this evaluates true, it adds the text \"Farming update:\". Again, this particular if statement does not have an else text"},
                [11] = {"advExSpacer11", " "},
                [12] = {"advExDesc5", "Most of the remainder of this example should be familiar if you understand the basic example. You might notice the next if statement actually has an example of the else text being used. In this case, it's checking if %p is greater than 100 and if so, displaying \"100\". If not, it'll display %p. This basically caps the percent at 100 instead of displaying, for example: 150%."},
                [13] = {"advExSpacer13", " "},
            },
        }

        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

        strs.desc = {desc, 1}

        local i = 2
        for heading, lines in U.pairs(alertFormatsLines) do
            heading = heading:gsub("^%d+", "")
            strs["heading" .. i] = {heading, i, true}
            i = i + 1

            for _, line in U.pairs(lines) do
                if heading == variables then
                    strs[line[1]] = {string.format("%s%%%s|r = %s", lightblue, line[1] ~= "escapeDesc" and line[1] or "", line[2]), i}
                elseif heading == colors then
                    strs[line[1]] = {string.format("%s%%%s%%|r = %s", lightblue, line[1], line[2]), i}
                else
                    strs[line[1]] = {line[2], i}
                end
                i = i + 1
            end
        end
    elseif group == "barAlertFormats" then

        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
        -- [[Localization strings]] --
        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

        local desc = "Bar alerts track a bar's progress (e.g. the number of objectives on the bar complete). Formats are edited under the Alert Formats Settings tab in the Bar Options section.  Preview boxes show you what your alert will look like in real time. Use the sliders (Progress Count, Progress Total) to adjust the settings of this preview. Check Bar Has Name to see what an alert will look like when a bar is given a custom name.\n\nKeep in mind that all variables are case sensitive."

        local variables = "Variables"
        local colors = "Colors"

        local alertFormatsLines = {
            [1 .. variables] = {
                [1] = {"b", "bar id"},
                [2] = {"B", "bar id and name"},
                [3] = {"c", "number of completed objectives"},
                [4] = {"n", "bar name"},
                [5] = {"p", "percentage of objectives complete"},
                [8] = {"r", "number of objectives required to complete bar progress"},
                [7] = {"t", "total number of objectives"},
                [8] = {"escapeDesc", "escapes variables"},
            },

            [2 .. colors] = {
                [1] = {"progressColor", "colors the following text green if the objective has been met or yellow if it hasn't"},
                [2] = {"color", "used to close a color variable"},
            },

            [3 .. "Basic Example"] = {
                [1] = {"basicExCode", string.format("%s%s|r", lightblue, "%B progress: %progressColor%%c/%t%color%%if(%p>0, (%p%%),)if%")},
                [2] = {"basicExPreview1", string.format("Bar 1 (My Bar Name) progress: %s100/100|r", green)},
                [3] = {"basicExPreview2", string.format("Bar 1 (My Bar Name) progress: %s0/100|r", gold)},
                [4] = {"basicExSpacer4", " "},
                [5] = {"basicExDesc", "Bar alert formats are written the same way normal alert formats are. Colors are closed with %color% and start with the type (%progressColor% is the only one that exists at the moment) and if statements can be used to customize your alert. Variables for bar alert formats are not the same as normal button alerts."},
            },

            [4 .. "If Statements"] = {
                [1] = {"ifsDesc1", string.format("If statements can be used to write different text depending on a condition. See the Alert Formats Help documentation for more information on how to write if statements.", lightblue, green, green, green)},
            },
        }

        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

        strs.desc = {desc, 1}

        local i = 2
        for heading, lines in U.pairs(alertFormatsLines) do
            heading = heading:gsub("^%d+", "")
            strs["heading" .. i] = {heading, i, true}
            i = i + 1

            for _, line in U.pairs(lines) do
                if heading == variables then
                    strs[line[1]] = {string.format("%s%%%s|r = %s", lightblue, line[1] ~= "escapeDesc" and line[1] or "", line[2]), i}
                elseif heading == colors then
                    strs[line[1]] = {string.format("%s%%%s%%|r = %s", lightblue, line[1], line[2]), i}
                else
                    strs[line[1]] = {line[2], i}
                end
                i = i + 1
            end
        end
    elseif group == "base" then
        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
        -- [[Localization strings]] --
        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

        local desc = "If you need any assistance or have any suggestions/requests, please open a ticket at: https://github.com/niketa-wow/farming-bar/issues"
        local desc1 = "Other comments are welcomed on Curse (Twitch) and WoW Interface."

        local baseLines = {
            [1 .. "Contact"] = {
                [1] = {"contactDesc1", string.format("%sDiscord:|r Niketa#1247", lightblue)},
                [2] = {"contactDesc2", string.format("%sBattle.net:|r Niketa#1952", lightblue)},
                [3] = {"contactDesc3", string.format("%sCurse/WoW Interface:|r Niketa", lightblue)},
                [4] = {"spacer7", " "},
                [5] = {"contactDesc4", string.format("%sGitHub:|r https://github.com/niketa-wow", lightblue)},
            },

            [2 .. "Down the Road"] = {
                [1] = {"dtrDesc1", "Disclaimer: this section is meant to give you an idea of things I am interested in implementing but have not started actively working on. As such, there is no confirmed time frame for when these features may be released."},
                [2] = {"spacer11", " "},
                [3] = {"dtrDesc2", string.format("%sMixed shopping lists:|r more complex shopping lists that behave like a mixed items list, but for shopping lists instead of individual items. An example of use is if you wanted track the mats to make 10 enchants, but they could be different enchants.", lightblue)},
                [4] = {"spacer13", " "},
                [5] = {"dtrDesc3", string.format("%sCustom skins:|r create custom skins to use instead of the built-in default and minimal skins.", lightblue)},
                [6] = {"spacer15", " "},
                [7] = {"dtrDesc4", string.format("%sTrack items across all toons:|r add support to track your objective using mats across all toons.", lightblue)},
                [8] = {"spacer17", " "},
                [9] = {"dtrDesc5", string.format("%sCustomizable keybinds:|r change the keybinds used on bars/buttons (e.g. setting objective, moving the item, etc). Right click for use and left click for move will not be changeable.", lightblue)},
                [10] = {"spacer18", " "},
                [11] = {"dtrDesc6", string.format("%sObjective conditions:|r set up custom objective trackers based on certain conditions. Examples may include zone or math objectives (such as count is divisible by 5).", lightblue)},
                [12] = {"spacer19", " "},
            },
        }

        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

        strs.desc = {desc, 1}
        strs.desc = {desc, 2}

        i = 3
        for heading, lines in U.pairs(baseLines) do
            heading = heading:gsub("^%d+", "")
            strs["heading" .. i] = {heading, i, true}
            i = i + 1

            for _, line in U.pairs(lines) do
                strs[line[1]] = {line[2], i}
                i = i + 1
            end
        end
    elseif group == "bars" then
        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
        -- [[Localization strings]] --
        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
        local desc = string.format("Bars are the containers for groups of buttons. While each bar has a limit of %d buttons, you can add an unlimited number of bars. If enabled, bar tooltips will give you information about each bar and tips for shortcuts that you can use on the bar's anchor.", var)

        local barsLines = {
            [1 .. "Bar Anchor Shortcuts"] = {
                [1] = {"shortcutDesc1", string.format("%sClick and drag|r moves the bar.", lightblue)},
                [2] = {"shortcutDesc2", string.format("%sCtrl+click|r opens the options frame to the Settings page.", lightblue)},
                [3] = {"shortcutDesc3", string.format("%sShift+click|r toggle's the bar's movability to lock or unlock the bar.", lightblue)},
                [4] = {"shortcutSpacer4", " "},
                [5] = {"shortcutDesc4", string.format("%sRight-click|r opens the options frame to the Help page.", lightblue)},
                [6] = {"shortcutDesc5", string.format("%sCtrl+right-click|r opens an editbox which allows you to enter a button ID to open up in the Objective Builder. This can be helpful if you have the show-empties property disabled.", lightblue)},
                [7] = {"shortcutDesc6", string.format("%sShift+right-click|r opens the options frame to the configuration page for the bar whose anchor you clicked.", lightblue)},
                [8] = {"shortcutSpacer8", " "},
                [9] = {"shortcutDesc7", "You can remove these tips from the bar's anchor tooltip by disabling the Bar Tips option under Settings."},
            },

            [2 .. "How can I configure bars?"] = {
                [1] = {"configDesc1", "Bars can be configured in a variety of ways and can be given a name or description to make them easier to identify. These names will be displayed in your bars' tooltips."},
                [2] = {"configSpacer2", " "},
                [3] = {"configDesc2", "In addition to changing a bar's movability, you can set it to hidden and even mouseover if you want to hide it until you hover over it. One thing to note is that anchor mouseover will only hide the anchor unless you hover over it. This can be helpful if you want your bar to look more like a normal action bar."},
                [4] = {"configSpacer4", " "},
                [5] = {"configDesc3", "The show-empties property will show a background texture and allow mouse events when enabled but be hidden when disabled. When hidden, empty buttons cannot accept any mouse actions unless there's an item on your cursor. Alternatively, if you need track an objective on a hidden button, you can access the Objective Builder by ctrl+right-clicking the bar's anchor and entering the button ID."},
                [6] = {"configSpacer6", " "},
                [7] = {"configDesc4", "In addition to setting the number of visible buttons, you can set the amount of buttons are displayed on each row/column. Bar button direction controls the direction that buttons grow out of the anchor and row/column direction controls the direction each new row or column grows. By default, row/column direction is set to normal (bottom/right)."},
                [8] = {"configSpacer8", " "},
                [9] = {"configDesc5", "You can adjust how your bar looks by changing the font, scale, alpha, button size, and button padding."},
            },

            [3 .. "Can I configure all bars at once?"] = {
                [1] = {"configAllDesc1", "Yes! In the options frame, click on the main Bars section and you'll find all options that configure every bar. Additionally, when you use commands to configure your bar, by default all bars will be configured and you must specify a barID to change only one."},
            },
        }


        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

        strs.desc = {desc, 1}

        i = 2
        for heading, lines in U.pairs(barsLines) do
            heading = heading:gsub("^%d+", "")
            strs["heading" .. i] = {heading, i, true}
            i = i + 1

            for _, line in U.pairs(lines) do
                strs[line[1]] = {line[2], i}
                i = i + 1
            end
        end
    elseif group == "buttons" then
        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
        -- [[Localization strings]] --
        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
        local desc = string.format("Buttons are the frames that are used to track each individual objective. Each bar can hold %d buttons.", var)

        local buttonsLines = {
            [1 .. "What are the button anchor shortcuts?"] = {
                [1] = {"shortcutDesc1", string.format("%sClick|r selects an objective to move.", lightblue)},
                [2] = {"shortcutDesc2", string.format("%sAlt+click|r toggles bank inclusion.", lightblue)},
                [3] = {"shortcutDesc3", string.format("%sCtrl+click|r opens an editbox which allows you to enter an objective goal.", lightblue)},
                [4] = {"shortcutDesc4", string.format("%sShift+drag|r to move an item. This only works on items and not other objective types.", lightblue)},
                [5] = {"shortcutSpacer5", " "},
                [6] = {"shortcutDesc5", string.format("%sRight-click|r to use an item. On other objective types, nothing happens.", lightblue)},
                [7] = {"shortcutDesc6", string.format("%sAlt+right-click|r at the bank to move this item from your bank to your bags until your objective goal is met.", lightblue)},
                [8] = {"shortcutDesc7", string.format("%sCtrl+alt+right-click|r at the bank to move all of this item from your bank to your bags.", lightblue)},
                [9] = {"shortcutDesc8", string.format("%sShift+alt+right-click|r at the bank to move all of this item from your bags to your bank.", lightblue)},
                [10] = {"shortcutDesc9", string.format("%sCtrl+right-click|r opens the Objective Builder for this button.", lightblue)},
                [11] = {"shortcutDesc10", string.format("%sShift+right-click|r clears the objective.", lightblue)},
                [12] = {"shortcutSpacer11", " "},
                [13] = {"shortcutDesc11", "You can remove these tips from the button tooltips by disabling the Button Tips option under Settings."},
            },

            [2 .. "How can I configure buttons?"] = {
                [1] = {"configDesc1", "You can change your button's general look by adjusting the button size and padding in its bar's configuration page or changing your profile skin under Settings. While configurations made in the bar section are character only changes, any button settings under Settings are profile specific."},
                [2] = {"configSpacer2", " "},
                [3] = {"configDesc2", "You can adjust the size and position of the count text and objective text from the Buttons tab in its bar's configuration. Additionally, from the Profile Settings, you can change the color of the count to represent the item quality, bank inclusion status, or a custom color."},
                [4] = {"configSpacer4", " "},
                [5] = {"configDesc3", "You may also enable a border around buttons to indicate the item quality and even hide the default bank overlay border (four-point golden border). This, in addition to the count color support, allows you to customize your buttons in even more ways without worrying about this border clashing with your button."},
            },

            [3 .. "Is Masque supported?"] = {
                [1] = {"masqueDesc1", "Yes! It's now a lot easier to customize buttons to suit your UI better. Additionally, the ability to hide the default bank inclusion border and move your text makes it easier to work with most Masque skins."},
            },
        }


        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

        strs.desc = {desc, 1}

        i = 2
        for heading, lines in U.pairs(buttonsLines) do
            heading = heading:gsub("^%d+", "")
            strs["heading" .. i] = {heading, i, true}
            i = i + 1

            for _, line in U.pairs(lines) do
                strs[line[1]] = {line[2], i}
                i = i + 1
            end
        end
    elseif group == "mixedItems" then
        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
        -- [[Localization strings]] --
        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

        local desc = "Mixed items allow you to track a combination of items as one objective."

        local mixedItemsLines = {
            [1 .. "How to create a mixed items objective"] = {
                [1] = {"creationDesc1", "To create a mixed items objective, first open the Objective Builder by ctrl+right-clicking the button you want to track it on. Alternatively, you can ctrl+right-click the bar's anchor and enter a button ID to open the builder. From the dropdown at the top, select Mixed Items."},
                [2] = {"creationSpacer2", " "},
                [3] = {"creationDesc2", "First, give your mixed items objective a title. You can choose an icon, but the default question mark icon will be used if you don't. If you want to manually enter an icon, you must use either the file ID (ex: 134400) or the full file path (ex: interface/icons/inv_misc_questionmark)."},
                [4] = {"creationSpacer4", " "},
                [5] = {"creationDesc3", "Add the total amount you want to track to the Quantity field. Finally, you can add your items. To add an item, type the item ID or item name into the Add Item field and hit enter (or press okay). If the item is valid, it will be added to the list and displayed in the items list."},
                [6] = {"creationSpacer6", " "},
                [7] = {"creationDesc4", "Keep in mind that if you haven't cached the item and it's not in your inventory, you will have to use the item ID. You can add as many items as you want, but you need at least 2."},
                [8] = {"creationSpacer8", " "},
                [9] = {"creationDesc5", "When you've finished adding items, click Update Button and your mixed items objective will be created!"},
            },
            [2 .. "Example"] = {
                [1] = {"exDesc1", "Let's pretend you are leveling Jewelcrafting and your guide tells you to craft 40 epic gems."},
                [2] = {"exSpacer2", " "},
                [3] = {"exDesc2", "Create a mixed items objective and give it any name and icon. Set your quantity to 40 and then add the uncut gems to the items list. For this example, we'll add: Lava Lazuli, Sand Spinel, Sea Currant, and Dark Opal."},
                [4] = {"exSpacer4", " "},
                [5] = {"exDesc3", "When you have a total of 40 between any of the four gems, your mixed items objective will be complete. For example, you may have: 26 Lava Lazuli, 3 Sand Spinel, 0 Sea Currant, and 15 Dark Opal. Your objective will be marked complete with 44/40 items. Note that you don't need to have 40 of each item; if you want at least 40 of each gem, use a shopping list."},
            },
        }


        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

        strs.desc = {desc, 1}

        i = 2
        for heading, lines in U.pairs(mixedItemsLines) do
            heading = heading:gsub("^%d+", "")
            strs["heading" .. i] = {heading, i, true}
            i = i + 1

            for _, line in U.pairs(lines) do
                strs[line[1]] = {line[2], i}
                i = i + 1
            end
        end
    elseif group == "objectiveBuilder" then
        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
        -- [[Localization strings]] --
        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
        local desc = "The Objective Builder allows you to create complex objectives "

        local buttonsLines = {
            [1 .. "Do I have to use the Objective Builder?"] = {
                [1] = {"requiredDesc1", "While the Objective Builder lets you customize your farming objective in various ways, sometimes you need to track something simple and fast. You can drag and drop (or pickup) an item from your inventory and place it on a button to quickly track it. Additionally, if you know the item ID or currency ID that you want to track, you can use the following shortcuts to get started quicker."},
                [2] = {"requiredSpacer2", " "},
                [3] = {"requiredDesc2", string.format("%sCtrl+shift+click|r a button to quickly enter a currency ID.", lightblue)},
                [4] = {"requiredDesc3", string.format("%sCtrl+shift+right-click|r a button to quickly enter an item ID.", lightblue)},
            },

            [2 .. "What shortcuts make it faster to add objectives?"] = {
                [1] = {"shortcutDesc1", string.format("%sPressing enter within most editboxes|r will change focus to the next editbox.", lightblue)},
                [2] = {"shortcutDesc2", string.format("%sPressing shift+enter within an any editbox|r (except the first) will change focus to the previous editbox.", lightblue)},
                [3] = {"shortcutSpacer3", " "},
                [4] = {"shortcutDesc4", string.format("%sPressing ctrl+enter within any Currency or Item editbox|r will finalize and create the objective.", lightblue)},
                [5] = {"shortcutSpacer5", " "},
                [6] = {"shortcutDesc6", string.format("%sPressing ctrl+enter within an Icon editbox|r will open the Icon Selector and focus the search bar.", lightblue)},
                [7] = {"shortcutDesc7", string.format("%sPressing ctrl+enter within the Icon Selector Search editbox|r will select and apply the currently focused icon.", lightblue)},
                [8] = {"shortcutSpacer8", " "},
                [9] = {"shortcutDesc9", string.format("%sPressing enter within an Add Item editbox|r will validate and add the item to the pending list.", lightblue)},
                [10] = {"shortcutDesc10", string.format("%sPressing ctrl+enter within an Add Item editbox|r will validate and add the item to the pending list and then finalize and create the objective.", lightblue)},
                [11] = {"shortcutSpacer11", " "},
            },
        }


        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

        strs.desc = {desc, 1}

        i = 2
        for heading, lines in U.pairs(buttonsLines) do
            heading = heading:gsub("^%d+", "")
            strs["heading" .. i] = {heading, i, true}
            i = i + 1

            for _, line in U.pairs(lines) do
                strs[line[1]] = {line[2], i}
                i = i + 1
            end
        end
    elseif group == "shoppingLists" then
        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
        -- [[Localization strings]] --
        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

        local desc = "Shopping lists allow you to track multiple items with their own objectives as one objective. This can be helpful for crafting as you can track each reagent required as one objective that is only met when you have all of the reagents."

        local shoppingListsLines = {
            [1 .. "How to create a shopping list"] = {
                [1] = {"creationDesc1", "To create a shopping list, first open the Objective Builder by ctrl+right-clicking the button you want to track it on. Alternatively, you can ctrl+right-click the bar's anchor and enter a button ID to open the builder. From the dropdown at the top, select Shopping List."},
                [2] = {"creationSpacer2", " "},
                [3] = {"creationDesc2", "First, give your shopping list a title. You can choose an icon, but the default question mark icon will be used if you don't. If you want to manually enter an icon, you must use either the file ID (ex: 134400) or the full file path (ex: interface/icons/inv_misc_questionmark)."},
                [4] = {"creationSpacer4", " "},
                [5] = {"creationDesc3", "To add an item, first type the objective amount for the item into the Quantity field. Then type the item ID or item name into the Add Item field and hit enter (or press okay). If the item is valid, it will be added to the list and displayed in the items list."},
                [6] = {"creationSpacer6", " "},
                [7] = {"creationDesc4", "Keep in mind that if you haven't cached the item and it's not in your inventory, you will have to use the item ID. You can add as many items as you want, but you need at least 2."},
                [8] = {"creationSpacer8", " "},
                [9] = {"creationDesc5", "When you've finished adding items, click Update Button and your shopping list will be created!"},
            },
            [2 .. "Example"] = {
                [1] = {"exDesc1", "Say you want a shopping list that alerts you when you can craft Drums of the Maelstrom. The reagents required are 25x Coarse Leather and 10x Blood-Stained Bone."},
                [2] = {"exSpacer2", " "},
                [3] = {"exDesc2", "Create a shopping list and give it any name and icon. Add 25 Coarse Leather and 10 Blood-Stained Bone to the item list."},
                [4] = {"exSpacer4", " "},
                [5] = {"exDesc3", "When you have enough leather AND bones to craft the drums, your shopping list will be marked as complete. Unlike mixed items lists, each individual item objective must be met before the shopping list will be completed. On your button, the objective will be displayed as the sum of all item objectives."},
            },
        }


        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

        strs.desc = {desc, 1}

        i = 2
        for heading, lines in U.pairs(shoppingListsLines) do
            heading = heading:gsub("^%d+", "")
            strs["heading" .. i] = {heading, i, true}
            i = i + 1

            for _, line in U.pairs(lines) do
                strs[line[1]] = {line[2], i}
                i = i + 1
            end
        end
    elseif group == "templates" then
        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
        -- [[Localization strings]] --
        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
        local desc = string.format("Templates allow you to create sets of objectives to reuse on multiple bars or characters. There are a number of built-in templates available but if you have a suggestion for additional templates, please contact me via one of the channels listed on the Help page.", var)

        local templatesLines = {
            [1 .. "How to use templates"] = {
                [1] = {"createDesc1", "There are two ways to use templates: via slash commands or the bars' configuration pages. For information about template slash commands, reference Commands."},
                [2] = {"createSpacer2", " "},
                [3] = {"createDesc2", "Templates can be found on each individual bar's configuration page under the Buttons tab. You can create a new template from the objectives on the bar, but only the objectives on the this bar will be saved. You cannot save multiple bars as a single template."},
                [4] = {"createSpacer4", " "},
                [5] = {"createDesc3", "Loading a template will remove all objectives on the current bar and load the template objectives. If there are more template objectives than visible buttons, the number of buttons shown will be automatically adjusted. Objective information is not saved in a template unless it's a mixed items objective or shopping list. However, even for those, the include bank flag is not saved."},
            },
        }


        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

        strs.desc = {desc, 1}

        i = 2
        for heading, lines in U.pairs(templatesLines) do
            heading = heading:gsub("^%d+", "")
            strs["heading" .. i] = {heading, i, true}
            i = i + 1

            for _, line in U.pairs(lines) do
                strs[line[1]] = {line[2], i}
                i = i + 1
            end
        end
    end

    return strs
end


-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- ITEM MOVER ---------------------------------------------------------------------------------------------------------
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

L._ItemMover = function(str, var1, var2)
    var1 = var1 and var1 or ""
    var2 = var2 and var2 or ""

    local strs = {
        bankNotOpen = "Bank closed before move completed.",
        itemMoveFailed = string.format("%s could not be moved.", var1),
        moveStarted = string.format("Moving %s%s... Do not close the bank frame.", var2, var1 == "items" and " items" or ""),
        moveFailed = string.format("Move failed: %s", var1),
        moveSuccessful = "Move completed successfully.",
    }

    return strs[str]
end


-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- OBJECTIVE BUILDER --------------------------------------------------------------------------------------------------
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

L._ObjectiveBuilder = function(str)
    local strs = {
        currencyDesc = "To track a currency, select it from the dropdown list then click Update Button. If you can't find the currency you are looking for in the menu, you can add it manually by the currency ID.",
        editboxTips = "Pressing enter from any editbox will move to the next editbox while shift+enter moves to the previous. Ctrl+enter will open the icon selector from the icon editbox and update the button from the add item editbox.",
        editItem = "Left click an item to edit its objective.",
        itemDesc = "To track an item, type the name or item ID into the editbox then click Update Button. Keep in mind that you can only add an item by name if it has already been cached or you have it in your inventory.",
        mixedItemsDesc = "Mixed Items objectives track any combination of multiple items to add up to one total objective. You can add items by item name or ID, but if the item hasn't already been cached and you don't have any in your bank or bags, you must use the item ID.",
        removeItem = "Right click an item to remove it from the list.",
        shoppingListDesc = "Shopping List objectives track multiple item objectives as an overall objective. Shopping lists will not complete until each item's individual objective is met. You can add items by item name or ID, but if the item hasn't already been cached and you don't have any in your bank or bags, you must use the item ID.",
        title = "Farming Bar Objective Builder",
    }

    return strs[str]
end


-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- SETTINGS -----------------------------------------------------------------------------------------------------------
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

L._Settings = function(str, var1)
    var1 = var1 and var1 or ""

    local strs = {
        AutoCastableDesc = "Enables the four-point gold border indicating bank inclusion.",
        autoLootItemsOtherDesc = "Temporarily enables auto looting when using an item on a button.",
        barChatToggleDesc = "Enables bar progress chat alerts.",
        barCountPreviewRangeDesc = "Sets the count of objectives complete for the bar alert format preview.",
        barProgressInputDesc = "Sets the format for bar progress alerts.",
        barScreenToggleDesc = "Enables bar progress screen alerts.",
        barSoundToggleDesc = "Enables bar progress sound alerts.",
        barTitlePreviewToggleDesc = "Enables a sample bar name/desc for the bar alert format preview.",
        barTotalPreviewRangeDesc = "Sets the total number of objectives for the bar alert format preview.",
        barTipTooltipDesc = "Displays shortcut tips at the bottom of bars' tooltips.",
        barTooltipDesc = "Enables bar tooltips.",
        BorderDesc = "Enables the item quality glow.",
        buttonTipTooltipDesc = "Displays shortcut tips at the bottom of buttons' tooltips.",
        buttonTooltipDesc = "Enables button tooltips.",
        chatToggleDesc = "Enables chat alerts.",
        commandsDescDesc = "Enable or disable command aliases in case of conflicts with other addons.",
        commandsToggleDesc = string.format("Enables the command alias /%s.", var1),
        CooldownDesc = "Enables the item cooldown swipe.",
        CooldownEdgeDesc = "Enables the bling on the edge of item cooldown swipes.",
        countColorDropDownDesc = "Changes the color of buttons' count text.",
        enableModTooltipDesc = "Enables the ability to toggle tooltip tips with a modifier key.",
        faceDesc = "Sets the font face for button text.",
        farmingProgressDesc = "Sets the sound that plays when you progress toward your objective goal.",
        hasObjectiveInputDesc = "Sets the format of alerts when a objective goal is set.",
        helpBarExecuteDesc = "View help documentation for bar alert formats.",
        helpExecuteDesc = "View help documentation for alert formats.",
        includeDataTemplatesDesc = "Include objective data when loading user-defined templates.",
        includeDataPromptTemplatesDesc = "Prompt to decide whether to include objective data each time a user-defined template is loaded.",
        masqueToggleDesc = "Lets Masque control skins for bars/buttons.",
        masqueToggleName = "Enable Masque",
        modTooltipDesc = "Sets the modifier key to be used to toggle tips on tooltips.",
        newCountPreviewRangeDesc = "Sets the new count for the button alert format preview.",
        noObjectiveInputDesc = "Sets the format of alerts when no objective goal is set.",
        objectiveClearedDesc = "Sets the sound that plays when you cancel a objective goal.",
        objectiveCompleteDesc = "Sets the sound that plays when you complete a objective goal.",
        objectivePreviewRangeDesc = "Sets an objective for the button alert format preview.",
        objectiveSetDesc = "Sets the sound that plays when you set a objective goal.",
        oldCountPreviewRangeDesc = "Sets the old count for the button alert format preview.",
        outlineDesc = "Sets the font outline for button text.",
        resetBarProgressDesc = "Resets the alert format for Bar Progress.",
        resetBarProgressConfirm = "Are you sure you want to reset Bar Progress to the default alert format?",
        resetHasObjectiveDesc = "Resets the alert format for Has Objective to the default.",
        resetHasObjectiveConfirm = "Are you sure you want to reset Has Objective to the default alert format?",
        resetNoObjectiveDesc = "Resets the alert format for No Objective to the default.",
        resetNoObjectiveConfirm = "Are you sure you want to reset No Objective to the default alert format?",
        sampleBarTitle = "My Bar Name",
        saveOrderTemplatesDesc = "Save objective order when loading user-defined templates.",
        saveOrderPromptTemplatesDesc = "Prompt to decide whether to save objective order each time a user-defined template is loaded.",
        screenToggleDesc = "Enables screen alerts.",
        skinDropDownDesc = "Sets the built-in skin for bars/buttons.",
        soundToggleDesc = "Enables sound alerts.",
    }

    return strs[str]
end


-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- SETTINGS -----------------------------------------------------------------------------------------------------------
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

L._StaticPopups = function(str)
    local strs = {
        confirmOverwriteTemplate = "Farming Bar: Template \"%s\" already exists. Do you want to overwrite this template?",
        includeTemplateData = "Farming Bar: Do you want to include objective data while loading template \"%s\"?",
        saveTemplateOrder = "Farming Bar: Do you want to save the objective order while loading template \"%s\"?",
    }

    return strs[str]
end


-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- TOOLTIPS -----------------------------------------------------------------------------------------------------------
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

L._Tooltips = function(id, str)
    local strs = {}

    if id == "bar" then
        strs[1] = "Click and drag to move the bar."
        strs[2] = "Ctrl+click to open settings."
        strs[3] = "Shift+click to lock or unlock the bar."
        strs[4] = "Right-click to open the help page."
        strs[5] = "Ctrl+right-click to specify a button ID\nto configure in the Objective Builder."
        strs[6] = "Shift+right-click to configure this bar."
    elseif id == "button" then
        strs[1] = "Click to select/move an objective."
        strs[2] = "Alt+click toggles bank inclusion."
        strs[3] = "Ctrl+click to set a objective goal."
        strs[4] = "Shift+drag to move an item."

        strs[5] = "Right-click to use the item."
        strs[6] = "Alt-right-click at the bank to move\nthis item to your bags up to your objective."
        strs[7] = "Ctrl+alt+right-click at the bank to move\nall of this item to your bags."
        strs[8] = "Shift+alt+right-click at the bank to move\nall of this item to the bank."

        strs[9] = "Ctrl+right-click to open the Objective Builder."
        strs[10] = "Ctrl+shift+click to enter a currency ID."
        strs[11] = "Ctrl+shift+right-click to enter an item ID."

        strs[12] = "Shift+right-click clears the slot."
        strs[13] = "Pickup and place (or drag and drop) an item\nonto this button to track it."
    elseif id == "broker" then
        strs[1] = string.format("%sClick|r to toggle settings.", lightblue)
        strs[2] = string.format("%sRight-click|r to configure bars.", lightblue)
        strs[3] = string.format("%sAlt+right-click|r to toggle mouseovers.", lightblue)
        strs[4] = string.format("%sAlt+ctrl+right-click|r to toggle anchor mouseovers.", lightblue)
        strs[5] = string.format("%sCtrl+right-click|r to toggle visibility.", lightblue)
        strs[6] = string.format("%sShift+right-click|r to toggle movability.", lightblue)
    end

    return strs[str]
end


-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- MISCELLANEOUS -------------------------------------------------------------------------------------------------------
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

L.BarMovableChanged = function(barID, movable)
    if barID then
        if movable == "_toggle" then
            return string.format("Bar %s's movability toggled.", barID)
        else
            return string.format("Bar %s %s.", barID, movable and "unlocked" or "locked")
        end
    elseif movable == "_toggle" then
        return "All bars' movability toggled."
    else
        return string.format("All bars %s.", movable and "unlocked" or "locked")
    end
end

L.BarTrackingChanged = function(barID, tracking)
    if barID then
        if tracking == "_toggle" then
            return string.format("Bar %s's tracking toggled.", barID)
        else
            return string.format("Bar %s %s.", barID, tracking and "tracking progress" or "no longer tracking progress")
        end
    elseif tracking == "_toggle" then
        return "All bars' tracking toggled."
    else
        return string.format("All bars %s.", tracking and "tracking progress" or "no longer tracking progress")
    end
end

L.ButtonAttributesAccessible = function(barID, buttonID)
    return string.format("Updated button right+click attributes are now accessible for button %d:%d.", barID, buttonID)
end

L.FarmingObjectiveSet = function(objective, item)
    if not objective or objective == 0 then
        return "Farming objective cleared."
    elseif objective and item then
        return string.format("Farming objective set: %s %s", U.iformat(objective, 2), item)
    end
end

L.GetBarIDString = function(barID)
    return string.format("Bar %d", barID)
end

L.GetErrorMessage = function(str, var1, var2)
    var1 = var1 and var1 or ""
    var2 = var2 and var2 or ""

    local strs = {
        invalidAlpha = string.format("Alpha must be an integer between %d and %d.", var1, var2),
        invalidBarID = "Invalid barID.",
        invalidBarNameArgs = "You must provide a valid barID and title for your bar.",
        invalidButtonDirection = "Invalid button direction.",
        invalidButtonPadding = string.format("Button padding must be an integer between %d and %d.", var1, var2),
        invalidButtonSize = string.format("Button size must be an integer between %d and %d.", var1, var2),
        invalidCountDifference = "Error: new count cannot be the same as old count.",
        invalidCurrency = string.format("Invalid currency: %s", var1),
        invalidFontSize = string.format("Font size must be an integer between %d and %d.", var1, var2),
        invalidGroupDirection = "Invalid row/column direction.",
        invalidGroupSize = string.format("Group size (buttons per row) must be an integer between %d and %d.", var1, var2),
        invalidIncludeData = "Missing include data boolean (true/false).",
        invalidItemID = string.format("Invalid item: %s", var1),
        invalidListQuantity = "Mixed Items and Shopping List objectives require at least 2 items.",
        invalidMouseoverFrame = "Mouseover frame must be specified as either bar or anchor.",
        invalidObjectiveQuantity = "Objective quantity must be greater than 0.",
        invalidObjectiveTitle = "Please provide a title for your Mixed Items objective.",
        invalidProgressDifference = "Error: progress count cannot be greater than progress total.",
        invalidSaveOrder = "Missing save order boolean (true/false).",
        invalidScale = string.format("Scale must be an integer between %s and %s.", tostring(var1), tostring(var2)),
        invalidTemplate = "Invalid or missing template name.",
        invalidTemplateName = string.format("Template named \"%s\" doesn't exist.", var1),
        invalidVisibleButtons = string.format("Visible buttons must be an integer between %d and %d.", var1, var2),
        missingTemplateName = "You must provide a title for your template.",
    }

    return strs[str]
end

L.IncludeBankChanged = function(barID, buttonID, includeBank)
    return string.format("Bar %d button %d bank inclusion %s.", barID, buttonID, includeBank and "enabled" or "disabled")
end

L.TemplateDeleted = function(templateName)
    return string.format("Template \"%s\" deleted.", templateName)
end

L.TemplateSaved = function(barID, templateName)
    return string.format("All items on bar %d saved as farming template: %s", barID, templateName)
end

L.UsingItem = function(itemID)
    return string.format("Using %s", select(2, GetItemInfo(itemID)))
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

L.CombatWarning = "Button right+click attributes cannot be changed during combat and will not correspond with the correct item until combat ends."
L.CommandCombatError = "This command cannot be executed during combat. Please try again when you are no longer in combat."
L.MasqueUpgrade = "Please upgrade to the latest version of Masque."
L.OptionsCombatWarning = "Options will open after combat ends."