-- PureVR Slim Gamma Balanced Edition – Pure 2.38 Compatible

local M = {}

-- Pure registration so filter is accepted as official VR filter
function M.onInit()
  if pure and pure.registerPPFilter then
    pure.registerPPFilter("pureVR_slim_gamma", 1)
  end
end

function M.onSessionStart()
  if pure and pure.initVR then
    pure.initVR()
  end
end

function M.onBeforeFrame()
  if pure and pure.preProcess then
    pure.preProcess()
  end
end

function M.onFrame()
  if pure and pure.applyVR then
    pure.applyVR()
  end
end

function M.onAfterFrame()
  if pure and pure.postProcess then
    pure.postProcess()
  end
end

return M
