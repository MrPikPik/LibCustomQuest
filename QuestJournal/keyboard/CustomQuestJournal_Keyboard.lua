--/script SCENE_MANAGER:Show("customQuestJournal")

function CUSTOM_QUEST_JOURNAL_KEYBOARD:OnShowing()
    self.listDirty = true

	LCQ.buttonJournal.m_object:SetState(1)
	LCQ.buttonJournal.m_object:SetLocked(true)

    if self.listDirty then
        self:RefreshQuestMasterList()
        self:RefreshQuestList()
        self:RefreshQuestCount()
    end

    --self:FocusQuestWithIndex(QUEST_JOURNAL_MANAGER:GetFocusedQuestIndex())

    KEYBIND_STRIP:AddKeybindButtonGroup(self.keybindStripDescriptor)
end

function CUSTOM_QUEST_JOURNAL_KEYBOARD:OnHiding()
	LCQ.buttonJournal.m_object:SetState(0)
	LCQ.buttonJournal.m_object:SetLocked(false)

    KEYBIND_STRIP:RemoveKeybindButtonGroup(self.keybindStripDescriptor)
end

function CUSTOM_QUEST_JOURNAL_KEYBOARD:GetHintText(questId)
    return CUSTOM_QUEST_MANAGER:GetHintText(questId)
end

function CUSTOM_QUEST_JOURNAL_KEYBOARD:ShowOnMap()
   local selectedQuestIndex = self:GetSelectedQuestIndex()
   if(selectedQuestIndex) then
        LCQ_DBG:Error("Show on map not implemented yet")
        --ZO_WorldMap_ShowQuestOnMap(selectedQuestIndex)
    end
end

function CUSTOM_QUEST_JOURNAL_KEYBOARD:InitializeKeybindStripDescriptors()
    self.keybindStripDescriptor =
    {
        alignment = KEYBIND_STRIP_ALIGN_CENTER,

        -- Show On Map
        {
            name = GetString(SI_QUEST_JOURNAL_SHOW_ON_MAP),
            keybind = "UI_SHORTCUT_SHOW_QUEST_ON_MAP",

            callback = function()
                local selectedQuestIndex = self:GetSelectedQuestIndex()
                if(selectedQuestIndex) then
                    self:ShowOnMap(selectedQuestIndex)
                end
            end,

            visible = function()
                local selectedQuestIndex = self:GetSelectedQuestIndex()
                if(selectedQuestIndex) then
                    return true
                end
                return false
            end
        },
    }
end

function CUSTOM_QUEST_JOURNAL_KEYBOARD:RefreshQuestCount()
    local questsCount=0
    for _ in pairs(CUSTOM_QUEST_MANAGER.quests) do
        questsCount = questsCount+1
    end

    self.questCount:SetText(zo_strformat(LCQ_QUESTS_CURRENT, questsCount)) --#CUSTOM_QUEST_MANAGER.quests won't work because of the strings as indices
end

function CUSTOM_QUEST_JOURNAL_KEYBOARD:RefreshQuestMasterList()
    LCQ_DBG:Info("Rebuilding quest masterlist...")
    local quests, categories, seenCategories = CUSTOM_QUEST_JOURNAL_MANAGER:GetQuestListData()
    self.questMasterList = {
        quests = quests,
        categories = categories,
        seenCategories = seenCategories,
    }
end

function CUSTOM_QUEST_JOURNAL_KEYBOARD:GetQuestInfo(questId)
    return CUSTOM_QUEST_MANAGER:GetQuestInfo(questId)
end

function CUSTOM_QUEST_JOURNAL_KEYBOARD:GetQuestRepeatType(questId)
    local repeatType = QUEST_REPEAT_NOT_REPEATABLE 
    if CUSTOM_QUEST_MANAGER:IsRepeatable(questId) then
        repeatType = QUEST_REPEAT_REPEATABLE
    else repeatType = QUEST_REPEAT_NOT_REPEATABLE end

    return repeatType
end