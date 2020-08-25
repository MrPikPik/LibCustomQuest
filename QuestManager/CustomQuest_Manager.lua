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
        self.quests[quest.id] = CustomQuest:New(quest.id, quest.name, quest.text, quest.level, quest.type, quest.location, quest.instanceDisplayType, quest.stages, quest.repeatable)
        return quest.id 
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

-- Get all quests at once
function CustomQuest_Manager:GetAllQuests()
    return self.quests
end

-- Get the number of quests
function CustomQuest_Manager:GetNumActiveQuests()
    local i = 0
    for _ in pairs(self.quests) do i = i + 1 end
    return i
end


-----------------------------------------
-- Quest progress
-----------------------------------------

-- Gets the progress of a specified quest's stage's condition/task
function CustomQuest_Manager:GetQuestProgress(questID, stage, condition)
    -- Check if the progress exists, if not return 0
    if self.progress[questID] and self.progress[questID][stage] and self.progress[questID][stage][condition] then
        return self.progress[questID][stage][condition]
    else
        return 0
    end
end


function CustomQuest_Manager:GetQuestCurrentStage(questID)
    local quest = self

    
    return stage
end

-- Sets the progress of a specified quest's stage's condition/task to a given value
function CustomQuest_Manager:SetQuestProgress(questID, stage, condition, value)
    -- Check if we have any progress data for the given questID
    if not self.progress[questID] then
        self.progress[questID] = {}
    end

    -- Check if we have any saved data for the given stage of our quest
    if not self.progress[questID][stage] then
        self.progress[questID][stage] = {}
    end
    
    -- Set the progress
    self.progress[questID][stage][condition] = value
end


-----------------------------------------
-- Quest data
-----------------------------------------

-- Gets the zone name of a quest. This is used for grouping in the journal
function CustomQuest_Manager:GetQuestLocationInfo(questID)
    local quest = self:GetQuest(questID)
    if quest then
        return quest:GetLocation()
    end
end

-- Gets the type of the quest
function CustomQuest_Manager:GetQuestType(questID)
    local quest = self:GetQuest(questID)
    if quest then
        return quest:GetType()
    end
end


-- Gets the name of the quest
function CustomQuest_Manager:GetQuestName(questID)
    local quest = self:GetQuest(questID)
    if quest then
        return quest:GetName()
    end
end

-- Gets the level requirement/recommendation of the quest
function CustomQuest_Manager:GetQuestLevel(questID)
    local quest = self:GetQuest(questID)
    if quest then
        return quest:GetLevel()
    end
end

-- Gets the instance display type of the quest, e.g. trial, dungeon, etc.
function CustomQuest_Manager:GetQuestInstanceDisplayType(questID)
    local quest = self:GetQuest(questID)
    if quest then
        return quest:GetInstanceDisplayType()
    end
end

-- Gets the number of stages in the quest
function CustomQuest_Manager:GetQuestNumSteps(questID)
    local quest = self:GetQuest(questID)
    return #quest.stages
end

function CustomQuest_Manager:GetQuestStepsInfo(questID, stepIndex)
    local quest = self:GetQuest(questID)
    if quest.stages[stepIndex] then
        local text = quest.stages[stepIndex].text or "No text provided"
        local visibility = quest.stages[stepIndex].visibility or nil
        local type = quest.stages[stepIndex].type or 0
        local overrideText = quest.stages[stepIndex].overrideText or ""
        local numConditions = quest.stages[stepIndex].numConditions or 0
        
        return text, visibility, type, overrideText, numConditions
    end
end

function CustomQuest_Manager:GetQuestInfo(questID)
    local quest = self:GetQuest(questID)
    if quest then
        return quest:GetInfo()
    end
end

function CustomQuest_Manager:GetQuestTaskInfo(questID, stage, task)
    local quest = self:GetQuest(questID)
    if quest.stages and quest.stages[stage] ~= nil then
        local stage = quest.stages[stage]
        if stage.tasks and stage.tasks[task] ~= nil then
            local task = stage.tasks[task]
        
            local conditionText = task.text
            local currentCount = 0 --self.GetQuestProgress(questID, stage, task)
            local maxCount = task.max or 1
            local isFailCondition = false
            local isComplete = (currentCount <= maxCount)
            local isCreditShared = task.sharedProgress or false
            local isVisible = not task.invisible or true
            local conditionType = "???"
            
            return conditionText, currentCount, maxCount, isFailCondition, isComplete, isCreditShared, isVisible, conditionType
        end
    end
end

-- TODO
function CustomQuest_Manager:GetCustomQuestNumConditions(questIndex, questType)
    d("CustomQuest_Manager:GetCustomQuestNumConditions(" .. questIndex .. ", " .. questType .. ")")
    return 1
end

function CustomQuest_Manager:IsRepeatable(questID)
    local quest = self:GetQuest(questID)
    if quest then
        return quest:IsRepeatable()
    end
end

-----------------------------------------
-- Find data in quests
-----------------------------------------

-- Checks if a given name is aa valid active target
function CustomQuest_Manager:IsValidInteractionTarget(target)
    for id, quest in pairs(self.quests) do
        
    end
end




CUSTOM_QUEST_MANAGER = CustomQuest_Manager:New()