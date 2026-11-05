-- mode.lua
ac.store('.mode.driftchallenge.anythinggoeshere', 1)
local DebugDisplay = require('debug_display')
local LocalRenderGates = require('local_render_gates')
local LocalGates = require('local_gates')
local LocalScoring = require('local_scoring')
local Settings = require('settings')
local Judging = require('judging')
local DriftHUD = require('drift_hud')
local LogoDisplay = require('logo_display')
local ArcadeScoring = require('arcade_scoring')
local startGatePassed = false
local unsupportedTrack = false
local maxNumberText = "999 m"  
local maxNumberWidth = nil  

LocalScoring.setDriftHUD(DriftHUD)
Judging.init(LocalScoring)
Judging.setScale(1.0)

local lastGatePassed = 0
local showStartImage = false
local showFinishImage = false
local imageTimer = 0

local isDriftMissionOpen = false
local keyGPressedLastFrame = false
local keyRPressedLastFrame = false
local keySPressedLastFrame = false

local startRaceAudios
local finishAudios
local zeroAudio
local goAudio

local function initializeAudioEvents()
    startRaceAudios = {
        ac.AudioEvent.fromFile({filename = 'audio/002.mp3', use3D = false, loop = false}, false),
        ac.AudioEvent.fromFile({filename = 'audio/003.mp3', use3D = false, loop = false}, false),
        ac.AudioEvent.fromFile({filename = 'audio/004.mp3', use3D = false, loop = false}, false),
        ac.AudioEvent.fromFile({filename = 'audio/005.mp3', use3D = false, loop = false}, false)
    }

    finishAudios = {
        ac.AudioEvent.fromFile({filename = 'audio/050.mp3', use3D = false, loop = false}, false),
        ac.AudioEvent.fromFile({filename = 'audio/5075.mp3', use3D = false, loop = false}, false),
        ac.AudioEvent.fromFile({filename = 'audio/7585.mp3', use3D = false, loop = false}, false),
        ac.AudioEvent.fromFile({filename = 'audio/8595.mp3', use3D = false, loop = false}, false),
        ac.AudioEvent.fromFile({filename = 'audio/95100.mp3', use3D = false, loop = false}, false)
    }

    for _, audio in ipairs(startRaceAudios) do
        audio.cameraExteriorMultiplier = 1
        audio.cameraInteriorMultiplier = 1
        audio.cameraTrackMultiplier = 1
    end

    for _, audio in ipairs(finishAudios) do
        audio.cameraExteriorMultiplier = 1
        audio.cameraInteriorMultiplier = 1
        audio.cameraTrackMultiplier = 1
    end

    zeroAudio = ac.AudioEvent.fromFile({filename = 'audio/zero.mp3', use3D = false, loop = false}, false)
    zeroAudio.cameraExteriorMultiplier = 1
    zeroAudio.cameraInteriorMultiplier = 1
    zeroAudio.cameraTrackMultiplier = 1

    goAudio = ac.AudioEvent.fromFile({filename = 'audio/go.mp3', use3D = false, loop = false}, false)
    goAudio.cameraExteriorMultiplier = 1
    goAudio.cameraInteriorMultiplier = 1
    goAudio.cameraTrackMultiplier = 1
end

local startRaceAudioPlayed = false
local zeroAudioPlayed = false

local function playRandomStartRaceAudio()
    if not startRaceAudioPlayed then
        local randomIndex = math.random(1, #startRaceAudios)
        startRaceAudios[randomIndex]:start()
        startRaceAudioPlayed = true
    end
end

local lastDriftAngleSign = 0
local transitionCount = 0
local isCountingTransitions = false

local function getMaxAllowedTransitions()
    local trackData = LocalGates.getTrackData(currentTrack)
    return trackData and trackData.maxAllowedTransitions or 3
end

local currentTrack = nil
local carPositionSet = false

local function setCarPosition(position, rotation)
    local car = ac.getCar(0)
    if car and car.physicsAvailable then
        rotation = rotation or 0
        local direction = vec3(math.cos(math.rad(rotation)), 0, math.sin(math.rad(rotation)))
        physics.setCarPosition(0, position, direction)
        carPositionSet = true
        ac.debug("Car position set to", position, "with rotation", rotation)
    else
        setTimeout(function() setCarPosition(position, rotation) end, 100)
    end
end

local isCameraAnimationPlaying = false
local totalCameraAnimationDuration = 7

local function startCameraAnimation()
    if Settings.trainingMode then
        return
    end

    isCameraAnimationPlaying = true
    physics.lockUserGearboxFor(totalCameraAnimationDuration, true)

    local camera = ac.grabCamera('Mode')
    if camera then
        camera.fov = 56
        playRandomStartRaceAudio()

        local shots = {
            {
                duration = 3,
                update = function(camera, car, t)
                    local startPos = car.position + car.look * 5 + vec3(0, 2, 0)
                    local endPos = car.position + car.look * 4 + vec3(0, 1, 0)
                    camera.transform.position = math.lerp(startPos, endPos, t / 3)
                    camera.transform.look = car.position + vec3(0, 1, 0) - camera.transform.position
                    camera.transform.up = vec3(0, 1, 0)
                end
            },
            {
                duration = 2.5,
                update = function(camera, car, t)
                    local startAngle = math.pi * 2.25
                    local endAngle = startAngle + math.pi * 0.5
                    local angle = math.lerp(startAngle, endAngle, t / 25)
                    local radius = math.lerp(6, 4, t / 5)
                    local height = math.lerp(1.5, 1.2, t / 5)
                    local offsetX = math.cos(angle) * radius
                    local offsetZ = math.sin(angle) * radius
                    camera.transform.position = car.position + vec3(offsetX, height, offsetZ)
                    camera.transform.look = car.position + vec3(0, 1, 0) - camera.transform.position
                    camera.transform.up = vec3(0, 1, 0)
                end
            },
            {
                duration = 2,
                update = function(camera, car, t)
                    camera.transform.position = car.position + vec3(0, 8 - t * 2, 0)
                    camera.transform.look = car.position - camera.transform.position
                    camera.transform.up = car.look
                end
            }
        }

        local currentShot = 1
        local shotTime = 0
        local totalTime = 0
        local totalDuration = 0
        for _, shot in ipairs(shots) do
            totalDuration = totalDuration + shot.duration
        end

        local cameraInterval = setInterval(function ()
            if Settings.CamerasAnimation == 0 then
                clearInterval(cameraInterval)
                camera:dispose()
                isCameraAnimationPlaying = false
                return
            end

            local car = ac.getCar(0) or error()
            local dt = ac.getGameDeltaT()
            shotTime = shotTime + dt
            totalTime = totalTime + dt
            local shot = shots[currentShot]
            if shot then
                shot.update(camera, car, shotTime, dt)
                camera.ownShare = 1
                camera.cameraRestoreThreshold = 0.25
                if shotTime >= shot.duration then
                    shotTime = 0
                    currentShot = currentShot + 1
                end
            else
                camera.ownShare = math.max(0, 1 - (totalTime - totalDuration) / 2)
                if camera.ownShare == 0 then
                    clearInterval(cameraInterval)
                    camera:dispose()
                    isCameraAnimationPlaying = false
                end
            end
        end, 0)
    end
end

local showGetToStartMessage = true
local currentGate = 0
local showEntrySpeed = false
local entrySpeedText = ""

local entrySpeed = 0
local entrySpeedTimer = 0
local maxSpeedReached = 0
local entrySpeedShown = false


local entrySpeedTriggeredByLine = false

local function resetTransitionCount()
    transitionCount = 0
    isCountingTransitions = false
    lastDriftAngleSign = 0
end

local function resetScript(skipCameraAnimation)
    if startRaceAudios then
        for _, audio in ipairs(startRaceAudios) do
            audio:stop()
            audio:dispose()
        end
    end
    if finishAudios then
        for _, audio in ipairs(finishAudios) do
            audio:stop()
            audio:dispose()
        end
    end
    if zeroAudio then 
        zeroAudio:stop()
        zeroAudio:dispose() 
    end
    if goAudio then 
        goAudio:stop()
        goAudio:dispose() 
    end

    initializeAudioEvents()

    LocalScoring.resetScore()
    DriftHUD.resetTrafficLight()
    LocalRenderGates.init()
    if Judging.reset then
        Judging.reset()
    end

    if not skipCameraAnimation and not unsupportedTrack then
        startCameraAnimation()
    end

    lastGatePassed = 0
    showStartImage = false
    showFinishImage = false
    imageTimer = 0
    startRaceAudioPlayed = false
    zeroAudioPlayed = false
    entrySpeed = 0
    entrySpeedTimer = 0
    maxSpeedReached = 0
    entrySpeedShown = false
    showEntrySpeed = false
    entrySpeedTriggeredByLine = false  
    resetTransitionCount()
    isDriftMissionOpen = false
    keyGPressedLastFrame = false
    keyRPressedLastFrame = false
    keySPressedLastFrame = false
    isCountingTransitions = false
    startGatePassed = false
    ac.debug("Script reset")
end

local function init()
    math.randomseed(os.time())

    currentTrack = ac.getTrackID()
    if LocalGates.setCurrentTrack(currentTrack) then
        ac.debug("Track set:", currentTrack)
        LogoDisplay.setCurrentTrack(currentTrack)
        local trackData = LocalGates.getTrackData(currentTrack)
        
        if trackData then
            if trackData.startPosition then
                setCarPosition(trackData.startPosition, trackData.startRotation)
            else
                ac.debug("No start position specified in track data")
            end
        end
        
    else
        ac.debug("Unsupported track:", currentTrack)
        unsupportedTrack = true
    end
    
    initializeAudioEvents()
    resetScript(false)

    LogoDisplay.setShowInterface(true)
    ArcadeScoring.init(LocalScoring)
    LogoDisplay.init(LocalScoring)
    
end

init()

local startGateAudioPlayed = false

local function drawTextWithShadow(text, size, pos, color, shadowColor, shadowOffset)
    shadowOffset = shadowOffset or vec2(1, 1)
    ui.dwriteDrawText(text, size, vec2(pos.x + shadowOffset.x, pos.y + shadowOffset.y), shadowColor)
    ui.dwriteDrawText(text, size, pos, color)
end

local maxDamage = 0
local isDriftFailed = false
local startGateTyreTemps = {
    core = {22, 22, 23, 23},
    outside = {22, 22, 23, 23}
}

local function getTyreTemperatures()
    local car = ac.getCar(0)
    local temperatures = {
        core = {},
        outside = {}
    }
    for i = 0, 3 do
        temperatures.core[i + 1] = car.wheels[i].tyreCoreTemperature
        temperatures.outside[i + 1] = car.wheels[i].tyreOutsideTemperature
    end
    return temperatures
end

local getBackToStartButton = ac.ControlButton('__APP_GET_BACK_TO_START')
local restartSessionButton = ac.ControlButton('__APP_RESTART_SESSION')
local seeDriftTrackButton = ac.ControlButton('__APP_SEE_DRIFT_TRACK')

local lastCrossProductSign = nil

function script.update(dt)
    if unsupportedTrack then
        return
    end

    DebugDisplay.update(dt)

    local car = ac.getCar(0)
    if car then
        currentGate, gateType, percentage = LocalGates.isCarInAnyGate(car)

        local isDriftActive = LocalScoring.updateScore(dt, car, currentGate, gateType, percentage)

        if gateType == "entryspeedline" and not entrySpeedShown then
            local currentSpeed = car.speedKmh
            entrySpeed = currentSpeed
            showEntrySpeed = true
            entrySpeedTimer = 3
            entrySpeedShown = true
            LocalScoring.setEntrySpeed(entrySpeed)
            LocalScoring.setEntrySpeedShown(true)
            ac.debug(string.format("Entry Speed Line (gate) crossed at speed: %.1f km/h", entrySpeed))
        end

        if currentGate == 1 and gateType == "start" and not startGatePassed then
            LogoDisplay.setShowInterface(false)

            local trafficLightState = DriftHUD and DriftHUD.getTrafficLightState() or 0
            if trafficLightState == 4 and not startGateAudioPlayed then
                goAudio:start()
                startGateAudioPlayed = true
                ac.debug("Start gate audio (go.mp3) played")

                startGateTyreTemps = getTyreTemperatures()
                ac.debug(string.format("Tyre temperatures at start gate: FL core: %.1f, outside: %.1f; FR core: %.1f, outside: %.1f; RL core: %.1f, outside: %.1f; RR core: %.1f, outside: %.1f",
                    startGateTyreTemps.core[1], startGateTyreTemps.outside[1],
                    startGateTyreTemps.core[2], startGateTyreTemps.outside[2],
                    startGateTyreTemps.core[3], startGateTyreTemps.outside[3],
                    startGateTyreTemps.core[4], startGateTyreTemps.outside[4]))

            elseif trafficLightState ~= 4 and not startGateAudioPlayed then
                zeroAudio:start()
                startGateAudioPlayed = true
                ac.debug("False start audio played")
            end
        elseif currentGate == #LocalGates.getGates() and gateType == "finish" then
            LogoDisplay.setShowInterface(true)

            if not LocalScoring.isDriftFailed() then
                local totalScore = Judging.getTotalScore()
                local audioIndex
                if totalScore < 50 then
                    audioIndex = 1
                elseif totalScore < 75 then
                    audioIndex = 2
                elseif totalScore < 85 then
                    audioIndex = 3
                elseif totalScore < 95 then
                    audioIndex = 4
                else
                    audioIndex = 5
                end
                finishAudios[audioIndex]:start()
            end

            LocalScoring.stopTimer()
        end

        if currentGate ~= 0 and currentGate ~= lastGatePassed then
            if currentGate > 0 then
                local gates = LocalGates.getGates()
                local gate = gates[currentGate]
                ac.debug("Passed gate " .. tostring(currentGate))

                if gateType == "start" and not startGatePassed then
                    startGatePassed = true
                    showStartImage = true
                    imageTimer = 2
                    showGetToStartMessage = false

                    zeroAudioPlayed = false

                    LocalScoring.resetScore()
                    LocalScoring.startTimer()

                elseif gateType == "finish" then
                    showFinishImage = true
                    imageTimer = 2
                end
            else
                if gateType == "no_go_zone" then
                    ac.debug("Entered no go zone " .. tostring(-currentGate))
                    LocalScoring.incrementNoGoZonesPassed()
                elseif gateType == "trajectorygate" then
                    ac.debug("Entered trajectory gate " .. tostring(-currentGate))
                    LocalScoring.incrementTrajectoryGatesPassed()
                end
            end

            lastGatePassed = currentGate
        end

        if isDriftActive then
            local currentSpeed = car.speedKmh
            local trackData = LocalGates.getTrackData(currentTrack)

            if not LocalScoring.isDriftStarted() then
                maxSpeedReached = 0
                showEntrySpeed = false
                entrySpeedTimer = 0
                entrySpeedShown = false
                LocalScoring.setEntrySpeedShown(false)
                startGateAudioPlayed = false
            else
                
                if not trackData or not trackData.entrySpeedLine then
                    if currentSpeed > maxSpeedReached then
                        maxSpeedReached = currentSpeed
                    elseif (maxSpeedReached - currentSpeed) > 15 and not entrySpeedShown then
                        entrySpeed = maxSpeedReached
                        showEntrySpeed = true
                        entrySpeedTimer = 3
                        entrySpeedShown = true
                        LocalScoring.setEntrySpeed(entrySpeed)
                        LocalScoring.setEntrySpeedShown(true)

                        if trackData then
                            ac.debug(string.format("Entry Speed: %.1f km/h", entrySpeed))
                            ac.debug(string.format("Perfect Entry Speed: %.1f km/h", trackData.perfectEntrySpeed or 120))
                        end
                    end
                end
            end
        end

        if imageTimer > 0 then
            imageTimer = imageTimer - dt
            if imageTimer <= 0 then
                showStartImage = false
                showFinishImage = false
            end
        end

        if showEntrySpeed then
            entrySpeedTimer = entrySpeedTimer - dt
            if entrySpeedTimer <= 0 then
                showEntrySpeed = false
                LocalScoring.setEntrySpeedShown(false)
            end
        end

        Judging.update(dt)
        DriftHUD.updateTime(dt)

        if LocalScoring.isDriftFailed() and not zeroAudioPlayed then
            zeroAudio:start()
            zeroAudioPlayed = true
        end

        if restartSessionButton:pressed() then
            if ac.tryToRestartSession() then
                ac.debug("Session restarted successfully")
            else
                ac.debug("Failed to restart session")
            end
        end

        if seeDriftTrackButton:pressed() then
            isDriftMissionOpen = not isDriftMissionOpen
            DriftHUD.setDriftMissionOpen(isDriftMissionOpen)
            ArcadeScoring.setDriftMissionOpen(isDriftMissionOpen)
            ac.setAppsHidden(isDriftMissionOpen)
            LogoDisplay.setShowInterface(not isDriftMissionOpen)
        end

        if getBackToStartButton:pressed() and not isCameraAnimationPlaying then
            local trackData = LocalGates.getTrackData(currentTrack)
            if trackData and trackData.alternateStartPosition then
                setCarPosition(trackData.alternateStartPosition, trackData.alternateStartRotation or trackData.startRotation)
                resetScript(true)
                local car = ac.getCar(0)
                if car then
                    physics.setCarBodyDamage(0, 0)
                    maxDamage = 0

                    setTimeout(function()
                        for i = 0, 3 do
                            physics.setTyresTemperature(0, i, startGateTyreTemps.core[i + 1], 8)
                            physics.setTyresTemperature(0, i, startGateTyreTemps.outside[i + 1], 4)
                            physics.setTyresTemperature(0, i, startGateTyreTemps.outside[i + 1], 1)
                            physics.setTyresTemperature(0, i, startGateTyreTemps.outside[i + 1], 2)
                        end

                        ac.debug(string.format("Tyre temperatures set to: FL core: %.1f, outside/inner/medium: %.1f; FR core: %.1f, outside/inner/medium: %.1f; RL core: %.1f, outside/inner/medium: %.1f; RR core: %.1f, outside/inner/medium: %.1f",
                            startGateTyreTemps.core[1], startGateTyreTemps.outside[1],
                            startGateTyreTemps.core[2], startGateTyreTemps.outside[2],
                            startGateTyreTemps.core[3], startGateTyreTemps.outside[3],
                            startGateTyreTemps.core[4], startGateTyreTemps.outside[4]))
                    end, 0)
                end

                Judging.hideScores()
                ArcadeScoring.reset()
                ac.debug("Car teleported to alternate start position, script reset, damage cleared, scores hidden, and ArcadeScoring reset")
            else
                ac.debug("Alternate start position not defined for this track")
            end
        end
        keySPressedLastFrame = keySPressed

        DriftHUD.updateTrafficLight(dt)

        local drift_angle_with_direction = 0
        if car and car.speedKmh and car.speedKmh > 20 then
            local speed = car.speedKmh
            local velocity_x = car.velocity.x
            local velocity_z = car.velocity.z
            local velocity_direction = math.atan2(velocity_z, velocity_x)
            local car_heading = math.atan2(car.look.z, car.look.x)
            drift_angle = velocity_direction - car_heading
            if drift_angle > math.pi then
                drift_angle = drift_angle - 2 * math.pi
            elseif drift_angle < -math.pi then
                drift_angle = drift_angle + 2 * math.pi
            end
            drift_angle_with_direction = math.deg(drift_angle)
            drift_angle = math.abs(math.deg(drift_angle))
        end

        if LocalScoring.isEntrySpeedShown() and not isCountingTransitions then
            isCountingTransitions = true
            lastDriftAngleSign = math.sign(drift_angle_with_direction)
        end

        if isCountingTransitions then
            local currentSign = math.sign(drift_angle_with_direction)
            if currentSign ~= lastDriftAngleSign and currentSign ~= 0 then
                transitionCount = transitionCount + 1
                lastDriftAngleSign = currentSign

                if transitionCount > getMaxAllowedTransitions() then
                    LocalScoring.failDriftDueToExcessiveTransitions(transitionCount)
                    isCountingTransitions = false
                end
            end
        end

        if currentGate == #LocalGates.getGates() and LocalScoring.isDriftStarted() and not LocalScoring.isDriftFinished() then
            isCountingTransitions = false
        end

        isDriftFailed = LocalScoring.isDriftFailed()

        if LocalScoring.isEntrySpeedShown() and not ArcadeScoring.isScoring then
            ArcadeScoring.startScoring()
        end

        if LocalScoring.isDriftFinished() then
            ArcadeScoring.stopScoring()
        end

        ArcadeScoring.update(dt, car, transitionCount)
    end
end

function script.drawUI()
    if unsupportedTrack then
        local uiState = ac.getUI()
        local screenWidth = uiState.windowSize.x
        local screenHeight = uiState.windowSize.y
        local fontSize = 40
        local text = "No active Drift task on this track.\nCreate task with Drift Zones Editor \nDownload it on App Shelf"

        ui.pushDWriteFont('Montserrat:\\Fonts')
        local textSize = ui.measureDWriteText(text, fontSize)
        local textX = (screenWidth - textSize.x) / 2.0
        local textY = (screenHeight - textSize.y) / 3.5

        drawTextWithShadow(text, fontSize, vec2(textX, textY), rgbm(1, 0, 0, 1), rgbm(0, 0, 0, 1))
        ui.popDWriteFont()
        return
    end

    if not isDriftMissionOpen then
        local uiState = ac.getUI()
        local scale = (uiState.windowSize.x / 800 + uiState.windowSize.y / 1440) / 2

        
        if Settings.showTransparentWindow == 1 then
            
            ui.beginTransparentWindow('combinedWindow', vec2(uiState.windowSize.x - 12000 * scale, -5 * scale), vec2(200, 350):scale(scale))


            
            local car = ac.getCar(0)
            local speed = car.speedKmh

           
            local drift_angle = 0
            local drift_angle_with_direction = 0
            if car and car.speedKmh and car.speedKmh > 20 then  
                local speed = car.speedKmh
                local velocity_x = car.velocity.x
                local velocity_z = car.velocity.z
                local velocity_direction = math.atan2(velocity_z, velocity_x)

                local car_heading = math.atan2(car.look.z, car.look.x)

                drift_angle = velocity_direction - car_heading

                if drift_angle > math.pi then
                    drift_angle = drift_angle - 2 * math.pi
                elseif drift_angle < -math.pi then
                    drift_angle = drift_angle + 2 * math.pi
                end

                
                drift_angle_with_direction = math.deg(drift_angle)

                
                drift_angle = math.abs(math.deg(drift_angle))
            end

            local score = LocalScoring.getScore()
            local multiplier = LocalScoring.getMultiplier()
            local multiplierTimer = LocalScoring.getMultiplierTimer()

            
            ui.pushFont(ui.Font.Title)
            ui.setCursor(vec2(20, 10 * scale))  
            ui.text(string.format("Speed: %.1f km/h", speed))
            ui.text(string.format("Drift Angle: %.1f°", drift_angle))  
            ui.text(string.format("Drift Angle (with direction): %.1f°", drift_angle_with_direction))  
            ui.text(string.format("Transitions: %d", transitionCount))  
            ui.text(string.format("Score: %d", math.floor(score)))
            ui.text(string.format("Multiplier: x%d (%.1fs)", multiplier, multiplierTimer))


            if LocalScoring.isDriftActive() then
                ui.text(string.format("Drift Time: %.1f s", LocalScoring.getDriftDuration()))
            elseif LocalScoring.isDriftFinished() then
                local entrySpeedValue = LocalScoring.getEntrySpeed()
                if entrySpeedValue and entrySpeedValue > 0 then
                    ui.text(string.format("Entry Speed: %.1f km/h", entrySpeedValue))
                else
                    ac.debug("Entry Speed is not valid.")
                end
                ui.text(string.format("Peak Angle: %.1f°", LocalScoring.getPeakAngle()))
                ui.text(string.format("Gates Passed: %d", LocalScoring.getGatesPassed()))
                ui.text(string.format("No Go Zones Passed: %d", LocalScoring.getNoGoZonesPassed()))
            end

            ui.popFont()

            ui.endTransparentWindow()
        end

        
        if Settings.showDebugDisplay == 1 then
            DebugDisplay.draw()
        end

        
        if showGetToStartMessage then
            local uiState = ac.getUI()
            local screenWidth = uiState.windowSize.x
            local screenHeight = uiState.windowSize.y
            local fontSize = 50
            local text = "Get to the start"

            ui.pushDWriteFont('Montserrat:\\Fonts')
            local textWidth = ui.measureDWriteText(text, fontSize).x
            local textHeight = ui.measureDWriteText(text, fontSize).y
            local textX = (screenWidth - textWidth) / 2.0
            local textY = screenHeight * 0.175 

            
            drawTextWithShadow(text, fontSize, vec2(textX, textY), rgbm(1, 1, 1, 1), rgbm(0, 0, 0, 1))

            
            local car = ac.getCar(0)
            local startGate = LocalGates.getGates()[1]
            if startGate then
                
                local gateAngle = math.rad(startGate.rotation)
                local gateHalfWidth = startGate.size.width / 2
                local gateHalfLength = startGate.size.length / 2

                
                local gateCorners = {
                    vec3(-gateHalfWidth, 0, -gateHalfLength),
                    vec3(gateHalfWidth, 0, -gateHalfLength),
                    vec3(gateHalfWidth, 0, gateHalfLength),
                    vec3(-gateHalfWidth, 0, gateHalfLength)
                }

                
                for i, corner in ipairs(gateCorners) do
                    local rotatedX = corner.x * math.cos(gateAngle) - corner.z * math.sin(gateAngle)
                    local rotatedZ = corner.x * math.sin(gateAngle) + corner.z * math.cos(gateAngle)
                    gateCorners[i] = vec3(
                        rotatedX + startGate.position.x,
                        startGate.position.y,
                        rotatedZ + startGate.position.z
                    )
                end

                
                local minDistance = math.huge
                for i = 1, #gateCorners do
                    local corner1 = gateCorners[i]
                    local corner2 = gateCorners[i % 4 + 1]

                    
                    local edgeVector = vec3(corner2.x - corner1.x, 0, corner2.z - corner1.z)
                    local carVector = vec3(car.position.x - corner1.x, 0, car.position.z - corner1.z)
                    local edgeLength = edgeVector:length()
                    local t = math.clamp(carVector:dot(edgeVector) / (edgeLength * edgeLength), 0, 1)
                    local closestPoint = vec3(
                        corner1.x + t * edgeVector.x,
                        corner1.y,
                        corner1.z + t * edgeVector.z
                    )

                    
                    local distance = vec3.distance(car.position, closestPoint)
                    if distance < minDistance then
                        minDistance = distance
                    end
                end

                
                local adjustedDistance = math.max(minDistance - 3, 0)

                local distanceText
                local distanceColor
                if adjustedDistance <= 1 then
                    distanceText = "Wait for Green"
                    distanceColor = rgbm(0, 1, 0, 1)  
                else
                    
                    local t = math.min(1, (10 - adjustedDistance) / 9)  
                    distanceColor = rgbm(
                        1 - t,  
                        t,      
                        0,      
                        1       
                    )
                end

                if adjustedDistance <= 1 then
                    local distanceTextWidth = ui.measureDWriteText(distanceText, fontSize * 0.75).x
                    local distanceTextX = (screenWidth - distanceTextWidth) / 2
                    
                    drawTextWithShadow(distanceText, fontSize * 0.75, vec2(distanceTextX, textY + textHeight - 5), distanceColor, rgbm(0, 0, 0, 1))
                else
                    local labelText = "Distance to start line: "
                    local numberText = string.format("%.0f m", adjustedDistance)

                    
                    local labelWidth = ui.measureDWriteText(labelText, fontSize * 0.75).x

                    
                    if not maxNumberWidth then
                        maxNumberWidth = ui.measureDWriteText(maxNumberText, fontSize * 0.75).x
                    end

                    
                    local totalWidth = labelWidth + maxNumberWidth
                    local startX = (screenWidth - totalWidth) / 2

                    
                    drawTextWithShadow(labelText, fontSize * 0.75, vec2(startX, textY + textHeight - 5), rgbm(1, 1, 1, 1), rgbm(0, 0, 0, 1))

                    
                    local numberWidth = ui.measureDWriteText(numberText, fontSize * 0.75).x

                    
                    local numberX = startX + labelWidth + (maxNumberWidth - numberWidth) / 2

                    
                    drawTextWithShadow(numberText, fontSize * 0.75, vec2(numberX, textY + textHeight - 5), distanceColor, rgbm(0, 0, 0, 1))
                end
            end

            ui.popDWriteFont()
        end

        
        if showEntrySpeed then
            local uiState = ac.getUI()
            local screenWidth = uiState.windowSize.x
            local screenHeight = uiState.windowSize.y
            local fontSize = 36
            local labelText = "Entry Speed:"
            local speedText = string.format("%.1f", entrySpeed)
            local unitText = "km/h"

            
            ui.pushDWriteFont('Montserrat:\\Fonts')

            local labelWidth = ui.measureDWriteText(labelText, fontSize).x
            local speedWidth = ui.measureDWriteText(speedText, fontSize).x
            local unitWidth = ui.measureDWriteText(unitText, fontSize).x

            local totalWidth = labelWidth + speedWidth + unitWidth + 20  
            local startX = (screenWidth - totalWidth) / 2
            local textY = screenHeight * 0.22  

            
            local speedColor
            local trackData = LocalGates.getTrackData()
            local perfectEntrySpeed = trackData and trackData.perfectEntrySpeed or 120 

            if entrySpeed >= perfectEntrySpeed then
                speedColor = rgbm(0, 1, 0, 1)  
            else
                
                local t = math.min(1, (entrySpeed - (perfectEntrySpeed - 35)) / 35)
                speedColor = rgbm(
                    1 - t,  
                    t,      
                    0,      
                    1       
                )
            end

            
            drawTextWithShadow(labelText, fontSize, vec2(startX, textY), rgbm(1, 1, 1, 1), rgbm(0, 0, 0, 1))
            drawTextWithShadow(speedText, fontSize, vec2(startX + labelWidth + 10, textY), speedColor, rgbm(0, 0, 0, 1))
            drawTextWithShadow(unitText, fontSize, vec2(startX + labelWidth + speedWidth + 20, textY), rgbm(1, 1, 1, 1), rgbm(0, 0, 0, 1))

            
            ui.popDWriteFont()
        end

        
        Judging.draw()

        
        DriftHUD.draw()

        
        local driftMessage, driftMessageType = LocalScoring.getDriftMessage()
        if driftMessage ~= "" then
            local uiState = ac.getUI()
            local screenWidth = uiState.windowSize.x
            local screenHeight = uiState.windowSize.y
            local fontSize = 30
            local messageColor = driftMessageType == "warning" and rgbm(1, 0, 0, 1) or rgbm(1, 1, 1, 1)

            ui.pushDWriteFont('Montserrat:\\Fonts')
            local textWidth = ui.measureDWriteText(driftMessage, fontSize).x
            local textX = (screenWidth - textWidth) / 2.0
            local textY = screenHeight * 0.19 

            drawTextWithShadow(driftMessage, fontSize, vec2(textX, textY), messageColor, rgbm(0, 0, 0, 1))
            ui.popDWriteFont()
        end
    end

    
    LogoDisplay.draw(isDriftMissionOpen or (isDriftFailed and isDriftMissionOpen))

    ArcadeScoring.draw()
end

function script.destroy()
    
end


local originalLocalScoringResetScore = LocalScoring.resetScore
function LocalScoring.resetScore()
    if originalLocalScoringResetScore then
        originalLocalScoringResetScore()
    end
    resetTransitionCount()
end

