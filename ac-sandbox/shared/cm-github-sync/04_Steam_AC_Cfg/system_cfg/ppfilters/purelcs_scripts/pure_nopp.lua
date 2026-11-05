-- This is called once while AC starts
function init_pure_script()

    -- activate Pure's Exposure Calculation via Cubemap Brightness Estimation
    -- Cubemap reflections must NOT be static (Settings->Assetto Corsa->Video->Reflections frequency)
    -- "Use proper physically-based smapling" MUST be activated (Settings->Custom Shaders Patch->Reflections FX->General Cubemap Reflections)
    pure.exposure.useCBE(true)
    pure.light.setVAOAdaption(true)

    --pure.config.set("light.sun.level", 0.7, true)
    --pure.light.setLambertGamma(5.6)
    

    -- sets a version and show it in Pure Config (PP)
    pure.script.setVersion(3.0)

    -- 
    pure.config.set("light.ambient_model_V2", true, true)
    pure.config.set("light.ambient.saturation", 0.5, true)
    pure.config.set("light.distant_ambient.level", 2.0, true)

    -- lower sunlight to avoid high tone clipping
    pure.config.set("shadows.presence", 0.5, true)
    
    pure.config.set("vao.track_exponent", 0.5, true)

    pure.config.set("nlp.lowest_ambient", 3.0, true)

    -- try to lower the dynamic of skydomes to fit in the unclipped dynamics of linear tones
    pure.config.set("clouds2D.brightness", 0.65, true)
    pure.config.set("clouds2D.contrast", 0.5, true)


    if pure.system.isVR then
        -- In VR don't use AE that much, its better to have a more stable exposure with real head/cam movements.
        -- Also don't raise exposure that much in very low sceneries (superexposure).
        pure.script.tools.handleExposure(1, { autoexposure = 0.00, fordriving = false, fixedexposure = 0.25, superexposure = 0.35, fixedmixmulti = 1.0 })
    else
        pure.script.tools.handleExposure(1, { autoexposure = 0.00, fordriving = true,  fixedexposure = 0.25, superexposure = 0.35, fixedmixmulti = 1.0 })
    end
end


local cloud_shadow = 0
local photo = 0

-- This is called every frame
function update_pure_script(dt)

    local cloud_shadow = math.max(pure.world.getCloudShadow(), pure.world.getOvercast()) * pure.camera.getOcclusion()

    pure.config.set("light.advanced_ambient_light", 1.5 + 1.5*cloud_shadow, true)
end
