local LocalGates = require('local_gates')

return {
    gates = {
        { type = "start", position = vec3(-130.413, 18.842, -474.368), rotation = 109.984, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 11.400} },
        { type = "normal", position = vec3(-152.275, 18.351, -352.536), rotation = 0.597, pitch = 0.0, roll = 0.0, size = {width = 2.000, length = 5.000}, score_multiplier = 1.00, target_angle = 17 },
        { type = "normal", position = vec3(-183.705, 20.576, -281.747), rotation = 65.864, pitch = 0.0, roll = 0.0, size = {width = 2.000, length = 5.000}, score_multiplier = 1.50, target_angle = 30 },
        { type = "normal", position = vec3(-250.163, 19.269, -268.716), rotation = 67.642, pitch = 0.0, roll = 0.0, size = {width = 2.000, length = 5.000}, score_multiplier = 1.00, target_angle = 30 },
        { type = "OZ", position = vec3(-266.241, 16.979, -233.069), rotation = -83.377, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 3.840}, score_multiplier = 0.25, target_angle = 30 },
        { type = "normal", position = vec3(-228.304, 20.605, -191.511), rotation = 258.252, pitch = 0.0, roll = 0.0, size = {width = 2.000, length = 5.000}, score_multiplier = 1.00, target_angle = 30 },
        { type = "finish", position = vec3(-191.718, 22.549, -206.854), rotation = 340.047, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 9.380} },
    },
    noGoZones = {
    },
    trajectoryGates = {
    },
    mapSettings = {
        scale = { x = 1.000, y = 1.000 },
        curvature = 1.460,
        rotation = -148.500,
        tension = -0.070,
        mergeDistance = 5.000,
        lineWidth = 60.000,
        startLine = {
            length = 34.200,
            angle = 0.000
        },
        finishLine = {
            length = 30.800,
            angle = 0.000
        }
    },
    squareSettings = {
        {
            index = 1,
            offset = vec2(0.000, 0.000),
            rotation = 199.984,
            size = {width = 40.000, height = 15.000},
            deleted = false
        },
        {
            index = 2,
            offset = vec2(10.000, -73.000),
            rotation = 142.700,
            size = {width = 25.000, height = 10.000},
            deleted = false
        },
        {
            index = 3,
            offset = vec2(49.000, -37.000),
            rotation = 19.700,
            size = {width = 26.000, height = 10.000},
            deleted = false
        },
        {
            index = 4,
            offset = vec2(-29.000, 39.000),
            rotation = 22.000,
            size = {width = 26.000, height = 10.000},
            deleted = false
        },
        {
            index = 5,
            offset = vec2(-45.000, 17.000),
            rotation = 57.100,
            size = {width = 12.000, height = 2.000},
            deleted = false
        },
        {
            index = 6,
            offset = vec2(32.000, -39.000),
            rotation = 59.300,
            size = {width = 26.000, height = 10.000},
            deleted = false
        },
        {
            index = 7,
            offset = vec2(0.000, 0.000),
            rotation = 430.047,
            size = {width = 40.000, height = 15.000},
            deleted = false
        },
    },
    mapTexts = {
        {
            text = "Start",
            position = vec2(-265.562, -216.160)
        },
        {
            text = "Finish",
            position = vec2(-176.425, -459.013)
        },
        {
            text = "TG-1",
            position = vec2(-219.380, -372.539)
        },
        {
            text = "TG-2",
            position = vec2(-191.536, -399.209)
        },
        {
            text = "TG-3",
            position = vec2(-176.425, -314.352)
        },
        {
            text = "OZ-1",
            position = vec2(-167.087, -379.813)
        },
        {
            text = "TG-4",
            position = vec2(-148.750, -467.095)
        },
    },
    entrySpeedLine = {
        position = vec3(-156.768, 18.453, -361.454),
        rotation = 6.653,
        size = {width = 0.100, length = 15.000}
    },
    maxAllowedTransitions = 2,

    startPosition = vec3(-106.914, 19.512, -551.278),
    startRotation = -70.906,
    alternateStartPosition = vec3(-128.957, 18.888, -477.214),
    alternateStartRotation = -66.894,
    perfectEntrySpeed = 120,
    gatesTransparency = {
        normal = 1.0,
        start = 1.0,
        finish = 1.0,
        oz = 1.0,
        noGoZone = 1.0,
        trajectory = 1.0
    }
}