--[[
Copyright (c) 2025 Dmitrii A.

Permission is hereby granted, free of charge, to any person obtaining a copy of this
software and associated documentation files (the "Software"), to deal in the Software
without restriction, including without limitation the rights to use, copy, modify,
merge, publish, distribute, sublicense, and/or sell copies of the Software, and 
to permit persons to whom the Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be included in all copies
or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR
A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

ScriptSettings = ac.INIConfig.scriptSettings():mapSection('SETTINGS', {
	sideForceK = 0.3,
	frontForceK = 0.4,
	dampK = 0.07,
	suspTravelK = 0.15,
	baseForceK = 1
})

ac.debug('settings', ScriptSettings)

-- Setup
local mainFfbK = 1.6        -- Main FFB multiplier, similar to the Gain setting
local frontForceLimit = 0.7 -- Front force limit. 1 = 100%
local suspForceLimit = 0.5  -- Suspension force limit. 1 = 100%
local slipMultK = 3000      -- Base multiplier for lateral force from slip
local turnMultK = 20        -- Steering force multiplier
local turnMultMax = 1.2     -- Limit for the steering force
local osMult = 1.8          -- Multiplier for lateral force reduction after slip (0 disables the effect)
local rsMultK = 0.2         -- Multiplier for lateral force when rear wheels lose grip (0 disables the effect)
local iceMult = 2           -- Force multiplier on ice
local gravelMult = 0.5      -- Force multiplier on gravel
local gravelVK = 0.1        -- Vibration effect on gravel (0 disables the effect)
local dampSlowSpeedK = 0.3  -- Additional damping at low speed
-- Warning: Changing these settings may cause unpredictable steering wheel behavior.
-- This can be dangerous and may lead to injuries, especially with direct drive wheels. Adjust with caution!

-- Implementation:
local carPh = ac.getCarPhysicsRate()

-- Use this line if you want to use `ffbValue`, but exclude suspension forces from it:
-- ac.setPureFFBMultiplier(0)

local carIni = ac.INIConfig.carData(car.index, 'car.ini')
local carIniFfbMult = math.min(carIni:get('CONTROLS', 'FFMULT', 1), 10)

local steerFfb = { 0, 0 }
local frontFfb = { 0, 0 }
local lastSuspT = { 0, 0 }
local ssRearMain = { 0, 0 }
local rsMult = 1
local wheelLoad = { 0, 0 }
local surfaceMult = { 0, 0 }
local vibrationS = { 0, 0 }

local gravelS = { ac.SurfaceExtendedType.Grass, ac.SurfaceExtendedType.Gravel, ac.SurfaceExtendedType.Sand }
local iceS = { ac.SurfaceExtendedType.Ice, ac.SurfaceExtendedType.Snow }
local function checkSurface(s)
	for i = 1, #gravelS do
		if s == gravelS[i] then
			return gravelMult
		end
	end
	for i = 1, #iceS do
		if s == iceS[i] then
			return iceMult
		end
	end
	return 1
end

rsMultK = math.ceil(rsMultK * 10) / 10

local function ffbState(i)
	local lastSide = vec3()
	local lastTMult = 0
	local fsSmooth = 0

	---@param wheel ac.StateWheel
	---@param tyre ac.StateWheelPhysicsRate
	local function update(dt, wheel, tyre)
		local roadSide = (tyre.side - tyre.contactNormal * tyre.side:dot(tyre.contactNormal)):normalize()
		local sideSlip = math.dot(roadSide, tyre.velocity)

		local turnMultBase = math.pow(1 + #(roadSide - lastSide) * turnMultK, 2)
		local turnMult = math.min(turnMultBase, lastTMult)
		turnMult = math.min(turnMult, turnMultMax)
		lastSide = roadSide
		lastTMult = turnMultBase

		local sideForce = tyre.fy * ScriptSettings.baseForceK
		local frontForce = -tyre.fx
		local rsosMult = rsMultK > 0 and (1 - (rsMult - 1) / rsMultK) or 1
		local overSlip = 1 + math.smoothstep(math.saturate((math.abs(sideSlip) - 3) / 6)) * osMult * rsosMult
		local slipMult = math.abs(sideSlip) * slipMultK
		local forceMult = slipMult > math.abs(sideForce) and math.abs(sideForce) / slipMult or 1
		slipMult = slipMult * forceMult * math.sign(sideSlip) * turnMult / overSlip
		fsSmooth = fsSmooth + (frontForce - fsSmooth) * 0.1

		ac.debug('slipMult', slipMult, nil, nil, 5, ac.DebugCollectMode.Average)
		ac.debug('sideForce', math.abs(sideForce), nil, nil, 5, ac.DebugCollectMode.Average)

		if i < 2 then
			local sType = checkSurface(tyre.surfaceExtendedType)
			steerFfb[i + 1] = slipMult * dt * sType
			frontFfb[i + 1] = -fsSmooth * dt * sType
			wheelLoad[i + 1] = tyre.load
			surfaceMult[i + 1] = sType
			vibrationS[i + 1] = tyre.surfaceExtendedType == ac.SurfaceExtendedType.Gravel and 1 or 0
		end
		if i > 1 then
			ssRearMain[i - 1] = math.abs(sideSlip)
		end
	end

	return update
end

local wheels = { ffbState(0), ffbState(1), ffbState(2), ffbState(3) }
local ffbCounter = 0
local ffbSwitcher = 1

function script.update(ffbValue, ffbDamper, steerInput, steerInputSpeed, dt)
	local sideForceK = ScriptSettings.sideForceK * 0.05
	local frontForceK = ScriptSettings.frontForceK * 0.1
	local dampK = ScriptSettings.dampK
	local suspTravelK = ScriptSettings.suspTravelK * 1000

	for i = 1, 4 do
		wheels[i](dt, car.wheels[i - 1], carPh.wheels[i - 1])
	end

	local baseGain = ac.getFFBGain()
	local ffbMultFinal = baseGain * (0.5 + carIniFfbMult / 4) * mainFfbK

	local slowSpeedMult = (1 - math.smoothstep(math.saturate((carPh.speedKmh - 3) / 50)))
	rsMult = 1 + math.saturate((ssRearMain[1] + ssRearMain[2] - 6) / 6) * rsMultK
	local ffbSideForce = (steerFfb[1] + steerFfb[2]) * sideForceK * rsMult * ffbMultFinal * (1 + slowSpeedMult)
	local ffbFrontForce = (frontFfb[1] - frontFfb[2]) * frontForceK * ffbMultFinal
	ffbFrontForce = math.clamp(ffbFrontForce, -frontForceLimit, frontForceLimit)
	local dampSpeedMult = (1 + #car.velocity * 0.02) * dampK
	local ffbDamp = steerInputSpeed * dampSpeedMult / rsMult

	local suspensionSpeed = { carPh.wheels[0].suspensionTravel - lastSuspT[1], carPh.wheels[1].suspensionTravel -
	lastSuspT[2] }
	local sSpeedMain = suspensionSpeed[1] - suspensionSpeed[2]
	local ffbSusp = sSpeedMain * suspTravelK * math.pow(ffbMultFinal, 0.5)
	ffbSusp = math.clamp(ffbSusp, -suspForceLimit, suspForceLimit)
	lastSuspT = { carPh.wheels[0].suspensionTravel, carPh.wheels[1].suspensionTravel }

	if surfaceMult[1] ~= 1 or surfaceMult[2] ~= 1 then
		ffbSusp = math.abs(math.pow(1 + ffbSusp, 0.5) - 1) * math.sign(ffbSusp)
	end

	-- Gravel vibration
	local vibrationMult = (vibrationS[1] + vibrationS[2]) / 2
	if vibrationMult > 0 then
		local loadMult = math.pow((math.saturate(wheelLoad[1] / 1000) + math.saturate(wheelLoad[2] / 1000)) / 2, 0.5)
		if ffbCounter > 1 then
			ffbSwitcher = -1
		elseif ffbCounter < -1 then
			ffbSwitcher = 1
		end
		ffbCounter = ffbCounter + 0.0025 * carPh.speedKmh * ffbSwitcher * math.random(0, 2)
		ffbCounter = ffbCounter * math.saturate(math.random(0, 5))
		ffbSideForce = ffbSideForce + (ffbCounter * gravelVK * loadMult * vibrationMult * baseGain) / (1 + math.abs(ffbSideForce))
	end

	local ffbFinal = (ffbSideForce + ffbSusp + ffbFrontForce) * math.saturate(carPh.speedKmh - 3)
	ffbDamper = math.abs(ffbDamp) + slowSpeedMult * dampSlowSpeedK
	return ffbFinal, ffbDamper
end
