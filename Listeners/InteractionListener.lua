-----------------------------------------
-- Interaction Listener
-----------------------------------------

LCQInteractionListener = LCQListener:Subclass()

function LCQInteractionListener:New(...)
    local listener = LCQListener.New(self, ...)
    listener:Initialize(...)
    return listener
end

function LCQInteractionListener:Initialize(...)
    self.name = "InteractionListener"
    self.targets = {}
    
    EVENT_MANAGER:RegisterForEvent(LibCustomQuest.name, EVENT_SHOW_BOOK, function(...) self:OnBookRead(...) end)

    LCQ_DBG:Verbose("Listener: Interaction listener initalized")
end

function LCQInteractionListener:IsTargetRegisteredInteraction(name)
    for _, target in ipairs(self.targets) do
        if target.name == name then
            -- This is so the secondary prompt won't show so we hook into the base game interact instead
            if target.type ~= CUSTOM_INTERACTION_READ then
                return true
            end
        end
    end
    return false
end

function LCQInteractionListener:GetTargetInteractionText(name)
    for _, target in ipairs(self.targets) do
        if target.name == name then
            -- Hard coded cases for interaction that always should use the same interaction prompt
            if target.type == CUSTOM_INTERACTION_TALK then
                return GetString(SI_GAMECAMERAACTIONTYPE2) -- "Talk"
            elseif target.type == CUSTOM_INTERACTION_READ then
                -- Return nil, as at this time we want to just rely on the base-game "READ" interaction
                --return GetString(SI_GAMECAMERAACTIONTYPE6) -- "Read"
            end

            -- Custom interaction prompts, valid for certain cases
            if target.interactionText then
                if type(target.interactionText) == "number" then
                    return GetString(target.interactionText)
                else
                    return target.interactionText
                end
            else
                return GetString(SI_BINDING_NAME_GAMEPAD_GAME_CAMERA_INTERACT) -- "Interact", fallback default value
            end
        end
    end
    return ""
end

function LCQInteractionListener:RunInteractionForTarget(name)
    for _, target in ipairs(self.targets) do
        if target.name == name then
            -- We have a valid target, now do the interaction linked to its
            if target.type == CUSTOM_INTERACTION_TALK then
                LibCustomDialog.ShowDialog(target.dialog)
                -- Since dialogs should handle the completion of themselves, we won't progress but only show the dialog.
            elseif target.type == CUSTOM_INTERACTION_EMOTE then
                -- Play an emote and progress
                self:FireCallbacks("OnConditionMet", target)
            elseif target.type == CUSTOM_INTERACTION_READ then
                self:FireCallbacks("OnConditionMet", target)
            elseif target.type == CUSTOM_INTERACTION_START_QUEST then
                CUSTOM_QUEST_MANAGER:StartQuest(target.quest, target.questId)
                self:Remove(target)
            end
        end
    end
end

function LCQInteractionListener:OnBookRead(event, bookTitle, _, _, _, bookId)
    -- Pass shown book title (target book) to see if there's interactions
    self:RunInteractionForTarget(bookTitle)
end