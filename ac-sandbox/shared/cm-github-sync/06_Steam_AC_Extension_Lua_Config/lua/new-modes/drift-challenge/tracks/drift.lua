local LocalGates = require('local_gates')

return {
    gates = {
        { type = "start", position = vec3(6.725, -0.005, -22.256), rotation = 31.600, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 15.890}, line_width = 1.00, color_r = 0.90, color_g = 0.90, color_b = 0.90 },
        { type = "OZ", position = vec3(-135.144, -0.005, -132.984), rotation = 163.900, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 2.400}, score_multiplier = 0.33, target_angle = 30, line_width = 1.68, color_r = 0.90, color_g = 0.90, color_b = 0.90 },
        { type = "OZ", position = vec3(-143.986, -0.005, -130.490), rotation = 153.400, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 2.400}, score_multiplier = 0.33, target_angle = 30, line_width = 1.68, color_r = 0.90, color_g = 0.90, color_b = 0.90 },
        { type = "OZ", position = vec3(-152.022, -0.005, -124.388), rotation = 132.600, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 2.380}, score_multiplier = 0.34, target_angle = 30, line_width = 1.68, color_r = 0.90, color_g = 0.90, color_b = 0.90 },
        { type = "normal", position = vec3(-153.394, -0.005, -65.378), rotation = 149.000, pitch = 0.0, roll = 0.0, size = {width = 2.000, length = 6.070}, score_multiplier = 1.00, target_angle = 30, line_width = 0.91, color_r = 0.90, color_g = 0.90, color_b = 0.90 },
        { type = "normal", position = vec3(-72.226, -0.005, -63.122), rotation = 125.000, pitch = 0.0, roll = 0.0, size = {width = 2.000, length = 7.580}, score_multiplier = 1.00, target_angle = 30, line_width = 0.91, color_r = 0.90, color_g = 0.90, color_b = 0.90 },
        { type = "normal", position = vec3(-67.400, -0.005, -16.970), rotation = 55.000, pitch = 0.0, roll = 0.0, size = {width = 2.000, length = 5.960}, score_multiplier = 1.00, target_angle = 30, line_width = 0.91, color_r = 0.90, color_g = 0.90, color_b = 0.90 },
        { type = "normal", position = vec3(-96.340, -0.005, 29.420), rotation = 153.000, pitch = 0.0, roll = 0.0, size = {width = 2.000, length = 4.660}, score_multiplier = 1.00, target_angle = 30, line_width = 0.91, color_r = 0.90, color_g = 0.90, color_b = 0.90 },
        { type = "normal", position = vec3(-74.460, -0.005, 72.180), rotation = 170.000, pitch = 0.0, roll = 0.0, size = {width = 1.700, length = 4.240}, score_multiplier = 1.00, target_angle = 30, line_width = 0.91, color_r = 0.90, color_g = 0.90, color_b = 0.90 },
        { type = "normal", position = vec3(-70.550, -0.005, 135.520), rotation = 135.000, pitch = 0.0, roll = 0.0, size = {width = 2.000, length = 6.000}, score_multiplier = 1.00, target_angle = 30, line_width = 0.91, color_r = 0.90, color_g = 0.90, color_b = 0.90 },
        { type = "normal", position = vec3(-9.880, -0.005, 137.000), rotation = 59.500, pitch = 0.0, roll = 0.0, size = {width = 2.000, length = 6.000}, score_multiplier = 1.00, target_angle = 30, line_width = 0.91, color_r = 0.90, color_g = 0.90, color_b = 0.90 },
        { type = "normal", position = vec3(46.340, -0.005, 91.590), rotation = 70.000, pitch = 0.0, roll = 0.0, size = {width = 2.000, length = 6.000}, score_multiplier = 1.00, target_angle = 30, line_width = 0.91, color_r = 0.90, color_g = 0.90, color_b = 0.90 },
        { type = "normal", position = vec3(133.550, -0.005, 85.030), rotation = 78.000, pitch = 0.0, roll = 0.0, size = {width = 2.000, length = 4.000}, score_multiplier = 1.00, target_angle = 30, line_width = 0.91, color_r = 0.90, color_g = 0.90, color_b = 0.90 },
        { type = "normal", position = vec3(172.001, -0.005, 32.492), rotation = 156.000, pitch = 0.0, roll = 0.0, size = {width = 2.190, length = 4.940}, score_multiplier = 1.00, target_angle = 50, line_width = 0.91, color_r = 0.90, color_g = 0.90, color_b = 0.90 },
        { type = "finish", position = vec3(133.250, -0.005, 19.250), rotation = 4.000, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 14.190}, line_width = 1.00, color_r = 0.90, color_g = 0.90, color_b = 0.90 },
    },
    noGoZones = {
        {
            position = vec3(-125.470, -0.000, -58.960),
            rotation = 0.000,
            size = {width = 0.200, length = 4.000}
        },
        {
            position = vec3(-164.230, 0.000, -100.680),
            rotation = 100.000,
            size = {width = 0.200, length = 2.500}
        },
    },
    trajectoryGates = {
    },
    mapSettings = {
        scale = { x = 1.000, y = 1.000 },
        curvature = 0.760,
        rotation = 12.600,
        tension = 0.110,
        mergeDistance = 20.000,
        lineWidth = 23.600,
        startLine = {
            length = 20.000,
            angle = 0.000
        },
        finishLine = {
            length = 20.000,
            angle = -0.000
        }
    },
    squareSettings = {
        {
            index = 1,
            offset = vec2(0.000, 0.000),
            rotation = 321.539,
            size = {width = 40.000, height = 15.000},
            deleted = false
        },
        {
            index = 2,
            offset = vec2(0.000, 0.000),
            rotation = 238.900,
            size = {width = 12.000, height = 2.000},
            deleted = true
        },
        {
            index = 3,
            offset = vec2(0.000, 0.000),
            rotation = 235.400,
            size = {width = 12.000, height = 2.000},
            deleted = true
        },
        {
            index = 4,
            offset = vec2(1.000, 28.000),
            rotation = 229.600,
            size = {width = 10.000, height = 2.000},
            deleted = false
        },
        {
            index = 5,
            offset = vec2(-9.000, -7.000),
            rotation = 90.000,
            size = {width = 22.000, height = 8.000},
            deleted = false
        },
        {
            index = 6,
            offset = vec2(-34.000, -12.000),
            rotation = 8.800,
            size = {width = 22.000, height = 8.000},
            deleted = false
        },
        {
            index = 7,
            offset = vec2(20.000, -13.000),
            rotation = 122.900,
            size = {width = 22.000, height = 8.000},
            deleted = false
        },
        {
            index = 8,
            offset = vec2(-23.000, 0.000),
            rotation = 105.400,
            size = {width = 22.000, height = 8.000},
            deleted = false
        },
        {
            index = 9,
            offset = vec2(22.000, 0.000),
            rotation = 90.000,
            size = {width = 22.000, height = 8.000},
            deleted = false
        },
        {
            index = 10,
            offset = vec2(-10.000, 30.000),
            rotation = 225.000,
            size = {width = 22.000, height = 8.000},
            deleted = false
        },
        {
            index = 11,
            offset = vec2(34.000, 18.000),
            rotation = 149.500,
            size = {width = 22.000, height = 8.000},
            deleted = false
        },
        {
            index = 12,
            offset = vec2(-5.000, -20.000),
            rotation = 164.600,
            size = {width = 22.000, height = 8.000},
            deleted = false
        },
        {
            index = 13,
            offset = vec2(1.000, 29.000),
            rotation = 168.000,
            size = {width = 22.000, height = 8.000},
            deleted = false
        },
        {
            index = 14,
            offset = vec2(27.000, 0.000),
            rotation = 83.400,
            size = {width = 22.000, height = 8.000},
            deleted = false
        },
        {
            index = 15,
            offset = vec2(0.000, 0.000),
            rotation = 94.000,
            size = {width = 40.000, height = 15.000},
            deleted = false
        },
        {
            index = 16,
            offset = vec2(-69.000, -51.000),
            rotation = 94.400,
            size = {width = 10.000, height = 2.000},
            deleted = false
        },
        {
            index = 17,
            offset = vec2(-46.000, -24.000),
            rotation = 190.000,
            size = {width = 10.000, height = 2.000},
            deleted = false
        },
    },
    mapTexts = {
        {
            text = "Start",
            position = vec2(-4.933, -6.795)
        },
        {
            text = "Finish",
            position = vec2(50.385, 25.920)
        },
        {
            text = "TG-1",
            position = vec2(-151.360, -71.085)
        },
        {
            text = "TG-2",
            position = vec2(-96.450, -61.574)
        },
        {
            text = "TG-3",
            position = vec2(-50.895, -27.718)
        },
        {
            text = "TG-4",
            position = vec2(-135.904, 21.736)
        },
        {
            text = "TG-5",
            position = vec2(-77.740, 22.877)
        },
        {
            text = "TG-6",
            position = vec2(-126.549, 124.066)
        },
        {
            text = "TG-7",
            position = vec2(-19.575, 125.968)
        },
        {
            text = "TG-8",
            position = vec2(-14.288, 60.157)
        },
        {
            text = "TG-9",
            position = vec2(78.043, 107.708)
        },
        {
            text = "TG-10",
            position = vec2(135.801, 67.385)
        },
        {
            text = "OZ-1",
            position = vec2(-140.378, -129.287)
        },
        {
            text = "NG-1",
            position = vec2(-106.212, -101.898)
        },
        {
            text = "NG-2",
            position = vec2(-130.616, -56.629)
        },
    },
    entrySpeedLine = {
        position = vec3(-96.677, -0.005, -110.659),
        rotation = 134.605,
        length = 15.000
    },
    maxAllowedTransitions = 6,

    startPosition = vec3(25.551, 0.122, 3.815),
    startRotation = 69.866,
    alternateStartPosition = vec3(9.553, -0.005, -19.586),
    alternateStartRotation = 39.165,
    perfectEntrySpeed = 115,
    gatesTransparency = {
        normal = 1.0,
        start = 0.7,
        finish = 1.0,
        oz = 1.0,
        noGoZone = 1.0,
        trajectory = 1.0
    }
}