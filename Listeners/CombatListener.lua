-----------------------------------------
-- Combat Listener
-----------------------------------------

LCQCombatListener = LCQListener:Subclass()

function LCQCombatListener:New(...)
    local listener = LCQListener.New(self, ...)
    listener:Initialize(...)
    return listener
end

function LCQCombatListener:Initialize(...)
    self.name = "CombatListener"
    self.targets = {}

    -- Combat Damage Filters
	EVENT_MANAGER:RegisterForEvent(self.name.."CombatDamage1", EVENT_COMBAT_EVENT, function(...) self:OnDamage(...) end)
	EVENT_MANAGER:AddFilterForEvent(self.name.."CombatDamage1", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_DAMAGE)
    EVENT_MANAGER:RegisterForEvent(self.name.."CombatDamage2", EVENT_COMBAT_EVENT, function(...) self:OnDamage(...) end)
    EVENT_MANAGER:AddFilterForEvent(self.name.."CombatDamage2", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_CRITICAL_DAMAGE)

    -- Combat Death Filters
	EVENT_MANAGER:RegisterForEvent(self.name.."CombatDeath1", EVENT_COMBAT_EVENT, function(...) self:OnDeath(...) end)
    EVENT_MANAGER:AddFilterForEvent(self.name.."CombatDeath1", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_DIED)
    EVENT_MANAGER:RegisterForEvent(self.name.."CombatDeath2", EVENT_COMBAT_EVENT, function(...) self:OnDeath(...) end)
	EVENT_MANAGER:AddFilterForEvent(self.name.."CombatDeath2", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_DIED_XP)

    LCQ_DBG:Verbose("Listener: Combat listener initalized")
end

function LCQCombatListener:RunInteractionForTarget(target)
    self:FireCallbacks("OnConditionMet", target)
end

function LCQCombatListener:OnDamage(event, result, _, abilityName, _, _, sourceName, sourceType, targetName, targetType, _, powerType, damageType)
    local sourceName = zo_strformat("<<1>>", sourceName)
    local targetName = zo_strformat("<<1>>", targetName)

    for _, target in ipairs(self.targets) do
        if targetName == GetUnitName("player") and target.name == sourceName and target.type == CUSTOM_COMBAT_EVENT_DAMAGE_TAKEN then
            self:RunInteractionForTarget(target)
        elseif sourceName == GetUnitName("player") and target.name == targetName and target.type == CUSTOM_COMBAT_EVENT_DAMAGE_GIVEN then
            self:RunInteractionForTarget(target)
        end
    end
end

-- Might need to be rewritten in the future depending on how it's used
function LCQCombatListener:OnDeath(event, result, _, abilityName, _, _, sourceName, sourceType, targetName, targetType, _, powerType, damageType)
    local sourceName = zo_strformat("<<1>>", sourceName)
    local targetName = zo_strformat("<<1>>", targetName)

    for _, target in ipairs(self.targets) do
        -- Separate as above, between sourceName deathXP and targetName deathXP?
        if (target.name == sourceName or target.name == targetName) and target.type == CUSTOM_COMBAT_EVENT_ON_DEATH_XP then
            self:RunInteractionForTarget(target)
        end
    end
end