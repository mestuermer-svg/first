local LocalGates = require('local_gates')

return {
    gates = {
        { type = "start", position = vec3(-237.149, 0.277, 17.404), rotation = 355.812, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 13.300}, line_width = 1.00, color_r = 1.00, color_g = 0.00, color_b = 0.15 },
        { type = "normal", position = vec3(22.631, 0.288, 6.991), rotation = 265.952, pitch = 0.0, roll = 0.0, size = {width = 2.000, length = 10.930}, score_multiplier = 1.00, target_angle = 30, line_width = 1.37, color_r = 1.00, color_g = 0.15, color_b = 0.00 },
        { type = "normal", position = vec3(114.057, -0.059, -33.649), rotation = 205.333, pitch = 0.0, roll = 0.0, size = {width = 2.000, length = 5.000}, score_multiplier = 1.00, target_angle = 30, line_width = 1.37, color_r = 1.00, color_g = 0.15, color_b = 0.00 },
        { type = "normal", position = vec3(138.163, -0.060, -70.558), rotation = 264.623, pitch = 0.0, roll = 0.0, size = {width = 2.000, length = 5.000}, score_multiplier = 1.00, target_angle = 30, line_width = 1.37, color_r = 1.00, color_g = 0.15, color_b = 0.00 },
        { type = "OZ", position = vec3(188.471, -0.066, -78.528), rotation = 100.366, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 2.500}, score_multiplier = 0.25, target_angle = 30, line_width = 1.70, color_r = 1.00, color_g = 0.15, color_b = 0.00 },
        { type = "OZ", position = vec3(190.169, -0.061, -89.985), rotation = 97.510, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 2.500}, score_multiplier = 0.25, target_angle = 30, line_width = 1.70, color_r = 1.00, color_g = 0.15, color_b = 0.00 },
        { type = "OZ", position = vec3(189.338, -0.048, -105.952), rotation = 82.066, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 2.500}, score_multiplier = 0.25, target_angle = 30, line_width = 1.70, color_r = 1.00, color_g = 0.15, color_b = 0.00 },
        { type = "normal", position = vec3(141.779, 0.295, -120.288), rotation = 82.883, pitch = 0.0, roll = 0.0, size = {width = 2.000, length = 9.380}, score_multiplier = 1.00, target_angle = 30, line_width = 1.37, color_r = 1.00, color_g = 0.15, color_b = 0.00 },
        { type = "normal", position = vec3(87.444, 0.109, -77.364), rotation = 25.930, pitch = 0.0, roll = 0.0, size = {width = 2.000, length = 5.000}, score_multiplier = 1.00, target_angle = 30, line_width = 1.37, color_r = 1.00, color_g = 0.15, color_b = 0.00 },
        { type = "normal", position = vec3(26.683, 0.244, -27.835), rotation = 87.001, pitch = 0.0, roll = 0.0, size = {width = 2.000, length = 5.000}, score_multiplier = 1.00, target_angle = 30, line_width = 1.37, color_r = 1.00, color_g = 0.15, color_b = 0.00 },
        { type = "normal", position = vec3(-19.606, 0.244, -85.889), rotation = 134.108, pitch = 0.0, roll = 0.0, size = {width = 2.000, length = 5.000}, score_multiplier = 1.00, target_angle = 30, line_width = 1.37, color_r = 1.00, color_g = 0.15, color_b = 0.00 },
        { type = "normal", position = vec3(-50.974, 0.253, -94.686), rotation = 74.158, pitch = 0.0, roll = 0.0, size = {width = 2.000, length = 5.000}, score_multiplier = 1.00, target_angle = 30, line_width = 1.37, color_r = 1.00, color_g = 0.15, color_b = 0.00 },
        { type = "finish", position = vec3(-63.653, 0.144, -81.372), rotation = 143.676, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 14.930}, line_width = 1.00, color_r = 0.90, color_g = 0.11, color_b = 0.00 },
    },
    noGoZones = {
    },
    trajectoryGates = {
        {
            type = "trajectory",
            position = vec3(111.746, 0.031, -103.842),
            rotation = -32.558,
            pitch = 0.0,
            roll = 0.0,
            size = {width = 0.100, length = 3.540}
        },
    },
    mapSettings = {
        scale = { x = 0.660, y = 1.000 },
        curvature = 1.000,
        rotation = -116.800,
        tension = -0.010,
        mergeDistance = 20.000,
        lineWidth = 60.000,
        startLine = {
            length = 27.500,
            angle = 0.000
        },
        finishLine = {
            length = 30.000,
            angle = -6.300
        }
    },
    squareSettings = {
        {
            index = 1,
            offset = vec2(0.000, 0.000),
            rotation = 445.812,
            size = {width = 40.000, height = 15.000},
            deleted = false
        },
        {
            index = 2,
            offset = vec2(26.000, -7.000),
            rotation = -125.100,
            size = {width = 35.000, height = 9.000},
            deleted = false
        },
        {
            index = 3,
            offset = vec2(-35.000, -28.000),
            rotation = -4.400,
            size = {width = 24.000, height = 9.000},
            deleted = false
        },
        {
            index = 4,
            offset = vec2(-40.000, 0.000),
            rotation = 46.100,
            size = {width = 24.000, height = 9.000},
            deleted = false
        },
        {
            index = 5,
            offset = vec2(-52.000, -15.000),
            rotation = 70.200,
            size = {width = 12.000, height = 2.000},
            deleted = false
        },
        {
            index = 6,
            offset = vec2(-51.000, 0.000),
            rotation = 35.100,
            size = {width = 12.000, height = 2.000},
            deleted = false
        },
        {
            index = 7,
            offset = vec2(-31.000, 18.000),
            rotation = 24.100,
            size = {width = 12.000, height = 2.000},
            deleted = false
        },
        {
            index = 8,
            offset = vec2(31.000, 36.000),
            rotation = 13.200,
            size = {width = 37.000, height = 9.000},
            deleted = false
        },
        {
            index = 9,
            offset = vec2(54.000, 29.000),
            rotation = 2.200,
            size = {width = 24.000, height = 9.000},
            deleted = false
        },
        {
            index = 10,
            offset = vec2(17.000, -16.000),
            rotation = 57.100,
            size = {width = 24.000, height = 9.000},
            deleted = false
        },
        {
            index = 11,
            offset = vec2(-10.000, -32.000),
            rotation = -50.500,
            size = {width = 24.000, height = 9.000},
            deleted = false
        },
        {
            index = 12,
            offset = vec2(-21.000, -18.000),
            rotation = -116.300,
            size = {width = 24.000, height = 9.000},
            deleted = false
        },
        {
            index = 13,
            offset = vec2(0.000, 0.000),
            rotation = 233.676,
            size = {width = 40.000, height = 15.000},
            deleted = false
        },
    },
    mapTexts = {
        {
            text = "Start",
            position = vec2(130.532, 5.091)
        },
        {
            text = "Finish",
            position = vec2(-81.704, -26.008)
        },
        {
            text = "TG-1",
            position = vec2(43.392, -84.072)
        },
        {
            text = "TG-2",
            position = vec2(-106.830, -110.840)
        },
        {
            text = "TG-3",
            position = vec2(-131.957, -95.685)
        },
        {
            text = "TG-4",
            position = vec2(-201.989, -71.672)
        },
        {
            text = "TG-5",
            position = vec2(-113.780, -68.326)
        },
        {
            text = "TG-6",
            position = vec2(-18.621, -60.453)
        },
        {
            text = "TG-7",
            position = vec2(-141.045, -51.792)
        },
        {
            text = "TG-8",
            position = vec2(-139.976, -34.275)
        },
        {
            text = "OZ-1",
            position = vec2(-215.354, -93.913)
        },
    },
    entrySpeedLine = {
        position = vec3(0.181, 0.249, 6.377),
        rotation = 269.800,
        length = 10.000
    },
    maxAllowedTransitions = 99,

    startPosition = vec3(-221.742, 0.312, 47.344),
    startRotation = 23.989,
    alternateStartPosition = vec3(-241.966, 0.277, 17.985),
    alternateStartRotation = 176.283,
    perfectEntrySpeed = 94,
    gatesTransparency = {
        normal = 0.9,
        start = 1.0,
        finish = 1.0,
        oz = 0.9,
        noGoZone = 1.0,
        trajectory = 1.0
    }
}