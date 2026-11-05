-- logo_display.lua

local LogoDisplay = {}
local currentTrack = nil
local showInterface = true
local LocalScoring  
local LocalGates = require('local_gates')


local getBackToStartButton = ac.ControlButton('__APP_GET_BACK_TO_START')
local restartSessionButton = ac.ControlButton('__APP_RESTART_SESSION')
local seeDriftTrackButton = ac.ControlButton('__APP_SEE_DRIFT_TRACK')


local colors = {
    BLACK = rgbm(0, 0, 0, 0.5),
    WHITE = rgbm(1, 1, 1, 1),
    GREEN = rgbm(0, 1, 0, 1),
    RED = rgbm(1, 0, 0, 1),
}

local hud_scale = 1.0  


function LogoDisplay.init(localScoringModule)
    LocalScoring = localScoringModule
end


function LogoDisplay.setCurrentTrack(track)
    currentTrack = track
end


function LogoDisplay.draw(isDriftMissionOpen)
    local window_size = ui.windowSize()
    local window_width, window_height = window_size.x, window_size.y

    if isDriftMissionOpen then
        
        local panel_size = vec2(1600, 800) * hud_scale  
        local panel_pos = vec2(
            (window_width - panel_size.x) / 2,
            (window_height - panel_size.y) / 2  
        )
        local corner_radius = 20 * hud_scale

        
        local image_path
        local showCreateTaskMessage = false
        local messageText = ""
        
        if currentTrack then
            local ac_root = ac.getFolder(ac.FolderID.Root)
            local mod_path = ac_root .. '/extension/lua/new-modes/drift-challenge/'
            local track_image = mod_path .. 'tracks/' .. currentTrack .. '.png'
            local fileExists = io.fileExists(track_image)
            
            if fileExists then
                image_path = track_image
            else
                image_path = mod_path .. 'assets/blank.png'
                showCreateTaskMessage = true
                messageText = string.format(
                    "Create a custom drift task image for '%s'\nby putting %s.png in:\n/assettocorsa/extension/lua/new-modes/drift-challenge/tracks/\nor use Drift Task Map Editor to Generate it", 
                    currentTrack, 
                    currentTrack
                )
            end
        else
            local mod_path = ac.getFolder(ac.FolderID.ExtCfgLua) .. '/new-modes/drift-challenge/'
            image_path = mod_path .. 'assets/blank.png'
        end

        
        ui.drawRectFilled(panel_pos, panel_pos + panel_size, colors.BLACK, corner_radius)

        
        local text_width = panel_size.x * 0.4  
        local image_width = panel_size.x * 0.6  

        
        ui.pushDWriteFont('Montserrat:\\Fonts')
        
        local trackData = LocalGates.getTrackData(currentTrack)
        if trackData then
            
            local normalGatesCount = 0
            local ozGatesCount = 0
            local noGoZonesCount = #(trackData.noGoZones or {})
            local gateMultipliers = {}  
            
            for i, gate in ipairs(trackData.gates) do
                if gate.type == "normal" then
                    normalGatesCount = normalGatesCount + 1
                    if gate.score_multiplier and gate.score_multiplier ~= 1.0 then
                        table.insert(gateMultipliers, {
                            index = normalGatesCount,
                            multiplier = gate.score_multiplier
                        })
                    end
                elseif gate.type == "OZ" then
                    ozGatesCount = ozGatesCount + 1
                end
            end

            
            local fontSize = 35
            local titleFontSize = fontSize * 1.7
            
            
            local trackTitle = currentTrack:gsub("_", " "):gsub("^%l", string.upper)
            local textPos = vec2(panel_pos.x + 30, panel_pos.y + 30)
            
            ui.dwriteDrawText(trackTitle, titleFontSize, vec2(textPos.x + 1, textPos.y + 1), rgbm(0, 0, 0, 1))
            ui.dwriteDrawText(trackTitle, titleFontSize, textPos, rgbm(1, 1, 1, 1))

            
            textPos.y = textPos.y + titleFontSize + 50
            ui.dwriteDrawText("Drift Task:", titleFontSize, vec2(textPos.x + 1, textPos.y + 1), rgbm(0, 0, 0, 1))
            ui.dwriteDrawText("Drift Task:", titleFontSize, textPos, rgbm(1, 1, 1, 1))

            
            textPos.y = textPos.y + titleFontSize + 10

            
            local tgCounter = 0  
            local displayedLines = 0  
            local maxLines = 10  
            
            
            local allZones = {}
            local zoneGroups = {}  
            
            
            for i = 2, #trackData.gates - 1 do
                local gate = trackData.gates[i]
                if gate.type == "normal" then
                    tgCounter = tgCounter + 1
                    
                    
                    local groupKey = nil
                    if gate.score_multiplier and gate.score_multiplier > 1.09 then
                        if gate.target_angle and gate.target_angle > 49 then
                            
                            groupKey = string.format("%.1fx_%d", gate.score_multiplier, math.floor(gate.target_angle))
                        else
                            
                            groupKey = string.format("%.1fx", gate.score_multiplier)
                        end
                    elseif gate.target_angle and gate.target_angle > 49 then
                        
                        groupKey = string.format(">%d", math.floor(gate.target_angle))
                    end
                    
                    if groupKey then
                        zoneGroups[groupKey] = zoneGroups[groupKey] or {
                            numbers = {},
                            multiplier = gate.score_multiplier,
                            angle = gate.target_angle and gate.target_angle > 49 and gate.target_angle or nil
                        }
                        table.insert(zoneGroups[groupKey].numbers, tgCounter)
                    end
                end
            end
            
            
            for _, group in pairs(zoneGroups) do
                table.sort(group.numbers)  
                local text
                if #group.numbers == 1 then
                    
                    if group.multiplier and group.multiplier > 1.09 and group.angle then
                        text = string.format("TG-%d: %.1fx >%d°", 
                            group.numbers[1], group.multiplier, math.floor(group.angle))
                    elseif group.multiplier and group.multiplier > 1.09 then
                        text = string.format("TG-%d: %.1fx", 
                            group.numbers[1], group.multiplier)
                    else
                        text = string.format("TG-%d: >%d°", 
                            group.numbers[1], math.floor(group.angle))
                    end
                else
                    
                    if group.multiplier and group.multiplier > 1.09 and group.angle then
                        text = string.format("TG-%d,%d: %.1fx >%d°", 
                            group.numbers[1], group.numbers[#group.numbers], 
                            group.multiplier, math.floor(group.angle))
                    elseif group.multiplier and group.multiplier > 1.09 then
                        text = string.format("TG-%d,%d: %.1fx", 
                            group.numbers[1], group.numbers[#group.numbers], 
                            group.multiplier)
                    else
                        text = string.format("TG-%d,%d: >%d°", 
                            group.numbers[1], group.numbers[#group.numbers], 
                            math.floor(group.angle))
                    end
                end
                table.insert(allZones, {number = group.numbers[1], text = text})
            end
            
            
            table.sort(allZones, function(a, b) 
                return a.number < b.number
            end)
            
           
            for _, zone in ipairs(allZones) do
                if displayedLines >= maxLines then break end
                
                ui.dwriteDrawText(zone.text, fontSize, vec2(textPos.x + 1, textPos.y + 1), rgbm(0, 0, 0, 1))
                ui.dwriteDrawText(zone.text, fontSize, textPos, rgbm(1, 1, 1, 1))
                textPos.y = textPos.y + fontSize + 5
                displayedLines = displayedLines + 1
            end

            
            if displayedLines < maxLines then
                
                local normalGatesWithDefaultMultiplier = normalGatesCount - #gateMultipliers
                if normalGatesWithDefaultMultiplier > 0 and displayedLines < maxLines then
                    local text = string.format("TG Zones: 1.0x (%d Zone%s)\n", 
                        normalGatesWithDefaultMultiplier, 
                        normalGatesWithDefaultMultiplier > 1 and "s" or "")
                    ui.dwriteDrawText(text, fontSize, vec2(textPos.x + 1, textPos.y + 1), rgbm(0, 0, 0, 1))
                    ui.dwriteDrawText(text, fontSize, textPos, rgbm(1, 1, 1, 1))
                    textPos.y = textPos.y + fontSize + 5
                    displayedLines = displayedLines + 1
                end

                if ozGatesCount > 0 and displayedLines < maxLines then
                    local ozText = string.format("OZ Zones: %d Zone%s\n", 
                        ozGatesCount, 
                        ozGatesCount > 1 and "s" or "")
                    ui.dwriteDrawText(ozText, fontSize, vec2(textPos.x + 1, textPos.y + 1), rgbm(0, 0, 0, 1))
                    ui.dwriteDrawText(ozText, fontSize, textPos, rgbm(1, 1, 1, 1))
                    textPos.y = textPos.y + fontSize + 5
                    displayedLines = displayedLines + 1
                end

                if noGoZonesCount > 0 and displayedLines < maxLines then
                    local ngText = "No Go: -10 Points"
                    local restText = string.format(" (%d Zone%s)", noGoZonesCount, noGoZonesCount > 1 and "s" or "")
                    
                    ui.dwriteDrawText(ngText, fontSize, vec2(textPos.x + 1, textPos.y + 1), rgbm(0, 0, 0, 1))
                    ui.dwriteDrawText(ngText, fontSize, textPos, rgbm(1, 0.3, 0.3, 1))
                    
                    local ngWidth = ui.measureDWriteText(ngText, fontSize).x
                    ui.dwriteDrawText(restText, fontSize, vec2(textPos.x + ngWidth + 1, textPos.y + 1), rgbm(0, 0, 0, 1))
                    ui.dwriteDrawText(restText, fontSize, textPos + vec2(ngWidth, 0), rgbm(1, 1, 1, 1))
                    
                    textPos.y = textPos.y + fontSize + 25
                    displayedLines = displayedLines + 1
                end
            end

            ui.dwriteDrawText("Max Transitions: " .. (trackData.maxAllowedTransitions or 3), fontSize, vec2(textPos.x + 1, textPos.y + 1), rgbm(0, 0, 0, 1))
            ui.dwriteDrawText("Max Transitions: " .. (trackData.maxAllowedTransitions or 3), fontSize, textPos, rgbm(1, 1, 1, 1))
            textPos.y = textPos.y + fontSize + 5

            if trackData.perfectEntrySpeed then
                local prefix = "Perfect Entry Speed: "
                local speedText = " " .. tostring(trackData.perfectEntrySpeed)  
                local suffix = " km/h"
                
                ui.dwriteDrawText(prefix, fontSize, vec2(textPos.x + 1, textPos.y + 1), rgbm(0, 0, 0, 1))
                ui.dwriteDrawText(prefix, fontSize, textPos, rgbm(1, 1, 1, 1))
                
                local prefixWidth = ui.measureDWriteText(prefix, fontSize).x
                ui.dwriteDrawText(speedText, fontSize, vec2(textPos.x + prefixWidth + 1, textPos.y + 1), rgbm(0, 0, 0, 1))
                ui.dwriteDrawText(speedText, fontSize, textPos + vec2(prefixWidth, 0), rgbm(0.5, 1, 0.5, 1))
                
                local speedWidth = ui.measureDWriteText(speedText, fontSize).x
                ui.dwriteDrawText(suffix, fontSize, vec2(textPos.x + prefixWidth + speedWidth + 1, textPos.y + 1), rgbm(0, 0, 0, 1))
                ui.dwriteDrawText(suffix, fontSize, textPos + vec2(prefixWidth + speedWidth, 0), rgbm(1, 1, 1, 1))
            end

            
            textPos.x = panel_pos.x + 30  
            textPos.y = panel_pos.y + panel_size.y - fontSize - 30  
            local maxPointsText = "Maximum Points: "
            ui.dwriteDrawText(maxPointsText, fontSize, vec2(textPos.x + 1, textPos.y + 1), rgbm(0, 0, 0, 1))
            ui.dwriteDrawText(maxPointsText, fontSize, textPos, rgbm(1, 1, 1, 1))
            
            local maxPointsWidth = ui.measureDWriteText(maxPointsText, fontSize).x
            ui.dwriteDrawText(" 100", fontSize, vec2(textPos.x + maxPointsWidth + 1, textPos.y + 1), rgbm(0, 0, 0, 1))
            ui.dwriteDrawText(" 100", fontSize, textPos + vec2(maxPointsWidth, 0), rgbm(0.5, 1, 0.5, 1))
        end
        
        ui.popDWriteFont()

        
        if image_path then
            local image_size_original = ui.imageSize(image_path)
            if image_size_original then
                local image_area = vec2(image_width, panel_size.y - 60)
                local img_aspect = image_size_original.x / image_size_original.y
                local area_aspect = image_area.x / image_area.y
                local final_image_size

                if img_aspect > area_aspect then
                    final_image_size = vec2(image_area.x, image_area.x / img_aspect)
                else
                    final_image_size = vec2(image_area.y * img_aspect, image_area.y)
                end

                local image_pos = vec2(
                    panel_pos.x + text_width,
                    panel_pos.y + 30
                )

                local image_offset = vec2(
                    (image_area.x - final_image_size.x) / 2,
                    0
                )

                ui.drawImage(image_path, 
                    image_pos + image_offset, 
                    image_pos + image_offset + final_image_size, 
                    colors.WHITE
                )
            end
        end

        
        if showCreateTaskMessage then
            local messageSize = 15 * hud_scale
            local messagePos = vec2(
                panel_pos.x + text_width,  
                panel_pos.y + panel_size.y - 100 * hud_scale  
            )
            
            messageText = "  " .. messageText  
            ui.dwriteDrawText(messageText, messageSize, vec2(messagePos.x + 1, messagePos.y + 1), rgbm(0, 0, 0, 1))
            ui.dwriteDrawText(messageText, messageSize, messagePos, rgbm(1, 1, 1, 1))
        end
    end

    
    if not isDriftMissionOpen and not LocalScoring.isDriftActive() then
        local panel_size = vec2(400, 140) * hud_scale
        local panel_pos = vec2(20, window_height - panel_size.y - 20)
        local corner_radius = 20 * hud_scale

        local windowFlags = ui.WindowFlags.NoTitleBar +
                            ui.WindowFlags.NoBackground +
                            ui.WindowFlags.AlwaysAutoResize +
                            ui.WindowFlags.NoSavedSettings

        ui.beginTransparentWindow('LogoDisplayPanel', panel_pos, panel_size, nil, windowFlags)
        ui.drawRectFilled(vec2(0, 0), panel_size, colors.BLACK, corner_radius)

        ui.pushDWriteFont('Montserrat:\\Fonts')
        local fontSize = 18 * hud_scale
        local line_height = fontSize + 4

        local function drawLineWithButton(prefix, button, suffix, pos)
            ui.dwriteDrawText(prefix, fontSize, pos, colors.WHITE)
            local prefix_width = ui.measureDWriteText(prefix, fontSize).x
            
            ui.setCursor(vec2(pos.x + prefix_width + 3 * hud_scale, pos.y - 5 * hud_scale))
            local buttonSize = vec2(70 * hud_scale, line_height + 10 * hud_scale)

            ui.pushStyleColor(ui.StyleColor.Button, rgbm(0.26, 0.59, 0.98, 0))
            ui.pushStyleColor(ui.StyleColor.ButtonHovered, rgbm(0.7, 0, 0, 0.5))

            local buttonText = button == seeDriftTrackButton and "BIND KEY" or 
                              button == restartSessionButton and "BIND KEY" or 
                              button == getBackToStartButton and "BIND KEY"

            local flags = ui.ControlButtonControlFlags.AlterRealConfig
            button:control(buttonSize, flags, buttonText)

            ui.popStyleColor(2)

            local button_width = 60 * hud_scale
            local suffix_pos = vec2(pos.x + prefix_width + button_width + 17 * hud_scale, pos.y)
            ui.dwriteDrawText(suffix, fontSize, suffix_pos, colors.WHITE)
        end

        drawLineWithButton(
            "Press", 
            seeDriftTrackButton, 
            "to see the Drift Task",
            vec2(20 * hud_scale, 20 * hud_scale)
        )
        
        drawLineWithButton(
            "Press", 
            restartSessionButton, 
            "to Restart Session",
            vec2(20 * hud_scale, 60 * hud_scale)
        )
        
        drawLineWithButton(
            "Press", 
            getBackToStartButton, 
            "to Get back to start line",
            vec2(20 * hud_scale, 100 * hud_scale)
        )

        ui.popDWriteFont()
        ui.endTransparentWindow()
    end
end

function LogoDisplay.setScale(scale)
    hud_scale = scale
end

function LogoDisplay.setShowInterface(show)
    showInterface = show
end

function LogoDisplay.resetInterface()
    showInterface = true
end

function LogoDisplay.isInterfaceVisible()
    return showInterface
end

return LogoDisplay
