LCQ_QuestJournal_Keyboard = LCQ_QuestJournal_Shared:Subclass()

function LCQ_QuestJournal_Keyboard:New(...)
	local questJournalManager = LCQ_QuestJournal_Shared.New(self)
	questJournalManager:Initialize(...)
	return questJournalManager
end

function LCQ_QuestJournal_Keyboard:Initialize(control)
	self.control = control
	self.sceneName = "customQuestJournal"

	self.bgFragment = ZO_FadeSceneFragment:New(LCQ_SharedRightBackground_Keyboard)
	self.sceneTitle = LCQ_MAIN_MENU_CUSTOM_JOURNAL

	self.questCount = control:GetNamedChild("QuestCount")
	self.titleText = control:GetNamedChild("TitleText")
	self.levelText = control:GetNamedChild("LevelText")
	self.questIcon = control:GetNamedChild("QuestIcon")
	self.repeatableIcon = control:GetNamedChild("RepeatableIcon")
	self.repeatableText = control:GetNamedChild("RepeatableText")
	self.conditionTextOrLabel = control:GetNamedChild("ConditionTextOrLabel")
	self.hintTextBulletList = ZO_BulletList:New(control:GetNamedChild("HintTextBulletList"), "LCQ_QuestJournal_HintBulletLabel", "LCQ_QuestJournal_HintBullet")
	self.conditionTextBulletList = ZO_BulletList:New(control:GetNamedChild("ConditionTextBulletList"), "LCQ_QuestJournal_ConditionBulletLabel")
	self.optionalStepTextBulletList = ZO_BulletList:New(control:GetNamedChild("OptionalStepTextBulletList"), "LCQ_QuestJournal_ConditionBulletLabel")

	self.bgText = control:GetNamedChild("BGText")
	self.stepText = control:GetNamedChild("StepText")
	self.optionalStepTextLabel = control:GetNamedChild("OptionalStepTextLabel")
	self.questInfoContainer = control:GetNamedChild("QuestInfoContainer")
	self.questStepContainer = control:GetNamedChild("QuestStepContainer")

	LCQ_QuestJournal_Shared.Initialize(self, control)
			
	--Quest tracker depends on this data for finding the next quest to focus.
	self:RefreshQuestList()
end

function LCQ_QuestJournal_Keyboard:RegisterIcons()
	self:RegisterIconTexture(ZO_ANY_QUEST_TYPE,     INSTANCE_DISPLAY_TYPE_SOLO,             "EsoUI/Art/Journal/journal_Quest_Instance.dds")
	self:RegisterIconTexture(ZO_ANY_QUEST_TYPE,     INSTANCE_DISPLAY_TYPE_DUNGEON,          "EsoUI/Art/Journal/journal_Quest_Group_Instance.dds")
	self:RegisterIconTexture(ZO_ANY_QUEST_TYPE,     INSTANCE_DISPLAY_TYPE_GROUP_DELVE,      "EsoUI/Art/Journal/journal_Quest_Group_Delve.dds")
	self:RegisterIconTexture(ZO_ANY_QUEST_TYPE,     INSTANCE_DISPLAY_TYPE_GROUP_AREA,       "EsoUI/Art/Journal/journal_Quest_Group_Area.dds")
	self:RegisterIconTexture(ZO_ANY_QUEST_TYPE,     INSTANCE_DISPLAY_TYPE_RAID,             "EsoUI/Art/Journal/journal_Quest_Trial.dds")
	self:RegisterIconTexture(ZO_ANY_QUEST_TYPE,     INSTANCE_DISPLAY_TYPE_PUBLIC_DUNGEON,   "EsoUI/Art/Journal/journal_Quest_Dungeon.dds")
	self:RegisterIconTexture(ZO_ANY_QUEST_TYPE,     INSTANCE_DISPLAY_TYPE_DELVE,            "EsoUI/Art/Journal/journal_Quest_Delve.dds")
	self:RegisterIconTexture(ZO_ANY_QUEST_TYPE,     INSTANCE_DISPLAY_TYPE_HOUSING,          "EsoUI/Art/Journal/journal_Quest_Housing.dds")
	self:RegisterIconTexture(ZO_ANY_QUEST_TYPE,     INSTANCE_DISPLAY_TYPE_ZONE_STORY,       "EsoUI/Art/Journal/journal_Quest_ZoneStory.dds")
	self:RegisterIconTexture(ZO_ANY_QUEST_TYPE,     INSTANCE_DISPLAY_TYPE_COMPANION,        "EsoUI/Art/Journal/journal_Quest_Companion.dds")
end

function LCQ_QuestJournal_Keyboard:RegisterTooltips()
	--[[local function ZoneStoryParamFunction(questId)
		if questId then
			local zoneId = GetJournalQuestZoneStoryZoneId(questId)
			return GetZoneNameById(zoneId)
		end
		return ""
	end]]

	self:RegisterTooltipText(ZO_ANY_QUEST_TYPE,     INSTANCE_DISPLAY_TYPE_SOLO,             SI_QUEST_JOURNAL_SOLO_TOOLTIP)
	self:RegisterTooltipText(ZO_ANY_QUEST_TYPE,     INSTANCE_DISPLAY_TYPE_DUNGEON,          SI_QUEST_JOURNAL_DUNGEON_TOOLTIP)
	self:RegisterTooltipText(ZO_ANY_QUEST_TYPE,     INSTANCE_DISPLAY_TYPE_RAID,             SI_QUEST_JOURNAL_RAID_TOOLTIP)
	-- nothing should be marked as GROUP_DELVE, but just in case treat it like GROUP      
	self:RegisterTooltipText(ZO_ANY_QUEST_TYPE,     INSTANCE_DISPLAY_TYPE_GROUP_DELVE,      SI_QUEST_JOURNAL_GROUP_TOOLTIP)
	self:RegisterTooltipText(ZO_ANY_QUEST_TYPE,     INSTANCE_DISPLAY_TYPE_GROUP_AREA,       SI_QUEST_JOURNAL_GROUP_TOOLTIP)
	self:RegisterTooltipText(ZO_ANY_QUEST_TYPE,     INSTANCE_DISPLAY_TYPE_PUBLIC_DUNGEON,   SI_QUEST_JOURNAL_PUBLIC_DUNGEON_TOOLTIP)
	self:RegisterTooltipText(ZO_ANY_QUEST_TYPE,     INSTANCE_DISPLAY_TYPE_DELVE,            SI_QUEST_JOURNAL_DELVE_TOOLTIP)
	self:RegisterTooltipText(ZO_ANY_QUEST_TYPE,     INSTANCE_DISPLAY_TYPE_HOUSING,          SI_QUEST_JOURNAL_HOUSING_TOOLTIP)
	self:RegisterTooltipText(ZO_ANY_QUEST_TYPE,     INSTANCE_DISPLAY_TYPE_ZONE_STORY,       SI_QUEST_JOURNAL_ZONE_STORY_TOOLTIP) --, ZoneStoryParamFunction)
	self:RegisterTooltipText(ZO_ANY_QUEST_TYPE,     INSTANCE_DISPLAY_TYPE_COMPANION,        SI_QUEST_JOURNAL_COMPANION_TOOLTIP)
end

function LCQ_QuestJournal_Keyboard:SetIconTexture(iconControl, iconData, selected)
	local texture = GetControl(iconControl, "Icon")
	texture.selected = selected
	
	if selected then
		texture:SetTexture("EsoUI/Art/Journal/journal_Quest_Selected.dds")
		texture:SetAlpha(1)
		texture:SetHidden(false)
	else
		local texturePath = self:GetIconTexture(iconData.questType, iconData.displayType)

		if texturePath then
			texture:SetTexture(texturePath)
			texture.tooltipText = self:GetTooltipText(iconData.questType, iconData.displayType, iconData.questId)

			texture:SetAlpha(0.50)
			texture:SetHidden(false)
		else
			texture:SetHidden(true)
		end
	end
end

function LCQ_QuestJournal_Keyboard:InitializeQuestList()
	self.navigationTree = ZO_Tree:New(self.control:GetNamedChild("NavigationContainerScrollChild"), 60, -10, 300)

	local function TreeHeaderSetup(node, control, name, open)
		control:SimpleArrowSetup(name, open)

		ZO_IconHeader_UpdateSize(control)
	end

	self.navigationTree:AddTemplate("ZO_SimpleArrowIconHeader", TreeHeaderSetup, nil, nil, nil, 0)

	local function TreeEntrySetup(node, control, data, open)
		control:SetText(data.name)
		control.con = GetCon(data.level)
		control.questId = data.questId

		local NOT_SELECTED = false
		control:SetSelected(NOT_SELECTED)
		self:SetIconTexture(control, data, NOT_SELECTED)
	end

	local function TreeEntryOnSelected(control, data, selected, reselectingDuringRebuild)
		self:FireCallbacks("QuestSelected", data.questId)
		control:SetSelected(selected)
		if selected and not reselectingDuringRebuild then
			self:RefreshDetails()
			-- The quest tracker performs focus logic on quest/remove/update, only force focus if the player has clicked on the quest through the journal UI
			if SCENE_MANAGER:IsShowing(self.sceneName) then
				--FOCUSED_QUEST_TRACKER:ForceAssist(data.questId)
			end
		end

		self:SetIconTexture(control, data, selected)
	end

	local function TreeEntryEquality(left, right)
		return left.name == right.name
	end
	self.navigationTree:AddTemplate("LCQ_QuestJournalNavigationEntry", TreeEntrySetup, TreeEntryOnSelected, TreeEntryEquality)

	self.navigationTree:SetExclusive(true)
	self.navigationTree:SetOpenAnimation("ZO_TreeOpenAnimation")
end

function LCQ_QuestJournal_Keyboard:InitializeKeybindStripDescriptors()
	self.keybindStripDescriptor =
	{
		alignment = KEYBIND_STRIP_ALIGN_CENTER,

		-- Cycle Focused Quest
		--[[{
			name = GetString(SI_QUEST_JOURNAL_CYCLE_FOCUSED_QUEST),
			keybind = "UI_SHORTCUT_QUATERNARY",

			callback = function()
				d("Focus Quest not implemented")
				--local IGNORE_SCENE_RESTRICTION = true
				--FOCUSED_QUEST_TRACKER:AssistNext(IGNORE_SCENE_RESTRICTION)
				--self:FocusQuestWithIndex(LCQ_QUEST_JOURNAL_MANAGER:GetFocusedQuestId())
			end,

			visible = function()
				return GetNumCustomJournalQuests() >= 2
			end
		},]]

		-- Show On Map
		{
			name = GetString(SI_QUEST_JOURNAL_SHOW_ON_MAP),
			keybind = "UI_SHORTCUT_SHOW_QUEST_ON_MAP",

			callback = function()
				local selectedQuestId = self:GetSelectedQuestId()
				if(selectedQuestId) then
					self:ShowOnMap(selectedQuestId)
				end
			end,

			visible = function()
				local selectedQuestId = self:GetSelectedQuestId()
				if(selectedQuestId) then
					return true
				end
				return false
			end
		},

		-- Share Quest
		{
			name = GetString(SI_QUEST_JOURNAL_SHARE),
			keybind = "UI_SHORTCUT_TERTIARY",

			callback = function()
				local selectedQuestId = self:GetSelectedQuestId()
				if(selectedQuestId) then
					LCQ_QUEST_JOURNAL_MANAGER:ShareQuest(selectedQuestId)
				end
			end,

			visible = function()
				return self:CanShareQuest()
			end
		},

		-- Abandon Quest
		{
			name = GetString(SI_QUEST_JOURNAL_ABANDON),
			keybind = "UI_SHORTCUT_NEGATIVE",

			callback = function()
				local selectedData = self.navigationTree:GetSelectedData()
				if(selectedData and selectedData.questId) then
					LCQ_QUEST_JOURNAL_MANAGER:ConfirmAbandonQuest(selectedData.questId)
				end
			end,

			visible = function()
				return self:CanAbandonQuest()
			end
		},
	}
end

function LCQ_QuestJournal_Keyboard:InitializeScenes(sceneName, baseJournalBackgroundFragment)
	local LCQ_JOURNAL_FRAGMENT = ZO_HUDFadeSceneFragment:New(self.control)
	CUSTOM_QUEST_JOURNAL_SCENE = ZO_Scene:New(sceneName or self.sceneName, SCENE_MANAGER)

	CUSTOM_QUEST_JOURNAL_SCENE:AddFragmentGroup(FRAGMENT_GROUP.PLAYER_PROGRESS_BAR_KEYBOARD_CURRENT)
	CUSTOM_QUEST_JOURNAL_SCENE:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_STANDARD_RIGHT_PANEL)
	CUSTOM_QUEST_JOURNAL_SCENE:AddFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW)
	CUSTOM_QUEST_JOURNAL_SCENE:AddFragment(FRAME_TARGET_BLUR_STANDARD_RIGHT_PANEL_FRAGMENT)
	CUSTOM_QUEST_JOURNAL_SCENE:AddFragment(FRAME_EMOTE_FRAGMENT_JOURNAL)
	CUSTOM_QUEST_JOURNAL_SCENE:AddFragment(baseJournalBackgroundFragment or self.bgFragment)
	CUSTOM_QUEST_JOURNAL_SCENE:AddFragment(TITLE_FRAGMENT)
	CUSTOM_QUEST_JOURNAL_SCENE:AddFragment(ZO_SetTitleFragment:New(self.sceneTitle))
	CUSTOM_QUEST_JOURNAL_SCENE:AddFragment(TREE_UNDERLAY_FRAGMENT)
	CUSTOM_QUEST_JOURNAL_SCENE:AddFragment(CODEX_WINDOW_SOUNDS)
	CUSTOM_QUEST_JOURNAL_SCENE:AddFragment(LCQ_JOURNAL_FRAGMENT)

	--SYSTEMS:RegisterKeyboardRootScene(self.sceneName, CUSTOM_QUEST_JOURNAL_SCENE)

	CUSTOM_QUEST_JOURNAL_SCENE:RegisterCallback("StateChange",
		function(oldState, newState)
			if(newState == SCENE_SHOWING) then
				self.listDirty = true

				if self.listDirty then
					LCQ_QUEST_JOURNAL_MANAGER:BuildQuestListData()
					self:RefreshQuestCount()
					self:RefreshQuestList()
				end

				--self:FocusQuestWithIndex(LCQ_QUEST_JOURNAL_MANAGER:GetFocusedQuestId())

				KEYBIND_STRIP:AddKeybindButtonGroup(self.keybindStripDescriptor)
			elseif(newState == SCENE_HIDDEN) then
				KEYBIND_STRIP:RemoveKeybindButtonGroup(self.keybindStripDescriptor)
			end
		end)
end

function LCQ_QuestJournal_Keyboard:GetSceneName()
	return self.sceneName
end

function LCQ_QuestJournal_Keyboard:GetSelectedQuestData()
	return self.navigationTree:GetSelectedData()
end

--Not Updated
--[[function LCQ_QuestJournal_Keyboard:FocusQuestWithIndex(id)
	local node = self.questIdToTreeNode[id]

	if node then
		self.navigationTree:SelectNode(node)
	end
end]]

function LCQ_QuestJournal_Keyboard:RefreshQuestCount()
	self.questCount:SetText(zo_strformat(LCQ_QUESTS_CURRENT, CUSTOM_QUEST_MANAGER:GetNumCustomJournalQuests())) --, MAX_JOURNAL_QUESTS))
end

function LCQ_QuestJournal_Keyboard:RefreshQuestList()
	self.questIdToTreeNode = {}

	ClearTooltip(InformationTooltip)

	-- Add items to the tree
	self.navigationTree:Reset()

	local categoryNodes = {}

	local categories = LCQ_QUEST_JOURNAL_MANAGER:GetCustomQuestCategories()
	for i, categoryInfo in ipairs(categories) do
		categoryNodes[categoryInfo.name] = self.navigationTree:AddNode("ZO_SimpleArrowIconHeader", categoryInfo.name)
	end

	local firstNode
	local lastNode
	local assistedNode

	local questList = LCQ_QUEST_JOURNAL_MANAGER:GetQuestList()

	for i, questInfo in ipairs(questList) do
		local parent = categoryNodes[questInfo.categoryName]
		local questNode = self.navigationTree:AddNode("LCQ_QuestJournalNavigationEntry", questInfo, parent)
		firstNode = firstNode or questNode
		self.questIdToTreeNode[questInfo.questId] = questNode

		if lastNode then
			lastNode.nextNode = questNode
		end

		if i == #questList then
			questNode.nextNode = firstNode
		end

		--[[if assistedNode == nil and GetTrackedIsAssisted(TRACK_TYPE_QUEST, questInfo.questId) then
			assistedNode = questNode
		end]]

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

function LCQ_QuestJournal_Keyboard:RefreshDetails()
	KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybindStripDescriptor)

	local questData = self:GetSelectedQuestData()
	if not questData then
		self.questInfoContainer:SetHidden(true)
		self.questStepContainer:SetHidden(true)
		self.questIcon:SetHidden(true)
		self.repeatableIcon:SetHidden(true)
		ClearTooltip(InformationTooltip)
		return
	end

	self.questInfoContainer:SetHidden(false)
	self.questStepContainer:SetHidden(false)

	local questId = questData.questId
	local questName, bgText, stepText, stepType, stepOverrideText, completed, tracked, _, _, questType, instanceDisplayType = CUSTOM_QUEST_MANAGER:GetCustomQuestInfo(questId)
	local conColorDef = ZO_ColorDef:New(GetConColor(questData.level))
	local repeatableType = CUSTOM_QUEST_MANAGER:GetCustomQuestRepeatType(questId)

	self.titleText:SetText(zo_strformat(SI_QUEST_JOURNAL_QUEST_NAME_FORMAT, questName))
	self.levelText:SetText(zo_strformat(SI_QUEST_JOURNAL_QUEST_LEVEL, conColorDef:Colorize(tostring(questData.level))))

	local texturePath = self:GetIconTexture(questType, instanceDisplayType)
	if texturePath then
		self.questIcon:SetHidden(false)
		self.questIcon.tooltipText = self:GetTooltipText(questType, instanceDisplayType, questId)
		self.questIcon:SetTexture(texturePath)
	else
		self.questIcon:SetHidden(true)
	end

	if repeatableType ~= QUEST_REPEAT_NOT_REPEATABLE then
		self.repeatableText:SetText(GetString(SI_QUEST_JOURNAL_REPEATABLE_TEXT))
		self.repeatableText:SetHidden(false)
		self.repeatableIcon:SetHidden(false)
	else
		self.repeatableText:SetHidden(true)
		self.repeatableIcon:SetHidden(true)
	end

	self.conditionTextBulletList:Clear()
	self.optionalStepTextBulletList:Clear()
	self.hintTextBulletList:Clear()

	local questStrings = self.questStrings
	ZO_ClearNumericallyIndexedTable(questStrings)

	if completed then
		local goalCondition, _, _, _, goalBackgroundText, goalDescription = CUSTOM_QUEST_MANAGER:GetCustomQuestEnding(questId)
	   
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

		self:BuildTextForStepVisibility(questId, QUEST_STEP_VISIBILITY_HINT)
		if self.hintTextLabel then
			self.hintTextLabel:SetHidden(#questStrings == 0)
		end
		for i = 1, #questStrings do
			self.hintTextBulletList:AddLine(questStrings[i])
		end

		local offset = #questStrings > 0 and NON_EMPTY_LIST_Y_OFFSET or EMPTY_LIST_Y_OFFSET
		UpdateListAnchors(self.conditionTextOrLabel, self.hintTextBulletList.control, offset)

		ZO_ClearNumericallyIndexedTable(questStrings)

		local showMultipleOrSteps = LCQ_QUEST_JOURNAL_MANAGER:DoesShowMultipleOrSteps(stepOverrideText, stepType, questId)
		self.conditionTextOrLabel:SetText(showMultipleOrSteps and GetString(SI_QUEST_OR_DESCRIPTION) or "")
		LCQ_QUEST_JOURNAL_MANAGER:BuildTextForTasks(stepOverrideText, questId, questStrings)

		for i = 1, #questStrings do
			self.conditionTextBulletList:AddLine(questStrings[i].name)
		end
		ZO_ClearNumericallyIndexedTable(questStrings) 

		self:BuildTextForStepVisibility(questId, QUEST_STEP_VISIBILITY_OPTIONAL)
		self.optionalStepTextLabel:SetHidden(#questStrings == 0)
		for i = 1, #questStrings do
			self.optionalStepTextBulletList:AddLine(questStrings[i])
		end
		ZO_ClearNumericallyIndexedTable(questStrings) 
	end
end

--XML Handlers

function LCQ_QuestJournalNavigationEntry_GetTextColor(self)
	if self.selected then
		return GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_SELECTED)
	elseif self.mouseover  then
		return GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_HIGHLIGHT)
	else
		return GetColorForCon(self.con)
	end
end

function LCQ_QuestJournalNavigationEntry_OnMouseUp(label, button, upInside)
	if button == MOUSE_BUTTON_INDEX_RIGHT and upInside then
		local node = label.node
		local questId = node.data.questId
		if questId then
			ClearMenu()

			--AddMenuItem(GetString(SI_QUEST_JOURNAL_SHOW_ON_MAP), function() ZO_WorldMap_ShowQuestOnMap(questId) end)

			if CUSTOM_QUEST_MANAGER:GetIsCustomQuestSharable(questId) and IsUnitGrouped("player") then
				--AddMenuItem(GetString(SI_QUEST_JOURNAL_SHARE), function() LCQ_QUEST_JOURNAL_MANAGER:ShareQuest(questId) end)
			end

			if(node.data.questType ~= QUEST_TYPE_MAIN_STORY) then
				AddMenuItem(GetString(SI_QUEST_JOURNAL_ABANDON), function() LCQ_QUEST_JOURNAL_MANAGER:ConfirmAbandonQuest(questId) end)
			end

			AddMenuItem(GetString(SI_QUEST_JOURNAL_REPORT_QUEST), function()
																	HELP_CUSTOMER_SUPPORT_KEYBOARD:OpenScreen(HELP_CUSTOMER_SERVICE_QUEST_ASSISTANCE_KEYBOARD:GetFragment())
																	HELP_CUSTOMER_SERVICE_QUEST_ASSISTANCE_KEYBOARD:SetDetailsText(node.data.name)
																end)

			ShowMenu(label)
		end
		return
	end

	--ZO_ZoneStories_Manager.StopZoneStoryTracking()

	ZO_TreeEntry_OnMouseUp(label, upInside)
end

function LCQ_QuestJournal_Keyboard_OnInitialized(control)
	CUSTOM_QUEST_JOURNAL_KEYBOARD = LCQ_QuestJournal_Keyboard:New(control)
	SYSTEMS:RegisterKeyboardObject("customQuestJournal", CUSTOM_QUEST_JOURNAL_KEYBOARD)
end

function LCQ_QuestJournal_OnQuestIconMouseEnter(texture)
	if texture.tooltipText and texture.tooltipText ~= "" then
		InitializeTooltip(InformationTooltip, texture, BOTTOM, 0, 0, TOP)
		SetTooltipText(InformationTooltip, texture.tooltipText)
	end
end

function LCQ_QuestJournal_OnQuestIconMouseExit()
	ClearTooltip(InformationTooltip)
end