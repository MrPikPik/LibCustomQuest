---------------------
-- LCQ_QuestSharer --
---------------------
LCQ_QuestSharer = ZO_Object:Subclass()

function LCQ_QuestSharer:New()
    local sharer = ZO_Object.New(self)
    sharer:Initialize()
    return sharer
end

function LCQ_QuestSharer:Initialize()
    LCQ_DBG:Verbose("LCQ_QuestSharer: Initializing...")

	-- Is there possibly a better way to detect LibDataShare?s
	if LibDataShare then
        LCQ_DBG:Info("LCQ_QuestSharer: LibDataShare found. Quest sharing and syncing will be enabled.")

		-- Register Small Map for Custom Quest Share, Big Map for Custom Quest Progress Share
		self.shareCustomQuest = LibDataShare:RegisterMap("LibCustomQuest-ShareQuest", 28, function(...) self:HandleShareQuest(...) end)
		self.shareCustomQuestProgress = LibDataShare:RegisterMap("LibCustomQuest-ShareProgress", 8, function(...) self:HandleShareProgress(...) end)

		self.enabled = true
    else
        LCQ_DBG:Info("LCQ_QuestSharer: LibDataShare not found. Quest sharing will be disabled.")
		self.enabled = false
    end
end

function LCQ_QuestSharer:IsQuestSharingEnabled()
	return self.enabled
end

function LCQ_QuestSharer:HandleShareQuest(tag, sharedQuestId)
	if not self.enabled then return end

	local questId = CUSTOM_QUEST_MANAGER:GetQuestIdFromHash(sharedQuestId)
	local msgText

	if CUSTOM_QUEST_MANAGER:IsValidCustomQuestId(questId) and (not CUSTOM_QUEST_MANAGER:IsCustomQuestStarted(questId)) then
		local questName = CUSTOM_QUEST_MANAGER:GetCustomQuestName(questId)
		--msgText = zoStr("Receiving Quest <<1>> From <<2>>", questName, GetUnitDisplayName(tag))
		
		local questName = CUSTOM_QUEST_MANAGER:GetCustomQuestName(questId)
		local characterName, displayName = GetUnitName(tag), GetUnitDisplayName(tag)
		local name = ZO_GetPrimaryPlayerNameWithSecondary(displayName, characterName)

		local data = PLAYER_TO_PLAYER:AddPromptToIncomingQueue(INTERACT_TYPE_QUEST_SHARE, characterName, displayName, zo_strformat(SI_PLAYER_TO_PLAYER_INCOMING_QUEST_SHARE, ZO_SELECTED_TEXT:Colorize("[LibCustomQuest] " .. name), questName),
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
		LCQ_DBG:Log("<<1>> attempted to share a quest with you.", LCQ_DBG_INFO, GetUnitDisplayName(tag))
	end
end

function LCQ_QuestSharer:HandleShareProgress(tag, progressData)
	if not self.enabled then return end

	local noShare = true
	progressData = tostring(progressData)

	local questId = CUSTOM_QUEST_MANAGER:GetQuestIdFromHash(tonumber(progressData:sub(3)))
	local stageIndex = tonumber(progressData:sub(1, 1))
	local conditionIndex = tonumber(progressData:sub(2,2))

	local questName = CUSTOM_QUEST_MANAGER:GetCustomQuestName(questId)
	LCQ_DBG:Info("Sharing Update of <<1>>, Stage <<2>>, Condition <<3>>", questName, stageIndex, conditionIndex)
	ProgressCustomQuestCondition(questId, stageIndex, conditionIndex, noShare)
end