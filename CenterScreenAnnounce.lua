local LibCustomQuest = LibCustomQuest or {}

local CENTER_SCREEN_EVENT_HANDLERS = {}

-- New Quest
CENTER_SCREEN_EVENT_HANDLERS[CUSTOM_EVENT_CUSTOM_QUEST_ADDED] = function(questId)
    local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.QUEST_ACCEPTED)
    local questJournalObject = SYSTEMS:GetObject("customQuestJournal")
    local instanceDisplayType = CUSTOM_QUEST_MANAGER:GetCustomQuestInstanceDisplayType(questId)
    local questName = CUSTOM_QUEST_MANAGER:GetCustomQuestName(questId)
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
    local instanceDisplayType = CUSTOM_QUEST_MANAGER:GetCustomQuestInstanceDisplayType(questId)  
    local questName = CUSTOM_QUEST_MANAGER:GetCustomQuestName(questId)
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
    if CUSTOM_QUEST_MANAGER:GetCustomQuestHiddenInfo(questId, stage, condition) then return end

    local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.QUEST_OBJECTIVE_INCREMENT)
    local conditionText = CUSTOM_QUEST_MANAGER:GetCustomQuestConditionText(questId, stage, condition)
    messageParams:SetText(conditionText)
    messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_OBJECTIVE_COMPLETED)
    return messageParams
end

-- Objective Complete
CENTER_SCREEN_EVENT_HANDLERS[CUSTOM_EVENT_CUSTOM_QUEST_OBJECTIVE_COMPLETED] = function(questId, stage, condition) 
    if CUSTOM_QUEST_MANAGER:GetCustomQuestHiddenInfo(questId, stage, condition) then return end

    local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.QUEST_OBJECTIVE_COMPLETE)
    local conditionText = CUSTOM_QUEST_MANAGER:GetCustomQuestConditionText(questId, stage, condition)
    messageParams:SetText(zo_strformat(SI_NOTIFYTEXT_OBJECTIVE_COMPLETE, conditionText))
    messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_OBJECTIVE_COMPLETED)
    return messageParams
end

-- Objective Update (i.e. "Collect Item: 2/10")
CENTER_SCREEN_EVENT_HANDLERS[CUSTOM_EVENT_CUSTOM_QUEST_OBJECTIVE_UPDATED] = function(questId, stage, condition, current, max) 
    local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.QUEST_OBJECTIVE_INCREMENT)
    local conditionText = CUSTOM_QUEST_MANAGER:GetCustomQuestConditionText(questId, stage, condition)
    messageParams:SetText(zo_strformat(SI_ALERTTEXT_QUEST_CONDITION_UPDATE, conditionText, current, max))
    messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_OBJECTIVE_COMPLETED)
    return messageParams
end

function LibCustomQuest.CenterAnnounce(event, ...)
    if not CENTER_SCREEN_EVENT_HANDLERS[event] then return end
    LCQ_DBG:Verbose("Showing CSA for QuestId <<1>>, stage <<2>> condition <<3>>", ...)
    CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(CENTER_SCREEN_EVENT_HANDLERS[event](...))
end