local LibCustomQuest = LibCustomQuest or {}

LibCustomQuest.name = "LibCustomQuest"
LibCustomQuest.version = 1.0

function LibCustomQuest.Initialize()
    LibCustomQuest.manager = CUSTOM_QUEST_MANAGER

	--[[local function GetButtonData()
		ZO_SceneGroup:New(CUSTOM_QUEST_JOURNAL_KEYBOARD.sceneName)

		local clickSound = "Click_MenuBar"

		local buttonToQuestLog =
		{
            categoryName = LCQ_JOURNAL_CUSTOM_QUEST_MENU_HEADER,
            descriptor = CUSTOM_QUEST_JOURNAL_KEYBOARD.sceneName,
            normal = "EsoUI/Art/Journal/journal_tabIcon_quest_up.dds",
            pressed = "EsoUI/Art/Journal/journal_tabIcon_quest_down.dds",
            highlight = "EsoUI/Art/Journal/journal_tabIcon_quest_over.dds",
			callback = function(button) PlaySound(clickSound) SCENE_MANAGER:Show(CUSTOM_QUEST_JOURNAL_KEYBOARD.sceneName) end,
		}

		return {buttonToQuestLog}
	end]]

    local customSceneNameII = "customQuestJournalII"
    CUSTOM_QUEST_JOURNAL_KEYBOARD:InitializeScenes(customSceneNameII, RIGHT_BG_FRAGMENT)

    local sceneGroupInfo = MAIN_MENU_KEYBOARD.sceneGroupInfo["journalSceneGroup"]
	local iconData = sceneGroupInfo.menuBarIconData

    for i = #iconData, 1, -1 do
        iconData[i + 1] = iconData[i]
        if i == 2 then
            iconData[2] = {
                categoryName = LCQ_MAIN_MENU_CUSTOM_JOURNAL,
                descriptor = customSceneNameII,
                normal = "EsoUI/Art/Journal/journal_tabIcon_quest_up.dds",
                pressed = "EsoUI/Art/Journal/journal_tabIcon_quest_down.dds",
                highlight = "EsoUI/Art/Journal/journal_tabIcon_quest_over.dds",
            }
            break
        end
    end

	local sceneGroupBarFragment = sceneGroupInfo.sceneGroupBarFragment
	CUSTOM_QUEST_JOURNAL_SCENE:AddFragment(sceneGroupBarFragment)

    local scenegroup = SCENE_MANAGER:GetSceneGroup("journalSceneGroup")
	scenegroup:AddScene(customSceneNameII)
	MAIN_MENU_KEYBOARD:AddRawScene(customSceneNameII, MENU_CATEGORY_JOURNAL, MAIN_MENU_KEYBOARD.categoryInfo[MENU_CATEGORY_JOURNAL], "journalSceneGroup")

    --[[CUSTOM_QUEST_JOURNAL_SCENE:RegisterCallback("StateChange", function(old, new)
        if new == "showing" then
            CUSTOM_QUEST_JOURNAL_KEYBOARD:RefreshQuestMasterList()
            CUSTOM_QUEST_JOURNAL_KEYBOARD:RefreshQuestList()
            CUSTOM_QUEST_JOURNAL_KEYBOARD:RefreshQuestCount()
        end
    end)]]

    -- Create all the various listener classes
    LCQ_DBG:Verbose("Creating Listeners...")
    LibCustomQuest.listeners = {}

    -- LCQWorldCoordinateListener
    LCQ_COORDINATELISTENER = LCQWorldCoordinateListener:New()
    LCQ_COORDINATELISTENER:RegisterCallback("OnConditionMet", function(target)
        LCQ_COORDINATELISTENER:Remove(target)
        CUSTOM_QUEST_MANAGER:OnConditionComplete(target.questId, target.conditionId)
    end)
    LibCustomQuest.listeners[LCQ_COORDINATELISTENER.name] = LCQ_COORDINATELISTENER

    -- LCQInteractionListener
    LCQ_INTERACTIONLISTENER = LCQInteractionListener:New()
    LCQ_INTERACTIONLISTENER:RegisterCallback("OnConditionMet", function(target)
        LCQ_INTERACTIONLISTENER:Remove(target)
        CUSTOM_QUEST_MANAGER:OnConditionComplete(target.questId, target.conditionId)
    end)
    LibCustomQuest.listeners[LCQ_INTERACTIONLISTENER.name] = LCQ_INTERACTIONLISTENER

    -- LCQCurrencyListener
    LCQ_CURRENCYLISTENER = LCQCurrencyListener:New()
    LCQ_CURRENCYLISTENER:RegisterCallback("OnConditionMet", function(target)
        LCQ_DBG:Warn("Condition complete for condition #<<1>> in <<2>>", target.conditionId, target.questId)
    end)
    LCQ_CURRENCYLISTENER:RegisterCallback("OnConditionUpdate", function(target)
        LCQ_DBG:Warn("Condition update for condition #<<1>> in <<2>>: <<3>> remaining", target.conditionId, target.questId, target.amount)
    end)
    LibCustomQuest.listeners[LCQ_CURRENCYLISTENER.name] = LCQ_CURRENCYLISTENER

    -- LCQCombatListener
    LCQ_COMBATLISTENER = LCQCombatListener:New()
    LCQ_COMBATLISTENER:RegisterCallback("OnConditionMet", function(target)
        LCQ_COMBATLISTENER:Remove(target)
        CUSTOM_QUEST_MANAGER:OnConditionComplete(target.questId, target.conditionId)
        LCQ_DBG:Warn("Condition complete for condition #<<1>> in <<2>>", target.conditionId, target.questId)
    end)
    LibCustomQuest.listeners[LCQ_COMBATLISTENER.name] = LCQ_COMBATLISTENER

    -- Initialize the reticle hooks
    LCQ_DBG:Verbose("Setting up reticle...")
    LibCustomQuest.SetupReticle()

    LCQ_DBG:Verbose("Setting up QuestMarkerManager...")
    CUSTOM_QUEST_MARKER_MANAGER = LCQ_QuestMarkerManager:New()

    --/script CUSTOM_QUEST_MARKER_MANAGER:AddQuestMarker("QUEST_MARKER_QUEST_GIVER", 41, 379485, 14930, 195040)

    LCQ_DBG:Info("LibCustomQuest: Base initialization done.")
end

--[[function LibCustomQuest.InteractionHandler()
    local interactionType, interactionTarget = GetInteractionTargetName()

    LCQ_INTERACTIONLISTENER:RunInteractionForTarget(GetInteractionTargetName())
end]]

function LibCustomQuest.DebugBinding() 
    d("Target: \"" .. tostring(GetInteractionTargetName()) .. "\"")
    d(GetDistanceToReticleOverTarget())
    d(GetMapPlayerPosition("reticleover"))
end

function LibCustomQuest.AddQuestMarkerOnPlayer()
    local zone, x, y, z = GetUnitRawWorldPosition("player")
    CUSTOM_QUEST_MARKER_MANAGER:AddQuestMarker("QUEST_MARKER_TRACKED", zone, x, y + 350, z)
    CUSTOM_QUEST_MARKER_MANAGER:OnUpdate()
end

function LibCustomQuest.AddQuestGiver(quest, questStartData)
    
    local target = {
        name = questStartData.name,
        type = CUSTOM_INTERACTION_START_QUEST,
        quest = quest,
        questId = quest.id
    }

    LCQ_INTERACTIONLISTENER:Listen(target)
    CUSTOM_QUEST_MARKER_MANAGER:AddQuestMarker("QUEST_MARKER_QUEST_GIVER", questStartData.name, questStartData.zone, questStartData.x, questStartData.y, questStartData.z)
end

function LibCustomQuest.ShowJournal()
    if IsInGamepadPreferredMode() then
        SCENE_MANAGER:Toggle("gamepad_customQuestJournal")
    else
        SCENE_MANAGER:Toggle("customQuestJournal")
    end
end

local defaultVars = {
    ["QuestProgress"] = {   
    --[[
        -- Example Format
        [questId (string)] = {
            ["stage"] = currentStage (num),
            ["stages"] = {  
                [stage1 (num)] = {
                    ["conditions"] = {
                        [condition1 (num)] = complete (bool),
                        [condition2 (num)] = incomplete (bool),
                    },
                },
                [stage2 (num)] = {
                    ["conditions"] = {
                        [condition1 (num)] = incomplete (bool),
                        [condition2 (num)] = complete (bool),
                    },
                },
            },
        },
    ]]
    },
}

local function OnLibraryLoaded(event, addonName)
    if addonName ~= LibCustomQuest.name then return end
    EVENT_MANAGER:UnregisterForEvent(LibCustomQuest.name, EVENT_ADD_ON_LOADED)

    -- Debugger Log Level (Set this to LCQ_DBG_NORMAL so in general use most errors won't show)
    LCQ_DBG:SetLogLevel(LCQ_DBG_DEBUG)
    LCQ_DBG:SetDebugOutputEnabled(true)

    LCQ_DBG:Log("Initializing LibCustomQuest...", LCQ_DBG_ALWAYS_SHOW)

    -- Saved Vars
    LCQ_DBG:Verbose("Loading SavedVars and syncing progress...")
    LibCustomQuest.SV = ZO_SavedVars:NewCharacterIdSettings("LCQSavedVariables", 1.2, nil, defaultVars, GetWorldName())
    CUSTOM_QUEST_MANAGER.progress = LibCustomQuest.SV.QuestProgress

    --EVENT_MANAGER:RegisterForEvent(LibCustomQuest.name, EVENT_CLIENT_INTERACT_RESULT, LibCustomQuest.OnPlayerInteract)
    --EVENT_MANAGER:RegisterForEvent(LibCustomQuest.name, EVENT_PLAYER_ACTIVATED, LibCustomQuest.OnPlayerActivated)

    LibCustomQuest.Initialize()

    if LibDataShare then
        LCQ_DBG:Info("LibCustomQuestShare: LibDataShare found.")
        LibCustomQuestShare.Initialize()
        LibCustomQuestShare.SetEnabled(true)
    else
        LCQ_DBG:Info("LibCustomQuestShare: LibDataShare not found. Quest sharing will be disabled.")
        LibCustomQuestShare.SetEnabled(false)
    end

    LCQ_DBG:Verbose("Registering slash commands...")
    SLASH_COMMANDS["/lcqgetpos"] = LibCustomQuest.Helpers.GetWorldPos
    SLASH_COMMANDS["/lcqgetradius"] = LibCustomQuest.Helpers.GetWorldRadius
    SLASH_COMMANDS["/lcqsetlocmarker"] = LibCustomQuest.Helpers.SetLocMarker
    SLASH_COMMANDS["/lcqnuke"] = function() LibCustomQuest.SV.QuestProgress = {} end -- Nukes all saved quest progress

    LCQ = LibCustomQuest

    LCQ_DBG:Log("Finished initializing LibCustomQuest. Happy questing!", LCQ_DBG_ALWAYS_SHOW)
end
EVENT_MANAGER:RegisterForEvent(LibCustomQuest.name, EVENT_ADD_ON_LOADED, OnLibraryLoaded)