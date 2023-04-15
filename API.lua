function StartCustomQuest(quest, questId)
	questId = quest ~= nil and quest.id or questId
	CUSTOM_QUEST_MANAGER:StartQuest(_, questId)
end

function IsCustomQuestStarted(questId)
	return CUSTOM_QUEST_MANAGER:IsCustomQuestStarted(questId)
end

function IsCustomQuestConditionComplete(questId, stageIndex, conditionIndex)
	return CUSTOM_QUEST_MANAGER:IsConditionComplete(questId, stageIndex, conditionIndex)
end

function ProgressCustomQuestCondition(questId, stageIndex, conditionIndex, suppressSharing)
	LCQ_DBG:Info("Received condition completion request for quest <<1>> at stage <<2>>, condition <<3>>", questId, stageIndex, conditionIndex)
	local stage, conditions = CUSTOM_QUEST_MANAGER:GetCustomQuestProgress(questId)
	if stage ~= stageIndex then 
		LCQ_DBG:Info("<<1>> is at stage <<2>>. Request aborted", questId, stage)
	else
		if not CUSTOM_QUEST_MANAGER:IsConditionComplete(questId, stageIndex, conditionIndex) then
			CUSTOM_QUEST_MANAGER:OnConditionComplete(questId, conditionIndex, suppressSharing)
		end
	end
end

function IsCustomQuestComplete(questId)
	return CUSTOM_QUEST_MANAGER:IsCustomQuestComplete(questId)
end

function CompleteCustomQuest(questId)
	LCQ_DBG:Info("Received completion request for quest <<1>>", questId)

	-- Quest is complete!
	LCQ_DBG:Info("Custom Quest with id \"<<1>>\" complete", questId)
	CUSTOM_QUEST_MANAGER:SetQuestComplete(questId)
	LibCustomQuest.CenterAnnounce(CUSTOM_EVENT_CUSTOM_QUEST_COMPLETE, questId)
	CUSTOM_QUEST_MANAGER:FireCallbacks("OnCustomQuestsUpdated", questId)
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
	elseif GetUnitName("reticleover") ~= "" and not IsUnitPlayer("reticleover") then
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

	--LCQ_DBG:Log("Distance to reticleover: <<1>>", LCQ_DBG_ALWAYS_SHOW, tostring(d))
	return zo_distance3D(x1, y1, z1, x2, y2, z2) --Returns (number) 3D distance --Units will be in whatever units you pass in
end

function GetDistanceToPoint(x, y, z)
	x, y, z = x or 0, y or 0, z or 0
	local _, x1, y1, z1 = GetUnitWorldPosition("player")
	return zo_distance3D(x, y, z, x1, y1, z1) --Returns (number) 3D distance --Units will be in whatever units you pass in
end