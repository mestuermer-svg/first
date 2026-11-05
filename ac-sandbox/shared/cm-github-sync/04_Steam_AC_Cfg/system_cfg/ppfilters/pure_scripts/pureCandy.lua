local _l_exposure_LUT = {
--        exposure
        { 0.05,   1.00, 0.50,    0.420, 1.00, 1.00, 0.00  },
        { 0.065,  0.98, 0.46,    0.410, 1.00, 1.00, 0.00  },
        { 0.075,  0.92, 0.44,    0.360, 1.00, 0.90, 0.00  },
        { 0.087,  0.81, 0.40,    0.330, 1.00, 0.75, 0.00  },
        { 0.1,    0.70, 0.35,    0.290, 1.00, 0.50, 0.05  },
        { 0.15,   0.63, 0.22,    0.227, 0.75, 0.20, 0.15  },
        { 0.2,    0.55, 0.10,    0.260, 0.25, 0.05, 0.30  },
        { 0.3,    0.50, 0.10,    0.255, 0.00, 0.00, 0.60  },
        { 0.5,    0.50, 0.10,    0.250, 0.00, 0.00, 1.00  },
        { 1.0,    0.50, 0.10,    0.250, 0.00, 0.00, 1.00  },
    }
local _l_ExposureCPP = LUT:new(_l_exposure_LUT)
-- initialize with a statndard day exposure
local _l_Exposure_result = _l_ExposureCPP:get(0.03)



local CSP_VERSION = ac.getPatchVersionCode()

local cloud_shadow = 0
local cloud_shadow_sun = 0
local cloud_shadow_twilight = 0
local badness = 0
local night = 0
local occlusion = 0
local contrast = 1.0
local contrast_damp_day = 0
local contrast_damp_night = 0
local too_dark = 0
local gamma = 1.25
local new_gamma = 0

local candy = 0
local candy_all = 0
local candy_sqrt = 0


-- This is an example, how to integrate a very own tonemapping into Pure ppf script,
-- if you want to use Pure's tonemapping debug options (clipping and curve debug)

-- We now define a table with the variables used in the c code
-- that is our LUA - C bridge, to access the tonemapping dynamically
-- and we define our c code of the tonemapping
local tonemap__custom_Colorsafe = {
    -- definition of the variables
    values = {
        A     = 5.962,  -- contrast
        B     = 0.649,  -- inner gamma
        C     = 1.115,  -- low tone exponential gain
        D     = 1.030,  -- high tone exponential gain
        E     = 0.015,  -- vertical shift
        F     = 4.500,  -- gamma
        gain  = 1.000,
    },
    -- definition of the shader's c code
    -- you only define your tonemapping function here
    -- In this example, the tonemapping function gets the rgb vector, because it will be set with pure.pp.setCustomRGBTonemapping()
    -- you MUST use "float3 tonemapping(float3 x)" as function name
    shader = [[ 
        
        float softclip(float x){
            return pow(max(0, (gain/(D + exp(-A*(pow(max(0, x),C)-B))))-E) , (1/lerp(1,F,min(1,sqrt(x))) ));
        }

        /* RGB HSV functions you can use in your code
            hue2rgb(in float hue)
            rgb2hcv(in float3 rgb)
            hsv2rgb(in float3 hsv)
            hsl2rgb(in float3 hsl)
            rgb2hsv(in float3 rgb)
            rgb2hsl(in float3 rgb)
        */

        float3 SafeColor(float3 x){
            float3 uni = float3(softclip(x.r), softclip(x.g), softclip(x.b));
            float3 hsv_pre = rgb2hsv(x);
            float3 hsv_uni = rgb2hsv(uni);
            
            float diff = saturate(hsv_pre.y-hsv_uni.y);
            hsv_uni.y *= 1 + pow(diff, 0.67);
            hsv_uni.y = saturate(hsv_uni.y);
            return hsv2rgb(hsv_uni);
        }

        float3 tonemapping(float3 x){
            return SafeColor(x);
        }
    ]]
}


local _l_current_tonemapping = 4 -- choose Boese as default
local function set_tonemapping(dt, mode)

    if pure.pp.setTonemapping then
        -- if Pure tonemapping available (Pure 0.180 or higher)

        if mode < 2 then
            -- Sensitometric
            pure.pp.setTonemapping(ac.TonemapFunction.Sensitometric)
            
            if candy > 0 then
                -- if candy is used, leave the standard sensitometric (function 2, mapping factor = 1.0)
                ac.setPpTonemapUseHdrSpace(false)
                -- and gain the brightness before tonemapping
                ac.setPpTonemapMappingFactor(1 + candy)
                -- therefore lower the world's brightness | adapt the curve to the sunangle, because it mainly depends sunlight
                pure.light.setGlobalBrightness(1 / math.pow((1+candy), pure.mod.dayCurve(0.7, 1.1, 0.67)))
            else
                -- with 0 candy, reset to the YEBIS default
                ac.setPpTonemapUseHdrSpace(true)
            end

            -- define gamma
            new_gamma = 1.25

            -- do a color grading to fix some colors
            ac.setPpColorGradingIntensity(math.max(0.01, _l_Exposure_result[4]
                                                    -- for now just use sunangle functions to stop GC
                                                    * pure.mod.sun(0.75)
                                                    * pure.mod.twilight(0)))
            -- set a custom Bloom with this tonemapping
            ac.setGlareBloomLuminanceGamma(1.0)
            
        elseif mode < 3 then
            -- Uchimura
            pure.pp.setTonemapping(ac.TonemapFunction.Uchimura)
            pure.config.set("ppTonemapUchimura.maxDisplayBrightness", -0.98, true)
            pure.config.set("ppTonemapUchimura.contrast", 0.13 + 0.34*candy, true)
            pure.config.set("ppTonemapUchimura.linearSectionStart", 0.01, true)
            pure.config.set("ppTonemapUchimura.linearSectionLength", -0.02, true)
            --pure.config.set("ppTonemapUchimura.black", 0.0, true)
            pure.config.set("ppTonemapUchimura.pedestal", -0.002, true)
            pure.config.set("ppTonemapUchimura.gain", 0.125*candy, true)

            -- World brightness is neutral
            pure.light.setGlobalBrightness(1)

            -- define gamma
            new_gamma = 1.25

            -- don't use color grading with this fine tonemapping
            ac.setPpColorGradingIntensity(0)
            -- set a custom Bloom with this tonemapping
            ac.setGlareBloomLuminanceGamma(1.6 + 0.35*math.pow(candy, 0.1))

        elseif mode < 4 then
            -- Lottes
            pure.pp.setTonemapping(ac.TonemapFunction.Lottes)
            pure.config.set("ppTonemapLottes.contrast", 0.6 + 0.37*candy, true)
            pure.config.set("ppTonemapLottes.gamma", -0.03, true)
            pure.config.set("ppTonemapLottes.hdrMax", 0.6 - 0.2*candy, true)
            pure.config.set("ppTonemapLottes.midIn", -0.25, true)
            pure.config.set("ppTonemapLottes.midOut", -0.24, true)
            pure.config.set("ppTonemapLottes.gain", 0.125*candy, true)

            -- World brightness is neutral
            pure.light.setGlobalBrightness(1)

            -- define gamma
            new_gamma = 1.25

            -- don't use color grading with this fine tonemapping
            ac.setPpColorGradingIntensity(0)
            -- set a custom Bloom with this tonemapping
            ac.setGlareBloomLuminanceGamma(1.5 + 0.5*math.pow(candy, 0.1))

        elseif mode < 5 then
            -- Boese
            
            tonemap__custom_Colorsafe.values.A = pure.script.ui.getValue("TONEMAPPING__A")
            tonemap__custom_Colorsafe.values.B = pure.script.ui.getValue("TONEMAPPING__B")
            tonemap__custom_Colorsafe.values.C = pure.script.ui.getValue("TONEMAPPING__C")
            tonemap__custom_Colorsafe.values.D = pure.script.ui.getValue("TONEMAPPING__D")
            tonemap__custom_Colorsafe.values.E = pure.script.ui.getValue("TONEMAPPING__E")
            tonemap__custom_Colorsafe.values.F = pure.script.ui.getValue("TONEMAPPING__F")
            tonemap__custom_Colorsafe.values.gain = pure.script.ui.getValue("TONEMAPPING__gain")
        
            -- increase the contrast with candy
            tonemap__custom_Colorsafe.values.A = tonemap__custom_Colorsafe.values.A + candy
            -- vertically shift it down with candy, so the dark tones getting more black
            tonemap__custom_Colorsafe.values.E =tonemap__custom_Colorsafe.values.E - 0.015*candy_sqrt
            
            -- set the custom rgb tonemapping
            pure.pp.setCustomRGBTonemapping(tonemap__custom_Colorsafe)

            -- World brightness is neutral
            pure.light.setGlobalBrightness(1)

            -- define gamma
            new_gamma = 1.00

            -- don't use color grading with this fine tonemapping
            ac.setPpColorGradingIntensity(0)
            -- set a custom Bloom with this tonemapping
            ac.setGlareBloomLuminanceGamma(1.0 + 0.75*math.pow(candy, 0.5))
        end
    else
        -- Pure 0.165 or lower
        ac.setPpTonemapFunction(ac.TonemapFunction.Sensitometric)
    end

    -- set gamma
    new_gamma = new_gamma * (1 - 0.2*_l_Exposure_result[6] + 0.05*cloud_shadow_twilight)
    gamma = gamma * math.max(0, 1-dt*2) + new_gamma*dt*2
    local tmp_gamma = gamma * pure.pp.getGammaModulator()
    if tmp_gamma > 0.9999 and tmp_gamma < 1.0001 then
        -- gamma must not be 1.0, then CSP custom tonemapping is not working
        tmp_gamma = 0.9999
    end
    ac.setPpTonemapGamma(tmp_gamma)
end



function init_pure_script()

    -- sets a version and show it in Pure Config (PP)
    pure.script.setVersion(2.2)
    pure.script.setAuthor("Peter Boese")
    -- if a script preset file was saved with an older version, the settings can be reset
    pure.script.resetSettingsWithNewVersion()

    ac.useCubemapBrightnessEstimation(2.5, 0.67, 4)
    pure.exposure.cbe.setAdaptionSpeeds(0.25, 0.75)

    pure.script.ui.addText("Add bling bling with the Candy slider...")
    pure.script.ui.addSliderFloat("Candy", 0.85, 0, 1.5)

    pure.script.ui.addSeparator()

    pure.script.ui.addText("Monitor adjustments")
    pure.script.ui.addSliderFloat("black limit low exposure", 0.010, 0, 1)
    pure.script.ui.addSliderFloat("black limit high exposure", 0.030, 0, 1)

    pure.script.ui.addSeparator()

    if CSP_VERSION >= 2349 then
        -- CSP 0.1.80p204 (dynamic tonemapping)
        pure.script.ui.addRadioButtons("Tonemapping", _l_current_tonemapping, "Sensitometric (Yebis default),Uchimura 2017,Lottes 2016,Boese 2023")
        pure.script.ui.addSeparator()

        -- here we can create the sliders for the custom tonemapping
        -- If the name starts with "TONEMAPPING__", the slider will be moved in the "PP Tonemapping control" group
        pure.script.ui.addSliderFloat("TONEMAPPING__A",     tonemap__custom_Colorsafe.values.A    , 0, 20)
        pure.script.ui.addSliderFloat("TONEMAPPING__B",     tonemap__custom_Colorsafe.values.B    , 0, 1)
        pure.script.ui.addSliderFloat("TONEMAPPING__C",     tonemap__custom_Colorsafe.values.C    , 0, 2)
        pure.script.ui.addSliderFloat("TONEMAPPING__D",     tonemap__custom_Colorsafe.values.D    , 0, 2)
        pure.script.ui.addSliderFloat("TONEMAPPING__E",     tonemap__custom_Colorsafe.values.E    , -0.1, 0.1)
        pure.script.ui.addSliderFloat("TONEMAPPING__F",     tonemap__custom_Colorsafe.values.F    , 0, 10)
        pure.script.ui.addSliderFloat("TONEMAPPING__gain",  tonemap__custom_Colorsafe.values.gain , 0, 2)
    else
        set_tonemapping(1, 0)
    end

    pure.script.ui.addCheckbox("Spectrum Adaption", true)
    pure.script.ui.addCheckbox("VAO Adaption", true)

    -- use the new ambient ligth model
    pure.config.set("light.ambient_model_V2", true, true)
    -- ambient light is now more linear and we can lower the threshold for car lights much lower
    pure.config.set("AI_headlights.ambient_light", 0.5, true)

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
                                                  superexposure = 0.75,  -- for very dark sceneries, where you can barely see anything, the exposure can rise to this value
                                                  fixedmixmulti = 1.0 }) -- a multiplier of the automatically generated mix of fixed exposure
    
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
                       With the "superexposure", you can lift exposure even more, for very dark sceneries

            pure.script.tools.handleExposure(2, {method = 5, target = 4.0, mix = 1.0, superexposure = 0.75})
    --]]

    if pure.system.isVR then
        -- lower the exposure target in VR, also use a much lower superexposure 
        pure.script.tools.handleExposure(2, {method = 5, target = 3.0, mix = 0.50, fixedexposure = 0.25, superexposure = 0.30})
        pure.config.set( "ui.white_reference_point", 0.7, true)
    else
        pure.script.tools.handleExposure(2, {method = 5, target = 3.0, mix = 1.00, fixedexposure = 0.25, superexposure = 0.30})
    end


    pure.config.set( "moon.light", 1.25, true)



    --[[
        GROUND FOG SHADER - Weather dependent modifications

        The groundfog shader already uses weather variables. It controls density, fade out, scale, width and height with this variables.
        If you want to customize the groundfog look per weather with the ppfilter script, you can use those already existent variables and overwrite them, like:

        pure.script.weather.setVariable("PURE_GROUNDFOG_Density", "Mist", 1.0) -- default value 0.4
        pure.script.weather.setVariable("PURE_GROUNDFOG_FadeOut", "Fog", 25) -- default value 50
        pure.script.weather.setVariable("PURE_GROUNDFOG_Scale", "Sand", 1.0) -- default value 1.5
        pure.script.weather.setVariable("PURE_GROUNDFOG_Width", "Sand", 5.0) -- default value 3.0
        pure.script.weather.setVariable("PURE_GROUNDFOG_Height", "Sand", 5.0) -- default value 3.0

        Just have a look at the \extension\weather\pure\render\groundfog\render_groundfog.lua
        There you will find the default values in the Initialize_PURE_SHADER__groundfog() function.
    ]]
    
end


function set_pure_script()
    -- This function will be called if every script related things are initialized.
    -- So here is a good point to set some default values.

    pure.pp.set("spice.MagicBloom.active", true, true)
end


function update_pure_script(dt)

    -- For this ppfilter, an extented light dynamic is the base. So daylight (sun and ambient) is much higher then in Pure's default settings.
    pure.config.set("light.daylight_multiplier", 2.1, true)

    -- get the results of the exposure LUT
    -- limit minimum exposure with low sunangles
    local _l_exp = math.max(pure.mod.dayCurve(0.12, 0.05, 0.67), pure.exposure.cbe.getValue())
    _l_Exposure_result = _l_ExposureCPP:get(_l_exp)


    night = pure.mod.night(0)
    -- determine if the cam is in a building, if so, this returns 0
    occlusion = pure.camera.getOcclusion()

    cloud_shadow            = pure.world.getCloudShadow() * occlusion
    cloud_shadow_sun        = cloud_shadow * pure.mod.sun(0)
    cloud_shadow_twilight   = cloud_shadow * pure.mod.twilight(0)
    badness                 = math.pow(pure.world.getBadness() * pure.mod.twilight(0) * occlusion, 1.5)


    candy = pure.script.ui.getValue("Candy")
    candy_all = candy
    -- make a curve and don't do candy in the night
    candy = candy * candy * pure.mod.day(0)


    -- adjusting sun blinding effect
    pure.config.set("shaders.sunblinding.iris", 0.40 + 0.10 * candy, true)

    if pure.system.isHDR() then
        pure.config.set("shaders.sunblinding.cover", 0, true)
    else
        if pure.system.isVR then
            -- lower godrays
            pure.config.set("pp.godrays", 0.1, true)
        else
            -- lower godrays
            pure.config.set("pp.godrays", 0.5, true)
        end
        pure.config.set("shaders.sunblinding.cover", 0.60 + 0.25 * candy, true)
    end

    local cam_sun_face = pure.utils.CamFacesSun()

    

    -- set the displays brightness
    pure.config.set( "csp_lights.displays", 1 + 0.3*pure.mod.day(4)*candy_all, true)

    candy_sqrt = math.pow(candy,0.5)

    -- try to compansate emissives for daylight
    local emissives = 1.50 + 0.01 / (pure.exposure.cbe.getValue() ^ 1.75)
    pure.config.set( "csp_lights.emissive", emissives, true)
    pure.config.set( "csp_lights.bounce", 3.0, true)

    
    -- this will help the gain visibility of low tones in HDR mode. Therefore gamma could be set lower and HDR look improves.
    local hdr_black_limit = 0
    if pure.system.isHDR() then hdr_black_limit = 1.00 end

    -- limit black range
    contrast_damp_day = 0.1 * (pure.script.ui.getValue("black limit low exposure") + hdr_black_limit)
    contrast_damp_night = 0.1 * (pure.script.ui.getValue("black limit low exposure") + hdr_black_limit) * _l_Exposure_result[6]
    contrast = 1.0 - math.min(
        math.max(contrast_damp_day, contrast_damp_night),
        contrast_damp_day*_l_Exposure_result[5] + contrast_damp_night
    ) * (1.0 - 0.5*candy * (1 - 3*math.max(contrast_damp_day, contrast_damp_night)))


    -- manage different tonemappings
    if CSP_VERSION >= 2349 then
        -- CSP 0.1.80p204 (dynamic tonemapping)
        set_tonemapping(dt, pure.script.ui.getValue("Tonemapping"))
    else
        set_tonemapping(dt, 0)
    end
    

    -- due to the adjusted tonemapping, sunlitten textures are brighter, therfore lower sunlight
    pure.config.set( "light.sun.level", 1.00 - 0.2*candy_sqrt, true)
    pure.config.set( "light.sun.saturation", pure.mod.dayCurve(1.1, 1.1+1.0*candy_sqrt*pure.mod.sun(0), 0.65), true)
    -- boost the speculars for more blinky blinky
    pure.config.set( "light.sun.speculars", 0.40 + 0.5*candy_sqrt + 1.0*cam_sun_face*candy_sqrt, true)
    -- Also try to improve the effective dynamic, by gaining the reflections - mostly with low exposures.
    pure.config.set("reflections.level", 1.0 + 0.15*_l_Exposure_result[5], true)

    -- gain ambient light saturation with lower sun angles
    pure.config.set( "light.ambient.saturation", 1 + (0.25*candy)*sun_compensate(0), true)
    -- lower distant ambient light with lower sun angles
    pure.config.set( "light.distant_ambient.level", 0.5 * pure.mod.sun(0.5) * pure.mod.twilight(0.0), true)
    pure.config.set( "light.distant_ambient.saturation", 1.5, true)
    pure.config.set("light.advanced_ambient_light", 1.00-0.60*cam_sun_face*candy_sqrt, true)

    -- this is a counterpart to this. For low sun, gain the light
    pure.light.setLambertGamma(2.2 + 0.63*candy)
    

    
    pure.config.set( "pp.contrast", contrast, true)
    if pure.system.isVR then
        pure.config.set( "pp.brightness", 1.000 - (0.1*candy) + 3*(1-contrast), true)
    else
        pure.config.set( "pp.brightness", 1, true)
    end

    --pure.config.set( "clouds2D.brightness", 0.9 - 0.1*pure.mod.twilight(-5*math.pow(candy, 0.5)) - 0.040*candy, true)
    --pure.config.set( "clouds2D.brightness", 0.95, true)
    --pure.config.set( "clouds2D.contrast", 1.1 + 0.025*candy, true)


    -- this will compensate the spectrum with missing sunlight in overcast sceneries
    pure.light.setSpectrumAdaption(pure.script.ui.getValue("Spectrum Adaption"))

    -- this adapts the VAO parameters with overcast sceneries
    pure.light.setVAOAdaption(pure.script.ui.getValue("VAO Adaption"))


    -- bloom on high tone > 0.95 at night and > 1.5 at day
    local glare_threshold = (0.95 - math.min(0.90, (candy*0.25)) + 0.55 * _l_Exposure_result[5]*_l_Exposure_result[5])
    if pure.system.isHDR() then
        glare_threshold = glare_threshold*2.5
    end
    ac.setGlareThreshold(glare_threshold)
    --ac.setGlareThreshold(2)
    

    -- ###########################
    --      adapting godrays
    -- ###########################

    if pure.shader.isRunning("sunblinding") then
        -- use godrays as a real atmosphere effect, if sunblinding shader is running
        pure.script.tools.handleGodrays(3*math.saturate(pure.mod.sun(-0.5))*candy * (1 + 2*pure.world.getFog()), 0.1, nil, nil, (1-0.5*cam_sun_face))
    else

        -- use the script tools to do basic godrays handling
        -- # godrays are faded out, if camera is not in sun direction
        -- # godrays are dependent of Pure Config godrays setting 
        if pure.system.isVR then
            pure.script.tools.handleGodrays(5.0 * pure.mod.twilight(2) * pure.mod.sun(2), 4.0, nil, nil, 0.35)
        else
            pure.script.tools.handleGodrays(7.5 * pure.mod.twilight(2) * pure.mod.sun(2), 4.0, nil, nil, 0.40)
        end
        
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
end






