LibCustomQuestShare = {name = "LibCustomQuestShare"}

local LCQS = LibCustomQuestShare
local name = LibCustomQuestShare.name

local CR = CHAT_ROUTER
local zoStr = zo_strFormat
local chatLibPrefix = "<".. name ..">"

local function HandleData(tag, questId)
	local msgText
	local questId = tostring(questId)

	if CUSTOM_QUEST_MANAGER:IsValidCustomQuestId(questId) then	
		local questName = CUSTOM_QUEST_MANAGER:GetCustomQuestName(questId)
		msgText = zoStr("Receiving Quest <<1>> From <<2>>", questName, GetUnitDisplayName(tag))
		CUSTOM_QUEST_MANAGER:StartQuest(_, questId)
	else end -- Show something here?

	CR:AddSystemMessage(chatLibPrefix .. msgText)
end

function LibCustomQuestShare.Initialize()
	-- Register Hew's Bane map for data sharing.
	LCQS.shareCQData = LibDataShare:RegisterMap("LibCustomQuest", 28, HandleData)
end