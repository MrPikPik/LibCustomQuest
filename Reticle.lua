local LibCustomQuest = LibCustomQuest or {}

local function ReticleOverrides()
    function LCQ_TEST_RETICLE:IsInteractableFoundNotFound(interactionExists)
        local name = GetInteractionTargetName()

        if interactionExists and LCQ_INTERACTIONLISTENER:IsTargetRegisteredInteraction(name) then
            local result, name = true, name
            local action = LCQ_INTERACTIONLISTENER:GetTargetInteractionText(name)

            return true, name, action
        elseif not interactionExists then
			local result, targetName, targetAction = LCQ_TEST_RETICLE:IsValidFurnitureTarget()
			if result then return result, targetName, targetAction end
        end

        return false
    end

	function LCQ_TEST_RETICLE:FurnitureHasInteraction(altName, furnitureName)
		local name = altName or furnitureName
        return LCQ_INTERACTIONLISTENER:IsTargetRegisteredInteraction(name)
	end
end

local function OnInteract()
    if LCQ_TEST_RETICLE:IsThisReticleInstanceValidShowing() then
        local interactionTargetName = LCQ_TEST_RETICLE.contextTarget

        LCQ_INTERACTIONLISTENER:RunInteractionForTarget(interactionTargetName)
    end
end

local function ReticleSetFuncs()
	LCQ_TEST_RETICLE:SetOnInteractFunc(LibCustomQuest.name, OnInteract)
    LCQ_TEST_RETICLE:SetCustomInteractActionAndKeys(nil,"ALCI_INTERACT_KEY","ALCI_INTERACT_KEY")
end

function LibCustomQuest.SetupReticle()
    LCQ_TEST_RETICLE = ALCINamespace:New(LibCustomQuest.name, ALCI_ON_INTERACT_FOUND_NOT_FOUND)
    ReticleOverrides()
	ReticleSetFuncs()
end

function LibCustomQuest.SetFurnitureTargets(furnitureData, owner, houseId)
    LCQ_TEST_RETICLE:SetFurnitureTargets(furnitureData, owner, houseId)
end