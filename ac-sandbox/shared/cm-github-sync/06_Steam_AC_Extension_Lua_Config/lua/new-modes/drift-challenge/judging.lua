local Judging = {}
local Judges = require('judges')
local Settings = require('settings')
local ArcadeScoring = require('arcade_scoring')
local LocalGates = require('local_gates')

local LocalScoring

local judgesScores = nil
local showJudgesScores = false
local scoreDisplayDuration = 20
local scoreDisplayTimer = 0
local arcadeScore = 0

local lineDisplayInterval = 1.0
local lastLineDelay = 2.0

local currentLineIndex = 0
local lineDisplayTimer = 0


local hud_scale = 1.0


local function drawTextWithShadow(text, size, pos, color, shadowColor, shadowOffset)
    shadowOffset = shadowOffset or vec2(1, 1)
    ui.dwriteDrawText(text, size, vec2(pos.x + shadowOffset.x, pos.y + shadowOffset.y), shadowColor)
    ui.dwriteDrawText(text, size, pos, color)
end

local compactLines = {
    {"Finish!", ""},
    {"Arcade score:", 0},
    {"Your Time:", "N/A"},
    {"Entry Speed:", "N/A"},
    {"Peak Angle:", "N/A"},
    {"Average Angle:", "N/A"},
    {"Judges' decision:", "N/A"}
}


local function getPercentageColor(percentage)
    if percentage >= 90 then
        return rgbm(0, 1, 0, 1)  
    elseif percentage >= 70 then
        return rgbm(1, 1, 0, 1)  
    elseif percentage >= 50 then
        return rgbm(1, 0.5, 0, 1)  
    else
        return rgbm(1, 0, 0, 1)  
    end
end


local function getMissedClipsColor(count)
    local t = math.min((count - 1) / 4, 1)  
    return rgbm(1,           
              1 * (1 - t),   
              0,             
              1)             
end

function Judging.init(localScoringModule)
    LocalScoring = localScoringModule
end


function Judging.setScale(scale)
    hud_scale = scale or 1.0
end

function Judging.calculateScores()
    local entrySpeed = LocalScoring.getEntrySpeed()
    local averageAngle = LocalScoring.getAverageDriftAngle()
    local driftDuration = LocalScoring.getDriftDuration()
    local noGoZonesPassed = LocalScoring.getNoGoZonesPassed()
    local trajectoryGatesPassed = LocalScoring.getTrajectoryGatesPassed()
    local passed_gates = LocalScoring.getPassedGateIndices()

    judgesScores = Judges.getScores(entrySpeed, averageAngle, driftDuration, noGoZonesPassed, trajectoryGatesPassed, passed_gates)
    judgesScores.details.entrySpeed = entrySpeed
    judgesScores.details.peakAngle = LocalScoring.getPeakAngle()
    judgesScores.details.totalTime = LocalScoring.getTotalTime()
    
    
    local gateAnglesLines = {""}  
    local currentLine = 1
    local gatesInLine = 0
    local gates = LocalGates.getGates()
    local isFirstLine = true  
    
    for i = 2, #gates - 1 do
        local gate = gates[i]
        if passed_gates[i] and passed_gates[i].angle then
            if gatesInLine >= (isFirstLine and 4 or 5) then  
                currentLine = currentLine + 1
                gateAnglesLines[currentLine] = ""
                gatesInLine = 0
                isFirstLine = false
            end
            
            if gatesInLine > 0 then
                gateAnglesLines[currentLine] = gateAnglesLines[currentLine] .. " "
            end
            
            gateAnglesLines[currentLine] = gateAnglesLines[currentLine] .. 
                string.format("%d:%d°", i-1, passed_gates[i].angle)
            gatesInLine = gatesInLine + 1
        end
    end
    judgesScores.details.gateAnglesLines = gateAnglesLines

    arcadeScore = ArcadeScoring.getScore()
    showJudgesScores = true
    scoreDisplayTimer = scoreDisplayDuration
    compactLines[2][2] = arcadeScore and math.floor(arcadeScore) or 0
    compactLines[3][2] = judgesScores.details.totalTime and string.format("%.2f s", judgesScores.details.totalTime) or "N/A"
    compactLines[4][2] = judgesScores.details.entrySpeed and string.format("%.2f km/h", judgesScores.details.entrySpeed) or "N/A"
    compactLines[5][2] = judgesScores.details.peakAngle and string.format("%.2f°", judgesScores.details.peakAngle) or "N/A"
    compactLines[6][2] = judgesScores.details.averageAngle and string.format("%.2f°", judgesScores.details.averageAngle) or "N/A"
    compactLines[7][2] = judgesScores.total or "N/A"
    currentLineIndex = 0
    lineDisplayTimer = 0
end

function Judging.update(dt)
    if showJudgesScores then
        scoreDisplayTimer = scoreDisplayTimer - dt
        if scoreDisplayTimer <= 0 then
            showJudgesScores = false
        else
            if currentLineIndex < #compactLines then
                lineDisplayTimer = lineDisplayTimer + dt
                local currentInterval = lineDisplayInterval
                if currentLineIndex == #compactLines - 1 then
                    currentInterval = lastLineDelay
                end
                if lineDisplayTimer >= currentInterval then
                    currentLineIndex = currentLineIndex + 1
                    lineDisplayTimer = 0
                end
            end
        end
    end
end

function Judging.draw()
    if showJudgesScores and judgesScores then
        local screenWidth = ui.windowWidth()
        local screenHeight = ui.windowHeight()
        ui.pushDWriteFont('Montserrat:\\Fonts')

        
        local panel_size = vec2(600, 400)
        if hud_scale then
            panel_size = panel_size * hud_scale
        end
        local panel_pos = vec2(
            (screenWidth - panel_size.x) / 2,
            (screenHeight - panel_size.y) / 2.7 * 0.85  
        )
        local corner_radius = 20
        if hud_scale then
            corner_radius = corner_radius * hud_scale
        end

        
        ui.drawRectFilled(panel_pos, panel_pos + panel_size, rgbm(0, 0, 0, 0.0), corner_radius)

        local function getScoreColor(score)
            if score < 75 then
                local t = score / 75
                return rgbm(1 - t * 0.5, t * 0.5, 0, 1)
            else
                local t = (score - 75) / 25
                return rgbm(0.5 - t * 0.5, 0.5 + t * 0.5, 0, 1)
            end
        end

        if Settings.showMainResultsBlock == 1 and currentLineIndex == #compactLines then  
            local color = rgbm(1, 1, 1, 1)
            local shadowColor = rgbm(0, 0, 0, 1)
            local fontSize = 25
            local lineHeight = fontSize * 1.5
            local yPos = screenHeight * 0.79 * 0.85

            local function drawLine(text, value, valueColor, percentValue)
                local textWidth = ui.measureDWriteText(text, fontSize).x
                local valueWidth = ui.measureDWriteText(tostring(value), fontSize).x
                local percentWidth = percentValue and ui.measureDWriteText(tostring(percentValue), fontSize).x or 0
                local totalWidth = textWidth + valueWidth + percentWidth + 20
                
                local startX = (screenWidth - totalWidth) / 2
                drawTextWithShadow(text, fontSize, vec2(startX, yPos), color, shadowColor)
                if value ~= "" then
                    if percentValue then
                        
                        drawTextWithShadow(tostring(value), fontSize, vec2(startX + textWidth + 20, yPos), color, shadowColor)
                        local baseWidth = ui.measureDWriteText(value, fontSize).x
                        
                        local percent = percentValue:sub(1, -2)  
                        local bracket = ")"
                        drawTextWithShadow(percent, fontSize, vec2(startX + textWidth + 20 + baseWidth, yPos), valueColor, shadowColor)
                        local percentWidth = ui.measureDWriteText(percent, fontSize).x
                        drawTextWithShadow(bracket, fontSize, vec2(startX + textWidth + 20 + baseWidth + percentWidth, yPos), color, shadowColor)
                    else
                        
                        local textColor = valueColor or color
                        drawTextWithShadow(tostring(value), fontSize, vec2(startX + textWidth + 20, yPos), textColor, shadowColor)
                    end
                end
                yPos = yPos + lineHeight
            end

            local mainLines = {
                {"  Entry Speed:", judgesScores.details.entrySpeedScore and string.format("%.2f (", judgesScores.details.entrySpeedScore),
                    getPercentageColor((judgesScores.details.entrySpeedScore / 10) * 100),
                    string.format("%.0f%%", (judgesScores.details.entrySpeedScore / 10) * 100) .. ")"},
                {"  Style:", judgesScores.details.angleScore and string.format("%.2f (", judgesScores.details.angleScore),
                    getPercentageColor((judgesScores.details.angleScore / 20) * 100),
                    string.format("%.0f%%", (judgesScores.details.angleScore / 20) * 100) .. ")"},
                {"  Drift Zones Score:", judgesScores.details.gatesScore and string.format("%.2f (", judgesScores.details.gatesScore),
                    getPercentageColor((judgesScores.details.gatesScore / 75) * 100),
                    string.format("%.0f%%", (judgesScores.details.gatesScore / 75) * 100) .. ")"},
            }

            
            local missedClips = 0
            local gates = LocalGates.getGates()
            local passed_gates = LocalScoring.getPassedGateIndices()
            for i = 2, #gates - 1 do  
                if not passed_gates[i] then
                    missedClips = missedClips + 1
                end
            end
            
            
            if missedClips > 0 then
                table.insert(mainLines, {
                    "  Zones Missed:", 
                    tostring(missedClips),
                    getMissedClipsColor(missedClips)
                })
            end

            
            table.insert(mainLines, {"  No Go Zone Penalty:", judgesScores.details.noGoZonePenalty and string.format("%.2f", judgesScores.details.noGoZonePenalty)})
            table.insert(mainLines, {"  Trajectory Penalty:", judgesScores.details.trajectoryGatePenalty and string.format("%.2f", judgesScores.details.trajectoryGatePenalty)})

            for i, line in ipairs(mainLines) do
                if i == #mainLines then
                    ui.pushDWriteFont('Montserrat:\\Fonts;Weight=Bold')
                end
                drawLine(line[1], line[2], line[3], line[4])
                if i == #mainLines then
                    ui.popDWriteFont()
                end
            end
        end

        local compactFontSize = 30
        local compactLineHeight = compactFontSize * 1.5
        local compactYPos = panel_pos.y + 50 * hud_scale  

        for i, line in ipairs(compactLines) do
            if i <= currentLineIndex then
                local text, value = line[1], line[2]
                local textWidth = ui.measureDWriteText(text, compactFontSize).x
                local valueWidth = ui.measureDWriteText(tostring(value), compactFontSize).x
                local totalWidth = textWidth + valueWidth + 20
                local startX = (screenWidth - totalWidth) / 2
                drawTextWithShadow(text, compactFontSize, vec2(startX, compactYPos), rgbm(1, 1, 1, 1), rgbm(0, 0, 0, 1))
                if value ~= "" then
                    local valueColor = i == #compactLines and getScoreColor(judgesScores.total or 0) or rgbm(1, 1, 1, 1)
                    drawTextWithShadow(tostring(value), compactFontSize, vec2(startX + textWidth + 20, compactYPos), valueColor, rgbm(0, 0, 0, 1))
                end
                compactYPos = compactYPos + compactLineHeight
            end
        end
        ui.popDWriteFont()
    end
end

function Judging.resetLineDisplay()
    lineDisplayTimer = 0
    currentLineIndex = 0
end

function Judging.getScores()
    return judgesScores
end

function Judging.isShowingScores()
    return showJudgesScores
end

function Judging.getTotalScore()
    return judgesScores and judgesScores.total or 0
end

function Judging.hideScores()
    showJudgesScores = false
    scoreDisplayTimer = 0
    currentLineIndex = 0
end

return Judging
