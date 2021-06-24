do 
    local control = CreateControlFromVirtual("CustomQuestJournal", nil, "ALCI_QuestJournal")
    local sceneName = "customQuestJournal"

    local sceneData = {}
    sceneData[1] = {type="journal", control=control, bgControl=LCQ.bgControl, sceneName=sceneName, sceneGroupTitle=LCQ_MAIN_MENU_CUSTOM_JOURNAL}

    _, CUSTOM_QUEST_JOURNAL_KEYBOARD = ALCI_Scene_Setup("LibCustomQuest", sceneData)
    CUSTOM_QUEST_JOURNAL_MANAGER = CUSTOM_QUEST_JOURNAL_KEYBOARD.managerObject
    
    SYSTEMS:RegisterKeyboardObject("customQuestJournal", CUSTOM_QUEST_JOURNAL_KEYBOARD)
end

----------
-- CustomQuestJournal_Manager
----------

function CUSTOM_QUEST_JOURNAL_MANAGER:BuildTextForTasks(_, questId, questStrings)
    local stage = CUSTOM_QUEST_MANAGER.quests[questId].currentStage
    local conditionCount = CUSTOM_QUEST_MANAGER:GetCustomQuestNumConditions(questId, stage)
    self:BuildTextForConditions(questId, stage, conditionCount, questStrings)
    
end

function CUSTOM_QUEST_JOURNAL_MANAGER:DoesShowMultipleOrSteps(stepOverrideText, stepType, questIndex)
    LCQ_DBG:Critical("DoesShowMultipleOrSteps not implemented")
    if stepOverrideText and (stepOverrideText ~= "") then
        return false
    else
        local conditionCount = CUSTOM_QUEST_MANAGER:GetCustomQuestNumConditions(questIndex, QUEST_MAIN_STEP_INDEX)
        if(stepType == QUEST_STEP_TYPE_OR and conditionCount > 1) then
            return true
        else
            return false
        end
    end
end

function CUSTOM_QUEST_JOURNAL_MANAGER:GetQuestConditionInfo(questId, stepIndex, conditionStep)
    return CUSTOM_QUEST_MANAGER:GetQuestTaskInfo(questId, stepIndex, conditionStep)
end

function CUSTOM_QUEST_JOURNAL_MANAGER:GetQuestIdList()
    local quests = CUSTOM_QUEST_JOURNAL_KEYBOARD.questMasterList.quests

    local questIdList = {} 
    for i, _ in ipairs(quests) do
        table.insert(questIdList, quests[i].questId)
    end

    return questIdList
end

function CUSTOM_QUEST_JOURNAL_MANAGER:GetQuestList()
    return CUSTOM_QUEST_JOURNAL_KEYBOARD.questMasterList.quests
end

function CUSTOM_QUEST_JOURNAL_MANAGER:GetQuestCategories()
    return CUSTOM_QUEST_JOURNAL_KEYBOARD.questMasterList.categories
end

function CUSTOM_QUEST_JOURNAL_MANAGER:GetQuestListData()
    local seenCategories = {}
    local categories = {}
    local quests = {}

    -- Create a table for categories and one for quests
    for questID, questData in pairs(CUSTOM_QUEST_MANAGER.quests) do
        if not questData.completed then
            local zone = questData.location
            local questType = CUSTOM_QUEST_MANAGER:GetQuestType(questID)
            local name = questData.name
            local level = questData.level
            local instanceDisplayType = questData.instanceDisplayType
            local categoryName, categoryType = self:GetQuestCategoryNameAndType(questType, zone)

            if not seenCategories[categoryName] then
                table.insert(categories, {name = categoryName, type = categoryType})
                seenCategories[categoryName] = true
            end

            if name == "" then
                name = GetString(SI_QUEST_JOURNAL_UNKNOWN_QUEST_NAME)
            end

            table.insert(quests, {
                name = name,
                questId = questID,
                level = level,
                categoryName = categoryName,
                categoryType = categoryType,
                questType = questType,
                displayType = instanceDisplayType
            })
        end
    end

    -- Sort the tables
    --table.sort(categories, CustomQuestJournal_Manager_SortQuestCategories)
    --table.sort(quests, CustomQuestJournal_Manager_SortQuestEntries)

    return quests, categories, seenCategories
end