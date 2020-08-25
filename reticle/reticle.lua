-----------------
-- LCQ Reticle --
-----------------

LCQ_Reticle = ZO_Object:Subclass()

function LCQ_Reticle:New()
    local reticle = ZO_Object:New(self)
    reticle:Initialize()
    return reticle
end

function LCQ_Reticle:Initialize()
    local LCQ_Interact = WINDOW_MANAGER:CreateControl("LCQ_InteractContainer", ZO_ReticleContainer, CT_CONTROL)
    LCQ_Interact:SetDimensions(200, 50)
    LCQ_Interact:SetAnchor(LEFT, ZO_ReticleContainer, CENTER, 45, 40)

    local LCQ_Context = WINDOW_MANAGER:CreateControl("LCQ_InteractContext", LCQ_InteractContainer, CT_LABEL)
    LCQ_Context:SetDimensionConstraints(-1, -1, 380, -1)
    LCQ_Context:SetAnchor(BOTTOMLEFT, ZO_ReticleContainerInteract, BOTTOMLEFT, 0, 0)

    local LCQ_KeybindButton = WINDOW_MANAGER:CreateControlFromVirtual("LCQ_InteractKeybindButton", LCQ_InteractContainer, "ZO_KeybindButton")
    --LCQ_KeybindButton:SetAnchor(TOPLEFT, ZO_ReticleContainerInteract, BOTTOMLEFT, 0, 0)

    self.interact = LCQ_Interact
    self.interactContext = LCQ_Context
    self.interactKeybindButton = LCQ_KeybindButton
    
    self:UpdateGamepadMode()
    
    local HookFunction = function()
        local interactionPossible = GetGameCameraInteractableInfo()

        self.interact:SetHidden(true)

        if interactionPossible then
            local action, interactableName, interactionBlocked, isOwned, additionalInteractInfo, context, contextLink, isCriminalInteract = GetGameCameraInteractableActionInfo()

            --
            local isValidDialogueTarget, dialogueTarget = LCQ_isValidDialogueTarget(interactableName or GetUnitName("reticleover"))
            --

            --Could be more efficient?
            if interactableName then 
                hideInteractContextString = true
                self.interactKeybindButton:ClearAnchors()
                self.interactKeybindButton:SetAnchor(TOPLEFT, ZO_ReticleContainerInteractContext, BOTTOMLEFT, 20, 46)
            else
                hideInteractContextString = false
                self.interactKeybindButton:ClearAnchors()
                self.interactKeybindButton:SetAnchor(TOPLEFT, ZO_ReticleContainerInteractContext, BOTTOMLEFT, 20, 6)
            end

            if not isValidDialogueTarget then return else action = GetString(SI_GAMECAMERAACTIONTYPE2) interactableName = dialogueTarget end

            local interactKeybindButtonColor = ZO_NORMAL_TEXT
            local additionalInfoLabelColor = ZO_CONTRAST_TEXT
            self.interactKeybindButton:ShowKeyIcon()

            local hideInteractContextString
            local interactContextString

            self.interactKeybindButton:SetKeybind("LCQ_INTERACT", hideUnbound, "LCQ_INTERACT") --The Keybind is shared between Keyboard/Gamepad. The user can input any valid Keybind (I think).

            if action and interactableName then
                currentInteractAction = action
                currentDialogueTarget = interactableName
                

                if isOwned or isCriminalInteract then
                    interactKeybindButtonColor = ZO_ERROR_COLOR
                end
                
                if hideInteractContextString then interactContextString = ""
                else interactContextString = interactableName end

                self.interactContext:SetText(interactContextString)

                self.interactionBlocked = interactionBlocked
                self.interactKeybindButton:SetNormalTextColor(interactKeybindButtonColor)
                self.interactKeybindButton:SetText(zo_strformat(SI_GAME_CAMERA_TARGET, action))

                local interactionType = GetInteractionType()
                local showBusy = interactionType ~= INTERACTION_NONE and interactionType ~= INTERACTION_FISH and interactionType ~= INTERACTION_PICKPOCKET  and interactionType ~= INTERACTION_HIDEYHOLE or (IsInGamepadPreferredMode() and IsBlockActive())
                self.interactKeybindButton:SetEnabled(not showBusy and not self.interactionBlocked)

                self.interact:SetHidden(false)

                return
            end
        end
    end
    
    EVENT_MANAGER:RegisterForEvent("LCQ_Reticle", EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, self.UpdateGamepadMode)

    SecurePostHook(RETICLE, "UpdateInteractText", HookFunction)
end

function LCQ_Reticle:UpdateGamepadMode()
    if IsInGamepadPreferredMode() then   
        self.interactContext:SetFont("ZoFontGamepad42")
        self.interactKeybindButton:SetNameFont("ZoFontGamepad42")
        self.interactKeybindButton:SetupStyle(KEYBIND_STRIP_GAMEPAD_STYLE)
    else
        self.interactContext:SetFont("ZoInteractionPrompt")
        self.interactKeybindButton:SetNameFont("ZoInteractionPrompt")
        self.interactKeybindButton:SetupStyle(KEYBIND_STRIP_STANDARD_STYLE)
    end
end

function LCQ_isValidDialogueTarget(target)
    local isTargetASpeaker = false --You can loop over possible speakers to match target to speaker and thus dialogue.
    local interactionExists, _, _, _, _, _, _ = GetGameCameraInteractableInfo()
    local dialogueTarget = ""

    if not interactionExists then return false end

    --Find active/all quests
    for i, quest in pairs(CUSTOM_QUEST_MANAGER:GetAllQuests()) do
        --local lang = GetCVar("language.2")
        --if not isQuestInLanguage(quest.id, lang) then
            --d(GetString(ALIANYM_LANGUAGE_NOT_SUPPORTED))
            --return false
        --end

        for i=1, #Alianym.Dialogues do
            local dialogues = Alianym.Dialogues[i]
            local step = quest.stages.current or 1

            if dialogues.DETAILS.questId == quest.id and dialogues.ENTRY.speaker == target and dialogues.DETAILS.questStage == step then
                isTargetASpeaker = true
                dialogueTarget = target

                return isTargetASpeaker, dialogueTarget, i
            end
        end
    end
 
    return isTargetASpeaker, dialogueTarget
end


LCQ_RETICLE = LCQ_Reticle:New()