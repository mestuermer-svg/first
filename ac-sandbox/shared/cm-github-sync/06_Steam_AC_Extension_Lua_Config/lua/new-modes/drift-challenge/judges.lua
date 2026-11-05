local Judges = {}
local LocalGates = require('local_gates')
local Settings = require('settings')



local function calculateScore(entrySpeed, averageAngle, driftDuration, noGoZonesPassed, trajectoryGatesPassed, passed_gates)
    
    local trackData = LocalGates.getTrackData()
    local perfectEntrySpeed = trackData and trackData.perfectEntrySpeed or 120
    
    
    local entrySpeedScore
    if entrySpeed >= perfectEntrySpeed then
        entrySpeedScore = 10
    else
        
        entrySpeedScore = math.floor(math.min(20, math.max(0, (entrySpeed - (perfectEntrySpeed - 35)) / 35 * 20))) / 2
    end

    
    local angleScore
    if averageAngle < 20 then
        angleScore = 0
    elseif averageAngle >= 42 then
        angleScore = 20  
    else
        
        angleScore = math.floor((averageAngle - 20) / (42 - 20) * 40 + 0.5) / 2
    end

    
    local gates = LocalGates.getGates()
    local gatesScore = 0
    local totalGateMultiplier = 0
    local passedGateMultiplier = 0
    
    for i = 2, #gates - 1 do  
        local gate = gates[i]
        local gateMultiplier = gate.score_multiplier or 1
        totalGateMultiplier = totalGateMultiplier + gateMultiplier
        
        if passed_gates[i] then
            
            local gatePassAngle = passed_gates[i].angle or 0
            local targetAngle = gate.target_angle or 0
            
            
            local angleMultiplier = 0.0  
            if targetAngle > 0 then
                if gatePassAngle >= targetAngle then
                    angleMultiplier = 1.0  
                elseif gatePassAngle < 15 then
                    angleMultiplier = 0.0  
                else
                    
                    angleMultiplier = 0.1 + (gatePassAngle - 15) / (targetAngle - 15) * 0.9
                end
            end
            
            passedGateMultiplier = passedGateMultiplier + (gateMultiplier * angleMultiplier)
            
            
            ac.debug(string.format("Gate %d - Target: %.1f°, Actual: %.1f°, Multiplier: %.2f, Score Multiplier: %.2f, Final: %.2f",
                i, targetAngle, gatePassAngle, angleMultiplier, gateMultiplier, gateMultiplier * angleMultiplier))
        end
    end

    
    gatesScore = math.floor((passedGateMultiplier / totalGateMultiplier) * 150 + 0.5) / 2

    local noGoZonePenalty = noGoZonesPassed * Settings.noGoZonePenaltyPoints
    local trajectoryGatePenalty = (trajectoryGatesPassed or 0) * Settings.trajectoryGatePenaltyPoints
    local totalScore = entrySpeedScore + angleScore + gatesScore - noGoZonePenalty - trajectoryGatePenalty
    
    
    local finalScore = math.min(100, math.max(0, totalScore))
    
    return finalScore, {
        entrySpeedScore = entrySpeedScore,
        angleScore = angleScore,
        averageAngle = averageAngle,
        gatesScore = gatesScore,
        passedGateMultiplier = passedGateMultiplier,
        totalGateMultiplier = totalGateMultiplier,
        noGoZonePenalty = noGoZonePenalty,
        trajectoryGatePenalty = trajectoryGatePenalty
    }
end

function Judges.getScores(entrySpeed, averageAngle, driftDuration, noGoZonesPassed, trajectoryGatesPassed, passed_gates)
    local score, details = calculateScore(entrySpeed, averageAngle, driftDuration, noGoZonesPassed, trajectoryGatesPassed, passed_gates)
    return {
        total = score,
        details = details
    }
end

return Judges
