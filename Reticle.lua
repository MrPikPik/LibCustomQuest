local LibCustomQuest = LibCustomQuest or {}

local function UpdateInteractText(self, currentFrameTimeSeconds)
    local name = GetInteractionTargetName()
    if LCQ_INTERACTIONLISTENER:IsTargetRegisteredInteraction(name) then
        -- If there is no interaction enabled from the base game, we need to enable and update the interaction paramters ourselves
        if self.interact:IsHidden() then
            self.interact:SetHidden(false)
            self.interactContext:SetText(name)
        end

        local isVanillaInteractionAvailable = GetGameCameraInteractableInfo()
        if not isVanillaInteractionAvailable then
            self.interactKeybindButton:SetHidden(true)
        end

        
        self.interactKeybindButton2:SetHidden(false)
        local orignalInteractionShown = self.interactKeybindButton:IsHidden()
        if orignalInteractionShown then
            self.interactKeybindButton2:ClearAnchors()
            self.interactKeybindButton2:SetAnchor(TOPLEFT, ZO_ReticleContainerInteractContext, BOTTOMLEFT, 60, 6)
        else
            self.interactKeybindButton2:ClearAnchors()
            self.interactKeybindButton2:SetAnchor(TOPLEFT, ZO_ReticleContainerInteractContext, BOTTOMLEFT, 60, 46)
        end
        self.interactKeybindButton2:SetText(LCQ_INTERACTIONLISTENER:GetTargetInteractionText(name))
    else
        self.interactKeybindButton:SetHidden(false)
        self.interactKeybindButton2:SetHidden(true)
    end
end

local function OnGamePadPreferredModeChange()
    if IsInGamepadPreferredMode() then   
        RETICLE.interactKeybindButton2:SetNameFont("ZoFontGamepad42")
        RETICLE.interactKeybindButton2:SetupStyle(KEYBIND_STRIP_GAMEPAD_STYLE)
    else
        RETICLE.interactKeybindButton2:SetNameFont("ZoInteractionPrompt")
        RETICLE.interactKeybindButton2:SetupStyle(KEYBIND_STRIP_STANDARD_STYLE)
    end
end

function LibCustomQuest.SetupReticle()
    RETICLE.interactKeybindButton2 = WINDOW_MANAGER:CreateControlFromVirtual("LCQ_InteractKeybindButton", ZO_ReticleContainerInteract, "ZO_KeybindButton")
    RETICLE.interactKeybindButton2:SetKeybind("LCQ_INTERACT", true, "LCQ_INTERACT")

    EVENT_MANAGER:RegisterForEvent("LCQ_Reticle", EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, OnGamePadPreferredModeChange)

    ZO_PostHook(RETICLE, "UpdateInteractText", UpdateInteractText)
end