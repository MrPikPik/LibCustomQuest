local LibCustomQuest = LibCustomQuest or {}

LibCustomQuest.name = "LibCustomQuest"
LibCustomQuest.version = 1.0

function LibCustomQuest.Initialize()
    LibCustomQuest.manager = CUSTOM_QUEST_MANAGER

    local quest4 = {
        id = "TESTQUEST4",
        location = "Stonefalls",
        type = "None",
        name = "Master Clothier",
        level = 50,
        instanceDisplayType = INSTANCE_DISPLAY_TYPE_NONE,
        text = "To become a better crafter, I must talk to the local master craftsmen.",
        stages = {
            [1] = {
                text = "I better talk to Voldsea Arvel in Davon's Watch.",
                tasks = {
                    [1] = {
                        text = "Talk to Voldsea Arvel",
                        type = QUEST_CONDITION_TYPE_TALK,
                        data = {
                            target = "Voldsea Arvel",
                            dialog = {},
                        }
                    },
                },
            },
            [2] = {
                text = "I talked to Voldsea Arvel in Davon's Watch.\nShe asked me to make some clothing at the crafting station nearby.",
                tasks = {
                    [1] = {
                        text = "Craft a robe",
                    },
                },
            },
        },
    }

    --CUSTOM_QUEST_MANAGER:RegisterQuest(quest4)

	local function GetButtonData()
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
	end

    --[[CUSTOM_QUEST_JOURNAL_KEYBOARD:InitializeScenes()

    local sceneGroupInfo = MAIN_MENU_KEYBOARD.sceneGroupInfo["journalSceneGroup"]
	local iconData = sceneGroupInfo.menuBarIconData

    for i = #iconData, 1, -1 do
        iconData[i + 1] = iconData[i]
        if i == 2 then
            iconData[2] = {
                categoryName = SI_JOURNAL_CUSTOM_QUEST_MENU_HEADER,
                descriptor = CUSTOM_QUEST_JOURNAL_KEYBOARD.sceneName,
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
	scenegroup:AddScene(CUSTOM_QUEST_JOURNAL_KEYBOARD.sceneName)
	MAIN_MENU_KEYBOARD:AddRawScene(CUSTOM_QUEST_JOURNAL_KEYBOARD.sceneName, MENU_CATEGORY_JOURNAL, MAIN_MENU_KEYBOARD.categoryInfo[MENU_CATEGORY_JOURNAL], "journalSceneGroup")


    CUSTOM_QUEST_JOURNAL_SCENE:RegisterCallback("StateChange", function(old, new)
        if new == "showing" then
            CUSTOM_QUEST_JOURNAL_KEYBOARD:RefreshQuestMasterList()
            CUSTOM_QUEST_JOURNAL_KEYBOARD:RefreshQuestList()
            CUSTOM_QUEST_JOURNAL_KEYBOARD:RefreshQuestCount()
        end
    end)]]

    -- Create all the various listener classes
    LibCustomQuest.listeners = {}

    -- LCQWorldCoordinateListener
    LCQ_COORDINATELISTENER = LCQWorldCoordinateListener:New()
    LCQ_COORDINATELISTENER:RegisterCallback("OnConditionMet", function(target)
        LCQ_COORDINATELISTENER:Remove(target)
        CUSTOM_QUEST_MANAGER:OnConditionComplete(target.questId, target.conditionid)
    end)
    LibCustomQuest.listeners[LCQ_COORDINATELISTENER.name] = LCQ_COORDINATELISTENER

    -- LCQInteractionListener
    LCQ_INTERACTIONLISTENER = LCQInteractionListener:New()
    LCQ_INTERACTIONLISTENER:RegisterCallback("OnConditionMet", function(target)
        LCQ_INTERACTIONLISTENER:Remove(target)
        CUSTOM_QUEST_MANAGER:OnConditionComplete(target.questId, target.conditionid)
    end)
    LibCustomQuest.listeners[LCQ_INTERACTIONLISTENER.name] = LCQ_INTERACTIONLISTENER

    -- LCQCurrencyListener
    LCQ_CURRENTYLISTENER = LCQCurrencyListener:New()
    LCQ_CURRENTYLISTENER:RegisterCallback("OnConditionMet", function(target)
        LCQ_DBG:Warn("Condition complete for condition #<<1>> in <<2>>", target.conditionid, target.questId)
    end)
    LCQ_CURRENTYLISTENER:RegisterCallback("OnConditionUpdate", function(target)
        LCQ_DBG:Warn("Condition update for condition #<<1>> in <<2>>: <<3>> remaining", target.conditionid, target.questId, target.amount)
    end)
    LibCustomQuest.listeners[LCQ_CURRENTYLISTENER.name] = LCQ_CURRENTYLISTENER

    -- Initialize the reticle hooks
    LibCustomQuest.SetupReticle()

    CUSTOM_QUEST_MARKER_MANAGER = LCQ_QuestMarkerManager:New()

    --/script CUSTOM_QUEST_MARKER_MANAGER:AddQuestMarker("QUEST_MARKER_QUEST_GIVER", 41, 379485, 14930, 195040)
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

function LibCustomQuest.OnBookRead(event, bookTitle, _, _, _, bookId)
    LCQ_INTERACTIONLISTENER:OnBookRead(bookTitle, bookId)
end

local function OnLibraryLoaded(event, addonName)
    if addonName ~= LibCustomQuest.name then return end
    EVENT_MANAGER:UnregisterForEvent(LibCustomQuest.name, EVENT_ADD_ON_LOADED)

    -- Debugger Log Level (Set this to normal so in general use most errors won't show)
    LCQ_DBG:SetLogLevel(LCQ_DBG_NORMAL)


    LibCustomQuest.SV = ZO_SavedVars:New("LCQSavedVariables", 1.0, nil, {})
    --CUSTOM_QUEST_MANAGER.progress = LibCustomQuest.SV
    LCQ_DBG:Debug("No SavedVariables loading or saving!")

    EVENT_MANAGER:RegisterForEvent(LibCustomQuest.name, EVENT_SHOW_BOOK, LibCustomQuest.OnBookRead)
    --EVENT_MANAGER:RegisterForEvent(LibCustomQuest.name, EVENT_CLIENT_INTERACT_RESULT, LibCustomQuest.OnPlayerInteract)
    --EVENT_MANAGER:RegisterForEvent(LibCustomQuest.name, EVENT_PLAYER_ACTIVATED, LibCustomQuest.OnPlayerActivated)

    LibCustomQuest.Initialize()

    SLASH_COMMANDS["/lcqgetpos"] = LibCustomQuest.Helpers.GetPos
    SLASH_COMMANDS["/lcqgetradius"] = LibCustomQuest.Helpers.GetRadius
    SLASH_COMMANDS["/lcqgetworldpos"] = LibCustomQuest.Helpers.GetWorldPos
end
EVENT_MANAGER:RegisterForEvent(LibCustomQuest.name, EVENT_ADD_ON_LOADED, OnLibraryLoaded)