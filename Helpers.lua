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

    function Helpers.GetRadius()
        if x == 0 or y == 0 then return end

        local x2, y2 = GetMapPlayerPosition("player")

        local dx, dy = x2-x, y2-y
        r = math.sqrt(dx*dx + dy*dy)

        LCQ_DBG:Log("Radius (distance) for previously set point: <<1>>", LCQ_DBG_ALWAYS_SHOW, tostring(r))
    end

    LibCustomQuest.Helpers = Helpers
end