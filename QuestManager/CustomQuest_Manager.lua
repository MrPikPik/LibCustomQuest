CustomQuest_Manager = ZO_CallbackObject:Subclass()

function CustomQuest_Manager:New(...)
    local manager = ZO_CallbackObject.New(self)
    manager:Initialize(...)
    return manager
end

function CustomQuest_Manager:Initialize(control)
    self.quests = {}
end

function CustomQuest_Manager:RegisterQuest(quest)
    self.quests[quest.id] = quest
end

function CustomQuest_Manager:GetQuest(questID)
    if self.quests[questID] ~= nil then
        return self.quests[questID]
    else
        return false
    end
end

function CustomQuest_Manager:GetAllQuests()
    return self.quests
end

function CustomQuest_Manager:GetNumActiveQuests()
    return #self.quests
end


-----------------------------------------
-- Quest data
-----------------------------------------
function CustomQuest_Manager:GetQuestLocationInfo(questID)
    local quest = self:GetQuest(questID)
    return quest.location
end

function CustomQuest_Manager:GetQuestType(questID)
    local quest = self:GetQuest(questID)
    return quest.type
end

function CustomQuest_Manager:GetQuestName(questID)
    local quest = self:GetQuest(questID)
    return quest.name
end

function CustomQuest_Manager:GetQuestLevel(questID)
    local quest = self:GetQuest(questID)
    return quest.level
end

function CustomQuest_Manager:GetQuestInstanceDisplayType(questID)
    local quest = self:GetQuest(questID)
    return quest.instanceDisplayType
end

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
        local currentStep = quest.stages.current or 1
        local name = quest.name or "No name provided"
        local bgText = quest.text or "No text provided"
        local stepText = quest.stages[currentStep].text or "No text provided"
        local stepType = quest.stages[currentStep].type or "???"
        local questType = "???"
        local instanceDisplayType = quest.instanceDisplayType or INSTANCE_DISPLAY_TYPE_NONE
        
        
        return name, bgText, stepText, stepType, "???", false, false, 50, false, questType, instanceDisplayType
    end
end


CUSTOM_QUEST_MANAGER = CustomQuest_Manager:New()