local _l_exposure_LUT = {
--        exposure
        { 0.000,  1.00, 0.00, 0.00 },
        { 0.020,  1.00, 0.00, 0.00 },
        { 0.025,  0.75, 0.00, 0.00 },
        { 0.050,  0.25, 0.10, 0.05 },
        { 0.075,  0.05, 0.25, 0.30 },
        { 0.100,  0.00, 0.50, 0.90 },
        { 0.15,   0.00, 0.80, 1.00 },
        { 0.2,    0.00, 1.00, 0.50 },
        { 0.3,    0.00, 1.00, 0.25 },
        { 0.5,    0.00, 1.00, 0.05 },
        { 1.0,    0.00, 1.00, 0.00 },
    }
local _l_Exposure_lut
local _l_ExposureCPP = LUT:new(_l_exposure_LUT)



local _l_style = 0
local _l_style_table = {
    tonemap = {
        gInputBrightness = 0.0,
        gOutputBrightness = 0.0,
        gExponentStart = 0.0,
        gExponentHighFalloff = 0.0,
        gBlacklift = 0.0,
    },
    temperature = 1.0,
    saturation = 1.0,
}

local _l_ext_tonemapping_table = {
    gInputBrightness = 0.0,
    gOutputBrightness = 0.0,
    gExponentStart = 0.0,
    gExponentHighFalloff = 0.0,
    gBlacklift = 0.0,
}


local cam_sun_face = 0
local photo_realistic = 0.0
local photo_realistic_2 = 0.0
local photo_realistic_3 = 0.0
local photo_realistic_sqrt = 0.0
local softlook = 0
local softlook_day = 0
local softlook_day_2 = 0

local ae_measure_area__pos = vec2(0.0, 0.11)
local ae_measure_area__ext = vec2(0.8, 0.65)

local glare_settings = {
    Luminance = 0,
    BloomLevels = 0,
    ShapeLuminance = 0,
    ShapeBloomLuminance = 0,
    ShapeGhostLuminance = 0,
}

local tonemap__custom_RGB_HDR = {
    -- definition of the variables
    values = {
        gInputBrightness = 1.60,
        gOutputBrightness = 0.70,
        gExponentStart = 2.45,
        gExponentHighFalloff = 1.00,
        gBlacklift = 0.48,
        gStockHDR = false,
    },

    --[[
        Pure already provides some variables:

        gExposure       (float)
        gGamma          (float)
        gMappingFactor  (float)
        gDXGI_HDR       (bool)

        so you can use them in your shader
    ]]


    -- definition of the shader's c code
    -- you only define your tonemapping function here
    -- In this example, the tonemapping function gets the rgb vector, because it will be set with pure.pp.setCustomRGBTonemapping()
    -- you MUST use "float3 tonemapping(float3 x)" as function name
    shader = [[
        /*
        HDR conversion, to emulate a LDR-like look, but with higher tone resolution/precision
        by Peter Boese (2023)

        The base of this conversion is already a logarithmic input. The PPFilter HDR settings are used,
        to generate the logarithmic conversion of the linear tones from the render passes.
        The HDR settings from the pureHDR.ini:
            [EXT_DXGI_HDR]
                CUSTOM_YEBIS_TONEMAPPING=0
                POST_BRIGHTNESS=1.0
                POST_GAMMA=1
                POST_TONEMAPPING=0
                SUPPORTED=1
                YEBIS_BRIGHTNESS=1.0
        Those values will convert the linear tones into the logarithmic form,
        where we have the important tones (low - low mid) from 0 - 1. And all the mid and high tones
        are already compressed and ~ 6.15 will be the highest displayable tone.

        The logarithmic form is much better to use simple functions, to control the different ranges, like 
        ultra low (0 - 0.0125), low (0.125 - 0.5), low-mid (0.5 - 1.0), mid (1 - 2), high-mid (2 - 4) and high (4 - 8)
        So we can define the most important range from 0 - 1 and the HDR detail range from 1 - 6.15.
        */

        float3 tonemapping(float3 x){

            x = max(0, x);                                                          // cut negative values, if there would be some

            if(gStockHDR){
                x = pow(x * 0.01, 0.34);                                            // a cheap workaround to convert the stock CSP HDR parameters
            }

            float max_value = 6.15;                                                 // the maximum displayable tone of the logarithmic input
            
            x = pow(max(0, x*gInputBrightness),                                     // input brightness
                    (1.5+0.5*saturate(x))                                           // more contrast with low tones
                    * lerp(gBlacklift, 1, saturate(sqrt(x)*(1+7*gBlacklift)))       // lift ultra low tones
                    * 0.5                                                           // general gamma
                );
         
            x = pow(max(0, x), max(0, gExponentStart-gExponentHighFalloff*saturate(x))); // relative gamma

            x *= gOutputBrightness;                                                 // output brightness
            x = lerp(x, max_value, saturate(x/max_value));                          // high tone limitation
            
            return x;
        }
    ]]
}






local function set_style(style)

    _l_style = style

    if _l_style < 2 then
        -- neutral
        _l_style_table.tonemap.gInputBrightness = 0.0
        _l_style_table.tonemap.gOutputBrightness = 0.0
        _l_style_table.tonemap.gExponentStart = 0.0
        _l_style_table.tonemap.gExponentHighFalloff = 0.0
        _l_style_table.tonemap.gBlacklift = 0.0

        _l_style_table.temperature = 1.00
        _l_style_table.saturation = 0.95
    elseif _l_style < 3 then
        -- vibrant
        _l_style_table.tonemap.gInputBrightness = 0.0
        _l_style_table.tonemap.gOutputBrightness = 0.0
        _l_style_table.tonemap.gExponentStart = 0.0
        _l_style_table.tonemap.gExponentHighFalloff = 0.2
        _l_style_table.tonemap.gBlacklift = 0.0

        _l_style_table.temperature = 1.00
        _l_style_table.saturation = 1.15
    elseif _l_style < 4 then
        -- warm
        _l_style_table.tonemap.gInputBrightness = 0.0
        _l_style_table.tonemap.gOutputBrightness = 0.0
        _l_style_table.tonemap.gExponentStart = 0.0
        _l_style_table.tonemap.gExponentHighFalloff = 0.3
        _l_style_table.tonemap.gBlacklift = 0.0

        _l_style_table.temperature = 0.90
        _l_style_table.saturation = 1.00
    elseif _l_style < 5 then
        -- cool
        _l_style_table.tonemap.gInputBrightness = 0.0
        _l_style_table.tonemap.gOutputBrightness = 0.0
        _l_style_table.tonemap.gExponentStart = 0.0
        _l_style_table.tonemap.gExponentHighFalloff = 0.0
        _l_style_table.tonemap.gBlacklift = 0.0

        _l_style_table.temperature = 1.10
        _l_style_table.saturation = 0.95
    end

    pure.config.set("pp.color_temperature", _l_style_table.temperature, true)
    pure.config.set("pp.saturation", _l_style_table.saturation, true)
end








function pureLCS__init(params)

    local style = (params and params.style) and params.style or 1
    local photorealistic = (params and params.photorealistic) and params.photorealistic or 0.5
    local softlook = (params and params.softlook) and params.softlook or 0.5
    local sunblinding = (params and params.sunblinding) and params.sunblinding or 0.5
    
    if params and params.stock_hdr_paramters ~= nil then
        tonemap__custom_RGB_HDR.values.gStockHDR = params.stock_hdr_paramters
    end

    -- get ppfilter glare settings
    glare_settings.Luminance            = pure.yebis.get("glareLuminance")
    glare_settings.BloomLevels          = pure.yebis.get("glareBloomLevels")
    glare_settings.ShapeLuminance       = pure.yebis.get("glareShapeLuminance")
    glare_settings.ShapeBloomLuminance  = pure.yebis.get("glareShapeBloomLuminance")
    glare_settings.ShapeGhostLuminance  = pure.yebis.get("glareShapeGhostLuminance")

    -- check init params for tonemapping customizations
    if params and params.custom_tonemapping then
        -- values
        if params.custom_tonemapping.values and tonemap__custom_RGB_HDR.values then
            for k,v in pairs(tonemap__custom_RGB_HDR.values) do
                if params.custom_tonemapping.values[k]~=nil then
                    tonemap__custom_RGB_HDR.values[k] = params.custom_tonemapping.values[k]
                end
            end
        end
    end


    -- here we can create the sliders for the custom tonemapping
    -- If the name starts with "TONEMAPPING__", the slider will be moved in the "PP Tonemapping control" group
    pure.script.ui.addSliderFloat("TONEMAPPING__Input Brightness", tonemap__custom_RGB_HDR.values.gInputBrightness, 0.5, 4)
    pure.script.ui.addSliderFloat("TONEMAPPING__Output Brightness", tonemap__custom_RGB_HDR.values.gOutputBrightness, 0.25, 2)
    pure.script.ui.addSliderFloat("TONEMAPPING__Exponent", tonemap__custom_RGB_HDR.values.gExponentStart, 1, 4)
    pure.script.ui.addSliderFloat("TONEMAPPING__Exponent High Falloff", tonemap__custom_RGB_HDR.values.gExponentHighFalloff, 0.0, 4)
    pure.script.ui.addSliderFloat("TONEMAPPING__Blacklift Low Exposure", 0.480, 0, 1.0)
    pure.script.ui.addSliderFloat("TONEMAPPING__Blacklift High Exposure", 0.510, 0, 1.0)


    if pure.system.isHDR() then

        -- force Pure to bypass YEBIS
        pure.pp.forceYEBISBypass()

        -- set a custom HDR tone convertion
        pure.pp.setCustomRGBTonemapping(tonemap__custom_RGB_HDR)
        ac.setPpTonemapGamma(1)
    else
        -- do a failsafe tonemapping if HDR is not active  
        pure.pp.setTonemapping(ac.TonemapFunction.Uchimura)

        pure.script.ui.addStateString("ERROR", "HDR not properly set!!!")
        pure.script.ui.addSeparator()
    end

    -- generate the elements to control the sun blinding effect
--    pure.script.ui.addSliderFloat("sun blinding", 1.00, 0, 1.5)
--    pure.script.ui.addStateFloat("sun blinding state", 0)

    -- draw a separator line
    pure.script.ui.addSeparator()

    pure.script.ui.addRadioButtons("Style", style, "Neutral,Vibrant,Warm,Cool")

    pure.script.ui.addSliderFloat("photo-realistic", photorealistic, 0.0, 1.0, "Bigger sun light and ambient light difference. Adds camera effects too.")
    pure.script.ui.addSliderFloat("soft-look", softlook, 0.0, 1.0, "Creates a softer look with more distant fog.")
    pure.script.ui.addSliderFloat("sunblinding", sunblinding, 0.0, 1.0, "...")

    -- ambient light is now more linear and we can lower the threshold for car lights much lower
    pure.config.set("AI_headlights.ambient_light", 0.75, true)

    --pure.config.set("clouds2D.brightness", 0.75, true)

    -- set exposure control to eye-based...
    pure.script.tools.handleExposure(1, { autoexposure = 1.00, fixedexposure = 0.25, superexposure = 0.35, fixedmixmulti = 1.0 })

    pure.config.set("Scene.emissive_adaption", true, true)
    pure.config.set("csp_lights.bounce", 1.7, true)

    pure.pp.set("spice.MagicBloom.threshold", 4, true)
end




function pureLCS__set()

    pure.pp.set("pp.luma_invert", true, true)
end





function pureLCS__update(dt, params)

    -- get the index to retrieve the values from the exposure LUT
    -- The LUT is used to get specific values for certain exposure levels
    local exp = math.max(pure.exposure.getValue(), pure.mod.dayCurve(0.12, 0, 0.5))
    _l_Exposure_lut  = _l_ExposureCPP:get(exp)


    local sunblinding = pure.script.ui.getValue("sunblinding")
    cam_sun_face = pure.config.get("shaders.sunblinding.active") and pure.utils.CamFacesSun() * sunblinding or 0.0


    photo_realistic = pure.script.ui.getValue("photo-realistic")
    photo_realistic_2 = photo_realistic * photo_realistic
    photo_realistic_3 = photo_realistic * photo_realistic_2
    photo_realistic_sqrt = photo_realistic^0.5
    softlook = pure.script.ui.getValue("soft-look")
    softlook_day = (1-_l_Exposure_lut[2]) * softlook
    softlook_day_2 = softlook_day^2

    --pure.light.setSpectrumAdaption(0.75 * photo_realistic)

    local selected_style = pure.script.ui.getValue("Style")
    if _l_style ~= selected_style then
        set_style(selected_style)
    end


    -- check update offset params for tonemapping offset customizations
    if params and params.custom_tonemapping then
        -- values
        if params.custom_tonemapping.values then
            for k,v in pairs(params.custom_tonemapping.values) do
                if _l_ext_tonemapping_table[k]~=nil then
                    _l_ext_tonemapping_table[k] = v
                end
            end
        end
    end


    if pure.system.isHDR() then

        local photo_realistic_mod = photo_realistic^1.75

        -- in case you need some more advanced control via the current exposure, use this like in the "pure" ppf/script
        --_l_Exposure_lut = _l_ExposureCPP:get(pure.exposure.getValue())

        -- we define a variable here, to find out, if exposure is seriously lifted. While day at the track it should have around 0.017 to 0.02
        -- So if it is much higher, there is a need of more exposure and therefore we can control things with this information.
        local exp_boosted_for_visibility = math.lerpInvSat(pure.exposure.getValue(), 0.04, 0.07)

        -- we set the tonemapping shader values here. We get the values from the sliders...
        tonemap__custom_RGB_HDR.values.gInputBrightness = (pure.script.ui.getValue("TONEMAPPING__Input Brightness") + _l_style_table.tonemap.gInputBrightness + _l_ext_tonemapping_table.gInputBrightness)
                                                        * (1 + 0.375*photo_realistic_mod )
        tonemap__custom_RGB_HDR.values.gOutputBrightness = (pure.script.ui.getValue("TONEMAPPING__Output Brightness") + _l_style_table.tonemap.gOutputBrightness + _l_ext_tonemapping_table.gOutputBrightness)
                                                            * (1 + 0.275*_l_Exposure_lut[1]) -- adapt the HDR look for very low exposures
                                                            * (1.00 - 0.25*photo_realistic_mod^0.5 )
        tonemap__custom_RGB_HDR.values.gExponentStart   = (pure.script.ui.getValue("TONEMAPPING__Exponent") + _l_style_table.tonemap.gExponentStart + _l_ext_tonemapping_table.gExponentStart)
                                                        * (1 + 0.05*photo_realistic_mod)
                                                        * (1 - 0.20*math.max(_l_Exposure_lut[2]^0.5, 1-pure.mod.sun(0)))
                                                        * (1 + 0.35*cam_sun_face^0.67)

        tonemap__custom_RGB_HDR.values.gExponentHighFalloff = math.max(0, (pure.script.ui.getValue("TONEMAPPING__Exponent High Falloff") + _l_style_table.tonemap.gExponentHighFalloff + _l_ext_tonemapping_table.gExponentHighFalloff))
                                                            --* (1 + (1-_l_Exposure_lut[1])) -- adapt the HDR look for very low exposures

        -- fade the black lift for high and low exposures, so you can define different values for day and night
        tonemap__custom_RGB_HDR.values.gBlacklift = 1-math.lerp(
                                                        pure.script.ui.getValue("TONEMAPPING__Blacklift Low Exposure"),
                                                        pure.script.ui.getValue("TONEMAPPING__Blacklift High Exposure"),
                                                        math.lerpInvSat(pure.exposure.getValue(), 0.06, 0.15)
                                                    )

--[[
        -- SUN BLINDING EFFECT
        -- get the value from the "sun blinding" slider 
        local sun_blinding_setting = pure.script.ui.getValue("sun blinding")
        

        -- get the state of sun facing from Pure
        cam_sun_face = pure.utils.CamFacesSun() * sun_blinding_setting * 0.6666667
        -- show the current sun facing value
        pure.script.ui.setValue("sun blinding state", cam_sun_face*1.5)

        -- modulate and define the sunblinding with the value of the sunblinding slider
        pure.config.set("shaders.sunblinding.cover",        0.50*sun_blinding_setting, true)
        pure.config.set("shaders.sunblinding.blinding",     0.50*sun_blinding_setting^3, true)
        pure.config.set("shaders.sunblinding.iris",         0.75*sun_blinding_setting, true)
        pure.config.set("shaders.sunblinding.star_opacity", 6.00*sun_blinding_setting, true)
        pure.config.set("shaders.sunblinding.star_size",    1.30, true)
        pure.config.set("shaders.sunblinding.star_blur",    1.80, true)
        pure.config.set("shaders.sunblinding.star_style",   1.40, true)
        -- END OF SUN BLINDING EFFECT
    
        -- we can also boost the sunlight for more immersion
        pure.config.set("light.sun.level",              pure.mod.dayCurve(2.00, 2.50, 0.60), true)
        pure.config.set("light.sun.saturation",         pure.mod.dayCurve(0.70, 1.30, 0.90), true)
        pure.config.set("light.advanced_ambient_light", 2.5 - 2.0*cam_sun_face, true)
        pure.config.set("csp_lights.bounce",            2.0 + 2.0*_l_Exposure_lut[2], true)
]]
    else
        
    end

    

    -- apply gamma / so the PP adjustments slider can be used
    local tmp_gamma = pure.pp.getGammaModulator()
    tmp_gamma = tmp_gamma * (0.85 + softlook * 0.15 * softlook_day)
    if not pure.pp.YEBISisBypassed() then
        -- If HDR is not activated, YEBIS is also not forced. Then check the gamma value
        if tmp_gamma > 0.9999 and tmp_gamma < 1.0001 then
            -- gamma must not be 1.0, otherwise it it is 1.0, CSP custom tonemapping is not working
            tmp_gamma = 0.9999
        end
    end
    ac.setPpTonemapGamma(tmp_gamma)

    pure.config.set("pp.contrast", 1 + 0.005*softlook_day, true)
    

    -- set some specific Glare parameters with photorealism and exposure flash
    pure.yebis.set("glareThreshold", 3)
    pure.yebis.set("glareLuminance", glare_settings.Luminance * (1.0 + 1.0 * photo_realistic))
    pure.yebis.set("glareBloomLevels", math.floor(glare_settings.BloomLevels * (0.5 + 0.5 * photo_realistic)))
    pure.yebis.set("glareShapeLuminance", glare_settings.ShapeLuminance * (0.25 + 0.75*photo_realistic))
    pure.yebis.set("glareShapeBloomLuminance", glare_settings.ShapeBloomLuminance * (0.25 + 0.75*photo_realistic))
    pure.yebis.set("glareShapeGhostLuminance", glare_settings.ShapeGhostLuminance * pure.mod.sun(0) * 2 * math.saturateN(photo_realistic_3-0.50))


    -- modifing the world ligths with photorealism to have a higher contrast of sun and ambient light
    pure.config.set("light.sun.level", 1.0 + 0.25 * pure.mod.sun(0) * photo_realistic^1.5 + 0.2 * softlook_day, true)
    pure.config.set("light.ambient.level", 1.00 + 2*photo_realistic_2, true)


    pure.config.set("pp.brightness", (1 - 0.125*cam_sun_face^0.67), true)
    
    

    -- luminance based saturation
    -- less saturation when looking towards the sun in bright conditions
    -- less saturation of very dark tones in dark conditions
    pure.pp.set("pp.luma_saturation", math.lerp(    0.5,
                                                    (1 - 0.75 * cam_sun_face * (1-0.65*photo_realistic_2)) * (1 + 0.3 * softlook_day_2),
                                                    1-_l_Exposure_lut[2]
                                            )  
                                    , true)
    pure.pp.set("pp.luma_threshold", math.lerp( 0.15,
                                                1 - softlook_day * 0.60,
                                                1-_l_Exposure_lut[2]
                                            )
                                    , true)


    

    if cam_sun_face > 0 then
        pure.config.set("shaders.sunblinding.gain", sunblinding^2, true)
        pure.config.set("shaders.sunblinding.iris", sunblinding, true)
    end
    pure.config.set("shaders.sunblinding.booster", 2.0*sunblinding, true)

    -- reduce far fog exponent with softlook to get it more to the default wfx look
    pure.config.set("fog.far.exponent", 1.00 - 0.30 * softlook * (1 - pure.utils.CamIsInTunnel()), true)

    -- also make the sky softer
    pure.config.set("clouds2D.brightness", 1 + 0.5 * photo_realistic_3, true)
    pure.config.set("clouds2D.contrast", 1 - softlook_day_2 * 0.5, true)

    -- the idea is: for eye-based visuals (photo_realistic < 0.5), we limit the lowest possible exposure. So with low sunangles we still have
    -- enough exposure to see everything, because the eyes adapting to the darker ambient.
    pure.exposure.cbe.setLimits(math.lerp(0.070 - 0.038*math.saturateN(pure.mod.dayCurve(-1.0, 2.0, 0.5)), 0.023, photo_realistic_sqrt), pure.exposure.cbe.getHighLimit())


    -- with photorealism we shrink FOV of the Cubemap Brightness Estimation, so we have a more camera direction dependent exposure
    pure.exposure.cbe.setAnalysis( (0.0 + 0.70 * photo_realistic_2),
                                    1, -- exponent   / focus on the ground
                                    4 * photo_realistic_2) -- multiplier / focus on the ground


    -- AUTO - EXPOSURE controlling
    -- with photo realism we shrink the field of Autoexposure measurement
    -- This will give you the behavior of a cameras autoexposure control
    -- We bend the curve a bit, too have this effect just for big values of "photo_realistic"
    local measure_area_mod = (photo_realistic_2)
    ae_measure_area__pos:set(0.0, 0.11 + 0.11*measure_area_mod)
    ae_measure_area__ext:set(0.8 - 0.2*measure_area_mod, 0.65 - 0.10*measure_area_mod)
    ac.setAutoExposureMeasuringArea(ae_measure_area__pos, ae_measure_area__ext)
    local AE_boost  = measure_area_mod
                    * 0.5
                    * (0.5 + 0.5*_l_Exposure_lut[2])

    local bright_weather = (0.5 + 0.5*pure.world.getOvercast()) * (1-pure.world.getBadness()) * math.min(math.saturateN(pure.mod.dayCurve(-0.5, 1.5, 0.5)), 1-_l_Exposure_lut[2])
    local new_target = math.min(math.lerp(pure.exposure.yebis.getTarget() * (1 + AE_boost), 0.02, bright_weather), 
                                pure.exposure.cbe.getValue() * 0.5
                            )
    new_target = math.max(0.025, new_target)
    

    -- We can use the pure.exposure.yebis.getTarget() function here, because we use the expsosure handling tool, which sets the target!
    -- If you don't use the exposure handling tool, you can't do this! You would cause a feedback loop and expsoure would rise to infinite values!
    pure.exposure.yebis.setTarget(new_target)
    pure.exposure.yebis.setLimits(pure.exposure.yebis.getLowLimit(), pure.exposure.yebis.getHighLimit() * (1 + AE_boost))

    -- we gain the speed of the exposure adaption in photorealism
    local low   = 2.5 + 7.5*photo_realistic
    local high  = 2.0 + 3.0*photo_realistic
    pure.exposure.cbe.setAdaptionSpeeds(low, high)
    pure.exposure.yebis.setAdaptionSpeeds(low, high)


    pure.script.tools.handleGodrays(0, 0, 0.0, 0, 2.0)
end








