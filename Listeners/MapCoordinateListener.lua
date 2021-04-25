-----------------------------------------
-- Map Coordinate Listener
-----------------------------------------

LCQMapCoordinateListener = LCQListener:Subclass()

function LCQMapCoordinateListener:New(...)
    local listener = LCQListener.New(self, ...)
    listener:Initialize(...)
    return listener
end

function LCQMapCoordinateListener:Initialize()
    self.name = "MapCoordinateListener"
    self.targets = {}
    self.zone = 0
    self.subzone = 0
    self.x = 0
    self.y = 0
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ZONE_CHANGED, function(...) self:OnZoneChange(...) end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED, function() self:OnPlayerActivated() end)
    EVENT_MANAGER:RegisterForUpdate(self.name, LCQ_UPDATE_INTERVAL, function() self:Update() end)
    EVENT_MANAGER:RegisterForUpdate(self.name .. "Pos", 0, function() self:OnPositionUpdate() end)

    LCQ_DBG:Verbose("Listener: Map coordinate listener initalized")
end

-- Update function that checks if the player is in range of any active objective
function LCQMapCoordinateListener:Update()
    for _, target in pairs(self.targets) do
        if target.zone == self.zone then
            if target.subzone == self.subzone then
                -- Get the player distance to the target position
                local dx = target.x - self.x
                local dy = target.y - self.y
                local dist = math.sqrt(dx*dx + dy*dy)

                -- If player is close enough
                if dist <= target.r then
                    self:FireCallbacks("OnConditionMet", target)
                end
            end
        end
    end
end

-- First initialization of the zone id
function LCQMapCoordinateListener:OnPlayerActivated()
    self.zone = GetZoneId(GetUnitZoneIndex("player"))
    -- There is no way to get the current subzone id that I can find, except getting the map name qhich would require a lookup table for every map name
    -- The only way to obtain the subzone id is from the EVENT_ZONE_CHANGED event, which doesn't get triggered on load :(
end

-- Updates the internal x and y coordinate values.
-- TODO: Maybe implement height check as well?
function LCQMapCoordinateListener:OnPositionUpdate()
    self.x, self.y = GetMapPlayerPosition("player")
end

function LCQMapCoordinateListener:OnZoneChange(eventCode, zoneName, subZoneName, newSubzone, zoneId, subZoneId)
    -- If entering a subzone, zoneid is 0, so we keep the existing one
    self.zone = (zoneId > 0) and zoneId or self.zone
    self.subzone = subZoneId
end