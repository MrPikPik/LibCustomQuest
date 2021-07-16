-----------------------------------------
-- Quest Marker Manager
-----------------------------------------

LCQ_QuestMarkerManager = ZO_Object:Subclass()

local QUEST_MARKER_TEXTURES = {
    QUEST_MARKER_QUEST_GIVER        = "/esoui/art/floatingmarkers/quest_available_icon.dds",
    QUEST_MARKER_TRACKED            = "/esoui/art/floatingmarkers/quest_icon_assisted.dds",
    QUEST_MARKER_UNTRACKED          = "/esoui/art/floatingmarkers/quest_icon.dds",
    QUEST_MARKER_REPEATABLE         = "/esoui/art/floatingmarkers/repeatablequest_available_icon.dds",
    QUEST_MARKER_INSIDE_TRACKED     = "/esoui/art/floatingmarkers/quest_icon_door_assisted.dds",
    QUEST_MARKER_INSIDE_UNTRACKED   = "/esoui/art/floatingmarkers/quest_icon_door.dds",
}

local LCQ_COMPASS_PINS_QUEST_GIVER = "LCQ_PinType_QuestGiver"
local LCQ_COMPASS_PINS_QUEST_MARKER = "LCQ_PinType_QuestMarker"
local LCQ_COMPASS_PINS_QUEST_INSIDE = "LCQ_PinType_QuestInside"
local LCQ_COMPASS_PINS_QUEST_REPEATABLE = "LCQ_PinType_QuestRepeatable"

local function UpdatePinCenterLabel(pin, normalizedAngle, distance)
    --d("UpdatePinCenterLabel")
    if pin.pinName then
        if zo_abs(normalizedAngle) < 0.1 then
            if COMPASS.areaOverrideAnimation:IsPlaying() then
                COMPASS.centerOverPinLabelAnimation:PlayBackward()
            elseif not COMPASS.centerOverPinLabelAnimation:IsPlaying() or not COMPASS.centerOverPinLabelAnimation:IsPlayingBackward() then
                COMPASS.centerOverPinLabel:SetText(pin.pinName)
                COMPASS.centerOverPinLabelAnimation:PlayForward()
            end
        end
    end
end

local pinLayouts = {
    questGiver = {
        maxDistance = 0.025,
        maxAngle = 5,
        texture = "/esoui/art/compass/quest_available_icon.dds",
        sizeCallback = function(pin, angle, normalizedAngle, distance)
            local scale = 64
            normalizedAngle = zo_abs(normalizedAngle)
            if normalizedAngle >= 0.95 then
                scale = zo_lerp(64, 48, zo_clampedPercentBetween(0, 0.05, normalizedAngle - 0.95))
            end
            pin:SetDimensions(scale, scale)     
        end,
        additionalLayout = {
            [1] = function(pin, angle, normalizedAngle, distance)
                pin:SetAlpha(1)
                UpdatePinCenterLabel(pin, normalizedAngle, distance)
            end,
            [2] = function(pin)
                pin:SetHidden(true)
            end,
        }
    },
    questObjective = {
        maxDistance = 1,
        texture = "/esoui/art/compass/quest_icon_assisted.dds",
    },
    questObjectiveArea = {
        maxDistance = 1,
        texture = "/esoui/art/compass/quest_assistedareapin.dds",
    },
}

function LCQ_QuestMarkerManager:New(...)
    local manager = ZO_Object.New(self)
    manager:Initialize(...)
    return manager
end

function LCQ_QuestMarkerManager:Initialize()
    self.markers = {}

    local function markerFarctory(pool, id)
        LCQ_DBG:Info("QuestMarkerFactory: Creating new marker with id <<1>>", id)
        d(zo_strformat("QuestMarkerFactory: Creating new marker with id <<1>>", id))
        local control = WINDOW_MANAGER:CreateControl("LCQ_QuestMarker" .. id, self.window, CT_TEXTURE)
        return control
    end

    self.markerPool = ZO_ObjectPool:New(markerFarctory)
    self.markerId = 1

    self:CreateUI()

    self:SetupCompassPins()

    EVENT_MANAGER:RegisterForUpdate("LCQ_QuestMarkerManager", 0, function() self:OnUpdate() end)

    LCQ_DBG:Info("Quest Marker Manager Initialized.")
end

function LCQ_QuestMarkerManager:CreateUI()
    -- Create render space control
    self.control = WINDOW_MANAGER:CreateControl("LCQ_QuestMarkerControl", GuiRoot, CT_CONTROL)
    self.control:Create3DRenderSpace()

    -- Create parent window for icons
	self.window = WINDOW_MANAGER:CreateTopLevelWindow("LCQ_QuestMarkerWindow")
	self.window:ClearAnchors()
	self.window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    self.window:SetDimensions(GuiRoot:GetWidth(), GuiRoot:GetHeight())
	self.window:SetDrawLayer(0)
	self.window:SetDrawLevel(0)
	self.window:SetDrawTier(0)
end

function LCQ_QuestMarkerManager:SetupCompassPins()
    -- Only the first type need the update function as it handles all pintypes.
    COMPASS_PINS:AddCustomPin(LCQ_COMPASS_PINS_QUEST_GIVER, function() self:UpdateCompassPins() end, pinLayouts.questGiver)
    COMPASS_PINS:AddCustomPin(LCQ_COMPASS_PINS_QUEST_MARKER, function() end, pinLayouts.questObjective)
end


function LCQ_QuestMarkerManager:UpdateCompassPins()
    --Add all pins
    local currentZone = GetUnitWorldPosition("player")
    for i, marker in ipairs(self.markers) do
        if marker.zone == currentZone then
            local x, y = GetNormalizedWorldPosition(marker.zone, marker.x, marker.y, marker.z)
            
            if marker.type == "QUEST_MARKER_QUEST_GIVER" then
                COMPASS_PINS.pinManager:CreatePin(LCQ_COMPASS_PINS_QUEST_GIVER, "TestPin", x, y, "Testpin")
            elseif marker.type == "QUEST_MARKER_TRACKED" then
                COMPASS_PINS.pinManager:CreatePin(LCQ_COMPASS_PINS_QUEST_MARKER, "TestPin", x, y, "Testpin")
            end
        end
    end
end

function LCQ_QuestMarkerManager:AddQuestMarker(type, text, zone, worldX, worldY, worldZ)
    local marker = {
        type = type or "QUEST_MARKER_TRACKED",
        text = text,
        texture = QUEST_MARKER_TEXTURES[type] or QUEST_MARKER_TEXTURES["QUEST_MARKER_TRACKED"],
        zone = zone or 0,
        x = worldX or 0,
        y = worldY or 0,
        z = worldZ or 0,
        id = self.markerId,
    }
    self.markerId = self.markerId + 1
    table.insert(self.markers, marker)
    self:UpdateCompassPins()


    -- GetNormalizedWorldPosition(integer zoneId, integer worldX, integer worldY, integer worldZ)
    -- Returns: number normalizedX, number normalizedY
    -- 
    -- GetRawNormalizedWorldPosition(integer zoneId, integer worldX, integer worldY, integer worldZ)
    -- Returns: number normalizedX, number normalizedY

end

function LCQ_QuestMarkerManager:RemoveQuestMarker(questMarker)
    for i, marker in ipairs(self.markers) do
        if marker.id == questMarker.id then
            -- Remove from compass
            COMPASS_PINS.pinManager:RemovePin(marker.id)

            --Remove from map
            -- TODO

            --Remove from world
            table.remove(self.markers, i)
        end
    end
end

-- Position to screen math taken with permission from Ody's Support Icons
function LCQ_QuestMarkerManager:OnUpdate()
    local currentZone = GetUnitRawWorldPosition("player")

    -- Prepare render space
    Set3DRenderSpaceToCurrentCamera(self.control:GetName())
    -- Retrieve camera world position and orientation vectors
    local cX, cY, cZ = GuiRender3DPositionToWorldPosition(self.control:Get3DRenderSpaceOrigin())
    local fX, fY, fZ = self.control:Get3DRenderSpaceForward()
    local rX, rY, rZ = self.control:Get3DRenderSpaceRight()
    local uX, uY, uZ = self.control:Get3DRenderSpaceUp()

    -- https://semath.info/src/inverse-cofactor-ex4.html
    -- calculate determinant for camera matrix
    -- local det = rX * uY * fZ - rX * uZ * fY - rY * uX * fZ + rZ * uX * fY + rY * uZ * fX - rZ * uY * fX
    -- local mul = 1 / det
    -- determinant should always be -1
    -- instead of multiplying simply negate
    -- calculate inverse camera matrix
    local i11 = -(uY * fZ - uZ * fY)
    local i12 = -(rZ * fY - rY * fZ)
    local i13 = -(rY * uZ - rZ * uY)
    local i21 = -(uZ * fX - uX * fZ)
    local i22 = -(rX * fZ - rZ * fX)
    local i23 = -(rZ * uX - rX * uZ)
    local i31 = -(uX * fY - uY * fX)
    local i32 = -(rY * fX - rX * fY)
    local i33 = -(rX * uY - rY * uX)
    local i41 = -(uZ * fY * cX + uY * fX * cZ + uX * fZ * cY - uX * fY * cZ - uY * fZ * cX - uZ * fX * cY)
    local i42 = -(rX * fY * cZ + rY * fZ * cX + rZ * fX * cY - rZ * fY * cX - rY * fX * cZ - rX * fZ * cY)
    local i43 = -(rZ * uY * cX + rY * uX * cZ + rX * uZ * cY - rX * uY * cZ - rY * uZ * cX - rZ * uX * cY)

    -- Screen dimensions
    local uiW, uiH = GuiRoot:GetDimensions()

    -- Drawing order
    local ztotal = 0
    local zorder = {}

    -- Marker updates
    local markerNum = 1
    for i, marker in ipairs(self.markers) do
        if marker.zone == currentZone then
            local wX, wY, wZ = marker.x, marker.y, marker.z

            -- Move the quest marker up based how far the player is away from it
            -- This makes the quest markers not overlap objects underneath them like NPCs when they get bigger in scale due to distance
            local offsetY = 100 * zo_clampedPercentBetween(0, 5000, GetDistanceToPoint(marker.x, marker.y, marker.z))
            wY = wY + offsetY

            -- Calculate marker view position
            local pX = wX * i11 + wY * i21 + wZ * i31 + i41
            local pY = wX * i12 + wY * i22 + wZ * i32 + i42
            local pZ = wX * i13 + wY * i23 + wZ * i33 + i43

            -- If marker is in front
            if pZ > 0 then
                -- Calculate unit screen position
                local w, h = GetWorldDimensionsOfViewFrustumAtDepth(pZ)
                local x, y = pX * uiW / w, -pY * uiH / h
                -- Update icon position

                local icon = self.markerPool:AcquireObject(markerNum)
                markerNum = markerNum + 1
                icon:ClearAnchors()
                icon:SetAnchor(CENTER, self.window, CENTER, x, y)

                -- Update icon size
                local scale = zo_lerp(40, 30, zo_clampedPercentBetween(1000, 5000, GetDistanceToPoint(marker.x, marker.y, marker.z)))
                icon:SetDimensions(scale, scale)

                -- Opacity
                local alpha = 1 - zo_clampedPercentBetween(2500, 5000, GetDistanceToPoint(marker.x, marker.y, marker.z))
                icon:SetAlpha(alpha*alpha) -- Quadratic falloff

                -- Icon Texture
                icon:SetTexture(marker.texture)

                -- Show icon
                icon:SetHidden(false)

                -- handle draw order
                -- FIXME: in theory, 2 icons could have the same floored pZ
                -- FIXME: zorder buffer should either store icons in tables or
                -- FIXME: decrease chance for same depth by multiplying pZ before
                -- FIXME: flooring for additional precision
                zorder[1 + zo_floor(pZ*100)] = icon
                ztotal = ztotal + 1
            end
        end
    end

    if ztotal > 0 then
        local keys = {}
        for k in pairs(zorder) do
            table.insert(keys, k)
        end
        table.sort(keys)
        -- adjust draw order
        for _, k in ipairs( keys ) do
            zorder[k]:SetDrawLevel(ztotal)
            ztotal = ztotal - 1
        end
    end
end