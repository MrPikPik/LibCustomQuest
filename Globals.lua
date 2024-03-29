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
QUEST_CONDITION_TYPE_COMBAT     = "combat"

----------------------
-- Quest Start Type --
----------------------
QUEST_START_TYPE_IMMEDIATE      = "immediatly"
QUEST_START_TYPE_DIALOGUE       = "dialogue"
QUEST_START_TYPE_BOOK           = "book"
QUEST_START_TYPE_INTERACTION    = "interaction"

----------------------
-- COMBAT EVENT TYPES --
----------------------
CUSTOM_COMBAT_EVENT_DAMAGE_TAKEN    = "damageTaken"
CUSTOM_COMBAT_EVENT_DAMAGE_GIVEN    = "damageGiven"
CUSTOM_COMBAT_EVENT_ON_DEATH        = "onDeath"

----------------------
-- COMBAT TARGET TYPES --
----------------------
COMBAT_TARGET_TYPE_MONSTER_DIFFICULTY   = "monsterDifficulty"

----------------------
--Interactions --
----------------------
CUSTOM_INTERACTION_START_QUEST      = "startQuest"
CUSTOM_INTERACTION_SIMPLE           = "simple"
CUSTOM_INTERACTION_TALK             = "talk"
CUSTOM_INTERACTION_EMOTE            = "emote"
CUSTOM_INTERACTION_EMOTE_AT_TARGET  = "emoteAtTarget"
CUSTOM_INTERACTION_READ             = "read"
CUSTOM_INTERACTION_LOOT             = "loot"

-- Quest update events
CUSTOM_EVENT_CUSTOM_QUEST_ADDED = 1000
CUSTOM_EVENT_CUSTOM_QUEST_COMPLETE = 1001
CUSTOM_EVENT_CUSTOM_QUEST_OBJECTIVE_ADDED = 1002
CUSTOM_EVENT_CUSTOM_QUEST_OBJECTIVE_COMPLETED = 1003
CUSTOM_EVENT_CUSTOM_QUEST_OBJECTIVE_UPDATED = 1004

-- Player change events
CUSTOM_EVENT_PLAYER_LOOT_RECEIVE = 2000
CUSTOM_EVENT_PLAYER_MONEY_RECEIVED = 2001
CUSTOM_EVENT_PLAYER_ZONE_CHANGE = 2002
CUSTOM_EVENT_PLAYER_DEATH = 2003

CUSTOM_EVENT_QUEST_SHOW_JOURNAL_ENTRY = 3000

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