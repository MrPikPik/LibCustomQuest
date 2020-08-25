----------
-- LCQ_Debugger
----------

--debugger version 1.3

LCQ_DBG_QUIET = 0
LCQ_DBG_NORMAL = 1
LCQ_DBG_INFO = 2
LCQ_DBG_VERBOSE = 3
LCQ_DBG_ERROR = 4
LCQ_DBG_CRITICAL = 5
LCQ_DBG_DEBUG = 6


LCQ_Debugger = ZO_Object:Subclass()

function LCQ_Debugger:New()
    local debugger = ZO_Object.New(self)
    debugger:Initialize()
    return debugger
end

function LCQ_Debugger:Initialize()
    self.logLevel = LCQ_DBG_NORMAL
end

function LCQ_Debugger:SetLogLevel(level)
    if level < LCQ_DBG_QUIET then
        self.logLevel = LCQ_DBG_QUIET
    elseif level > LCQ_DBG_DEBUG then
        self.logLevel = LCQ_DBG_DEBUG
    else
        self.logLevel = level
    end
end

function LCQ_Debugger:GetLogLevel()
    return self.logLevel
end

function LCQ_Debugger:Log(message, debugLevel, ...)
    if not message then return end
    local level = debugLevel or 1
    if level <= self.logLevel then
        local lvlstr = "|cffffff"
        if level == 2 then
            lvlstr = "|c0fb800[Info] "
        elseif level == 3 then
            lvlstr = "|cff9d00[Warning] "
        elseif level == 4 then
            lvlstr = "|cc40000[Error] "
        elseif level == 5 then
            lvlstr = "|cff0000[Critical] "
        elseif level == 6 then
            lvlstr = "|c0081b8[Debug] "
        end
        
        df("[LCQ Debug] " .. lvlstr .. tostring(message) .. "|r", ...)
    end
end

function LCQ_Debugger:Warn(message, ...)
    if not message then return end
    self:Log(message, LCQ_DBG_VERBOSE, ...)
end

function LCQ_Debugger:Info(message, ...)
    if not message then return end
    self:Log(message, LCQ_DBG_INFO, ...)
end

function LCQ_Debugger:Error(message, ...)
    if not message then return end
    self:Log(message, LCQ_DBG_ERROR, ...)
end

function LCQ_Debugger:Debug(message, ...)
    if not message then return end
    self:Log(message, LCQ_DBG_DEBUG, ...)
end

LCQ_DBG = LCQ_Debugger:New()