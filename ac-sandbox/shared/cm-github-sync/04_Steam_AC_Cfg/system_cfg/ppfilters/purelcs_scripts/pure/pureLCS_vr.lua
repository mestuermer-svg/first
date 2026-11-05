local gamma = 1.5



-- LUTs (Look Up Tables) are a good way to define non linear value changes.
-- The first column is the index. In the following LUTs the index is CBE (Cubemap Brightness Estimation) value.
-- You can add more columns. They are calculated automatically, when calling LUT:get(index)
-- We use the LUT to control different things dependent on exposure.
local _l_exposure_LUT = {
    --  exposure
        { 0.00,   0.00, 0.0, 1.00, 1.00, 0.00, 1.00, 1.000  },
        { 0.02,   0.00, 0.0, 1.00, 1.00, 0.00, 1.00, 1.000  },
        { 0.05,   0.00, 0.0, 1.00, 1.00, 0.00, 1.00, 0.550  },
        { 0.063,  0.10, 0.0, 1.00, 0.90, 0.00, 1.00, 0.350  },
        { 0.075,  0.20, 0.0, 1.00, 0.60, 0.00, 0.95, 0.150  },
        { 0.087,  0.60, 0.0, 1.00, 0.30, 0.00, 0.90, 0.050  },
        { 0.1,    0.90, 0.0, 1.00, 0.15, 0.05, 0.80, 0.040  },
        { 0.15,   1.00, 0.0, 0.75, 0.05, 0.15, 0.65, 0.030  },
        { 0.2,    0.50, 0.1, 0.25, 0.00, 0.30, 0.40, 0.020  },
        { 0.3,    0.25, 0.7, 0.00, 0.00, 0.60, 0.20, 0.005  },
        { 0.5,    0.05, 1.0, 0.00, 0.00, 1.00, 0.05, 0.000  },
        { 1.0,    0.00, 1.0, 0.00, 0.00, 1.00, 0.00, 0.000  },
    }
local _l_ExposureCPP = LUT:new(_l_exposure_LUT)
-- initialize with a standard day exposure
local _l_Exposure_lut = _l_ExposureCPP:get(0.03)



local cam_sun_face = 0
local photo_realistic = 0.0
local photo_realistic_2 = 0.0
local photo_realistic_3 = 0.0
local photo_realistic_sqrt = 0.0
local softlook = 0
local softlook_day = 0
local softlook_day_2 = 0
local interior = true

local ae_measure_area__pos = vec2(0.0, 0.11)
local ae_measure_area__ext = vec2(0.8, 0.65)

local glare_settings = {
    Luminance = 0,
    BloomLevels = 0,
    ShapeLuminance = 0,
    ShapeBloomLuminance = 0,
    ShapeGhostLuminance = 0,
}


-- This is an example, how to integrate a very own tonemapping into Pure ppf script,
-- if you want to use Pure's tonemapping debug options (clipping and curve debug)

-- We now define a table with the variables used in the c code
-- that is our LUA - C bridge, to access the tonemapping dynamically
-- and we define our c code of the tonemapping
local tonemap__custom = {
    -- definition of the variables
    values = {
        gLCS = true,
        P = 2.00, 
        a = 1.00, 
        m = 0.29, --0.30
        l = 0.40, 
        c = 1.00, 
        b = 0.00, 
        gain= 1.00,
        agx_mix = 0.85, --0.50
        agx_mix_exp = 0.40, --0.50
        agx_slope = 1.18, --1.20
        agx_power = 2.40, --2.40
        agx_sat   = 0.99, --0.65
        agx_sat_dependency = 1.0,
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

    float3 agxLook(float3 val, float luma) {
        
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

        x = pow(max(0, x*1.075), 1.025);

        float3 hsv = rgb2hsv(x);

        float luma = saturate(dot(x, luminosityFactor));
        
        float3 col = agx(x);
        col = agxLook(col, luma);
        col = agxEotf(col);

        x = lerp(x, col, agx_mix * pow(luma, agx_mix_exp) * sqrt(1 - agx_sat_dependency * saturate(hsv.y)));

        x *= gain;
        x = float3(uchimura(x.r), uchimura(x.g), uchimura(x.b));

        return x;
    }

    float3 tonemapping(float3 x){
        return RGB_Uchimura_AgX(x);
    }
]]
}


local _l_style_table = {
    tonemap = {
        P = 0.0, -- max. display brightness
        a = 0.0, -- contrast
        m = 0.0, -- linear section start
        l = 0.0, -- linear section length
        c = 0.0, -- black
        b = 0.0, -- pedestral 
        gain = 0.0,
        agx_mix = 0.0,
        agx_mix_luma_exp = 0.0,
        agx_slope = 0.0,
        agx_power = 0.0,
        agx_sat = 0.0,
    },
    temperature = 1.0,
}

local _l_ext_tonemapping_table = {
    P = 0.0, -- max. display brightness
    a = 0.0, -- contrast
    m = 0.0, -- linear section start
    l = 0.0, -- linear section length
    c = 0.0, -- black
    b = 0.0, -- pedestral 
    gain = 0.0,
    agx_mix = 0.0,
    agx_mix_luma_exp = 0.0,
    agx_slope = 0.0,
    agx_power = 0.0,
    agx_sat = 0.0,
}

local _l_init = true
--local _l_current_tonemapping = 3 -- choose Uchimura/AGX as default
local _l_style = 0
local function set_tonemapping(dt, params)

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


    local dyn_range_adjust = _l_Exposure_lut[1]^1.5
    local dyn_range_adjust_inv = 1-dyn_range_adjust
    local dyn_range_adjust_dark = _l_Exposure_lut[6]^2
    local dyn_range_adjust_dark_inv = 1-dyn_range_adjust_dark
    --local ultra_dark = 1 - _l_Exposure_lut[4]^0.34

    local uchimura__maxDisplayBrightness = -0.95 - 0.03*photo_realistic

    local uchimura__contrast    = 0.6
                                --- 0.20 * _l_Exposure_lut[7]
                                --+ 1.00 * cam_sun_face
                                --+ 0.30 * softlook_day * pure.world.getCloudShadow()

    local uchimura__linearSessionStart  = -0.21
                                        --+ 0.03 * _l_Exposure_lut[7]
                                        + 0.04 * photo_realistic_2
                                        + 0.01 * cam_sun_face
                                        -- - 0.04 * softlook_day
                                        
    local uchimura__linearSectionLength = math.lerp(
                                                0.3,
                                                -0.3*(1-_l_Exposure_lut[7]),
                                            photo_realistic)
                                            
    local uchimura__black = (0.5 * _l_Exposure_lut[3])
                                    
    local uchimura__gain    = math.lerp(-0.400,
                                        -0.275 + 0.1*(1-_l_Exposure_lut[4]),
                                        photo_realistic) * (0.7 + 0.3*_l_Exposure_lut[6]
                                    )
                            - math.lerp(0.25, 0.32, photo_realistic) * softlook_day * (1 - 0.35*pure.world.getCloudShadow())
                            

    if not _l_init then
        -- using Pure's custom Uchimura-Agx tonemapping shader
    
        -- we get the values from the sliders
        tonemap__custom.values.P    = pure.script.ui.getValue("TONEMAPPING__maxDisplayBrightness")
                                    + uchimura__maxDisplayBrightness + _l_style_table.tonemap.P
                                    + _l_ext_tonemapping_table.P

        tonemap__custom.values.a    = pure.script.ui.getValue("TONEMAPPING__contrast")
                                    + uchimura__contrast + _l_style_table.tonemap.a
                                    + _l_ext_tonemapping_table.a

        tonemap__custom.values.m    = math.max(0.001, pure.script.ui.getValue("TONEMAPPING__linearSectionStart")
                                    + uchimura__linearSessionStart) + _l_style_table.tonemap.m
                                    + _l_ext_tonemapping_table.m
        tonemap__custom.values.m    = math.max(0.01, tonemap__custom.values.m)

        tonemap__custom.values.P    = math.max(tonemap__custom.values.P, tonemap__custom.values.m + 0.01)
        
        tonemap__custom.values.l    = math.min(1-math.max(0, tonemap__custom.values.m), pure.script.ui.getValue("TONEMAPPING__linearSectionLength")
                                    + uchimura__linearSectionLength + _l_style_table.tonemap.l
                                    + _l_ext_tonemapping_table.l)

        tonemap__custom.values.c    = pure.script.ui.getValue("TONEMAPPING__black")
                                    + uchimura__black + _l_style_table.tonemap.c
                                    + _l_ext_tonemapping_table.c

        tonemap__custom.values.b    = pure.script.ui.getValue("TONEMAPPING__pedestal")
                                    + _l_style_table.tonemap.b
                                    + _l_ext_tonemapping_table.b

        tonemap__custom.values.gain = pure.script.ui.getValue("TONEMAPPING__gain")
                                    + uchimura__gain + _l_style_table.tonemap.gain
                                    + _l_ext_tonemapping_table.gain
                                    

        -- agx_mix defines the possible use of AgX
        -- In this tonemapping shader, AgX has more influence on high tones.                        
        tonemap__custom.values.agx_mix      = pure.script.ui.getValue("TONEMAPPING__agx_mix")
                                            + _l_style_table.tonemap.agx_mix
                                            + _l_ext_tonemapping_table.agx_mix
        -- agx_mix_exp defines the curve of the AgX low->high tone mix.
        -- if agx_mix_exp is very low, low tones are influence much by AgX tonemapping
        tonemap__custom.values.agx_mix_exp  = pure.script.ui.getValue("TONEMAPPING__agx_mix_luma_exp")
                                            + _l_style_table.tonemap.agx_mix_luma_exp
                                            + _l_ext_tonemapping_table.agx_mix_luma_exp
        -- agx_slope defines the strength of the high tone compression
        tonemap__custom.values.agx_slope    = pure.script.ui.getValue("TONEMAPPING__agx_slope")
                                            + _l_style_table.tonemap.agx_slope
                                            + _l_ext_tonemapping_table.agx_slope
                                            + ( 0.05 * softlook_day + 0.15 * _l_Exposure_lut[1] * softlook * (1 - 0.5*pure.world.getOvercast())) * (1 - 0.5 * photo_realistic_2)
        -- agx_power is like an inversed gamma
        tonemap__custom.values.agx_power    = (
                                                pure.script.ui.getValue("TONEMAPPING__agx_power")
                                                * (1 + 0.45*photo_realistic)
                                                + _l_style_table.tonemap.agx_power
                                                + _l_ext_tonemapping_table.agx_power
                                            ) * 2.2
        -- agx_sat defines the maximum saturation
        tonemap__custom.values.agx_sat      = pure.script.ui.getValue("TONEMAPPING__agx_sat")
                                            * (1 - 0.15 * photo_realistic)
                                            + _l_style_table.tonemap.agx_sat
                                            + _l_ext_tonemapping_table.agx_sat

        

        tonemap__custom.values.agx_sat_dependency = 1-photo_realistic^8
        
        -- check limits
        tonemap__custom.values.P = math.max(tonemap__custom.values.P, tonemap__custom.values.m + 0.01)
        tonemap__custom.values.l = math.min(1-math.max(0, tonemap__custom.values.m), tonemap__custom.values.l)

        pure.pp.setCustomRGBTonemapping(tonemap__custom)
    end

    -- set gamma
    local tmp_gamma = gamma * pure.pp.getGammaModulator()
    if tmp_gamma > 0.9999 and tmp_gamma < 1.0001 then
        -- gamma must not be 1.0, then CSP custom tonemapping is not working
        tmp_gamma = 0.9999
    end
    ac.setPpTonemapGamma(tmp_gamma)

    --_l_current_tonemapping = mode
end



local function set_style(style)

    _l_style = style

    if _l_style < 2 then
        -- neutral
        _l_style_table.tonemap.P = 0.0
        _l_style_table.tonemap.a = 0.0
        _l_style_table.tonemap.m = 0.0
        _l_style_table.tonemap.l = 0.0
        _l_style_table.tonemap.c = 0.0
        _l_style_table.tonemap.b = 0.0
        _l_style_table.tonemap.gain = 0.0
        _l_style_table.tonemap.agx_mix = 0.0
        _l_style_table.tonemap.agx_mix_luma_exp = 0.0
        _l_style_table.tonemap.agx_slope = 0.0
        _l_style_table.tonemap.agx_power = 0.0
        _l_style_table.tonemap.agx_sat = -0.025

        _l_style_table.temperature = 1.00
    elseif _l_style < 3 then
        -- vibrant
        _l_style_table.tonemap.P = 0.0
        _l_style_table.tonemap.a = 0.0
        _l_style_table.tonemap.m = 0.015
        _l_style_table.tonemap.l = 0.0
        _l_style_table.tonemap.c = 0.0
        _l_style_table.tonemap.b = 0.0
        _l_style_table.tonemap.gain = 0.1
        _l_style_table.tonemap.agx_mix = 0.0
        _l_style_table.tonemap.agx_mix_luma_exp = 0.0
        _l_style_table.tonemap.agx_slope = 0.025
        _l_style_table.tonemap.agx_power = 1.0
        _l_style_table.tonemap.agx_sat = 0.075

        _l_style_table.temperature = 1.00
    elseif _l_style < 4 then
        -- warm
        _l_style_table.tonemap.P = 0.0
        _l_style_table.tonemap.a = 0.0
        _l_style_table.tonemap.m = 0.0
        _l_style_table.tonemap.l = -0.15
        _l_style_table.tonemap.c = 0.0
        _l_style_table.tonemap.b = 0.0
        _l_style_table.tonemap.gain = 0.05
        _l_style_table.tonemap.agx_mix = 0.0
        _l_style_table.tonemap.agx_mix_luma_exp = 0.0
        _l_style_table.tonemap.agx_slope = -0.025
        _l_style_table.tonemap.agx_power = 0.75
        _l_style_table.tonemap.agx_sat = -0.06

        _l_style_table.temperature = 0.94
    elseif _l_style < 5 then
        -- cool
        _l_style_table.tonemap.P = 0.0
        _l_style_table.tonemap.a = 0.0
        _l_style_table.tonemap.m = 0.0
        _l_style_table.tonemap.l = -0.15
        _l_style_table.tonemap.c = 0.0
        _l_style_table.tonemap.b = 0.0
        _l_style_table.tonemap.gain = 0.0
        _l_style_table.tonemap.agx_mix = 0.0
        _l_style_table.tonemap.agx_mix_luma_exp = 0.0
        _l_style_table.tonemap.agx_slope = 0.05
        _l_style_table.tonemap.agx_power = 0.8
        _l_style_table.tonemap.agx_sat = -0.10

        _l_style_table.temperature = 1.06
    end

    pure.config.set("pp.color_temperature", _l_style_table.temperature, true)
end



function pureLCS__init(params)

    local style = (params and params.style) and params.style or 1
    local photorealistic = (params and params.photorealistic) and params.photorealistic or 0.5
    local softlook = (params and params.softlook) and params.softlook or 0.5
    local sunblinding = (params and params.sunblinding) and params.sunblinding or 0.5

    -- check init params for tonemapping customizations
    if params and params.custom_tonemapping then
        -- values
        if params.custom_tonemapping.values and tonemap__custom.values then
            for k,v in pairs(tonemap__custom.values) do
                if params.custom_tonemapping.values[k]~=nil then
                    tonemap__custom.values[k] = params.custom_tonemapping.values[k]
                end
            end
        end
    end

    pure.exposure.yebis.useAlternativeAutoexposure(true)

    -- get ppfilter glare settings
    glare_settings.Luminance            = pure.yebis.get("glareLuminance")
    glare_settings.BloomLevels          = pure.yebis.get("glareBloomLevels")
    glare_settings.ShapeLuminance       = pure.yebis.get("glareShapeLuminance")
    glare_settings.ShapeBloomLuminance  = pure.yebis.get("glareShapeBloomLuminance")
    glare_settings.ShapeGhostLuminance  = pure.yebis.get("glareShapeGhostLuminance")

    -- set performance settings for VR
    pure.yebis.set("glareAfterImage", false)
    pure.yebis.set("glareBloomLevels", 2)
    pure.yebis.set("glareGhost", false)
    pure.yebis.set("glareGhostActive", false)
    pure.yebis.set("glarePrecision", 0)
    pure.yebis.set("glareBlur", 0)

    pure.yebis.set("godraysDepthMaskThreshold", 1.0)
    
    pure.script.ui.addSeparator()

    --pure.script.ui.addRadioButtons("Tonemapping", _l_current_tonemapping, "Sensitometric (Yebis default),Uchimura 2017,Uchimura-AgX,Lottes 2016")
    --pure.script.ui.addSeparator()
    
    set_tonemapping(1)

    -- here we can create the sliders for the custom tonemapping
    -- If the name starts with "TONEMAPPING__", the slider will be moved in the "PP Tonemapping control" group
    pure.script.ui.addSliderFloat("TONEMAPPING__maxDisplayBrightness",  tonemap__custom.values.P            , 0, 5)
    pure.script.ui.addSliderFloat("TONEMAPPING__contrast",              tonemap__custom.values.a            , 0, 2)
    pure.script.ui.addSliderFloat("TONEMAPPING__linearSectionStart",    tonemap__custom.values.m            , 0.001, 1.00)
    pure.script.ui.addSliderFloat("TONEMAPPING__linearSectionLength",   tonemap__custom.values.l            , 0, 0.98)
    pure.script.ui.addSliderFloat("TONEMAPPING__black",                 tonemap__custom.values.c            , 0, 2)
    pure.script.ui.addSliderFloat("TONEMAPPING__pedestal",              tonemap__custom.values.b            , -0.1, 0.1)
    pure.script.ui.addSliderFloat("TONEMAPPING__gain",                  tonemap__custom.values.gain         , 0, 10)
    pure.script.ui.addSliderFloat("TONEMAPPING__agx_mix",               tonemap__custom.values.agx_mix      , 0, 1)
    pure.script.ui.addSliderFloat("TONEMAPPING__agx_mix_luma_exp",      tonemap__custom.values.agx_mix_exp  , 0, 1)
    pure.script.ui.addSliderFloat("TONEMAPPING__agx_slope",             tonemap__custom.values.agx_slope    , 0, 2)
    pure.script.ui.addSliderFloat("TONEMAPPING__agx_power",             tonemap__custom.values.agx_power    , 0, 10)
    pure.script.ui.addSliderFloat("TONEMAPPING__agx_sat",               tonemap__custom.values.agx_sat      , 0, 2)


    pure.script.ui.addRadioButtons("Style", style, "Neutral,Vibrant,Warm,Cool")

    pure.script.ui.addSliderFloat("photo-realistic", photorealistic, 0.0, 1.0, "Bigger sun light and ambient light difference. Adds camera effects too.")
    pure.script.ui.addSliderFloat("soft-look", softlook, 0.0, 1.0, "Creates a softer look with more distant fog.")
    pure.script.ui.addSliderFloat("sunblinding", sunblinding, 0.0, 1.0, "Emulates the effect when looking into the sun.")

    pure.script.tools.handleExposure(1, { autoexposure = 1.00, fixedexposure = 0.25, superexposure = 0.35, fixedmixmulti = 1.0 })
    --pure.script.tools.handleExposure(2, {method = 5, target = 1.0, mix = 0.50, fixedexposure = 0.25, superexposure = 0.50})

    pure.config.set("Scene.emissive_adaption", true, true)
    pure.config.set("csp_lights.bounce", 1.25, true)
    --pure.config.set("light.daylight_multiplier", 0.34)

    _l_init = false -- initialization is done
end




function pureLCS__set()

    pure.pp.set("pp.luma_invert", true, true)
end





function pureLCS__update(dt, params)

    -- get the index to retrieve the values from the exposure LUT
    -- The LUT is used to get specific values for certain exposure levels
    -- Just prevent too low CBE values for low sunangles.
    local exp = pure.exposure.getValue()
    _l_Exposure_lut  = _l_ExposureCPP:get(exp)

    local sunblinding = pure.script.ui.getValue("sunblinding")
    cam_sun_face = pure.config.get("shaders.sunblinding.active") and pure.utils.CamFacesSun() * sunblinding or 0.0


    interior = ac.isInteriorView()
    photo_realistic = pure.script.ui.getValue("photo-realistic")
    photo_realistic_2 = photo_realistic * photo_realistic
    photo_realistic_3 = photo_realistic * photo_realistic_2
    photo_realistic_sqrt = photo_realistic^0.5
    softlook = pure.script.ui.getValue("soft-look")
    softlook_day = _l_Exposure_lut[4] * softlook
    softlook_day_2 = softlook_day^2

    local selected_style = pure.script.ui.getValue("Style")
    if _l_style ~= selected_style then
        set_style(selected_style)
    end


    --pure.config.set("light.ambient_radiosity.level", 2, true)

    -- Just help a bit in dark ambient
    gamma = math.lerp(1.70 + 0.5*photo_realistic_2, 1.60, _l_Exposure_lut[6])
    gamma = gamma * (1 + softlook * (_l_Exposure_lut[4]^0.5 * 0.3 + _l_Exposure_lut[1] * 0.2))

    --pure.config.set("pp.contrast", 1 + 0.015*softlook_day, true)
    pure.config.set("pp.brightness", (1 - 0.125*cam_sun_face^0.67), true)

   

    -- luminance based saturation
    -- less saturation when looking towards the sun in bright conditions
    -- less saturation of very dark tones in dark conditions
    pure.pp.set("pp.luma_saturation", math.lerp(    0.5,
                                                    (1 - 0.75*cam_sun_face * (1-photo_realistic_2)) * (1 + 0.3 * softlook_day_2),
                                                    _l_Exposure_lut[4]
                                            )  
                                    , true)
    pure.pp.set("pp.luma_threshold", math.lerp( 0.10 + 0.10 * _l_Exposure_lut[3],
                                                1 - softlook_day * 0.60,
                                                _l_Exposure_lut[4]
                                            )
                                    , true)




    -- reduce far fog exponent with softlook to get it more to the default wfx look
    pure.config.set("fog.far.exponent", 1.00 - 0.30 * softlook * (1 - pure.utils.CamIsInTunnel()), true)
        
    -- also make the sky softer
    pure.config.set("clouds2D.brightness", 1 + photo_realistic_3, true)
    pure.config.set("clouds2D.contrast", 1 - softlook_day_2 * 0.5, true)

    --set_tonemapping(dt, pure.script.ui.getValue("Tonemapping"))
    set_tonemapping(dt, params)


    -- set some specific Glare parameters with photorealism and exposure flash
    pure.yebis.set("glareThreshold", 3)
    pure.yebis.set("glareLuminance", glare_settings.Luminance * (0.1 + 0.9 * photo_realistic))
    pure.yebis.set("glareShapeLuminance", glare_settings.ShapeLuminance * (0.25 + 0.75*photo_realistic))
    pure.yebis.set("glareShapeBloomLuminance", glare_settings.ShapeBloomLuminance * (0.25 + 0.75*photo_realistic))
  

    -- modifing the world ligths with photorealism to have a higher contrast of sun and ambient light
    pure.config.set("light.sun.level", 0.85 + 1.00 * pure.mod.sun(0) * photo_realistic + (0.60 + 0.4*photo_realistic) * softlook_day, true)
    pure.config.set("light.ambient.level", 1.00 + 2*photo_realistic_2, true)


    --[[  EXPOSURE  ]]--

    -- the idea is: for eye-based visuals (photo_realistic < 0.5), we limit the lowest possible exposure. So with low sunangles we still have
    -- enough exposure to see everything, because the eyes adapting to the darker ambient.
    pure.exposure.cbe.setLimits(math.lerp(0.072 - 0.040*math.saturateN(pure.mod.dayCurve(-1.0, 2.0, 0.5)), 0.028, photo_realistic), pure.exposure.cbe.getHighLimit())
    
    pure.exposure.cbe.setAnalysis(0, 1, 0.5)

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
                    * (1 - 0.5*_l_Exposure_lut[4])

    local bright_weather = (0.5 + 0.5*pure.world.getOvercast()) * (1-pure.world.getBadness()) * math.min(math.saturateN(pure.mod.dayCurve(-0.5, 1.5, 0.5)), _l_Exposure_lut[6])
    local new_target = math.min(math.lerp(pure.exposure.yebis.getTarget() * (1 + AE_boost), 0.02, bright_weather), 
                                pure.exposure.cbe.getValue() * 0.5
                            )
    new_target = math.max(0.025, new_target)


    -- We can use the pure.exposure.yebis.getTarget() function here, because we use the expsosure handling tool, which sets the target!
    -- If you don't use the exposure handling tool, you can't do this! You would cause a feedback loop and expsoure would rise to infinite values!
    pure.exposure.yebis.setTarget(new_target)
    pure.exposure.yebis.setLimits(pure.exposure.yebis.getLowLimit(), pure.exposure.yebis.getHighLimit() * (1 + AE_boost))
    
    -- we gain the speed of the exposure adaption in photorealism
    local low   = 2.0 + 8.0*photo_realistic
    local high  = 10 - 5.0*photo_realistic
    pure.exposure.cbe.setAdaptionSpeeds(low, high)
    pure.exposure.yebis.setAdaptionSpeeds(low, high)
    

    --[[  GODRAYS  ]]--

    -- switch off godrays completelly, but use the sun's aura shader
    if cam_sun_face > 0 then
        pure.config.set("shaders.sunblinding.gain", sunblinding^2, true)
        pure.config.set("shaders.sunblinding.iris", sunblinding, true)
    end
    pure.config.set("shaders.sunblinding.booster", 2.0*sunblinding, true)

    pure.script.tools.handleGodrays(0, 0, 0, 0, (0.75 + 2.25*sunblinding) * (1 - pure.world.getSunCover()^0.1))
end