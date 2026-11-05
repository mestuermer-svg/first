
local _l_exposure_LUT = {
--        exposure
        { 0.000,  1.00, 0.00  },
        { 0.020,  1.00, 0.00  },
        { 0.025,  0.75, 0.00  },
        { 0.050,  0.25, 0.10  },
        { 0.075,  0.05, 0.25  },
        { 0.100,  0.00, 0.50  },
        { 0.15,   0.00, 0.80  },
        { 0.2,    0.00, 1.00  },
        { 0.3,    0.00, 1.00  },
        { 0.5,    0.00, 1.00  },
        { 1.0,    0.00, 1.00  },
    }
local _l_Exposure_lut
local _l_ExposureCPP = LUT:new(_l_exposure_LUT)


local tonemap__custom_RGB_HDR = {
    -- definition of the variables
    values = {
        gInputBrightness = 1.65,
        gOutputBrightness = 0.70,
        gExponentStart = 2.3,
        gExponentHighFalloff = 0.70,
        gBlacklift = 0.52,
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

        #define luminosityFactor float3(0.2126, 0.7152, 0.0722)                     // a standard luminosity vector
        float3 tonemapping(float3 x){

            x = max(0, x);                                                          // cut negative values, if there would be some

            float max_value = 6.15;                                                 // the maximum displayable tone of the logarithmic input
            
            x = pow(max(0, x*gInputBrightness),                                     // input brightness
                    (1.5+0.5*saturate(x))                                           // more contrast with low tones
                    * lerp(gBlacklift, 1, saturate(sqrt(x)*(1+7*gBlacklift)))       // lift ultra low tones
                    * 0.5                                                           // general gamma
                );

            float grayscale = float(dot(x, luminosityFactor));                          // calculate the luminance of the tone
            float low_tone_color_blind = pow(saturate((grayscale/(0.75*gExposure))),3); // determine the visibility of colorfulness

            x = lerp(float3(grayscale*0.95,grayscale*0.975,grayscale*1.025),        // fade to a blueish grey for lowest tones
                     x,
                     low_tone_color_blind
                );
            //x = lerp(float3(1,0,0), x, low_tone_color_blind);                     // use this to adjust the color blindness of the lowest tones
            
            x = pow(max(0, x), max(0, gExponentStart-gExponentHighFalloff*saturate(x))); // relative gamma

            x *= gOutputBrightness;                                                 // output brightness
            x = lerp(x, max_value, saturate(x/max_value));                          // high tone limitation
            
            return x;
        }
    ]]
}


-- This is called once while AC starts, or the ppfilter changed
function init_pure_script()

    -- this will compensate the spectrum with missing sunlight in overcast sceneries
    pure.light.setSpectrumAdaption(0.50)
    -- this adapts the VAO parameters with overcast sceneries
    pure.light.setVAOAdaption(1.0)
    -- use new gamma for material lighting
    pure.light.setLambertGamma(2.0)

    -- sets a version and show it in Pure Config (PP)
    pure.script.setVersion(1.0)
    pure.script.setAuthor("Peter Boese")
    -- if a script preset file was saved with an older version, the settings can be reset
    pure.script.resetSettingsWithNewVersion()

    -- here we can create the sliders for the custom tonemapping
    -- If the name starts with "TONEMAPPING__", the slider will be moved in the "PP Tonemapping control" group
    pure.script.ui.addSliderFloat("TONEMAPPING__Input Brightness", 1.65, 0.5, 4)
    pure.script.ui.addSliderFloat("TONEMAPPING__Output Brightness", 0.70, 0.25, 2)
    pure.script.ui.addSliderFloat("TONEMAPPING__Exponent", 2.30, 1, 4)
    pure.script.ui.addSliderFloat("TONEMAPPING__Exponent High Falloff", 0.725, 0.0, 4)
    pure.script.ui.addSliderFloat("TONEMAPPING__Blacklift Low Exposure", 0.520, 0, 1.0)
    pure.script.ui.addSliderFloat("TONEMAPPING__Blacklift High Exposure", 0.520, 0, 1.0)


    if pure.system.isHDR() then

        -- force Pure to bypass YEBIS
        pure.pp.forceYEBISBypass()

        -- set a custom HDR tone convertion
        pure.pp.setCustomRGBTonemapping(tonemap__custom_RGB_HDR)
        ac.setPpTonemapGamma(1)

        -- Define the world parameters to look nice in HDR
        -- Pure's default values are focused to look good in LDR. So the world lighting is already defined to help with the needed tonal compression.
        -- For HDR we can boost and lower some parameters for more dynamic
        pure.config.set("light.daylight_multiplier",        1.75, true)
        pure.config.set("clouds2D.brightness",              1.85, true)
        pure.config.set("clouds2D.contrast",                1.10, true)
        pure.config.set("light.sun.speculars",              1.00, true)
        pure.config.set("light.directional_ambient.level",  0.50, true)
        pure.config.set("light.sky.level",                  1.85, true)
        pure.config.set("moon.light",                       1.25, true)

        pure.config.set("reflections.saturation", 0.6, true)

        pure.config.set("csp_lights.emissive",  4.0, true)
        pure.config.set("csp_lights.displays",  2.0, true)

        pure.config.set("pp.saturation", 1.10, true)
    else
        -- do a failsafe tonemapping if HDR is not active  
        pure.pp.setTonemapping(ac.TonemapFunction.Uchimura)

        pure.script.ui.addStateString("ERROR", "HDR not properly set!!!")
        pure.script.ui.addSeparator()
    end

    -- generate the elements to control the sun blinding effect
    pure.script.ui.addSliderFloat("sun blinding", 1.00, 0, 1.5)
    pure.script.ui.addStateFloat("sun blinding state", 0)

    -- draw a separator line
    pure.script.ui.addSeparator()

    
    -- use the new ambient ligth model
    pure.config.set("light.ambient_model_V2", true, true)
    -- ambient light is now more linear and we can lower the threshold for car lights much lower
    pure.config.set("AI_headlights.ambient_light", 0.75, true)

    -- set exposure control to eye-based...
    pure.script.tools.handleExposure(1, {   autoexposure    = 1.00,
                                            fordriving      = true,
                                            fixedexposure   = 0.15,
                                            superexposure   = 0.25,
                                            fixedmixmulti   = 1.0,
                                            minimumexposure = 0.020 
                                        })
    
end


local cam_sun_face = 0

-- This is called every frame
function update_pure_script(dt)

    -- get the index to retrieve the values from the exposure LUT
    -- The LUT is used to get specific values for certain exposure levels
    local exp = math.max(pure.exposure.getValue(), pure.mod.dayCurve(0.12, 0, 0.5))
    _l_Exposure_lut  = _l_ExposureCPP:get(exp)
    

    if pure.system.isHDR() then

        -- we just find out here, if the Exposure control is set to "... driving focused"
        local driving_focused_exp = pure.script.ui.getValue("Exposure is driving focused")

        -- in case you need some more advanced control via the current exposure, use this like in the "pure" ppf/script
        --_l_Exposure_lut = _l_ExposureCPP:get(pure.exposure.getValue())

        -- we define a variable here, to find out, if exposure is seriously lifted. While day at the track it should have around 0.017 to 0.02
        -- So if it is much higher, there is a need of more exposure and therefore we can control things with this information.
        local exp_boosted_for_visibility = math.lerpInvSat(pure.exposure.getValue(), 0.04, 0.07)

        -- we set the tonemapping shader values here. We get the values from the sliders...
        tonemap__custom_RGB_HDR.values.gInputBrightness = pure.script.ui.getValue("TONEMAPPING__Input Brightness")
        tonemap__custom_RGB_HDR.values.gOutputBrightness = pure.script.ui.getValue("TONEMAPPING__Output Brightness")
                                                         * (1 + 0.275*_l_Exposure_lut[1]) -- adapt the HDR look for very low exposures
        tonemap__custom_RGB_HDR.values.gExponentStart = pure.script.ui.getValue("TONEMAPPING__Exponent")
        tonemap__custom_RGB_HDR.values.gExponentHighFalloff = math.max(0, pure.script.ui.getValue("TONEMAPPING__Exponent High Falloff"))
                                                            * (1 + 0.175*_l_Exposure_lut[1]) -- adapt the HDR look for very low exposures
        if driving_focused_exp then
            -- If the Exposure control is set to "... driving focused", compress the high tones a bit more, when exposure is lifted in darker areas
            tonemap__custom_RGB_HDR.values.gExponentHighFalloff = tonemap__custom_RGB_HDR.values.gExponentHighFalloff * (1 + 0.34*exp_boosted_for_visibility) 
        end

        -- fade the black lift for high and low exposures, so you can define different values for day and night
        tonemap__custom_RGB_HDR.values.gBlacklift = 1-math.lerp(
                                                        pure.script.ui.getValue("TONEMAPPING__Blacklift Low Exposure"),
                                                        pure.script.ui.getValue("TONEMAPPING__Blacklift High Exposure"),
                                                        math.lerpInvSat(pure.exposure.getValue(), 0.06, 0.15)
                                                    )


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
    else
        
    end

    

    -- apply gamma / so the PP adjustments slider can be used
    local tmp_gamma = pure.pp.getGammaModulator()
    if not pure.pp.YEBISisBypassed() then
        -- If HDR is not activated, YEBIS is also not forced. Then check the gamma value
        if tmp_gamma > 0.9999 and tmp_gamma < 1.0001 then
            -- gamma must not be 1.0, otherwise it it is 1.0, CSP custom tonemapping is not working
            tmp_gamma = 0.9999
        end
    end
    ac.setPpTonemapGamma(tmp_gamma)

end