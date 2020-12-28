local addonName, addon = ...
local FarmingBar = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

--*------------------------------------------------------------------------

function addon:GetHelpOptions()
    local options = {
        alerts = {
            order = 1,
            type = "group",
            name = L["Alerts"],
            args = {},
        },

        ------------------------------------------------------------

        commands = {
            order = 2,
            type = "group",
            name = L["Commands"],
            args = {},
        },

        ------------------------------------------------------------

        objectives = {
            order = 3,
            type = "group",
            name = L["Objectives"],
            args = {},
        },

        ------------------------------------------------------------

        templates = {
            order = 4,
            type = "group",
            name = L["Templates"],
            args = {},
        },

        ------------------------------------------------------------

        -- MAIN: General about, feedback/support, bars and buttons

        alpha = {
            order = 1,
            type = "description",
            name = [[Thank you for testing the alpha! Please create an issue at |cff00ccff[ https://github.com/niketa-wow/farmingbar/issues ]|r for suggestions and bug reports. Please specify the alpha version "|cff00C78C3.0-alpha4|r" in your report. Features in the stable release that are not implemented in this alpha are not bugs and should not be reported.


For questions that aren't feature requests or bug reports, message me on Discord |cff00ccff@Niketa#1247|r or comment at |cff00ccff[ https://www.curseforge.com/wow/addons/farming-bar ]|r.


If you switch back to the stable version from this alpha, your alpha settings will not be saved but your stable database will be intact and restored. There is no guarantee that alpha database versions will be protected during alpha restructures (though I will try my best not to restructure anything major).]],
        },
    }

    return options
end