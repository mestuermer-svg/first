-- debug_display.lua

local DebugDisplay = {}
local LocalGates = require('local_gates')
local LocalScoring = require('local_scoring')
local Settings = require('settings')

local debugInfo = {
    fps = 0,
    memoryUsage = 0,
    carPosition = vec3(),
    carOrientation = vec3(),
    carSpeedKmh = 0,
    carWidth = 0,
    carLength = 0,
    carGear = 0,
    carRPM = 0,
    carThrottle = 0,
    carBrake = 0,
    carClutch = 0,
    carFuel = 0,
    carDamage = {0, 0, 0, 0, 0},
    trackSupported = false,
    gatesFound = false,
    averageDriftAngle = 0,
    carCorners = {},
    isLapValid = false,
    maxDamage = 0,
    currentDriftAngle = 0,
}

local isDriftFailed = false
local damageFailureThreshold = 20

local maxDamage = 0

function DebugDisplay.update(dt)
    debugInfo.fps = 1 / dt
    debugInfo.memoryUsage = collectgarbage("count")
    
    local car = ac.getCar(0)
    if car then
        debugInfo.carPosition = car.position
        debugInfo.carOrientation = car.look
        debugInfo.carSpeedKmh = car.speedKmh
        debugInfo.carGear = car.gear
        debugInfo.carRPM = car.rpm
        debugInfo.carThrottle = car.gas
        debugInfo.carBrake = car.brake
        debugInfo.carClutch = car.clutch
        debugInfo.carFuel = car.fuel
        
        local damageData = car.damage
        debugInfo.carDamage = {damageData[0], damageData[1], damageData[2], damageData[3], damageData[4]}
        
        local overallDamage = 0
        for i = 1, 4 do
            overallDamage = overallDamage + debugInfo.carDamage[i]
        end

        maxDamage = math.max(maxDamage, overallDamage)
        debugInfo.maxDamage = maxDamage

        if overallDamage > damageFailureThreshold and not isDriftFailed then
            isDriftFailed = true
            LocalScoring.failDriftDueToDamage(overallDamage)
        end

        if overallDamage <= damageFailureThreshold then
            isDriftFailed = false
        end

        if car.aabbSize then
            debugInfo.carWidth = car.aabbSize.x
            debugInfo.carLength = car.aabbSize.z
        end

        
        local halfCarWidth = debugInfo.carWidth / 2
        local halfCarLength = debugInfo.carLength / 2
        local carAngle = math.atan2(car.look.z, car.look.x)
        
        local carCorners = {
            vec2(-halfCarWidth, -halfCarLength),
            vec2(halfCarWidth, -halfCarLength),
            vec2(halfCarWidth, halfCarLength),
            vec2(-halfCarWidth, halfCarLength)
        }

        for i, corner in ipairs(carCorners) do
            local rotatedX = corner.x * math.cos(carAngle) - corner.y * math.sin(carAngle)
            local rotatedY = corner.x * math.sin(carAngle) + corner.y * math.cos(carAngle)
            debugInfo.carCorners[i] = vec3(
                rotatedX + car.position.x,
                car.position.y,
                rotatedY + car.position.z
            )
        end
    end

    debugInfo.trackSupported = LocalGates.isTrackSupported()
    debugInfo.gatesFound = debugInfo.trackSupported and #LocalGates.getGates() > 0
    
    
    ac.debug("Current track:", ac.getTrackID())
    ac.debug("Track supported:", debugInfo.trackSupported)
    ac.debug("Gates found:", debugInfo.gatesFound)
    ac.debug("Number of gates:", #LocalGates.getGates())

    debugInfo.isLapValid = LocalScoring.isLapValid()
    
    
    debugInfo.averageDriftAngle = LocalScoring.getAverageDriftAngle()

    if car and car.speedKmh and car.speedKmh > Settings.lowSpeedThreshold then
        local velocity_x = car.velocity.x
        local velocity_z = car.velocity.z
        local velocity_direction = math.atan2(velocity_z, velocity_x)

        local car_heading = math.atan2(car.look.z, car.look.x)

        local drift_angle_rad = velocity_direction - car_heading

        if drift_angle_rad > math.pi then
            drift_angle_rad = drift_angle_rad - 2 * math.pi
        elseif drift_angle_rad < -math.pi then
            drift_angle_rad = drift_angle_rad + 2 * math.pi
        end

        debugInfo.currentDriftAngle = math.abs(math.deg(drift_angle_rad))
    else
        debugInfo.currentDriftAngle = 0
    end
end

function DebugDisplay.draw()
    ui.beginTransparentWindow('debugWindow', vec2(40, ui.windowHeight() - 1000), vec2(500, 1590))
    ui.beginOutline()
    ui.pushDWriteFont('Orange juice 2.0:\\Fonts;Weight=Medium')

    local color = rgbm(1, 1, 1, 1)
    local yPos = 0
    local lineHeight = 25
    local labelWidth = 300

    local function drawLine(text, value, valueColor)
        ui.dwriteDrawText(text, 18, vec2(0, yPos), color)
        ui.dwriteDrawText(tostring(value), 18, vec2(labelWidth, yPos), valueColor or color)
        yPos = yPos + lineHeight
    end

    drawLine("FPS:", string.format("%.1f", debugInfo.fps))
    drawLine("Memory usage:", string.format("%.2f KB", debugInfo.memoryUsage))
    drawLine("Car position:", string.format("%.2f, %.2f, %.2f", debugInfo.carPosition.x, debugInfo.carPosition.y, debugInfo.carPosition.z))
    drawLine("Car orientation:", string.format("%.2f, %.2f, %.2f", debugInfo.carOrientation.x, debugInfo.carOrientation.y, debugInfo.carOrientation.z))
    drawLine("Car speed:", string.format("%.2f km/h", debugInfo.carSpeedKmh))
    drawLine("Car width:", string.format("%.2f m", debugInfo.carWidth))
    drawLine("Car length:", string.format("%.2f m", debugInfo.carLength))
    drawLine("Gear:", tostring(debugInfo.carGear))
    drawLine("Engine RPM:", string.format("%.0f rpm", debugInfo.carRPM))
    drawLine("Throttle:", string.format("%.2f%%", debugInfo.carThrottle * 100))
    drawLine("Brake:", string.format("%.2f%%", debugInfo.carBrake * 100))
    drawLine("Clutch:", string.format("%.2f%%", debugInfo.carClutch * 100))
    drawLine("Fuel:", string.format("%.2f L", debugInfo.carFuel))  

    local trackSupportColor = debugInfo.trackSupported and rgbm(0, 1, 0, 1) or rgbm(1, 0, 0, 1)
    drawLine("Track supported:", debugInfo.trackSupported and "Yes" or "No", trackSupportColor)

    local gatesFoundColor = debugInfo.gatesFound and rgbm(0, 1, 0, 1) or rgbm(1, 0, 0, 1)
    drawLine("Gates found on track:", debugInfo.gatesFound and "Yes" or "No", gatesFoundColor)

    drawLine("Average drift angle:", string.format("%.2f°", debugInfo.averageDriftAngle))
    drawLine("Current drift angle:", string.format("%.2f°", debugInfo.currentDriftAngle))

    
    for i, corner in ipairs(debugInfo.carCorners) do
        drawLine(string.format("Car corner %d:", i), string.format("%.2f, %.2f, %.2f", corner.x, corner.y, corner.z))
    end

    
    drawLine("Damage Info:", "")
    local zoneNames = {"Front", "Rear", "Left", "Right"}
    local overallDamage = 0
    for i = 1, 4 do
        local damageValue = debugInfo.carDamage[i]
        overallDamage = overallDamage + damageValue
        drawLine(string.format("%s:", zoneNames[i]), string.format("%.2f", damageValue))
    end

    
    drawLine("Overall Damage:", string.format("%.2f", overallDamage))

    
    drawLine("Max Damage:", string.format("%.2f", debugInfo.maxDamage))

    
    local driftStatusColor = isDriftFailed and rgbm(1, 0, 0, 1) or rgbm(0, 1, 0, 1)
    local driftStatusText = isDriftFailed and "Failed" or "Active"
    if isDriftFailed then
        if not debugInfo.isLapValid then
            driftStatusText = "Failed due to invalid lap"
        elseif overallDamage > damageFailureThreshold then
            driftStatusText = "Failed due to damage"
        end
    end
    drawLine("Drift Status:", driftStatusText, driftStatusColor)

    
    local lapValidColor = debugInfo.isLapValid and rgbm(0, 1, 0, 1) or rgbm(1, 0, 0, 1)
    drawLine("Lap Valid:", debugInfo.isLapValid and "Yes" or "No", lapValidColor)

    ui.popDWriteFont()
    ui.endOutline(0, 1.5)
    ui.endTransparentWindow()
end

local function display_detailed_score(judges_scores)
    local detailed_info = "Detailed score information:\n\n"
    
    for judge_name, score_info in pairs(judges_scores) do
        detailed_info = detailed_info .. judge_name .. ":\n"
        detailed_info = detailed_info .. "  Base score: " .. string.format("%.2f", score_info.base_score) .. "\n"
        detailed_info = detailed_info .. "  Gates passed: " .. score_info.gates_passed .. "/" .. #LocalGates.getGates() .. "\n"
        detailed_info = detailed_info .. "  No Go Zone penalty: " .. string.format("%.2f", score_info.no_go_penalty) .. "\n"
        detailed_info = detailed_info .. "  Angle bonus: " .. string.format("%.2f", score_info.angle_bonus) .. "\n"
        detailed_info = detailed_info .. "  Speed bonus: " .. string.format("%.2f", score_info.speed_bonus) .. "\n"
        detailed_info = detailed_info .. "  Final score: " .. string.format("%.2f", score_info.final_score) .. "\n\n"
    end
    
    return detailed_info
end

function display_score(score, judges_scores)
    local detailed_info = display_detailed_score(judges_scores)
   
    print("Detailed Info: ", detailed_info)
  
    display_text(detailed_info, x, y + 100, font_size, color)
end


function display_text(text, x, y, font_size, color)
    love.graphics.setColor(color)
    love.graphics.setFont(love.graphics.newFont(font_size))
    love.graphics.print(text, x, y)
end

return DebugDisplay
