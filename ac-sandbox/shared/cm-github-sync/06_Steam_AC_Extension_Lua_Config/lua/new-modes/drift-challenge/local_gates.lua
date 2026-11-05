-- local_gates.lua

local LocalGates = {}
local Settings = require('settings')


local Gate = {}
Gate.__index = Gate

function Gate.new(data)
    local self = setmetatable({}, Gate)
    self.position = data.position
    self.rotation = data.rotation
    self.size = data.size
    self.type = data.type
    self.score_multiplier = data.score_multiplier or 1  
    return self
end


local function createGate(data)
    return Gate.new(data)
end

local currentTrack = nil
local trackData = nil

function LocalGates.setCurrentTrack(track)
    currentTrack = track
    local success, result = pcall(require, 'tracks.' .. track)
    if success then
        trackData = result
        return true
    else
        trackData = nil
        return false
    end
end

function LocalGates.getGates()
    return trackData and trackData.gates or {}
end

function LocalGates.getNoGoZones()
    return trackData and trackData.noGoZones or {}
end

function LocalGates.getTrajectoryGates()
    return trackData and trackData.trajectoryGates or {}
end


function LocalGates.getTrackData()
    return trackData
end

function LocalGates.isCarInGate(car, gate)
    if gate.type == "normal" then
        
        local rearWheelsInside = 0

        
        if isPointInRotatedRectangle(car.wheels[2].position, gate) then
            rearWheelsInside = rearWheelsInside + 1
        end
        
        
        if isPointInRotatedRectangle(car.wheels[3].position, gate) then
            rearWheelsInside = rearWheelsInside + 1
        end

        local percentage = (rearWheelsInside / 2) * 100  

        
        if rearWheelsInside >= 1 then
            return true, percentage
        else
            return false, percentage
        end
    elseif gate.type == "entryspeedline" then
        -- start/finish gate logic
        local halfCarWidth = car.aabbSize.x / 2
        local halfCarLength = car.aabbSize.z / 2
        local halfGateWidth = gate.size.width / 2
        local halfGateLength = gate.size.length / 2
        local angleRad = math.rad(gate.rotation + (Settings.gateOrientationOffset or 0))
        local cosAngle = math.cos(angleRad)
        local sinAngle = math.sin(angleRad)

        local gateCorners = {
            vec2(-halfGateWidth, -halfGateLength),
            vec2(halfGateWidth, -halfGateLength),
            vec2(halfGateWidth, halfGateLength),
            vec2(-halfGateWidth, halfGateLength)
        }

        for i, corner in ipairs(gateCorners) do
            local rotatedX = corner.x * cosAngle - corner.y * sinAngle
            local rotatedY = corner.x * sinAngle + corner.y * cosAngle
            gateCorners[i] = vec2(rotatedX + gate.position.x, rotatedY + gate.position.z)
        end

        -- position check
        local positions = {
            car.position,
            car.position - car.velocity * ac.getGameDeltaT()  -- last position
        }

        for _, pos in ipairs(positions) do
            local carCorners = {
                vec2(-halfCarWidth, -halfCarLength),
                vec2(halfCarWidth, -halfCarLength),
                vec2(halfCarWidth, halfCarLength),
                vec2(-halfCarWidth, halfCarLength)
            }

            for i, corner in ipairs(carCorners) do
                local worldPos = pos 
                    + car.look * corner.y 
                    + car.side * corner.x
                carCorners[i] = vec2(worldPos.x, worldPos.z)
            end

            if doPolygonsIntersect(carCorners, gateCorners) then
                ac.debug(string.format("Entry speed line detected at speed: %.1f km/h", car.speedKmh))
                return true, 100
            end
        end

        -- checking line intersection
        local prevPos = car.position - car.velocity * ac.getGameDeltaT()
        local movement = {
            vec2(prevPos.x, prevPos.z),
            vec2(car.position.x, car.position.z)
        }

        for i = 1, #gateCorners do
            local j = i % #gateCorners + 1
            local gateLine = {gateCorners[i], gateCorners[j]}
            
            if doLinesIntersect(movement[1], movement[2], gateLine[1], gateLine[2]) then
                ac.debug(string.format("Entry speed line intersection detected at speed: %.1f km/h", car.speedKmh))
                return true, 100
            end
        end

        return false, 0
    elseif gate.type == "OZ" then
        
        for i = 0, 3 do
            if isPointInRotatedRectangle(car.wheels[i].position, gate) then
                
                return true, 100
            end
        end
        return false, 0
    else
        
        local halfCarWidth = car.aabbSize.x / 2
        local halfCarLength = car.aabbSize.z / 2
        local halfGateWidth = gate.size.width / 2
        local halfGateLength = gate.size.length / 2
        local angleRad = math.rad(gate.rotation + (Settings.gateOrientationOffset or 0))
        local cosAngle = math.cos(angleRad)
        local sinAngle = math.sin(angleRad)

        local gateCorners = {
            vec2(-halfGateWidth, -halfGateLength),
            vec2(halfGateWidth, -halfGateLength),
            vec2(halfGateWidth, halfGateLength),
            vec2(-halfGateWidth, halfGateLength)
        }

        for i, corner in ipairs(gateCorners) do
            local rotatedX = corner.x * cosAngle - corner.y * sinAngle
            local rotatedY = corner.x * sinAngle + corner.y * cosAngle
            gateCorners[i] = vec2(rotatedX + gate.position.x, rotatedY + gate.position.z)
        end

        local carCorners = {
            vec2(-halfCarWidth, -halfCarLength),
            vec2(halfCarWidth, -halfCarLength),
            vec2(halfCarWidth, halfCarLength),
            vec2(-halfCarWidth, halfCarLength)
        }

        for i, corner in ipairs(carCorners) do
            local worldPos = car.position 
                + car.look * corner.y 
                + car.side * corner.x
            carCorners[i] = vec2(worldPos.x, worldPos.z)
        end

        if doPolygonsIntersect(carCorners, gateCorners) then
            local carCenter = vec2(car.position.x, car.position.z)
            local gateCenter = vec2(gate.position.x, gate.position.z)
            local gateDirection = vec2(math.cos(angleRad), math.sin(angleRad))
            local carToGateVector = carCenter - gateCenter
            local projectionLength = carToGateVector:dot(gateDirection)
            local percentage = ((projectionLength + halfGateLength) / (2 * halfGateLength)) * 100
            percentage = math.min(math.max(percentage, 0), 100)
            return true, percentage
        end

        return false, 0
    end
end

function isPointInRotatedRectangle(point, rectangle)
    
    local point2D = vec2(point.x, point.z)
    
    
    local rectCenter = vec2(rectangle.position.x, rectangle.position.z)
    local rectSize = rectangle.size
    local halfWidth = rectSize.width / 2
    local halfLength = rectSize.length / 2
    local angleRad = math.rad(rectangle.rotation + (Settings.gateOrientationOffset or 0))

    
    local cosAngle = math.cos(-angleRad)  
    local sinAngle = math.sin(-angleRad)
    local translatedX = point2D.x - rectCenter.x
    local translatedY = point2D.y - rectCenter.y

    local localX = translatedX * cosAngle - translatedY * sinAngle
    local localY = translatedX * sinAngle + translatedY * cosAngle

    
    if localX >= -halfWidth and localX <= halfWidth and localY >= -halfLength and localY <= halfLength then
        return true
    else
        return false
    end
end

function doPolygonsIntersect(poly1, poly2)
    for i = 1, #poly1 do
        if isPointInsidePolygon(poly1[i], poly2) then
            return true
        end
    end
    for i = 1, #poly2 do
        if isPointInsidePolygon(poly2[i], poly1) then
            return true
        end
    end
    return false
end

function isPointInsidePolygon(point, polygon)
    local inside = false
    local j = #polygon
    for i = 1, #polygon do
        if (polygon[i].y > point.y) ~= (polygon[j].y > point.y) and
           point.x < (polygon[j].x - polygon[i].x) * (point.y - polygon[i].y) / (polygon[j].y - polygon[i].y) + polygon[i].x then
            inside = not inside
        end
        j = i
    end
    return inside
end

function LocalGates.isCarInAnyGate(car)
    if not currentTrack then return 0, nil, 0 end

    local gates = LocalGates.getGates()
    for i, gate in ipairs(gates) do
        local isInGate, percentage = LocalGates.isCarInGate(car, gate)
        if isInGate then
            local gateType = gate.type
            return i, gateType, percentage
        end
    end

    local noGoZones = LocalGates.getNoGoZones()
    for i, zone in ipairs(noGoZones) do
        local isInGate, _ = LocalGates.isCarInGate(car, zone)
        if isInGate then
            return -i, "no_go_zone", 0
        end
    end

    local trajectoryGates = LocalGates.getTrajectoryGates()
    for i, gate in ipairs(trajectoryGates) do
        local isInGate, percentage = LocalGates.isCarInGate(car, gate)
        if isInGate then
            return -i, "trajectorygate", percentage
        end
    end

    
    local td = LocalGates.getTrackData()
    if td and td.entrySpeedLine then
        local esl = td.entrySpeedLine
        
        local lineGate = {
            type = "entryspeedline",
            position = esl.position,
            rotation = esl.rotation + 90,  
            size = {
                width = 0.1,  
                length = esl.length
            }
        }
        local isInGate, percentage = LocalGates.isCarInGate(car, lineGate)
        if isInGate then
            ac.debug("Car is in entry speed line gate, percentage:", percentage)
            return -999, "entryspeedline", percentage
        end
    end

    return 0, nil, 0
end



function LocalGates.isTrackSupported()
    return currentTrack ~= nil and trackData ~= nil
end

-- Добавьте эту функцию для проверки пересечения линий
function doLinesIntersect(p1, p2, p3, p4)
    local function ccw(A, B, C)
        return (C.y - A.y) * (B.x - A.x) > (B.y - A.y) * (C.x - A.x)
    end
    
    return ccw(p1, p3, p4) ~= ccw(p2, p3, p4) and ccw(p1, p2, p3) ~= ccw(p1, p2, p4)
end

return LocalGates