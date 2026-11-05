-- local_render_gates.lua

local LocalRenderGates = {}
local LocalGates = require('local_gates')

local paint = ac.TrackPaint()
paint.bulgeFactor = 0.5
paint.ageFactor = 0
paint.castStep = 0.5  

local currentGates = {}

local function addGate(gate, color)
    local lineWidth = gate.line_width or 1.0
    
    if gate.type == "OZ" or gate.type == "no_go_zone" or gate.type == "trajectory" or 
       gate.type == "start" or gate.type == "finish" or gate.size.width <= 0.1 then
        local dir = mat4x4.rotation(math.rad(-gate.rotation), vec3(0, 1, 0)):transformVector(vec3(0, 0, gate.size.length / 2))
        local baseLineWidth = 0.1
        paint:line(gate.position - dir, gate.position + dir, color, baseLineWidth * lineWidth)
    else
        paint:rect(gate.position, vec2(gate.size.length, gate.size.width), gate.rotation, 0.1 * lineWidth, color)
    end
end

local function updateGatesPaint()
    paint:reset()

    local trackData = LocalGates.getTrackData()
    if trackData then
        local gates = LocalGates.getGates()
        for _, gate in ipairs(gates) do
            local color
            if gate.type == "start" then
                color = rgbm(
                    gate.color_r or 0.9,
                    gate.color_g or 0.9,
                    gate.color_b or 0.9,
                    trackData.gatesTransparency.start or 1
                )
            elseif gate.type == "finish" then
                color = rgbm(
                    gate.color_r or 0.9,
                    gate.color_g or 0.9,
                    gate.color_b or 0.9,
                    trackData.gatesTransparency.finish or 1
                )
            elseif gate.type == "OZ" or gate.type == "normal" then
                color = rgbm(
                    gate.color_r or 0.9,
                    gate.color_g or 0.9,
                    gate.color_b or 0.9,
                    trackData.gatesTransparency[gate.type == "OZ" and "oz" or "normal"] or 1
                )
            else
                color = rgbm(0.9, 0.9, 0.9, trackData.gatesTransparency.normal or 1)
            end
            addGate(gate, color)
        end

        
        local noGoZones = LocalGates.getNoGoZones()
        for _, gate in ipairs(noGoZones) do
            local color = rgbm(1, 0, 0, trackData.gatesTransparency.noGoZone or 1)
            gate.type = "no_go_zone"  
            addGate(gate, color)
        end

                
        local trajectoryGates = LocalGates.getTrajectoryGates()
        for _, gate in ipairs(trajectoryGates) do
            local color = rgbm(1, 1, 0, trackData.gatesTransparency.trajectory or 1)
            gate.type = "trajectory"  
            addGate(gate, color)
        end

        if trackData.entrySpeedLine then
            local line = trackData.entrySpeedLine
            local lineRotation = math.rad(line.rotation)
            local forward = vec3(math.cos(lineRotation), 0, math.sin(lineRotation))
            
            local halfLength = line.length / 2
            local lineStart = line.position - forward * halfLength
            local lineEnd = line.position + forward * halfLength
            
            paint:line(
                lineStart, 
                lineEnd, 
                rgbm(0, 0.7, 0, 0.0),  
                0.05  
            )
        end
    end
end

local appliedState = nil

function LocalRenderGates.init()
    setInterval(function ()
        if type(appliedState) == 'boolean' then
            
            return clearInterval
        end


        local currentState = stringify.binary(LocalGates.getGates())
        if currentState ~= appliedState then
            ac.log('Gates changed')
            appliedState = currentState
            updateGatesPaint()
        end
    end, 0.5)
end


function LocalRenderGates.refresh()
    if appliedState ~= true then
        appliedState = true
        setTimeout(function ()
            updateGatesPaint()
            appliedState = false
        end)
    end
end

function LocalRenderGates.updateGateInRealtime(index, gate)
    if gate.arrayType == "noGoZones" then
        local noGoZones = LocalGates.getNoGoZones()
        if noGoZones and noGoZones[index] then
            gate.type = "no_go_zone"
            noGoZones[index] = gate
            LocalGates.setNoGoZones(noGoZones)
        end
    elseif gate.arrayType == "trajectoryGates" then
        local trajectoryGates = LocalGates.getTrajectoryGates()
        if trajectoryGates and trajectoryGates[index] then
            gate.type = "trajectory"
            trajectoryGates[index] = gate
            LocalGates.setTrajectoryGates(trajectoryGates)
        end
    else
        local gates = LocalGates.getGates()
        if gates and gates[index] then
            gates[index] = gate
            LocalGates.setGates(gates)
        end
    end
    
    
    LocalRenderGates.refresh()
end

function LocalRenderGates.updateGates(gates)
    if gates then
        LocalGates.setGates(gates)
    end
    LocalRenderGates.refresh()
end


function LocalRenderGates.setCastStep(step)
    if type(step) == "number" and step > 0 then
        paint.castStep = step
        LocalRenderGates.refresh()  
    end
end

return LocalRenderGates
