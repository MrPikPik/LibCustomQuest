-----------------------------------------
-- Custom Quest Manager
-----------------------------------------

CustomQuest_Manager = ZO_Object:Subclass()

-- Creates a new instance of the CustomQuest_Manager object
function CustomQuest_Manager:New()
    local manager = ZO_Object.New(self)
    manager:Initialize()
    return manager
end

-- Initializes a CustomQuest_Manager object
function CustomQuest_Manager:Initialize()
    self.quests = {}
    self.progress = {}
end

-- Registers a quest to the CustomQuest_Manager object.
-- Ensure you call with a well formed quest object
function CustomQuest_Manager:RegisterQuest(quest)
    assert(quest and quest.id, "No quest given or no ID found.")
    if self.quests[quest.id] ~= nil then
        error("Quest ID already in use.")
    else
        -- Instantiate quest object
        self.quests[quest.id] = CustomQuest:New(quest.id, quest.name, quest.text, quest.level, quest.location, quest.instanceDisplayType, quest.stages, quest.outcome, quest.repeatable)

        self.progress[quest.id] = {stage = 1, conditions = {}}

        return quest.id
    end
end

function CustomQuest_Manager:StartQuest(quest, questId)
    local id
    if questId then
        id = questId
    else
        id = quest.id
    end
    
    if not self.quests[id] then
        if not quest then return end
        self:RegisterQuest(quest)
    end

    local stage, conditions = self:GetCustomQuestProgress(id)
    local suppressCSA = false --not (stage == 1 and conditions == {})
    if not suppressCSA then
        LibCustomQuest.CenterAnnounce(CUSTOM_EVENT_CUSTOM_QUEST_ADDED, id)
    end
    
    self:UpdateQuestListeners(id, suppressCSA)
end

function CustomQuest_Manager:UpdateQuestListeners(questId, suppressCSA)
    local suppressCSA = suppressCSA or false
    local stage, conditions = self:GetCustomQuestProgress(questId)
    local _, _, _, _, numConditions = self:GetCustomQuestStepInfo(questId, stage)

    LCQ_DBG:Info("<<1>>: Stage <<2>> with <<3>> tasks", questId, stage, numConditions)

    for i = 1, numConditions do
        if not conditions[i] then
            -- Announce condition
            if not suppressCSA then
                LibCustomQuest.CenterAnnounce(CUSTOM_EVENT_CUSTOM_QUEST_OBJECTIVE_ADDED, questId, stage, i)
            end

            -- Start listening for the condition's condition
            local task = self.quests[questId].stages[stage].tasks[i]
            local type = task.type
            if not type then
                LCQ_DBG:Critical("Task type is nil! <<1>>", self.GetCustomQuestName(questId))
            end

            if type == QUEST_CONDITION_TYPE_LOCATION then
                LCQ_COORDINATELISTENER:Listen(task.data, questId, i)
                LCQ_DBG:Verbose("Added coordinate target for <<1>>", task.text)
            elseif type == QUEST_CONDITION_TYPE_TALK then
                LCQ_INTERACTIONLISTENER:Listen(task.data, questId, i)
                LCQ_DBG:Verbose("Added dialog target for <<1>>", task.data.name)
            elseif type == QUEST_CONDITION_TYPE_INTERACT then
                -- This is added with "read" interaction, but could be similar for all interaction types – (all would use the INTERACTIONLISTENTER?)
                LCQ_INTERACTIONLISTENER:Listen(task.data, questId, i)
                LCQ_DBG:Verbose("Added interaction target for <<1>>", task.data.name)                
            end
        end
    end
end

function CustomQuest_Manager:OnConditionComplete(questId, conditionId)
    LCQ_DBG:Verbose("Condition complete for QuestID <<1>>", questId)
    local stage = self.quests[questId].currentStage
    self.quests[questId].stages[stage].tasks[conditionId].complete = true
    self:SetQuestConditionComplete(questId, conditionId)

    LibCustomQuest.CenterAnnounce(CUSTOM_EVENT_CUSTOM_QUEST_OBJECTIVE_COMPLETED, questId, stage, conditionId)

    local allComplete = true
    -- Check for incomplete conditions
    for index, task in ipairs(self.quests[questId].stages[stage].tasks) do
        if not task.complete then
            LCQ_DBG:Verbose("Task with index <<1>> is incomplete", index)
            allComplete = false
        end
    end

    -- If all conditions are fulfilled, progress stage
    if allComplete then
        LCQ_DBG:Info("All tasks are complete, progressing stage")
        LCQ_INTERACTIONLISTENER:RemoveAllForQuestId(questId)
        self:AdvanceQuestStage(questId)

        if self.quests[questId].currentStage <= #self.quests[questId].stages then
            self:UpdateQuestListeners(questId)
        else
            -- Quest is complete!
            LCQ_DBG:Info("Custom Quest with id \"<<1>>\" complete", questId)
            self:SetQuestComplete(questId)
            LibCustomQuest.CenterAnnounce(CUSTOM_EVENT_CUSTOM_QUEST_COMPLETE, questId)
        end
    end
end

-- Get quest data by ID
function CustomQuest_Manager:GetCustomQuest(questId)
    if self.quests[questId] ~= nil then
        return self.quests[questId]
    else
        return nil
    end
end

function CustomQuest_Manager:GetCustomQuestConditionText(questId, stage, condition)
    return self.quests[questId].stages[stage].tasks[condition].text
end

-----------------------------------------
-- Quest progress
-----------------------------------------

-- Progress structure:
--
-- progress[id] = {
--    stage = currentStage,
--    conditions = {
--        [1] = condition 1 done,
--        [2] = condition 2 done,
--        [3] = condition 3 done,
--        ...
--    }
--}
--
-- When progressing a stage, reset the conditions table to match the number of conditions of the new step

-- Gets the progress of a specified quest's stage's condition/task
function CustomQuest_Manager:GetCustomQuestProgress(questID)
    local stage = 1
    local conditions = {}

    if self.progress[questID] then
        -- Stage
        if self.progress[questID].stage then
           stage = self.progress[questID].stage
        end
        -- Conditions
        if self.progress[questID].conditions then
            conditions = self.progress[questID].conditions
        end
    end
    return stage, conditions
end

function CustomQuest_Manager:IsConditionComplete(questId, conditionIndex)
    if not questId then return false end
    local _, conditions = self:GetCustomQuestProgress(questId)
    return conditions[conditionIndex]
end

function CustomQuest_Manager:IsCustomQuestComplete(questId)
    return self.progress[questId].completed
end

function CustomQuest_Manager:AdvanceQuestStage(questId)
    local stage = self.quests[questId].currentStage
    self.quests[questId].currentStage = stage + 1
    self.progress[questId].stage = stage + 1
    self.progress[questId].conditions = {}
end

function CustomQuest_Manager:SetQuestConditionComplete(questId, conditionIndex)
    if not self.progress[questId].conditions then
        self.progress[questId].conditions = {}
    end
    self.progress[questId].conditions[conditionIndex] = true
end

function CustomQuest_Manager:SetQuestComplete(questId)
    self.progress[questId].completed = true
    self.quests[questId].completed = true
end

-----------------------------------------
-- Quest data
-----------------------------------------

-- Gets the zone name of a quest. This is used for grouping in the journal
function CustomQuest_Manager:GetCustomQuestLocationInfo(questId)
    local quest = self:GetCustomQuest(questId)
    if quest then
        return quest.location
    end
end

-- Gets the type of the quest
function CustomQuest_Manager:GetCustomQuestType(questId)
    local quest = self:GetCustomQuest(questId)
    if quest then
        return quest.type
    end
end

-- Gets the name of the quest
function CustomQuest_Manager:GetCustomQuestName(questId)
    local quest = self:GetCustomQuest(questId)
    if quest then
        return quest.name
    end
end

-- Gets the level requirement/recommendation of the quest
function CustomQuest_Manager:GetCustomQuestLevel(questId)
    local quest = self:GetCustomQuest(questId)
    if quest then
        return quest.level
    end
end

-- Gets the instance display type of the quest, e.g. trial, dungeon, etc.
function CustomQuest_Manager:GetCustomQuestInstanceDisplayType(questId)
    local quest = self:GetCustomQuest(questId)
    if quest then
        return quest.instanceDisplayType
    end
end

-- Gets the quest repeat type (can account for more than just repeatable/not-repeatable)
function CustomQuest_Manager:GetCustomQuestRepeatType(questId)
    local quest = self:GetCustomQuest(questId)

    if quest then
        return quest.repeatType
    end
end

-- Gets the number of conditions in the quest stage
function CustomQuest_Manager:GetCustomQuestNumConditions(questId, questStage) --stepIndex)
    local quest = self:GetCustomQuest(questId)
    if quest.stages[questStage] then
        return #quest.stages[questStage].tasks
    end
end

-- Gets the condition info
function CustomQuest_Manager:GetCustomQuestConditionInfo(questId, stage, condition)
    local quest = self:GetCustomQuest(questId)

    if quest.stages and quest.stages[stage] ~= nil then
        local stage = quest.stages[stage]
        if stage.tasks and stage.tasks[condition] ~= nil then
            local task = stage.tasks[condition]

            local conditionText = task.text
            local currentCount = 1 or nil --self.GetCustomQuestProgress(questID, stage, task)
            local maxCount = #stage.tasks or nil --task.max or 0
            local isFailCondition = false
            local isComplete = task.complete --(currentCount >= maxCount) -- ???
            local isVisible = not task.invisible or true
            local conditionType = "???"

            return conditionText, currentCount, maxCount, isFailCondition, isComplete, _, isVisible, conditionType
        end
    end
end

-- Gets the number of stages in the quest
function CustomQuest_Manager:GetCustomQuestNumSteps(journalQuestId)
    d("GetCustomQuestNumSteps not in use.")
end

-- Gets the info for the specific step
function CustomQuest_Manager:GetCustomQuestStepInfo(questId, questStage) 
    local quest = self:GetCustomQuest(questId)
    if quest.stages[questStage] then
        local stepText = self.quests[questId].stages[questStage].hint or nil
        local visibility = quest.stages[questStage].visibility or nil
        local stepType = quest.stages[questStage].type or 0
        local trackerOverrideText = quest.stages[questStage].overrideText or ""
        local numConditions = #quest.stages[questStage].tasks

        return stepText, visibility, stepType, trackerOverrideText, numConditions
    end
end

function CustomQuest_Manager:GetCustomQuestCurrentStage(questId)
    return self.quests[questId].currentStage
end

function CustomQuest_Manager:GetCustomQuestInfo(questId)
    local quest = self:GetCustomQuest(questId)

    local questStage = self:GetCustomQuestCurrentStage(questId)
    local stage = quest.stages[questStage] or {}

    local questName = self:GetCustomQuestName(questId)
    local bgText = quest.text
    local activeStepText = stage.text or "No text provided"
    local activeStepType = nil --
    local activeStepTrackerOverrideText = "" --
    local completed = self:IsCustomQuestComplete(questId)
    local tracked = false --
    local questLevel = self:GetCustomQuestLevel(questId)
    local pushed = nil --
    local questType = self:GetCustomQuestType(questId)
    local instanceDisplayType = self:GetCustomQuestInstanceDisplayType(questId)

    return questName, bgText, activeStepText, activeStepType, activeStepTrackerOverrideText, completed, tracked, questLevel, _, questType, instanceDisplayType  
end

--To Do:
function CustomQuest_Manager:GetCustomQuestEnding(questId)
    local quest = self:GetCustomQuest(questId)

    local goal = quest.goal or "" --
    local dialog = quest.dialog or "" --
    local confirmComplete = quest.confirmComplete or "" --
    local declineComplete = quest.declineComplete or "" --
    local backgroundText = quest.outcome or ""
    local journalStepText = quest.endStepText or "" --

	return goal, dialog, confirmComplete, declineComplete, backgroundText, journalStepText
end

function CustomQuest_Manager:GetIsCustomQuestSharable(questId)
    return false
end

function CustomQuest_Manager:GetNumCustomJournalQuests()
    local count = 0

    for _, _ in pairs(self.quests) do
        count=count+1
    end

    return count
end

function CustomQuest_Manager:IsValidCustomQuestId(questId)
    return self:GetCustomQuest(questId)
end

CUSTOM_QUEST_MANAGER = CustomQuest_Manager:New()
