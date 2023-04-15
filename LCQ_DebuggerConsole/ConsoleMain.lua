local LCQ_DebugConsole = ZO_Object:Subclass()

function LCQ_DebugConsole:New(control)
	local c = ZO_Object.New(self)
	c:Initialize(control)
	return c
end

function LCQ_DebugConsole:Initialize(control)
	self.control = control
		
	self.commands = {}
	self.mirrorToChat = true
	self.chatLogLevel = LCQ_DBG_WARNING
	
	-- TODO: Buffer messages for later filtering.
	--self.messageBuffer = ZO_CircularBuffer:New(500)

	self.output = control:GetNamedChild("Output")
	self.input = control:GetNamedChild("EditBox")

	SLASH_COMMANDS["/lcqdebugconsole"] = LCQ_DebugConsole_Toggle

	local function Log(debugger, message, debugLevel, ...)
		if not message then return end
		local level = debugLevel or 1

		if level <= debugger:GetLogLevel() or level == LCQ_DBG_ALWAYS_SHOW then
			if level == LCQ_DBG_DEBUG and not debugger.showDebug then return end
			local currentTime = GetTimeString()

			local logText = zo_strformat("[<<1>>]<<2>> <<3>>|r", currentTime ,GetString("LCQ_DBG_FORMAT_", level), zo_strformat(message, ...))
			self:Write(logText)
			if self.mirrorToChat then
				if level <= self.chatLogLevel or level == LCQ_DBG_ALWAYS_SHOW then
					d(logText)
				end
			end
		end
	end

	LCQ_DBG.Log = Log
end


function LCQ_DebugConsole:Write(text)
	self.output:AddMessage(text)
end

function LCQ_DebugConsole:AddCommand(name, fn)
	self.commands[name] = fn
end

function LCQ_DebugConsole:InvokeCommand(name, ...)
	if self.commands[name] then
		self.commands[name](...)
	else
		self:Write(zo_strformat("Command '<<1>>' unknown.", name))
	end
end

function LCQ_DebugConsole:Exec(str)
	local argv = {}
	for substr in str:gmatch("%S+") do table.insert(argv, substr) end
	self:Write(zo_strformat("Debugger Input: <<1>>", str))
	self:InvokeCommand(unpack(argv))
end

--XML Handlers
function LCQ_DebugConsole_Init(control)
	LCQ_DEBUG_CONSOLE = LCQ_DebugConsole:New(control)
end

function LCQ_DebugConsole_Close()
	LCQ_DEBUG_CONSOLE.control:SetHidden(true)
end

function LCQ_DebugConsole_Toggle()
	if LCQ_DEBUG_CONSOLE.control:IsHidden() then
		LCQ_DEBUG_CONSOLE.control:SetHidden(false)
		--LCQ_DEBUG_CONSOLE.input:TakeFocus()
	else
		LCQ_DEBUG_CONSOLE.control:SetHidden(true)
	end
end

function LCQ_DebugConsole_ExecFromInput()
	LCQ_DEBUG_CONSOLE:Exec(LCQ_DEBUG_CONSOLE.input:GetText())
end

function LCQ_DebugConsole_OnMouseWheel(control, delta, ctrl, alt, shift)
	local pos = control:GetNamedChild("Output"):GetScrollPosition()
	control:GetNamedChild("Output"):SetScrollPosition(pos - delta)
end

function LCQ_DebugConsole_ToggleFocus()
	if LCQ_DEBUG_CONSOLE.control:IsHidden() then
		LCQ_DEBUG_CONSOLE.control:SetHidden(false)
		LCQ_DEBUG_CONSOLE.input:TakeFocus()
	else
		LCQ_DEBUG_CONSOLE.control:SetHidden(true)
	end
end