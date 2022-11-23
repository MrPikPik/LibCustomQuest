------------------
-- LCQ_Debugger --
------------------

--debugger version 1.6

LCQ_DBG_ALWAYS_SHOW = 0
LCQ_DBG_QUIET       = 1
LCQ_DBG_CRITICAL    = 2
LCQ_DBG_ERROR       = 3
LCQ_DBG_NORMAL      = 4
LCQ_DBG_WARNING     = 5
LCQ_DBG_INFO        = 6
LCQ_DBG_VERBOSE     = 7
LCQ_DBG_DEBUG       = 8

LCQ_Debugger = ZO_Object:Subclass()

function LCQ_Debugger:New()
    local debugger = ZO_Object.New(self)
    debugger:Initialize()
    return debugger
end

function LCQ_Debugger:Initialize()
    self.logLevel = LCQ_DBG_NORMAL or LCQ_DBG_QUIET
    self.showDebug = false
end

---Sets the current log level
---@param level number
function LCQ_Debugger:SetLogLevel(level)
    if level < LCQ_DBG_QUIET then
        self.logLevel = LCQ_DBG_QUIET
    elseif level >= LCQ_DBG_DEBUG then
        self.logLevel = LCQ_DBG_DEBUG
        self.showDebug = true
    else
        self.logLevel = level
    end
end

---Set the debug output enabled or disabled
---@param enabled boolean
function LCQ_Debugger:SetDebugOutputEnabled(enabled)
    self.showDebug = enabled
end

---Gets the current log level
---@return number currentLogLevel
function LCQ_Debugger:GetLogLevel()
    return self.logLevel
end

---Prints a message to chat
---@param message string Format string used by zo_strformat
---@param debugLevel number
function LCQ_Debugger:Log(message, debugLevel, ...)
    if not message then return end
    local level = debugLevel or 1

    if level <= self.logLevel or level == LCQ_DBG_ALWAYS_SHOW then
        if level == LCQ_DBG_DEBUG and not self.showDebug then return end
        d(zo_strformat(LCQ_DBG_FORMAT, GetString("LCQ_DBG_FORMAT_", level), zo_strformat(message, ...)))
    end
end

function LCQ_Debugger:TestLevels()
    self:Log("Debugger Test: Always Show",  LCQ_DBG_ALWAYS_SHOW)
    self:Log("Debugger Test: Quiet",        LCQ_DBG_QUIET)
    self:Log("Debugger Test: Critical",     LCQ_DBG_CRITICAL)
    self:Log("Debugger Test: Error",        LCQ_DBG_ERROR)
    self:Log("Debugger Test: Normal",       LCQ_DBG_NORMAL)
    self:Log("Debugger Test: Warning",      LCQ_DBG_WARNING)
    self:Log("Debugger Test: Info",         LCQ_DBG_INFO)
    self:Log("Debugger Test: Verbose",      LCQ_DBG_VERBOSE)
    self:Log("Debugger Test: Debug",        LCQ_DBG_DEBUG)
end

---Displays a warning in chat
---@param message string Format string used by zo_strformat
function LCQ_Debugger:Warn(message, ...)
    if not message then return end
    self:Log(message, LCQ_DBG_VERBOSE, ...)
end

---Displays a info in chat
---@param message string Format string used by zo_strformat
function LCQ_Debugger:Info(message, ...)
    if not message then return end
    self:Log(message, LCQ_DBG_INFO, ...)
end

---Displays a verbose message in chat
---@param message string Format string used by zo_strformat
function LCQ_Debugger:Verbose(message, ...)
    if not message then return end
    self:Log(message, LCQ_DBG_VERBOSE, ...)
end

---Displays an error in chat
---@param message string Format string used by zo_strformat
function LCQ_Debugger:Error(message, ...)
    if not message then return end
    self:Log(message, LCQ_DBG_ERROR, ...)
end

---Displays a critical error in chat
---@param message string Format string used by zo_strformat
function LCQ_Debugger:Critical(message, ...)
    if not message then return end
    self:Log(message, LCQ_DBG_CRITICAL, ...)
end

---Displays a debug message in chat
---@param message string Format string used by zo_strformat
function LCQ_Debugger:Debug(message, ...)
    if not message then return end
    self:Log(message, LCQ_DBG_DEBUG, ...)
end

---Throws a Lua error
---@param message string Format string used by zo_strformat
function LCQ_Debugger:LuaError(message, ...)
    message = message or "No message"
    error(zo_strformat(GetString(LCQ_DBG_FORMAT_3) .. message .. "|r", ...))
end

---Throws a Lua assertion
---@param condition bool Condition for assertion
---@param message string Format string used by zo_strformat
function LCQ_Debugger:LuaAssert(condition, message, ...)
    message = message or "No message"
    assert(condition, zo_strformat(GetString(LCQ_DBG_FORMAT_9) .. message .. "|r", ...))
end

LCQ_DBG = LCQ_Debugger:New()