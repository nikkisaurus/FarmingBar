# Farming Bar
## Version 3.0
### 3.0-alpha3
- Additional bar customizations are now available through the GUI
  -  -- Bar: title, mute all alerts, hidden, growth direction and type, movability, scale, alpha
  -  -- Button: number of buttons, buttons per wrap, size, padding, count anchor, objective anchor
  -  -- Button operations: clear buttons, reindex buttons, size bar to buttons
  -  -- Bars can be added and removed from the GUI as well as the implemented command.
-  Some general addon settings are now available through the GUI
   -  -- Profile: skin, count style and color, button layers (bank overlay, item quality, cooldown, cooldown edge), font settings
-  Profile settings are now accessible

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
  - -- Display Reference (item/currency/macrotext to control auto icon and on use action)
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
- Added quality of life changes to the Objective Builder:
    - -- You can now set objectives for currencies and items within the Objective Builder
    - -- When opening an Objective Builder group, the first editbox is automatically focused
    - -- Focusing an editbox will select the whole text
    - -- Pressing shift+enter while focusing an editbox will focus the previous editbox, similar to how pressing enter focuses the next editbox
    - -- Pressing ctrl+enter on the icon editbox will open up the icon selector ("Choose")
    - -- Pressing ctrl+enter on the icon selector's search editbox will choose the current focused icon
    - -- Pressing ctrl+enter will update the button ("Update Button") while focusing the following editboxes:
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