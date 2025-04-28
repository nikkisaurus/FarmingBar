local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)

function addon:PLAYER_ENTERING_WORLD()
    local index
    private.ChatFrame, index = private:GetChatFrame()

    if not private.ChatFrame then
        private.ChatFrame, index = FCF_OpenNewWindow(L.addonName, true)
    end

    private:UpdateChatFrame()
end

function private:GetChatFrame()
    for i = 1, NUM_CHAT_WINDOWS do
        local frame = _G["ChatFrame" .. i]
        if frame and frame.name == L.addonName then
            return frame, i
        end
    end
end

function private:UpdateChatFrame()
    local frame, index = private:GetChatFrame()
    if not frame then
        return
    end

    local settings = private.db.global.settings.chatFrame
    private.defaultChatFrame = settings.enabled and frame or DEFAULT_CHAT_FRAME

    if settings.enabled then
        if settings.docked then
            FCFDock_AddChatFrame(GENERAL_CHAT_DOCK, frame, index)
        else
            frame:Show()
            FloatingChatFrame_Update(index)
        end
    else
        FCF_Close(private.ChatFrame)
    end
end
