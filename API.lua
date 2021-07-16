function ProgressCustomQuestCondition(questId, stageIndex, conditionIndex)
    LCQ_DBG:Info("Received completion request for quest <<1>> at stage <<2>>, condition <<3>>", questId, stageIndex, conditionIndex)
    if not CUSTOM_QUEST_MANAGER:IsConditionComplete(questId, conditionIndex) then
        CUSTOM_QUEST_MANAGER:OnConditionComplete(questId, conditionIndex)
    end
end

function GetInteractionTargetName()
    local interactionExists, interactionAvailableNow, questInteraction, questTargetBased, questJournalIndex, questToolIndex, questToolOnCooldown = GetGameCameraInteractableInfo()
    local action, interactableName, interactionBlocked, isOwned, additionalInteractInfo, context, contextLink, isCriminalInteract = GetGameCameraInteractableActionInfo()

    -- Prioritization:
    -- 1. Base game interactibles (NPCs, containers, doors, etc.)
    -- 2. Reticle/Look-At target
    -- 3. Players

    if interactionExists and interactableName ~= "" and interactableName ~= nil then
        return interactableName
    elseif GetUnitName("reticleover") ~= "" and not IsUnitPlayer("reticleover") and (GetDistanceToReticleOverTarget() < 350) then -- TODO: Distance check "GetDistanceToReticleOverTarget() < 500"?
        LCQ_DBG:Debug("Interaction target has no range check!")
        return GetUnitName("reticleover")
    elseif PLAYER_TO_PLAYER:HasTarget() then
        return PLAYER_TO_PLAYER.currentTargetDisplayName
    else
        return ""
    end
end

function GetDistanceToReticleOverTarget()
    if not DoesUnitExist("reticleover") then return -1 end
    local _, x1, y1, z1 = GetUnitWorldPosition("player")
    local _, x2, y2, z2 = GetUnitWorldPosition("reticleover")
    local dx, dy, dz = x2 - x1, y2 - y1, z2 - z1
    local d = math.sqrt(dx*dx + dy*dy + dz*dz)
    --LCQ_DBG:Log("Distance to reticleover: <<1>>", LCQ_DBG_ALWAYS_SHOW, tostring(d))
    return d
end

function GetDistanceToPoint(x, y, z)
    x, y, z = x or 0, y or 0, z or 0
    local _, x1, y1, z1 = GetUnitWorldPosition("player")
    local dx, dy, dz = x - x1, y - y1, z - z1
    return math.sqrt(dx*dx + dy*dy + dz*dz)
end