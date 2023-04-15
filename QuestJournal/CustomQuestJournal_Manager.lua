local QUEST_CAT_ZONE = 1
local QUEST_CAT_OTHER = 2
local QUEST_CAT_MISC = 3

----------
-- LCQ_QuestJournal_Manager
----------

LCQ_QuestJournal_Manager = ZO_CallbackObject:Subclass()

function LCQ_QuestJournal_Manager:New(...)
	local manager = ZO_CallbackObject.New(self)
	manager:Initialize(...)
	return manager
end

function LCQ_QuestJournal_Manager:Initialize(control)
	self.categories = {}
	self.quests = {}

	self:BuildQuestListData()

	self:RegisterForEvents()
end

function LCQ_QuestJournal_Manager:RegisterForEvents()
	local function OnFocusQuestIdChanged(eventCode, questId)
		self.focusedQuestId = questId
	end

	--EVENT_MANAGER:RegisterForEvent("QuestJournal_Manager", EVENT_QUEST_SHOW_JOURNAL_ENTRY, OnFocusQuestIdChanged)

	local function OnAssistChanged(unassistedData, assistedData)
		if assistedData and assistedData.arg1 then
			self.focusedQuestId = assistedData.arg1
		end
	end

	--FOCUSED_QUEST_TRACKER:RegisterCallback("QuestTrackerAssistStateChanged", OnAssistChanged)

	--EVENT_MANAGER:RegisterForEvent("QuestJournal_Manager", EVENT_QUEST_ADDED, OnQuestsUpdated)
	--EVENT_MANAGER:RegisterForEvent("QuestJournal_Manager", EVENT_QUEST_REMOVED, OnQuestsUpdated)
	--EVENT_MANAGER:RegisterForEvent("QuestJournal_Manager", EVENT_QUEST_LIST_UPDATED, OnQuestsUpdated)
end

local function BuildTextHelper(questId, questStage, conditionStep, questStrings)
	local conditionText, _, _, isFailCondition, isComplete, _, isVisible = CUSTOM_QUEST_MANAGER:GetCustomQuestConditionInfo(questId, questStage, conditionStep)

	if isVisible and not isFailCondition and conditionText ~= "" then
		if isComplete then
			conditionText = ZO_DISABLED_TEXT:Colorize(conditionText)
		end

		local taskInfo =
		{
			name = conditionText,
			isComplete = isComplete,
		}

		table.insert(questStrings, taskInfo)
	end
end

function LCQ_QuestJournal_Manager:BuildTextForConditions(questId, stepIndex, numConditions, questStrings)
	local questStage = CUSTOM_QUEST_MANAGER:GetCustomQuestCurrentStage(questId)
	for i = 1, numConditions do
		BuildTextHelper(questId, questStage, i, questStrings)
	end
end

function LCQ_QuestJournal_Manager:BuildTextForTasks(stepOverrideText, questId, questStrings)
	local questStage = CUSTOM_QUEST_MANAGER:GetCustomQuestCurrentStage(questId)

	if stepOverrideText and (stepOverrideText ~= "") then
		BuildTextHelper(questId, questStage, nil, questStrings)
	else
		local conditionCount = CUSTOM_QUEST_MANAGER:GetCustomQuestNumConditions(questId, questStage) --QUEST_MAIN_STEP_INDEX)
		self:BuildTextForConditions(questId, QUEST_MAIN_STEP_INDEX, conditionCount, questStrings)
	end
end

function LCQ_QuestJournal_Manager:DoesShowMultipleOrSteps(stepOverrideText, stepType, questId)
	if stepOverrideText and (stepOverrideText ~= "") then
		return false
	else
		local questStage = CUSTOM_QUEST_MANAGER:GetCustomQuestCurrentStage(questId)
		local conditionCount = CUSTOM_QUEST_MANAGER:GetCustomQuestNumConditions(questId, questStage) --QUEST_MAIN_STEP_INDEX)
		if stepType == QUEST_STEP_TYPE_OR and conditionCount > 1 then
			return true
		else
			return false
		end
	end
end

local function LCQ_QuestJournal_Manager_SortQuestCategories(entry1, entry2)
	if entry1.type == entry2.type then
		return entry1.name < entry2.name
	else
		return entry1.type < entry2.type
	end
end

local function LCQ_QuestJournal_Manager_SortQuestEntries(entry1, entry2)
	if entry1.categoryType == entry2.categoryType then
		if entry1.categoryName == entry2.categoryName then
			return entry1.name < entry2.name
		end

		return entry1.categoryName < entry2.categoryName
	end
	return entry1.categoryType < entry2.categoryType
end

ZO_IS_QUEST_TYPE_IN_OTHER_CATEGORY =
{
	[QUEST_TYPE_MAIN_STORY] = true,
	[QUEST_TYPE_GUILD] = true,
	[QUEST_TYPE_CRAFTING] = true,
	[QUEST_TYPE_HOLIDAY_EVENT] = true,
	[QUEST_TYPE_BATTLEGROUND] = true,
	[QUEST_TYPE_PROLOGUE] = true,
	[QUEST_TYPE_UNDAUNTED_PLEDGE] = true,
	[QUEST_TYPE_COMPANION] = true,
}

function LCQ_QuestJournal_Manager:GetCustomQuestCategoryNameAndType(questType, zone)
	local categoryName, categoryType
	if ZO_IS_QUEST_TYPE_IN_OTHER_CATEGORY[questType] then
		categoryName = GetString("SI_QUESTTYPE", questType)
		categoryType = QUEST_CAT_OTHER
	elseif zone ~= "" then
		categoryName = zo_strformat(SI_QUEST_JOURNAL_ZONE_FORMAT, zone)
		categoryType = QUEST_CAT_ZONE
	else
		categoryName = GetString(SI_QUEST_JOURNAL_GENERAL_CATEGORY)
		categoryType = QUEST_CAT_MISC
	end
	return categoryName, categoryType
end

function LCQ_QuestJournal_Manager:AreQuestsInTheSameCategory(quest1Type, quest1Zone, quest2Type, quest2Zone)
	local quest1IsOtherCategory = ZO_IS_QUEST_TYPE_IN_OTHER_CATEGORY[quest1Type]
	local quest2IsOtherCategory = ZO_IS_QUEST_TYPE_IN_OTHER_CATEGORY[quest2Type]
	if quest1IsOtherCategory ~= quest2IsOtherCategory then
		return false
	else
		if quest1IsOtherCategory then
			return quest1Type == quest2Type
		else
			--true if they have the same zone or if they both have no zone and would end up in the general category
			return quest1Zone == quest2Zone
		end
	end
end

function LCQ_QuestJournal_Manager:FindQuestWithSameCategoryAsCompletedQuest(questId)
	local _, completedQuestType = GetCompletedQuestInfo(questId)
	local completedQuestZone = GetCompletedQuestLocationInfo(questId)
	--for i = 1, MAX_JOURNAL_QUESTS do
	for id, _ in pairs(CUSTOM_QUEST_MANAGER.quests) do
		if CUSTOM_QUEST_MANAGER:IsCustomQuestStarted(id) then
			local questType = CUSTOM_QUEST_MANAGER:GetCustomQuestType(id)
			local zone = CUSTOM_QUEST_MANAGER:GetCustomQuestLocationInfo(id)
			if self:AreQuestsInTheSameCategory(completedQuestType, completedQuestZone, questType, zone) then
				return id
			end
		end 
	end
	return nil
end

function LCQ_QuestJournal_Manager:BuildQuestListData()
	ZO_ClearNumericallyIndexedTable(self.categories)
	ZO_ClearNumericallyIndexedTable(self.quests)

	local addedCategories = {}

	-- Create a table for categories and one for quests
	--for i = 1, MAX_JOURNAL_QUESTS do
	for id, _ in pairs(CUSTOM_QUEST_MANAGER.quests) do
		if CUSTOM_QUEST_MANAGER:IsCustomQuestStarted(id) then
			local zone = CUSTOM_QUEST_MANAGER:GetCustomQuestLocationInfo(id)
			local questType = CUSTOM_QUEST_MANAGER:GetCustomQuestType(id)
			local categoryName, categoryType = self:GetCustomQuestCategoryNameAndType(questType, zone)

			if CUSTOM_QUEST_MANAGER:IsCustomQuestComplete(id) then
				categoryName = GetString(LCQ_QUEST_COMPLETED_CATEGORY)
				categoryType = QUEST_CAT_OTHER
			end

			if not addedCategories[categoryName] then
				table.insert(self.categories, {name = categoryName, type = categoryType})
				addedCategories[categoryName] = true
			end

			local name = CUSTOM_QUEST_MANAGER:GetCustomQuestName(id)
			if name == "" then
				name = GetString(SI_QUEST_JOURNAL_UNKNOWN_QUEST_NAME)
			end

			local level = CUSTOM_QUEST_MANAGER:GetCustomQuestLevel(id)
			local instanceDisplayType = CUSTOM_QUEST_MANAGER:GetCustomQuestInstanceDisplayType(id)

			table.insert(self.quests,
				{
					name = name,
					questId = id,
					level = level,
					categoryName = categoryName,
					categoryType = categoryType,
					questType = questType,
					displayType = instanceDisplayType
				}
			)
		end
	end

	-- Sort the tables
	table.sort(self.categories, LCQ_QuestJournal_Manager_SortQuestCategories)
	table.sort(self.quests, LCQ_QuestJournal_Manager_SortQuestEntries)

	self:FireCallbacks("QuestListUpdated")
end

function LCQ_QuestJournal_Manager:GetQuestListData()
	return self.quests, self.categories
end

function LCQ_QuestJournal_Manager:GetQuestList()
	return self.quests
end

function LCQ_QuestJournal_Manager:GetCustomQuestCategories()
	return self.categories
end

function LCQ_QuestJournal_Manager:GetNextSortedQuestForQuestId(questId)
	for i, quest in ipairs(self.quests) do
		if quest.questId == questId then
			local nextQuest = (i == #self.quests) and 1 or (i + 1)
			return self.quests[nextQuest].questId
		end
	end
end

function LCQ_QuestJournal_Manager:ConfirmAbandonQuest(questId)
	local questName = CUSTOM_QUEST_MANAGER:GetCustomQuestName(questId)
	local questLevel = CUSTOM_QUEST_MANAGER:GetCustomQuestLevel(questId)
	local conColorDef = ZO_ColorDef:New(GetConColor(questLevel))
	questName = conColorDef:Colorize(questName)

	ZO_Dialogs_ShowPlatformDialog("ABANDON_CUSTOM_QUEST", {questId = questId}, {mainTextParams = {questName}})
end

function LCQ_QuestJournal_Manager:ShareQuest(questId)
	ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.QUEST_SHARE_SENT, GetString(SI_QUEST_SHARED))
	LibCustomQuestShare.shareCustomQuest:QueueData(CUSTOM_QUEST_MANAGER:GetQuestHash(questId))
end

--Not Updated
--[[function LCQ_QuestJournal_Manager:UpdateFocusedQuest()
	local focusedQuestId = nil
	local numTrackedQuests = GetNumTracked()
	for i=1, numTrackedQuests do
		local trackType, arg1, arg2 = GetTrackedById(i)
		if GetTrackedIsAssisted(trackType, arg1, arg2) then
			focusedQuestId = arg1
			break
		end
	end

	self.focusedQuestId = focusedQuestId
end

function LCQ_QuestJournal_Manager:GetFocusedQuestId()
	return self.focusedQuestId
end]]

LCQ_QUEST_JOURNAL_MANAGER = LCQ_QuestJournal_Manager:New()