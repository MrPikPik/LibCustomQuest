local LibCustomQuest = LibCustomQuest or {}

local CENTER_SCREEN_EVENT_HANDLERS = {}

-- New Quest
CENTER_SCREEN_EVENT_HANDLERS[CUSTOM_EVENT_CUSTOM_QUEST_ADDED] = function(questId)
    local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.QUEST_ACCEPTED)
    local questJournalObject = SYSTEMS:GetObject("customQuestJournal")
    local instanceDisplayType = CUSTOM_QUEST_MANAGER:GetQuestInstanceDisplayType(questId)
    local questName = CUSTOM_QUEST_MANAGER:GetQuestName(questId)
    local iconTexture = questJournalObject:GetIconTexture(instanceDisplayType)
    if iconTexture then
        messageParams:SetText(zo_strformat(SI_NOTIFYTEXT_QUEST_ACCEPT_WITH_ICON, zo_iconFormat(iconTexture, "75%", "75%"), questName))
    else
        messageParams:SetText(zo_strformat(SI_NOTIFYTEXT_QUEST_ACCEPT, questName))
    end
    messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_QUEST_ADDED)
    return messageParams
end

-- Quest Complete
CENTER_SCREEN_EVENT_HANDLERS[CUSTOM_EVENT_CUSTOM_QUEST_COMPLETE] = function(questId)
    local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.QUEST_COMPLETED)
    local questJournalObject = SYSTEMS:GetObject("customQuestJournal")
    local instanceDisplayType = CUSTOM_QUEST_MANAGER:GetQuestInstanceDisplayType(questId)  
    local questName = CUSTOM_QUEST_MANAGER:GetQuestName(questId)
    local iconTexture = questJournalObject:GetIconTexture(instanceDisplayType)
    if iconTexture then
        messageParams:SetText(zo_strformat(SI_NOTIFYTEXT_QUEST_COMPLETE_WITH_ICON, zo_iconFormat(iconTexture, "75%", "75%"), questName))
    else
        messageParams:SetText(zo_strformat(SI_NOTIFYTEXT_QUEST_COMPLETE, questName))
    end
    messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_QUEST_COMPLETED)
    return messageParams
end

-- New Objective
CENTER_SCREEN_EVENT_HANDLERS[CUSTOM_EVENT_CUSTOM_QUEST_OBJECTIVE_ADDED] = function(questId, stage, condition) 
    local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.OBJECTIVE_ACCEPTED)
    local conditionText = CUSTOM_QUEST_MANAGER:GetQuestConditionText(questId, stage, condition)
    messageParams:SetText(conditionText)
    messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_OBJECTIVE_COMPLETED)
    return messageParams
end

-- Objective Complete
CENTER_SCREEN_EVENT_HANDLERS[CUSTOM_EVENT_CUSTOM_QUEST_OBJECTIVE_COMPLETED] = function(questId, stage, condition) 
    local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.OBJECTIVE_COMPLETED)
    local conditionText = CUSTOM_QUEST_MANAGER:GetQuestConditionText(questId, stage, condition)
    messageParams:SetText(zo_strformat(SI_NOTIFYTEXT_OBJECTIVE_COMPLETE, conditionText))
    messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_OBJECTIVE_COMPLETED)
    return messageParams
end

function LibCustomQuest.CenterAnnounce(event, ...)
    if not CENTER_SCREEN_EVENT_HANDLERS[event] then return end
    LCQ_DBG:Verbose("Showing CSA for event <<1>>, questId <<2>>", event, ...)
    CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(CENTER_SCREEN_EVENT_HANDLERS[event](...))
end