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

local function CustomQuestJournal_Shared_RegisterDataInTable(table, questType, instanceDisplayType, data)
    local questTableIndex = questType or ZO_ANY_QUEST_TYPE
    table[questTableIndex] = table[questTableIndex] or {}

    table[questTableIndex][instanceDisplayType or ZO_ANY_INSTANCE_DISPLAY_TYPE] = data
end

local function CustomQuestJournal_Shared_GetDataFromTable(table, questType, instanceDisplayType)
    local data

    -- Attempt to pull data specifically for this quest type first
    if table[questType] then
        data = table[questType][instanceDisplayType] or table[questType][ZO_ANY_INSTANCE_DISPLAY_TYPE]
    end

    -- If we didn't find specific data for this quest type, try to fetch it for any quest type
    if data == nil and table[ZO_ANY_QUEST_TYPE] then
        data = table[ZO_ANY_QUEST_TYPE][instanceDisplayType] or table[ZO_ANY_QUEST_TYPE][ZO_ANY_INSTANCE_DISPLAY_TYPE]
    end

    return data
end

--TODO: Get ride of this exstensibility.  The icon should only be controlled by the display type.
function CustomQuestJournal_Shared:RegisterIconTexture(questType, instanceDisplayType, texturePath)
    CustomQuestJournal_Shared_RegisterDataInTable(self.icons, questType, instanceDisplayType, texturePath)
end

function CustomQuestJournal_Shared:GetIconTexture(questType, instanceDisplayType)
    return CustomQuestJournal_Shared_GetDataFromTable(self.icons, questType, instanceDisplayType)
end

function CustomQuestJournal_Shared:RegisterTooltipText(questType, instanceDisplayType, stringIdOrText, paramsFunction)
    local tooltipText = type(stringIdOrText) == "number" and GetString(stringIdOrText) or stringIdOrText

    local data = tooltipText
    if paramsFunction then 
        data =
        {
            text = tooltipText,
            paramsFunction = paramsFunction,
        }
    end

    CustomQuestJournal_Shared_RegisterDataInTable(self.tooltips, questType, instanceDisplayType, data)
end

function CustomQuestJournal_Shared:GetTooltipText(questType, instanceDisplayType, questIndex)
    local data = CustomQuestJournal_Shared_GetDataFromTable(self.tooltips, questType, instanceDisplayType)
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

function CustomQuestJournal_Shared:BuildTextForStepVisibility(questID, visibilityType)
    local numSteps = CUSTOM_QUEST_MANAGER:GetQuestNumSteps(questID)
    local questStrings = self.questStrings
    for stepIndex = 2, numSteps do
        local stepJournalText, visibility, _, stepOverrideText, _ = CUSTOM_QUEST_MANAGER:GetQuestStepsInfo(questID, stepIndex)

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

function CustomQuestJournal_Shared:CanAbandonQuest()
    local selectedData = self:GetSelectedQuestData()
    if selectedData and selectedData.questIndex and selectedData.questType ~= QUEST_TYPE_MAIN_STORY then
        return true
    end
    return false
end

function CustomQuestJournal_Shared:CanShareQuest()
    local selectedQuestIndex = self:GetSelectedQuestIndex()
    if selectedQuestIndex then
        return GetIsQuestSharable(selectedQuestIndex) and IsUnitGrouped("player")
    end
    return false
end

function CustomQuestJournal_Shared:RefreshDetails()
    --to be overridden
end

function CustomQuestJournal_Shared:RefreshQuestCount()
    -- This function is overridden by sub-classes.
end

function CustomQuestJournal_Shared:RefreshQuestMasterList()
    -- Override if necesary
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
        ZO_WorldMap_ShowQuestOnMap(selectedQuestIndex)
    end
end