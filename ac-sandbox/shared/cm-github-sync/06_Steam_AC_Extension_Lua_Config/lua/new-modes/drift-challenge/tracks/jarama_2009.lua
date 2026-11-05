local LocalGates = require('local_gates')

return {
    gates = {
        { type = "start", position = vec3(-20.332, 7.952, -152.312), rotation = 133.487, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 12.630}, line_width = 1.00, color_r = 0.90, color_g = 0.90, color_b = 0.90 },
        { type = "normal", position = vec3(-222.412, 3.358, -136.845), rotation = 89.033, pitch = 0.0, roll = 0.0, size = {width = 2.000, length = 5.000}, score_multiplier = 1.50, target_angle = 50, line_width = 1.26, color_r = 1.00, color_g = 1.00, color_b = 1.00 },
        { type = "OZ", position = vec3(-243.512, 1.903, -122.466), rotation = 136.647, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 2.690}, score_multiplier = 0.33, target_angle = 30, line_width = 2.00 },
        { type = "OZ", position = vec3(-247.652, 1.677, -117.137), rotation = 116.385, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 2.500}, score_multiplier = 0.33, target_angle = 30, line_width = 2.00, color_r = 0.90, color_g = 0.90, color_b = 0.90 },
        { type = "OZ", position = vec3(-249.994, 1.661, -109.934), rotation = 92.677, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 2.500}, score_multiplier = 0.33, target_angle = 30, line_width = 2.00 },
        { type = "normal", position = vec3(-238.367, 2.680, -84.939), rotation = -66.591, pitch = 0.0, roll = 0.0, size = {width = 2.000, length = 5.000}, score_multiplier = 1.00, target_angle = 50, line_width = 1.26, color_r = 1.00, color_g = 1.00, color_b = 1.00 },
        { type = "normal", position = vec3(-189.961, 2.832, -75.274), rotation = -67.742, pitch = 0.0, roll = 0.0, size = {width = 2.000, length = 5.000}, score_multiplier = 1.00, target_angle = 30, line_width = 1.26, color_r = 1.00, color_g = 1.00, color_b = 1.00 },
        { type = "OZ", position = vec3(-153.770, 3.375, -20.020), rotation = 126.802, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 2.500}, score_multiplier = 0.33, target_angle = 30, line_width = 2.00 },
        { type = "OZ", position = vec3(-159.765, 3.192, -11.754), rotation = 130.290, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 2.500}, score_multiplier = 0.33, target_angle = 30, line_width = 2.00 },
        { type = "OZ", position = vec3(-166.558, 3.074, -4.578), rotation = 134.317, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 2.500}, score_multiplier = 0.33, target_angle = 30, line_width = 2.00 },
        { type = "normal", position = vec3(-221.630, 2.315, 4.955), rotation = 100.451, pitch = 0.0, roll = 0.0, size = {width = 2.000, length = 5.000}, score_multiplier = 1.00, target_angle = 50, line_width = 1.26, color_r = 1.00, color_g = 1.00, color_b = 1.00 },
        { type = "finish", position = vec3(-255.638, 2.003, -6.597), rotation = 190.648, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 11.390} },
    },
    noGoZones = {
        {
            position = vec3(-166.847, 2.307, -17.597),
            rotation = -50.851,
            size = {width = 0.100, length = 3.850}
        },
        {
            position = vec3(-259.521, 2.742, -116.792),
            rotation = 101.033,
            size = {width = 0.100, length = 5.000}
        },
    },
    trajectoryGates = {
        {
            type = "trajectory",
            position = vec3(-243.871, 3.199, -135.070),
            rotation = 162.322,
            pitch = 0.0,
            roll = 0.0,
            size = {width = 0.100, length = 2.420}
        },
        {
            type = "trajectory",
            position = vec3(-260.085, 2.782, -101.848),
            rotation = -93.948,
            pitch = 0.0,
            roll = 0.0,
            size = {width = 0.100, length = 2.990}
        },
        {
            type = "trajectory",
            position = vec3(-160.274, 2.758, -51.438),
            rotation = 56.734,
            pitch = 0.0,
            roll = 0.0,
            size = {width = 0.100, length = 5.740}
        },
    },
    mapSettings = {
        scale = { x = 1.210, y = 1.300 },
        curvature = 1.420,
        rotation = 145.300,
        tension = -0.750,
        mergeDistance = 20.000,
        lineWidth = 46.400,
        startLine = {
            length = 31.700,
            angle = -0.000
        },
        finishLine = {
            length = 30.800,
            angle = -0.000
        }
    },
    squareSettings = {
        {
            index = 1,
            offset = vec2(0.000, 0.000),
            rotation = 223.487,
            size = {width = 40.000, height = 15.000},
            deleted = false
        },
        {
            index = 2,
            offset = vec2(9.000, 49.000),
            rotation = -43.900,
            size = {width = 28.000, height = 12.000},
            deleted = false
        },
        {
            index = 3,
            offset = vec2(-13.000, 10.000),
            rotation = -15.400,
            size = {width = 11.000, height = 2.000},
            deleted = true
        },
        {
            index = 4,
            offset = vec2(-21.000, 4.000),
            rotation = -50.500,
            size = {width = 11.000, height = 2.000},
            deleted = false
        },
        {
            index = 5,
            offset = vec2(-17.000, -0.000),
            rotation = -63.700,
            size = {width = 11.000, height = 2.000},
            deleted = true
        },
        {
            index = 6,
            offset = vec2(-37.000, -29.000),
            rotation = -24.100,
            size = {width = 32.000, height = 12.000},
            deleted = false
        },
        {
            index = 7,
            offset = vec2(-85.000, 0.000),
            rotation = 28.500,
            size = {width = 30.000, height = 12.000},
            deleted = false
        },
        {
            index = 8,
            offset = vec2(-12.000, 1.000),
            rotation = -17.600,
            size = {width = 11.000, height = 2.000},
            deleted = true
        },
        {
            index = 9,
            offset = vec2(-16.000, 2.000),
            rotation = 0.000,
            size = {width = 11.000, height = 2.000},
            deleted = false
        },
        {
            index = 10,
            offset = vec2(-13.000, 7.000),
            rotation = 13.200,
            size = {width = 12.000, height = 2.000},
            deleted = true
        },
        {
            index = 11,
            offset = vec2(-48.000, 0.000),
            rotation = -50.500,
            size = {width = 30.000, height = 12.000},
            deleted = false
        },
        {
            index = 12,
            offset = vec2(0.000, 0.000),
            rotation = 280.648,
            size = {width = 40.000, height = 15.000},
            deleted = false
        },
        {
            index = 13,
            offset = vec2(4.000, 33.000),
            rotation = -8.800,
            size = {width = 12.000, height = 2.000},
            deleted = false
        },
        {
            index = 14,
            offset = vec2(-58.000, 44.000),
            rotation = -19.800,
            size = {width = 12.000, height = 2.000},
            deleted = false
        },
    },
    mapTexts = {
        {
            text = "NG-1",
            position = vec2(-77.100, -90.079)
        },
        {
            text = "NG-2",
            position = vec2(-150.927, -112.546)
        },
        {
            text = "Start",
            position = vec2(-218.577, -4.256)
        },
        {
            text = "Finish",
            position = vec2(-111.219, -151.413)
        },
        {
            text = "TG-1",
            position = vec2(-95.042, -53.458)
        },
        {
            text = "TG-2",
            position = vec2(-113.572, -111.423)
        },
        {
            text = "TG-3",
            position = vec2(-179.458, -84.238)
        },
        {
            text = "TG-4",
            position = vec2(-185.340, -143.101)
        },
        {
            text = "OZ-1",
            position = vec2(-120.337, -84.013)
        },
        {
            text = "OZ-2",
            position = vec2(-198.870, -108.502)
        },
    },
    entrySpeedLine = {
        position = vec3(-184.377, 3.168, -134.290),
        rotation = 87.124,
        length = 10.000
    },
    maxAllowedTransitions = 2,

    startPosition = vec3(3.205, 11.883, -183.238),
    startRotation = -60.166,
    alternateStartPosition = vec3(-18.467, 8.246, -155.801),
    alternateStartRotation = -47.508,
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