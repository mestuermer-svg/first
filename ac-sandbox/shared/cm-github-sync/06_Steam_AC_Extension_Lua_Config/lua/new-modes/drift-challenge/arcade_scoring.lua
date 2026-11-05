local ArcadeScoring = {}
local Settings = require('settings')
local LocalGates = require('local_gates')
local LogoDisplay = require('logo_display')

local LocalScoring

local settings = ac.INIConfig.scriptSettings():mapSection('SETTINGS', {
  ENABLE_ARCADE_SCORING = false
})

local arcadeScore = 0
local isScoring = false
local startTime = 0
local scoreMultiplier = 1
local multiplierTimer = 0
local multiplierDuration = 5
local lastTransitionCount = 0

local hud_scale = 1.0
local multiplierFill = 0
local animationSpeed = 2

local colors = {
    GRAY = rgbm(0.2, 0.2, 0.2, 0),
    LIGHT_GREEN = rgbm(0, 1, 0, 1),
    YELLOW = rgbm(1, 1, 0, 1),
    RED = rgbm(1, 0, 0, 1),
    GREEN = rgbm(0, 1, 0, 1),
    WHITE = rgbm(1, 1, 1, 1),
    BLACK = rgbm(0, 0, 0, 0),
    TRANSPARENT = rgbm(0, 0, 0, 0),
    NEON_RED = rgbm(1, 0, 0, 0.9),
    DARK_GRAY = rgbm(0.1, 0.1, 0.1, 0.7),
    NEON_BLUE = rgbm(0, 0.5, 1, 1),
}

local panel_size = vec2(400, 120) * hud_scale
local corner_radius = 20 * hud_scale

local initialMultiplier = 1
local initialTimer = 0

local scoreAnimation = {
    scale = 1,
    targetScale = 1,
    scaleSpeed = 5,
    glowAlpha = 0,
    glowTargetAlpha = 0,
    glowSpeed = 5,
}

local particles = {}

local driftRanks = {
    {score = 0, name = ""},
}

local isDriftMissionOpen = false

local function shouldDisplayArcadeScoring()
    return settings.ENABLE_ARCADE_SCORING and 
           LocalScoring.isDriftActive() and
           not LocalScoring.isDriftFailed() and
           not isDriftMissionOpen
end

function ArcadeScoring.setDriftMissionOpen(isOpen)
    isDriftMissionOpen = isOpen
end

function ArcadeScoring.reset()
    arcadeScore = 0
    isScoring = false
    startTime = 0
    scoreMultiplier = 1
    multiplierTimer = 0
    lastTransitionCount = 0
    multiplierFill = 0
    initialMultiplier = 1
    initialTimer = 0
    scoreAnimation.scale = 1
    scoreAnimation.targetScale = 1
    scoreAnimation.glowAlpha = 0
    scoreAnimation.glowTargetAlpha = 0
    particles = {}

    local gates = LocalGates.getGates()
    for _, gate in ipairs(gates) do
        gate.scoredForArcade = false
    end
end

function ArcadeScoring.startScoring()
    isScoring = true
    startTime = os.clock()
end

function ArcadeScoring.stopScoring()
    isScoring = false
end

function ArcadeScoring.init(localScoringModule)
    LocalScoring = localScoringModule
end

function ArcadeScoring.update(dt, car, transitionCount)
    if not isScoring or not settings.ENABLE_ARCADE_SCORING or not LocalScoring then
        return
    end

    local speed = car.speedKmh
    local driftAngle = LocalScoring.getAverageDriftAngle()
    local passedGates = LocalScoring.getPassedGateIndices()

    local baseScore = speed * 0.1 + driftAngle * 0.5

    local gates = LocalGates.getGates()
    for i, gate in ipairs(gates) do
        if passedGates[i] and not gate.scoredForArcade then
            initialMultiplier = initialMultiplier + 1
            multiplierTimer = multiplierDuration
            initialTimer = multiplierDuration
            gate.scoredForArcade = true

            multiplierFill = 1.0

            scoreAnimation.targetScale = 1.2
            scoreAnimation.glowTargetAlpha = 1

            table.insert(particles, {
                position = nil,
                time = 0,
                duration = 1,
            })
        end
    end

    local finalScore = baseScore * scoreMultiplier

    arcadeScore = arcadeScore + finalScore * dt

    if multiplierTimer > 0 then
        multiplierTimer = multiplierTimer - dt
        if multiplierTimer <= 0 then
            multiplierTimer = 0
            initialMultiplier = 1
            scoreMultiplier = 1
            multiplierFill = 0
        else
            multiplierFill = multiplierTimer / initialTimer
            scoreMultiplier = initialMultiplier
        end
    end

    if scoreAnimation.scale > 1 then
        scoreAnimation.scale = scoreAnimation.scale - dt * scoreAnimation.scaleSpeed
        if scoreAnimation.scale < 1 then
            scoreAnimation.scale = 1
        end
    end

    if scoreAnimation.glowAlpha > 0 then
        scoreAnimation.glowAlpha = scoreAnimation.glowAlpha - dt * scoreAnimation.glowSpeed
        if scoreAnimation.glowAlpha < 0 then
            scoreAnimation.glowAlpha = 0
        end
    end

    for i = #particles, 1, -1 do
        local p = particles[i]
        p.time = p.time + dt
        if p.time >= p.duration then
            table.remove(particles, i)
        end
    end
end

function ArcadeScoring.draw()
    if not shouldDisplayArcadeScoring() then
        return
    end

    local dt = ui.deltaTime()
    local screenWidth = ui.windowSize().x
    local screenHeight = ui.windowSize().y

    local panel_pos = vec2(20, screenHeight - panel_size.y - 20)
    local score_pos = vec2(panel_pos.x + panel_size.x / 2, panel_pos.y + 35 * hud_scale)

    ui.drawRectFilled(panel_pos, panel_pos + panel_size, colors.DARK_GRAY, corner_radius)

    local border_width = 5 * hud_scale
    local fill_color = colors.NEON_RED
    local unfill_color = colors.GRAY

    local function roundedRectPath(pos, size, radius)
        ui.pathArcTo(pos + vec2(radius, radius), radius, math.pi, math.pi * 1.5, 10)
        ui.pathLineTo(pos + vec2(size.x - radius, 0))
        ui.pathArcTo(pos + vec2(size.x - radius, radius), radius, math.pi * 1.5, math.pi * 2, 10)
        ui.pathLineTo(pos + vec2(size.x, size.y - radius))
        ui.pathArcTo(pos + vec2(size.x - radius, size.y - radius), radius, 0, math.pi * 0.5, 10)
        ui.pathLineTo(pos + vec2(radius, size.y))
        ui.pathArcTo(pos + vec2(radius, size.y - radius), radius, math.pi * 0.5, math.pi, 10)
        ui.pathLineTo(pos + vec2(0, radius))
    end

    roundedRectPath(panel_pos, panel_size, corner_radius)
    ui.pathStroke(unfill_color, false, border_width)

    if multiplierFill > 0 then
        ui.pathClear()
        local fill_length = (panel_size.x * 2 + panel_size.y * 2) * multiplierFill
        local current_length = 0

        local function addArc(center, radius, start_angle, end_angle)
            local arc_length = radius * math.abs(end_angle - start_angle)
            if current_length + arc_length > fill_length then
                local angle = start_angle + (end_angle - start_angle) * (fill_length - current_length) / arc_length
                ui.pathArcTo(center, radius, start_angle, angle, 10)
                return true
            else
                ui.pathArcTo(center, radius, start_angle, end_angle, 10)
                current_length = current_length + arc_length
                return false
            end
        end

        local function addLine(start, end_pos)
            local line_length = vec2.distance(start, end_pos)
            if current_length + line_length > fill_length then
                local t = (fill_length - current_length) / line_length
                ui.pathLineTo(vec2.lerp(start, end_pos, t))
                return true
            else
                ui.pathLineTo(end_pos)
                current_length = current_length + line_length
                return false
            end
        end

        if addArc(panel_pos + vec2(corner_radius, corner_radius), corner_radius, math.pi, math.pi * 1.5) then goto draw_fill end
        if addLine(panel_pos + vec2(corner_radius, 0), panel_pos + vec2(panel_size.x - corner_radius, 0)) then goto draw_fill end
        if addArc(panel_pos + vec2(panel_size.x - corner_radius, corner_radius), corner_radius, math.pi * 1.5, math.pi * 2) then goto draw_fill end
        if addLine(panel_pos + vec2(panel_size.x, corner_radius), panel_pos + vec2(panel_size.x, panel_size.y - corner_radius)) then goto draw_fill end
        if addArc(panel_pos + vec2(panel_size.x - corner_radius, panel_size.y - corner_radius), corner_radius, 0, math.pi * 0.5) then goto draw_fill end
        if addLine(panel_pos + vec2(panel_size.x - corner_radius, panel_size.y), panel_pos + vec2(corner_radius, panel_size.y)) then goto draw_fill end
        if addArc(panel_pos + vec2(corner_radius, panel_size.y - corner_radius), corner_radius, math.pi * 0.5, math.pi) then goto draw_fill end
        addLine(panel_pos + vec2(0, panel_size.y - corner_radius), panel_pos + vec2(0, corner_radius))

        ::draw_fill::
        ui.pathStroke(fill_color, false, border_width)
    end

    local fontSize = 60 * hud_scale * scoreAnimation.scale
    local scoreText = string.format("%d", math.floor(arcadeScore))
    ui.pushDWriteFont('Montserrat:\\Fonts')
    local textSize = ui.measureDWriteText(scoreText, fontSize)
    
    local maxYOffset = panel_size.y / 0
    local yOffset = math.min(textSize.y / 2, maxYOffset)
    
    local posX = score_pos.x - textSize.x / 2
    local posY = score_pos.y - yOffset * (1.3 - scoreAnimation.scale)

    if scoreAnimation.glowAlpha > 0 then
        local glowColor = rgbm(0.2, 0.6, 1, scoreAnimation.glowAlpha)
        ui.dwriteDrawText(scoreText, fontSize, vec2(posX, posY), glowColor)
    end

    ui.dwriteDrawText(scoreText, fontSize, vec2(posX + 2, posY + 2), colors.BLACK)
    ui.dwriteDrawText(scoreText, fontSize, vec2(posX, posY), colors.WHITE)

    local multiplierText = string.format("x%.1f", scoreMultiplier)
    local multiplierSize = 30 * hud_scale
    local multiplierMeasure = ui.measureDWriteText(multiplierText, multiplierSize)
    local multiplierPosX = panel_pos.x + panel_size.x - multiplierMeasure.x - 20 * hud_scale
    local multiplierPosY = panel_pos.y + 10 * hud_scale

    local multiplier_bg_size = vec2(multiplierMeasure.x + 20 * hud_scale, multiplierSize + 10 * hud_scale)
    local multiplier_bg_pos = vec2(multiplierPosX - 10 * hud_scale, multiplierPosY - 5 * hud_scale)
    ui.drawRectFilled(multiplier_bg_pos, multiplier_bg_pos + multiplier_bg_size, colors.NEON_RED, 10 * hud_scale)

    ui.dwriteDrawText(multiplierText, multiplierSize, vec2(multiplierPosX, multiplierPosY - 3 * hud_scale), colors.WHITE)

    ui.popDWriteFont()
end

function ArcadeScoring.setScale(scale)
    hud_scale = scale
    panel_size = vec2(400, 140) * hud_scale
    corner_radius = 20 * hud_scale
end

function ArcadeScoring.getScore()
    return arcadeScore
end

return ArcadeScoring
