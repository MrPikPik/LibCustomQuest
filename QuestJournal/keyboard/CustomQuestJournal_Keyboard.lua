CustomQuestJournal_Keyboard = CustomQuestJournal_Shared:Subclass()

function CustomQuestJournal_Keyboard:New(...)
    local questJournalManager = CustomQuestJournal_Shared.New(self)
    questJournalManager:Initialize(...)
    return questJournalManager
end

function CustomQuestJournal_Keyboard:Initialize(control)
    self.control = control
    self.sceneName = "customQuestJournal"

    self.questCount = control:GetNamedChild("QuestCount")
    self.titleText = control:GetNamedChild("TitleText")
    self.levelText = control:GetNamedChild("LevelText")
    self.questIcon = control:GetNamedChild("QuestIcon")
    self.repeatableIcon = control:GetNamedChild("RepeatableIcon")
    self.repeatableText = control:GetNamedChild("RepeatableText")
    self.conditionTextOrLabel = control:GetNamedChild("ConditionTextOrLabel")
    self.hintTextBulletList = ZO_BulletList:New(control:GetNamedChild("HintTextBulletList"), "ZO_QuestJournal_HintBulletLabel", "ZO_QuestJournal_HintBullet")
    self.conditionTextBulletList = ZO_BulletList:New(control:GetNamedChild("ConditionTextBulletList"), "ZO_QuestJournal_ConditionBulletLabel")
    self.optionalStepTextBulletList = ZO_BulletList:New(control:GetNamedChild("OptionalStepTextBulletList"), "ZO_QuestJournal_ConditionBulletLabel")

    self.bgText = control:GetNamedChild("BGText")
    self.stepText = control:GetNamedChild("StepText")
    self.optionalStepTextLabel = control:GetNamedChild("OptionalStepTextLabel")
    self.questInfoContainer = control:GetNamedChild("QuestInfoContainer")
    self.questStepContainer = control:GetNamedChild("QuestStepContainer")

    self:RefreshQuestMasterList()

    CustomQuestJournal_Shared.Initialize(self, control)

    --Quest tracker depends on this data for finding the next quest to focus.
    self:RefreshQuestList()
end

function CustomQuestJournal_Keyboard:RegisterIcons()
    self:RegisterIconTexture(INSTANCE_DISPLAY_TYPE_SOLO,             "EsoUI/Art/Journal/journal_Quest_Instance.dds")
    self:RegisterIconTexture(INSTANCE_DISPLAY_TYPE_DUNGEON,          "EsoUI/Art/Journal/journal_Quest_Group_Instance.dds")
    self:RegisterIconTexture(INSTANCE_DISPLAY_TYPE_GROUP_DELVE,      "EsoUI/Art/Journal/journal_Quest_Group_Delve.dds")
    self:RegisterIconTexture(INSTANCE_DISPLAY_TYPE_GROUP_AREA,       "EsoUI/Art/Journal/journal_Quest_Group_Area.dds")
    self:RegisterIconTexture(INSTANCE_DISPLAY_TYPE_RAID,             "EsoUI/Art/Journal/journal_Quest_Trial.dds")
    self:RegisterIconTexture(INSTANCE_DISPLAY_TYPE_PUBLIC_DUNGEON,   "EsoUI/Art/Journal/journal_Quest_Dungeon.dds")
    self:RegisterIconTexture(INSTANCE_DISPLAY_TYPE_DELVE,            "EsoUI/Art/Journal/journal_Quest_Delve.dds")
    self:RegisterIconTexture(INSTANCE_DISPLAY_TYPE_HOUSING,          "EsoUI/Art/Journal/journal_Quest_Housing.dds")
    self:RegisterIconTexture(INSTANCE_DISPLAY_TYPE_ZONE_STORY,       "EsoUI/Art/Journal/journal_Quest_ZoneStory.dds")
end

function CustomQuestJournal_Keyboard:RegisterTooltips()
    self:RegisterTooltipText(INSTANCE_DISPLAY_TYPE_SOLO,             SI_QUEST_JOURNAL_SOLO_TOOLTIP)
    self:RegisterTooltipText(INSTANCE_DISPLAY_TYPE_DUNGEON,          SI_QUEST_JOURNAL_DUNGEON_TOOLTIP)
    self:RegisterTooltipText(INSTANCE_DISPLAY_TYPE_RAID,             SI_QUEST_JOURNAL_RAID_TOOLTIP)
    -- nothing should be marked as GROUP_DELVE, but just in case treat it like GROUP
    self:RegisterTooltipText(INSTANCE_DISPLAY_TYPE_GROUP_DELVE,      SI_QUEST_JOURNAL_GROUP_TOOLTIP)
    self:RegisterTooltipText(INSTANCE_DISPLAY_TYPE_GROUP_AREA,       SI_QUEST_JOURNAL_GROUP_TOOLTIP)
    self:RegisterTooltipText(INSTANCE_DISPLAY_TYPE_PUBLIC_DUNGEON,   SI_QUEST_JOURNAL_PUBLIC_DUNGEON_TOOLTIP)
    self:RegisterTooltipText(INSTANCE_DISPLAY_TYPE_DELVE,            SI_QUEST_JOURNAL_DELVE_TOOLTIP)
    self:RegisterTooltipText(INSTANCE_DISPLAY_TYPE_HOUSING,          SI_QUEST_JOURNAL_HOUSING_TOOLTIP)
    self:RegisterTooltipText(INSTANCE_DISPLAY_TYPE_ZONE_STORY,       SI_QUEST_JOURNAL_ZONE_STORY_TOOLTIP)
end

function CustomQuestJournal_Keyboard:SetIconTexture(iconControl, iconData, selected)
    local texture = GetControl(iconControl, "Icon")
    texture.selected = selected

    if selected then
        texture:SetTexture("EsoUI/Art/Journal/journal_Quest_Selected.dds")
        texture:SetAlpha(1)
        texture:SetHidden(false)
    else
        local texturePath = self:GetIconTexture(iconData.displayType)

        if texturePath then
            texture:SetTexture(texturePath)
            texture.tooltipText = self:GetTooltipText(iconData.displayType, iconData.questIndex)

            texture:SetAlpha(0.50)
            texture:SetHidden(false)
        else
            texture:SetHidden(true)
        end
    end
end

function CustomQuestJournal_Keyboard:InitializeQuestList()
    self.navigationTree = ZO_Tree:New(self.control:GetNamedChild("NavigationContainerScrollChild"), 60, -10, 300)

    local openTexture = "EsoUI/Art/Buttons/tree_open_up.dds"
    local closedTexture = "EsoUI/Art/Buttons/tree_closed_up.dds"
    local overOpenTexture = "EsoUI/Art/Buttons/tree_open_over.dds"
    local overClosedTexture = "EsoUI/Art/Buttons/tree_closed_over.dds"

    local function TreeHeaderSetup(node, control, name, open)
        control.text:SetModifyTextType(MODIFY_TEXT_TYPE_UPPERCASE)
        control.text:SetText(name)

        control.icon:SetTexture(open and openTexture or closedTexture)
        control.iconHighlight:SetTexture(open and overOpenTexture or overClosedTexture)

        control.text:SetSelected(open)

        ZO_IconHeader_UpdateSize(control)
    end

    self.navigationTree:AddTemplate("CustomQuestJournalHeader", TreeHeaderSetup, nil, nil, nil, 0)

    local function TreeEntrySetup(node, control, data, open)
        control:SetText(data.name)
        control.con = GetCon(data.level)
        control.questIndex = data.questIndex

        local NOT_SELECTED = false
        control:SetSelected(NOT_SELECTED)
        self:SetIconTexture(control, data, NOT_SELECTED)
    end

    local function TreeEntryOnSelected(control, data, selected, reselectingDuringRebuild)
        self:FireCallbacks("QuestSelected", data.questIndex)
        control:SetSelected(selected)
        if selected and not reselectingDuringRebuild then
            self:RefreshDetails()
            -- The quest tracker performs focus logic on quest/remove/update, only force focus if the player has clicked on the quest through the journal UI
            if SCENE_MANAGER:IsShowing(self.sceneName) then
                --FOCUSED_QUEST_TRACKER:ForceAssist(data.questIndex)
            end
        end

        self:SetIconTexture(control, data, selected)
    end

    local function TreeEntryEquality(left, right)
        return left.name == right.name
    end
    self.navigationTree:AddTemplate("CustomQuestJournalNavigationEntry", TreeEntrySetup, TreeEntryOnSelected, TreeEntryEquality)

    self.navigationTree:SetExclusive(true)
    self.navigationTree:SetOpenAnimation("ZO_TreeOpenAnimation")
end

function CustomQuestJournal_Keyboard:InitializeKeybindStripDescriptors()
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

function CustomQuestJournal_Keyboard:InitializeScenes()
    CUSTOM_QUEST_JOURNAL_SCENE = ZO_Scene:New(self.sceneName, SCENE_MANAGER)

    CUSTOM_QUEST_JOURNAL_SCENE:AddFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW)
    CUSTOM_QUEST_JOURNAL_SCENE:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_STANDARD_RIGHT_PANEL)
    CUSTOM_QUEST_JOURNAL_SCENE:AddFragmentGroup(FRAGMENT_GROUP.PLAYER_PROGRESS_BAR_KEYBOARD_CURRENT)
    CUSTOM_QUEST_JOURNAL_SCENE:AddFragment(FRAME_EMOTE_FRAGMENT_JOURNAL)
    CUSTOM_QUEST_JOURNAL_SCENE:AddFragment(RIGHT_BG_FRAGMENT)
    CUSTOM_QUEST_JOURNAL_SCENE:AddFragment(TREE_UNDERLAY_FRAGMENT)
    CUSTOM_QUEST_JOURNAL_SCENE:AddFragment(TITLE_FRAGMENT)
    CUSTOM_QUEST_JOURNAL_SCENE:AddFragment(JOURNAL_TITLE_FRAGMENT)
    CUSTOM_QUEST_JOURNAL_SCENE:AddFragment(CODEX_WINDOW_SOUNDS)

    local CUSTOM_QUEST_JOURNAL_FRAGMENT = ZO_HUDFadeSceneFragment:New(CustomQuestJournal)
    CUSTOM_QUEST_JOURNAL_SCENE:AddFragment(CUSTOM_QUEST_JOURNAL_FRAGMENT)

    CUSTOM_QUEST_JOURNAL_SCENE:RegisterCallback("StateChange",
        function(oldState, newState)
            if(newState == SCENE_SHOWING) then
                if self.listDirty then
                    self:RefreshQuestCount()
                    self:RefreshQuestList()
                end

                --self:FocusQuestWithIndex(QUEST_JOURNAL_MANAGER:GetFocusedQuestIndex())

                KEYBIND_STRIP:AddKeybindButtonGroup(self.keybindStripDescriptor)
            elseif(newState == SCENE_HIDDEN) then
                KEYBIND_STRIP:RemoveKeybindButtonGroup(self.keybindStripDescriptor)
            end
        end)
end

function CustomQuestJournal_Keyboard:GetSceneName()
    return self.sceneName
end

function CustomQuestJournal_Keyboard:GetSelectedQuestData()
    return self.navigationTree:GetSelectedData()
end

function CustomQuestJournal_Keyboard:FocusQuestWithIndex(index)
    local node = self.questIndexToTreeNode[index]

    if node then
        self.navigationTree:SelectNode(node)
    end
end

function CustomQuestJournal_Keyboard:RefreshQuestCount()
    self.questCount:SetText(zo_strformat(LCQ_QUESTS_CURRENT, #CUSTOM_QUEST_MANAGER.quests))
end

function CustomQuestJournal_Keyboard:RefreshQuestMasterList()
    LCQ_DBG:Info("Rebuilding quest masterlist...")
    local quests, categories, seenCategories = CUSTOM_QUEST_JOURNAL_MANAGER:GetQuestListData()
    self.questMasterList = {
        quests = quests,
        categories = categories,
        seenCategories = seenCategories,
    }
end

function CustomQuestJournal_Keyboard:RefreshQuestList()
    local quests = self.questMasterList.quests
    local categories = self.questMasterList.categories

    self.questIndexToTreeNode = {}

    ClearTooltip(InformationTooltip)

    -- Add items to the tree
    self.navigationTree:Reset()

    local categoryNodes = {}

    for i = 1, #categories do
        local categoryInfo = categories[i]
        categoryNodes[categoryInfo.name] = self.navigationTree:AddNode("CustomQuestJournalHeader", categoryInfo.name)
    end

    local firstNode
    local lastNode
    local assistedNode
    for i = 1, #quests do
        local questInfo = quests[i]
        local parent = categoryNodes[questInfo.categoryName]
        local questNode = self.navigationTree:AddNode("CustomQuestJournalNavigationEntry", questInfo, parent)
        firstNode = firstNode or questNode
        self.questIndexToTreeNode[questInfo.questIndex] = questNode

        if lastNode then
            lastNode.nextNode = questNode
        end

        if i == #quests then
            questNode.nextNode = firstNode
        end

        --if assistedNode == nil and GetTrackedIsAssisted(TRACK_TYPE_QUEST, questInfo.questIndex) then
        --    assistedNode = questNode
        --end

        lastNode = questNode
    end

    self.navigationTree:Commit(assistedNode)

    self:RefreshDetails()

    self.listDirty = false
end

local function UpdateListAnchors(control, attachedTo, yOffset)
    control:ClearAnchors()
    control:SetAnchor(TOPLEFT, attachedTo, BOTTOMLEFT, 0, yOffset)
    control:SetAnchor(TOPRIGHT, attachedTo, BOTTOMRIGHT, 0, yOffset)
end

local EMPTY_LIST_Y_OFFSET = 0
local NON_EMPTY_LIST_Y_OFFSET = 10



---------
--  Updates the right part with all the quest info!
---------
function CustomQuestJournal_Keyboard:RefreshDetails()
    KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybindStripDescriptor)

    local questData = self:GetSelectedQuestData()

    -- If there is no quest to show (if the player has no active quests) hide everything on the info pane
    if not questData then
        LCQ_DBG:Warn("No quest selected. Hiding details section")
        self.questInfoContainer:SetHidden(true)
        self.questStepContainer:SetHidden(true)
        self.questIcon:SetHidden(true)
        self.repeatableIcon:SetHidden(true)
        ClearTooltip(InformationTooltip)
        return
    end

    self.questInfoContainer:SetHidden(false)
    self.questStepContainer:SetHidden(false)

    local questID = questData.questIndex
    local questName, bgText, stepText, level, instanceDisplayType = CUSTOM_QUEST_MANAGER:GetQuestInfo(questID)
    local conColorDef = ZO_ColorDef:New(GetConColor(questData.level))
    local isRepeatable = CUSTOM_QUEST_MANAGER:IsRepeatable(questID)

    -- Quest name
    self.titleText:SetText(zo_strformat(SI_QUEST_JOURNAL_QUEST_NAME_FORMAT, questName))

    -- Quest level
    local lvl = (type(questData.level) == "number") and conColorDef:Colorize(tostring(questData.level)) or questData.level
    self.levelText:SetText(zo_strformat(SI_QUEST_JOURNAL_QUEST_LEVEL, lvl))

    -- Special icon (e.g. trial, dungeon, arena)
    local texturePath = self:GetIconTexture(instanceDisplayType)
    if texturePath then
        self.questIcon:SetHidden(false)
        self.questIcon.tooltipText = self:GetTooltipText(instanceDisplayType, questIndex)
        self.questIcon:SetTexture(texturePath)
    else
        self.questIcon:SetHidden(true)
    end

    -- Repeatable (dailies, weeklies)
    if isRepeatable then
        self.repeatableText:SetText(GetString(SI_QUEST_JOURNAL_REPEATABLE_TEXT))
        self.repeatableText:SetHidden(false)
        self.repeatableIcon:SetHidden(false)
    else
        self.repeatableText:SetHidden(true)
        self.repeatableIcon:SetHidden(true)
    end


    -- Stage details
    self.conditionTextBulletList:Clear()
    self.optionalStepTextBulletList:Clear()
    self.hintTextBulletList:Clear()

    local questIndex = questData.questIndex
    local questStrings = self.questStrings
    ZO_ClearNumericallyIndexedTable(questStrings)

    if completed then
        local goalCondition, _, _, _, goalBackgroundText, goalDescription = GetJournalQuestEnding(questIndex)

        self.bgText:SetText(goalBackgroundText)
        self.stepText:SetText(goalDescription)
        self.conditionTextOrLabel:SetText("")
        self.conditionTextBulletList:AddLine(goalCondition)
        self.optionalStepTextLabel:SetHidden(true)
        if self.hintTextLabel then
            self.hintTextLabel:SetHidden(true)
        end
    else
        self.bgText:SetText(bgText)
        self.stepText:SetText(stepText)

        -- Hints
        local hint = self:GetHintText(questIndex)
        if hint then
            if self.hintTextLabel then
                self.hintTextLabel:SetHidden(hint ~= "")
            end
            self.hintTextBulletList:AddLine(hint)
        end

        --self:BuildTextForStepVisibility(questIndex, QUEST_STEP_VISIBILITY_HINT)
        --if self.hintTextLabel then
        --    self.hintTextLabel:SetHidden(#questStrings == 0)
        --end
        --for i = 1, #questStrings do
        --    self.hintTextBulletList:AddLine(questStrings[i])
        --end

        local offset = hint and NON_EMPTY_LIST_Y_OFFSET or EMPTY_LIST_Y_OFFSET
        UpdateListAnchors(self.conditionTextOrLabel, self.hintTextBulletList.control, offset)

        ZO_ClearNumericallyIndexedTable(questStrings)

        -- Tasks
        local showMultipleOrSteps = CUSTOM_QUEST_JOURNAL_MANAGER:DoesShowMultipleOrSteps(stepType, questIndex)
        self.conditionTextOrLabel:SetText(showMultipleOrSteps and GetString(SI_QUEST_OR_DESCRIPTION) or "")
        CUSTOM_QUEST_JOURNAL_MANAGER:BuildTextForTasks(questIndex, questStrings)

        for i = 1, #questStrings do
            self.conditionTextBulletList:AddLine(questStrings[i].name)
        end
        ZO_ClearNumericallyIndexedTable(questStrings)

        -- Optional Tasks
        self:BuildTextForStepVisibility(questIndex, QUEST_STEP_VISIBILITY_OPTIONAL)
        self.optionalStepTextLabel:SetHidden(#questStrings == 0)
        for i = 1, #questStrings do
            self.optionalStepTextBulletList:AddLine(questStrings[i])
        end
        ZO_ClearNumericallyIndexedTable(questStrings)
    end
end

function CustomQuestJournal_Keyboard:GetNextSortedQuestForQuestIndex(questIndex)
    if self.questMasterList and self.questMasterList.quests then
        local quests = self.questMasterList.quests
        for i, quest in ipairs(quests) do
            if quest.questIndex == questIndex then
                local nextQuest = (i == #quests) and 1 or (i + 1)
                return quests[nextQuest].questIndex
            end
        end
    end
end

--XML Handlers
do
    local function OnMouseEnter(control)
        ZO_SelectableLabel_OnMouseEnter(control.text)
        control.iconHighlight:SetHidden(false)
    end

    local function OnMouseExit(control)
        ZO_SelectableLabel_OnMouseExit(control.text)
        control.iconHighlight:SetHidden(true)
    end

    local function OnMouseUp(control, upInside)
        ZO_TreeHeader_OnMouseUp(control, upInside)
    end

    function CustomQuestJournalHeader_OnInitialized(self)
        self.icon = self:GetNamedChild("Icon")
        self.iconHighlight = self.icon:GetNamedChild("Highlight")
        self.text = self:GetNamedChild("Text")

        self.OnMouseEnter = OnMouseEnter
        self.OnMouseExit = OnMouseExit
        self.OnMouseUp = OnMouseUp
    end
end

function CustomQuestJournalNavigationEntry_GetTextColor(self)
    if self.selected then
        return GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_SELECTED)
    elseif self.mouseover  then
        return GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_HIGHLIGHT)
    else
        return GetColorForCon(self.con)
    end
end

function CustomQuestJournalNavigationEntry_OnMouseUp(label, button, upInside)
    if button == MOUSE_BUTTON_INDEX_RIGHT and upInside then
        local node = label.node
        local questIndex = node.data.questIndex
        if questIndex then
            ClearMenu()

            AddMenuItem(GetString(SI_QUEST_JOURNAL_SHOW_ON_MAP), function()
                LCQ_DBG:Error("Show on map not implemented yet")
                --ZO_WorldMap_ShowQuestOnMap(questIndex)
            end)


            ShowMenu(label)
        end
        return
    end

    ZO_TreeEntry_OnMouseUp(label, upInside)
end

function CustomQuestJournal_Keyboard_OnInitialized(control)
    CUSTOM_QUEST_JOURNAL_KEYBOARD = CustomQuestJournal_Keyboard:New(control)
    SYSTEMS:RegisterKeyboardObject("customQuestJournal", CUSTOM_QUEST_JOURNAL_KEYBOARD)
end

function CustomQuestJournal_OnQuestIconMouseEnter(texture)
    if texture.tooltipText and texture.tooltipText ~= "" then
        InitializeTooltip(InformationTooltip, texture, BOTTOM, 0, 0, TOP)
        SetTooltipText(InformationTooltip, texture.tooltipText)
    end
end

function CustomQuestJournal_OnQuestIconMouseExit()
    ClearTooltip(InformationTooltip)
end