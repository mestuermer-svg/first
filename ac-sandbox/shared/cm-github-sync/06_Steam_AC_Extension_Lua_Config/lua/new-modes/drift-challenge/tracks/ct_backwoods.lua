local LocalGates = require('local_gates')

return {
    gates = {
        { type = "start", position = vec3(41.598, -10.182, 198.258), rotation = 337.063, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 9.000} },
        { type = "normal", position = vec3(122.324, -5.128, 144.089), rotation = 193.594, pitch = 0.0, roll = 0.0, size = {width = 2.000, length = 5.000}, score_multiplier = 1.00, target_angle = 30 },
        { type = "OZ", position = vec3(121.069, -1.528, 115.265), rotation = 257.655, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 2.500}, score_multiplier = 0.25, target_angle = 30 },
        { type = "OZ", position = vec3(94.645, 4.863, 69.857), rotation = 117.151, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 2.500}, score_multiplier = 0.25, target_angle = 30 },
        { type = "OZ", position = vec3(103.134, 5.794, 55.965), rotation = 136.985, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 2.500}, score_multiplier = 0.25, target_angle = 30 },
        { type = "OZ", position = vec3(116.574, 6.228, 47.596), rotation = 153.822, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 2.590}, score_multiplier = 0.25, target_angle = 30 },
        { type = "OZ", position = vec3(143.818, 5.845, 46.974), rotation = 201.093, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 2.500}, score_multiplier = 0.25, target_angle = 30 },
        { type = "normal", position = vec3(169.630, 1.239, 91.837), rotation = 4.091, pitch = 0.0, roll = 0.0, size = {width = 2.000, length = 5.000}, score_multiplier = 1.00, target_angle = 30 },
        { type = "OZ", position = vec3(155.522, -6.147, 148.037), rotation = 66.432, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 2.500}, score_multiplier = 0.25, target_angle = 30 },
        { type = "OZ", position = vec3(168.130, -7.677, 165.630), rotation = 40.014, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 2.500}, score_multiplier = 0.25, target_angle = 30 },
        { type = "OZ", position = vec3(189.810, -9.356, 174.905), rotation = 3.933, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 2.500}, score_multiplier = 0.25, target_angle = 30 },
        { type = "normal", position = vec3(229.561, -12.166, 156.590), rotation = 221.618, pitch = 0.0, roll = 0.0, size = {width = 2.000, length = 5.000}, score_multiplier = 1.00, target_angle = 30 },
        { type = "OZ", position = vec3(251.936, -11.520, 105.968), rotation = 164.943, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 2.500}, score_multiplier = 0.25, target_angle = 30 },
        { type = "OZ", position = vec3(271.568, -10.980, 104.662), rotation = 188.419, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 2.500}, score_multiplier = 0.25, target_angle = 30 },
        { type = "OZ", position = vec3(291.676, -10.851, 117.909), rotation = 227.386, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 2.500}, score_multiplier = 0.25, target_angle = 30 },
        { type = "normal", position = vec3(265.300, -9.291, 178.735), rotation = 67.294, pitch = 0.0, roll = 0.0, size = {width = 2.000, length = 5.000}, score_multiplier = 1.00, target_angle = 30 },
        { type = "normal", position = vec3(202.253, -0.101, 199.493), rotation = 27.743, pitch = 0.0, roll = 0.0, size = {width = 2.000, length = 5.000}, score_multiplier = 2.00, target_angle = 30 },
        { type = "normal", position = vec3(223.781, -5.768, 263.842), rotation = -57.037, pitch = 0.0, roll = 0.0, size = {width = 2.000, length = 5.000}, score_multiplier = 2.00, target_angle = 30 },
        { type = "finish", position = vec3(248.118, -9.008, 268.900), rotation = 33.372, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 12.640} },
    },
    noGoZones = {
    },
    trajectoryGates = {
    },
    mapSettings = {
        scale = { x = 1.000, y = 1.000 },
        curvature = 1.180,
        rotation = -12.600,
        tension = -0.170,
        mergeDistance = 20.000,
        lineWidth = 53.000,
        startLine = {
            length = 20.000,
            angle = 0.000
        },
        finishLine = {
            length = 20.000,
            angle = 0.000
        }
    },
    squareSettings = {
        {
            index = 1,
            offset = vec2(0.000, 0.000),
            rotation = 427.063,
            size = {width = 40.000, height = 15.000},
            deleted = false
        },
        {
            index = 2,
            offset = vec2(27.000, -12.000),
            rotation = -72.500,
            size = {width = 23.000, height = 9.000},
            deleted = false
        },
        {
            index = 3,
            offset = vec2(16.000, -18.000),
            rotation = -30.700,
            size = {width = 12.000, height = 2.000},
            deleted = false
        },
        {
            index = 4,
            offset = vec2(-4.000, 0.000),
            rotation = -15.400,
            size = {width = 12.000, height = 2.000},
            deleted = false
        },
        {
            index = 5,
            offset = vec2(-4.000, -30.000),
            rotation = 226.985,
            size = {width = 12.000, height = 2.000},
            deleted = false
        },
        {
            index = 6,
            offset = vec2(19.000, -33.000),
            rotation = 243.822,
            size = {width = 12.000, height = 2.000},
            deleted = false
        },
        {
            index = 7,
            offset = vec2(6.000, -20.000),
            rotation = 291.093,
            size = {width = 12.000, height = 2.000},
            deleted = false
        },
        {
            index = 8,
            offset = vec2(19.000, -2.000),
            rotation = 74.300,
            size = {width = 23.000, height = 9.000},
            deleted = false
        },
        {
            index = 9,
            offset = vec2(-20.000, 13.000),
            rotation = 156.432,
            size = {width = 12.000, height = 2.000},
            deleted = false
        },
        {
            index = 10,
            offset = vec2(0.000, 21.000),
            rotation = 114.100,
            size = {width = 12.000, height = 2.000},
            deleted = false
        },
        {
            index = 11,
            offset = vec2(26.000, 8.000),
            rotation = 63.200,
            size = {width = 12.000, height = 2.000},
            deleted = false
        },
        {
            index = 12,
            offset = vec2(22.000, 0.000),
            rotation = -61.500,
            size = {width = 23.000, height = 9.000},
            deleted = false
        },
        {
            index = 13,
            offset = vec2(14.000, -28.000),
            rotation = 41.700,
            size = {width = 12.000, height = 2.000},
            deleted = false
        },
        {
            index = 14,
            offset = vec2(26.000, -26.000),
            rotation = 92.200,
            size = {width = 12.000, height = 2.000},
            deleted = false
        },
        {
            index = 15,
            offset = vec2(20.000, -11.000),
            rotation = 317.386,
            size = {width = 12.000, height = 2.000},
            deleted = false
        },
        {
            index = 16,
            offset = vec2(-13.000, 35.000),
            rotation = 149.300,
            size = {width = 23.000, height = 9.000},
            deleted = false
        },
        {
            index = 17,
            offset = vec2(-16.000, 18.000),
            rotation = 76.800,
            size = {width = 23.000, height = 9.000},
            deleted = false
        },
        {
            index = 18,
            offset = vec2(-9.000, 16.000),
            rotation = 39.500,
            size = {width = 23.000, height = 9.000},
            deleted = false
        },
        {
            index = 19,
            offset = vec2(0.000, 0.000),
            rotation = 123.372,
            size = {width = 40.000, height = 15.000},
            deleted = false
        },
    },
    mapTexts = {
        {
            text = "TG-1",
            position = vec2(95.677, 139.549)
        },
        {
            text = "TG-2",
            position = vec2(172.889, 91.993)
        },
        {
            text = "TG-3",
            position = vec2(184.768, 125.916)
        },
        {
            text = "TG-4",
            position = vec2(253.539, 168.082)
        },
        {
            text = "TG-5",
            position = vec2(169.763, 185.836)
        },
        {
            text = "TG-6",
            position = vec2(206.962, 240.050)
        },
        {
            text = "OZ-1",
            position = vec2(129.125, 107.845)
        },
        {
            text = "OZ-2",
            position = vec2(84.424, 54.266)
        },
        {
            text = "OZ-3",
            position = vec2(139.754, 169.984)
        },
        {
            text = "OZ-4",
            position = vec2(235.096, 68.215)
        },
        {
            text = "Start",
            position = vec2(45.662, 219.442)
        },
        {
            text = "Finish",
            position = vec2(262.604, 229.587)
        },
    },
    entrySpeedLine = {
        position = vec3(104.059, -8.092, 164.996),
        rotation = 234.171,
        length = 10.000
    },
    maxAllowedTransitions = 99,

    startPosition = vec3(-0.501, -10.190, 214.975),
    startRotation = 90.767,
    alternateStartPosition = vec3(38.829, -10.190, 198.683),
    alternateStartRotation = 151.984,
    perfectEntrySpeed = 90,
    gatesTransparency = {
        normal = 1.0,
        start = 1.0,
        finish = 1.0,
        oz = 1.0,
        noGoZone = 1.0,
        trajectory = 1.0
    }
}