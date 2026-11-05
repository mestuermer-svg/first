-- LUTs (Look Up Tables) are a good way to define non linear value changes.
-- The first column is the index. In the following LUTs the index is CBE (Cubemap Brightness Estimation) value.
-- You can add more columns. They are calculated automatically, when calling LUT:get(index)
-- We use the LUT to control different things dependent on exposure.
local _l_exposure_LUT = {
--  exposure
    { 0.00,   0.10, 0.0, 1.00, 1.00, 0.00, 1.00, 1.00  },
    { 0.02,   0.10, 0.0, 1.00, 1.00, 0.00, 1.00, 1.00  },
    { 0.05,   0.10, 0.0, 1.00, 1.00, 0.00, 1.00, 0.55  },
    { 0.063,  0.17, 0.0, 1.00, 0.90, 0.00, 1.00, 0.35  },
    { 0.075,  0.25, 0.0, 1.00, 0.60, 0.00, 0.95, 0.15  },
    { 0.087,  0.60, 0.0, 1.00, 0.30, 0.00, 0.90, 0.00  },
    { 0.1,    0.80, 0.0, 1.00, 0.15, 0.05, 0.80, 0.00  },
    { 0.15,   1.00, 0.0, 0.75, 0.05, 0.15, 0.65, 0.00  },
    { 0.2,    0.75, 0.1, 0.25, 0.00, 0.30, 0.40, 0.00  },
    { 0.3,    0.25, 0.7, 0.00, 0.00, 0.60, 0.20, 0.00  },
    { 0.5,    0.05, 1.0, 0.00, 0.00, 1.00, 0.05, 0.00  },
    { 1.0,    0.00, 1.0, 0.00, 0.00, 1.00, 0.00, 0.00  },
}
local _l_ExposureCPP = LUT:new(_l_exposure_LUT)
-- initialize with a statndard day exposure
local _l_Exposure_lut = _l_ExposureCPP:get(0.03)

-- a simple brightness filter
--local _l_brightness_filter = ac.ColorCorrectionHsb { hue=0, saturation=1.0, brightness=1.125, keepLuminance=true }
--ac.weatherColorCorrections[#ac.weatherColorCorrections + 1] = _l_brightness_filter

-- compensate rgb shift with simple colorgrading
--local _l_rgb_filter = ac.ColorCorrectionModulationRgb { color = rgb(0.98,1.00,1.03) }
--ac.weatherColorCorrections[#ac.weatherColorCorrections + 1] = _l_rgb_filter



local CSP_VERSION = ac.getPatchVersionCode()

local cloud_shadow
local cloud_shadow_sun
local cloud_shadow_twilight
local cam_sun_face = 0
local badness
local fog
local occlusion = 0
local gamma = 1.0



-- This is called once while AC starts, or the ppfilter changed
function init_pure_script()

    -- tonemapping is set in the PPFilter ini
    --ac.setPpTonemapFunction(2)
    
    -- this will compensate the spectrum with missing sunlight in overcast sceneries
    pure.light.setSpectrumAdaption(1.0)
    -- this adapts the VAO parameters with overcast sceneries
    pure.light.setVAOAdaption(1.0)
    -- use new gamma for material lighting
    pure.light.setLambertGamma(1.50)
    --pure.light.adaptLambertGamma(false)



    -- sets a version and show it in Pure Config (PP)
    pure.script.setVersion(1.0)
    pure.script.setAuthor("Peter Boese")
    -- if a script preset file was saved with an older version, the settings can be reset
    pure.script.resetSettingsWithNewVersion()


    if pure.system.isVR then    
        pure.config.set("pp.godrays", 0.50, true)
    else
        pure.script.ui.addStateString("WARNING", "AC is not in VR mode!!!")
        pure.script.ui.addSeparator()
    end

    -- set sunblinding shader's VR tweak
    pure.config.set("shaders.sunblinding.VR_tweak", true, true)
    pure.script.ui.addSliderFloat("sun blinding", 0.5, 0, 1.0)

    pure.script.ui.addSeparator()

    pure.script.ui.addText("Monitor adjustments")

    -- create a float number slider in the PP tab of Pure Config app
    --                             name                        default value,   minimum, maximum
    pure.script.ui.addSliderFloat("black limit low exposure",  0.0,             0,       1)
    pure.script.ui.addSliderFloat("black limit high exposure", 0.0,             0, 1)

    -- draw a separator line
    pure.script.ui.addSeparator()

-- i just removed those sliders for a clearer UI
--[[
    pure.script.ui.addSliderFloat("gamma high sun", 1.65, 0, 3)
    pure.script.ui.addSliderFloat("gamma low exposure", 1.75, 0, 3)
    pure.script.ui.addSliderFloat("gamma mid exposure", 1.6, 0, 3)
    pure.script.ui.addSliderFloat("gamma high exposure", 1.5, 0, 3)

    -- create a state float, to output a number
    --                            name          initial value
    pure.script.ui.addStateFloat("final gamma", 0             )
    pure.script.ui.addSeparator()
]]


    -- use the new ambient ligth model
    pure.config.set("light.ambient_model_V2", true, true)
    -- ambient light is now more linear and we can lower the threshold for car lights much lower
    pure.config.set("AI_headlights.ambient_light", 0.5, true)


    -- ***************************************************
    -- * E X P O S U R E
    -- ***************************************************
    
    -- If you don't want to think about exposure handling, just let Pure do this.
    -- You can set a certain exposure handling mode.
    --[[
        Pure's exposure handling modes:

        0:
            deactivate Pure's extented exposure handling. Only a basic exposure control is running. You can setup your own exposure control then.

        1:
            This mode establishes a well balanced exposure control. It is more on the "eye simulation" side, than on "camera exposure" simulation.
            The mode will handle all needed parameters in the background, but it will generate a "use autoexposure" slider and a state output ("final exposure").
            Use the "autoexposure" slider, to adjust the mix of auto exposure. If the slider is at 1.0, the visible scene has a decent effect on the exposure
            calculation. This mix works the most for daytimes and bright sceneries.
            For dark sceneries like bad weather and nighttime, the exposure is faded to a static value. Esp. in interior view, this static exposure is
            realy fixed to a practical value, to avoid the exposure fluctuations in this view.

            pure.script.tools.handleExposure(1, { autoexposure = 0.85,   -- the mix of autoexposure
                                                  fordriving = false,    -- this will set the focus to driving, it boosts the exposure for dark sceneries
                                                  fixedexposure = 0.25,  -- the value of the fixed exposure, which is used for dark sceneries
                                                  fixedmixmulti = 1.0,   -- a multiplier of the automatically generated mix of fixed exposure
                                                  superexposure = 0.75,  -- for very dark sceneries, where you can barely see anything, the exposure can rise to this value
                                                  minimumexposure = 0.01,-- the lowest possible exposure
                                                 })
    
        2:
            This mode will give you a camera-like exposure handling. Controlling is fast and you have a selection of the common exposure models.
            You can choose between "Fixed", "YEBIS Autoexposure", "Cubemap Brightness Estimation", "AE+CBE" and "Hybrid"

            "Fixed" - just a static exposure. Use the "Target" slider to adjust the fixed exposure

            "YEBIS Autoexposure" - the exposure control from YEBIS PP suite. It analyzes the visible picture and tries to adjust.
                                   Use the "Mix" slider, to set the upper exposure limit.

            "Cubemap Brightness Estimation" - a new method, possible with CSP 1.76 and later. The brightness of the reflections is used, to determine
                                              the whole scene brightness around the camera. So this method "sees" everything and not only the visible view.
                                              Therefore it is much more stable, esp. in cockpit views.

            "AE+CBE" - a mix of YEBIS AE and CBE. Use the "Mix" slider to adjust the mix between both.

            "Hybrid" - This is a very advanced exposure method. It combines all 3 exposure methods and uses only the good parts of them.
                       If the scene brightness is very high (daytimes), it will use CBE and AE to determine the best exposure.
                       The darker the scene gets (twilight and nighttime), the more static the exposure gets.

            pure.script.tools.handleExposure(2, {   method = 5,
                                                    target = 4.0,
                                                    mix = 1.0,
                                                    fixedexposure = 0.25,  -- the value of the fixed exposure, which is used for dark sceneries (used in hybrid mode)
                                                    superexposure = 0.75,  -- for very dark sceneries, where you can barely see anything, the exposure can rise to this value
                                                    minimumexposure = 0.01,-- the lowest possible exposure
                                                })
    --]]
            
    if pure.system.isVR then
        -- In VR don't use AE that much, its better to have a more stable exposure with real head/cam movements.
        -- Also don't raise exposure that much in very low sceneries (superexposure).
        pure.script.tools.handleExposure(1, { autoexposure = 0.50, fordriving = false, fixedexposure = 0.25, superexposure = 0.35, fixedmixmulti = 1.0 })
    else
        pure.script.tools.handleExposure(1, { autoexposure = 0.85, fordriving = true, fixedexposure = 0.15, superexposure = 0.5, fixedmixmulti = 1.0 })
    end
end




-- This is called every frame
function update_pure_script(dt)

    -- For this ppfilter, an extented light dynamic is the base. So daylight (sun and ambient) is much higher then in Pure's default settings.
    pure.config.set("light.daylight_multiplier", 2.1, true)
    
    -- determine if the cam is in a building, if so, this returns 0
    occlusion = pure.camera.getOcclusion()

    -- set some helper variables, to define light situations
    -- for low sunangles or in buildings, they should be 0, because then it does not matter, how sunlight is influenced
    cloud_shadow            = pure.world.getCloudShadow() * occlusion
    cloud_shadow_sun        = cloud_shadow * pure.mod.sun(0)
    cloud_shadow_twilight   = cloud_shadow * pure.mod.twilight(0)
    badness = math.pow(pure.world.getBadness() * pure.mod.twilight(0) * occlusion, 1.5)
    fog = math.smootherstep(pure.world.getFog()) * pure.mod.twilight(0) * occlusion
    fog = fog * fog



    -- get the index to retrieve the values from the exposure LUT
    -- The LUT is used to get specific values for certain exposure levels
    -- Just prevent too low CBE values for low sunangles.
    local exp = math.max(pure.exposure.getValue(), pure.mod.dayCurve(0.12, 0, 0.5))
    _l_Exposure_lut  = _l_ExposureCPP:get(exp)


    -- use different lower black levels for interior and exterior views
    local black_multi = 0.05
    if ac.isInteriorView() then
        
    else
        black_multi = 0.025
    end

    
    -- this will help the gain visibility of low tones in HDR mode. Therefore gamma could be set lower in the ppfilter's HDR settings and HDR look improves.
    local hdr_black_limit = 0
    if pure.system.isHDR() then hdr_black_limit = 1.5 end

    -- Limit the color range, to simulate a visible but not usable lower light noise.
    local contrast_damp_day = black_multi * (pure.script.ui.getValue("black limit low exposure") + hdr_black_limit)
    local contrast_damp_night = black_multi * (pure.script.ui.getValue("black limit high exposure") + hdr_black_limit) * _l_Exposure_lut[5]
    pure.config.set( "pp.contrast",
                        1.00 - math.min(
                                        math.max(contrast_damp_day, contrast_damp_night),
                                        contrast_damp_day*_l_Exposure_lut[4] + contrast_damp_day*cloud_shadow_twilight + contrast_damp_night
                                    ),
                        true)

    -- Let the scene look warmer with nice weather, but colder with bad weather.
    -- Just a simple trick, to get in a mood   
    -- Also reduce blue light a bit (better for the eyes)                
    pure.config.set( "pp.color_temperature", 0.94 + 0.04*badness*pure.mod.dayCurve(1,0.25,0.67), true)    

    -- The filter has visibility as its primary goal. So we use gamma to shrink the dynamic and gain brightness.
    -- We use 4 gamma stages (high sun, bright light, mid light, low light and very low light)
    -- We need to interpolate the 4 gamma stages, dependent on their meaning to get one value we can set.
    gamma =   math.lerp(    
                    math.lerp(
                            math.lerp(
                                1.50, --pure.script.ui.getValue("gamma low exposure"),
                                1.47, --pure.script.ui.getValue("gamma high sun"),
                                math.min(1, math.max(0, pure.mod.dayCurve(0.0,1.2,0.67))) 
                            ),
                            1.45, --pure.script.ui.getValue("gamma mid exposure") ,
                            _l_Exposure_lut[1]),
                    1.4, --pure.script.ui.getValue("gamma high exposure"),
                    _l_Exposure_lut[2]
                )
    
    -- set the UI state variable, too show the value in Pure Config
    --pure.script.ui.setValue("final gamma", gamma)

    local tmp_gamma = gamma * pure.pp.getGammaModulator()
    if tmp_gamma > 0.9999 and tmp_gamma < 1.0001 then
        -- gamma must not be 1.0, then CSP custom tonemapping is not working
        tmp_gamma = 0.9999
    end
    ac.setPpTonemapGamma(tmp_gamma)






    -- get the state of the exposure meaning. Is it used for driving or for taking pictures
    local driving_focused_exp = pure.script.ui.getValue("Exposure is driving focused") and 1 or 0


    -- using Pure's internal Uchimura tonemapping
    pure.pp.setTonemapping(ac.TonemapFunction.Uchimura)
    pure.config.set("ppTonemapUchimura.maxDisplayBrightness", -0.95, true)
    pure.config.set("ppTonemapUchimura.contrast", 0.400, true)

    -- here we gain the gamma of low-mid tones, if the exposure is rising (0.03 -> 0.08)
    pure.config.set("ppTonemapUchimura.linearSectionStart", -0.28 + 0.08*_l_Exposure_lut[7], true)

    -- if exposure is focused for driving (to see things better on the ground), 
    -- compress the high tones. This will avoid clipping tones and a smoother reception of bright things
    pure.config.set("ppTonemapUchimura.linearSectionLength", 0.07 - 0.2*driving_focused_exp, true)
    
    -- we try to get lowest tones stable, when lifting gamma in the low-mid tones
    pure.config.set("ppTonemapUchimura.black", -0.35 - 0.07*_l_Exposure_lut[7], true)

    pure.config.set("ppTonemapUchimura.pedestal", -0.005, true)
    pure.config.set("ppTonemapUchimura.gain", 0, true)


    

    





    
    -- SUN BLINDING EFFECT
    if pure.shader.isRunning("sunblinding") then
        -- if the sun blinding shader is active

        -- use godrays as a fog effect, if sunblinding shader is running
        pure.script.tools.handleGodrays(1.5*math.saturate(pure.mod.sun(-0.5))*pure.world.getFog()^0.67, 0.125, nil, nil, 1)


        -- get the value from the "sun blinding" slider 
        local sun_blinding_setting = pure.script.ui.getValue("sun blinding")*2
        -- control the sun_blinding shader

        pure.config.set("shaders.sunblinding.cover",        0.0, true)
        pure.config.set("shaders.sunblinding.blinding",     0.25, true)
        pure.config.set("shaders.sunblinding.iris",         1.00*sun_blinding_setting^0.5, true)
        pure.config.set("shaders.sunblinding.star_opacity", 2.00*sun_blinding_setting^1.5, true)
        pure.config.set("shaders.sunblinding.star_size",    1.25, true)
        pure.config.set("shaders.sunblinding.star_blur",    1.50, true)
        pure.config.set("shaders.sunblinding.star_style",   0, true)
        pure.config.set("shaders.sunblinding.time_down",    0.5+0.25*sun_blinding_setting, true)
        
        -- get the state of sun facing from Pure
        cam_sun_face = pure.utils.CamFacesSun() * sun_blinding_setting * 0.6666667
    else
        -- reset it
        cam_sun_face = 0


        -- if the shader is not active, use the standard godrays

        -- ###########################
        --      adapting godrays
        -- ###########################

        -- use the script tools to do basic godrays handling
        -- # godrays are faded out, if camera is not in sun direction
        -- # godrays are dependent of Pure Config godrays setting 
        pure.script.tools.handleGodrays(pure.mod.twilight(2) * pure.mod.sun(3-2*cam_sun_face) * (1+1*cam_sun_face),
                                        nil,
                                        nil,
                                        nil,
                                        nil)

        --[[
        -- You can also customize the godrays with this function
        -- pure.script.tools.handleGodrays(length, angle_attenuation, hue, saturation, brightness)
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
    -- END OF SUN BLINDING EFFECT


    -- additional modulation of world parameters to gain the sun blinding effect
    -- The meaning is: sunlight is much brighter than ambient light, but for LDR image, ambient light (esp. adv ambi light) helps to see more details.
    -- So ambient light is only lowered and sunlight is only gained, if the cam looks into the sun.
    -- Additionally we raise the sky brightness a bit, to gain the HDR effect.
    pure.config.set("light.sun.saturation",         pure.mod.dayCurve(1.10, 1.40+0.05*cloud_shadow_sun) * (1-0.125*cam_sun_face), true)
    pure.config.set("light.sun.level",              1+0.5*cam_sun_face, true)
    pure.config.set("light.sun.speculars",          1+0.5*cam_sun_face, true)
    --pure.config.set("light.ambient.level",          1-0.25*cam_sun_face, true)
    pure.config.set("light.advanced_ambient_light", 0.8+0.2*math.max(badness, math.max(pure.world.getOvercast(), cloud_shadow_sun))-0.20*cam_sun_face, true)
    pure.config.set("light.sky.level",              1+0.75*cam_sun_face*pure.mod.sun(0), true)
    pure.config.set("clouds2D.brightness",          1+0.75*cam_sun_face, true)


    pure.config.set("moon.light", 0.25, true)

    -- Also try to improve the effective dynamic, by gaining the reflections - mostly with high exposures.
    pure.config.set("reflections.level", 0.9, true)
    pure.config.set("reflections.saturation", (1-0.5*cam_sun_face), true)

    -- We need to adapt the CSP lights to the higher dynamic too. Pure was build to prevent this, but many tests showed, that the AC/CSP engine is not
    -- realy capable of it. So we need to gain emissives strongly for day. 
    -- Due to we are using the exposure to control this, this control is very natural and adapts well to the current scenery.
    -- So this is still a solution of the tunnels problem and CSP lights are still realistic in their usage.
    pure.config.set("csp_lights.bounce", 2.3, true)
    local emissives = 1.50 + 0.20/pure.exposure.cbe.getValue()
    pure.config.set("csp_lights.emissive", emissives, true)
end