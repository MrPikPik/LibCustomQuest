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
function CustomQuest:Initialize(id, name, bgtext, level, location, instanceDisplayType, stages, outcome, repeatType)
    self.id = id
    self.name = name or "Unnamed Quest"
    self.text = bgtext or " --- "
    self.level = level or 50
    self.type = ZO_ANY_QUEST_TYPE
    self.location = location or "Unknown Zone"
    self.instanceDisplayType = instanceDisplayType or INSTANCE_DISPLAY_TYPE_NONE
    self.stages = stages or {}
    self.currentStage = (CUSTOM_QUEST_MANAGER.progress[id] and CUSTOM_QUEST_MANAGER.progress[id].stage > 1 and CUSTOM_QUEST_MANAGER.progress[id].stage) or 1
    self.completed = (CUSTOM_QUEST_MANAGER.progress[id] and CUSTOM_QUEST_MANAGER.progress[id].stage > #stages) --false -- TODO: Load progress from SavedVariables (Handled by .currentStage)
    self.outcome = outcome
    self.repeatType = repeatType or QUEST_REPEAT_NOT_REPEATABLE

    LCQ_DBG:Info("Created quest object with id '<<1>>'.", id)
end

--[[function CustomQuest:GetInfo()
    local name = self.name
    local bgText = self.text
    local stage = self.stages[self.currentStage] or {}
    local stepText = stage.text or "No text provided"
    local completed = self.completed
    local type = self.type
    local level = self.level
    local instanceDisplayType = self.instanceDisplayType or INSTANCE_DISPLAY_TYPE_NONE

    return name, bgText, stepText, _, _, completed, _, type, instanceDisplayType, level
end]]