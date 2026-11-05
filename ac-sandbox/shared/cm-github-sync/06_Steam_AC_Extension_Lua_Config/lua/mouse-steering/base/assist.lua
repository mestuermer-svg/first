--[[
  This type of scripts uses the same API as GamepadFX scripts, but has extra inputs.
]]

local uis = ac.getUI()
local steeringFinal = 0
local gasFinal = 0
local brakeFinal = 0
local clutchFinal = 1
local forceSmooth = 0
local forceMult = 1
local slidingMult = 1

---@param dt number @Time passed in seconds.
---@param deltaX number @Horizontal mouse shift since the last frame, relative, can be adjusted in controls settings.
---@param deltaY number @Vertical mouse shift since the last frame, relative, can be adjusted in controls settings.
---@param useMouseButtons boolean @Please use mouse buttons for controls only if this value is `true`, and keep in mind middle mouse button might be used to toggle mouse steering in general.
function script.update(dt, deltaX, deltaY, useMouseButtons)
  gasFinal = ac.isKeyDown(ui.KeyIndex.LeftButton) and gasFinal + 0.05 or gasFinal - 0.1
  brakeFinal = ac.isKeyDown(ui.KeyIndex.RightButton) and brakeFinal + 0.05 or brakeFinal - 0.1
  gasFinal = math.saturate(gasFinal)
  brakeFinal = math.saturate(brakeFinal)
  clutchFinal = math.saturate((car.rpm - 1500) / 1000)

  local sliding = car.localVelocity.x / math.max(3, car.speedMs)
  slidingMult = slidingMult + (math.pow(sliding, 2) - slidingMult) * 0.02
  forceSmooth = forceSmooth + (math.clamp(car.ffbFinal, -1, 1) - forceSmooth) * 0.05

  local posMult = 2 + math.abs(steeringFinal) * 0.5 - math.min(car.speedKmh / 400, 1)
  forceMult = forceMult + (posMult - forceMult) * 0.01
  steeringFinal = steeringFinal + deltaX * forceMult - forceSmooth * 0.0001 * (1 + math.min(slidingMult, 0.5) * 2)
  steeringFinal = math.clamp(steeringFinal, -1, 1)

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

