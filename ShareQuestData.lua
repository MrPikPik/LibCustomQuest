LibCustomQuestShare = {name = "LibCustomQuestShare"}

local LCQS = LibCustomQuestShare
local name = LibCustomQuestShare.name

local CR = CHAT_ROUTER
local zoStr = zo_strformat
local chatLibPrefix = "<".. "LCQ" ..">"

local function HandleShareQuest(tag, questId)
	local questId = tostring(questId)
	local msgText

	if CUSTOM_QUEST_MANAGER:IsValidCustomQuestId(questId) and (not CUSTOM_QUEST_MANAGER:IsCustomQuestStarted(questId)) then	
		local questName = CUSTOM_QUEST_MANAGER:GetCustomQuestName(questId)
		--msgText = zoStr("Receiving Quest <<1>> From <<2>>", questName, GetUnitDisplayName(tag))
		
		local questName = CUSTOM_QUEST_MANAGER:GetCustomQuestName(questId)
		local characterName, displayName = GetUnitName(tag), GetUnitDisplayName(tag)
		local name = ZO_GetPrimaryPlayerNameWithSecondary(displayName, characterName)

		local data = PLAYER_TO_PLAYER:AddPromptToIncomingQueue(INTERACT_TYPE_QUEST_SHARE, characterName, displayName, zo_strformat(SI_PLAYER_TO_PLAYER_INCOMING_QUEST_SHARE, ZO_SELECTED_TEXT:Colorize(chatLibPrefix.. " " ..name), questName),
			function()
				CUSTOM_QUEST_MANAGER:StartQuest(_, questId)
			end,
			function()
				-- Close Prompt
			end,
			function()
				self:RemoveFromIncomingQueue(INTERACT_TYPE_QUEST_SHARE, characterName, displayName)
			end)
		data.questId = questId
		data.uniqueSounds = {
			accept = SOUNDS.QUEST_SHARE_ACCEPTED,
			decline = SOUNDS.QUEST_SHARE_DECLINED,
		}

	else
		msgText = zoStr("<<1>> attempted to share a quest with you.", GetUnitDisplayName(tag))
		CR:AddSystemMessage(chatLibPrefix .. msgText)
	end
end

local function HandleShareProgress(tag, progressData)
	local noShare = true
	progressData = tostring(progressData)

	local questId = tonumber(progressData:sub(3))
	local stageIndex = tonumber(progressData:sub(1, 1))
	local conditionIndex = tonumber(progressData:sub(2,2))

	local questName = CUSTOM_QUEST_MANAGER:GetCustomQuestName(questId)
	LCQ_DBG:Info("Sharing Update of <<1>>, Stage <<2>>, Condition <<3>>", questName, stage, numConditions)
	ProgressCustomQuestCondition(questId, stageIndex, conditionIndex, noShare)
end

function LibCustomQuestShare.Initialize()
	-- Register Small Map for Custom Quest Share, Big Map for Custom Quest Progress Share
	LCQS.shareCustomQuest = LibDataShare:RegisterMap("LibCustomQuest-ShareQuest", 28, HandleShareQuest)
	LCQS.shareCustomQuestProgress = LibDataShare:RegisterMap("LibCustomQuest-ShareProgress", 8, HandleShareProgress)
end