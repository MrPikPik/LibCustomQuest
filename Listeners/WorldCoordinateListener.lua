-----------------------------------------
-- World Coordinate Listener
-----------------------------------------

LCQWorldCoordinateListener = LCQListener:Subclass()

function LCQWorldCoordinateListener:New(...)
    local listener = LCQListener.New(self, ...)
    listener:Initialize(...)
    return listener
end

function LCQWorldCoordinateListener:Initialize()
    self.name = "WorldCoordinateListener"
    self.targets = {}
    self.zone = 0
    self.subzone = 0
    self.x = 0 -- Forward axis
    self.y = 0 -- Right axis
    self.z = 0 -- Up/Height axis

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ZONE_CHANGED, function(...) self:OnZoneChange(...) end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED, function() self:OnPlayerActivated() end)
    EVENT_MANAGER:RegisterForUpdate(self.name, LCQ_UPDATE_INTERVAL, function() self:Update() end)
    EVENT_MANAGER:RegisterForUpdate(self.name .. "Pos", 0, function() self:OnPositionUpdate() end)

    LCQ_DBG:Verbose("Listener: World coordinate listener initalized")
end

-- Update function that checks if the player is in range of any active objective
function LCQWorldCoordinateListener:Update()
    for _, target in pairs(self.targets) do
        if target.zone == self.zone then
            -- if target.subzone == self.subzone then (do we still need this?)
                -- Get the player distance to the target position
                local distCM = zo_floor(zo_distance3D(target.x, target.y, target.z, self.x, self.y, self.z))
                local distM = zo_floor(distCM / 100)

                -- If player is close enough
                if distM <= target.r then
                    if target.type == CUSTOM_INTERACTION_START_QUEST then
                        CUSTOM_QUEST_MANAGER:StartQuest(target.quest, target.questId)
                        self:Remove(target)
                    else
                        self:FireCallbacks("OnConditionMet", target)
                    end
                end
            --end
        end
    end
end

-- Function other listeners can use to determine if their target a) have location data and if so b) are within the set radius
function LCQWorldCoordinateListener:IsTargetInRadius(target)
    local worldCoordinateListener = self

    if target.zone == worldCoordinateListener.zone then
        -- if target.subzone == self.subzone then (do we still need this?)
            -- Get the player distance to the target position
            local distCM = zo_floor(zo_distance3D(target.x, target.y, target.z, self.x, self.y, self.z))
            local distM = zo_floor(distCM / 100)

            -- If player is close enough
            if distM <= target.r then
                return true
            end
        --end
    end
end

-- First initialization of the zone id
function LCQWorldCoordinateListener:OnPlayerActivated()
    self.zone = GetZoneId(GetUnitZoneIndex("player"))
    -- There is no way to get the current subzone id that I can find, except getting the map name which would require a lookup table for every map name
    -- The only way to obtain the subzone id is from the EVENT_ZONE_CHANGED event, which doesn't get triggered on load :(
end

-- Updates the internal x, y, and z coordinate values.
function LCQWorldCoordinateListener:OnPositionUpdate()
    _, self.x, self.y, self.z = GetUnitWorldPosition("player")
end

function LCQWorldCoordinateListener:OnZoneChange(eventCode, zoneName, subZoneName, newSubzone, zoneId, subZoneId)
    -- If entering a subzone, zoneid is 0, so we keep the existing one
    self.zone = (zoneId > 0) and zoneId or self.zone
    self.subzone = subZoneId
end