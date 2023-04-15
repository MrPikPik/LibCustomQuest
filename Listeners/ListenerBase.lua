-----------------------------------------
-- Listener Base
-----------------------------------------

LCQListener = ZO_CallbackObject:Subclass()

-- Instantiates a new task object
function LCQListener:New(...)
    local listener = ZO_CallbackObject.New(self)
    return listener
end

function LCQListener:Initialize()
    -- To be overridden
    self.targets = {}

    LCQ_DBG:Warning("Listener: Base listener class has been initialized as object!")
end

function LCQListener:Listen(target, questId, conditionId)
    target.questId = questId
    target.conditionId = conditionId
    table.insert(self.targets, target)
    LCQ_DBG:Verbose("<<1>>: Added new listening target for quest '<<2>>': '<<3>>'.", self.name, questId, target.name or "Unnamed target")
end

function LCQListener:Remove(target)
    for i, t in ipairs(self.targets) do
        if t.questId == target.questId and t.conditionId == target.conditionId then
            LCQ_DBG:Verbose("<<1>>: Removed listening target for '<<2>>': '<<3>>'.", self.name, target.questId, target.name or "Unnamed target")
            table.remove(self.targets, i)
        end
    end
end

function LCQListener:RemoveAllForQuestId(questId)
    for i, t in ipairs(self.targets) do
        if t.questId == questId then
            table.remove(self.targets, i)
        end
    end
    LCQ_DBG:Verbose("<<1>>: Removed all listening targets for '<<2>>'.", self.name, questId)
end