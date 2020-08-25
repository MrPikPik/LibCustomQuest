-----------------------------------------
-- Custom Quest
-----------------------------------------

CustomQuest = ZO_Object:Subclass()

-- Instantiates a new quest object
function CustomQuest:New(...)
    local quest = ZO_Object.New(self)
    quest:Initialize(...)
    return quest
end

-- Initializes a CustomQuest object
function CustomQuest:Initialize(id, name, bgtext, level, type, location, instanceDisplayType, stages, repeatable)
    self.id = id
    self.name = name or "Unknown Quest"
    self.text = bgtext or "No text provided"
    self.level = level or 50
    self.type = type or "???" -- TODO!
    self.location = location or "Unknown Zone"
    self.instanceDisplayType = instanceDisplayType or INSTANCE_DISPLAY_TYPE_NONE
    self.stages = stages or {}
    self.repeatable = repeatable or false
    
    LCQ_DBG:Info("Created quest with id %s", id)
end

function CustomQuest:GetInfo()
    local currentStep = self.stages.current or 1
    local name = self.name
    local bgText = self.text
    
    local stage = self.stages[currentStep] or {}
    local stepText = stage.text or "No text provided"
    local stepType = stage.type or "???"
    local stepOverrideText = stage.overrideText or stepText
    
    local completed = false
    local tracked = false
    local pushed = false
    local level = self.level
    local questType = "???"
    local instanceDisplayType = self.instanceDisplayType or INSTANCE_DISPLAY_TYPE_NONE
    
    
    
    return name, bgText, stepText, stepType, overrideText, completed, tracked, level, pushed, questType, instanceDisplayType
end



function CustomQuest:GetName()
    return self.name
end

function CustomQuest:GetType()
    return self.type
end

function CustomQuest:GetLocation()
    return self.location
end

function CustomQuest:GetLevel()
    return self.level
end

function CustomQuest:GetInstanceDisplayType()
    return self.instanceDisplayType
end

function CustomQuest:GetNumStages()
    return #self.stages
end

function CustomQuest:GetStage(stageIndex)
    return self.stages[stageIndex]
end

function CustomQuest:GetNumTasks(stageIndex)
    return #self.stages[stageIndex].tasks
end

function CustomQuest:GetTask(stageIndex, taskIndex)
    return self.stages[stageIndex].tasks[taskIndex]
end

function CustomQuest:IsRepeatable()
    return self.repeatable
end