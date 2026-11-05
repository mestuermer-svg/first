local LocalGates = require('local_gates')

return {
    gates = {
        { type = "start", position = vec3(177.732, -5.556, -288.599), rotation = 153.122, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 11.240}, line_width = 1.58, color_r = 0.90, color_g = 1.00, color_b = 0.23 },
        { type = "normal", position = vec3(329.598, -7.427, -358.340), rotation = -296.193, pitch = 0.0, roll = 0.0, size = {width = 2.000, length = 5.000}, score_multiplier = 1.00, target_angle = 30, line_width = 1.00, color_r = 0.90, color_g = 1.00, color_b = 0.90 },
        { type = "OZ", position = vec3(343.528, -7.902, -384.785), rotation = 825.032, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 2.500}, score_multiplier = 0.25, target_angle = 30, line_width = 1.01, color_r = 1.00, color_g = 1.00, color_b = 1.00 },
        { type = "normal", position = vec3(314.032, -6.958, -416.831), rotation = 102.308, pitch = 0.0, roll = 0.0, size = {width = 2.000, length = 5.000}, score_multiplier = 1.00, target_angle = 35, line_width = 1.00, color_r = 0.90, color_g = 1.00, color_b = 0.90 },
        { type = "OZ", position = vec3(258.471, -5.366, -419.726), rotation = 191.481, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 1.830}, score_multiplier = 0.50, target_angle = 30, line_width = 1.00, color_r = 0.90, color_g = 0.90, color_b = 0.90 },
        { type = "normal", position = vec3(203.315, -3.539, -420.911), rotation = 49.065, pitch = 0.0, roll = 0.0, size = {width = 2.000, length = 5.000}, score_multiplier = 1.50, target_angle = 30, line_width = 1.00, color_r = 0.90, color_g = 0.90, color_b = 0.90 },
        { type = "OZ", position = vec3(151.140, -0.576, -386.452), rotation = 182.695, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 2.500}, score_multiplier = 0.25, target_angle = 30, line_width = 1.00, color_r = 0.90, color_g = 0.90, color_b = 0.90 },
        { type = "OZ", position = vec3(136.642, -0.011, -388.731), rotation = 201.108, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 2.500}, score_multiplier = 0.25, target_angle = 30, line_width = 1.00, color_r = 0.90, color_g = 0.90, color_b = 0.90 },
        { type = "OZ", position = vec3(122.801, 0.518, -394.381), rotation = 208.498, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 2.500}, score_multiplier = 0.25, target_angle = 30, line_width = 1.00, color_r = 0.90, color_g = 0.90, color_b = 0.90 },
        { type = "OZ", position = vec3(112.618, 0.921, -401.592), rotation = 223.333, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 2.500}, score_multiplier = 0.25, target_angle = 30, line_width = 1.00, color_r = 0.90, color_g = 0.90, color_b = 0.90 },
        { type = "OZ", position = vec3(104.688, 1.257, -409.939), rotation = 233.883, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 2.500}, score_multiplier = 0.25, target_angle = 30, line_width = 1.00, color_r = 0.90, color_g = 0.90, color_b = 0.90 },
        { type = "OZ", position = vec3(97.514, 1.609, -421.244), rotation = 246.138, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 2.500}, score_multiplier = 0.25, target_angle = 30, line_width = 1.00, color_r = 0.90, color_g = 0.90, color_b = 0.90 },
        { type = "OZ", position = vec3(92.416, 1.972, -436.968), rotation = 257.348, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 2.500}, score_multiplier = 0.25, target_angle = 30, line_width = 1.00, color_r = 0.90, color_g = 0.90, color_b = 0.90 },
        { type = "OZ", position = vec3(91.439, 2.285, -454.119), rotation = -88.136, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 2.500}, score_multiplier = 0.25, target_angle = 30, line_width = 1.00, color_r = 0.90, color_g = 0.90, color_b = 0.90 },
        { type = "normal", position = vec3(110.732, 2.726, -493.229), rotation = 229.661, pitch = 0.0, roll = 0.0, size = {width = 2.000, length = 5.000}, score_multiplier = 1.00, target_angle = 30, line_width = 1.00, color_r = 0.90, color_g = 0.90, color_b = 0.90 },
        { type = "normal", position = vec3(171.643, 2.140, -530.199), rotation = 230.956, pitch = 0.0, roll = 0.0, size = {width = 2.000, length = 5.000}, score_multiplier = 1.00, target_angle = 30, line_width = 1.00, color_r = 0.90, color_g = 0.90, color_b = 0.90 },
        { type = "normal", position = vec3(205.794, 1.192, -570.268), rotation = 231.281, pitch = 0.0, roll = 0.0, size = {width = 2.000, length = 5.000}, score_multiplier = 1.00, target_angle = 30, line_width = 1.00, color_r = 0.90, color_g = 0.90, color_b = 0.90 },
        { type = "normal", position = vec3(260.848, -1.382, -588.937), rotation = -52.439, pitch = 0.0, roll = 0.0, size = {width = 2.000, length = 5.000}, score_multiplier = 2.00, target_angle = 30, line_width = 1.00, color_r = 0.90, color_g = 0.90, color_b = 0.90 },
        { type = "normal", position = vec3(311.819, -5.869, -537.719), rotation = -52.466, pitch = 0.0, roll = 0.0, size = {width = 2.000, length = 5.000}, score_multiplier = 1.00, target_angle = 30, line_width = 1.00, color_r = 0.90, color_g = 0.90, color_b = 0.90 },
        { type = "normal", position = vec3(374.537, -8.907, -526.780), rotation = 224.074, pitch = 0.0, roll = 0.0, size = {width = 2.000, length = 5.000}, score_multiplier = 1.00, target_angle = 30, line_width = 1.00, color_r = 0.90, color_g = 0.90, color_b = 0.90 },
        { type = "finish", position = vec3(382.353, -8.608, -540.556), rotation = 303.623, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 14.830}, line_width = 1.00, color_r = 0.90, color_g = 1.00, color_b = 0.23 },
    },
    noGoZones = {
        {
            position = vec3(346.108, -7.578, -366.711),
            rotation = 152.086,
            size = {width = 0.100, length = 2.490},
            line_width = 1.00
        },
    },
    trajectoryGates = {
    },
    mapSettings = {
        scale = { x = 1.090, y = 1.000 },
        curvature = 0.910,
        rotation = -3.200,
        tension = -0.230,
        mergeDistance = 20.000,
        lineWidth = 60.000,
        startLine = {
            length = 34.200,
            angle = 0.000
        },
        finishLine = {
            length = 35.000,
            angle = 0.000
        }
    },
    squareSettings = {
        {
            index = 1,
            offset = vec2(0.000, 0.000),
            rotation = 228.122,
            size = {width = 40.000, height = 15.000},
            deleted = false
        },
        {
            index = 2,
            offset = vec2(-5.000, 32.000),
            rotation = -28.500,
            size = {width = 22.000, height = 9.000},
            deleted = false
        },
        {
            index = 3,
            offset = vec2(-22.000, 17.000),
            rotation = 17.600,
            size = {width = 12.000, height = 2.000},
            deleted = false
        },
        {
            index = 4,
            offset = vec2(-37.000, -28.000),
            rotation = -2.100,
            size = {width = 22.000, height = 9.000},
            deleted = false
        },
        {
            index = 5,
            offset = vec2(-38.000, 26.000),
            rotation = -87.800,
            size = {width = 10.000, height = 2.000},
            deleted = false
        },
        {
            index = 6,
            offset = vec2(-29.000, -12.000),
            rotation = -28.000,
            size = {width = 22.000, height = 9.000},
            deleted = false
        },
        {
            index = 7,
            offset = vec2(-68.000, 15.000),
            rotation = 109.800,
            size = {width = 12.000, height = 2.000},
            deleted = false
        },
        {
            index = 8,
            offset = vec2(0.000, 0.000),
            rotation = 291.108,
            size = {width = 12.000, height = 2.000},
            deleted = true
        },
        {
            index = 9,
            offset = vec2(-45.000, 0.000),
            rotation = -50.500,
            size = {width = 12.000, height = 2.000},
            deleted = false
        },
        {
            index = 10,
            offset = vec2(0.000, 0.000),
            rotation = 313.333,
            size = {width = 12.000, height = 2.000},
            deleted = true
        },
        {
            index = 11,
            offset = vec2(-37.000, -11.000),
            rotation = 323.883,
            size = {width = 12.000, height = 2.000},
            deleted = false
        },
        {
            index = 12,
            offset = vec2(0.000, 0.000),
            rotation = 336.138,
            size = {width = 12.000, height = 2.000},
            deleted = true
        },
        {
            index = 13,
            offset = vec2(-26.000, -12.000),
            rotation = 347.348,
            size = {width = 12.000, height = 2.000},
            deleted = false
        },
        {
            index = 14,
            offset = vec2(0.000, 0.000),
            rotation = 1.864,
            size = {width = 12.000, height = 2.000},
            deleted = true
        },
        {
            index = 15,
            offset = vec2(-5.000, -34.000),
            rotation = 138.300,
            size = {width = 22.000, height = 9.000},
            deleted = false
        },
        {
            index = 16,
            offset = vec2(38.000, -4.000),
            rotation = -37.300,
            size = {width = 22.000, height = 9.000},
            deleted = false
        },
        {
            index = 17,
            offset = vec2(48.000, -57.000),
            rotation = -26.300,
            size = {width = 22.000, height = 9.000},
            deleted = false
        },
        {
            index = 18,
            offset = vec2(51.000, -2.000),
            rotation = 43.900,
            size = {width = 22.000, height = 9.000},
            deleted = false
        },
        {
            index = 19,
            offset = vec2(-12.000, 18.000),
            rotation = 41.700,
            size = {width = 22.000, height = 9.000},
            deleted = false
        },
        {
            index = 20,
            offset = vec2(44.000, -9.000),
            rotation = -57.100,
            size = {width = 22.000, height = 9.000},
            deleted = false
        },
        {
            index = 21,
            offset = vec2(0.000, 0.000),
            rotation = 393.623,
            size = {width = 40.000, height = 15.000},
            deleted = false
        },
        {
            index = 22,
            offset = vec2(-6.000, 6.000),
            rotation = 50.500,
            size = {width = 12.000, height = 2.000},
            deleted = false
        },
    },
    mapTexts = {
        {
            text = "Start",
            position = vec2(168.890, -318.204)
        },
        {
            text = "Finish",
            position = vec2(333.707, -559.761)
        },
        {
            text = "TG-1",
            position = vec2(306.116, -353.815)
        },
        {
            text = "NG-1",
            position = vec2(330.439, -372.265)
        },
        {
            text = "OZ-1",
            position = vec2(281.430, -403.156)
        },
        {
            text = "OZ-2",
            position = vec2(222.982, -405.302)
        },
        {
            text = "OZ-3",
            position = vec2(101.366, -393.288)
        },
        {
            text = "TG-2",
            position = vec2(277.074, -459.363)
        },
        {
            text = "TG-3",
            position = vec2(183.412, -449.065)
        },
        {
            text = "TG-4",
            position = vec2(106.812, -514.282)
        },
        {
            text = "TG-5",
            position = vec2(191.761, -514.711)
        },
        {
            text = "TG-6",
            position = vec2(188.857, -582.072)
        },
        {
            text = "TG-7",
            position = vec2(277.800, -580.356)
        },
        {
            text = "TG-8",
            position = vec2(260.737, -515.140)
        },
        {
            text = "TG-9",
            position = vec2(347.139, -498.407)
        },
    },
    entrySpeedLine = {
        position = vec3(309.543, -7.309, -353.357),
        rotation = 66.601,
        length = 15.000
    },
    maxAllowedTransitions = 6,

    startPosition = vec3(148.671, -5.253, -279.381),
    startRotation = -174.586,
    alternateStartPosition = vec3(174.448, -5.521, -287.628),
    alternateStartRotation = 154.085,
    perfectEntrySpeed = 115,
    gatesTransparency = {
        normal = 1.0,
        start = 0.5,
        finish = 1.0,
        oz = 1.0,
        noGoZone = 1.0,
        trajectory = 1.0
    }
}