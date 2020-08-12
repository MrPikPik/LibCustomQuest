if not Alianym then Alianym = {} end
if not ALIANYM then ALIANYM = {} end

Alianym_Reticle = {}
local currentDialogueTarget = ""
local currentInteractAction = ""

local AlianymContext
local AlianymInteract
local AlianymKeybindButton

function Alianym_Reticle:Initialize()
    local RETICLE_KEYBOARD_STYLE =
    {
        font = "ZoInteractionPrompt",
        keybindButtonStyle = KEYBIND_STRIP_STANDARD_STYLE,
    }
    local RETICLE_GAMEPAD_STYLE =
    {
        font = "ZoFontGamepad42",
        keybindButtonStyle = KEYBIND_STRIP_GAMEPAD_STYLE,
    }

    AlianymInteract = WINDOW_MANAGER:CreateControl("ALIANYMInteract", ZO_ReticleContainer, CT_CONTROL)
    AlianymInteract:SetDimensions(200, 50)
    AlianymInteract:SetAnchor(LEFT, ZO_ReticleContainer, CENTER, 45, 40)

    AlianymContext = WINDOW_MANAGER:CreateControl("ALIANYMInteractContext", AlianymInteract, CT_LABEL)
    AlianymContext:SetDimensionConstraints(-1, -1, 380, -1)
    AlianymContext:SetAnchor(BOTTOMLEFT, ZO_ReticleContainerInteract, BOTTOMLEFT, 0, 0)

    AlianymKeybindButton = WINDOW_MANAGER: CreateControlFromVirtual("ALIANYMInteractKeybindButton", AlianymInteract, "ZO_KeybindButton")
    --AlianymKeybindButton:SetAnchor(TOPLEFT, ZO_ReticleContainerInteract, BOTTOMLEFT, 0, 0)

    if IsInGamepadPreferredMode() then
        AlianymContext:SetFont(RETICLE_GAMEPAD_STYLE.font)
        AlianymKeybindButton:SetNameFont(RETICLE_GAMEPAD_STYLE.font)
        AlianymKeybindButton:SetupStyle(RETICLE_GAMEPAD_STYLE.keybindButtonStyle)
    else
        AlianymContext:SetFont(RETICLE_KEYBOARD_STYLE.font)
        AlianymKeybindButton:SetNameFont(RETICLE_KEYBOARD_STYLE.font)
        AlianymKeybindButton:SetupStyle(RETICLE_KEYBOARD_STYLE.keybindButtonStyle)
    end

    Alianym_Reticle.interact = AlianymInteract
    Alianym_Reticle.interactContext = AlianymContext
    Alianym_Reticle.interactKeybindButton = AlianymKeybindButton
end

SecurePostHook(RETICLE, "UpdateInteractText", function()
    local interactionPossible = GetGameCameraInteractableInfo()

    Alianym_Reticle.interact:SetHidden(true)

    if interactionPossible then
        local action, interactableName, interactionBlocked, isOwned, additionalInteractInfo, context, contextLink, isCriminalInteract = GetGameCameraInteractableActionInfo()

        --
        local isValidDialogueTarget, dialogueTarget = Alianym_Reticle.isValidDialogueTarget(interactableName or GetUnitName("reticleover"))
        --

        --Could be more efficient?
        if interactableName then 
            hideInteractContextString = true
            AlianymKeybindButton:ClearAnchors()
            AlianymKeybindButton:SetAnchor(TOPLEFT, ZO_ReticleContainerInteractContext, BOTTOMLEFT, 20, 46)
        else
            hideInteractContextString = false
            AlianymKeybindButton:ClearAnchors()
            AlianymKeybindButton:SetAnchor(TOPLEFT, ZO_ReticleContainerInteractContext, BOTTOMLEFT, 20, 6)
        end

        if not isValidDialogueTarget then return else action = GetString(ALIANYM_CUSTOM_DIALOGUE_ACTION) interactableName = dialogueTarget end

        local interactKeybindButtonColor = ZO_NORMAL_TEXT
        local additionalInfoLabelColor = ZO_CONTRAST_TEXT
        Alianym_Reticle.interactKeybindButton:ShowKeyIcon()

        local hideInteractContextString
        local interactContextString

        Alianym_Reticle.interactKeybindButton:SetKeybind("ALIANYM_INTERACT_KEY", hideUnbound, "ALIANYM_INTERACT_KEY") --The Keybind is shared between Keyboard/Gamepad. The user can input any valid Keybind (I think).

        if action and interactableName then
            currentInteractAction = action
            currentDialogueTarget = interactableName
            

            if isOwned or isCriminalInteract then
                interactKeybindButtonColor = ZO_ERROR_COLOR
            end
            
            if hideInteractContextString then interactContextString = ""
            else interactContextString = interactableName end

            Alianym_Reticle.interactContext:SetText(interactContextString)

            Alianym_Reticle.interactionBlocked = interactionBlocked
            Alianym_Reticle.interactKeybindButton:SetNormalTextColor(interactKeybindButtonColor)
            Alianym_Reticle.interactKeybindButton:SetText(zo_strformat(SI_GAME_CAMERA_TARGET, action))

            local interactionType = GetInteractionType()
            local showBusy = interactionType ~= INTERACTION_NONE and interactionType ~= INTERACTION_FISH and interactionType ~= INTERACTION_PICKPOCKET  and interactionType ~= INTERACTION_HIDEYHOLE or (IsInGamepadPreferredMode() and IsBlockActive())
            Alianym_Reticle.interactKeybindButton:SetEnabled(not showBusy and not Alianym_Reticle.interactionBlocked)

            Alianym_Reticle.interact:SetHidden(false)

            return
        end
    end
end)

function Alianym_Reticle.isValidDialogueTarget(target)
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

local function HandleDialogueInteract()

    local _, _, dialogId = Alianym_Reticle.isValidDialogueTarget(currentDialogueTarget)

    if dialogId then
        --Might want to make the "Dialogues[questId]" array multi-dimensional as the same NPC could have separate dialogues based on quest stage.
        --Should also do a check that the Dialogue Tree chosen matches up not only with a quest, but with a specific quest -stage-.
        LibCustomDialog.ShowDialog(Alianym.Dialogues[dialogId].ENTRY)
        return true
    end

    return false
end

function Alianym.Interact() --Can be refined.
    if not Alianym_Reticle.interactionBlocked and not Alianym_Reticle.interact:IsHidden() then

        --Filter on action type. This means in the future you could re-use this function for other interactions.
        if currentInteractAction == GetString(ALIANYM_CUSTOM_DIALOGUE_ACTION) then
            success = HandleDialogueInteract()
        end
    end
end