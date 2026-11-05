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
    { 0.1,    0.90, 0.0, 1.00, 0.15, 0.05, 0.80, 0.00  },
    { 0.15,   1.00, 0.0, 0.75, 0.05, 0.15, 0.65, 0.00  },
    { 0.2,    0.50, 0.1, 0.25, 0.00, 0.30, 0.40, 0.00  },
    { 0.3,    0.25, 0.7, 0.00, 0.00, 0.60, 0.20, 0.00  },
    { 0.5,    0.05, 1.0, 0.00, 0.00, 1.00, 0.05, 0.00  },
    { 1.0,    0.00, 1.0, 0.00, 0.00, 1.00, 0.00, 0.00  },
}
local _l_ExposureCPP = LUT:new(_l_exposure_LUT)
-- initialize with a standard day exposure
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
local driving_focused_exp = false
local photo_realistic = 0.0
local interior = true

local ae_measure_area__pos = vec2(0.0, 0.11)
local ae_measure_area__ext = vec2(0.8, 0.65)


-- This is an example, how to integrate a very own tonemapping into Pure ppf script,
-- if you want to use Pure's tonemapping debug options (clipping and curve debug)

-- We now define a table with the variables used in the c code
-- that is our LUA - C bridge, to access the tonemapping dynamically
-- and we define our c code of the tonemapping
local tonemap__custom = {
    -- definition of the variables
    values = {
        P = 2.00, 
        a = 1.00, 
        m = 0.29, --0.30
        l = 0.40, 
        c = 1.00, 
        b = 0.00, 
        gain= 1.00,
        agx_mix = 0.85, --0.50
        agx_mix_exp = 0.40, --0.50
        agx_slope = 1.25, --1.20
        agx_power = 1.75, --2.40
        agx_sat   = 0.99, --0.65
    },
    -- definition of the shader's c code
    -- you only define your tonemapping function here
    -- you MUST use "float tonemapping(float x)" as function name

    --[[
        AgX Minimal variant from https://www.shadertoy.com/view/cd3XWr
        by bwrensch which is a fork of the AgX Minimal of Troy Sobotka
        // https://github.com/sobotka/AgX
        //
        // using a 6th order polynomial approximation instead
        // of the more complex sigmoid function or lookup table.
        //
        // Some more details here: 
        // https://iolite-engine.com/blog_posts/minimal_agx_implementation

        converted to CSP Shaders by Peter Boese
    ]]


    --[[
        Uchimura - AgX

        The main intention behind this special tonemapping is to use Uchimura's nice dynamics compression but
        also using AgX's different high tone saturation handling. 
    ]]

    shader = [[

    #define luminosityFactor float3(0.2126, 0.7152, 0.0722)

    // Mean error^2: 3.6705141e-06
    float3 agxDefaultContrastApprox(float3 x) {
        float3 x2 = x * x;
        float3 x4 = x2 * x2;
        
        return  + 15.5     * x4 * x2
                - 40.14    * x4 * x
                + 31.96    * x4
                - 6.868    * x2 * x
                + 0.4298   * x2
                + 0.1191   * x
                - 0.00232;
    }

    float3 agx(float3 val) {

        float3x3 agx_mat = float3x3(
          0.842479062253094, 0.0423282422610123, 0.0423756549057051,
          0.0784335999999992,  0.878468636469772,  0.0784336,
          0.0792237451477643, 0.0791661274605434, 0.879142973793104);

        float min_ev = -12.47393f;
        float max_ev = 4.026069f;
      
        // Input transform
        val = mul(agx_mat, val);
        
        // Log2 space encoding
        val = clamp(log2(val), min_ev, max_ev);
        val = (val - min_ev) / (max_ev - min_ev);
        
        // Apply sigmoid function approximation
        val = agxDefaultContrastApprox(val);
      
        return val;
    }

    float3 agxEotf(float3 val) {
        float3x3 agx_mat_inv = float3x3(
          1.19687900512017, -0.0528968517574562, -0.0529716355144438,
          -0.0980208811401368, 1.15190312990417, -0.0980434501171241,
          -0.0990297440797205, -0.0989611768448433, 1.15107367264116);
          
        // Undo input transform
        return mul(agx_mat_inv, val);
    }

    float3 agxLook(float3 val) {
        float luma = dot(val, luminosityFactor);
        
        // Default
        float3 offset = float3(0.0, 0.0, 0.0);
        float3 slope = float3(agx_slope, agx_slope, agx_slope);
        float3 power = float3(agx_power, agx_power, agx_power);
        float sat = agx_sat;
        
        // ASC CDL
        val = pow(max(0, val * slope + offset), power);
        return luma + sat * (val - luma);
    }

    float uchimura(float x) {
        // Uchimura 2017, "HDR theory and practice"
        // Math: https://www.desmos.com/calculator/gslcdxvipg
        // Source: https://www.slideshare.net/nikuque/hdr-theory-and-practicce-jp
        float l0 = ((P - m) * l) / a;
        float L0 = m - m / a;
        float L1 = m + (1.0 - m) / a;
        float S0 = m + l0;
        float S1 = m + a * l0;
        float C2 = (a * P) / (P - S1);
        float CP = -C2 / P;
    
        float w0 = 1.0 - smoothstep(0.0, m, x);
        float w2 = step(m + l0, x);
        float w1 = 1.0 - w0 - w2;
    
        float T = m * pow(abs(x / m), c) + b;
        float S = P - (P - S1) * exp(CP * (x - S0));
        float L = m + a * (x - m);
    
        return T * w0 + L * w1 + S * w2;
    }

    float3 RGB_Uchimura_AgX(float3 x){

        float luma = saturate(dot(x, luminosityFactor));
        
        float3 col = agx(x);
        col = agxLook(col);
        col = agxEotf(col);

        x = lerp(x, col, agx_mix * pow(luma, agx_mix_exp));

        x *= gain;
        x = float3(uchimura(x.r), uchimura(x.g), uchimura(x.b));

        return x;
    }

    float3 tonemapping(float3 x){
        return RGB_Uchimura_AgX(x);
    }
]]
}


local _l_init = true
local _l_current_tonemapping = 2 -- choose Uchimura as default
local function set_tonemapping(dt, mode)

    -- create a modifier for the tonemappings. If exposure is focused for driving, compress hightones,
    -- but not realy for high sunangles. The compression should be big with low sunangles, where the sky is bright,
    -- but the ground is dark.
    local driving_exp_mod = driving_focused_exp and (pure.mod.dayCurve(1, 0.2, 0.67)) or 0.0

    if mode < 2 then
        -- Sensitometric
        if pure.system.isHDR then
            pure.pp.setTonemapping(ac.TonemapFunction.Sensitometric)
        else
            pure.pp.setTonemapping(ac.TonemapFunction.Sensitometric)
        end

    elseif mode < 4 then

        local dyn_range_adjust = _l_Exposure_lut[1]^1.5
        local dyn_range_adjust_inv = 1-dyn_range_adjust
        local dyn_range_adjust_dark = _l_Exposure_lut[6]^2
        local dyn_range_adjust_dark_inv = 1-dyn_range_adjust_dark
        --local ultra_dark = 1 - _l_Exposure_lut[4]^0.34

        local uchimura__maxDisplayBrightness = -0.95 + 0.15*cam_sun_face

        local uchimura__contrast    = math.lerp(
                                            0.7 + 0.20*_l_Exposure_lut[7],
                                            1.4 - 0.6*(1-_l_Exposure_lut[3]),
                                        photo_realistic)

        --uchimura__contrast = uchimura__contrast * (1 + ultra_dark)                            

        local uchimura__linearSessionStart  = math.lerp(
                                                    -0.257, -- -0275
                                                    (interior and -0.275 or -0.265 ),
                                                photo_realistic^0.34)

        --uchimura__linearSessionStart = math.lerp(uchimura__linearSessionStart, -0.299, ultra_dark)
                                            
        local uchimura__linearSectionLength = math.lerp(
                                                    0.3 - 0.2*driving_exp_mod,
                                                    0.3 - 0.2*driving_exp_mod*dyn_range_adjust_dark_inv - 0.1*dyn_range_adjust_dark - 0.3*dyn_range_adjust,
                                                photo_realistic)
                                                
        local uchimura__black   = math.lerp(
                                        0.2 - 0.2*_l_Exposure_lut[7] + 0.07*cam_sun_face,
                                        0.00 + 0.07*cam_sun_face,
                                    photo_realistic)

        local uchimura__gain    = math.lerp(
                                        -0.325 - 0.08*cam_sun_face,
                                        -0.325 - 0.08*cam_sun_face - (interior and 0.2 or 0.2)*_l_Exposure_lut[7] + 0.3*(1-_l_Exposure_lut[3]),
                                    photo_realistic)
                                

        if mode < 3 then 
            -- using Pure's internal Uchimura tonemapping
            pure.pp.setTonemapping(ac.TonemapFunction.Uchimura)
            pure.config.set("ppTonemapUchimura.maxDisplayBrightness", uchimura__maxDisplayBrightness, true)
            pure.config.set("ppTonemapUchimura.contrast", uchimura__contrast, true)
            pure.config.set("ppTonemapUchimura.linearSectionStart", uchimura__linearSessionStart, true)
            pure.config.set("ppTonemapUchimura.linearSectionLength", uchimura__linearSectionLength, true)
            pure.config.set("ppTonemapUchimura.black", uchimura__black, true)
            pure.config.set("ppTonemapUchimura.gain", uchimura__gain, true)
        elseif not _l_init then
            -- using Pure's custom Uchimura-Agx tonemapping shader
        
            -- we get the values from the sliders
            tonemap__custom.values.P    = pure.script.ui.getValue("TONEMAPPING__maxDisplayBrightness") + uchimura__maxDisplayBrightness
            tonemap__custom.values.a    = pure.script.ui.getValue("TONEMAPPING__contrast") + uchimura__contrast
            tonemap__custom.values.m    = math.max(0.001, pure.script.ui.getValue("TONEMAPPING__linearSectionStart") + uchimura__linearSessionStart)
            tonemap__custom.values.P    = math.max(tonemap__custom.values.P, tonemap__custom.values.m + 0.01)
            tonemap__custom.values.l    = math.min(1-math.max(0, tonemap__custom.values.m), pure.script.ui.getValue("TONEMAPPING__linearSectionLength") + uchimura__linearSectionLength)
            tonemap__custom.values.c    = pure.script.ui.getValue("TONEMAPPING__black") + uchimura__black
            tonemap__custom.values.b    = pure.script.ui.getValue("TONEMAPPING__pedestal")
            tonemap__custom.values.gain = pure.script.ui.getValue("TONEMAPPING__gain") + uchimura__gain

            -- agx_mix defines the possible use of AgX
            -- In this tonemapping shader, AgX has more influence on high tones.                        
            tonemap__custom.values.agx_mix      = pure.script.ui.getValue("TONEMAPPING__agx_mix")
            -- agx_mix_exp defines the curve of the AgX low->high tone mix.
            -- if agx_mix_exp is very low, low tones are influence much by AgX tonemapping
            tonemap__custom.values.agx_mix_exp  = pure.script.ui.getValue("TONEMAPPING__agx_mix_luma_exp")
            -- agx_slope defines the strength of the high tone compression
            tonemap__custom.values.agx_slope    = pure.script.ui.getValue("TONEMAPPING__agx_slope")
            -- agx_power is like an inversed gamma
            tonemap__custom.values.agx_power    = pure.script.ui.getValue("TONEMAPPING__agx_power") * 2.2
            -- agx_sat defines the maximum saturation
            tonemap__custom.values.agx_sat      = pure.script.ui.getValue("TONEMAPPING__agx_sat")

            -- check limits
            tonemap__custom.values.P = math.max(tonemap__custom.values.P, tonemap__custom.values.m + 0.01)
            tonemap__custom.values.l = math.min(1-math.max(0, tonemap__custom.values.m), tonemap__custom.values.l)

            pure.pp.setCustomRGBTonemapping(tonemap__custom)
        end

    elseif mode < 5 then

        local exp_mod   = (1-_l_Exposure_lut[4])
        local exp_mod2  = (1-_l_Exposure_lut[6])^2

        -- using Pure's internal Lottes tonemapping
        pure.pp.setTonemapping(ac.TonemapFunction.Lottes)
        pure.config.set("ppTonemapLottes.contrast", 0.75, true)
        pure.config.set("ppTonemapLottes.gamma",
                math.lerp(
                        -0.03,
                        -0.03 - 0.05*exp_mod2,
                    photo_realistic^0.50),
            true)
        
        -- if exposure is focused for driving, to see things on the ground, 
        -- so it is much higher, esp in low sunangles, then compress the high tones
        pure.config.set("ppTonemapLottes.hdrMax", 0.1 + 0.3*driving_exp_mod, true)
    
        pure.config.set("ppTonemapLottes.midIn",
                math.lerp(
                        -0.25 + 0.04*exp_mod,
                        -0.25 - 0.05*exp_mod2,
                    photo_realistic^0.50),
            true)

        pure.config.set("ppTonemapLottes.midOut", -0.24 + 0.07*exp_mod, true)
        pure.config.set("ppTonemapLottes.gain", 0.05, true)
        
    end
    
    -- set gamma
    local tmp_gamma = gamma * pure.pp.getGammaModulator()
    if tmp_gamma > 0.9999 and tmp_gamma < 1.0001 then
        -- gamma must not be 1.0, then CSP custom tonemapping is not working
        tmp_gamma = 0.9999
    end
    ac.setPpTonemapGamma(tmp_gamma)

    _l_current_tonemapping = mode
end





-- This is called once while AC starts, or the ppfilter changed
function init_pure_script()

    -- tonemapping is set in the PPFilter ini
    --ac.setPpTonemapFunction(2)
    
    -- this adapts the VAO parameters with overcast sceneries
    pure.light.setVAOAdaption(1.0)
    -- use new gamma for material lighting
    pure.light.setLambertGamma(1.25)
    --pure.light.adaptLambertGamma(false)

    -- sets a version and show it in Pure Config (PP)
    pure.script.setVersion(3.1)
    pure.script.setAuthor("Peter Boese")
    -- if a script preset file was saved with an older version, the settings can be reset
    pure.script.resetSettingsWithNewVersion()

 
    if CSP_VERSION >= 2349 then
        -- CSP 0.1.80p204 (dynamic tonemapping)
        pure.script.ui.addRadioButtons("Tonemapping", _l_current_tonemapping, "Sensitometric (Yebis default),Uchimura 2017,Uchimura-AgX,Lottes 2016")
        pure.script.ui.addSeparator()
        
        set_tonemapping(1, _l_current_tonemapping)

        -- here we can create the sliders for the custom tonemapping
        -- If the name starts with "TONEMAPPING__", the slider will be moved in the "PP Tonemapping control" group
        pure.script.ui.addSliderFloat("TONEMAPPING__maxDisplayBrightness",  tonemap__custom.values.P        , 0, 5)
        pure.script.ui.addSliderFloat("TONEMAPPING__contrast",              tonemap__custom.values.a        , 0, 2)
        pure.script.ui.addSliderFloat("TONEMAPPING__linearSectionStart",    tonemap__custom.values.m        , 0.001, 1.00)
        pure.script.ui.addSliderFloat("TONEMAPPING__linearSectionLength",   tonemap__custom.values.l        , 0, 0.98)
        pure.script.ui.addSliderFloat("TONEMAPPING__black",                 tonemap__custom.values.c        , 0, 2)
        pure.script.ui.addSliderFloat("TONEMAPPING__pedestal",              tonemap__custom.values.b        , -0.1, 0.1)
        pure.script.ui.addSliderFloat("TONEMAPPING__gain",                  tonemap__custom.values.gain     , 0, 10)
        pure.script.ui.addSliderFloat("TONEMAPPING__agx_mix",               tonemap__custom.values.agx_mix   , 0, 1)
        pure.script.ui.addSliderFloat("TONEMAPPING__agx_mix_luma_exp",      tonemap__custom.values.agx_mix_exp, 0, 1)
        pure.script.ui.addSliderFloat("TONEMAPPING__agx_slope",             tonemap__custom.values.agx_slope , 0, 2)
        pure.script.ui.addSliderFloat("TONEMAPPING__agx_power",             tonemap__custom.values.agx_power , 0, 10)
        pure.script.ui.addSliderFloat("TONEMAPPING__agx_sat",               tonemap__custom.values.agx_sat   , 0, 2)
    else
        set_tonemapping(1, 0)
    end

    if pure.system.isVR then    
        pure.config.set("pp.godrays", 0.50, true)
    end

    pure.script.ui.addSliderFloat("photo-realistic", 0.5, 0.0, 1.0)
    pure.script.ui.addSliderFloat("spectrum adaption", 1.0, 0, 2)
    pure.script.ui.addSliderFloat("sun blinding", 0.5, 0, 1.0)

    pure.script.ui.addSeparator()

    pure.script.ui.addText("Monitor adjustments")

    -- create a float number slider in the PP tab of Pure Config app
    --                             name                        default value,   minimum, maximum
    pure.script.ui.addSliderFloat("black limit low exposure",  0.0,             0,       1)
    pure.script.ui.addSliderFloat("black limit high exposure", 0.0,             0, 1)

    -- draw a separator line
    pure.script.ui.addSeparator()


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
                                                  autoexposure_mod = 1.00,    -- use this to modify the set autoexposure in the update function
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
                                                    target_mod = 1.00,     -- use this to modify the set target in the update function
                                                    mix = 1.0,
                                                    mix_mod = 1.00,        -- use this to modify the set mix in the update function
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
        pure.script.tools.handleExposure(1, { autoexposure = 1.00, fordriving = false,  fixedexposure = 0.20, superexposure = 0.50, fixedmixmulti = 1.0 })
    end



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

    pure.exposure.yebis.useAlternativeAutoexposure()

    -- use the SPICE PP suite
    pure.pp.UseSpice()

    _l_init = false -- initialization is done
end




-- This is called every frame
function update_pure_script(dt)


    interior = ac.isInteriorView()
    photo_realistic = pure.script.ui.getValue("photo-realistic")

    -- For this ppfilter, an extented light dynamic is the base. So daylight (sun and ambient) is much higher then in Pure's default settings.
    pure.config.set("light.daylight_multiplier", 2.1, true)

    -- this will compensate the spectrum with missing sunlight in overcast sceneries
    pure.light.setSpectrumAdaption(pure.script.ui.getValue("spectrum adaption"))
    
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
    local exp = pure.exposure.getValue()
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
    --pure.config.set( "pp.color_temperature", 1.00 + 0.04*badness*pure.mod.dayCurve(1,0.25,0.67), true)    

    -- The filter has visibility as its primary goal. So we use gamma to shrink the dynamic and gain brightness.
    -- We use 4 gamma stages (high sun, bright light, mid light, low light and very low light)
    -- We need to interpolate the 4 gamma stages, dependent on their meaning to get one value we can set.
    gamma =   math.lerp(    
                    math.lerp(
                            math.lerp(
                                1.60, --pure.script.ui.getValue("gamma low exposure"),
                                1.55, --pure.script.ui.getValue("gamma high sun"),
                                math.min(1, math.max(0, pure.mod.dayCurve(0.0,1.2,0.67))) 
                            ),
                            1.50, --pure.script.ui.getValue("gamma mid exposure") ,
                            _l_Exposure_lut[1]),
                    1.40, --pure.script.ui.getValue("gamma high exposure"),
                    _l_Exposure_lut[2]
                )


    pure.config.set( "pp.brightness", 1.00, true )

    -- set the UI state variable, too show the value in Pure Config
    --pure.script.ui.setValue("final gamma", gamma)

    -- get the state of the exposure meaning. Is it used for driving or for taking pictures
    driving_focused_exp = pure.script.ui.getValue("Exposure is driving focused")

    set_tonemapping(dt, pure.script.ui.getValue("Tonemapping"))
    
    -- SUN BLINDING EFFECT
    if pure.shader.isRunning("sunblinding") then
        -- if the sun blinding shader is active

        -- use godrays as a fog effect, if sunblinding shader is running
        pure.script.tools.handleGodrays(1.5*math.saturate(pure.mod.sun(-0.5))*pure.world.getFog()^0.67, 0.125, nil, nil, 1)


        -- get the value from the "sun blinding" slider 
        local sun_blinding_setting = pure.script.ui.getValue("sun blinding")*2
        -- control the sun_blinding shader

        if pure.system.isVR then
            pure.config.set("shaders.sunblinding.cover",        0.0, true)
            pure.config.set("shaders.sunblinding.blinding",     0.0, true)
            pure.config.set("shaders.sunblinding.iris",         0.50*sun_blinding_setting, true)
            pure.config.set("shaders.sunblinding.star_opacity", 1.8*sun_blinding_setting^1.5, true)
            pure.config.set("shaders.sunblinding.star_size",    1.0, true)
            pure.config.set("shaders.sunblinding.star_blur",    2, true)
            pure.config.set("shaders.sunblinding.star_style",   0, true)
            pure.config.set("shaders.sunblinding.time_down",    0.5+1*sun_blinding_setting, true)
            pure.config.set("shaders.sunblinding.time_up",      1.0-0.25*sun_blinding_setting, true)
        else
            pure.config.set("shaders.sunblinding.cover",        (0.500*sun_blinding_setting)^4, true)
            pure.config.set("shaders.sunblinding.blinding",     2*(0.500*sun_blinding_setting)^6, true)
            pure.config.set("shaders.sunblinding.iris",         (0.500 + 0.25*photo_realistic)*sun_blinding_setting, true)
            pure.config.set("shaders.sunblinding.star_opacity", 0.850*sun_blinding_setting^2, true)
            pure.config.set("shaders.sunblinding.star_size",    2.000, true)
            pure.config.set("shaders.sunblinding.time_down",    (0.5+1*sun_blinding_setting) * (1 - 0.75*photo_realistic), true)
            pure.config.set("shaders.sunblinding.time_up",      1.0-0.25*sun_blinding_setting, true)
        end
        if pure.system.isHDR() then
            pure.config.set("shaders.sunblinding.cover", 0, true)
        end
        
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
    --pure.config.set("light.sun.saturation",         pure.mod.dayCurve(1.00, 1.0+0.25*cloud_shadow_sun, 0.5), true)
    pure.config.set("light.sun.level",              1+0.5*cam_sun_face, true)
    pure.config.set("light.sun.speculars",          1+0.5*cam_sun_face, true)
    
    -- damp advanced ambient light when looking into the sun and lower it with photo realism
    pure.config.set("light.ambient.level",          (1-0.25*cam_sun_face) * (1 - 0.5 * photo_realistic^3), true)
    pure.config.set("light.advanced_ambient_light", (1.0-0.90*cam_sun_face) * (1 - 0.5 * photo_realistic^2), true)


    pure.config.set("light.sky.level",              1+0.75*cam_sun_face*pure.mod.sun(0), true)
    pure.config.set("clouds2D.brightness",          1+0.75*cam_sun_face, true)

    pure.config.set("light.advanced_ambient_lightV2_sun", pure.mod.dayCurve(1.80, 1.25, 2), true)

    pure.config.set("reflections.saturation",         1-0.5*cam_sun_face, true)
    pure.config.set("reflections.level",              1-0.5*cam_sun_face, true)
    

    -- Also try to improve the effective dynamic, by gaining the reflections - mostly with high exposures.
    --pure.config.set("reflections.level", 1.4 - 0.3*_l_Exposure_lut[6]*(1+cam_sun_face), true)
    --pure.config.set("reflections.saturation", (1-0.5*cam_sun_face), true)

    -- We need to adapt the CSP lights to the higher dynamic too. Pure was build to prevent this, but many tests showed, that the AC/CSP engine is not
    -- realy capable of it. So we need to gain emissives strongly for day. 
    -- Due to we are using the exposure to control this, this control is very natural and adapts well to the current scenery.
    -- So this is still a solution of the tunnels problem and CSP lights are still realistic in their usage.
    pure.config.set("csp_lights.bounce", 2.0 - 0.5*photo_realistic, true)
    local emissives = 1.00 + 0.15/pure.exposure.cbe.getValue()
    pure.config.set("csp_lights.emissive", emissives, true)

    -- we want to gain bloom with photo realism
    local bloom_boost = photo_realistic * (1 - _l_Exposure_lut[4])
    -- you can set all YEBIS parameters with this function / see all parameter names at the end of this script
    pure.yebis.set("glareBloomLevels", math.floor(2 + 4*photo_realistic))
    pure.yebis.set("glareBloomLuminanceGamma", 1.15 + 0.25*bloom_boost)
    pure.yebis.set("glareShapeBloomLuminance", 0.1 + 0.1*photo_realistic)
    pure.yebis.set("glareThreshold", (1.0 - 0.70*photo_realistic^1.5))

    local camera_effects = (photo_realistic^3)
    pure.yebis.set("glareShapeGhostLuminance", 0.0 + 1.00*camera_effects)
    pure.yebis.set("glareShapeAfterimageLuminance", 0.0 + 3.00*camera_effects)
    pure.yebis.set("glareShapeAfterimageLength", 0.0 + 0.50*camera_effects*(1-_l_Exposure_lut[6]))


    -- AUTO - EXPOSURE controlling
    -- with photo realism with shrink the field of Autoexposure measurement
    -- This will give you the behavior of a cameras autoexposure control
    -- We bend the curve a bit, too have this effect just for big values of "photo_realistic"
    local measure_area_mod = (photo_realistic^1.5)
    ae_measure_area__pos:set(0.0, 0.11 - 0.11*measure_area_mod)
    ae_measure_area__ext:set(0.8 - 0.4*measure_area_mod, 0.65 - 0.30*measure_area_mod)
    ac.setAutoExposureMeasuringArea(ae_measure_area__pos, ae_measure_area__ext)
    local AE_boost  = measure_area_mod
                    * (interior and 0.5 or 0.75)
                    * (1 - _l_Exposure_lut[4])

    pure.exposure.yebis.setTarget(pure.exposure.yebis.getTarget() * (1 + AE_boost))
    pure.exposure.yebis.setLimits(pure.exposure.yebis.getLowLimit(), pure.exposure.yebis.getHighLimit() * (1 + AE_boost))

    if pure.system.isVR then
        pure.script.tools.handleExposure_setParameter("superexposure", 0.35 - 0.10 * photo_realistic)
    else
        pure.script.tools.handleExposure_setParameter("superexposure", 0.50 - 0.25 * photo_realistic)
    end

    --pure.camera.setCPL(0.25 * photo_realistic * (_l_Exposure_lut[6]^2))
    pure.config.set("reflections.emissive_boost", 1 + 4*photo_realistic, true)
end



--[[

pure.yebis.set(parameter, value)
parameter + value type :
    "hue" number
    "saturation" number
    "brightness" number
    "contrast" number
    "sepia" number
    "colorTemperature" number
    "whiteBalance" number
    "fixedWidth" number
    "cameraNearPlane" number
    "cameraFarPlane" number
    "cameraVerticalFOVRad" number
    "tonemapUseHDRSpace" number
    "tonemapExposure" number
    "tonemapGamma" number
    "tonemapFunction" number
    "tonemapViewportScaleWidth" number
    "tonemapViewportScaleHeight" number
    "tonemapViewportOffsetX" number
    "tonemapViewportOffsetY" number
    "tonemapMappingFactor" number
    "autoExposureEnabled" boolean
    "autoExposureDelay" number
    "autoExposureMin" number
    "autoExposureMax" number
    "autoExposureTarget" number
    "autoExposureInfluencedByGlare" boolean
    "vignetteStrength" number
    "vignetteFOVDependence" number
    "chromaticAberrationEnabled" boolean
    "chromaticAberrationActive" boolean
    "chromaticAberrationSamples" number
    "chromaticAberrationLateralDisplacement" vec2
    "chromaticAberrationUniformDisplacement" vec2
    "diaphragmRotateScale" number
    "diaphragmRotateOffsetRad" number
    "diaphragmRotationType" number
    "feedbackEnabled" boolean
    "feedbackAspectRatio" number
    "feedbackWeight" number
    "feedbackCurrentWeight" number
    "feedbackTimeInSeconds" number
    "glareEnabled" boolean
    "glareAnamorphic" boolean
    "glareShape" number
    "glarePrecision" number
    "glareQuality" number
    "glareBrightPass" number
    "glareUseCustomShape" boolean
    "glareAfterImage" boolean
    "glareGhost" boolean
    "glareGhostActive" boolean
    "glareGhostConcentricDistortion" number
    "glareLuminance" number
    "glareBlur" number
    "glareThreshold" number
    "glareBloomFilterThreshold" number
    "glareBloomGaussianRadiusScale" number
    "glareBloomLuminanceGamma" number
    "glareBloomLevels" number
    "glareGenerationRangeScale" number
    "glareStarLengthFOVDependence" number
    "glareStarSoftness" number
    "glareStarFilterThreshold" number
    "glareFOVDependence" number
    "glareShapeLuminance" number
    "glareShapeBloomLuminance" number
    "glareShapeBloomDispersion" number
    "glareShapeBloomDispersionBaseLevel" number
    "glareShapeGhostLuminance" number
    "glareShapeGhostHaloLuminance" number
    "glareShapeGhostDistortion" number
    "glareShapeGhostSharpeness" boolean
    "glareShapeStarLuminance" number
    "glareShapeStarStreaks" number
    "glareShapeStarLength" number
    "glareShapeStarSecondaryLength" number
    "glareShapeStarRotation" boolean
    "glareShapeStarInclinationAngle" number
    "glareShapeStarDispersion" number
    "glareShapeStarForceDispersion" boolean
    "glareShapeAfterimageLuminance" number
    "glareShapeAfterimageLength" number
    "dofEnabled" boolean
    "dofActive" boolean
    "dofQuality" number
    "dofFocusDistance" number
    "dofApertureFNumber" number
    "dofImageSensorHeight" number
    "dofVerticalFOVBaseRad" number
    "dofAdaptiveApertureFactor" number
    "dofApertureParameter" number
    "dofApertureType" number
    "dofApertureFrontLevels" number
    "dofApertureBackLevels" number
    "dofBackgroundMaskThreshold" number
    "dofEdgeQuality" number
    "godraysEnabled" boolean
    "godraysInCameraFustrum" boolean
    "godraysDiffractionRing" number
    "godraysDiffractionRingAttenuation" number
    "godraysDiffractionRadius" number
    "godraysDiffractionRingSpectrumOrder" number
    "godraysDiffractionRingOuterColor" rgbm
    "godraysUseSunLightColor" boolean
    "godraysColor" rgbm
    "godraysLength" number
    "godraysGlareRatio" number
    "godraysAngleAttenuation" number
    "godraysNoiseMask" number
    "godraysNoiseFrequency" number
    "godraysDepthMaskThreshold" number
    "lensDistortionEnabled" boolean
    "lensDistortionRoundness" number
    "lensDistortionSmoothness" number
    "filmicContrast" number

]]