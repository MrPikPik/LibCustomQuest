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
        self.quests[quest.id] = CustomQuest:New(quest.id, quest.name, quest.text, quest.level, quest.location, quest.instanceDisplayType, quest.stages, quest.repeatable)

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

    local stage, conditions = self:GetQuestProgress(id)
    local suppressCSA = false --not (stage == 1 and conditions == {})
    if not suppressCSA then
        LibCustomQuest.CenterAnnounce(CUSTOM_EVENT_CUSTOM_QUEST_ADDED, id)
    end
    
    self:UpdateQuestListeners(id, suppressCSA)
end

function CustomQuest_Manager:UpdateQuestListeners(questid, suppressCSA)
    local suppressCSA = suppressCSA or false
    local stage, conditions = self:GetQuestProgress(questid)
    local _, _, _, _, numConditions = self:GetQuestStepInfo(questid, stage)

    LCQ_DBG:Info("<<1>>: Stage <<2>> with <<3>> tasks", questid, stage, numConditions)

    for i = 1, numConditions do
        if not conditions[i] then
            -- Announce condition
            if not suppressCSA then
                LibCustomQuest.CenterAnnounce(CUSTOM_EVENT_CUSTOM_QUEST_OBJECTIVE_ADDED, questid, stage, i)
            end

            -- Start listening for the condition's condition
            local task = self.quests[questid].stages[stage].tasks[i]
            local type = task.type
            if not type then
                LCQ_DBG:Critical("Task type is nil! <<1>>", self.GetQuestName(questid))
            end

            if type == QUEST_CONDITION_TYPE_LOCATION then
                LCQ_COORDINATELISTENER:Listen(task.data, questid, i)
                LCQ_DBG:Verbose("Added coordinate target for <<1>>", task.text)
            elseif type == QUEST_CONDITION_TYPE_TALK then
                LCQ_INTERACTIONLISTENER:Listen(task.data, questid, i)
                LCQ_DBG:Verbose("Added ineraction target for <<1>>", task.data.name)
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
function CustomQuest_Manager:GetQuest(questID)
    if self.quests[questID] ~= nil then
        return self.quests[questID]
    else
        return nil
    end
end


function CustomQuest_Manager:GetQuestConditionText(questId, stage, condition)
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
function CustomQuest_Manager:GetQuestProgress(questID)
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
    local _, conditions = self:GetQuestProgress(questId)
    return conditions[conditionIndex]
end

function CustomQuest_Manager:IsQuestComplete(questId)
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
function CustomQuest_Manager:GetQuestLocationInfo(questID)
    local quest = self:GetQuest(questID)
    if quest then
        return quest.location
    end
end

-- Gets the type of the quest
function CustomQuest_Manager:GetQuestType(questID)
    local quest = self:GetQuest(questID)
    if quest then
        return quest.type
    end
end


-- Gets the name of the quest
function CustomQuest_Manager:GetQuestName(questID)
    local quest = self:GetQuest(questID)
    if quest then
        return quest.name
    end
end

-- Gets the level requirement/recommendation of the quest
function CustomQuest_Manager:GetQuestLevel(questID)
    local quest = self:GetQuest(questID)
    if quest then
        return quest.level
    end
end

-- Gets the instance display type of the quest, e.g. trial, dungeon, etc.
function CustomQuest_Manager:GetQuestInstanceDisplayType(questID)
    local quest = self:GetQuest(questID)
    if quest then
        return quest.instanceDisplayType
    end
end

-- Gets the number of stages in the quest
function CustomQuest_Manager:GetQuestNumSteps(questID)
    local quest = self:GetQuest(questID)
    return #quest.stages
end

function CustomQuest_Manager:GetQuestStepInfo(questID, stepIndex)
    local quest = self:GetQuest(questID)
    if quest.stages[stepIndex] then
        local text = quest.stages[stepIndex].text or "No text provided"
        local visibility = quest.stages[stepIndex].visibility or nil
        local type = quest.stages[stepIndex].type or 0
        local overrideText = quest.stages[stepIndex].overrideText or ""
        local numConditions = #quest.stages[stepIndex].tasks

        return text, visibility, type, overrideText, numConditions
    end
end

function CustomQuest_Manager:GetQuestInfo(questID)
    local quest = self:GetQuest(questID)
    if quest then
        return quest:GetInfo()
    end
end

function CustomQuest_Manager:GetQuestTaskInfo(questID, stage, condition)
    local quest = self:GetQuest(questID)
    if quest.stages and quest.stages[stage] ~= nil then
        local stage = quest.stages[stage]
        if stage.tasks and stage.tasks[condition] ~= nil then
            local task = stage.tasks[condition]

            local conditionText = task.text
            local currentCount = -1 --self.GetQuestProgress(questID, stage, task)
            local maxCount = task.max or 0
            local isFailCondition = false
            local isComplete = task.complete --(currentCount >= maxCount) -- ???
            local isVisible = not task.invisible or true
            local conditionType = "???"

            return conditionText, currentCount, maxCount, isFailCondition, isComplete, _, isVisible, conditionType
        end
    end
end

-- Gets the numbers of conditions in the current step
function CustomQuest_Manager:GetCustomQuestNumConditions(questId, step)
    for id, quest in pairs(self.quests) do
        if id == questId then
            local _, _, _, _, s = self:GetQuestStepInfo(questId, step)
            s = s or "Error"
            return s
        end
    end
end

function CustomQuest_Manager:GetHintText(questId)
    local currentStage = self.quests[questId].currentStage
    return self.quests[questId].stages[currentStage].hint
end

function CustomQuest_Manager:IsRepeatable(questID)
    local quest = self:GetQuest(questID)
    if quest then
        return quest.repeatable
    end
end

CUSTOM_QUEST_MANAGER = CustomQuest_Manager:New()