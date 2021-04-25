---------------------
--Custom Quest Journal Shared
---------------------

-- Used for indexing into icon/tooltip tables if we don't care what the quest or instance display types are
ZO_ANY_QUEST_TYPE = "all_quests"
ZO_ANY_INSTANCE_DISPLAY_TYPE = "all_instances"

CustomQuestJournal_Shared = ZO_CallbackObject:Subclass()

function CustomQuestJournal_Shared:New()
    local newObject = ZO_CallbackObject.New(self)

    return newObject
end

function CustomQuestJournal_Shared:Initialize(control)
    self.control = control
    self.listDirty = true

    self.questStrings = {}
    self.icons = {}
    self.tooltips = {}

    self:RegisterIcons()
    self:RegisterTooltips()

    self:InitializeQuestList(control)
    self:InitializeKeybindStripDescriptors()
    self:RefreshQuestList()
    self:RefreshQuestCount()
    self:InitializeScenes()

    --control:RegisterForEvent(EVENT_QUEST_ADDED, function() self:OnQuestsUpdated() end)
    --control:RegisterForEvent(EVENT_QUEST_REMOVED, function() self:OnQuestsUpdated() end)
    --control:RegisterForEvent(EVENT_QUEST_LIST_UPDATED, function() self:OnQuestsUpdated() end)
    --control:RegisterForEvent(EVENT_QUEST_ADVANCED, function(eventCode, questIndex) self:OnQuestAdvanced(questIndex) end)
    --control:RegisterForEvent(EVENT_QUEST_CONDITION_COUNTER_CHANGED, function(eventCode, ...) self:OnQuestConditionInfoChanged(...) end)
    --control:RegisterForEvent(EVENT_LEVEL_UPDATE, function(eventCode, unitTag) self:OnLevelUpdated(unitTag) end)
end

local function CustomQuestJournal_Shared_RegisterDataInTable(table, instanceDisplayType, data)
    table[instanceDisplayType or ZO_ANY_INSTANCE_DISPLAY_TYPE] = data
end

local function CustomQuestJournal_Shared_GetDataFromTable(table, instanceDisplayType)
    return table[instanceDisplayType] or table[ZO_ANY_INSTANCE_DISPLAY_TYPE]
end

function CustomQuestJournal_Shared:RegisterIconTexture(instanceDisplayType, texturePath)
    CustomQuestJournal_Shared_RegisterDataInTable(self.icons, instanceDisplayType, texturePath)
end

function CustomQuestJournal_Shared:GetIconTexture(instanceDisplayType)
    return CustomQuestJournal_Shared_GetDataFromTable(self.icons, instanceDisplayType)
end

function CustomQuestJournal_Shared:RegisterTooltipText(instanceDisplayType, stringIdOrText)
    local data = type(stringIdOrText) == "number" and GetString(stringIdOrText) or stringIdOrText
    CustomQuestJournal_Shared_RegisterDataInTable(self.tooltips, instanceDisplayType, data)
end

function CustomQuestJournal_Shared:GetTooltipText(instanceDisplayType, questIndex)
    local data = CustomQuestJournal_Shared_GetDataFromTable(self.tooltips, instanceDisplayType)
    local text = data
    if type(data) == "table" then
        text = zo_strformat(data.text, data.paramsFunction(questIndex))
    end
    return text
end

function CustomQuestJournal_Shared:InitializeQuestList()
    -- Should be overridden
end

function CustomQuestJournal_Shared:InitializeKeybindStripDescriptors()
    -- Should be overridden
end

function CustomQuestJournal_Shared:InitializeScenes()
    -- Should be overridden
end

function CustomQuestJournal_Shared:GetSelectedQuestData()
    -- Should be overridden
end

function CustomQuestJournal_Shared:RefreshQuestList()
    -- Should be overridden
end

function CustomQuestJournal_Shared:RegisterIcons()
    -- Should be overridden
end

function CustomQuestJournal_Shared:RegisterTooltips()
    -- Should be overridden
end

function CustomQuestJournal_Shared:OnLevelUpdated(unitTag)
    if (unitTag == "player") then
        if self.control:IsHidden() then
            self.listDirty = true
        else
            self:RefreshQuestList()
        end
    end
end

function CustomQuestJournal_Shared:GetHintText(questId)
    return CUSTOM_QUEST_MANAGER:GetHintText(questId)
end

function CustomQuestJournal_Shared:BuildTextForStepVisibility(questID, visibilityType)
    local numSteps = CUSTOM_QUEST_MANAGER:GetQuestNumSteps(questID)
    local questStrings = self.questStrings
    for stepIndex = 2, numSteps do
        local stepJournalText, visibility, _, stepOverrideText, _ = CUSTOM_QUEST_MANAGER:GetQuestStepInfo(questID, stepIndex)

        if visibility == visibilityType then
            if(stepJournalText ~= "") then
                table.insert(questStrings, zo_strformat(SI_QUEST_JOURNAL_TEXT, stepJournalText))
            end
            
            if stepOverrideText and (stepOverrideText ~= "") then
                table.insert(questStrings, stepOverrideText)
            end
        end
    end
end

function CustomQuestJournal_Shared:GetSelectedQuestIndex()
    local selectedData = self:GetSelectedQuestData()
    return selectedData and selectedData.questIndex
end

function CustomQuestJournal_Shared:RefreshDetails()
    --to be overridden
end

function CustomQuestJournal_Shared:RefreshQuestCount()
    -- This function is overridden by sub-classes.
end

function CustomQuestJournal_Shared:RefreshQuestMasterList()
    -- Override if necessary
end

function CustomQuestJournal_Shared:OnQuestsUpdated()
    self:RefreshQuestMasterList()
    if self.control:IsHidden() then
        self.listDirty = true
    else
        self:RefreshQuestCount()
        self:RefreshQuestList()
    end
end

function CustomQuestJournal_Shared:OnQuestAdvanced(questIndex)
    local selectedQuestIndex = self:GetSelectedQuestIndex()
    if questIndex == selectedQuestIndex then
        self:RefreshDetails()
    end
end

function CustomQuestJournal_Shared:OnQuestConditionInfoChanged(questIndex, questName, conditionText, conditionType, curCondtionVal, newConditionVal, conditionMax, isFailCondition, stepOverrideText, isPushed, isQuestComplete, isConditionComplete, isStepHidden, isConditionCompleteStatusChanged, isConditionCompletableBySiblingStatusChanged)
    local selectedQuestIndex = self:GetSelectedQuestIndex()
    if questIndex == selectedQuestIndex then
        self:RefreshDetails()
    end
end

function CustomQuestJournal_Shared:ShowOnMap()
   local selectedQuestIndex = self:GetSelectedQuestIndex()
   if(selectedQuestIndex) then
        LCQ_DBG:Error("Show on map not implemented yet")
        --ZO_WorldMap_ShowQuestOnMap(selectedQuestIndex)
    end
end