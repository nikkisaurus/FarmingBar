# Farming Bar

## Version 3.0

### 3.0-alpha19

- Options have been rearranged
- Implemented icon selector
- Implemented bar duplication
- Implemented configuration for all bars
- Reinstated the "/craft" command for objective actions
  - -- Designated recipe action is no longer planned because it would make it more difficult to add vellums to the script
  - -- Create your action as a macrotext using "/craft ProfessionName Recipe Name"
  - -- Don't forget to add vellums or other items you need to target during crafting:
  - -- -- /craft Enchanting Shadowlands Gathering
  - -- -- /use Enchanting Vellum
- Bug fixes:
  - -- Duplicating an objective now opens the config for the new objective
  - -- Fixed error from misplaced packager tag for classic
  - -- Loading an objective onto the cursor now clears items or spells on the previously on the cursor

### 3.0-alpha18

- Implemented remaining alert settings
- Implemented objective quick add buttons in the Objective Builder
- Implemented objective duplication
- Implemented objective import and export
- Configurations have been rearranged
- Added configuration for bar backdrop
- Option added to use GameTooltip instead of FarmingBar_Tooltip
- Merged hideObjectiveInfo with hint enableModifier into tooltip condensedTooltip
- Implemented option to create objective from a button item
- You can now open the objective editor from an empty button to link an objective template
- Implemented auto loot on use
- Implemented keybind configurations
- Implemented bar custom hide function
- To compensate for BCC's lack of a GLOBAL_MOUSE_DOWN event, clicking a bar's anchor or an icon dropper in the objective builder now clears objectives from the mouse
  - -- Retail will continue to be cleared by right clicking in addition to clicking a bar's anchor
- Bug fixes:
  - -- Fixed bug where bar was movable with the wrong button click
  - -- Fixed lua error when configuring bars after changing profiles
  - -- Fixed bar alerts so that progress is announced when objectives change
  - -- Disabled "Copy From" in bar configuration when only one bar exists
  - -- Objectives now properly clear when deleted from the mouse
  - -- DragFrame should only attempt to clear an objective when it is loaded
  - -- "CURSOR_UPDATE" now only calls bar:SetAlpha when an item is on the cursor
  - -- Anchors no longer show when anchorMouseover is enabled and hidden empty buttons are temporarily visible (unless anchor is focus)

### 3.0-alpha17

- Bug fixes:
  - -- Removed the non-existant event "CURSOR_CHANGED" from TBCC and changed to "CURSOR_UPDATE"
  - -- Fixed several packager errors preventing the TBCC file from properly packaging
  - -- Fixed error where database attempted to index a table that did not yet exist

### 3.0-alpha16 (3.0-alpha15 skipped)

- Added configuration for bar and button alert formats
  - -- Bar alerts are still under construction
- Implemented button configurations for showEmpty, mouseover, and anchorMouseover
- Changed tooltip for trackers
  - -- trackerCount / trackerObjective (totalTrackerCount / totalTrackerObjective)
  - -- Added progress color to trackerCount
- Bug fixes:
  - -- Fixed bug that prevented bars from being deleted
  - -- Fixed error in cloning bars when enabling or disabling them

### 3.0-alpha14

- Keybinds to toggle bank or all character inclusions have been removed
  - -- All objectives now utilize the per character objective editor accessed with ctrl+right-click (different than objective templates accessed with the same keybind on the bar anchor)
  - -- Default keybinds have changed for the quick add editboxes
- Added a mute alert option for individual objectives (character specific)
- You can now change or remove the template link of an objective on a bar from the objective editor
- You can now include guild banks into item counts
- Changed tracker alerts info.trackerObjective to return overall objective by default
- Added total tracker objective to tooltips in the form:
  - -- trackerName trackerObjectiveCount / trackerObjective\*objectiveObjective (totalTrackerCount / trackerObjective)
- Performance improvements
  - -- Revised alerts to check counts only when necessary
  - -- Changed COMBAT_LOG_EVENT_UNFILTERED to SPELL_UPDATE_COOLDOWN to reduce the number of times called
- Bug fixes:
  - -- Fixed bug where objectives were not properly displayed in button tooltips

### 3.0-alpha13

- Bug fixes:
  - -- Removed "BAG_UPDATE_COOLDOWN" event from buttons to help performance issues
  - -- Fixed error when dropping an objective from the DragFrame with no mouse focus
  - -- Added appropriate data for tracker alerts to work with custom conditions

### 3.0-alpha12

- You can now enable or disable alerts (customization not yet implemented)
- Alert formats have been changed and now accept a user defined function returning a string (customization not yet implemented)
- Implemented tracker progress alerts for multi-tracker objectives
- Debug lines have been removed from creating new objectives or trackers until more reports of issues come in
- Bug fixes:
  - -- Fixed error when deleting objective template

### 3.0-alpha11

- Cleanup code
- Reimplemented link between objective templates and instances
- Added equivalency custom tracker keys
- Added temporary debug lines when creating a new objective template and new tracker
  - -- If you come across an error where new objectives or trackers do not load into the config UI, please reference the debug message in your issue ticket.
- Bug fixes:
  - -- Fixed typo in Objective Editor tile
  - -- Fixed bug where existing trackers could be recreated

### 3.0-alpha10

- Implemented objective editor to toggle includeBank and includeAllChars for multi-tracker objectives
- Bug fixes:
  - -- Fixed error when adding an objective with no trackers to a bar
  - -- Fixed bug where adding an item via the quick add editbox did not clear previous button objective
  - -- Fixed errors preventing custom conditions from being set and used (may be reworked in the future)
  - -- Added missing optional dependencies for includeAllChars: DataStore_Character, DataStore_Currencies

### 3.0-alpha9

- Reimplemented quick add editbox
- Keybinds:
  - -- Restored keybind to open Objective Builder
  - -- Restored keybind to open quick add editbox
  - -- Added include account guild bank counts (in maintenance)
  - -- Added move items up to objective to bank (in maintenance)
  - -- Added move items to bank (in maintenance)
- Bug fixes:
  - -- Fixed bug where user template dropdown was enabled with no templates
  - -- Fixed bug where switching or copying profiles would not apply profile specific settings
  - -- Fixed bug where reindexing bars did not sort objectives on hidden buttons
  - -- Removed forgotten print statement when creating new template
  - -- Added a check for bar tooltips to ensure barDB exists

### 3.0-alpha8

- Restructured database
- Restructured behavior of objectives
  - -- Bars and buttons have been rewritten to incorporate this change
- Objective counts are now rounded down instead of up
- You can now save and load templates
- You can now reindex buttons
- You can now size bar to buttons
- You can now toggle bank inclusion for single tracker objectives
- You can now toggle account counts for single tracker objectives
- Button tooltips no longer utilize GameTooltip and won't show information from other addons
- Tooltip tracker counts have been revised to be more clear: amount toward objective (total item count / amount toward tracker objective)
  - -- For example, if you have 400 total of an item, but your tracker counts 2 of the item as 1 for the objective, it will say: 200 (400 / 2)
- Bug fixes:
  - -- Fixed tooltip errors from missing tracker information
  - -- Fixed bug where clearing objectives did not reset the objective text
  - -- Fixed bug where objectives weren't highlighted when opening button objective editbox

### 3.0-alpha7

- Bug fixes:
  - Fix issue where item name can't be cached for trackers and causes Options to break
- Adjusted tooltip tracker counts to be more clear

### 3.0-alpha6

- Bug fixes:
  - -- Using the Clear Buttons operation now properly clears objectives on hidden buttons
  - -- Removing a bar now clears objectives
  - -- Bars now grow to accomodate templates correctly
  - -- Deleting objectives contained within templates now requires confirmation (known issue: when using Cleanup with multiple objectives that are in a template, only one confirmation pops up)
  - -- Missing objectives in user templates are not automatically created
  - -- Loading a built in template no longer opens newly created objectives
  - -- The config slash command now properly loads config options
- Classic specific bug fixes:
  - -- Fix error where Options would not load due to retail only code
- Remaining built in templates are now available
- DataStore compatible account counts are temporarily available until reworked to require no dependencies
- Objective tracker settings have been moved to the Trackers tab

### 3.0-alpha5

- Some built in templates are now available
- Config and Objective Builder have been reworked into the main options frame
  - -- To add an objective to a bar, there is an icon next to the selected objective's title (on the Objective tab) that you can click to load the objective onto your cursor
- The /craft slash command is still available for now, but will be reworked into a "RECIPE" Action in a future build
- There is now an operation to cleanup unused quick objectives (objectives created automatically when adding an item to a bar)
- Alpha should be properly compatible with Classic

### 3.0-alpha4

- You can now add a "counts for" value to trackers to specify how many times the objective should be incremented each time the tracker objective is met
  - For example: if you have an objective to track the number of enchanting dust you have and want to include shards that can be broken down into dust, you can set one tracker for dust (objective 1 and counts for 1) and one tracker for shards (objective 1 and counts for 3); you could even add crystals (objective 1 and counts for 6; 1 crystal = 2 shards)
- You can now see how many buttons an objective is being tracked on in the Objective Builder tooltip and when confirming a deletion
- You can now craft tradeskill recipes using the /craft slash command (/craft Recipe String); example:
  - /craft Enchanting Eternal Bounds
  - /use Enchanting Vellum
- Additional general addon settings are now available through the GUI:
  - Global: new quick objective settings, preserve template data, preserve template order, delete user templates
- You may now save and load user templates

### 3.0-alpha3

- Additional bar customizations are now available through the GUI
  - -- Bar: title, mute all alerts, hidden, growth direction and type, movability, alpha
  - -- Button: number of buttons, buttons per wrap, size, padding, count anchor, objective anchor
  - -- Button operations: clear buttons, reindex buttons, size bar to buttons
  - -- Bars can be added and removed from the GUI as well as the implemented command.
- Some general addon settings are now available through the GUI
  - -- Global: tooltips, hints, slash commands aliases
  - -- Profile: skin, count style and color, button layers (bank overlay, item quality, cooldown, cooldown edge), font settings
- Profile settings are now accessible
- Max number of buttons has been changed to 108
- You can now opt to hide objective info in button tooltips

### 3.0-alpha2

- Convert saved bars from character to profile specific

### 3.0-alpha1

- Complete addon rewrite
- Limited commands and bar customizations (alpha only)
- New objective structure
- All objectives are available globally
- There are no longer different types of objectives; tracker conditions control how objectives are counted
  - -- All (Shopping List or single tracker objective)
  - -- Any (Mixed Items or single tracker objective)
  - -- Custom
- Custom tracker conditions must return a table containing nested tables of tracker objectives: `return {{t1 = 10, t2 = 2, t3 = 3}, {t1 = 5}}`
  - -- Keys must be formatted "t%d" where "%d" is the tracker number
  - -- Values are tracker objectives
  - -- Tracker groups will be counted toward the objective in the order initialized in the condition
- Objective Settings:
  - -- Title
  - -- Icon (or auto)
  - -- Action (item/currency/macrotext to control auto icon and on use action)
  - -- Tracker condition
- Tracker Settings:
  - -- Objective
  - -- Include Bank
  - -- Exclude Objective (excludes count of tracker required for another objective)

## Version 2.1

- Compatible with Shadowlands 9.0 beta
- You can now mute alerts for individual bars
- You can now disable alerts for buttons with objectives that have already been completed per bar
- You can now track a bar's progress; e.g. 1/5 button objectives complete on this bar
  - -- Bar progress alerts can be enabled/disabled or customized independently from button alerts
- You can now add a title to item objectives
- You can now opt to show button/bar tips on tooltips only when a modifier is held down
- Ctrl+clicking a bar anchor no longer opens Settings
  - -- Alt+click now opens Settings
  - -- Ctrl+click now toggles the bar progress tracker
- Added quality of life changes to the Objective Builder: - -- You can now set objectives for currencies and items within the Objective Builder - -- When opening an Objective Builder group, the first editbox is automatically focused - -- Focusing an editbox will select the whole text - -- Pressing shift+enter while focusing an editbox will focus the previous editbox, similar to how pressing enter focuses the next editbox - -- Pressing ctrl+enter on the icon editbox will open up the icon selector ("Choose") - -- Pressing ctrl+enter on the icon selector's search editbox will choose the current focused icon - -- Pressing ctrl+enter will update the button ("Update Button") while focusing the following editboxes:
  Currencies: currency ID or objective
  Items: item ID, objective or title
  Mixed Items or Shopping Lists: add item
- Added a new quick track editbox to buttons, similar to the objective editbox
  - -- Ctrl+shift+click a button to quickly enter a currency ID (retail only)
  - -- Ctrl+shift+right-click a button to quickly enter an item ID
- Global setting added to temporarily switch auto loot on when using items on buttons
- You can now include saved objective data when loading a user-defined template
  - -- New global setting "Include Data" automatically includes objective data whenever loading a user-defined template
  - -- New global setting "Include Data Prompt" prompts you to choose whether or not to include objective data when loading a user-defined template
  - -- New global setting "Save Order" automatically preserves the objective order when loading a user-defined template
  - -- New global setting "Save Order Prompt" prompts you to choose whether or not to save the objective order when loading a user-defined template
  - -- The template load command now accepts two additional required arguments for include data and save order (respectively):
    `/farmingbar template load 1 true false This Template Rocks`
- Bug fixes
  - -- Fixed missing localization strings
  - -- Fixed bug where item mover would not move reagents if the reagent bank wasn't purchased
  - -- Fixed bug where Shopping List counts didn't add up correctly
  - -- Fixed bug where changing showEmpties property on all bars at once would not persist through reload
  - -- Fixed error with Quick Buttons when logging in/reloading during combat
  - -- Fixed error when clicking the Help buttons to go to Alert Formats documentations
  - -- Attempted to fix an inconsistent error sorting icons in the Objective Builder

## Version 2.0.7

- Removed extra code from me being lazy copy/pasting a fix

## Version 2.0.6

- Fixed a bug where button text wouldn't save its position when using a Masque skin
- Made anchor quick size buttons slightly larger and bar number slightly smaller so the buttons would be easier to click on

## Version 2.0.5

- Added a delay when moving items from shopping list from bank to bags to fix bags full error
- Adjusted the default alert format for has objective to only say objective complete when the objective is first met and to say farming progress above the objective
- Added buttons to reset has objective and no objective alert formats to default
- Changed message when clearing objectives to make sense in multiple scenarios

## Version 2.0.4

- Fixed counts for shopping lists
- Fixed sound files for classic
- Fixed issue where no sound alert played when gaining progress toward an objective
- Changed alerts while moving items so that screen alerts are shown on the moving progress window and chat/sound alerts are no longer suppressed

## Version 2.0.3

- Minor code cleanup
- Fixed an issue where open settings do not refresh when changes are made via slash commands.
- Revised the functionality of the broker icon:
  - -- Left-click toggles settings
  - -- Right-click toggles configuration
  - -- Alt+right-click toggles mouseover
  - -- Alt+ctrl+right-click toggles anchor mouseover
  - -- Ctrl+right-click toggles visibility
  - -- Shift+right-click toggles movability
- Added a new command alias: /fb
- Added the ability to toggle main command aliases off or on, in case of conflict with another addon
- Added alias for /farmingbar buttons: /farmingbar btns
- Added alias for /farmingbar template: /farmingbar tpl

## Version 2.0.2

- Fixed packaging issue.

## Version 2.0.1

- Attempt to fix error with GetFileDataClassic in retail version; it's a packager issue, so trying to work around that.

## Version 2.0

- Complete addon rewrite
- Added more options to customize the look and feel of your bars:
  - -- Change the color of your count text to indicate bank inclusion, item quality, or a custom color
  - -- Hide the four-point golden bank inclusion border
  - -- Show a border indicating item quality
  - -- Show a cooldown swipe on items
  - -- Mouseover capability, including anchor mouseover only
  - -- Toggle the visibility of empty buttons
  - -- Change the number of buttons per row/column
  - -- Change the size of buttons
  - -- Change the padding between buttons
  - -- Change the font of bars' text
  - -- Change the position of count and objective texts
  - -- Give your bar a name or description
  - -- Masque skins support
- Added Objective Builder to create custom objectives beyond items:
  - -- Currencies
  - -- Mixed items (a combination of various items to complete one common objective)
  - -- Shopping lists (a group of several item objectives required to complete the main objective)
- Shortcuts on bars and buttons have been added or changed:
  - -- Added ability to open the Objective Builder from bar anchor and button (ctrl+right-click)
  - -- Toggle bank inclusion has changed to alt+left-click; shift+left-click now moves an item as shift+drag support has been added
  - -- Move items between your bags and bank via Alt+right-click (with additional shift and ctrl modifiers to customize behavior)
- Quality of life changes:
  - -- Track and move items by drag and drop
  - -- Configure all bars at once via the GUI
  - -- Access commands via /farmingbar, /farmbar, /farm, /fbar
  - -- Additional buttons to clear or tidy up bars
  - -- Hide bar/button tips at the bottom of tooltips
- Commands have been completely revamped. See documentation in game.
- You can now customize alert messages
- Option to change alert sounds has been added
- Profile support added
- Templates for Mechagon items added

## Version 1.0.1

- Fixed a lua error from alerts.
- Added templates for retail, courtesy of tednik of WoWInterface.
- Updated ToC to reflect compatibility with Classic and Retail.

## Version 1.0

- Initial upload.
