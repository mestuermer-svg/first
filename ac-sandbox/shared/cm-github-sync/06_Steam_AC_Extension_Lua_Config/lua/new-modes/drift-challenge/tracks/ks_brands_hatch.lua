local LocalGates = require('local_gates')

return {
    gates = {
        { type = "start", position = vec3(141.255, -15.749, -402.673), rotation = 66.360, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 11.480}, line_width = 1.00, color_r = 0.90, color_g = 0.90, color_b = 0.90 },
        { type = "OZ", position = vec3(146.633, -1.909, -130.823), rotation = 119.290, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 2.500}, score_multiplier = 0.25, target_angle = 15, line_width = 1.00, color_r = 0.90, color_g = 0.90, color_b = 0.90 },
        { type = "OZ", position = vec3(132.471, -1.335, -117.540), rotation = 149.369, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 2.500}, score_multiplier = 0.25, target_angle = 15, line_width = 1.00, color_r = 0.90, color_g = 0.90, color_b = 0.90 },
        { type = "OZ", position = vec3(116.321, -1.318, -112.959), rotation = 175.611, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 2.500}, score_multiplier = 0.25, target_angle = 15, line_width = 1.00, color_r = 0.90, color_g = 0.90, color_b = 0.90 },
        { type = "OZ", position = vec3(99.779, -1.873, -116.443), rotation = 200.556, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 2.500}, score_multiplier = 0.25, target_angle = 15, line_width = 1.00, color_r = 0.90, color_g = 0.90, color_b = 0.90 },
        { type = "OZ", position = vec3(83.046, -3.576, -132.330), rotation = 230.109, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 2.500}, score_multiplier = 0.25, target_angle = 15, line_width = 1.00, color_r = 0.90, color_g = 0.90, color_b = 0.90 },
        { type = "OZ", position = vec3(78.029, -5.165, -148.627), rotation = 267.508, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 2.500}, score_multiplier = 0.25, target_angle = 15, line_width = 1.00, color_r = 0.90, color_g = 0.90, color_b = 0.90 },
        { type = "normal", position = vec3(85.264, -11.311, -209.071), rotation = 179.854, pitch = 0.0, roll = 0.0, size = {width = 2.000, length = 5.000}, score_multiplier = 1.00, target_angle = 15, line_width = 1.00, color_r = 0.90, color_g = 0.90, color_b = 0.90 },
        { type = "finish", position = vec3(81.374, -12.494, -221.147), rotation = 270.024, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 9.950}, line_width = 1.00, color_r = 0.90, color_g = 0.90, color_b = 0.90 },
    },
    noGoZones = {
    },
    trajectoryGates = {
    },
    mapSettings = {
        scale = { x = 1.000, y = 1.000 },
        curvature = 0.700,
        rotation = -138.900,
        tension = -0.480,
        mergeDistance = 19.000,
        lineWidth = 60.000,
        startLine = {
            length = 25.800,
            angle = 0.000
        },
        finishLine = {
            length = 27.500,
            angle = 0.000
        }
    },
    squareSettings = {
        {
            index = 1,
            offset = vec2(0.000, 0.000),
            rotation = 156.360,
            size = {width = 40.000, height = 15.000},
            deleted = false
        },
        {
            index = 2,
            offset = vec2(-16.000, -27.000),
            rotation = 35.100,
            size = {width = 12.000, height = 2.000},
            deleted = false
        },
        {
            index = 3,
            offset = vec2(-27.000, -38.000),
            rotation = 70.200,
            size = {width = 12.000, height = 2.000},
            deleted = false
        },
        {
            index = 4,
            offset = vec2(-17.000, -37.000),
            rotation = 107.600,
            size = {width = 12.000, height = 2.000},
            deleted = false
        },
        {
            index = 5,
            offset = vec2(0.000, -34.000),
            rotation = 144.900,
            size = {width = 12.000, height = 2.000},
            deleted = false
        },
        {
            index = 6,
            offset = vec2(11.000, -35.000),
            rotation = 15.400,
            size = {width = 12.000, height = 2.000},
            deleted = false
        },
        {
            index = 7,
            offset = vec2(38.000, -39.000),
            rotation = 11.000,
            size = {width = 12.000, height = 2.000},
            deleted = false
        },
        {
            index = 8,
            offset = vec2(-5.000, -33.000),
            rotation = 136.100,
            size = {width = 23.000, height = 9.000},
            deleted = false
        },
        {
            index = 9,
            offset = vec2(0.000, 0.000),
            rotation = 360.024,
            size = {width = 40.000, height = 15.000},
            deleted = false
        },
    },
    mapTexts = {
        {
            text = "Start",
            position = vec2(94.831, -142.760)
        },
        {
            text = "Finish",
            position = vec2(117.303, -214.205)
        },
        {
            text = "TG-1",
            position = vec2(118.625, -295.094)
        },
        {
            text = "OZ-1",
            position = vec2(126.970, -357.506)
        },
    },
    maxAllowedTransitions = 2,

    startPosition = vec3(103.249, -9.010, -441.934),
    startRotation = -147.417,
    alternateStartPosition = vec3(140.023, -15.196, -406.088),
    alternateStartRotation = -117.760,
    perfectEntrySpeed = 135,
    gatesTransparency = {
        normal = 1.0,
        start = 1.0,
        finish = 0.0,
        oz = 1.0,
        noGoZone = 1.0,
        trajectory = 1.0
    }
}