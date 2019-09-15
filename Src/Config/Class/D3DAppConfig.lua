-- D3DAppConfig.lua
-- created on 2019/8/26
-- author @zoloypzuo

local D3D_DRIVER_TYPE_HARDWARE = 1

D3DAppConfig = {
    -- some window configurations
    mainWndCaption = "D3D11 App",
    clientWidth = 800,
    clientHeight = 600,

    -- some Direct3D configurations
    driverType = D3D_DRIVER_TYPE_HARDWARE,
    enable4xMsaa = false,
    _4xMsaaQuality = 0,

    engineDir = [[E:/ZeloEngineRoot/ZeloEngine/Introduction_to_3D_GameProgramming_with_Direct3D/]],
    configDir = [[E:/ZeloEngineRoot/ZeloEngine/Introduction_to_3D_GameProgramming_with_Direct3D/]] .. "Config/"
}

