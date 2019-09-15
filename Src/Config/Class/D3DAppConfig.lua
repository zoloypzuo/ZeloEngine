-- D3DAppConfig.lua
-- created on 2019/8/26
-- author @zoloypzuo

require("../../Script/PlainClass")
local D3D_DRIVER_TYPE_HARDWARE = 1

local D3DAppConfig = PlainClass(function(self)
    -- some window configurations
    self.mainWndCaption = "D3D11 App"
    self.clientWidth = 800
    self.clientHeight = 600

    -- some Direct3D configurations
    self.driverType = D3D_DRIVER_TYPE_HARDWARE
    self.enable4xMsaa = false
    self._4xMsaaQuality = 0

    self.engineDir = [[E:/ZeloEngineRoot/ZeloEngine/Introduction_to_3D_GameProgramming_with_Direct3D/]]
    self.configDir = [[E:/ZeloEngineRoot/ZeloEngine/Introduction_to_3D_GameProgramming_with_Direct3D/]] .. "Config/"
end)

return D3DAppConfig