LibCustomQuest = {}
local LibCustomQuest = LibCustomQuest

LibCustomQuest.name = "LibCustomQuest"
LibCustomQuest.version = 1.0

local questId = 1
local ActiveQuests = {}

function LibCustomQuest.OnInventoryChange(eventCode, bagId, slotId, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange)
   d("[LibCustomQuest] Inventory change: BagId " .. bagId .. ", Slot " .. slotId .. ", reason: " .. inventoryUpdateReason)
end

function LibCustomQuest.OnCurrencyUpdate(eventCode, currency, currencyLocation, newAmount, oldAmount, reason)
    d("[LibCustomQuest] Player gained " .. (newAmount - oldAmount) .. " of " .. currency)
end

function LibCustomQuest.OnUnitDeath(eventCode, unitTag, isDead)
    d("[LibCustomQuest] Something died (" .. unitTag .. ").")
end

function LibCustomQuest.OnLootReceived(eventCode, receivedBy, itemName, quantity, soundCategory, lootType, self, isPickpocketedLoot, questItemIcon, itemId, isStolen)
    d("[LibCustomQuest] Player looted " .. itemName)
end

function LibCustomQuest.OnSubzoneListChange(eventCode)
    d("[LibCustomQuest] SubzoneListChange")
end

function LibCustomQuest.OnZoneChange(eventCode, zoneName, subZoneName, newSubzone, zoneId, subZoneId)
    local a = {
        zoneId = zoneId,
        zoneName = zoneName,
        subZoneId = subZoneId,
        subZoneName = subZoneName,
        newSubzone = newSubzone,
    }
    
    d("[LibCustomQuest] Zone changed to " .. zoneName .. " (ID " .. zoneId .. ")")
    d(a)
end

function LibCustomQuest.OnZoneUpdate(eventCode, unitTag, newZoneName)
    d("[LibCustomQuest] Zone change for " .. unitTag .. " to " .. newZoneName)
end

function LibCustomQuest.OnPlayerStartSwimming(eventCode)
    d("[LibCustomQuest] Player started swimming.")
end

function LibCustomQuest.OnPlayerStopSwimming(eventCode)
    d("[LibCustomQuest] Player stopped swimming.")
end

function LibCustomQuest.OnPlayerInteract(eventCode, result, interactTargetName)
    d("[LibCustomQuest] Player interacted with " .. interactTargetName)
end

function LibCustomQuest.OnPlayerActivated(eventCode, initial)
    d("[LibCustomQuest] On player activated!")
end



function LibCustomQuest:RegisterQuest(quest)
    table.insert(self.ActiveQuests, quest)
    self.questId = self.questId + 1
end



function LibCustomQuest.Initialize()
    LibCustomQuest.manager = CUSTOM_QUEST_MANAGER
    
    local quest = {
        id = "TESTQUEST",
        location = "My Basement",
        type = "None",
        name = "Slapp Folvet",
        level = 69,
        instanceDisplayType = INSTANCE_DISPLAY_TYPE_RAID,
        text = "Folvet needs a real good slapping",
        stages = {
            [1] = {
                text = "I should go and slap her real good.",
                tasks = {
                    [1] = {
                        text = "Do \"stuff\"",
                        max = 420,
                    },
                },
            },
        },
    }
    
    local quest2 = {
        id = "TESTQUEST2",
        location = "My Basement",
        type = "None",
        name = "Slapp Hellhound",
        level = 50,
        instanceDisplayType = INSTANCE_DISPLAY_TYPE_DUNGEON,
        text = "Hellhound also needs a real good slapping",
        stages = {
            [1] = {
                text = "I should go and slap him.",
                tasks = {
                    [1] = {
                        text = "Do \"stuff\"",
                        max = 420,
                    },
                },
            },
        },
    }
    
    local quest3 = {
        id = "TESTQUEST3",
        location = "Stonefalls",
        type = "None",
        name = "New Content Awaits",
        level = 50,
        instanceDisplayType = INSTANCE_DISPLAY_TYPE_NONE,
        text = "I've heard about an addon creator, MrPikPik, who made it possible to create custom quests.\nI am very intrigued by this, so I will see what's up with this.",
        stages = {
            [1] = {
                text = "I heard the start of these new custom quests lies in Davon's Watch. I will immediately start my journey there and see if I can find new content.",
                tasks = {
                    [1] = {
                        text = "Travel to Davon's Watch",
                    },
                },
            },
        },
    }
    CUSTOM_QUEST_MANAGER:RegisterQuest(quest)
    CUSTOM_QUEST_MANAGER:RegisterQuest(quest2)
    CUSTOM_QUEST_MANAGER:RegisterQuest(quest3)

    
    CUSTOM_QUEST_JOURNAL_KEYBOARD:InitializeScenes()    
    
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
    end)
    
end


local function OnLibraryLoaded(event, addonName)
    if addonName ~= LibCustomQuest.name then return end
    EVENT_MANAGER:UnregisterForEvent(LibCustomQuest.name, EVENT_ADD_ON_LOADED)
    
    
    
    LibCustomQuest.SV = ZO_SavedVars:New("LCQSavedVariables", 1.0, nil, {})
    CUSTOM_QUEST_MANAGER.progress = LibCustomQuest.SV
    
    
    EVENT_MANAGER:RegisterForEvent(LibCustomQuest.name, EVENT_INVENTORY_SINLGE_SLOT_UPDATE, LibCustomQuest.OnInventoryChange)
    EVENT_MANAGER:RegisterForEvent(LibCustomQuest.name, EVENT_CURRENCY_UPDATE, LibCustomQuest.OnCurrencyUpdate)
    EVENT_MANAGER:RegisterForEvent(LibCustomQuest.name, EVENT_UNIT_DEATH_STATE_CHANGED, LibCustomQuest.OnUnitDeath)
    EVENT_MANAGER:RegisterForEvent(LibCustomQuest.name, EVENT_LOOT_RECEIVED, LibCustomQuest.OnLootReceived)
    --EVENT_MANAGER:RegisterForEvent(LibCustomQuest.name, EVENT_CURRENT_SUBZONE_LIST_CHANGED, LibCustomQuest.OnSubzoneListChange)
    EVENT_MANAGER:RegisterForEvent(LibCustomQuest.name, EVENT_ZONE_CHANGED, LibCustomQuest.OnZoneChange)
    EVENT_MANAGER:RegisterForEvent(LibCustomQuest.name, EVENT_ZONE_UPDATE, LibCustomQuest.OnZoneUpdate)
    EVENT_MANAGER:RegisterForEvent(LibCustomQuest.name, EVENT_PLAYER_SWIMMING, LibCustomQuest.OnPlayerStartSwimming)
    EVENT_MANAGER:RegisterForEvent(LibCustomQuest.name, EVENT_PLAYER_NOT_SWIMMING, LibCustomQuest.OnPlayerStopSwimming)
    EVENT_MANAGER:RegisterForEvent(LibCustomQuest.name, EVENT_CLIENT_INTERACT_RESULT, LibCustomQuest.OnPlayerInteract)
    EVENT_MANAGER:RegisterForEvent(LibCustomQuest.name, EVENT_PLAYER_ACTIVATED, LibCustomQuest.OnPlayerActivated)
    
    LibCustomQuest.Initialize()
    Alianym_Reticle:Initialize()
end
EVENT_MANAGER:RegisterForEvent(LibCustomQuest.name, EVENT_ADD_ON_LOADED, OnLibraryLoaded)