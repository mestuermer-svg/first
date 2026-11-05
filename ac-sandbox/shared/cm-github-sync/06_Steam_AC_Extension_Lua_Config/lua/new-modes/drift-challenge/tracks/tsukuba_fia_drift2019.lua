local LocalGates = require('local_gates')

return {
    gates = {
        { type = "start", position = vec3(-240.155, 0.821, 122.037), rotation = 65.000, pitch = -4.2, roll = 0.0, size = {width = 0.100, length = 15.240} },
        { type = "normal", position = vec3(110.754, 3.387, -15.442), rotation = 90.000, pitch = 0.0, roll = 0.0, size = {width = 2.800, length = 7.940}, score_multiplier = 2.00 },
        { type = "normal", position = vec3(103.650, 3.539, 62.590), rotation = 97.000, pitch = 0.0, roll = 0.0, size = {width = 2.500, length = 5.500}, score_multiplier = 1.00 },
        { type = "normal", position = vec3(14.270, 2.100, 44.750), rotation = 95.000, pitch = 0.5, roll = 0.0, size = {width = 2.300, length = 7.300}, score_multiplier = 1.00 },
        { type = "normal", position = vec3(-66.230, 0.545, 67.950), rotation = 72.000, pitch = 0.7, roll = 0.0, size = {width = 2.300, length = 5.500}, score_multiplier = 1.00 },
        { type = "normal", position = vec3(-150.430, 0.930, 58.510), rotation = 104.000, pitch = 0.0, roll = -6.0, size = {width = 2.300, length = 4.700}, score_multiplier = 1.00 },
        { type = "OZ", position = vec3(-167.540, 1.250, 55.340), rotation = 0.000, pitch = 6.0, roll = 0.0, size = {width = 0.100, length = 2.700}, score_multiplier = 0.20 },
        { type = "OZ", position = vec3(-186.110, 1.207, 63.940), rotation = 140.000, pitch = -6.0, roll = 0.0, size = {width = 0.100, length = 2.700}, score_multiplier = 0.20 },
        { type = "OZ", position = vec3(-195.910, 1.238, 85.240), rotation = 95.000, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 2.700}, score_multiplier = 0.20, heightOffset = 0.000 },
        { type = "OZ", position = vec3(-190.270, 1.335, 105.440), rotation = 55.000, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 2.700}, score_multiplier = 0.20, heightOffset = 0.000 },
        { type = "OZ", position = vec3(-176.110, 1.089, 116.170), rotation = 20.000, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 2.700}, score_multiplier = 0.20, heightOffset = 0.000 },
        { type = "normal", position = vec3(-139.720, 0.682, 116.830), rotation = 85.000, pitch = 0.0, roll = 0.0, size = {width = 2.300, length = 5.700}, score_multiplier = 1.00 },
        { type = "finish", position = vec3(-137.063, 0.657, 111.960), rotation = 173.100, pitch = 0.0, roll = 0.0, size = {width = 0.100, length = 11.680} },
    },
    noGoZones = {
        {
            position = vec3(-181.176, 0.109, 97.172),
            rotation = 420.371,
            size = {width = 0.100, length = 3.180}
        },
    },
    trajectoryGates = {
    },
    mapSettings = {
        scale = { x = 1.000, y = 1.000 },
        curvature = 1.110,
        rotation = 154.700,
        tension = -0.180,
        mergeDistance = 14.100,
        lineWidth = 60.000,
        startLine = {
            length = 35.000,
            angle = -0.000
        },
        finishLine = {
            length = 28.300,
            angle = 0.000
        }
    },
    squareSettings = {
        {
            index = 1,
            offset = vec2(0.000, 0.000),
            rotation = 155.000,
            size = {width = 40.000, height = 15.000},
            deleted = false
        },
        {
            index = 2,
            offset = vec2(0.000, 0.000),
            rotation = 180.000,
            size = {width = 40.000, height = 15.000},
            deleted = true
        },
        {
            index = 3,
            offset = vec2(100.000, 25.000),
            rotation = -19.800,
            size = {width = 34.000, height = 12.000},
            deleted = false
        },
        {
            index = 4,
            offset = vec2(51.000, -69.000),
            rotation = -11.000,
            size = {width = 34.000, height = 12.000},
            deleted = false
        },
        {
            index = 5,
            offset = vec2(83.000, 0.000),
            rotation = -43.900,
            size = {width = 34.000, height = 12.000},
            deleted = false
        },
        {
            index = 6,
            offset = vec2(34.000, -67.000),
            rotation = 162.000,
            size = {width = 34.000, height = 12.000},
            deleted = false
        },
        {
            index = 7,
            offset = vec2(2.000, 52.000),
            rotation = -15.400,
            size = {width = 34.000, height = 12.000},
            deleted = false
        },
        {
            index = 8,
            offset = vec2(35.000, 0.000),
            rotation = 35.100,
            size = {width = 12.000, height = 2.000},
            deleted = false
        },
        {
            index = 9,
            offset = vec2(28.000, -9.000),
            rotation = 6.600,
            size = {width = 12.000, height = 2.000},
            deleted = false
        },
        {
            index = 10,
            offset = vec2(27.000, -7.000),
            rotation = -15.400,
            size = {width = 12.000, height = 2.000},
            deleted = false
        },
        {
            index = 11,
            offset = vec2(30.000, -10.000),
            rotation = 145.000,
            size = {width = 12.000, height = 2.000},
            deleted = false
        },
        {
            index = 12,
            offset = vec2(21.000, -27.000),
            rotation = 110.000,
            size = {width = 12.000, height = 2.000},
            deleted = false
        },
        {
            index = 13,
            offset = vec2(27.000, -67.000),
            rotation = -24.100,
            size = {width = 34.000, height = 12.000},
            deleted = false
        },
        {
            index = 14,
            offset = vec2(0.000, 0.000),
            rotation = 263.100,
            size = {width = 40.000, height = 15.000},
            deleted = false
        },
        {
            index = 15,
            offset = vec2(19.000, 11.000),
            rotation = -11.000,
            size = {width = 12.000, height = 2.000},
            deleted = false
        },
    },
    mapTexts = {
        {
            text = "Finish",
            position = vec2(-65.579, 14.018)
        },
        {
            text = "Start",
            position = vec2(49.782, -15.246)
        },
        {
            text = "TG-1",
            position = vec2(-115.583, 110.646)
        },
        {
            text = "TG-2",
            position = vec2(-234.891, 62.921)
        },
        {
            text = "TG-3",
            position = vec2(-116.460, 79.026)
        },
        {
            text = "TG-4",
            position = vec2(-105.933, 35.425)
        },
        {
            text = "TG-5",
            position = vec2(-23.470, 52.512)
        },
        {
            text = "TG-6",
            position = vec2(-48.911, -8.175)
        },
        {
            text = "NG-1",
            position = vec2(-9.872, 20.303)
        },
        {
            text = "OZ-1",
            position = vec2(19.078, -3.658)
        },
    },
    maxAllowedTransitions = 3,

    startPosition = vec3(-141.238, 1.252, 182.578),
    startRotation = -6.418,
    alternateStartPosition = vec3(-235.140, 0.548, 123.542),
    alternateStartRotation = 40.311,
    perfectEntrySpeed = 165,
    gatesTransparency = {
        normal = 0.0,
        start = 1.0,
        finish = 1.0,
        oz = 1.0,
        noGoZone = 1.0,
        trajectory = 1.0
    }
}