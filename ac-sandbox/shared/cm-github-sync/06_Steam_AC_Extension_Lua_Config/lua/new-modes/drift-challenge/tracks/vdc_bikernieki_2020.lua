local LocalGates = require('local_gates')

return {
    gates = {
        { type = "start", position = vec3(308.280, 6.407, -563.790), rotation = 230.000, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 9.000} },
        { type = "normal", position = vec3(392.456, 7.383, -336.472), rotation = 35.000, pitch = 0.0, roll = 0.0, size = {width = 1.820, length = 8.570}, score_multiplier = 1.00, target_angle = 30, line_width = 1.01, color_r = 1.00, color_g = 1.00, color_b = 1.00 },
        { type = "normal", position = vec3(345.153, 6.872, -294.961), rotation = 43.700, pitch = 0.0, roll = 0.0, size = {width = 2.200, length = 8.570}, score_multiplier = 1.00, target_angle = 40, line_width = 1.00, color_r = 1.00, color_g = 1.00, color_b = 1.00 },
        { type = "normal", position = vec3(327.509, 6.446, -188.707), rotation = 153.000, pitch = 0.0, roll = 0.0, size = {width = 2.000, length = 8.720}, score_multiplier = 1.00, target_angle = 35, line_width = 1.00, color_r = 1.00, color_g = 1.00, color_b = 1.00 },
        { type = "normal", position = vec3(366.968, 6.399, -100.414), rotation = 9.000, pitch = 0.0, roll = 0.0, size = {width = 2.290, length = 8.570}, score_multiplier = 1.00, target_angle = 40, line_width = 1.00, color_r = 1.00, color_g = 1.00, color_b = 1.00 },
        { type = "OZ", position = vec3(345.600, 7.043, -42.410), rotation = 88.150, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 2.500}, score_multiplier = 0.25, target_angle = 30, line_width = 1.50, color_r = 1.00, color_g = 0.71, color_b = 0.00 },
        { type = "OZ", position = vec3(355.450, 7.102, -23.910), rotation = 32.150, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 2.500}, score_multiplier = 0.20, target_angle = 30, line_width = 1.50, color_r = 1.00, color_g = 0.71, color_b = 0.00 },
        { type = "OZ", position = vec3(375.650, 6.963, -16.410), rotation = 179.150, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 2.500}, score_multiplier = 0.20, target_angle = 30, line_width = 1.50, color_r = 1.00, color_g = 0.71, color_b = 0.00 },
        { type = "OZ", position = vec3(395.750, 6.547, -23.610), rotation = 140.150, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 2.500}, score_multiplier = 0.20, target_angle = 30, line_width = 1.50, color_r = 1.00, color_g = 0.71, color_b = 0.00 },
        { type = "OZ", position = vec3(406.228, 6.541, -43.133), rotation = 96.150, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 2.500}, score_multiplier = 0.20, target_angle = 30, line_width = 1.50, color_r = 1.00, color_g = 0.71, color_b = 0.00 },
        { type = "finish", position = vec3(402.584, 6.481, -52.856), rotation = 89.000, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 10.000} },
    },
    noGoZones = {
        {
            position = vec3(323.506, 6.805, -254.038),
            rotation = 110.000,
            size = {width = 0.100, length = 4.000}
        },
    },
    trajectoryGates = {
        {
            type = "trajectory",
            position = vec3(312.120, 6.536, -224.950),
            rotation = 170.000,
            pitch = 0.0,
            roll = 0.0,
            size = {width = 0.870, length = 24.000}
        },
    },
    mapSettings = {
        scale = { x = 1.390, y = 1.000 },
        curvature = 0.870,
        rotation = -126.300,
        tension = -0.100,
        mergeDistance = 0.000,
        lineWidth = 40.800,
        startLine = {
            length = 35.000,
            angle = 0.000
        },
        finishLine = {
            length = 29.200,
            angle = 0.000
        }
    },
    squareSettings = {
        {
            index = 1,
            offset = vec2(0.000, 0.000),
            rotation = 320.000,
            size = {width = 40.000, height = 15.000},
            deleted = false
        },
        {
            index = 2,
            offset = vec2(61.000, -33.000),
            rotation = 32.900,
            size = {width = 25.000, height = 10.000},
            deleted = false
        },
        {
            index = 3,
            offset = vec2(-52.000, 16.000),
            rotation = 39.500,
            size = {width = 25.000, height = 10.000},
            deleted = false
        },
        {
            index = 4,
            offset = vec2(51.000, -12.000),
            rotation = -65.800,
            size = {width = 26.000, height = 10.000},
            deleted = false
        },
        {
            index = 5,
            offset = vec2(-23.000, -27.000),
            rotation = -41.700,
            size = {width = 25.000, height = 10.000},
            deleted = false
        },
        {
            index = 6,
            offset = vec2(20.000, 0.000),
            rotation = 35.100,
            size = {width = 12.000, height = 2.000},
            deleted = false
        },
        {
            index = 7,
            offset = vec2(11.000, -13.000),
            rotation = 163.900,
            size = {width = 12.000, height = 2.000},
            deleted = false
        },
        {
            index = 8,
            offset = vec2(12.000, -9.000),
            rotation = 138.300,
            size = {width = 12.000, height = 2.000},
            deleted = false
        },
        {
            index = 9,
            offset = vec2(1.000, -15.000),
            rotation = 103.200,
            size = {width = 12.000, height = 2.000},
            deleted = false
        },
        {
            index = 10,
            offset = vec2(1.000, -16.000),
            rotation = 68.000,
            size = {width = 12.000, height = 2.000},
            deleted = false
        },
        {
            index = 11,
            offset = vec2(0.000, 0.000),
            rotation = 179.000,
            size = {width = 40.000, height = 15.000},
            deleted = false
        },
        {
            index = 12,
            offset = vec2(-22.000, -33.000),
            rotation = -112.000,
            size = {width = 12.000, height = 2.000},
            deleted = false
        },
    },
    mapTexts = {
        {
            text = "Start",
            position = vec2(310.489, -53.945)
        },
        {
            text = "TG-1",
            position = vec2(335.645, -374.553)
        },
        {
            text = "TG-2",
            position = vec2(339.940, -241.618)
        },
        {
            text = "TG-3",
            position = vec2(374.913, -306.521)
        },
        {
            text = "TG-4",
            position = vec2(363.869, -455.096)
        },
        {
            text = "OZ-1",
            position = vec2(395.038, -537.203)
        },
        {
            text = "NG-1",
            position = vec2(352.825, -343.274)
        },
        {
            text = "Finish",
            position = vec2(360.801, -541.895)
        },
    },
    entrySpeedLine = {
        position = vec3(390.920, 8.532, -434.329),
        rotation = -21.907,
        length = 10.000
    },
    maxAllowedTransitions = 3,

    startPosition = vec3(245.412, 6.516, -616.433),
    startRotation = -96.419,
    alternateStartPosition = vec3(304.463, 6.312, -563.763),
    alternateStartRotation = -131.615,
    perfectEntrySpeed = 135,
    gatesTransparency = {
        normal = 0.0,
        start = 1.0,
        finish = 0.0,
        oz = 1.0,
        noGoZone = 1.0,
        trajectory = 1.0
    }
}