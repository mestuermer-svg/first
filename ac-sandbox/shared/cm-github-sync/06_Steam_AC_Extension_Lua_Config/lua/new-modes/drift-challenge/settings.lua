local Settings = {}
local ini = ac.INIConfig.scriptSettings()



Settings.debugShowStartImage = 0  
Settings.debugShowFinishImage = 0  

Settings.carCornerMultipliers = {
    frontLeft = 1,
    frontRight = 1,
    rearLeft = 1,
    rearRight = 1
}


Settings.gateOrientationOffset = 0  

Settings.lowAngleThreshold = 3  
Settings.lowAngleDuration = 0.3  
Settings.lowSpeedThreshold = 10  
Settings.lowSpeedDuration = 0.5  


Settings.showDebugDisplay = 0  


Settings.noGoZonePenaltyPoints = 10  


Settings.trajectoryGatePenaltyPoints = 5  


Settings.showMainResultsBlock = 1  


Settings.gatesTransparency = 1  

Settings.showTransparentWindow = 1  


Settings.enableArcadeScoring = ini:get("SETTINGS", "ENABLE_ARCADE_SCORING", 1) == 1


Settings.trainingMode = ini:get("SETTINGS", "TRAINING_MODE", 0) == 1

return Settings
