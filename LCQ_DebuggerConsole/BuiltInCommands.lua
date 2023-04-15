-- clear / cls
local function clear()
	LCQ_DEBUG_CONSOLE.output:Clear()
end
LCQ_DEBUG_CONSOLE:AddCommand("cls", clear)
LCQ_DEBUG_CONSOLE:AddCommand("clear", clear)

-- script
local function script(...)
	assert(LoadString(LCQ_DebugConsole.Utils.CombineArgs(...)))()
end
LCQ_DEBUG_CONSOLE:AddCommand("script", script)

-- nuke
local function nuke()
	LCQ_DBG:Warn("Nuking all saved progress, aka hard wipe!")
	LibCustomQuest.SV.QuestProgress = {}
end
LCQ_DEBUG_CONSOLE:AddCommand("nuke", nuke)