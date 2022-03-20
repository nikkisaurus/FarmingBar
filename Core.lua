local addonName = ...
local addon = LibStub("AceAddon-3.0"):GetAddon("FarmingBar")
local L = LibStub("AceLocale-3.0"):GetLocale("FarmingBar", true)

-- Optional libraries
local ACD = LibStub("AceConfigDialog-3.0")
local LSM = LibStub("LibSharedMedia-3.0")
LibStub("LibAddonUtils-1.0"):Embed(addon)

-- *------------------------------------------------------------------------
-- Addon functions

function addon:OnInitialize()
	-- Create bar container
	self.bars = {}
	self.trackers = {}

	-- Set addon defaults
	self.maxButtons = 108
	self.maxButtonPadding = 40
	self.maxButtonSize = 120
	self.maxIcons = 500
	self.maxFontSize = 64
	self.maxTooltipTrackers = 10
	self.minButtonPadding = -3
	self.minButtonSize = 15
	self.minFontSize = 4

	self.moveDelay = 0.4
	self.OffsetX = 10
	self.OffsetY = 10
	self.tooltip_desc = { 1, 1, 1, 1, 1, 1, 1 }
	self.tooltip_keyvalue = { 1, 0.82, 0, 1, 1, 1, 1 }

	self.barProgress = [[function(info)
        -- info keys: progressCount, progressTotal, barIDName, barName, barNameLong, progressColor, objectiveSet, difference.sign, difference.color
        
        local difference = not info.objectiveSet and format(" (%s%s1|r)|r", info.difference.color or "", info.difference.sign or "") or ""

        return format("Progress: %s %s%d/%d|r%s", info.barNameLong, info.progressColor, info.progressCount, info.progressTotal, difference)
    end]]
	self.withObjective = [[function(info)
        -- info keys: objectiveTitle, objective.color, objective.count, oldCount, newCount, difference.sign, difference.color, difference.count

        local percent = floor((info.newCount / info.objective.count) * 100)
        local objectiveReps = floor(info.newCount / info.objective.count)

        local status = format("%s", (percent >= 100 and info.oldCount < info.objective.count) and "Objective complete!" or "Farming update:")
        local count = format("%s%d/%d|r", info.objective.color, info.newCount, info.objective.count)
        local difference = format("%s%s%d|r", info.difference.color or "", info.difference.sign or "", info.difference.count)

        return format("%s %s %s (%s%s)", status, info.objectiveTitle, count, objectiveReps > 1 and "x"..objectiveReps.." " or "", difference)
    end]]
	self.withoutObjective = [[function(info)
        -- info keys: objectiveTitle, objective.color, objective.count, oldCount, newCount, difference.sign, difference.color, difference.count

        local difference = format("%s%s%d|r", info.difference.color, info.difference.sign, info.difference.count)

        return format("Farming update: %s x%d (%s)", info.objectiveTitle, info.newCount, difference)
    end]]
	self.trackerProgress = [[function(info)
        -- info keys: objectiveTitle, trackerTitle, objective.color, objective.count, trackerObjective.color, trackerObjective.count, oldTrackerCount, newTrackerCount, trackerDifference.sign, trackerDifference.color, trackerDifference.count

        local title = format("(%s) %s", info.objectiveTitle, info.trackerTitle)
        local count = format("%s%d/%d|r", info.trackerObjective.color, info.newTrackerCount, info.trackerObjective.count)
        local difference = format("(%s%s%d|r)", info.trackerDifference.color, info.trackerDifference.sign, info.trackerDifference.count)

        return format("Tracker update: %s %s %s", title, count, difference)
    end]]

	self.customHide = [[function()
        -- This function must return a boolean flag to indicate if the bar should be hidden.
        -- Example:
        -- function()
        --     -- Shows the bar when fishing pole is equipped
        --     return not IsEquippedItem("Underlight Angler")
        -- end        
            
        return false
    end
    ]]

	self.customCondition =
		[[--Custom functions must return a number value. How you derive this count is completely up to you, so you can create complex rules to count your objective. Your function will be supplied two arguments (buttonDB[table] and GetTrackerCount[function]).

--buttonDB.trackers contains information about all trackers in this objective.
--GetTrackerCount will return a count for the tracker based on your settings, such as includeAllChars, includeBank, includeGuildBank:

    --local count = GetTrackerCount(_, buttonDB, trackerKey[, overrideObjective])

--trackerKey can be obtained from buttonDB.trackers. It will be in the format "ITEM:000000". overrideObjective can be used to override the saved objective for the specific tracker. For example, if your tracker contains an objective of 5, but you want to get the count per 1, supply 1 as this argument.

--Example: custom tracker to level Shadowlands enchanting through different recipes (5x Bargain of Haste or Crafter's Mark I).


--function(buttonDB, GetTrackerCount)
--    local min = math.min
--    local floor = math.floor
    
--    -- Tracker keys:
--    local soulDust = "ITEM:172230"
--    local sacredShard = "ITEM:172231"
--    local immortalShard = "ITEM:183951"
    
--    -- Get counts for each tracker
--    local count = 0
--    local trackerCounts = {}
    
--    for trackerKey, trackerInfo in pairs(buttonDB.trackers) do
--        trackerCounts[trackerKey] = GetTrackerCount(_, buttonDB, trackerKey)
--    end
    
--    -- Calculate the number of Bargain of Haste enchants
--    local numBargains = min(floor(trackerCounts[soulDust] / 2), floor(trackerCounts[sacredShard]))
    
--    count = count + (numBargains or 0)
--    trackerCounts[soulDust] = trackerCounts[soulDust] - (numBargains * 2)
--    trackerCounts[sacredShard] = trackerCounts[sacredShard] - numBargains
    
--    -- Calculate the number of Crafter's Mark I
--    local numMarks = min(floor(trackerCounts[soulDust] / 5), floor(trackerCounts[immortalShard] / 3))
    
--    count = count + (numMarks or 0)
--    trackerCounts[soulDust] = trackerCounts[soulDust] - (numMarks * 5)
--    trackerCounts[immortalShard] = trackerCounts[immortalShard] - (numMarks * 3)
    
    
--    return count
--end


-- Condition: All
function(buttonDB, GetTrackerCount)
    local count
    
    for trackerKey, trackerInfo in pairs(buttonDB.trackers) do
        local trackerCount = GetTrackerCount(_, buttonDB, trackerKey)
        
        count = not count and trackerCount or math.min(trackerCount, count)
    end
    
    return count
    
end
]]

	-- Register sounds
	--@retail@
	LSM:Register("sound", L["Auction Open"], 567482) -- id:5274
	LSM:Register("sound", L["Auction Close"], 567499) -- id:5275
	LSM:Register("sound", L["Loot Coin"], 567428) -- id:120
	LSM:Register("sound", L["Quest Activate"], 567400) -- id:618
	LSM:Register("sound", L["Quest Complete"], 567439) -- id:878
	LSM:Register("sound", L["Quest Failed"], 567459) -- id:846
	--@end-retail@
	--[===[@non-retail@
    LSM:Register("sound", L["Auction Open"], "sound/interface/auctionwindowopen.ogg") -- id:5274
    LSM:Register("sound", L["Auction Close"], "sound/interface/auctionwindowclose.ogg") -- id:5275
    LSM:Register("sound", L["Loot Coin"], "sound/interface/lootcoinsmall.ogg") -- id:120
    LSM:Register("sound", L["Quest Activate"], "sound/interface/iquestactivate.ogg") -- id:618
    LSM:Register("sound", L["Quest Complete"], "sound/interface/iquestcomplete.ogg") -- id:878
    LSM:Register("sound", L["Quest Failed"], "sound/interface/igquestfailed.ogg") -- id:846
    --@end-non-retail@]===]

	-- Initialize database and slash commands
	self:InitializeDB()
	self:RegisterSlashCommands()

	self.GameTooltip_OnUpdate = GameTooltip:GetScript("OnUpdate")
end

function addon:OnEnable()
	--@retail@
	self.fileData = self:GetFileDataRetail()
	--@end-retail@
	--[===[@non-retail@
	self.fileData = self:GetFileDataClassic()
	--@end-non-retail@]===]

	self:InitializeTooltips()
	self:InitializeAlerts()
	-- self:Initialize_Masque()
	self:InitializeBars()
	self:InitializeEvents()
	self:InitializeTrackers()
	self:InitializeDragFrame()
	self:InitializeOptions()
end

function addon:OnDisable() end

function addon:OnProfile_(...)
	self:ReleaseAllBars()
	self:InitializeBars()
end

function addon:InitializeEvents()
	self:RegisterEvent("BAG_UPDATE_DELAYED")
	--@retail@

	self:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
	--@end-retail@
end

function addon:InitializeTrackers()
	wipe(addon.trackers)

	for barID, bar in pairs(addon.bars) do
		if not bar:GetButtons() then
			return
		end
		for buttonID, button in pairs(bar:GetButtons()) do
			if not button:IsEmpty() then
				for trackerKey, tracker in pairs(button:GetButtonDB().trackers) do
					local trackerType, trackerID = addon:ParseTrackerKey(trackerKey)
					addon.trackers[trackerID] = addon.trackers[trackerID] or {}
					tinsert(addon.trackers[trackerID], { barID, buttonID })
				end
			end
		end
	end
end

function addon:RegisterSlashCommands()
	for command, enabled in pairs(self:GetDBValue("global", "settings.commands")) do
		if enabled then
			self:RegisterChatCommand(command, "SlashCommandFunc")
		else
			self:UnregisterChatCommand(command)
		end
	end

	self:RegisterChatCommand("craft", "CraftTradeSkill")
end

function addon:SlashCommandFunc(input)
	local cmd, arg, arg2 = strsplit(" ", strupper(input))
	if cmd == "BUILD" then
		addon.ObjectiveBuilder:Load()
	elseif cmd == "BAR" then
		if arg == "ADD" then
			self:CreateBar()
		elseif arg == "REMOVE" then
			local arg2 = tonumber(arg2)
			if addon.bars[arg2] then
				self:SetBarDisabled(arg2)
			end
		end
	elseif cmd == "CONFIG" then
		local arg = tonumber(arg)
		ACD:SelectGroup(addonName, "config", "container", addon.bars[arg] and "bar" .. arg)
		ACD:Open(addonName)
	else
		LibStub("AceConfigDialog-3.0"):Open(addonName)
		self:Print([[Currently available commands: "build", "bar add", "bar remove barID", "config"]])
	end
end

function addon:ReportError(error)
	PlaySound(846) -- "sound/interface/igquestfailed.ogg" classic?
	self:Print(string.format("%s %s", self.ColorFontString(L["Error"], "red"), error))
end

-- *------------------------------------------------------------------------
-- Methods

function addon:CloneTable(orig)
	-- https://forum.cockos.com/showthread.php?t=221712
	local copy
	if type(orig) == "table" then
		copy = {}
		for orig_key, orig_value in pairs(orig) do
			copy[self:CloneTable(orig_key)] = self:CloneTable(orig_value)
		end
		setmetatable(copy, self:CloneTable(getmetatable(orig)))
	else -- number, string, boolean, etc
		copy = orig
	end
	return copy
end

function addon:GetCharKey()
	return format("%s - %s", UnitName("player"), GetRealmName())
end

function addon:GetModifierString()
	local mod = ""
	if IsShiftKeyDown() then
		mod = "shift"
	end
	if IsControlKeyDown() then
		mod = "ctrl" .. (mod ~= "" and "-" or "") .. mod
	end
	if IsAltKeyDown() then
		mod = "alt" .. (mod ~= "" and "-" or "") .. mod
	end
	return mod
end

function addon:IsTooltipMod()
	if not self:GetDBValue("global", "settings.tooltips.condensedTooltip") then
		return true
	else
		return _G["Is" .. self:GetDBValue("global", "settings.tooltips.modifier") .. "KeyDown"]()
	end
end
