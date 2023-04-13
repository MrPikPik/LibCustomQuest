local Utils = {}

-- === String utils ===
-- Checks if a string starts with a given string
function Utils.StartsWith(text, search)
	return text:find(search, 1, #search) == 1
end

-- Left justify in given length
function Utils.LJust(text, len)
	local pad = string.rep(" ", len - #text)
	return text .. pad
end

-- Right justify in given length
function Utils.RJust(text, len)
	local pad = string.rep(" ", len - #text)
	return pad .. text
end

-- Center justify in given length
function Utils.CJust(text, len)
	local ws = (len - #text) / 2
	local pad = string.rep(" ", math.floor(ws))
	local opad = ((ws % 1) ~= 0.0) and " " or ""
	return pad .. text .. pad .. opad
end

-- === General utils ===
-- Appends all arguments into a whitespace delimited string
function Utils.CombineArgs(...)
	local text = ""
	for i = 1, select('#', ...) do
		text = text .. select(i, ...) .. " "
	end
	return string.sub(text, 1, -2)
end

-- Attempts to print a nice version of an object type
function Utils.TypedToString(obj)
	local t = type(obj)
	if t == "table" then
		return "<table>"
	elseif t == "function" then
		return "<function>"
	elseif t == "userdata" then
		if obj.GetName then
			return "<userdata:"..obj:GetName()..">"
		else
			return "<userdata:Unnamed>"
		end
	else
		return '<' .. t .. ':' .. tostring(obj) .. '>'
	end
end


function Utils.SortedPairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

LCQ_DebugConsole = getmetatable(LCQ_DEBUG_CONSOLE) or {}
LCQ_DebugConsole.Utils = Utils