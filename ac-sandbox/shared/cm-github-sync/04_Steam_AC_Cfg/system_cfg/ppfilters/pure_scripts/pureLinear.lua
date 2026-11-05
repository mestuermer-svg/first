-- compensate pureLinear's changed mix of sun and ambient light
local _l_rgb_filter = ac.ColorCorrectionModulationRgb { color = rgb(1.019, 1.00, 1.00) }
ac.weatherColorCorrections[#ac.weatherColorCorrections + 1] = _l_rgb_filter

local CSP_VERSION = ac.getPatchVersionCode()
local curve = 1.00
local fog

-- This is an example, how to integrate a very own tonemapping into Pure ppf script,
-- if you want to use Pure's tonemapping debug options (clipping and curve debug)
-- First we define a variable to switch between an edit mode with sliders and the normal mode, here the sliders are nomore visible.
-- Such sliders will make the development of the tonemapping much easier, later we don't need this anymore - maybe.
local edit_custom_tonemap = false
-- then we define a table with the variables used in the c code
-- that is our LUA - C bridge, to access the tonemapping dynamically
-- and we define our c code of the tonemapping
local tonemap__custom = {
    -- definition of the variables
    values = {
        A     = 4.160,  -- contrast
        B     = 0.665,  -- inner gamma
        C     = 0.600,  -- low tone exponential gain
        D     = 1.124,  -- high tone exponential gain
        E     = 0.070,  -- vertical shift
        F     = 1.000,  -- gamma
        gain  = 1.250,
    },
    -- definition of the shader's c code
    -- you only define your tonemapping function here
    -- you MUST use "float tonemapping(float x)" as function name
    shader = [[
        float softclip(float x){
            return pow(abs( (gain/(D + exp(-A*(pow(abs(x),C)-B))))-E) , (1/lerp(1,F,min(1,sqrt(x))) ));
        }
        float tonemapping(float x){
            return softclip(x);
        }
    ]]
}


-- The following tonemapping table includes a function for rgb manipulation
local tonemap__custom_Colorsafe = {
    -- definition of the variables
    values = {
        A     = 4.160,  -- contrast
        B     = 0.665,  -- inner gamma
        C     = 0.600,  -- low tone exponential gain
        D     = 1.124,  -- high tone exponential gain
        E     = 0.070,  -- vertical shift
        F     = 1.000,  -- gamma
        gain  = 1.250,
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




local _l_current_tonemapping = 2 -- choose custom as default
local function set_tonemapping(dt, mode)

    if mode < 2 then
        -- Sensitometric
        pure.pp.setTonemapping(ac.TonemapFunction.Log)
        pure.pp.setTonemappingCurve(curve)
        ac.setPpTonemapGamma(pure.pp.getGammaModulator())
    elseif mode < 4 then
        -- here we set our custom tonemapping
        pure.pp.setTonemappingCurve(0)
        if mode < 3 then
            -- "Custom" chosen
            tonemap__custom.values.A = pure.script.ui.getValue("TONEMAPPING__A")
            tonemap__custom.values.B = pure.script.ui.getValue("TONEMAPPING__B")
            tonemap__custom.values.C = pure.script.ui.getValue("TONEMAPPING__C")
            tonemap__custom.values.D = pure.script.ui.getValue("TONEMAPPING__D")
            tonemap__custom.values.E = pure.script.ui.getValue("TONEMAPPING__E")
            tonemap__custom.values.F = pure.script.ui.getValue("TONEMAPPING__F")
            tonemap__custom.values.gain = pure.script.ui.getValue("TONEMAPPING__gain")
        
            tonemap__custom.values.F = tonemap__custom.values.F + curve
            
            pure.pp.setCustomTonemapping(tonemap__custom)
        else
            -- "Custom_Colorsafe" chosen
            tonemap__custom_Colorsafe.values.A = pure.script.ui.getValue("TONEMAPPING__A")
            tonemap__custom_Colorsafe.values.B = pure.script.ui.getValue("TONEMAPPING__B")
            tonemap__custom_Colorsafe.values.C = pure.script.ui.getValue("TONEMAPPING__C")
            tonemap__custom_Colorsafe.values.D = pure.script.ui.getValue("TONEMAPPING__D")
            tonemap__custom_Colorsafe.values.E = pure.script.ui.getValue("TONEMAPPING__E")
            tonemap__custom_Colorsafe.values.F = pure.script.ui.getValue("TONEMAPPING__F")
            tonemap__custom_Colorsafe.values.gain = pure.script.ui.getValue("TONEMAPPING__gain")
        
            tonemap__custom_Colorsafe.values.F = tonemap__custom_Colorsafe.values.F + curve
            
            -- use this function to set rgb tonemapping
            pure.pp.setCustomRGBTonemapping(tonemap__custom_Colorsafe)
        end

        local gamma = pure.pp.getGammaModulator()
        if gamma > 0.9999 and gamma < 1.0001 then
            -- gamma must not be 1.0, then CSP custom tonemapping is not working
            gamma = 0.9999
        end

        ac.setPpTonemapGamma(gamma)
    end

    _l_current_tonemapping = mode
end



-- This is called once while AC starts
function init_pure_script()

    --ac.setPpTonemapGamma(1.0)

    -- activate Pure's Exposure Calculation via Cubemap Brightness Estimation
    -- Cubemap reflections must NOT be static (Settings->Assetto Corsa->Video->Reflections frequency)
    -- "Use proper physically-based smapling" MUST be activated (Settings->Custom Shaders Patch->Reflections FX->General Cubemap Reflections)
    pure.exposure.useCBE(true)
    -- this will compensate the spectrum with missing sunlight in overcast sceneries
    pure.light.setSpectrumAdaption(0.0)
    -- this adapts the VAO parameters with overcast sceneries
    pure.light.setVAOAdaption(true)
    -- use new gamma for material lighting
    pure.light.setLambertGamma(1.7)

    -- sets a version and show it in Pure Config (PP)
    pure.script.setVersion(3.2)
    pure.script.setAuthor("Peter Boese")
    pure.script.resetSettingsWithNewVersion()


    if CSP_VERSION >= 2349 then
        -- CSP 0.1.80p204 (dynamic tonemapping)
        pure.script.ui.addRadioButtons("Tonemapping", _l_current_tonemapping, "Linear,Custom,Custom_Colorsafe")

        -- here we can create the sliders for the custom tonemapping
        -- If the name starts with "TONEMAPPING__", the slider will be moved in the "PP Tonemapping control" group
        pure.script.ui.addSliderFloat("TONEMAPPING__A",     tonemap__custom.values.A    , 0, 20)
        pure.script.ui.addSliderFloat("TONEMAPPING__B",     tonemap__custom.values.B    , 0, 1)
        pure.script.ui.addSliderFloat("TONEMAPPING__C",     tonemap__custom.values.C    , 0, 2)
        pure.script.ui.addSliderFloat("TONEMAPPING__D",     tonemap__custom.values.D    , 0, 2)
        pure.script.ui.addSliderFloat("TONEMAPPING__E",     tonemap__custom.values.E    , -0.1, 0.1)
        pure.script.ui.addSliderFloat("TONEMAPPING__F",     tonemap__custom.values.F    , 0, 4)
        pure.script.ui.addSliderFloat("TONEMAPPING__gain",  tonemap__custom.values.gain , 0, 2)
        
    else
        set_tonemapping(1, 1)
    end


    -- adjusting sun blinding effect
    --pure.config.set("shaders.sunblinding.cover", 0.5, true)
    --pure.config.set("shaders.sunblinding.light", 0.75, true)
    pure.config.set("shaders.sunblinding.iris", 0.5, true)



    pure.script.ui.addSeparator()
    pure.script.ui.addSliderFloat("mapping factor gamma", 0.0, 0.0, 2.0)
    pure.script.ui.addSliderFloat("spectrum adaption", 1.0, 0, 2)


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
        pure.script.tools.handleExposure(2, {method = 5, target = 3.0, mix = 0.50, superexposure = 0.35})
    else
        --pure.script.tools.handleExposure(2, {method = 5, target = 5.25, mix = 1.00, superexposure = 0.50})
        pure.script.tools.handleExposure(2, {method = 5, target = 2, mix = 1.00, fixedexposure = 0.15, superexposure = 0.15})
    end

    --[[
        If you like to use the eye-based exposure mode, try this:

    pure.script.tools.handleExposure(1, { autoexposure  = 0.85,  
                                          fixedexposure = 0.30, 
                                          superexposure = 0.75, 
                                          fixedmixmulti = 1.00 })                                      
    ]]

    pure.config.set("pp.brightness", 1.25, true)
end

-- This is called every frame
function update_pure_script(dt)


    -- For this ppfilter, an extented light dynamic is the base. So daylight (sun and ambient) is much higher then in Pure's default settings.
    pure.config.set("light.daylight_multiplier", 2.1, true)


    -- to get more brightness in the shadow regions, boost adv. ambi light and lower the shadows, but not when looking towards the sun!
    local cam_sun_face = pure.utils.CamFacesSun()
    pure.config.set("light.advanced_ambient_light", 1.0-0.5*cam_sun_face, true)
    

    -- We need to adapt the CSP lights to the higher dynamic too. Pure was build to prevent this, but many tests showed, that the AC/CSP engine is not
    -- realy capable of it. So we need to gain emissives strongly for day. 
    -- Due to we are using the exposure to control this, this control is very natural and adapts well to the current scenery.
    -- So this is still a solution of the tunnels problem and CSP lights are still realistic in their usage.
    pure.config.set("csp_lights.bounce", 2.1, true)
    local emissives = 1.00 + 0.15/pure.exposure.cbe.getValue()
    pure.config.set("csp_lights.emissive", emissives, true)
    

    curve = pure.script.ui.getValue("mapping factor gamma")

    pure.light.setSpectrumAdaption(pure.script.ui.getValue("spectrum adaption"))

    -- manage different tonemappings
    if CSP_VERSION >= 2349 then
        -- CSP 0.1.80p204 (dynamic tonemapping)
        set_tonemapping(dt, pure.script.ui.getValue("Tonemapping"))
    else
        set_tonemapping(dt, 0)
    end

    
    --_l_brightness_filter.brightness = 1 + night_compensate(0)

    --  some PP effects controlled by the world
    fog = pure.world.getFog()
    fog = fog * fog *0
    ac.setGlareBloomLuminanceGamma(1 + 0.20 * fog)
    ac.setGlareThreshold(math.max(0, 3.5 - 3.0 * fog))

    -- ###########################
    --      adapting godrays
    -- ###########################
    if pure.system.isVR then
        -- lower godrays
        pure.config.set("pp.godrays", 0.1, true)
    end

    -- use the script tools to do basic godrays handling
    -- # godrays are faded out, if camera is not in sun direction
    -- # godrays are dependent of Pure Config godrays setting 
    pure.script.tools.handleGodrays()
    
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
