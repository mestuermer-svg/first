local _l_exposure_LUT = {
--        exposure
        { 0.05,   0.10, 1.00, 0.0, 1.00, 1.00, 0.00,    0.420  },
        { 0.063,  0.17, 1.00, 0.0, 1.00, 0.90, 0.00,    0.410  },
        { 0.075,  0.25, 1.00, 0.0, 1.00, 0.60, 0.00,    0.360  },
        { 0.087,  0.60, 0.90, 0.0, 1.00, 0.30, 0.00,    0.330  },
        { 0.1,    0.80, 0.70, 0.0, 1.00, 0.15, 0.05,    0.290  },
        { 0.15,   1.00, 0.50, 0.0, 0.75, 0.05, 0.15,    0.227  },
        { 0.2,    0.75, 0.25, 0.1, 0.25, 0.00, 0.30,    0.260  },
        { 0.3,    0.25, 0.00, 0.7, 0.00, 0.00, 0.60,    0.255  },
        { 0.5,    0.05, 0.00, 1.0, 0.00, 0.00, 1.00,    0.250  },
        { 1.0,    0.00, 0.00, 1.0, 0.00, 0.00, 1.00,    0.250  },
    }
local _l_Exposure_lut
local _l_ExposureCPP = LUT:new(_l_exposure_LUT)

-- a simple brightness filter
local _l_brightness_filter = ac.ColorCorrectionHsb { hue=0, saturation=1.0, brightness=1.0, keepLuminance=true }
ac.weatherColorCorrections[#ac.weatherColorCorrections + 1] = _l_brightness_filter

-- compensate rgb shift with simple colorgrading
local _l_rgb_filter = ac.ColorCorrectionModulationRgb { color = rgb(0.98,1.00,1.03) }
ac.weatherColorCorrections[#ac.weatherColorCorrections + 1] = _l_rgb_filter


-- This is called once while AC starts, or the ppfilter changed
function init_pure_script()

    --ac.setPpTonemapFunction(2)
    --pure.pp.setTonemapping(ac.TonemapFunction.Uchimura)
    
    -- this will compensate the spectrum with missing sunlight in overcast sceneries
    pure.light.setSpectrumAdaption(0.90)
    -- this adapts the VAO parameters with overcast sceneries
    pure.light.setVAOAdaption(1.0)
    -- use new gamma for material lighting
    pure.light.setLambertGamma(2.0)

    -- sets a version and show it in Pure Config (PP)
    pure.script.setVersion(2.1)
    -- if a script preset file was saved with an older version, the settings can be reset
    pure.script.resetSettingsWithNewVersion()

    -- set the limits for the CBE exposure
    pure.exposure.cbe.setLimits(0.068, 0.500)

    pure.script.ui.addSliderFloat("HDR peak brightness", 500, 400, 1600)
    pure.script.ui.addSliderFloat("Paperwhite", 0.3, 0, 1)
    pure.script.ui.addSliderFloat("sun blinding", 0.75, 0, 1.5)
    pure.script.ui.addStateFloat("sun blinding state", 0)

    -- draw a separator line
    pure.script.ui.addSeparator()

    -- create a float number slider in the PP tab of Pure Config app
    --                       name                        default value, minimum, maximum
    pure.script.ui.addSliderFloat("black limit low exposure", 0.0,           0,       1)
    pure.script.ui.addSliderFloat("black limit high exposure", 0.0, 0, 1)

    -- draw a separator line
    pure.script.ui.addSeparator()

    pure.script.ui.addSliderFloat("gamma high sun", 1.50, 0, 3)
    pure.script.ui.addSliderFloat("gamma low exposure", 1.90, 0, 3)
    pure.script.ui.addSliderFloat("gamma mid exposure", 2.10, 0, 3)
    pure.script.ui.addSliderFloat("gamma high exposure", 1.90, 0, 3)

    -- create a state float, to output a number
    --#region               name           initial value
    pure.script.ui.addStateFloat("final gamma", 0             )
    pure.script.ui.addStateFloat("final exposure", 0)

    -- use the new ambient ligth model
    pure.config.set("light.ambient_model_V2", true, true)

    pure.config.set( "clouds2D.brightness", 0.9, true)
    pure.config.set( "clouds2D.contrast", 1.075, true)
end

local overcast
local cloud_shadow
local cloud_shadow_sun
local cloud_shadow_twilight
local badness
local night = 0
local occlusion = 0
local exp = 0.2
local cam_sun_face = 0

-- This is called every frame
function update_pure_script(dt)

    pure.pp.setTonemapping(ac.TonemapFunction.Sensitometric)

    local peak_multi = math.pow(math.lerpInvSat(pure.script.ui.getValue("HDR peak brightness"), 400, 1600) * 1.5, 0.67)
    local paperwhite = math.lerpInvSat(pure.script.ui.getValue("Paperwhite"), 0, 1) * 2

    ac.setPpTonemapMappingFactor((1.0 + 0.05*pure.mod.day(-2)*peak_multi) + (paperwhite - 0.5))


    -- SUN BLINDING EFFECT
    -- get the value from the "sun blinding" slider 
    local sun_blinding_setting = pure.script.ui.getValue("sun blinding")


    -- get the state of sun facing from Pure
    cam_sun_face = pure.utils.CamFacesSun() * sun_blinding_setting * 0.6666667
    -- show the current sun facing value
    pure.script.ui.setValue("sun blinding state", cam_sun_face*1.5)


    pure.config.set("shaders.sunblinding.cover",        0, true)
    pure.config.set("shaders.sunblinding.iris",         0.75*sun_blinding_setting, true)
    pure.config.set("shaders.sunblinding.star_opacity", 0.75+0.25*sun_blinding_setting, true)
    pure.config.set("shaders.sunblinding.star_size",    1.25, true)
    pure.config.set("shaders.sunblinding.color",        0.0, true)


    -- additional modulation of world parameters to gain the sun blinding effect
    -- The meaning is: sunlight is much brighter than ambient light, but for LDR image, ambient light (esp. adv ambi light) helps to see more details.
    -- So ambient light is only lowered and sunlight is only gained, if the cam looks into the sun.
    -- Additionally we raise the sky brightness a bit, to gain the HDR effect.
    pure.config.set("light.sun.saturation",         1.0-0.125*cam_sun_face, true)
    pure.config.set("light.sun.level",              1+0.25*cam_sun_face, true)
    pure.config.set("light.sun.speculars",          1+1.5*cam_sun_face, true)
    pure.config.set("light.ambient.level",          1-0.25*cam_sun_face, true)
    pure.config.set("light.advanced_ambient_light", 1.0-0.50*cam_sun_face, true)
    pure.config.set("light.sky.level",              1+0.50*cam_sun_face, true)
    -- END OF SUN BLINDING EFFECT




    -- set a variable to define nighttime
    night = pure.mod.night(0)
    -- determine if the cam is in a building, if so, this returns 0
    occlusion = pure.camera.getOcclusion()

    -- adapt CSP lights to nighttimes
    pure.config.set("csp_lights.bounce", 1.0 + 0.5*night - 0.27*peak_multi, true)
    pure.config.set("csp_lights.emissive", 1.0 - 0.4*(1-pure.mod.twilight(0)) - 0.34*peak_multi, true)
    pure.config.set("csp_lights.displays", 1.00 - 0.27*peak_multi, true)

    -- expand the sensitivity for surrounded light to nighttimes
    ac.useCubemapBrightnessEstimation(2.5 + 0.50*night, 0.67, 3 + 2*night)
    -- make the reaction to bright light slower in nighttimes
    pure.exposure.cbe.setAdaptionSpeeds(1,2-night)

    -- get the index to retrieve the values from the exposure LUT
    -- The LUT is used to get specific values for certain exposure levels
    exp = exp * (1-dt) + math.max(pure.exposure.getValue(), pure.mod.dayCurve(0.12, 0, 0.5)) * dt
    _l_Exposure_lut = _l_ExposureCPP:get(exp*1.0)

    -- use a combination of CBE exposure and YEBIS autoexposure
    -- So the exposure is stabilized by CBE, but it can still react for low or high brightness in the view
    -- use 30% YEBIS AE
    pure.exposure.setCBEMix(1 - 0.3*_l_Exposure_lut[2])

    -- set some helper variables, to define light situations
    -- for low sunangles or in buildings, they should be 0, because then it does not matter, how sunlight is influenced
    overcast = pure.world.getOvercast() * occlusion * pure.mod.sun(0)
    cloud_shadow = math.max(pure.world.getOvercast() , pure.world.getCloudShadow()) * occlusion
    cloud_shadow_sun        = cloud_shadow * pure.mod.sun(0)
    cloud_shadow_twilight   = cloud_shadow * pure.mod.twilight(0)
    badness = math.pow(pure.world.getBadness() * pure.mod.twilight(0) * occlusion, 1.5)



    -- this will help the gain visibility of low tones in HDR mode. Therefore gamma could be set lower and HDR look improves.
    local hdr_black_limit = 0
    if pure.system.isHDR() then hdr_black_limit = 0.06 end

    -- use different lower black levels for interior and exterior views
    local black_multi = 0.1
    if ac.isInteriorView() then
        
    else
        black_multi = 0.05
    end

    -- Limit the color range, to simulate a visible but not usable lower light noise.
    local contrast_damp_day = black_multi * (pure.script.ui.getValue("black limit low exposure") + hdr_black_limit)
    local contrast_damp_night = black_multi * (pure.script.ui.getValue("black limit high exposure") + hdr_black_limit) * _l_Exposure_lut[6]
    pure.config.set( "pp.contrast",
                        1.00 - math.min(
                                        math.max(contrast_damp_day, contrast_damp_night),
                                        contrast_damp_day*_l_Exposure_lut[5] + contrast_damp_day*cloud_shadow_twilight + contrast_damp_night
                                    ),
                        true)

    pure.config.set("pp.saturation", 1.15 - 0.15*paperwhite, true)


    pure.config.set("clouds2D.brightness", 1.0 + 0.3*paperwhite - 0.15*peak_multi +0.50*cam_sun_face, true)
    pure.config.set("clouds2D.contrast", 0.9 + 0.1*paperwhite + 0.2*peak_multi, true)


    -- Let the scene look warmer with nice weather, but colder with bad weather.
    -- Just a simple trick, to get in a mood                   
    pure.config.set( "pp.color_temperature", 0.96 + 0.07*badness, true)               

    -- interpolate the 4 gamma stages, dependent on their meaning
    -- low exposure for daytimes, high sun for high sunangles, etc....
    local gamma =   math.lerp(    
                        math.lerp(
                                math.lerp(
                                    pure.script.ui.getValue("gamma low exposure"),
                                    pure.script.ui.getValue("gamma high sun"),
                                    math.min(1, math.max(0, pure.mod.dayCurve(0.0,1.2-1.2*cloud_shadow_sun,0.67))) 
                                ),
                                pure.script.ui.getValue("gamma mid exposure") * (1-pure.mod.dayCurve(0.15, 0.10, 0.7)*pure.world.getOvercast()),
                                _l_Exposure_lut[1]),
                        pure.script.ui.getValue("gamma high exposure"),
                        _l_Exposure_lut[3]
                    )
                    * pure.pp.getGammaModulator()
                    
    gamma = gamma * (1 - 0.175*peak_multi)
                    
    pure.script.ui.setValue("final gamma", gamma)
    ac.setPpTonemapGamma(gamma)

    local mid_low_light_comp = math.max(0, pure.script.ui.getValue("gamma mid exposure")-1)
                                * _l_Exposure_lut[1] * _l_Exposure_lut[1]
                                -- don't do the low light compesation in buildings
                                * occlusion
    
    -- raise contrast for middle exposure situations (twilight and overcast), to simulate a better dynamic of light
    --ac.setPpTonemapFilmicContrast((math.min(1, 0.65 - _d( mid_low_light_comp * 0.1 ))))

    -- use a brightness filter to change brightness
    _l_brightness_filter.brightness = 0.95
                                    -- lower brightness with bad weather
                                    + 0.10*badness
                                    -- make a boost for those difficult light sittuations, like twilight and overcast
                                    --+ (0.50 * (1-cloud_shadow_sun) * mid_low_light_comp * pure.mod.day(0.5))
                                    
    pure.script.ui.setValue("final exposure", pure.exposure.getValue() * _l_brightness_filter.brightness)

    -- lower light sensitivity a bit. CBE AE will react less to light changes
    pure.exposure.cbe.setSensitivity(0.9)
    -- adapt the CBE target to bad weather and nighttimes
    -- Force CBE to be lower in this situations.
    pure.exposure.cbe.setTarget(1.0 - 0.25*badness + 0.15*night)

    -- adapt YEBIS AE target to the scene
    local ae_target = _l_Exposure_lut[7] * (1 + pure.world.getFog() * pure.mod.day(0)) --* (1 + 2.0*(1-pure.utils.CamFacesSun()))
    ac.setAutoExposureTarget(ae_target*(0.1 + 0.05*cloud_shadow_sun))

    -- adapt the Color LUT to the current exposure (less correction with higher exposure/lower light)
    ac.setPpColorGradingIntensity(math.max(0.00, _l_Exposure_lut[4]
                                                    -- for now just use sunangle functions to stop GC
                                                    * pure.mod.sun(0.75)
                                                    * pure.mod.twilight(-1)))


    -- ###########################
    --      adapting godrays
    -- ###########################

    -- use the script tools to do basic godrays handling
    -- # godrays are faded out, if camera is not in sun direction
    -- # godrays are dependent of Pure Config godrays setting 
    pure.script.tools.handleGodrays(nil, nil, nil, nil, 2)
    
    --[[
    -- You can also customize the godrays with this function
    -- pure.script.tools.handleGodrays(length, hue, saturation, brightness)
       length - multiplier of the internal length (1.0 means no change)
       angle attenuation - multiplier of the internal angle attenuation (1.0 means no change)
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
    