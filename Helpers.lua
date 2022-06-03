local LibCustomQuest = LibCustomQuest or {}
do
    local Helpers = {}

    local x, y, r = 0, 0, 0


    function Helpers.GetPos()
        x, y = GetMapPlayerPosition("player")
        LCQ_DBG:Log("Point set: X=<<1>> Y=<<2>>", LCQ_DBG_ALWAYS_SHOW, tostring(x), tostring(y))
    end

    function Helpers.GetWorldPos()
        local _, x, y, z = GetUnitWorldPosition("player")
        LCQ_DBG:Log("Current World Position: X=<<1>> Y=<<2>> Z=<<3>>", LCQ_DBG_ALWAYS_SHOW, tostring(x), tostring(y), tostring(z))
    end

    function Helpers.GetRadius(x, y)
        if x == 0 or y == 0 then return end

        local x2, y2 = GetMapPlayerPosition("player")

        local dx, dy = x2-x, y2-y
        r = math.sqrt(dx*dx + dy*dy)

        LCQ_DBG:Log("Radius (distance) for previously set point: <<1>>", LCQ_DBG_ALWAYS_SHOW, tostring(r))
    end

    function Helpers.SetLocMarker()
        LCQ_DBG:Log("<Marker Reset>", LCQ_DBG_ALWAYS_SHOW)
        EVENT_MANAGER:UnregisterForUpdate(LibCustomQuest.name .. "Helpers") 

        local setZoneId, setX, setY, setZ = GetUnitWorldPosition("player")

        local function DisplayDistFromPoint()
            if GetZoneId(GetUnitZoneIndex("player")) == setZoneId and IsPlayerMoving() then
                local _, pX, pY, pZ = GetUnitWorldPosition("player")

                local distCM = zo_floor(zo_distance3D(setX, setY, setZ, pX, pY, pZ))
                local distM = zo_floor(distCM / 100)

                LCQ_DBG:Log("Distance From Marker: <<1>>", LCQ_DBG_ALWAYS_SHOW, distM)
            elseif GetZoneId(GetUnitZoneIndex("player")) ~= setZoneId then
                LCQ_DBG:Log("Moved out of Zone.", LCQ_DBG_ALWAYS_SHOW)
                EVENT_MANAGER:UnregisterForUpdate(LibCustomQuest.name .. "Helpers") 
            end
        end

        LCQ_DBG:Log("Marker set at current location – Move to see distance from point.", LCQ_DBG_ALWAYS_SHOW)

        EVENT_MANAGER:RegisterForUpdate(LibCustomQuest.name .. "Helpers", 500, function()
            DisplayDistFromPoint() 
        end)

        zo_callLater(function() 
            LCQ_DBG:Log("<Marker Expired>", LCQ_DBG_ALWAYS_SHOW) 
            EVENT_MANAGER:UnregisterForUpdate(LibCustomQuest.name .. "Helpers") 
        end, 20000)
    end

    LibCustomQuest.Helpers = Helpers
end