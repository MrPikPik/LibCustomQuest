local QUEST_CAT_ZONE = 1
local QUEST_CAT_OTHER = 2
local QUEST_CAT_MISC = 3

----------
-- CustomQuestJournal_Manager
----------

CustomQuestJournal_Manager = ZO_CallbackObject:Subclass()

function CustomQuestJournal_Manager:New(...)
    local manager = ZO_CallbackObject.New(self)
    manager:Initialize(...)
    return manager
end

function CustomQuestJournal_Manager:Initialize(control)
    --self:RegisterForEvents()
end

function CustomQuestJournal_Manager:RegisterForEvents()
    local function OnFocusQuestIndexChanged(eventCode, questIndex)
        self.focusedQuestIndex = questIndex
    end

    EVENT_MANAGER:RegisterForEvent("CustomQuestJournal_Manager", CUSTOM_EVENT_QUEST_SHOW_JOURNAL_ENTRY, OnFocusQuestIndexChanged)
end

local function BuildTextHelper(questId, stepIndex, conditionStep, questStrings)
    local conditionText, currentCount, maxCount, isFailCondition, isComplete, isVisible = CUSTOM_QUEST_MANAGER:GetQuestTaskInfo(questId, stepIndex, conditionStep)

    if(isVisible and not isFailCondition and conditionText ~= "") then
        if isComplete then
            conditionText = ZO_DISABLED_TEXT:Colorize(conditionText)
        end

        local taskInfo = {
            name = conditionText,
            isComplete = isComplete,
        }

        table.insert(questStrings, taskInfo)
    end
end

function CustomQuestJournal_Manager:BuildTextForConditions(questId, stepIndex, numConditions, questStrings)
    for i = 1, numConditions do
        BuildTextHelper(questId, stepIndex, i, questStrings)
    end
end

function CustomQuestJournal_Manager:BuildTextForTasks(questId, questStrings)
    local stage = CUSTOM_QUEST_MANAGER.quests[questId].currentStage
    local conditionCount = CUSTOM_QUEST_MANAGER:GetCustomQuestNumConditions(questId, stage)
    self:BuildTextForConditions(questId, stage, conditionCount, questStrings)
    
end

function CustomQuestJournal_Manager:DoesShowMultipleOrSteps(stepOverrideText, stepType, questIndex)
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

local function CustomQuestJournal_Manager_SortQuestCategories(entry1, entry2)
    LCQ_DBG:Critical("CustomQuestJournal_Manager_SortQuestCategories not implemented")
    if entry1.type == entry2.type then
        return entry1.name < entry2.name
    else
        return entry1.type < entry2.type
    end
end

local function CustomQuestJournal_Manager_SortQuestEntries(entry1, entry2)
    LCQ_DBG:Critical("CustomQuestJournal_Manager_SortQuestEntries not implemented")
    if entry1.categoryType == entry2.categoryType then
        if entry1.categoryName == entry2.categoryName then
            return entry1.name < entry2.name
        end

        return entry1.categoryName < entry2.categoryName
    end
    return entry1.categoryType < entry2.categoryType
end

-- ZO_IS_QUEST_TYPE_IN_OTHER_CATEGORY =
-- {
--     [QUEST_TYPE_MAIN_STORY] = true,
--     [QUEST_TYPE_GUILD] = true,
--     [QUEST_TYPE_CRAFTING] = true,
--     [QUEST_TYPE_HOLIDAY_EVENT] = true,
--     [QUEST_TYPE_BATTLEGROUND] = true,
--     [QUEST_TYPE_PROLOGUE] = true,
--     [QUEST_TYPE_UNDAUNTED_PLEDGE] = true,
-- }

function CustomQuestJournal_Manager:GetQuestCategoryNameAndType(questType, zone)
    LCQ_DBG:Critical("GetQuestCategoryNameAndType not implemented")
    local categoryName, categoryType
    if ZO_IS_QUEST_TYPE_IN_OTHER_CATEGORY[questType] then
        categoryName = GetString("SI_QUESTTYPE", questType)
        categoryType = QUEST_CAT_OTHER
    elseif zone ~= "" then
        categoryName = zo_strformat(SI_QUEST_JOURNAL_ZONE_FORMAT, zone)
        categoryType = QUEST_CAT_ZONE
    else
        categoryName = GetString(SI_QUEST_JOURNAL_GENERAL_CATEGORY)
        categoryType = QUEST_CAT_MISC
    end
    return categoryName, categoryType
end

function CustomQuestJournal_Manager:AreQuestsInTheSameCategory(quest1Type, quest1Zone, quest2Type, quest2Zone)
    LCQ_DBG:Critical("AreQuestsInTheSameCategory not implemented")
    local quest1IsOtherCategory = ZO_IS_QUEST_TYPE_IN_OTHER_CATEGORY[quest1Type]
    local quest2IsOtherCategory = ZO_IS_QUEST_TYPE_IN_OTHER_CATEGORY[quest2Type]
    if quest1IsOtherCategory ~= quest2IsOtherCategory then
        return false
    else
        if quest1IsOtherCategory then
            return quest1Type == quest2Type
        else
            --true if they have the same zone or if they both have no zone and would end up in the general category
            return quest1Zone == quest2Zone
        end
    end
end

function CustomQuestJournal_Manager:FindQuestWithSameCategoryAsCompletedQuest(questId)
    LCQ_DBG:Critical("FindQuestWithSameCategoryAsCompletedQuest not implemented")
    local _, completedQuestType = GetCompletedQuestInfo(questId)
    local completedQuestZone = GetCompletedQuestLocationInfo(questId)
    for i = 1, MAX_JOURNAL_QUESTS do
        if IsValidQuestIndex(i) then
            local questType = GetJournalQuestType(i)
            local zone = GetJournalQuestLocationInfo(i)
            if self:AreQuestsInTheSameCategory(completedQuestType, completedQuestZone, questType, zone) then
                return i
            end
        end 
    end
    return nil
end

function CustomQuestJournal_Manager:GetQuestListData()
    local seenCategories = {}
    local categories = {}
    local quests = {}

    -- Create a table for categories and one for quests
    for questID, questData in pairs(CUSTOM_QUEST_MANAGER.quests) do
        if not questData.completed then
            local zone = questData.zone
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
                questIndex = questID,
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

function CustomQuestJournal_Manager:UpdateFocusedQuest()
    local focusedQuestIndex = nil
    local numTrackedQuests = GetNumTracked()
    for i=1, numTrackedQuests do
        local trackType, arg1, arg2 = GetTrackedByIndex(i)
        if GetTrackedIsAssisted(trackType, arg1, arg2) then
            focusedQuestIndex = arg1
            break
        end
    end

    self.focusedQuestIndex = focusedQuestIndex
end

function CustomQuestJournal_Manager:GetFocusedQuestIndex()
    return self.focusedQuestIndex
end

CUSTOM_QUEST_JOURNAL_MANAGER = CustomQuestJournal_Manager:New()