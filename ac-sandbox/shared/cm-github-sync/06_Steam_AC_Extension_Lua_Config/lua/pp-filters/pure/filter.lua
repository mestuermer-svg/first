__PurePPfilter_version = 0.1

function _d(v)
    ac.debug("---",v)
    return v
end

function get__dirname()
    if ac.dirname then
        return ac.dirname()
    else
        return "assettocorsa\\extension\\lua\\pp-filters\\pure"
    end
end



local __pureConfig_path = ac.getFolder(4).."\\extension\\config-ext\\pure\\"
__pure_path = ac.getFolder(4).."\\extension\\weather\\pure\\"

-- fast Lookup tables
dofile(__pure_path.."\\utils\\utils_LUT.lua")
dofile(__pure_path.."\\utils\\utils_basics.lua")

dofile(__pure_path.."\\utils\\utils_memory_backup.lua")
dofile(__pure_path.."\\utils\\utils_connect.lua")
dofile(__pure_path.."\\utils\\utils_state.lua")

dofile(__pure_path.."\\spice\\gl.lua")

__pure__luafilter_path = get__dirname()
function ___reset__Pure_LUA_PPF___(msg)
    -- set the time of the reset in the backup memeory
    msg = msg or "___reset__Pure___"
    file_write(__pure__luafilter_path.."\\reset_dummy.lua","w+", msg)
end




-- Pure sends a signal if it runs
_l_PURE_PILOT_TONE = RAMBackup("PURE_PILOT_TONE")
_l_PURE_PILOT_TONE_update = os.clock()


purePPconnect = Connect("Pure_LUA_PPF_connect", nil, true, 1.0)
purePPstate = PureState:new(nil, true, "Pure_PP_state")



local function load_ldr_filter(path)
    local lua_path = path
    local path_end = string.sub(path, #path, #path)
    if path_end~="\\" and path_end~="/" then
        lua_path = path.."\\"
    end
    file = lua_path.."filter.lua"

    if file_exists(file) then
        dofile(file)

        if ldr_ppfilter_init then
            ldr_ppfilter_init(ui.windowSize(), lua_path)
            ac.debug("LUA PP Bridge, active", file)
        end
    end
end



function handleCommandFromPureWFX(cmd, value)
    if cmd == "wfxreset" then
        ___reset__Pure_LUA_PPF___("wfxreset")
    elseif cmd == "setPath" then
        if value~=nil and value~="" then
            load_ldr_filter(value)
        end
    end
end
purePPconnect:setCommandHandler(handleCommandFromPureWFX)




local _l_vec2_zero = vec2(0,0)
local _l_parameters = nil
local _l_ctrl_tbl = {}

function script.update(dt)
  
    local size = ui.windowSize()

    if purePPstate:checkInterface() then
        _l_parameters = purePPstate:getParameterList()
        if _l_parameters~=nil then
            for i,v in ipairs(_l_parameters) do
                if v.name~=nil and v.name~="" then
                    if v.type == TYPES.BOOLEAN then
                        _l_ctrl_tbl[v.name] = false
                    elseif v.type == TYPES.CHOICE then
                        _l_ctrl_tbl[v.name] = 0
                    elseif v.type == TYPES.INTEGER or v.type == TYPES.FLOAT then
                        _l_ctrl_tbl[v.name] = 0
                    elseif v.type == TYPES.STRING or v.type == TYPES.STRING_STORE then
                        _l_ctrl_tbl[v.name] = ""
                    end
                end
            end
        end
        ac.debug("LUA PP Bridge, parameters", #_l_parameters)
    end
    if purePPconnect:checkInterface() then
        purePPconnect:addCommand("running", "")
    end
    
    if ldr_ppfilter_update then
        for k,v in pairs(_l_ctrl_tbl) do
            if type(v)=="string" then
                _l_ctrl_tbl[k] = purePPstate:getString(k)
            else
                _l_ctrl_tbl[k] = purePPstate:getValue(k)
            end
        end
        if not ldr_ppfilter_update(dt, size, _l_ctrl_tbl) then
            -- if no effect is active
            ui.drawImage('dynamic::screen', _l_vec2_zero, size)
        end
    else
        -- if lua ppf file is established
        ui.drawImage('dynamic::screen', _l_vec2_zero, size)
    end
end
