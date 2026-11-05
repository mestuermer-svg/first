local LocalGates = require('local_gates')

return {
    gates = {
        { type = "start", position = vec3(36.249, 67.988, -23.602), rotation = 46.330, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 9.000}, line_width = 1.00, color_r = 0.90, color_g = 0.90, color_b = 0.90 },
        { type = "OZ", position = vec3(85.282, 65.379, 34.484), rotation = 88.345, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 2.020}, score_multiplier = 0.25, target_angle = 30, line_width = 1.00, color_r = 0.90, color_g = 0.90, color_b = 0.90 },
        { type = "OZ", position = vec3(75.121, 65.057, 51.897), rotation = 148.486, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 2.120}, score_multiplier = 0.25, target_angle = 30, line_width = 1.00, color_r = 0.90, color_g = 0.90, color_b = 0.90 },
        { type = "OZ", position = vec3(28.222, 62.015, 32.961), rotation = 2.007, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 2.020}, score_multiplier = 0.25, target_angle = 30, line_width = 1.00, color_r = 0.90, color_g = 0.90, color_b = 0.90 },
        { type = "OZ", position = vec3(-21.081, 61.334, 54.834), rotation = 199.190, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 2.110}, score_multiplier = 0.25, target_angle = 30, line_width = 1.00, color_r = 0.90, color_g = 0.90, color_b = 0.90 },
        { type = "OZ", position = vec3(-31.514, 61.692, 47.434), rotation = 231.345, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 2.020}, score_multiplier = 0.25, target_angle = 30, line_width = 1.00, color_r = 0.90, color_g = 0.90, color_b = 0.90 },
        { type = "OZ", position = vec3(-30.577, 62.096, 26.313), rotation = -53.414, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 2.020}, score_multiplier = 0.25, target_angle = 30, line_width = 1.00, color_r = 0.90, color_g = 0.90, color_b = 0.90 },
        { type = "normal", position = vec3(-14.974, 62.591, 16.491), rotation = 258.461, pitch = 0.0, roll = 0.0, size = {width = 1.430, length = 4.410}, score_multiplier = 0.50, target_angle = 30, line_width = 1.00, color_r = 0.90, color_g = 0.90, color_b = 0.90 },
        { type = "finish", position = vec3(3.824, 63.327, 18.411), rotation = -3.199, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 9.000}, line_width = 1.00, color_r = 0.90, color_g = 0.90, color_b = 0.90 },
    },
    noGoZones = {
    },
    trajectoryGates = {
    },
    mapSettings = {
        scale = { x = 1.000, y = 1.000 },
        curvature = 0.870,
        rotation = 0.000,
        tension = -0.250,
        mergeDistance = 6.200,
        lineWidth = 60.000,
        startLine = {
            length = 12.500,
            angle = 0.000
        },
        finishLine = {
            length = 12.500,
            angle = 0.000
        }
    },
    squareSettings = {
        {
            index = 1,
            offset = vec2(0.000, 0.000),
            rotation = 136.330,
            size = {width = 40.000, height = 15.000},
            deleted = false
        },
        {
            index = 2,
            offset = vec2(29.000, 15.000),
            rotation = 178.345,
            size = {width = 12.000, height = 2.000},
            deleted = false
        },
        {
            index = 3,
            offset = vec2(11.000, 23.000),
            rotation = 238.486,
            size = {width = 12.000, height = 2.000},
            deleted = false
        },
        {
            index = 4,
            offset = vec2(1.000, -23.000),
            rotation = 92.007,
            size = {width = 12.000, height = 2.000},
            deleted = false
        },
        {
            index = 5,
            offset = vec2(-5.000, 24.000),
            rotation = 289.190,
            size = {width = 12.000, height = 2.000},
            deleted = false
        },
        {
            index = 6,
            offset = vec2(-22.000, 0.000),
            rotation = 158.000,
            size = {width = 12.000, height = 2.000},
            deleted = false
        },
        {
            index = 7,
            offset = vec2(-23.000, 0.000),
            rotation = 14.600,
            size = {width = 12.000, height = 2.000},
            deleted = false
        },
        {
            index = 8,
            offset = vec2(27.000, -22.000),
            rotation = 2.200,
            size = {width = 23.000, height = 12.000},
            deleted = false
        },
        {
            index = 9,
            offset = vec2(0.000, 0.000),
            rotation = 86.801,
            size = {width = 40.000, height = 15.000},
            deleted = false
        },
    },
    mapTexts = {
        {
            text = "Start",
            position = vec2(15.934, -11.276)
        },
        {
            text = "Finish",
            position = vec2(16.080, 11.022)
        },
        {
            text = "OZ-1",
            position = vec2(51.703, 22.227)
        },
        {
            text = "OZ-2",
            position = vec2(21.336, 30.295)
        },
        {
            text = "OZ-3",
            position = vec2(-12.827, 23.460)
        },
        {
            text = "TG-1",
            position = vec2(-4.797, 4.747)
        },
    },
    entrySpeedLine = {
        position = vec3(75.510, 65.564, 17.624),
        rotation = -39.636,
        length = 15.000
    },
    maxAllowedTransitions = 99,

    startPosition = vec3(-8.422, 69.992, -16.242),
    startRotation = 163.560,
    alternateStartPosition = vec3(33.182, 68.215, -24.770),
    alternateStartRotation = -135.318,
    perfectEntrySpeed = 99,
    gatesTransparency = {
        normal = 1.0,
        start = 1.0,
        finish = 1.0,
        oz = 1.0,
        noGoZone = 1.0,
        trajectory = 1.0
    }
}