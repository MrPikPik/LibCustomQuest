---------------------
-- LCQ_QuestSharer --
---------------------

-- Format for shared data is ABBCCDDDDDDDDDD...
-- A: Leading 1
-- B: 2 digit stage 00 .. 99
-- C: 2 digit conditionIndex 00 .. 99
-- D: Remainder is the hashed questId

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
		self.shareCustomQuest = LibDataShare:RegisterMap("LibCustomQuest-ShareQuest", 28, function(...) self:IncomingQuestShareHandler(...) end)
		self.shareCustomQuestProgress = LibDataShare:RegisterMap("LibCustomQuest-ShareProgress", 8, function(...) self:IncomingQuestProgressShareHandler(...) end)

		self.enabled = true
    else
        LCQ_DBG:Info("LCQ_QuestSharer: LibDataShare not found. Quest sharing will be disabled.")
		self.enabled = false
    end
end

function LCQ_QuestSharer:IsQuestSharingEnabled()
	return self.enabled
end

function LCQ_QuestSharer:IncomingQuestShareHandler(tag, sharedQuestId)
	if not self:IsQuestSharingEnabled() then
		LCQ_DBG:Warn("LCQ_QuestSharer: Received remote quest sharing request, but sharing is not enabled. Ignoring request.")
		return
	end

	local questId = CUSTOM_QUEST_MANAGER:GetQuestIdFromHash(sharedQuestId)
	if CUSTOM_QUEST_MANAGER:IsValidCustomQuestId(questId) and (not CUSTOM_QUEST_MANAGER:IsCustomQuestStarted(questId)) then
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
		LCQ_DBG:Info("<<1>> attempted to share a quest with you which is either invalid or has already been started. QuestId: <<2>>", GetUnitDisplayName(tag), questId)
	end
end

function LCQ_QuestSharer:IncomingQuestProgressShareHandler(tag, progressData)
	if not self:IsQuestSharingEnabled() then
		LCQ_DBG:Warn("LCQ_QuestSharer: Received remote quest update sharing request, but sharing is not enabled. Ignoring request.")
		return
	end

	-- Parse out progress
	progressData = tostring(progressData)

	-- The leading 1 is our "magic delimiter" as numbers lower than 10 would have a leading 0 which would get truncated.
	local stageIndex = tonumber(progressData:sub(2, 3))
	local conditionIndex = tonumber(progressData:sub(4, 5))
	local questId = CUSTOM_QUEST_MANAGER:GetQuestIdFromHash(tonumber(progressData:sub(6)))

	local questName = CUSTOM_QUEST_MANAGER:GetCustomQuestName(questId)
	LCQ_DBG:Debug("LCQ_QuestSharer: Received sharing update for '<<1>>', Stage <<2>>, Condition <<3>>", questName, stageIndex, conditionIndex)

	local SUPPRESS_SHARE = true
	ProgressCustomQuestCondition(questId, stageIndex, conditionIndex, SUPPRESS_SHARE)
end

function LCQ_QuestSharer:QueueQuest(questId)
	if not self:IsQuestSharingEnabled() then
		LCQ_DBG:Warn("LCQ_QuestSharer: Received local quest sharing request, but sharing is not enabled. Ignoring request.")
		return
	end
	if not questId then
		LCQ_DBG:Error("LCQ_QuestSharer: Received local quest sharing request with missing questId.")
		return
	end

	local questHash = CUSTOM_QUEST_MANAGER:GetQuestHash(questId)
	LCQ_DBG:Debug("LCQ_QuestSharer: Sharing quest: '<<1>>' (Hash <<2>>)", questId, questHash)
	self.shareCustomQuest:QueueData(questHash)
end

function LCQ_QuestSharer:QueueQuestUpdate(questId, stage, conditionIndex)
	if not self:IsQuestSharingEnabled() then
		LCQ_DBG:Warn("LCQ_QuestSharer: Received local quest update sharing request, but sharing is not enabled. Ignoring request.")
		return
	end
	if not questId or not stage or not conditionIndex then
		LCQ_DBG:Error("LCQ_QuestSharer: Received local quest update sharing request with missing parameter(s).")
		return
	end


	-- The leading 1 is our "magic delimiter" as numbers lower than 10 would have a leading 0 which would get truncated.
	local questHash = CUSTOM_QUEST_MANAGER:GetHashFromQuestId(questId)
	local progressData = string.format("1%.2d%.2d%s", stage, conditionIndex, questHash)
	LCQ_DBG:Debug("LCQ_QuestSharer: Sharing data: '<<1>>' [1.<<2>>.<<3>>.<<4>>]", progressData, stage, conditionIndex, questHash)
	self.shareCustomQuestProgress:QueueData(tonumber(progressData))
end