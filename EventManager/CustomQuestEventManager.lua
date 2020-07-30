----------
-- CustomQuestEventManager
----------

CustomQuestEventManager = ZO_Object:Subclass()

function CustomQuestEventManager:New()
    local manager = ZO_Object.New(self)
    manager:Initialize()
    return manager
end

function CustomQuestEventManager:Initialize()
    self.eventRegistry = {}
end

function CustomQuestEventManager:RegisterForEvent(name, eventCode, callback)
    if self.eventRegistry[eventCode] then
        self.eventRegistry[eventCode][name] = callback
    end
end

function CustomQuestEventManager:UnregisterForEvent(name, eventCode)
    self.eventRegistry[eventCode][name] = nil
end

function CustomQuestEventManager:FireCallbacks(eventCode, ...)
    for _, callback in pairs(self.eventRegistry[eventCode]) do
        callback(...)
    end
end

function CustomQuestEventManager:FireEvent(eventCode, ...)

end

CUSTOM_QUEST_EVENT_MANAGER = CustomQuestEventManager:New()