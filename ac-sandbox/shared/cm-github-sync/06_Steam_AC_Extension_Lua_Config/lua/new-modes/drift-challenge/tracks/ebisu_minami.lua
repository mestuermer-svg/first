local LocalGates = require('local_gates')

return {
    gates = {
        { type = "start", position = vec3(-470.706, -116.495, -120.446), rotation = 226.747, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 6.320}, line_width = 1.00, color_r = 0.90, color_g = 0.90, color_b = 0.90 },
        { type = "normal", position = vec3(-382.993, -127.131, 20.657), rotation = -61.082, pitch = 0.0, roll = 0.0, size = {width = 1.540, length = 8.720}, score_multiplier = 2.00, target_angle = 30, line_width = 1.77, color_r = 0.90, color_g = 0.90, color_b = 0.90 },
        { type = "normal", position = vec3(-287.187, -131.630, 31.816), rotation = 244.090, pitch = 0.0, roll = 0.0, size = {width = 1.040, length = 6.720}, score_multiplier = 1.00, target_angle = 30, line_width = 1.05, color_r = 0.90, color_g = 0.90, color_b = 0.90 },
        { type = "OZ", position = vec3(-277.409, -132.162, 2.154), rotation = 88.425, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 2.500}, score_multiplier = 0.50, target_angle = 30, line_width = 2.44, color_r = 0.71, color_g = 0.71, color_b = 0.71 },
        { type = "OZ", position = vec3(-295.411, -131.056, -11.413), rotation = -10.286, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 2.500}, score_multiplier = 0.50, target_angle = 30, line_width = 2.44, color_r = 0.71, color_g = 0.71, color_b = 0.71 },
        { type = "normal", position = vec3(-351.109, -128.655, 16.895), rotation = 109.226, pitch = 0.0, roll = 0.0, size = {width = 1.540, length = 4.230}, score_multiplier = 1.00, target_angle = 30, line_width = 1.00, color_r = 0.90, color_g = 0.90, color_b = 0.90 },
        { type = "finish", position = vec3(-372.626, -126.629, 3.931), rotation = 206.063, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 8.420}, line_width = 1.00, color_r = 0.90, color_g = 0.90, color_b = 0.90 },
    },
    noGoZones = {
    },
    trajectoryGates = {
    },
    mapSettings = {
        scale = { x = 1.000, y = 1.000 },
        curvature = 0.620,
        rotation = -78.900,
        tension = -0.080,
        mergeDistance = 5.000,
        lineWidth = 60.000,
        startLine = {
            length = 22.500,
            angle = 0.000
        },
        finishLine = {
            length = 22.500,
            angle = 0.000
        }
    },
    squareSettings = {
        {
            index = 1,
            offset = vec2(0.000, 0.000),
            rotation = 316.747,
            size = {width = 40.000, height = 15.000},
            deleted = false
        },
        {
            index = 2,
            offset = vec2(0.000, 0.000),
            rotation = 197.276,
            size = {width = 32.000, height = 12.000},
            deleted = true
        },
        {
            index = 3,
            offset = vec2(0.000, 0.000),
            rotation = 44.575,
            size = {width = 32.000, height = 12.000},
            deleted = true
        },
        {
            index = 4,
            offset = vec2(0.000, 0.000),
            rotation = 112.505,
            size = {width = 12.000, height = 2.000},
            deleted = true
        },
        {
            index = 5,
            offset = vec2(0.000, 0.000),
            rotation = 143.187,
            size = {width = 12.000, height = 2.000},
            deleted = true
        },
        {
            index = 6,
            offset = vec2(55.000, -50.000),
            rotation = -65.900,
            size = {width = 30.000, height = 8.000},
            deleted = false
        },
        {
            index = 7,
            offset = vec2(41.000, 17.000),
            rotation = 92.200,
            size = {width = 30.000, height = 8.000},
            deleted = false
        },
        {
            index = 8,
            offset = vec2(70.000, 22.000),
            rotation = 122.900,
            size = {width = 12.000, height = 2.000},
            deleted = false
        },
        {
            index = 9,
            offset = vec2(37.000, -22.000),
            rotation = 33.600,
            size = {width = 12.000, height = 2.000},
            deleted = false
        },
        {
            index = 10,
            offset = vec2(3.000, 40.000),
            rotation = -46.100,
            size = {width = 22.000, height = 9.000},
            deleted = false
        },
        {
            index = 11,
            offset = vec2(0.000, 0.000),
            rotation = 296.063,
            size = {width = 40.000, height = 15.000},
            deleted = false
        },
    },
    mapTexts = {
        {
            text = "Start",
            position = vec2(-450.520, -40.098)
        },
        {
            text = "Finish",
            position = vec2(-405.780, -66.225)
        },
        {
            text = "TG-1",
            position = vec2(-314.546, -65.190)
        },
        {
            text = "TG-2",
            position = vec2(-297.878, -114.599)
        },
        {
            text = "TG-3",
            position = vec2(-391.452, -87.179)
        },
        {
            text = "OZ-1",
            position = vec2(-340.571, -124.170)
        },
    },
    entrySpeedLine = {
        position = vec3(-427.384, -120.900, -36.203),
        rotation = -24.813,
        length = 15.000
    },
    maxAllowedTransitions = 2,

    startPosition = vec3(-456.214, -118.623, -89.913),
    startRotation = 110.287,
    alternateStartPosition = vec3(-467.320, -116.778, -119.389),
    alternateStartRotation = 46.503,
    perfectEntrySpeed = 105,
    gatesTransparency = {
        normal = 0.5,
        start = 0.0,
        finish = 0.0,
        oz = 1.0,
        noGoZone = 1.0,
        trajectory = 1.0
    }
}