local DriftHUD = {}
local settings = require('settings')
local LocalGates = require('local_gates')
local LocalScoring = require('local_scoring')

local hud_scale = 1.0

local colors = {
    GRAY = rgbm(0.2, 0.2, 0.2, 1),
    LIGHT_GREEN = rgbm(0, 1, 0, 1),
    YELLOW = rgbm(1, 1, 0, 1),
    RED = rgbm(1, 0, 0, 1),
    GREEN = rgbm(0, 1, 0, 1),
    WHITE = rgbm(1, 1, 1, 1),
    BLACK = rgbm(0, 0, 0, 0.5),
    TRANSPARENT = rgbm(0, 0, 0, 0),
    NEON_RED = rgbm(1, 0, 0, 0.9),
    DARK_GRAY = rgbm(0.1, 0.1, 0.1, 0.3),
}

local function make_circle_path(center, radius, start_angle, end_angle, segments)
    ui.pathClear()
    ui.pathArcTo(center, radius, start_angle, end_angle, segments)
end

local current_fill = 0
local target_fill = 0
local animation_speed = 0.007

local rotation_angle = 0
local rotation_speed = 0.12

local pulse_scale = 1
local pulse_direction = 1
local pulse_speed = 0.002
local pulse_min = 0.95
local pulse_max = 1.25

local shift_offset_x = -130
local shift_offset_y = 0

function DriftHUD.setShift(offset_x, offset_y)
    shift_offset_x = offset_x
    shift_offset_y = offset_y
end

function DriftHUD.getShift()
    return shift_offset_x, shift_offset_y
end

local currentTime = 0

local traffic_light_timer = 0
local traffic_light_state = 0
local traffic_light_started = false

local light_animations = {}

for i = 1, 4 do
    light_animations[i] = {
        alpha = 0,
        scale = 0.5,
        active = false
    }
end

local green_pulse_alpha = 1
local green_pulse_direction = -1

local is_near_start_gate = false
local is_stationary = false
local green_light_timer = 0
local show_traffic_light = false

local delay_timer = 0

local greenLightTimer = 0
local isYellowBlinking = false
local blinkTimer = 0
local blinkInterval = 0.5  
local greenLightDuration = 5  


function DriftHUD.updateTrafficLight(dt)
    local my_car = ac.getCar(0)
    if my_car == nil then return end

    local gates = LocalGates.getGates()
    if #gates == 0 then return end

    local start_gate = gates[1]  
    if start_gate == nil then return end

    local distance_to_start = vec3.distance(my_car.position, start_gate.position)
    is_near_start_gate = distance_to_start < 7  
    is_stationary = my_car.speedKmh < 1  

    if is_near_start_gate and is_stationary and not traffic_light_started then
        if not settings.trainingMode then
            if delay_timer < 2 then  
                delay_timer = delay_timer + dt
                return
            end
        end

        traffic_light_timer = 0
        traffic_light_started = true
        show_traffic_light = true
        delay_timer = 0  

        if settings.trainingMode then
            
            traffic_light_state = 4
            light_animations[4].active = true
            light_animations[4].alpha = 1  
            light_animations[4].scale = 1  
        else
            
            traffic_light_state = 0
        end
    elseif traffic_light_started and not settings.trainingMode and traffic_light_state < 4 then
        
        traffic_light_timer = traffic_light_timer + dt

        if traffic_light_timer >= 1 then
            traffic_light_timer = 0
            traffic_light_state = traffic_light_state + 1
            if traffic_light_state <= 4 then
                light_animations[traffic_light_state].active = true
                light_animations[traffic_light_state].alpha = 0
                light_animations[traffic_light_state].scale = 0.5
            end
        end
    end

    if not is_near_start_gate and not is_stationary and traffic_light_state < 4 then
        traffic_light_started = false
        show_traffic_light = false
        traffic_light_state = 0
        traffic_light_timer = 0
        delay_timer = 0 
        for i = 1, 4 do
            light_animations[i].active = false
            light_animations[i].alpha = 0
            light_animations[i].scale = 0.5
        end
    end

    show_traffic_light = is_near_start_gate or traffic_light_started

    
    if not settings.trainingMode then
        for i = 1, 4 do
            if light_animations[i].active then
                light_animations[i].alpha = math.min(light_animations[i].alpha + dt * 12, 1)
                light_animations[i].scale = math.min(light_animations[i].scale + dt * 12, 1)
                if light_animations[i].alpha >= 1 and light_animations[i].scale >= 1 then
                    light_animations[i].active = false
                end
            end
        end
    end

    if traffic_light_state == 4 then
        greenLightTimer = greenLightTimer + dt
        if greenLightTimer >= greenLightDuration then
            isYellowBlinking = true
            traffic_light_state = 5  
            
            for i = 1, 4 do
                light_animations[i].active = true
                light_animations[i].alpha = 1
                light_animations[i].scale = 1
            end
        end
    end

    if isYellowBlinking then
        blinkTimer = blinkTimer + dt
        if blinkTimer >= blinkInterval then
            blinkTimer = 0
            
            local newAlpha = light_animations[1].alpha > 0 and 0 or 1
            for i = 1, 4 do
                light_animations[i].alpha = newAlpha
            end
        end
    end
end


local function drawBlurredCircle(center, radius, color, blur_strength)
    local blur_layers = 5
    for layer = blur_layers, 1, -1 do
        local layer_scale = 1 + (layer / blur_layers) * (blur_strength / 100)
        local layer_alpha = color.mult * (1 - (layer - 1) / blur_layers) * 0.2
        local blur_radius = radius * layer_scale
        local blur_color = rgbm(color.r, color.g, color.b, layer_alpha)
        ui.drawCircleFilled(center, blur_radius, blur_color, 64)
    end
    ui.drawCircleFilled(center, radius, color, 64)
end


local isDriftMissionOpen = false


function DriftHUD.setDriftMissionOpen(state)
    isDriftMissionOpen = state
end


function DriftHUD.draw()
    if isDriftMissionOpen then
        return  
    end

    local my_car = ac.getCar(0)
    if my_car == nil then return end

    local window_size = ui.windowSize()
    local window_width, window_height = window_size.x, window_size.y

    
    local circle_center = vec2(
        window_width - 50 - (50 * hud_scale),  
        window_height - 20 - (70 * hud_scale)   
    )

    
    local panel_size = vec2(400, 140) * hud_scale
    local panel_pos = vec2(
        window_width - panel_size.x - 20,  
        window_height - panel_size.y - 20   
    )

    
    ui.drawRectFilled(panel_pos, panel_pos + panel_size, colors.BLACK, 20 * hud_scale)

    local base_circle_radius = 50 * hud_scale
    local circle_width = 8 * hud_scale
    local empty_angle = math.pi * 0.1
    local top_angle = -math.pi / 2 + empty_angle / 2

    local gates = LocalGates.getGates()
    local total_gates = #gates - 2  
    
    local passed_gates = LocalScoring.getPassedGateIndices()

    
    local total_weight = 0
    local current_progress = 0

    for i = 2, #gates - 1 do  
        local gate_weight = gates[i].score_multiplier or 1
        total_weight = total_weight + gate_weight
        if passed_gates[i] then
            current_progress = current_progress + gate_weight
        end
    end

    
    local fill_percentage = current_progress / total_weight

    
    target_fill = fill_percentage
    if current_fill < target_fill then
        current_fill = math.min(current_fill + animation_speed, target_fill)
    elseif current_fill > target_fill then
        current_fill = math.max(current_fill - animation_speed, target_fill)
    end

    
    rotation_angle = rotation_angle + rotation_speed
    if rotation_angle > math.pi * 2 then
        rotation_angle = rotation_angle - math.pi * 2
    end

    
    pulse_scale = pulse_scale + pulse_speed * pulse_direction
    if pulse_scale >= pulse_max then
        pulse_direction = -1
    elseif pulse_scale <= pulse_min then
        pulse_direction = 1
    end

    
    make_circle_path(circle_center, base_circle_radius, top_angle, top_angle + math.pi * 2 - empty_angle, 60)
    ui.pathStroke(rgbm(0.3, 0.3, 0.3, 1), false, circle_width)

    
    local end_angle = math.lerp(top_angle, top_angle + math.pi * 2 - empty_angle, current_fill)
    make_circle_path(circle_center, base_circle_radius, top_angle, end_angle, 60)
    ui.pathStroke(colors.NEON_RED, false, circle_width)

    
    local pulse_offset = 10 * hud_scale  
    local outer_radius = base_circle_radius + (pulse_offset * pulse_scale)
    make_circle_path(circle_center, outer_radius, top_angle, top_angle + math.pi * 2 - empty_angle, 60)
    ui.pathStroke(colors.NEON_RED, false, 2 * hud_scale)

    
    local drift_angle = 0
    local speed = my_car.speedKmh
    if speed > 20 then
        local velocity_x = my_car.velocity.x
        local velocity_z = my_car.velocity.z
        local velocity_direction = math.atan2(velocity_z, velocity_x)

        local car_heading = math.atan2(my_car.look.z, my_car.look.x)

        drift_angle = velocity_direction - car_heading

        if drift_angle > math.pi then
            drift_angle = drift_angle - 2 * math.pi
        elseif drift_angle < -math.pi then
            drift_angle = drift_angle + 2 * math.pi
        end

        drift_angle = math.abs(math.deg(drift_angle))
    end

    
    ui.pushDWriteFont('Montserrat:\\Fonts')
    local drift_angle_rounded = math.min(math.floor(drift_angle), 99)
    local drift_angle_text = string.format("%02d°", drift_angle_rounded)
    local text_size_angle = 43 * hud_scale

    
    local text_color = drift_angle_rounded > 75 and rgbm(1, 0, 0, 1) or colors.WHITE

    
    local text_pos_angle = vec2(circle_center.x - 37 * hud_scale, circle_center.y - 25 * hud_scale)
    ui.dwriteDrawText(drift_angle_text, text_size_angle, text_pos_angle, text_color)
    ui.popDWriteFont()

    
    ui.pushDWriteFont('Montserrat:\\Fonts')
    local timer_text = string.format("%.1f", currentTime)
    local text_size_timer = 84 * hud_scale

    
    local timer_value = tonumber(timer_text) or 0

    
    local timer_x_offset = (timer_value >= 100) and (20 * hud_scale) or (50 * hud_scale)

    
    local text_pos_timer = vec2(
        panel_pos.x + timer_x_offset,
        panel_pos.y + 20 * hud_scale
    )
    ui.dwriteDrawText(timer_text, text_size_timer, text_pos_timer, colors.WHITE)
    ui.popDWriteFont()

    
    local start_gate = gates[1]  
    if start_gate and not LocalScoring.isDriftStarted() then
        local distance_to_start = vec3.distance(my_car.position, start_gate.position)
        is_near_start_gate = distance_to_start < 15
        is_stationary = my_car.speedKmh < 0.1

        
        show_traffic_light = is_near_start_gate or (traffic_light_started and traffic_light_state == 4 and green_light_timer > 0)

        
        if show_traffic_light then
            local traffic_light_side = 'left'  
            local traffic_light_size = vec2(80 * hud_scale, 300 * hud_scale)

            
            local traffic_light_pos = vec2(0, window_height / 2 - traffic_light_size.y / 2)
            if traffic_light_side == 'left' then
                traffic_light_pos.x = 50 * hud_scale
            elseif traffic_light_side == 'right' then
                traffic_light_pos.x = window_width - 50 * hud_scale - traffic_light_size.x
            end

            
            ui.drawRectFilled(traffic_light_pos, traffic_light_pos + traffic_light_size, colors.BLACK, 10 * hud_scale)

            
            local light_radius = 30 * hud_scale
            local light_spacing = 13 * hud_scale
            local light_positions = {}

            
            for i = 1, 4 do
                local y = traffic_light_pos.y + (i - 1) * (light_radius * 2 + light_spacing) + light_spacing
                local center = vec2(traffic_light_pos.x + traffic_light_size.x / 2, y + light_radius)
                table.insert(light_positions, center)
            end

            
            for i, center in ipairs(light_positions) do
                ui.drawCircleFilled(center, light_radius, colors.DARK_GRAY, 64)
            end

            
            local light_colors = {}
            for i = 1, 4 do
                if traffic_light_state < 4 then
                    if i <= traffic_light_state then
                        light_colors[i] = colors.RED
                    end
                else
                    if i == 4 then
                        light_colors[i] = colors.GREEN
                    end
                end
            end

            
            for i = 1, 4 do
                if light_animations[i].active then
                    light_animations[i].alpha = math.min(light_animations[i].alpha + ui.deltaTime() * 2, 1)
                    light_animations[i].scale = math.min(light_animations[i].scale + ui.deltaTime() * 2, 1)
                    if light_animations[i].alpha >= 1 and light_animations[i].scale >= 1 then
                        light_animations[i].active = false
                    end
                end
            end

            
            for i, center in ipairs(light_positions) do
                local color
                if isYellowBlinking then
                    color = colors.YELLOW  
                else
                    if traffic_light_state < 4 then
                        if i <= traffic_light_state then
                            color = colors.RED
                        end
                    elseif traffic_light_state == 4 then
                        if i == 4 then
                            color = colors.GREEN
                        end
                    end
                end

                if color then
                    local anim = light_animations[i]
                    local alpha = anim and anim.alpha or 1
                    local scale = anim and anim.scale or 1
                    local draw_color = rgbm(color.r, color.g, color.b, alpha)
                    local draw_radius = light_radius * scale
                    drawBlurredCircle(center, draw_radius, draw_color, 15)
                end
            end
        end
    end
end


function DriftHUD.setScale(scale)
    hud_scale = scale
end


function DriftHUD.getScale()
    return hud_scale
end


function DriftHUD.updateTime(dt)
    if LocalScoring.isDriftStarted() and not LocalScoring.isDriftFinished() then
        currentTime = currentTime + dt
    elseif not LocalScoring.isDriftStarted() then
        currentTime = 0
    end
end


function DriftHUD.getTrafficLightState()
    return traffic_light_state
end


function DriftHUD.resetTrafficLight()
    traffic_light_timer = 0
    traffic_light_state = 0
    traffic_light_started = false
    show_traffic_light = false
    for i = 1, 4 do
        light_animations[i].active = false
        light_animations[i].alpha = 0
        light_animations[i].scale = 0.5
    end
    greenLightTimer = 0
    isYellowBlinking = false
    blinkTimer = 0
end

return DriftHUD
