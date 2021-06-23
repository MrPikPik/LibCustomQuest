-- Main namespace table
LibCustomQuest = {}

-- Main update/polling interval in milliseconds. Gets used almost everywhere for polling based updates.
LCQ_UPDATE_INTERVAL = 1000


MENU_CATEGORY_CUSTOM_JOURNAL = 69

ZO_CATEGORY_LAYOUT_INFO[MENU_CATEGORY_CUSTOM_JOURNAL] = {
    binding = "TOGGLE_CUSTOM_JOURNAL",
    categoryName = LCQ_MAIN_MENU_CUSTOM_JOURNAL,

    descriptor = MENU_CATEGORY_CUSTOM_JOURNAL,
    normal = "EsoUI/Art/MainMenu/menuBar_journal_up.dds",
    pressed = "EsoUI/Art/MainMenu/menuBar_journal_down.dds",
    disabled = "EsoUI/Art/MainMenu/menuBar_journal_disabled.dds",
    highlight = "EsoUI/Art/MainMenu/menuBar_journal_over.dds",
}


----------------------
-- Quest Conditions --
----------------------
QUEST_CONDITION_TYPE_INVALID    = ""
QUEST_CONDITION_TYPE_TALK       = "talk"
QUEST_CONDITION_TYPE_INTERACT   = "interact"
QUEST_CONDITION_TYPE_ZONE       = "zone"
QUEST_CONDITION_TYPE_LOCATION   = "location"
QUEST_CONDITION_TYPE_GOLD       = "gold"
QUEST_CONDITION_TYPE_CRAFT      = "craft"
QUEST_CONDITION_TYPE_ITEM       = "item"
QUEST_CONDITION_TYPE_KILL       = "kill"


----------------------
--Interactions --
----------------------
CUSTOM_INTERACTION_START_QUEST  = "startQuest"
CUSTOM_INTERACTION_SIMPLE       = "simple"
CUSTOM_INTERACTION_TALK         = "talk"
CUSTOM_INTERACTION_EMOTE        = "emote"




-- Quest update events
CUSTOM_EVENT_CUSTOM_QUEST_ADDED = 1000
CUSTOM_EVENT_CUSTOM_QUEST_COMPLETE = 1001
CUSTOM_EVENT_CUSTOM_QUEST_OBJECTIVE_ADDED = 1002
CUSTOM_EVENT_CUSTOM_QUEST_OBJECTIVE_COMPLETED = 1003

-- Player change events
CUSTOM_EVENT_PLAYER_LOOT_RECEIVE = 2000
CUSTOM_EVENT_PLAYER_MONEY_RECEIVED = 2001
CUSTOM_EVENT_PLAYER_ZONE_CHANGE = 2002
CUSTOM_EVENT_PLAYER_DEATH = 2003



CUSTOM_EVENT_QUEST_SHOW_JOURNAL_ENTRY = 3000


function ProgressCustomQuestCondition(questId, stageIndex, conditionIndex)
    LCQ_DBG:Info("Received completion request for quest <<1>> at stage <<2>>, condition <<3>>", questId, stageIndex, conditionIndex)
    if not CUSTOM_QUEST_MANAGER:IsConditionComplete(questId, conditionIndex) then
        CUSTOM_QUEST_MANAGER:OnConditionComplete(questId, conditionIndex)
    end
end

function GetInteractionTargetName()
    local interactionExists, interactionAvailableNow, questInteraction, questTargetBased, questJournalIndex, questToolIndex, questToolOnCooldown = GetGameCameraInteractableInfo()
    local action, interactableName, interactionBlocked, isOwned, additionalInteractInfo, context, contextLink, isCriminalInteract = GetGameCameraInteractableActionInfo()

    -- Prioritization:
    -- 1. Base game interactibles (NPCs, containers, doors, etc.)
    -- 2. Reticle/Look-At target
    -- 3. Players

    if interactionExists and interactableName ~= "" and interactableName ~= nil then
        return interactableName
    elseif GetUnitName("reticleover") ~= "" and not IsUnitPlayer("reticleover") and (GetDistanceToReticleOverTarget() < 350) then -- TODO: Distance check "GetDistanceToReticleOverTarget() < 500"?
        LCQ_DBG:Debug("Interaction target has no range check!")
        return GetUnitName("reticleover")
    elseif PLAYER_TO_PLAYER:HasTarget() then
        return PLAYER_TO_PLAYER.currentTargetDisplayName
    else
        return ""
    end
end

function GetDistanceToReticleOverTarget()
    if not DoesUnitExist("reticleover") then return -1 end
    local _, x1, y1, z1 = GetUnitWorldPosition("player")
    local _, x2, y2, z2 = GetUnitWorldPosition("reticleover")
    local dx, dy, dz = x2 - x1, y2 - y1, z2 - z1
    local d = math.sqrt(dx*dx + dy*dy + dz*dz)
    --LCQ_DBG:Log("Distance to reticleover: <<1>>", LCQ_DBG_ALWAYS_SHOW, tostring(d))
    return d
end

function GetDistanceToPoint(x, y, z)
    if not x and not y then return -1 end
    local _, x1, y1, z1 = GetUnitWorldPosition("player")
    if not z then
        z = y
        y = y1
    end
    local dx, dy, dz = x - x1, y - y1, z - z1
    local d = math.sqrt(dx*dx + dy*dy + dz*dz)
    --LCQ_DBG:Log("Distance to point: <<1>>", LCQ_DBG_ALWAYS_SHOW, tostring(d))
    return d
end

-- SI_GAMECAMERAACTIONTYPE1     = "Search"
-- SI_GAMECAMERAACTIONTYPE10    = "Inspect"
-- SI_GAMECAMERAACTIONTYPE11    = "Repair"
-- SI_GAMECAMERAACTIONTYPE12    = "Unlock"
-- SI_GAMECAMERAACTIONTYPE13    = "Open"
-- SI_GAMECAMERAACTIONTYPE15    = "Examine"
-- SI_GAMECAMERAACTIONTYPE16    = "Fish"
-- SI_GAMECAMERAACTIONTYPE17    = "Reel In"
-- SI_GAMECAMERAACTIONTYPE18    = "Pack Up"
-- SI_GAMECAMERAACTIONTYPE19    = "Steal"
-- SI_GAMECAMERAACTIONTYPE2     = "Talk"
-- SI_GAMECAMERAACTIONTYPE20    = "Steal From"
-- SI_GAMECAMERAACTIONTYPE21    = "Pickpocket"
-- SI_GAMECAMERAACTIONTYPE23    = "Trespass"
-- SI_GAMECAMERAACTIONTYPE24    = "Hide"
-- SI_GAMECAMERAACTIONTYPE25    = "Preview"
-- SI_GAMECAMERAACTIONTYPE26    = "Exit"
-- SI_GAMECAMERAACTIONTYPE27    = "Excavate"
-- SI_GAMECAMERAACTIONTYPE3     = "Harvest"
-- SI_GAMECAMERAACTIONTYPE4     = "Disarm"
-- SI_GAMECAMERAACTIONTYPE5     = "Use"
-- SI_GAMECAMERAACTIONTYPE6     = "Read"
-- SI_GAMECAMERAACTIONTYPE7     = "Take"
-- SI_GAMECAMERAACTIONTYPE8     = "Destroy"
-- SI_GAMECAMERAACTIONTYPE9     = "Repair"