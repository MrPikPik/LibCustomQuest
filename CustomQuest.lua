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
function CustomQuest:Initialize(id, name, bgtext, level, location, instanceDisplayType, stages, repeatable)
    self.id = id
    self.name = name or "Unnamed Quest"
    self.text = bgtext or " --- "
    self.level = level or 50
    self.type = ZO_ANY_QUEST_TYPE
    self.location = location or "Unknown Zone"
    self.instanceDisplayType = instanceDisplayType or INSTANCE_DISPLAY_TYPE_NONE
    self.stages = stages or {}
    self.currentStage = 1 -- TODO: Load progress from SavedVariables!
    self.completed = false -- TOFO: Load progress from SavedVariables
    self.repeatable = repeatable or false

    LCQ_DBG:Debug("TODO: Quest progress is not being loaded yet")
    LCQ_DBG:Info("Created quest with id <<1>>", id)
end

function CustomQuest:GetInfo()
    local name = self.name
    local bgText = self.text
    local stage = self.stages[self.currentStage] or {}
    local stepText = stage.text or "No text provided"
    local completed = self.completed
    local type = self.type
    local level = self.level
    local instanceDisplayType = self.instanceDisplayType or INSTANCE_DISPLAY_TYPE_NONE

    return name, bgText, stepText, _, _, completed, _, type, instanceDisplayType, level
end