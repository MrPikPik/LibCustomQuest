LCQTQ = {}
local LCQTQ = LCQTQ

LCQTQ.id = "LCQ_TESTQUEST"

LCQTQ.Dialog1 = {
    speaker = "Silver-Gills",
    text = "Hello there traveler, how may I help you?",
    options = {
        [1] = {
            text = "I've heard, I can find new quests here in Davon's Watch",
            callback = function() ProgressCustomQuestCondition(LCQTQ.id, 2, 2) end,
            nextDialog = {
                speaker = "Silver-Gills",
                text = "Ah yes, the Mages Guild is currently looking for some assistance in... some peculiar matter.\n\nI suggest you go to them and ask there directly.",
            }
        },
    },
}

LCQTQ.Dialog2 = {
    speaker = "Tamthis Rothan",
    text = "What do you want?",
    options = {
        [1] = {
            text = "Do you know if... Nevermind",
            callback = function() ProgressCustomQuestCondition(LCQTQ.id, 2, 1) end,
        },
    },
}

LCQTQ.quest = {
    id = LCQTQ.id,
    lang = "en",
    location = "Stonefalls",
    type = ZO_ANY_QUEST_TYPE,
    name = "New Content Awaits",
    level = 50,
    instanceDisplayType = INSTANCE_DISPLAY_TYPE_NONE,
    text = "I've heard about an addon creator, MrPikPik, who made it possible to create custom quests.\nI am very intrigued by this, so I will see what's up with this.",
    outcome = "You learnt about custom quests and are now ready to do more of them.",
    stages = {
        [1] = {
            text = "I heard the start of these new custom quests lies in Davon's Watch. I will immediately start my journey there and see if I can find new content.",
            tasks = {
                [1] = {
                    text = "Travel to Davon's Watch",
                    type = QUEST_CONDITION_TYPE_LOCATION,
                    data = {
                        zone = 41,
                        x = 369149,
                        y = 13875,
						z = 173883,
                        r = 128.5,
                    },
                },
            },
        },
        [2] = {
            text = "I arrived in Davon's Watch. I should ask the locals about this new quest, maybe they can help me.",
            tasks = {
                [1] = {
                    text = "Talk to Tamthis Rothan",
                    type = QUEST_CONDITION_TYPE_TALK,
                    data = {
                        type = CUSTOM_INTERACTION_TALK,
                        name = "Tamthis Rothan",
                        needsExternalConfirmation = true,
                        dialog = LCQTQ.Dialog2,
                    }
                },
                [2] = {
                    text = "Talk to Silver-Gills",
                    type = QUEST_CONDITION_TYPE_TALK,
                    data = {
                        type = CUSTOM_INTERACTION_TALK,
                        name = "Silver-Gills",
                        needsExternalConfirmation = true,
                        dialog = LCQTQ.Dialog1,
                    }
                },
            },
        },
        [3] = {
            text = "The townfolk pointed me toward the Mages Guild. I will go there and see if there is the quest I am looking for.",
            hint = "The Mages Guild is located on the north of the town, close to the bank.",
            tasks = {
                [1] = {
                    text = "Enter the Mages Guild",
                    type = QUEST_CONDITION_TYPE_LOCATION,
                    data = {
                        zone = 41,
                        x = 357618,
                        y = 5291,
                        z = 173307,
                        r = 5.0,
                    },
                },
            },
        },
    },
}


local function OnAddonLoaded(event, addonName)
    if addonName ~= "LCQ_TestQuest" then return end
    EVENT_MANAGER:UnregisterForEvent("LCQ_TestQuest", EVENT_ADD_ON_LOADED)

    local questStartData = {
        name = "Philius Dormier",
        zone = 41,
        x = 379485,
        y = 14920,
        z = 195040,
    }
	
    --LibCustomQuest.AddQuestGiver(LCQTQ.quest, questStartData)
    
	CUSTOM_QUEST_MANAGER:RegisterQuest(LCQTQ.quest)
	
    LCQ_INTERACTIONLISTENER:Listen({name = "Philius Dormier", type = CUSTOM_INTERACTION_START_QUEST, interactionText = "Start Quest", quest = LCQTQ.quest, questId = "LCQ_TESTQUEST"}, "LCQ_TESTQUEST")
    CUSTOM_QUEST_MARKER_MANAGER:AddQuestMarker("QUEST_MARKER_QUEST_GIVER", "Philius Dormier", 41, 379485, 14920, 195040)
end
EVENT_MANAGER:RegisterForEvent("LCQ_TestQuest", EVENT_ADD_ON_LOADED, OnAddonLoaded)


--/script CUSTOM_QUEST_MANAGER:StartQuest(LCQTQ.quest)