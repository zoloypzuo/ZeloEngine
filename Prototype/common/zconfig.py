# coding=utf-8
# zconfig.py
# created on 2020/8/14
# author @zoloypzuo
# summary: config
import math

from common.ztable import Table

# ---------------------------------------------------
# default config
# ---------------------------------------------------
TheConfig = Table(
    Common=Table(
        debug=True,
        engineDir='D:\\MiniProj_01\\ZeloEngineScript',
        lockFPSTo30=True,
        localdataDir='D:\\MiniProj_01\\ZeloEngineScript\\localdata',
    ),
    Window=Table(
        mainWndCaption='ZeloEngine',
        clientWidth=640,
        clientHeight=320,
        fullScreen=False,
    ),
    Render=Table(
        # the projection matrix
        Projection=Table(
            screenFar=1000.,
            screenNear=.1,
            fieldOfView=math.pi / 4.,
        ),
        screenWidth=400,
        screenHeight=300,
        enable4xMsaa=False,
        _4xMsaaQuality=0,
        enableDepthStencilTest=True,

    ),
    Input=Table(
        mouseXSensitivity=1.,
        mouseYSensitivity=1.,
        mouseWheelSensitivity=1.,
        # 游戏命令ID => 输入索引
        # 一一映射
        # 可以通过config重载来加载不同映射表
        input_mapping={
            'test_game_cmd': 'Key-BTN_BASE3'
        }
    ),
    Python=Table(
        sys_path=[
            '',
            'C:\\windows\\SYSTEM32\\python27.zip',
            'C:\\Python27\\DLLs',
            'C:\\Python27\\lib',
            'C:\\Python27\\lib\\plat-win',
            'C:\\Python27\\lib\\lib-tk',
            'C:\\Python27',
            'C:\\Python27\\lib\\site-packages']
    )
)

OVERRIDES = {
    'TEST': {
        'debug': False,
    }
    # ---------------------------------------------------
    # platform overrides
    # ---------------------------------------------------
    #     'PC': {'a': 2},
    #     'ANDROID': {'a': 3},
    #     'IOS': {'a': 4}
}

# TheConfig = Table.parse_pairs(DEFAULT)  # 默认配置
