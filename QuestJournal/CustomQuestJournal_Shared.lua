---------------------
--Quest Journal Shared
---------------------

LCQ_QuestJournal_Shared = ZO_CallbackObject:Subclass()

function LCQ_QuestJournal_Shared:New()
	local newObject = ZO_CallbackObject.New(self)

	return newObject
end

function LCQ_QuestJournal_Shared:Initialize(control)
	self.control = control
	self.listDirty = true

	self.questStrings = {}
	self.icons = {}
	self.tooltips = {}

	self:RegisterIcons()
	self:RegisterTooltips()

	self:InitializeQuestList(control)
	self:InitializeKeybindStripDescriptors()
	self:RefreshQuestList()
	self:RefreshQuestCount()
	self:InitializeScenes()

	LCQ_QUEST_JOURNAL_MANAGER:RegisterCallback("QuestListUpdated", function() self:OnQuestsUpdated() end)

	--control:RegisterForEvent(EVENT_QUEST_ADVANCED, function(eventCode, questId) self:OnQuestAdvanced(questId) end)
	--control:RegisterForEvent(EVENT_QUEST_CONDITION_COUNTER_CHANGED, function(eventCode, ...) self:OnQuestConditionInfoChanged(...) end)
	--control:RegisterForEvent(EVENT_QUEST_CONDITION_OVERRIDE_TEXT_CHANGED, function(eventCode, index) self:OnQuestConditionInfoChanged(index) end)
	--control:RegisterForEvent(EVENT_LEVEL_UPDATE, function(eventCode, unitTag) self:OnLevelUpdated(unitTag) end)
	--control:AddFilterForEvent(EVENT_LEVEL_UPDATE, REGISTER_FILTER_UNIT_TAG, "player")
end

local function QuestJournal_Shared_RegisterDataInTable(table, questType, instanceDisplayType, data)
	local questTableIndex = questType or ZO_ANY_QUEST_TYPE
	table[questTableIndex] = table[questTableIndex] or {}

	table[questTableIndex][instanceDisplayType or ZO_ANY_INSTANCE_DISPLAY_TYPE] = data
end

local function QuestJournal_Shared_GetDataFromTable(table, questType, instanceDisplayType)
	local data

	-- Attempt to pull data specifically for this quest type first
	if table[questType] then
		data = table[questType][instanceDisplayType] or table[questType][ZO_ANY_INSTANCE_DISPLAY_TYPE]
	end

	-- If we didn't find specific data for this quest type, try to fetch it for any quest type
	if data == nil and table[ZO_ANY_QUEST_TYPE] then
		data = table[ZO_ANY_QUEST_TYPE][instanceDisplayType] or table[ZO_ANY_QUEST_TYPE][ZO_ANY_INSTANCE_DISPLAY_TYPE]
	end

	return data
end

--TODO: Get ride of this exstensibility.  The icon should only be controlled by the display type.
function LCQ_QuestJournal_Shared:RegisterIconTexture(questType, instanceDisplayType, texturePath)
	QuestJournal_Shared_RegisterDataInTable(self.icons, questType, instanceDisplayType, texturePath)
end

function LCQ_QuestJournal_Shared:GetIconTexture(questType, instanceDisplayType)
	return QuestJournal_Shared_GetDataFromTable(self.icons, questType, instanceDisplayType)
end

function LCQ_QuestJournal_Shared:RegisterTooltipText(questType, instanceDisplayType, stringIdOrText, paramsFunction)
	local tooltipText = type(stringIdOrText) == "number" and GetString(stringIdOrText) or stringIdOrText

	local data = tooltipText
	if paramsFunction then 
		data =
		{
			text = tooltipText,
			paramsFunction = paramsFunction,
		}
	end

	QuestJournal_Shared_RegisterDataInTable(self.tooltips, questType, instanceDisplayType, data)
end

function LCQ_QuestJournal_Shared:GetTooltipText(questType, instanceDisplayType, questId)
	local data = QuestJournal_Shared_GetDataFromTable(self.tooltips, questType, instanceDisplayType)
	local text = data
	if type(data) == "table" then
		text = zo_strformat(data.text, data.paramsFunction(questId))
	end
	return text
end

function LCQ_QuestJournal_Shared:InitializeQuestList()
	-- Should be overridden
end

function LCQ_QuestJournal_Shared:InitializeKeybindStripDescriptors()
	-- Should be overridden
end

function LCQ_QuestJournal_Shared:InitializeScenes()
	-- Should be overridden
end

function LCQ_QuestJournal_Shared:GetSelectedQuestData()
	-- Should be overridden
end

function LCQ_QuestJournal_Shared:RefreshQuestList()
	-- Should be overridden
end

function LCQ_QuestJournal_Shared:RegisterIcons()
	-- Should be overridden
end

function LCQ_QuestJournal_Shared:RegisterTooltips()
	-- Should be overridden
end

function LCQ_QuestJournal_Shared:OnLevelUpdated(unitTag)
	if self.control:IsHidden() then
		self.listDirty = true
	else
		self:RefreshQuestList()
	end
end

function LCQ_QuestJournal_Shared:BuildTextForStepVisibility(questId, visibilityType)
	local questStage = CUSTOM_QUEST_MANAGER:GetCustomQuestCurrentStage(questId)
	local numSteps = CUSTOM_QUEST_MANAGER:GetCustomQuestNumSteps(questId, questStage)

	local questStrings = self.questStrings

	if visibilityType == QUEST_STEP_VISIBILITY_HINT then
		stepJournalText, visibility, _, stepOverrideText = CUSTOM_QUEST_MANAGER:GetCustomQuestStepInfo(questId, questStage)

		if visibility == visibilityType then
			if stepJournalText ~= "" then
				table.insert(questStrings, zo_strformat(SI_QUEST_JOURNAL_TEXT, stepJournalText))
			end
			
			if stepOverrideText and (stepOverrideText ~= "") then
				table.insert(questStrings, stepOverrideText)
			end
		end
	end

	for stepIndex = 1, numSteps do
		local stepJournalText, visibility, stepOverrideText

		if visibilityType == QUEST_STEP_VISIBILITY_OPTIONAL then
			stepJournalText, visibility, _, stepOverrideText = CUSTOM_QUEST_MANAGER:GetCustomQuestStepInfo(questId, questStage, stepIndex)
		end

		-- Handle completed optional objectives
		if visibility == QUEST_STEP_VISIBILITY_OPTIONAL and CUSTOM_QUEST_MANAGER:IsConditionComplete(questId, questStage, stepIndex) then
			stepJournalText = ZO_DISABLED_TEXT:Colorize(stepJournalText)
		end

		if visibility == visibilityType then
			if stepJournalText ~= "" then
				table.insert(questStrings, zo_strformat(SI_QUEST_JOURNAL_TEXT, stepJournalText))
			end
			
			if stepOverrideText and (stepOverrideText ~= "") then
				table.insert(questStrings, stepOverrideText)
			end
		end
	end
end

function LCQ_QuestJournal_Shared:GetSelectedQuestId()
	local selectedData = self:GetSelectedQuestData()
	return selectedData and selectedData.questId
end

function LCQ_QuestJournal_Shared:CanAbandonQuest()
	local selectedData = self:GetSelectedQuestData()
	if selectedData and selectedData.questId and selectedData.questType ~= QUEST_TYPE_MAIN_STORY then
		return true
	end
	return false
end

function LCQ_QuestJournal_Shared:CanShareQuest()
	local selectedQuestId = self:GetSelectedQuestId()
	if selectedQuestId and LibDataShare then -- Need LibDataShare to share quest info
		return CUSTOM_QUEST_MANAGER:GetIsCustomQuestSharable(selectedQuestId) and IsUnitGrouped("player")
	end
	return false
end

function LCQ_QuestJournal_Shared:RefreshDetails()
	--to be overridden
end

function LCQ_QuestJournal_Shared:RefreshQuestCount()
	-- This function is overridden by sub-classes.
end

function LCQ_QuestJournal_Shared:OnQuestsUpdated()
	if self.control:IsHidden() then
		self.listDirty = true
	else
		self:RefreshQuestCount()
		self:RefreshQuestList()
	end
end

function LCQ_QuestJournal_Shared:OnQuestAdvanced(questId)
	local selectedQuestId = self:GetSelectedQuestId()
	if questId == selectedQuestId then
		self:RefreshDetails()
	end
end

function LCQ_QuestJournal_Shared:OnQuestConditionInfoChanged(questId, questName, conditionText, conditionType, curCondtionVal, newConditionVal, conditionMax, isFailCondition, stepOverrideText, isPushed, isQuestComplete, isConditionComplete, isStepHidden, isConditionCompleteStatusChanged, isConditionCompletableBySiblingStatusChanged)
	local selectedQuestId = self:GetSelectedQuestId()
	if questId == selectedQuestId then
		self:RefreshDetails()
	end
end

function LCQ_QuestJournal_Shared:ShowOnMap()
   local selectedQuestId = self:GetSelectedQuestId()
   if selectedQuestId then
   		d("ShowOnMap() not implemented")
		--ZO_WorldMap_ShowQuestOnMap(selectedQuestId)
	end
end

function LCQ_QuestJournal_Shared:GetNextSortedQuestForQuestId(questId)
	return LCQ_QUEST_JOURNAL_MANAGER:GetNextSortedQuestForQuestId(questId)
end
