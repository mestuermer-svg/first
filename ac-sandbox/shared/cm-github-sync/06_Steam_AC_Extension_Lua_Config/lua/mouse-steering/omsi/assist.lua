--[[
  This type of scripts uses the same API as GamepadFX scripts, but has extra inputs.
]]

local settings = ac.INIConfig.scriptSettings():mapSection('SETTINGS', {
  SCALE_Y = 1
})

local uis = ac.getUI()
local steeringFinal = 0
local gasBrakeFinal = 0
local gasFinal = 0
local brakeFinal = 0
local clutchFinal = 1

local exchange = ac.connect({
  ac.StructItem.key('omsi-mouse-steering'),
  pos = ac.StructItem.vec2(),
  lastActive = ac.StructItem.int64()
})

ac.loadRenderThreadModule('cursor')

---@param dt number @Time passed in seconds.
---@param deltaX number @Horizontal mouse shift since the last frame, relative, can be adjusted in controls settings.
---@param deltaY number @Vertical mouse shift since the last frame, relative, can be adjusted in controls settings.
---@param useMouseButtons boolean @Please use mouse buttons for controls only if this value is `true`, and keep in mind middle mouse button might be used to toggle mouse steering in general.
function script.update(dt, deltaX, deltaY, useMouseButtons)
  clutchFinal = math.saturate((car.rpm - 1500) / 1000)

  steeringFinal = steeringFinal + deltaX
  gasBrakeFinal = gasBrakeFinal + deltaY * settings.SCALE_Y
  steeringFinal = math.clamp(steeringFinal, -1, 1)
  gasBrakeFinal = math.clamp(gasBrakeFinal, -1, 1)

  gasFinal = math.saturate(-gasBrakeFinal)
  brakeFinal = math.saturate(gasBrakeFinal)

  exchange.pos.x = steeringFinal
  exchange.pos.y = gasBrakeFinal
  exchange.lastActive = ac.getSim().frame

  local state = ac.getJoypadState()
  state.steer = steeringFinal
  if useMouseButtons then
    state.gas = gasFinal
    state.brake = brakeFinal
    state.clutch = clutchFinal
    state.handbrake = ac.isKeyDown(ui.KeyIndex.XButton2) and 1 or 0
    if uis.mouseWheel < 0 then state.gearUp = true end
    if uis.mouseWheel > 0 then state.gearDown = true end
  end	
end

