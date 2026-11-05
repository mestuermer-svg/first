



local script_folder = pure.script.getFolder()
if pure.system.isHDR() then
    dofile(script_folder.."\\pure\\pureLCS_hdr.lua")
elseif pure.system.isVR() then
    dofile(script_folder.."\\pure\\pureLCS_vr.lua")
else
    dofile(script_folder.."\\pure\\pureLCS_screen.lua")
end




function init_pure_script()

    -- sets a version and show it in Pure Config (PP)
    pure.script.setVersion(1.0)
    pure.script.setAuthor("Peter Boese")
    -- if a script preset file was saved with an older version, the settings can be reset
    pure.script.resetSettingsWithNewVersion()

    pure.script.ui.addSeparator()
    if pure.system.isHDR() then
        pure.pp.forceYEBISBypass()
        pure.script.ui.addText("pureLCS script is in HDR mode")
    elseif pure.system.isVR() then
        pure.pp.forceYEBISBypass()
        pure.script.ui.addText("pureLCS script is in VR mode")
    else
        pure.script.ui.addText("pureLCS script is in Screen mode")
    end
    
    
    pureLCS__init()


--[[

    -- In Pure LCS you can modify the weather paramters.
    
    -- Note, those parameters are essential for the weather graphics and you could fall into a rabbit hole, if you change them drastically!

    pure.script.weather.defineWeather("Smoke", {
        clear = 0.9,                    -- [0..1] defines how clear the sky is and how many sunlight reaches the ground
        clouds = 0.2,                   -- [0..1] defines the amount of cloud coverage
        cloudsDensity = 0.0,            -- [0..1] defines the dense of the clouds
        fog = 0.30,                     -- [0..1] defines the view distance / amount of distance fog
        pollution = 0.8,                -- [0..1] defines the amount of near fog
        pollution_tint = rgb(1.0, 1.0, 1.0),   -- [rgb(r,g,b)] tint of the pollution / fog
        tint = rgb(0.56, 0.49, 0.63),   -- [rgb(r,g,b)] the overall tint of the weather / influences ambient light much
        ambi_mod = -0.3,                -- [-1..+] a modifier to scale the tint only while high sunangles (> 15°), will be faded to 0 with 0° sunangle
        saturation = 0.9,               -- [0..10] the saturation of the sunlight
        overcast = 0.0,                 -- [0..1] a definition to adjust the graphics for overcast ligting
        badness = 0.7,                  -- [0..1] a definition to adjust some internal algorithms like exposure a bit / mostly used for scripting
        thunder = 0.0,                  -- [0..1] defines the amount of thunder and lightning
    })


    -- You can also retrieve or set single weather paramters:
    local cloud_coverage = pure.script.weather.getWeatherParameter("BrokenClouds", "clouds")
    pure.script.weather.setWeatherParameter("BrokenClouds", "clouds", cloud_coverage*0.9)

]]

end

function set_pure_script()
    -- This function will be called if every script related things are initialized.
    -- So here is a good point to set some default values.

    if not pure.system.isVR() then
        pure.pp.set("spice.MagicBloom.active", true, true)
    end
end


function update_pure_script(dt)


    pureLCS__update(dt)
end