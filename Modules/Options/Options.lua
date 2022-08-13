local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)
local AceGUI = LibStub("AceGUI-3.0")
local LSM = LibStub("LibSharedMedia-3.0")

--[[ Menus ]]
local function GetTreeMenu()
    local menu = {
        {
            value = "Bars",
            text = L["Bars"],
        },
        {
            value = "Objectives",
            text = L["Objective Templates"],
        },
    }

    if addon.tcount(private.db.profile.bars) > 0 then
        menu[1].children = {}
    end
    for barID, _ in addon.pairs(private.db.profile.bars) do
        tinsert(menu[1].children, {
            value = "bar" .. barID,
            text = format("%s %d", L["Bar"], barID),
        })
    end

    if addon.tcount(private.db.global.objectives) > 0 then
        menu[2].children = {}
    end
    for objectiveTitle, _ in addon.pairs(private.db.global.objectives) do
        tinsert(menu[2].children, {
            value = objectiveTitle,
            text = objectiveTitle,
        })
    end

    return menu
end

--[[ Callbacks ]]
local function treeGroup_OnGroupSelected(treeGroup, _, path)
    local group, subgroup = strsplit("\001", path)
    treeGroup:ReleaseChildren()
    private["Get" .. group .. "Options"](private, treeGroup, subgroup)
end

--[[ Options ]]
function private:AddChildren(parent, ...)
    for _, child in pairs({ ... }) do
        parent:AddChild(child)
    end
end

function private:InitializeOptions()
    -- Widgets
    local options = AceGUI:Create("Frame")
    options:SetTitle(L.addonName)
    options:SetLayout("Fill")
    options:SetWidth(800)
    options:SetHeight(600)
    options:Hide()
    private.options = options

    local treeGroup = AceGUI:Create("TreeGroup")
    treeGroup:SetCallback("OnGroupSelected", treeGroup_OnGroupSelected)
    treeGroup:SetUserData("UpdateMenu", function()
        treeGroup:SetTree(GetTreeMenu())
    end)
    options:SetUserData("menu", treeGroup)

    private:AddChildren(options, treeGroup)
end

function private:LoadOptions()
    if not private.options then
        private:InitializeOptions()
    end

    private.options:Show()
    private:UpdateMenu(private.options:GetUserData("menu"))
end

function private:NotifyChange(parent)
    for _, child in pairs(parent.children) do
        local NotifyChange = child:GetUserData("NotifyChange")
        if NotifyChange then
            NotifyChange(child)
            parent:DoLayout()
        end

        if child.children then
            private:NotifyChange(child)
        end
    end
end

function private:SetOptionTooltip(widget, text)
    widget:SetCallback("OnEnter", function()
        private:LoadTooltip(
            widget.frame,
            "ANCHOR_RIGHT",
            0,
            0,
            { { line = text, color = private.defaults.tooltip_desc } }
        )
    end)
    widget:SetCallback("OnLeave", function()
        private:ClearTooltip()
    end)
end

function private:UpdateMenu(widget, ...)
    local UpdateMenu = widget:GetUserData("UpdateMenu")
    if UpdateMenu then
        UpdateMenu()
        if select(1, ...) then
            widget:SelectByPath(...)
        end
    end
end

--[[ Media ]]
function private:RegisterMedia()
    LSM:Register(LSM.MediaType.BACKGROUND, "UI EmptySlot White", [[INTERFACE\BUTTONS\UI-EMPTYSLOT-WHITE]])
    LSM:Register(LSM.MediaType.BACKGROUND, "UI ActionButton Border", [[Interface\Buttons\UI-ActionButton-Border]])
end

--[[ Masque Support ]]
local function MSQ_Callback(...)
    for _, bar in pairs(private.bars) do
        bar:UpdateButtonTextures()
    end
end

function private:InitializeMasque()
    local MSQ, MSQVersion = LibStub("Masque", true)

    if MSQ and MSQVersion >= 90002 then
        private.MSQ = {
            button = MSQ:Group(L.addonName),
        }

        private.MSQ.button:SetCallback(MSQ_Callback)
    end
end
