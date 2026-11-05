-- local_scoring.lua

local LocalScoring = {}
local LocalGates = require('local_gates')
local Judges = require('judges')
local Judging = require('judging')
local Settings = require('settings')

local DriftHUD = nil  

function LocalScoring.setDriftHUD(driftHUD)
    DriftHUD = driftHUD
end

local score = 0
local scoreMultiplier = 1
local multiplierTimer = 0
local multiplierDuration = 20  
local isDriftStarted = false
local isDriftFinished = false
local isDriftFailed = false
local driftStartTime = 0
local driftDuration = 0
local entrySpeed = 0
local peakAngle = 0
local gatesPassed = 0
local lastPassedGate = 0
local isInGate = false
local gateTimer = 0
local gateMultiplierIncreaseInterval = 0.01  
local noGoZonesPassed = 0
local trajectoryGatesPassed = 0  
local totalDriftAngle = 0
local driftAngleCount = 0
local averageDriftAngle = 0
local isEntrySpeedShown = false  


local passed_gates = {}


local driftMessage = ""
local driftMessageType = ""  
local driftMessageTimer = 0
local driftMessageDuration = 3  

local lowAngleTimer = 0
local lowSpeedTimer = 0

local startTime = 0
local finishTime = 0
local totalTime = 0

local isLapValid = true  


local function safeToString(value)
    if type(value) == "number" then
        return string.format("%.2f", value)
    else
        return tostring(value)
    end
end

function LocalScoring.setEntrySpeedShown(value)
    isEntrySpeedShown = value
end

function LocalScoring.isEntrySpeedShown()
    return isEntrySpeedShown
end


local function isOnValidTrack()
    local car = ac.getCar(0)
    local invalid = 0
    for i = 0, 3 do
        if not car.wheels[i].surfaceValidTrack then
            invalid = invalid + 1
        end
    end
    return invalid < 2
end

function LocalScoring.updateScore(dt, car, currentGate, gateType, percentage)
    local gates = LocalGates.getGates()
    local totalGates = #gates

    
    local trafficLightState = DriftHUD and DriftHUD.getTrafficLightState() or 0

    
    if currentGate == 1 and gateType == "start" and trafficLightState ~= 4 then
        
        LocalScoring.failDriftDueToFalseStart()
        return false
    end

    
    if currentGate == 1 and gateType == "start" and not isDriftStarted then
        isDriftStarted = true
        isDriftFinished = false
        isDriftFailed = false
        score = 0
        scoreMultiplier = 1
        multiplierTimer = 0
        driftStartTime = os.clock()
        entrySpeed = car.speedKmh
        peakAngle = 0
        gatesPassed = 0
        lastPassedGate = 1
        isInGate = false
        gateTimer = 0
        isEntrySpeedShown = false
        isCalculatingAverageAngle = false
        driftMessage = "New Drift Challenge Started!"
        driftMessageType = "normal"
        driftMessageTimer = driftMessageDuration
        passed_gates = {}  
        LocalScoring.startTimer()
        ac.debug("Drift started at gate:", currentGate)
        return true
    end

    
    local angle = 0
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

        angle = math.abs(math.deg(drift_angle_rad))
    else
        angle = 0
    end

    
    if isEntrySpeedShown and not isCalculatingAverageAngle then
        isCalculatingAverageAngle = true
        totalDriftAngle = 0
        driftAngleCount = 0
        lowAngleTimer = 0  
    end

    
    if isCalculatingAverageAngle and isDriftStarted and not isDriftFinished then
        totalDriftAngle = totalDriftAngle + angle
        driftAngleCount = driftAngleCount + 1
        averageDriftAngle = totalDriftAngle / driftAngleCount
    end




    if isDriftStarted and not isDriftFinished and car.speedKmh > Settings.lowSpeedThreshold and isCalculatingAverageAngle then
        if angle < Settings.lowAngleThreshold then
            lowAngleTimer = lowAngleTimer + dt
            if lowAngleTimer >= Settings.lowAngleDuration then
                isDriftFinished = true
                isDriftFailed = true
                driftMessage = string.format("Drift Challenge Failed! Angle too low (%.1f°) for too long.", angle)
                driftMessageType = "warning"
                driftMessageTimer = driftMessageDuration
                return false
            end
        else
            lowAngleTimer = 0
        end
    end


    if isDriftStarted and not isDriftFinished then
        if not isOnValidTrack() then

            isDriftFinished = true
            isDriftFailed = true
            driftMessage = "Drift Challenge Failed! Car left the track."
            driftMessageType = "warning"
            driftMessageTimer = driftMessageDuration
            return false
        end
    end


    if currentGate == totalGates and isDriftStarted and not isDriftFinished then
        isDriftFinished = true
        LocalScoring.stopTimer()  
        Judging.calculateScores(entrySpeed, averageDriftAngle, driftDuration, noGoZonesPassed, trajectoryGatesPassed, passed_gates)
        return false
    end


    if isDriftStarted and not isDriftFinished then
        if car.speedKmh < Settings.lowSpeedThreshold then
            lowSpeedTimer = lowSpeedTimer + dt
            if lowSpeedTimer >= Settings.lowSpeedDuration then
                isDriftFinished = true
                isDriftFailed = true
                driftMessage = "Drift Challenge Failed! Speed too low for too long."
                driftMessageType = "warning"
                driftMessageTimer = driftMessageDuration
                return false
            end
        else
            lowSpeedTimer = 0
        end
    end


    if multiplierTimer > 0 then
        multiplierTimer = multiplierTimer - dt
        if multiplierTimer <= 0 then
            scoreMultiplier = 1
        end
    end


    if currentGate > 0 then
        if not isInGate then
            isInGate = true
            gateTimer = 0
            if currentGate > 1 and currentGate < totalGates and currentGate > lastPassedGate then
                if angle > 8 then  
                    gatesPassed = gatesPassed + 1
                    
                    passed_gates[currentGate] = {
                        passed = true,
                        angle = angle
                    }
                end
                lastPassedGate = currentGate
            end
        end
        if gateType == "normal" then
            
        elseif gateType == "no_go_zone" then
            noGoZonesPassed = noGoZonesPassed + 1
            driftMessage = "Entered No Go Zone! Penalty applied."
            driftMessageType = "warning"
            driftMessageTimer = driftMessageDuration
        elseif gateType == "trajectorygate" then
            if not passed_gates[currentGate] then
                trajectoryGatesPassed = trajectoryGatesPassed + 1
                driftMessage = "Entered Trajectory Gate! Penalty applied."
                driftMessageType = "warning"
                driftMessageTimer = driftMessageDuration
                passed_gates[currentGate] = true
            end
        end
    else
        
        isInGate = false
        gateTimer = 0
    end

    
    peakAngle = math.max(peakAngle, angle)

    
    local baseScore = 0
    if isDriftStarted and not isDriftFinished and angle >= 7 and angle <= 110 then
        baseScore = car.speedKmh / 10 
    end

    
    local scoreIncrement = baseScore * scoreMultiplier * dt
    score = score + scoreIncrement

    
    if isDriftStarted and not isDriftFinished then
        driftDuration = os.clock() - driftStartTime
    end

    
    if driftMessageTimer > 0 then
        driftMessageTimer = driftMessageTimer - dt
        if driftMessageTimer <= 0 then
            driftMessage = ""
        end
    end

    return isDriftStarted and not isDriftFinished
end

function LocalScoring.getScore()
    return score
end

function LocalScoring.getMultiplier()
    return scoreMultiplier
end

function LocalScoring.getMultiplierTimer()
    return multiplierTimer
end

function LocalScoring.isDriftActive()
    return isDriftStarted and not isDriftFinished
end

function LocalScoring.isDriftFinished()
    return isDriftFinished
end

function LocalScoring.isDriftFailed()
    return isDriftFailed
end

function LocalScoring.getEntrySpeed()
    return entrySpeed
end

function LocalScoring.getPeakAngle()
    return peakAngle
end

function LocalScoring.getGatesPassed()
    return gatesPassed
end

function LocalScoring.getDriftDuration()
    return driftDuration
end

function LocalScoring.getNoGoZonesPassed()
    return noGoZonesPassed
end

function LocalScoring.getTrajectoryGatesPassed()
    return trajectoryGatesPassed
end

function LocalScoring.incrementNoGoZonesPassed()
    noGoZonesPassed = noGoZonesPassed + 1
end

function LocalScoring.incrementTrajectoryGatesPassed()
    trajectoryGatesPassed = trajectoryGatesPassed + 1
end

function LocalScoring.resetScore()
    score = 0
    scoreMultiplier = 1
    multiplierTimer = 0
    isDriftStarted = false
    isDriftFinished = false
    isDriftFailed = false
    driftStartTime = 0
    driftDuration = 0
    entrySpeed = 0
    peakAngle = 0
    gatesPassed = 0
    noGoZonesPassed = 0
    trajectoryGatesPassed = 0
    totalDriftAngle = 0
    driftAngleCount = 0
    averageDriftAngle = 0
    isEntrySpeedShown = false
    isCalculatingAverageAngle = false
    lowAngleTimer = 0
    lowSpeedTimer = 0
    startTime = 0
    finishTime = 0
    totalTime = 0
    isLapValid = true  
    Judging.resetLineDisplay()
    passed_gates = {}  
end

function LocalScoring.isDriftStarted()
    return isDriftStarted
end

function LocalScoring.setEntrySpeed(speed)
    entrySpeed = speed
end

function LocalScoring.getEntrySpeed()
    return entrySpeed
end

function LocalScoring.getAverageDriftAngle()
    return averageDriftAngle
end


function LocalScoring.getPassedGateIndices()
    return passed_gates
end


function LocalScoring.getDriftMessage()
    return driftMessage, driftMessageType
end

function LocalScoring.startTimer()
    startTime = os.clock()
end

function LocalScoring.stopTimer()
    finishTime = os.clock()
    totalTime = finishTime - startTime
end

function LocalScoring.getTotalTime()
    return totalTime
end


function LocalScoring.failDriftDueToDamage(overallDamage)
    if isDriftStarted and not isDriftFinished then
        isDriftFinished = true
        isDriftFailed = true
        driftMessage = string.format("Drift Challenge Failed! Overall damage (%.2f) exceeded threshold.", overallDamage)
        driftMessageType = "warning"
        driftMessageTimer = driftMessageDuration
    end
end


function LocalScoring.failDriftDueToInvalidLap()
    if isDriftStarted and not isDriftFinished then
        isDriftFinished = true
        isDriftFailed = true
        driftMessage = "Drift Challenge Failed! Lap is not valid."
        driftMessageType = "warning"
        driftMessageTimer = driftMessageDuration
    end
end


function LocalScoring.failDriftDueToFalseStart()
    isDriftStarted = true
    isDriftFinished = true
    isDriftFailed = true
    driftMessage = "Drift Challenge Failed! False start."
    driftMessageType = "warning"
    driftMessageTimer = driftMessageDuration
    ac.debug("False start detected!")  
end


function LocalScoring.isFalseStart()
    return isDriftFailed and driftMessage == "Drift Challenge Failed! False start."
end


function LocalScoring.isLapValid()
    return isLapValid
end


function LocalScoring.getArcadeScore()
    local gateScore = gatesPassed * 100  
    local angleScore = peakAngle * 10    
    local speedScore = entrySpeed * 2    

    local arcadeScore = gateScore + angleScore + speedScore

    
    arcadeScore = arcadeScore - (noGoZonesPassed * 500)  
    arcadeScore = arcadeScore - (trajectoryGatesPassed * 250)  

    return math.max(0, math.floor(arcadeScore))  
end

function LocalScoring.calculateFinalScore()
    local judgesScores = Judges.getScores(entrySpeed, averageDriftAngle, driftDuration, noGoZonesPassed, trajectoryGatesPassed, passed_gates)
    return judgesScores
end


function LocalScoring.failDriftDueToExcessiveTransitions(transitionCount)
    if isDriftStarted and not isDriftFinished then
        isEntrySpeedShown = false
        isDriftFinished = true
        isDriftFailed = true
        driftMessage = string.format("Drift Challenge Failed! Opposite Drift Detected! (%d).", transitionCount)
        driftMessageType = "warning"
        driftMessageTimer = driftMessageDuration
    end
end

return LocalScoring