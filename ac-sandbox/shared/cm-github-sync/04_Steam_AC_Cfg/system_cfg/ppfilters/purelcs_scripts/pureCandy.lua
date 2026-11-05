


-- Here we gat the file location of the script
local script_folder = pure.script.getFolder()

-- With the different screen modes, we load the associated sub-script from the standard "pure" script.
if pure.system.isHDR() then
    dofile(script_folder.."\\pure\\pureLCS_hdr.lua")
elseif pure.system.isVR() then
    dofile(script_folder.."\\pure\\pureLCS_vr.lua")
else
    dofile(script_folder.."\\pure\\pureLCS_screen.lua")
end





-- define an initial gamma correction
local gamma = pure.system.isVR() and 1.0 or 0.95 -- a little bit more gamma in VR
-- This is called "inline condition". You can shorten code with this. You don't need "if then end" blocks to just set one value with a condition.
-- The syntax in Lua is: (condition) and (value if condition is true) or (value if condition is false)

-- define an initial contrast boost
local contrast_add = 0--pure.system.isVR() and 0.300 or 0.750 -- use less contrast boost in VR


local star_length = 0.0
local candy = 0.5

function init_pure_script()

    -- sets a version and show it in Pure Config (PP)
    pure.script.setVersion(2.0)
    pure.script.setAuthor("Peter Boese")
    -- if a script preset file was saved with an older version, the settings can be reset
    pure.script.resetSettingsWithNewVersion()

    pure.script.ui.addSeparator()
    if pure.system.isHDR() then
        pure.pp.forceYEBISBypass()
        pure.script.ui.addText("pureLCS script is in HDR mode")
    elseif pure.system.isVR() then
        pure.pp.forceYEBISBypass()
        pure.script.ui.addText("pureLCS script is in VR mode")
    else
        pure.script.ui.addText("pureLCS script is in Screen mode")
    end
    


    -- You can preset variables of the pure lcs sub-scripts.
    -- The expample code you see contains every possible setting.
    -- So just comment or uncomment the needed variable
    pureLCS__init({
        style = 1,              -- set the "neutral" color style by default
        photorealistic = pure.system.isVR() and 0.5 or 0.5,   -- set the default photrealism higher with pureCandy, but not in VR
        softlook = 0.0,
        sunblinding = 0.50,
        --polarization = false,
        custom_tonemapping = {
            values = {
            -- (Uchimura-Agx shader)    
                --P = 2.00,       -- max. display brightness
                a = 0.750 + contrast_add,    -- contrast
                m = 0.300,       -- linear section start
                l = 0.300,       -- linear section length
                --c = 1.00,       -- black
                --b = 0.00,       -- pedestral 
                gain = 1.00,    -- gain

                --agx_mix = 0.85, 
                --agx_mix_exp = 0.40, 
                --agx_slope = 1.25, 
                --agx_power = 2.40, 
                --agx_sat   = 0.99,

            -- Peter Boese HDR shader
                gInputBrightness = 1.40,
                --gOutputBrightness = 0.70,
                gExponentStart = 2.25,
                --gExponentHighFalloff = 0.725,
            }
        }
    })

    -- create a variable to control the sky brightness
    -- in general the sky can be dimmer, because the skydomes are dimmer with this filter
    --pure.script.weather.addVariable("sky", 0.5)
    --pure.script.weather.setVariable("sky", "noCLouds", 1.00)
    --pure.script.weather.setVariable("sky", "Clear", 1.00)
    --pure.script.weather.setVariable("sky", "ScatteredClouds", 0.75)

    -- add a candy slider to customize the exaggerated camera effects
    pure.script.ui.addSliderFloat("Candy", 0.5, 0.0, 1.0, "Exaggerated camera effects like lense flare or bloom")

    -- override settings from the pure sub-scripts
    if pure.system.isHDR() then
        pure.script.tools.handleExposure(2, {method = 5, target = 1.30, mix = 0.85, minimumexposure = 0.020, fixedexposure = 0.20, superexposure = 0.50})
    else
        pure.script.tools.handleExposure(2, {method = 5, target = 1.00, mix = 0.85, minimumexposure = 0.020, fixedexposure = 0.20, superexposure = 0.50})
    end

    -- override saturation from pureCandy.ini 
    ac.setPpSaturation(1.0)
    
--[[

    -- In Pure LCS you can modify the weather parameters.
    
    -- Note, those parameters are essential for the weather graphics and you could fall into a rabbit hole, if you change them drastically!

    pure.script.weather.defineWeather("Smoke", {
        clear = 0.9,                    -- [0..1] defines how clear the sky is and how many sunlight reaches the ground
        clouds = 0.2,                   -- [0..1] defines the amount of cloud coverage
        cloudsDensity = 0.0,            -- [0..1] defines the dense of the clouds
        fog = 0.30,                     -- [0..1] defines the view distance / amount of distance fog
        pollution = 0.8,                -- [0..1] defines the amount of near fog
        tint = rgb(0.56, 0.49, 0.63),   -- [rgb(r,g,b)] the overall tint of the weather / influences ambient light much
        ambi_mod = -0.3,                -- [-1..+] a modifier to scale the tint only while high sunangles (> 15°), will be faded to 0 with 0° sunangle
        saturation = 0.9,               -- [0..10] the saturation of the sunlight
        overcast = 0.0,                 -- [0..1] a definition to adjust the graphics for overcast ligting
        badness = 0.7,                  -- [0..1] a definition to adjust some internal algorithms like exposure a bit / mostly used for scripting
        thunder = 0.0,                  -- [0..1] defines the amount of thunder and lightning
    })


    -- You can also retrieve or set single weather paramters:
    local cloud_coverage = pure.script.weather.getWeatherParameter("BrokenClouds", "clouds")
    pure.script.weather.setWeatherParameter("BrokenClouds", "clouds", cloud_coverage*0.9)

]]

    -- use the SPICE PP suite
    pure.pp.UseSpice()

    --pure.config.set("Scene.brightness", 0.85, true)

    star_length = pure.yebis.get("glareShapeStarLength")
end


-- here we define a table of offset values for the tonemapping paramters.
-- We use it to adjust the tonemapping in the update function.
-- Uncomment the variables you want to modify in the update function
-- They are commented to speed up things...
local tonemap_update_offsets = {
    custom_tonemapping = {
        values = {
        -- Uchimura Agx variables
            --P = 0.0,  -- max. display brightness
            --a = 0.0,    -- contrast
            m = 0.0,  -- linear section start
            --l = 0.0,  -- linear section length
            --c = 0.0,  -- black
            --b = 0.0,  -- pedestral 
            --gain = 0.0,   -- gain
            --agx_mix = 0.0,
            --agx_mix_luma_exp = 0.0,
            --agx_slope = 0.0,
            --agx_power = 0.0,
            --agx_sat = 0.0,

        -- Peter Boese HDR variables
            --gInputBrightness = -0.30,
            --gOutputBrightness = -0.1,
            --gExponentStart = 0.2,
            --gExponentHighFalloff = 0.0,
        },
    },
}
-- In the sub-scripts, Uchimura-Agx is used for the Screen and VR mode, but a custom HDR tonemapping is used in HDR mode.
-- Both tonemapping shaders have completely different parameter names, so we can use them all togehter in such table!


function set_pure_script()
    -- This function will be called if every script related things are initialized.
    -- So here is a good point to set some default values.

    pure.pp.set("pp.luma_invert", true, true)

    pure.pp.set("spice.MagicBloom.active", true, true)
    pure.pp.set("spice.MagicBloom.strength", 1.5, true)

    pure.pp.set("spice.SensorNoise.active", true, true)
end



local metering_offset   = vec2(0, 0.12)
local metering_size     = vec2(1, 0.80)



function update_pure_script(dt)

    -- get the exisiting final exposure
    local exp = pure.exposure.getValue()

    -- use the values from the sliders
    local photorealistic = pure.script.ui.getValue("photo-realistic")
    candy = pure.script.ui.getValue("Candy")

    -- gain the target with sunset
    --pure.script.tools.handleExposure_setParameter("target_mod", pure.mod.sun(1.25))

    -- set tonemapping offsets
    -- Uchimura Agx contrast is initial 1.75 and we want it to be 1.0 in dark scenes (exposure > 0.25)
    -- But in eye-based visuals (photorealistic < 0.5), we neutralize this contrast boost
    tonemap_update_offsets.custom_tonemapping.values.a = -contrast_add * math.lerp(1, math.lerpInvSat(exp, 0.18, 0.25), photorealistic)
    --tonemap_update_offsets.custom_tonemapping.values.m = _d(-0.05 * (1 - 25*math.saturateN(pure.exposure.getValue()^2)))

    tonemap_update_offsets.custom_tonemapping.values.gain = 0.2 - 0.1*photorealistic
    
    -- compress high tones a bit more in HDR with photorealism
    tonemap_update_offsets.custom_tonemapping.values.gExponentHighFalloff = 0.1 * photorealistic

    -- run the pure LCS sub-script
    -- You can pass a table to customize variables like the tonemapping parameters
    pureLCS__update(dt, tonemap_update_offsets)


    -- don't use the spectrum adaption with pureCandy
    pure.light.setSpectrumAdaption(0)

    -- boost sunlight
    --pure.config.set("light.sun.level", 1 + 0.25 * photorealistic * pure.mod.sun(0), true)

    -- boost blue sky
    pure.config.set("sky.saturation", 1 + 3 * candy, true)
    pure.config.set("sky.level", 1.0 + (0.5 + candy) * (1 - pure.world.getOvercast()) * pure.mod.sun(0), true)
    
    -- lower distant ambient light to prevent too high texture brightness with boosted sun light
    pure.config.set("light.distant_ambient.level", 0.25 + 0.75*pure.world.getOvercast(), true)
    
    pure.config.set("light.sun.speculars", 1 + 3*candy, true)




     -- reduce gamma
    --pure.config.set("pp.gamma", 0.95 + 0.08*photorealistic^2, true)

    pure.config.set("stars.appearance", 1 + 10 * candy^2, true)


    -- we lower the glare threshold with candy for thos dramatic pictures
    -- it is already handled in the sub-script, so we just need to get the current value und then we modify it.
    local tmp

    if pure.system.isHDR() then

        pure.config.set("csp_lights.bounce", 2.00, true)

        pure.exposure.cbe.setLimits(0.033, pure.exposure.cbe.getHighLimit())
        pure.exposure.yebis.setLimits(0.035, pure.exposure.yebis.getHighLimit())

        tmp = pure.yebis.get("glareThreshold")
        pure.yebis.set("glareThreshold", (3.0 - 1.5*candy))
        
        tmp = pure.yebis.get("glareLuminance")
        pure.yebis.set("glareLuminance", tmp * (0.00 + 1.50*candy^2))

        ac.setPpColorGradingIntensity(0)
    else

        pure.config.set("clouds2D.brightness", pure.config.get("clouds2D.brightness") * (1.0 + 0.5*candy^2), true)
        pure.config.set("clouds2D.contrast", pure.config.get("clouds2D.contrast") * (1.0 + 0.5*candy^2), true)

        local day_limit = 0.03--pure.mod.dayCurve(0.036, 0.033, 0.7)

        pure.exposure.cbe.setLimits(day_limit, pure.exposure.cbe.getHighLimit())
        pure.exposure.yebis.setLimits(day_limit, pure.exposure.yebis.getHighLimit())

        pure.yebis.set("glareThreshold", (pure.mod.dayCurve(1.85, 3, 0.7) - 1.25*candy^2))

        ac.setPpColorGradingIntensity(0.30 + 0.45*pure.mod.twilight(0))

        pure.script.tools.handleExposure_setParameter("target_mod", pure.mod.dayCurve(1.15, 1.00, 0.67))
    end


    pure.config.set("pp.saturation", 0.90, true)
    pure.pp.set("pp.luma_saturation", 1.10, true)
    pure.pp.set("pp.luma_threshold", 0.35, true)


    -- use most of the screen to measure brightness with boosted AE-target
    ac.setAutoExposureMeasuringArea(metering_offset, metering_size)
    
    tmp = pure.yebis.get("glareShapeBloomLuminance")
    pure.yebis.set("glareShapeBloomLuminance", tmp * (0.5 + candy))

    tmp = pure.yebis.get("glareShapeGhostLuminance")
    pure.yebis.set("glareShapeGhostLuminance", tmp * (1 + candy^2))

    local new_star_length = star_length * candy^2
    pure.yebis.set("glareShapeStarLength", new_star_length)
    pure.yebis.set("glareShapeStarSecondaryLength", new_star_length)

    ac.setWeatherFakeShadowOpacity(1)


    pure.script.tools.handleGodrays(8*math.saturate(pure.mod.sun(-0.5))*candy^1.5 * (1 + 2*pure.world.getFog()), 0.1, nil, nil, 0.5)
    --[[
        You can also customize the godrays with this function:

        pure.script.tools.handleGodrays(length, angle_attenuation, hue, saturation, brightness)

        length - multiplier of the internal length (1.0 means no change)
        angle_attenuation - multiplier of the internal angle attenuation (1.0 means no change)
        hue - offset of the internal hue (0.0 means no change)
        saturation - multiplier of the internal godrays color saturation (1.0 means no change)
        brightness - multiplier of the internal godrays color brightness (1.0 means no change)
        pure.script.tools.handleGodrays( pure.mod.twilight(2) * pure.mod.sun(3)
            , 1 
            , 12.5 * (1 - pure.mod.sun(0))
            , pure.mod.dayCurve(1.00, 0.5, 0.35)
            , 1 )
    ]]
    
end