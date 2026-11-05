local godrays_length = 0
local gamma = 1.0

function init_pure_script()

    pure.exposure.useCBE(true)

    pure.light.setLambertGamma(1.7)

    pure.script.ui.addCheckbox("Spectrum Adaption", true)
    pure.script.ui.addCheckbox("VAO Adaption", false)

    if pure.system.isVR then
        pure.script.tools.handleExposure(2, {method = 5, target = 1.5, mix = 0.85})
        pure.config.set( "ui.white_reference_point", 0.7, true)
    else
        pure.script.tools.handleExposure(2, {method = 4, target = 4.0, mix = 0.5})
    end
end

function update_pure_script(dt)
   
    -- this will compensate the spectrum with missing sunlight in overcast sceneries
    pure.light.setSpectrumAdaption(pure.script.ui.getValue("Spectrum Adaption"))

    -- this adapts the VAO parameters with overcast sceneries
    pure.light.setVAOAdaption(pure.script.ui.getValue("VAO Adaption"))

    pure.script.tools.handleGodrays()
end
